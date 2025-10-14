
function to_typstfont(font)
    family_name = FreeTypeAbstraction.family_name(font)
    return to_typstfont(Val(Symbol(lowercase(family_name))), font)
end
"""
Overload this to map the font family you are using to the associated string that
typst is willig to find the font under.
"""
function to_typstfont(::Val{T}, font) where {T}
    return String(T)
end

function to_mathfont(font)
    family_name = FreeTypeAbstraction.family_name(font)
    return to_mathfont(Val(Symbol(lowercase(family_name))), font)
end

"""
Overload this to map the font family you are using to the associated
math font. To use `Fira Math` whenever you select `Fira Sans` as a font
use:

```julia
MakieTypstEngine.to_mathfont(::Val{Symbol("fira sans")}, font) = "fira math"
```
Note how the dispatched argument is always fully lowercase. The output of this
function will be interpolated into the typst document at
`#show math.equation: set text(font: \$math_font)`
"""
function to_mathfont(::Val{T}, font) where {T}
    return String(T)
end

function from_typst_font(font_dict)
    family_name = font_dict["family"]
    from_typst_font(Val(Symbol(lowercase(family_name))), font_dict)
end

"""
Overload this function to map the font information from Typst back to fonts that
can be used by Makie. This is especially important when you want to use styling
in your typst strings, for example:
```julia
f = Figure()
Label(f[1,1], typst"_this_ is a *formatted* string", font="Fira Sans")
f
```
which use bold and italics. For example with `Fira Sans`, you would overload
```julia
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
    font_string = "fira sans \$style \$weight"
    return font_string
end
again, note the lower case font family name in the dispatch as well as the fact that
you need to do a separate dispatch of this kind for your math font, should you need
to customise the resolving behaviour as well.
```

Return either a string (fontname or path) that will
internally be passed to `Makie.to_font(your_font)`
(as described in the [fonts explanation](https://docs.makie.org/stable/explanations/fonts))
or a `FTFont` object directly.
"""
function from_typst_font(::Val{T}, font_dict) where {T}
    println(font_dict)
    return String(T)
end

maybe_to_FTFont(x::String) = Makie.to_font(x)
maybe_to_FTFont(x::FTFont) = x

# MARK: MathTeXEngine Fonts

"""
Use this function to get one of the MathTeXEngine fonts as a FTFont
"""
function MTEFont(name, style = :regular)
    @assert name in keys(MathTeXEngine.default_font_families) "Fontname $name not found in MathTeXEngines default fonts. Use one of $(keys(MathTeXEngine.default_font_families))"
    @assert style in keys(FontFamily(name).fonts) "Fontstyle $style not found for Font $name. Use one of $(keys(FontFamily(name).fonts))"
    # TODO: figure out what is going on here?
    if name == "NewComputerModern"
        @warn "NewComputerModern is a strange and broken font, some things may not work as expected."
    end
    if name == "TeXGyreHeros"
        @warn "TeXGyreHeros is not recognised by typst as a math enabled font, and thus not usable here."
    end
    return MathTeXEngine.get_font(FontFamily(name), style)
end

to_typstfont(::Val{Symbol("newcomputermodern math")}, font) = "New Computer Modern"

to_mathfont(::Val{Symbol("luciole")}, font) = "Luciole Math"
to_mathfont(::Val{Symbol("tex gyre pagella")}, font) = "TeX Gyre Pagella Math"
to_mathfont(::Val{Symbol("newcomputermodern math")}, font) = "New Computer Modern Math"

from_typst_font(::Val{Symbol("luciole")}, font) = resolve_MathTeXEngine_fonts("LucioleMath", font, 400, 600)
from_typst_font(::Val{Symbol("luciole math")}, font) = MathTeXEngine.get_font(FontFamily("LucioleMath"), :math)

from_typst_font(::Val{Symbol("tex gyre pagella")}, font) = resolve_MathTeXEngine_fonts("TeXGyrePagella", font, 400, 700)
from_typst_font(::Val{Symbol("tex gyre pagella math")}, font) = MathTeXEngine.get_font(FontFamily("TeXGyrePagella"), :math)

from_typst_font(::Val{Symbol("new computer modern")}, font) = resolve_MathTeXEngine_fonts("NewComputerModern", font, 400, 700)
from_typst_font(::Val{Symbol("new computer modern math")}, font) = MathTeXEngine.get_font(FontFamily("NewComputerModern"), :math)

function resolve_MathTeXEngine_fonts(name, font, normal_weight, bold_weight)
    var = font["variant"]
    if var["style"] == "italic"
        if var["weight"] == normal_weight
            return MathTeXEngine.get_font(FontFamily(name), :italic)
        elseif var["weight"] == bold_weight
            return MathTeXEngine.get_font(FontFamily(name), :bolditalic)
        else
            throw(error("encountered unknown weight of $(var["weight"]) when resolving font $name"))
        end
    elseif var["style"] == "normal"
        if var["weight"] == normal_weight
            return MathTeXEngine.get_font(FontFamily(name), :regular)
        elseif var["weight"] == bold_weight
            return MathTeXEngine.get_font(FontFamily(name), :bold)
        else
            throw(error("encountered unknown weight of $(var["weight"]) when resolving font $name"))
        end
    else
        throw(error("encountered unknown style of $(var["style"]) when resolving font $name"))
    end
end




# MARK: overwrites for fira sans
# to_mathfont(::Val{Symbol("fira sans")}, font) = "fira math"

# function from_typst_font(::Val{Symbol("fira sans")}, font_dict)
#     var = font_dict["variant"]
#     # somehow, Makie.to_font did not give me the right font for this one...
#     if var["style"] == "italic" && var["weight"] == 400
#         return "/Users/henrikwolf/Library/Fonts/FiraSans-Italic.ttf"
#     end
#     # when using the full "italic" string, Makie.to_font resolves to a different font family
#     style = var["style"] == "italic" ? "it" : ""
#     # the numerical weights map to stuff like "thin", "regular", "bold" and so on...
#     weight = if var["weight"] == 400
#         "regular"
#     elseif var["weight"] == 700
#         "bold"
#     else
#         throw(error("unknown weight encountered"))
#     end
#     font_string = "fira sans $style $weight"
#     return font_string
# end