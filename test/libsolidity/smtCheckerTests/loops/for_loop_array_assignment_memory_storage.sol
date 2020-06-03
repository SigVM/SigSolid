pragma experimental SMTChecker;

contract LoopFor2 {
	uint[] a;

	function testUnboundedForLoop(uint n, uint[] memory b, uint[] memory c) public {
		b[0] = 900;
		a = b;
		require(n > 0 && n < 100);
		for (uint i = 0; i < n; i += 1) {
			b[i] = i + 1;
			c[i] = b[i];
		}
		assert(b[0] == c[0]);
		assert(a[0] == 900);
		assert(b[0] == 900);
	}
}
// ====
// SMTSolvers: z3
// ----
// Warning 1218: (225-231): Error trying to invoke SMT solver.
// Warning 1218: (245-250): Error trying to invoke SMT solver.
// Warning 4661: (274-294): Assertion violation happens here
// Warning 4661: (321-340): Assertion violation happens here
