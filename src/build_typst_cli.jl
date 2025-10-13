# this code is executed when the package is loaded
# it checks if the rust cli has been build, an, if not
# builds it and puts it in a project specific scratch space

# taken from the Scratch.jl docs
function get_version()
    VersionNumber(TOML.parsefile(joinpath(dirname(@__DIR__), "layout-cli", "Cargo.toml"))["package"]["version"])
end

function get_cli_source_dir()
    joinpath(dirname(@__DIR__), "layout-cli")
end

const cli_version = get_version()
const cli_version_specific_scratch = Ref{String}()

const cli_source_dir = get_cli_source_dir()
const cli_binary = Ref{Cmd}()

function build_cli()
    try
        read(`cargo -V`, String)
    catch e
        throw(error("Cargo is necessary to build the CLI on your device. Do you have it installed?"))
    end
    @info "building cli..."
    cd(cli_source_dir) do
        run(`cargo build -r --target-dir $(cli_version_specific_scratch[])`)
    end
    binary_name = if Sys.iswindows()
        "layout-cli.exe"
    else
        "layout-cli"
    end
    cli_binary[] = `$(joinpath(cli_version_specific_scratch[], "release", binary_name))`
end