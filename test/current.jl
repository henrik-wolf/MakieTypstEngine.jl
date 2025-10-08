using Typstry
using Makie
using CairoMakie
using MakieTypstEngine
using MathTeXEngine



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
    )

    f
end


example_str = raw"""// template.typ
#set page(paper: "a6")
#set text(font: "Fira Math", 11pt)
#show math.equation: set text(font: "Fira Math")
$sum x/y^2$
"""

teststring = raw"""
#set page(margin: 1em, height: auto, width: auto, fill: white)
#set text(16pt, font: "JuliaMono")
#set text(40.0pt)
#set text(font: "Fira Math", 11pt)
#show math.equation: set text(font: "Fira Math")


// user code

$x^2$"""

output_elements = MakieTypstEngine.generate_typst_elements("", teststring, "")

els = generate_tex_elements(L"x^2")