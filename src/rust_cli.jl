include("general_utils.jl")

function build_rust_bin()
    cmd = `cargo build`
    cd(get_rust_dir()) do
        run(cmd)
    end
    return joinpath(get_rust_dir(), "target", "debug", "rust")
end

outbin = build_rust_bin()
run(`$outbin`)