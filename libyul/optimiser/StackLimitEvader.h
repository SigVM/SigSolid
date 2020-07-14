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
/**
 * Optimisation stage that assigns memory offsets to variables that would become unreachable if
 * assigned a stack slot as usual.
 */

#pragma once

#include <libyul/optimiser/OptimiserStep.h>

namespace solidity::yul
{

struct Object;
struct FunctionStackErrorInfo;

// Walks the call graph using a Depth-First-Search assigning memory offsets to variables.
// - The leaves of the call graph will get the lowest offsets, increasing towards the root.
// - ``m_nextAvailableSlot`` maps a function to the next available slot that can be used by another
//   function that calls it.
// - For each function starting from the root of the call graph:
//   - Visit all children that are not already visited.
//   - Determe the maximum value ``n`` of the values of ``m_nextAvailableSlot`` among the children.
//   - If the function itself contains variables that need memory slots, but is contained in a cycle,
//     abort the process as failure.
//   - If not, assign each variable its slot starting starting from ``n`` (incrementing it).
//   - Assign ``m_nextAvailableSlot`` of the function to ``n``.
class MemoryOffsetAllocator
{
public:
	MemoryOffsetAllocator(
		std::map<YulString, FunctionStackErrorInfo> const& _functionStackErrorInfo,
		std::set<YulString> const& _functionsInCycle,
		std::map<YulString, std::set<YulString>> const& _callGraph
	);
	uint64_t run();
	std::map<YulString, std::map<YulString, uint64_t>> const& slotAllocations() const { return m_slotAllocations; }
private:
	uint64_t run(YulString _function);
	std::map<YulString, FunctionStackErrorInfo> const& m_functionStackErrorInfo;
	std::set<YulString> const& m_functionsInCycle;
	std::map<YulString, std::set<YulString>> const& m_callGraph;

	std::map<YulString, std::map<YulString, uint64_t>> m_slotAllocations;
	std::map<YulString, uint64_t> m_nextAvailableSlot;
};


/**
 * Optimisation stage that assigns memory offsets to variables that would become unreachable if
 * assigned a stack slot as usual.
 *
 * Uses CompilabilityChecker to determine which variables in which functions are unreachable.
 *
 * Only variables outside of functions contained in cycles in the call graph are considered. Thereby it is possible
 * to assign globally fixed memory offsets to the variable. If a variable in a function contained in a cycle in the
 * call graph is reported as unreachable, the process is aborted.
 *
 * Offsets are assigned to the variables, s.t. on every path through the call graph each variable gets a unique offset
 * in memory. However, distinct paths through the call graph can use the same memory offsets for their variables.
 *
 * The current argument to the ``memoryinit`` call is used as base memory offset and then replaced by the offset past
 * the last memory offset used for a variable on any path through the call graph.
 *
 * Finally, the StackToMemoryMover is called to actually move the variables to their offsets in memory.
 *
 * Prerequisite: Disambiguator, TODO: anything else?
 */
class StackLimitEvader
{
public:
	static void run(
		OptimiserStepContext& _context,
		Object& _object,
		bool _optimizeStackAllocation
	);
	static void run(
		OptimiserStepContext& _context,
		Object& _object,
		std::map<YulString, FunctionStackErrorInfo> const& _functionStackErrorInfo
	);
};

}
