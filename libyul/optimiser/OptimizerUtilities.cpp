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
 * Some useful snippets for the optimiser.
 */

#include <libyul/optimiser/OptimizerUtilities.h>

#include <libyul/backends/evm/EVMDialect.h>
#include <libyul/AsmData.h>
#include <libyul/AsmParser.h>

#include <liblangutil/Token.h>
#include <libsolutil/CommonData.h>

#include <boost/range/algorithm_ext/erase.hpp>

using namespace std;
using namespace solidity;
using namespace solidity::langutil;
using namespace solidity::util;
using namespace solidity::yul;

void yul::removeEmptyBlocks(Block& _block)
{
	auto isEmptyBlock = [](Statement const& _st) -> bool {
		return holds_alternative<Block>(_st) && std::get<Block>(_st).statements.empty();
	};
	boost::range::remove_erase_if(_block.statements, isEmptyBlock);
}

// TODO: Should this be part of the Dialect instead?
bool yul::isRestrictedIdentifier(Dialect const& _dialect, YulString const& _identifier)
{
	if (TokenTraits::keywordByName(_identifier.str()) != Token::Identifier)
		return true;
	if (_identifier.empty() || _dialect.builtin(_identifier))
		return true;
	if (dynamic_cast<EVMDialect const*>(&_dialect))
		return Parser::instructions().count(_identifier.str());
	return false;
}
