{
    function f(a, b)
    {
        a := mload(a)
        a := add(a, 1)
    }
}
// ----
// step: unusedFunctionParameterPruner
//
// {
//     function f(a)
//     {
//         a := mload(a)
//         a := add(a, 1)
//     }
//     function f_1(a, b)
//     { f(a) }
// }
