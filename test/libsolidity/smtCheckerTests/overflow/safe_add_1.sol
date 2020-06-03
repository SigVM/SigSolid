pragma experimental SMTChecker;

contract C
{
	function add(uint x, uint y) public pure returns (uint) {
		require(x + y >= x);
		return x + y;
	}
}
// ----
// Warning 2529: (115-120): Overflow (resulting value larger than 2**256 - 1) happens here
