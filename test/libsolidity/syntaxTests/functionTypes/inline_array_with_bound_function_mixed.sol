library L {
    function f(uint a) internal pure {}
}
contract C {
    using L for *;
    function f() pure public {
        uint t;
        function() pure x;
        [t.f, x][0]({a: 8});
    }
}
// ----
// TypeError 6378: (168-176): Unable to deduce common type for array elements.
