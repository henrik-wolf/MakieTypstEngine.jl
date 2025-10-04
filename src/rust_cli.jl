include("general_utils.jl")

function build_rust_bin()
    cmd = `cargo build --bins`
    cd(get_rust_dir()) do
        run(cmd)
    end
    return joinpath(get_rust_dir(), "target", "debug", "typst2jsonbin")
end

## Copied from https://discourse.julialang.org/t/capture-stdout-and-stderr-in-case-a-command-fails/101772/3
function execute(cmd::Cmd)
    out = Pipe()
    err = Pipe()

    process = run(pipeline(ignorestatus(cmd); stdout = out, stderr = err))
    close(out.in)
    close(err.in)

    return_tuple = (stdout = String(read(out)), stderr = String(read(err)),
           exitcode = process.exitcode)
    return return_tuple
end

outbin = build_rust_bin()
output, errput, exitcode = execute(`$outbin`)
output
errput |> println