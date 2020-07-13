{
    function f(a, b, c) -> x, y, z
    {
        x, y, z := f(1, 2, 3)
        x := add(x, 1)
    }
}
// ----
// step: unusedFunctionParameterPruner
//
// {
//     function f() -> x, y, z
//     {
//         x, y, z := f_1(1, 2, 3)
//         x := add(x, 1)
//     }
//     function f_1(a, b, c) -> x, y, z
//     { x, y, z := f() }
// }
