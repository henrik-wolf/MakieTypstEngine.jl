include("general_utils.jl")

# get_run_cmd(paths = []) = length(paths) > 0 ? `cargo run -- $paths` : `cargo run`
# get_run_cmd() = cli_binary[]
function get_run_cmd(paths = [])
    if length(paths) > 0
        `target/release/layout-cli $paths`
    else
        `target/release/layout-cli`
    end
end
## Copied from https://discourse.julialang.org/t/capture-stdout-and-stderr-in-case-a-command-fails/101772/3
function execute(cmd::Cmd; input = nothing, path = ".")
    out = Pipe()
    err = Pipe()

    inputcmd = isnothing(input) ? `echo ''` : input
    cd(path) do
        process =
            run(pipeline(ignorestatus(cmd); stdin = inputcmd, stdout = out, stderr = err))
    end
    close(out.in)
    close(err.in)

    stderr = String(read(err))

    if length(stderr) > 0
        throw(error(stderr))
    end
    return String(read(out))
end

"""
Compile a string that looks like a full typst document into a json object of the layout
"""
function compile_string(str, additional_font_paths = [])
    runcmd = get_run_cmd(additional_font_paths)
    path = get_rust_dir()
    input_cmd = `echo $(str)` # definitely not safe

    output = execute(runcmd; input = input_cmd, path = path)
    return JSON.parse(output)
end

"""
Compile a typst file at `filename` into a json object of the layout
"""
function compile_file(filename)
    runcmd = get_run_cmd()
    path = get_rust_dir()
    new_filename = relpath(filename, path)
    input_cmd = `cat '$(escape_string(str))'` # definitely not safe

    output = execute(runcmd; input = input_cmd, path = path)
    return JSON.parse(output.stdout)
end

# compile_file(joinpath(get_rust_dir(), "template.typ"))

# example_str = raw"""// template.typ
# #set page(paper: "a4")
# #set text(font: "Fira Math", 11pt)
# #show math.equation: set text(font: "Fira Math")
# $sum x/y$
# """
# escape_string(example_str)
# output, errput = compile_string(example_str)