{
	function f(a) -> x { x := a }
	function g(b) -> y { pop(g(b)) }
}
// ----
// step: unusedFunctionParameterPruner
//
// {
//     function f(a) -> x
//     { x := a }
//     function g(b) -> y
//     { pop(g(b)) }
// }
