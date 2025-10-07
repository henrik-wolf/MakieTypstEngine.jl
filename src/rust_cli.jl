include("general_utils.jl")

run_cmd = `cargo run`
path = get_rust_dir()
input_cmd = `cat template.typ`

## Copied from https://discourse.julialang.org/t/capture-stdout-and-stderr-in-case-a-command-fails/101772/3
function execute(cmd::Cmd; input=nothing, path=".")
    out = Pipe()
    err = Pipe()

    inputcmd = isnothing(input) ? `echo ''` : input
    cd(path) do
        process = run(pipeline(ignorestatus(cmd); stdin=input_cmd, stdout = out, stderr = err))
    end
    close(out.in)
    close(err.in)

    return_tuple = (
        stdout = String(read(out)),
        stderr = String(read(err)),
        # exitcode = process.exitcode
    )
    return return_tuple
end


output, errput = execute(run_cmd; input=input_cmd, path=path)
