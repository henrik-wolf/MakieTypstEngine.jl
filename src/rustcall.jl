function compile_rust(filename)
    outfile = mktempdir() * "lib.so"
    cmd = `rustc $filename --crate-type=cdylib -o $outfile`
    run(cmd)
    return outfile
end


get_pkg_dir() = @__DIR__


using Libdl

lib_path = compile_rust(joinpath(get_pkg_dir(), "rust/hellojulia.rs"))
# lib = Libdl.dlopen(lib_path)
list_symbols = `nm -D $lib_path`
run(list_symbols)

function typst_to_json(typst_string, font_path)
    vec_typst_string = UInt8.(collect(typst_string))
    vec_font_path = UInt8.(collect(font_path))
    ret_vec = @ccall lib_path.typst_to_json(vec_typst_string::Vector{UInt8}, vec_font_path::Vector{UInt8})::Vector{UInt8}
    str = mapfoldl(Char, (*), ret_vec, "")
    return str
end

typst_to_json("hello ", "there")