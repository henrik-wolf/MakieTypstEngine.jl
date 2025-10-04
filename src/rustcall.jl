include("general_utils.jl")

function build_rust_lib()
    cmd = `cargo build --lib`
    cd(get_rust_dir()) do
        run(cmd)
    end
    return joinpath(get_rust_dir(), "target", "debug", "rust")
end



using Libdl

lib_path = compile_rust(joinpath(get_pkg_dir(), "rust/hellojulia.rs"))
# lib = Libdl.dlopen(lib_path)
list_symbols = `nm -D $lib_path`
run(list_symbols)

function typst_to_json(typst_string, font_path)
    # vec_typst_string = UInt8.(collect(typst_string))
    # vec_font_path = UInt8.(collect(font_path))
    out = ""
    ret_vec = @ccall lib_path.typst_to_json(
        out::Cstring,
        typst_string::Cstring,
        font_path::Cstring
    )::Cvoid
    str = mapfoldl(Char, (*), ret_vec, "")
    return str
end

typst_to_json("hello ", "there")