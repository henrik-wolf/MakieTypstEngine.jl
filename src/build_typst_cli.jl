# this code is executed when the package is loaded
# it builds, and puts the cli in a package and version specific scratch space

"""get version of rust/typst cli project"""
function get_version()
    VersionNumber(TOML.parsefile(joinpath(dirname(@__DIR__), "layout-cli", "Cargo.toml"))["package"]["version"])
end

"""get path at which the rust/typst cli source code lives"""
function get_cli_source_dir()
    joinpath(dirname(@__DIR__), "layout-cli")
end

const cli_version = get_version()
const cli_version_specific_scratch = Ref{String}()

const cli_source_dir = get_cli_source_dir()
const cli_binary = Ref{Cmd}()

"""
builds the rust/typst cli and puts the binary into a version specific scratch space.
Recompiling is cheap, thanks to cargo, thus, we do not check for repeated builds, but
run the build command on every package load.

!!! warning "Building Rust Crates"
    This function calls out to the cargo cli, which it assumes to be installed and available on
    your computer.
"""
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