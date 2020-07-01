{
  function f() -> x { x := g() }
  function g() -> x { for {} 1 {} {} }
  pop(f())
}
// ----
// : movable, movable apart from effects, can be removed, can be removed if no msize, can loop
// f: movable, movable apart from effects, can be removed, can be removed if no msize, can loop
// g: movable, movable apart from effects, can be removed, can be removed if no msize, can loop
