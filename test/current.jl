using CairoMakie
using MakieTypstEngine

using MathTeXEngine
using FreeTypeAbstraction

MakieTypstEngine.to_mathfont(::Val{Symbol("fira sans")}, font) = "fira math"

function MakieTypstEngine.from_typst_font(::Val{Symbol("fira sans")}, font_dict)
    var = font_dict["variant"]
    # somehow, Makie.to_font did not give me the right font for this one...
    if var["style"] == "italic" && var["weight"] == 400
        return "/Users/henrikwolf/Library/Fonts/FiraSans-Italic.ttf"
    end
    # when using the full "italic" string, Makie.to_font resolves to a different font family
    style = var["style"] == "italic" ? "it" : ""
    # the numerical weights map to stuff like "thin", "regular", "bold" and so on...
    weight = if var["weight"] == 400
        "regular"
    elseif var["weight"] == 700
        "bold"
    else
        throw(error("unknown weight encountered"))
    end
    font_string = "fira sans $style $weight"
    return font_string
end

typst"""
= test hallo!
$x+y^2$
"""

context

MakieTypstEngine.to_mathfont

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
#set text(font: "Fira Sans", 11pt, weight: "bold")
#show math.equation: set text(font: "Fira Math")
$sum x/y^2$
test *test* test
"""

MakieTypstEngine.get_run_cmd(["test", "test2/4/test"])

let
    f = Figure(size = (400, 800))
    a = [1, 2, 3]
    # Label(f[1, 1], typst"$sin(x^2) = \(a; mode=math)$")
    Label(f[1, 1], typst"""$ sum x/y^2 $ test *test* _test_

    test""", fontsize = 40, font = "Fira Sans")
    ax = Axis(f[2, 1])
    text!(ax, Point2f(0, 0), text = typst"$sin(x^2)$ 

    test", font = "Fira Sans", align = (:left, :center), justification = :right)
    f
end


output_elements = MakieTypstEngine.generate_typst_elements("", example_str)

output_elements[1][end]

a = Makie.to_font("Fira Sans")

MakieTypstEngine.to_mathfont(a)

FreeTypeAbstraction.family_name(a)


teststring = raw"""
#set page(margin: 1em, height: auto, width: auto, fill: white)
#set text(16pt, font: "JuliaMono")
#set text(40.0pt)
#set text(font: "Fira Sans", 11pt)
#show math.equation: set text(font: "Fira Math")


// user code

$1/(1 + e^(-beta x))$"""

font = findfont("Fira Math")

id = FreeTypeAbstraction.glyph_index(font, 's')
Makie.GlyphExtent(font, id)
Makie.GlyphExtent(font, 's')

t, l = MakieTypstEngine.generate_typst_elements("", teststring, "")
t = MakieTypstEngine.generate_typst_elements("", teststring, "")

l

@bs MakieTypstEngine.generate_typst_elements("", teststring, "")


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
    f = Figure(size = (100, 100))
    a = [1, 2, 3]
    Label(f[1, 1], typst"$sin(x^2) = \(a; mode=math)$")
    f
end

typst"$ sin(x^2) = \([1,2,3], mode=math)$".text

let
    f = Figure()
    ax = Axis(f[1, 1], xlabel = typst"$1/(1 + e^(-beta x))$ test", xlabelsize = 20)
    ax = Axis(f[1, 2], xlabel = "test", xlabelsize = 20)
    text!(ax, Point2f(0, 0), text = typst"$sum_(i=1)^5 i^2$")
    f
end

@edit Makie.to_font("est")


let
    typst_string = typst"""
    this is an integral:
    $ integral_0^t sin(x)^2 dif x $
    """
    fig = Figure()
    Label(fig[1, 2], typst_string, fontsize = 20, tellheight = false)
    Label(fig[2, 2], "this is an integral", fontsize = 20, tellheight = false)
    Label(fig[2, 2], typst"this is an integral", fontsize = 20, tellheight = false)
    ax = Axis(fig[1, 1], xlabel = typst"time $[s]$", ylabel = typst"$f(t)$")
    lines!(ax, 0 .. 10, sin, label = typst"$f(t) = sin(t)$")
    lines!(ax, 0 .. 10, cos, label = typst"$f(t) = cos(t)$")
    lines!(ax, 0 .. 10, t -> sin(t + π) + sin(t + 2π)^2, label = typst"$ f(t) = sum_(i=1)^2 sin^i (t+pi i) $")
    axislegend(ax)
    fig
end