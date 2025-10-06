using Typstry
using Makie
using CairoMakie
using MakieTypstEngine



typst"""
= test hallo!
$x+y^2$
"""

context



TypstContext().context


a = [1, 2, 3]

a = typst"\(a)"


let
    f = Figure(size = (1400, 700), fontsize = 40)
    ax = Axis(
        f[1, 1],
        title = "Test",
        xlabel = L"\frac{\int_3^{200} x^2 dx}{z^6}",
        ylabel = typst"$x^2$",
        xticks = ([1.0, 2.0, 3.0], [typst"a", typst"b", "c"]),
    )

    f
end