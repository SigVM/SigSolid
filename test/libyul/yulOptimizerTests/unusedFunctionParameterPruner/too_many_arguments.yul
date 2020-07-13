{
    function f(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18) -> y, z
    {
       y := mload(x3)
       z := mload(x7)
    }
}
// ----
// step: unusedFunctionParameterPruner
//
// {
//     function f(x3, x7) -> y, z
//     {
//         y := mload(x3)
//         z := mload(x7)
//     }
//     function f_1(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18) -> y, z
//     { y, z := f(x3, x7) }
// }
