{
    let z := f(1)
    function f(x) -> y
	{
		let w := mload(1)
		y := mload(w)
	}
}
// ----
// step: unusedFunctionParameterPruner
//
// {
//     let z := f_1(1)
//     function f() -> y
//     {
//         let w := mload(1)
//         y := mload(w)
//     }
//     function f_1(x) -> y
//     { y := f() }
// }
