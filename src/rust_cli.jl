include("general_utils.jl")

# get_run_cmd(paths = []) = length(paths) > 0 ? `cargo run -- $paths` : `cargo run`
# function get_run_cmd(paths = [])
#     if length(paths) > 0
#         `$(cli_binary[]) $paths`
#     else
#         cli_binary[]
#     end
# end
function get_run_cmd(paths = [])
    if length(paths) > 0
        `target/release/layout-cli $paths`
    else
        `target/release/layout-cli`
    end
end

## Copied from https://discourse.julialang.org/t/capture-stdout-and-stderr-in-case-a-command-fails/101772/3
function execute(cmd::Cmd; inputcmd, path = ".")
    out = Pipe()
    err = Pipe()

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
    input_cmd = `echo $(str)` # TODO: definitely not safe

    output = execute(runcmd; inputcmd = input_cmd, path = path)
    return JSON.parse(output)
end