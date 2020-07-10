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
 * UnusedFunctionParameterPruner: Optimiser step that removes unused-parameters function.
 */

#include <libyul/optimiser/UnusedFunctionParameterPruner.h>
#include <libyul/optimiser/NameCollector.h>
#include <libyul/optimiser/NameDispenser.h>
#include <libyul/optimiser/NameDisplacer.h>
#include <libyul/AsmData.h>

#include <libsolutil/CommonData.h>
#include <libsolutil/Visitor.h>

using namespace std;
using namespace solidity::util;
using namespace solidity::yul;
using namespace solidity::langutil;

namespace
{

/**
 * First step of UnusedFunctionParameterPruner: Find functions with whose parameters are not used in
 * its body.
 */
struct FindFunctionsWithUnusedParameters
{
	void operator()(FunctionDefinition const& _function)
	{
		map<YulString, size_t> namesFound = ReferencesCounter::countReferences(_function.body);

		// We skip if the function body
		// 1. is empty
		// 2. is a single statement, that is an assignment statement with RHS being a function call
		// 3. is a single expression-statement, that is a function call
		if (_function.body.statements.empty())
			return;
		if (_function.body.statements.size() == 1)
		{
			Statement const& e = _function.body.statements[0];
			if (holds_alternative<Assignment>(e))
			{
				if (holds_alternative<FunctionCall>(*get<Assignment>(e).value))
					return;
			}
			else if (holds_alternative<ExpressionStatement>(e))
				if (holds_alternative<FunctionCall>(get<ExpressionStatement>(e).expression))
					return;
		}

		TypedNameList reducedParameters;

		for (auto const& parameter: _function.parameters)
			if (namesFound.count(parameter.name))
				reducedParameters.push_back(parameter);

		if (reducedParameters.size() < _function.parameters.size())
			reducedTypeNames[_function.name] = move(reducedParameters);
	}

	// Map between function name and list of parameters after removing unused ones.
	map<YulString, TypedNameList> reducedTypeNames;
};

/**
 * Second step of UnusedFunctionParameterPruner: replace all references to functions with unused
 * parameters with a new name.
 *
 * For example: `function f(x) -> y { y := 1 }` will be replaced with something
 * like : `function f_1(x) -> y { y := 1 }`  and all references to `f` by `f_1`.
 */
struct ReplaceFunctionName: public NameDisplacer
{
	explicit ReplaceFunctionName(
		NameDispenser& _dispenser,
		std::set<YulString> const& _namesToFree
	): NameDisplacer(_dispenser, _namesToFree) {}
};

/**
 * Third step of UnusedFunctionParameterPruner: introduce a new function in the block with body of
 * the old one. Replace the body of the old one with a function call to the new one with reduced
 * parameters.
 *
 * For example: introduce a new function `f` with the same the body as `f_1`, but with reduced
 * parameters, i.e., `function f() -> y { y := 1 }`. Now replace the body of `f_1` with a call to
 * `f`, i.e., `f_1(x) -> y { y := f() }`.
 */
class AddPrunedFunction
{
public:
	explicit AddPrunedFunction(
		map<YulString, TypedNameList> const& _reducedTypeNames,
		map<YulString, YulString> const&  _translations
	):
		m_reducedTypeNames(_reducedTypeNames),
		m_translations(_translations),
		m_inverseTranslations(invertMap(m_translations))
	{}

	void operator()(Block& _block)
	{
		iterateReplacing(_block.statements, [&](Statement& _s) -> optional<vector<Statement>>
		{
			if (holds_alternative<FunctionDefinition>(_s))
			{
				FunctionDefinition& old = get<FunctionDefinition>(_s);
				if (m_inverseTranslations.count(old.name))
					return addFunction(old);
			}

			return nullopt;
		});
	}

private:
	vector<Statement> addFunction(FunctionDefinition& _old);

	map<YulString, TypedNameList> const& m_reducedTypeNames;

	map<YulString, YulString> const& m_translations;
	map<YulString, YulString> m_inverseTranslations;
};

vector<Statement> AddPrunedFunction::addFunction(FunctionDefinition& _old)
{
	SourceLocation loc = _old.location;
	auto newName = m_inverseTranslations.at(_old.name);

	FunctionDefinition newFunction{
		loc,
		newName,
		m_reducedTypeNames.at(newName), // parameters
		_old.returnVariables,
		{loc, {}} // body
	};

	swap(newFunction.body, _old.body);

	FunctionCall call;
	call.location = loc;
	call.functionName = Identifier{loc, newFunction.name};
	for (auto const& p: m_reducedTypeNames.at(newFunction.name))
		call.arguments.emplace_back(Identifier{loc, p.name});

	// Replace the body of `f_1` by an assignment which calls `f`, i.e.,
	// `return_parameters = f(reduced_parameters)`
	if (!_old.returnVariables.empty())
	{
		Assignment assignment;
		assignment.location = loc;

		// The LHS of the assignment.
		for (auto const& r: _old.returnVariables)
			assignment.variableNames.emplace_back(Identifier{loc, r.name});

		assignment.value = make_unique<Expression>(move(call));

		_old.body.statements.emplace_back(move(assignment));
	}
	else
		_old.body.statements.emplace_back(ExpressionStatement{loc, move(call)});

	return make_vector<Statement>(move(newFunction), move(_old));
}

} // anonymous namespace

void UnusedFunctionParameterPruner::run(OptimiserStepContext& _context, Block& _block)
{
	FindFunctionsWithUnusedParameters find;
	for (auto const& statement: _block.statements)
		if (holds_alternative<FunctionDefinition>(statement))
			find(std::get<FunctionDefinition>(statement));

	if (find.reducedTypeNames.empty())
		return;

	set<YulString> namesToFree =
		applyMap(find.reducedTypeNames, [](auto const& p) { return p.first; }, set<YulString>{});
	ReplaceFunctionName replace{_context.dispenser, namesToFree};
	replace(_block);

	AddPrunedFunction add{find.reducedTypeNames, replace.translations()};
	add(_block);
}
