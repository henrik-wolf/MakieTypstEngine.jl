include("general_utils.jl")

get_run_cmd() = `cargo run`

## Copied from https://discourse.julialang.org/t/capture-stdout-and-stderr-in-case-a-command-fails/101772/3
function execute(cmd::Cmd; input=nothing, path=".")
    out = Pipe()
    err = Pipe()

    inputcmd = isnothing(input) ? `echo ''` : input
    cd(path) do
        process = run(pipeline(ignorestatus(cmd); stdin=inputcmd, stdout = out, stderr = err))
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


function compile_string(str)
    runcmd = get_run_cmd()
    path = get_rust_dir()
    input_cmd = `echo $(str)` # definitely not safe

    return execute(runcmd; input=input_cmd, path=path)
end

function compile_file(filename)
    runcmd = get_run_cmd()
    path = get_rust_dir()
    new_filename = relpath(filename, path)
    input_cmd = `cat '$(escape_string(str))'` # definitely not safe

    return execute(runcmd; input=input_cmd, path=path)
end

# compile_file(joinpath(get_rust_dir(), "template.typ"))

example_str = raw"""// template.typ
#set page(paper: "a4")
#set text(font: "Fira Math", 11pt)
#show math.equation: set text(font: "Fira Math")
$sum x/y$
"""

run(`echo $(example_str)`;)

# escape_string(example_str)
# output, errput = compile_string(example_str)