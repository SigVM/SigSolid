library L {
    function f(uint a) internal pure {}
    function g(uint a) internal pure {}
}
contract C {
    using L for *;
    function f(bool x) pure public {
        uint t = 8;
        (x ? t.f : t.g)();
    }
}
// ----
// TypeError 1080: (192-205): True expression's type function (uint256) pure does not match false expression's type function (uint256) pure.
// TypeError 6160: (191-208): Wrong argument count for function call: 0 arguments given but expected 1.
