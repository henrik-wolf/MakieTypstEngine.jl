module MakieTypstEngine
using TestItems
using Typstry
using Makie
using MathTeXEngine
using JSON
using FreeTypeAbstraction

using Scratch
using Pkg.TOML

include("build_typst_cli.jl")

function __init__()
    scratch_name = "typst-layout-cli-$(cli_version.major).$(cli_version.minor).$(cli_version.patch)"
    global cli_version_specific_scratch[] = @get_scratch!(scratch_name)
    build_cli()
end

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
