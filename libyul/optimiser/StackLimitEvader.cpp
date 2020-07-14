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
#include <libevmasm/Exceptions.h>

using namespace std;
using namespace solidity;
using namespace solidity::yul;

MemoryOffsetAllocator::MemoryOffsetAllocator(
	map<YulString, FunctionStackErrorInfo> const& _functionStackErrorInfo,
	set<YulString> const& _functionsInCycle,
	map<YulString, set<YulString>> const& _callGraph
): m_functionStackErrorInfo(_functionStackErrorInfo), m_functionsInCycle(_functionsInCycle), m_callGraph(_callGraph)
{
}

uint64_t MemoryOffsetAllocator::run() { return run({}); }

uint64_t MemoryOffsetAllocator::run(YulString _function)
{
	if (m_nextAvailableSlot.count(_function))
		return m_nextAvailableSlot[_function];

	// Assign to zero early to guard against recursive calls.
	m_nextAvailableSlot[_function] = 0;

	uint64_t nextAvailableSlot = 0;
	if (m_callGraph.count(_function))
		for (auto child: m_callGraph.at(_function))
			nextAvailableSlot = std::max(run(child), nextAvailableSlot);

	if (m_functionStackErrorInfo.count(_function))
	{
		assertThrow(
			!m_functionsInCycle.count(_function),
			evmasm::StackTooDeepException,
			"Stack too deep in recursive function."
		);
		auto const& stackErrorInfo = m_functionStackErrorInfo.at(_function);
		yulAssert(!m_slotAllocations.count(_function), "");
		auto& assignedSlots = m_slotAllocations[_function];
		for (auto const& variable: stackErrorInfo.variables)
			if (variable.empty())
			{
				// TODO: Too many function arguments or return parameters.
			}
			else
				assignedSlots[variable] = nextAvailableSlot++;
	}

	return (m_nextAvailableSlot[_function] = nextAvailableSlot);
}

void StackLimitEvader::run(OptimiserStepContext& _context, Object& _object, bool _optimizeStackAllocation)
{
	// Determine which variables need to be moved.
	map<YulString, FunctionStackErrorInfo> functionStackErrorInfo = CompilabilityChecker::run(
		_context.dialect,
		_object,
		_optimizeStackAllocation
	);
	if (functionStackErrorInfo.empty())
		return;

	run(_context, _object, functionStackErrorInfo);
}

void StackLimitEvader::run(
	OptimiserStepContext& _context,
	Object& _object,
	std::map<YulString, FunctionStackErrorInfo> const& _functionStackErrorInfo)
{
	yulAssert(_object.code, "");
	auto const* evmDialect = dynamic_cast<EVMDialect const*>(&_context.dialect);
	yulAssert(
		evmDialect && evmDialect->providesObjectAccess(),
		"StackToMemoryMover can only be run on objects using the EVMDialect with object access."
	);

	// Find the literal argument of the ``memoryinit`` call, if there is a unique such call, otherwise abort.
	Literal* memoryInitLiteral = nullptr;
	if (
		auto memoryInits = FunctionCallFinder::run(*_object.code, "memoryinit"_yulstring);
		memoryInits.size() == 1
	)
		memoryInitLiteral = std::get_if<Literal>(&memoryInits.front()->arguments.back());
	if (!memoryInitLiteral)
		return;
	u256 reservedMemory = valueOfLiteral(*memoryInitLiteral);

	map<YulString, set<YulString>> callGraph = CallGraphGenerator::callGraph(*_object.code).functionCalls;

	// Collect all names of functions contained in cycles in the callgraph.
	// TODO: this algorithm is suboptimal and can be improved. It also overlaps with Semantics.cpp.
	std::set<YulString> containedInCycle;
	auto findCycles = [
		&,
		visited = std::map<YulString, uint64_t>{},
		currentPath = std::vector<YulString>{}
	](YulString _node, auto& _recurse) mutable -> void
	{
		if (auto it = std::find(currentPath.begin(), currentPath.end(), _node); it != currentPath.end())
			containedInCycle.insert(it, currentPath.end());
		else
		{
			visited[_node] = currentPath.size();
			currentPath.emplace_back(_node);
			for (auto const& child: callGraph[_node])
				_recurse(child, _recurse);
			currentPath.pop_back();
		}
	};
	findCycles(YulString{}, findCycles);

	MemoryOffsetAllocator memoryOffsetAllocator{_functionStackErrorInfo, containedInCycle, callGraph};
	uint64_t requiredSlots = 0;
	try {
		requiredSlots = memoryOffsetAllocator.run();
	} catch (evmasm::StackTooDeepException& _e) {
		return;
	}

	StackToMemoryMover{_context, reservedMemory, memoryOffsetAllocator.slotAllocations()}(*_object.code);
	memoryInitLiteral->value = YulString{util::toCompactHexWithPrefix(reservedMemory + 32 * requiredSlots)};
}