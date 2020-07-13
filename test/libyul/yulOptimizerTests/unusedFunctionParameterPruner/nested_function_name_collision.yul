// Test case where the name `g` occurs at two different places.
{
    function f(c) -> u
    {
        u := g(c)
        function g(d) -> w
        {
            w := 13
        }
    }

    function h(c) -> u
    {
        u := g(c)
        function g(d) -> w
        {
            w := 13
        }
    }

}
// ----
// step: unusedFunctionParameterPruner
//
// {
//     function g() -> w
//     { w := 13 }
//     function g_1(d) -> w
//     { w := g() }
//     function f(c) -> u
//     { u := g_1(c) }
//     function g_3() -> w_5
//     { w_5 := 13 }
//     function g_3_2(d_4) -> w_5
//     { w_5 := g_3() }
//     function h(c_1) -> u_2
//     { u_2 := g_3_2(c_1) }
// }
