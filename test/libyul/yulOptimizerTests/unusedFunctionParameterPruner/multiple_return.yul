{
	function f(a) -> y, z
	{
	   y := mload(1)
	   z := mload(2)
	}

	let a, b := f(sload(0))
}
// ----
// step: unusedFunctionParameterPruner
//
// {
//     let a_1, b := f_1(sload(0))
//     function f() -> y, z
//     {
//         y := mload(1)
//         z := mload(2)
//     }
//     function f_1(a) -> y, z
//     { y, z := f() }
// }
