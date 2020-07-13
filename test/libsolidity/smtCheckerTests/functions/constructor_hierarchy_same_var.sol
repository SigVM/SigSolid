pragma experimental SMTChecker;
contract C {
	uint a;
	constructor(uint x) public {
		a = x;
	}
}

contract A is C {
	constructor() C(2) public {
		assert(a == 0);
		assert(C.a == 0);
	}
}
// ----
// Warning 6328: (148-162): Assertion violation happens here
// Warning 6328: (166-182): Assertion violation happens here
