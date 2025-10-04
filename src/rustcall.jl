include("general_utils.jl")

# using Libdl

function build_rust_lib()
    cmd = `cargo build --lib`
    cd(get_rust_dir()) do
        run(cmd)
    end
    return joinpath(get_rust_dir(), "target", "debug", "libtypst2json.so")
end

lib_path = build_rust_lib()
run(`nm -D $lib_path`)

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