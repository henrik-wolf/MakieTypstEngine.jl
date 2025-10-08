module MakieTypstEngine
using TestItems
using Typstry
using Makie
using MathTeXEngine

include("rust_cli.jl")

# we need a way to:
# - represent a piece of typst code in julia (using typstry, I guess)
# - pass that to makie
# - on render, construct a context from the theme passed into the function
# - render the typst string with the context (calling out to rust)
# - get back a json thing that contains the glyphs
# - put them into to MathTeXEngine format, an pass that on to the backend

# TODO: Remove CairoMakie from dependencies

include("render.jl")
include("piracy.jl")
end
