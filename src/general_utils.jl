get_src_dir() = @__DIR__

get_rust_dir() = joinpath(
    dirname(get_src_dir()),
    "layout-cli"
)
#joinpath(get_src_dir(), "typst2json")