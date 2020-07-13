{
	{ let d, e, i := f(1, 2, 3) }
	function f(a, b, c) -> x, y, z
	{
	   y := mload(a)
	   z := mload(c)
	}
}
// ----
// step: unusedFunctionParameterPruner
//
// {
//     { let d, e, i := f_1(1, 2, 3) }
//     function f(a, c) -> x, y, z
//     {
//         y := mload(a)
//         z := mload(c)
//     }
//     function f_1(a, b, c) -> x, y, z
//     { x, y, z := f(a, c) }
// }
