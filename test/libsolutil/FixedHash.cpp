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
 * Unit tests for FixedHash.
 */

#include <libsolutil/FixedHash.h>

#include <boost/test/unit_test.hpp>

using namespace std;

namespace dev
{
namespace test
{

BOOST_AUTO_TEST_SUITE(FixedHash)

BOOST_AUTO_TEST_CASE(empty)
{
//	BOOST_CHECK_EQUAL(
//		keccak256(bytes()),
//		FixedHash<32>("0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470")
//	);
}

BOOST_AUTO_TEST_SUITE_END()

}
}
