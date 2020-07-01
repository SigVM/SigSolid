{
    function a() { b() }
    function b() { a() }
}
// ----
// : movable, movable apart from effects, can be removed, can be removed if no msize
// a: movable, movable apart from effects, can be removed, can be removed if no msize, can loop
// b: movable, movable apart from effects, can be removed, can be removed if no msize, can loop
