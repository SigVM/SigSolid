/*
	This file is part of solidity.

	solidity is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	solidity is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with solidity.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <libyul/optimiser/StackLimitEvader.h>
#include <libyul/optimiser/CallGraphGenerator.h>
#include <libyul/optimiser/FunctionCallFinder.h>
#include <libyul/optimiser/NameDispenser.h>
#include <libyul/optimiser/StackToMemoryMover.h>
#include <libyul/backends/evm/EVMDialect.h>
#include <libyul/AsmData.h>
#include <libyul/CompilabilityChecker.h>
#include <libyul/Dialect.h>
#include <libyul/Exceptions.h>
#include <libyul/Object.h>
#include <libyul/Utilities.h>
#include <libsolutil/Algorithms.h>
#include <libsolutil/CommonData.h>
#include <libsolutil/Visitor.h>
#include <libevmasm/Exceptions.h>

using namespace std;
using namespace solidity;
using namespace solidity::yul;

namespace
{
// Walks the call graph using a Depth-First-Search assigning memory offsets to variables.
// - The leaves of the call graph will get the lowest offsets, increasing towards the root.
// - ``nextAvailableSlot`` maps a function to the next available slot that can be used by another
//   function that calls it.
// - For each function starting from the root of the call graph:
//   - Visit all children that are not already visited.
//   - Determe the maximum value ``n`` of the values of ``nextAvailableSlot`` among the children.
//   - If the function itself contains variables that need memory slots, but is contained in a cycle,
//     abort the process as failure.
//   - If not, assign each variable its slot starting starting from ``n`` (incrementing it).
//   - Assign ``nextAvailableSlot`` of the function to ``n``.
struct MemoryOffsetAllocator
{
	map<YulString, set<YulString>> const& unreachableVariables;
	map<YulString, set<YulString>> const& callGraph;

	uint64_t run(YulString _function = YulString{})
	{
		if (nextAvailableSlot.count(_function))
			return nextAvailableSlot[_function];

		// Assign to zero early to guard against recursive calls.
		nextAvailableSlot[_function] = 0;

		uint64_t nextSlot = 0;
		if (callGraph.count(_function))
			for (auto child: callGraph.at(_function))
				nextSlot = std::max(run(child), nextSlot);

		if (unreachableVariables.count(_function))
		{
			yulAssert(!slotAllocations.count(_function), "");
			auto& assignedSlots = slotAllocations[_function];
			for (auto const& variable: unreachableVariables.at(_function))
				if (variable.empty())
				{
					// TODO: Too many function arguments or return parameters.
				}
				else
					assignedSlots[variable] = nextSlot++;
		}

		return (nextAvailableSlot[_function] = nextSlot);
	}

	map<YulString, map<YulString, uint64_t>> slotAllocations{};
	map<YulString, uint64_t> nextAvailableSlot{};
};

/// Checks if @a _initFreeMPtr is effectively the first proper statement in @a _block.
bool validateInitFreeMPtr(FunctionCall* _initFreeMPtr, Block& _block)
{
	for (Statement& statement: _block.statements)
		if (std::optional<bool> result = std::visit(util::GenericVisitor{
			[&](Block& _subBlock) -> std::optional<bool> {
				return validateInitFreeMPtr(_initFreeMPtr, _subBlock);
			},
			[&](FunctionDefinition&) -> std::optional<bool> { return std::nullopt; },
			[&](ExpressionStatement& _exprStmt) -> std::optional<bool> {
				return get_if<FunctionCall>(&_exprStmt.expression) == _initFreeMPtr;
			},
			[&](auto&&) -> std::optional<bool> { return false; }
		}, statement))
			return *result;
	return false;
}

}

void StackLimitEvader::run(OptimiserStepContext& _context, Object& _object, bool _optimizeStackAllocation)
{
	run(_context, _object, CompilabilityChecker(
		_context.dialect,
		_object,
		_optimizeStackAllocation
	).unreachableVariables);
}

void StackLimitEvader::run(
	OptimiserStepContext& _context,
	Object& _object,
	std::map<YulString, std::set<YulString>> const& _unreachableVariables)
{
	yulAssert(_object.code, "");
	auto const* evmDialect = dynamic_cast<EVMDialect const*>(&_context.dialect);
	yulAssert(
		evmDialect && evmDialect->providesObjectAccess(),
		"StackToMemoryMover can only be run on objects using the EVMDialect with object access."
	);

	// Find the literal argument of the ``initfreemptr`` call, if there is a unique such call, otherwise abort.
	Literal* initFreeMPtrLiteral = nullptr;
	if (
		auto initFreeMPtrs = FunctionCallFinder::run(*_object.code, "initfreemptr"_yulstring);
		initFreeMPtrs.size() == 1
	)
		if (validateInitFreeMPtr(initFreeMPtrs.front(), *_object.code))
			initFreeMPtrLiteral = std::get_if<Literal>(&initFreeMPtrs.front()->arguments.back());
	if (!initFreeMPtrLiteral)
		return;
	u256 reservedMemory = valueOfLiteral(*initFreeMPtrLiteral);

	CallGraph callGraph = CallGraphGenerator::callGraph(*_object.code);

	// We cannot move variables in recursive functions to fixed memory offsets.
	for (YulString function: callGraph.recursiveFunctions())
		if (_unreachableVariables.count(function))
			return;

	MemoryOffsetAllocator memoryOffsetAllocator{_unreachableVariables, callGraph.functionCalls};
	uint64_t requiredSlots = memoryOffsetAllocator.run();

	StackToMemoryMover{_context, reservedMemory, memoryOffsetAllocator.slotAllocations}(*_object.code);
	initFreeMPtrLiteral->value = YulString{util::toCompactHexWithPrefix(reservedMemory + 32 * requiredSlots)};
}