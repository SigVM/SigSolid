pragma experimental SMTChecker;

contract C
{
	function f(uint x) public pure {
		require(x < 100);
		for(uint i = 0; i < 10; ++i) {
			x = x + 1;
		}
		assert(x > 0);
	}
}
// ----
// Warning 1218: (153-166): Error trying to invoke SMT solver.
// Warning 4661: (153-166): Assertion violation happens here
