module MakieTypstEngine
using TestItems
using Typstry
using Makie
using JSON
using FreeTypeAbstraction

export @typst_str

# this is the machinery which builds and caches the rust based typst cli on load
using Scratch
using Pkg.TOML

include("build_typst_cli.jl")

function __init__()
    scratch_name = "typst-layout-cli-$(cli_version.major).$(cli_version.minor).$(cli_version.patch)"
    global cli_version_specific_scratch[] = @get_scratch!(scratch_name)
    build_cli()
end

# this is the main package code
include("rust_cli.jl")

include("render.jl")
include("piracy.jl")
end
