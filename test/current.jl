using Typstry
using Makie
using CairoMakie
using MakieTypstEngine
using MathTeXEngine
using FreeTypeAbstraction

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
#set text(font: "Times New Roman", 11pt)
#show math.equation: set text(font: "Fira Math")
$sum x/y^2$
test *test*
"""


output_elements = MakieTypstEngine.generate_typst_elements("", example_str, "")


teststring = raw"""
#set page(margin: 1em, height: auto, width: auto, fill: white)
#set text(16pt, font: "JuliaMono")
#set text(40.0pt)
#set text(font: "Fira Sans", 11pt)
#show math.equation: set text(font: "Fira Math")


// user code

$1/(1 + e^(-beta x))$"""

font = findfont("Fira Math")

t, l = MakieTypstEngine.generate_typst_elements("", teststring, "")

l


t[1]["content"]
gc = MakieTypstEngine.to_glyphcollection(t)

tex_elems = [i for i in generate_tex_elements(L"\frac{1}{1+e^{-\beta x}}")]

FreeTypeAbstraction.glyph_index(tex_elems[1])

FreeTypeAbstraction.glyph_index(font, elems[2] |> first)

output_elements[2][1]

let
    f = Figure(size = (1600, 900))
    ax = Axis(f[1, 1], yreversed = false, autolimitaspect = 1.0)
    ax2 = Axis(f[1, 2], yreversed = false, autolimitaspect = 1.0)

    locs = [i["location"] for i in output_elements]
    # for i in gc
    #     poly!(ax, i)
    # end
    poly!(ax, gc)
    for i in t
        text!(ax2, Point2f(1, -1) .* i["location"], text = i["content"]["text"], markerspace = :data, fontsize = 11, font = "Fira Math")
    end
    scatter!(ax, locs)
    lines!(ax, [output_elements[end]["location"], output_elements[end]["content"]["to"]])
    # limits!(ax, 10, 40, 20, 0)
    limits!(ax2, 10, 40, -20, 0)
    f
end


let
    f = Figure(size = (1600, 900), fontsize = 10)
    ax = Axis(f[1, 1], xlabel = typst"$1/(1 + e^(-beta x))$")
    f
end