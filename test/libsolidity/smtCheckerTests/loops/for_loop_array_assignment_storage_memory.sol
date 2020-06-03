pragma experimental SMTChecker;

contract LoopFor2 {
	uint[] b;
	uint[] c;

	function testUnboundedForLoop(uint n) public {
		b[0] = 900;
		uint[] memory a = b;
		require(n > 0 && n < 100);
		for (uint i = 0; i < n; i += 1) {
			b[i] = i + 1;
			c[i] = b[i];
		}
		// This is safe but too hard to solve currently.
		assert(b[0] == c[0]);
		assert(a[0] == 900);
		assert(b[0] == 900);
	}
}
// ----
// Warning 1218: (216-222): Error trying to invoke SMT solver.
// Warning 1218: (236-241): Error trying to invoke SMT solver.
// Warning 4661: (363-382): Assertion violation happens here
