# PreCICE.jl

<a style="text-decoration: none" href="https://github.com/precice/julia-bindings/blob/main/LICENSE" target="_blank">
    <img src="https://img.shields.io/github/license/precice/julia-bindings.svg" alt="GNU GPL license">
</a>

This package provides Julia language bindings for the C++ library [preCICE](https://github.com/precice/precice). It is a Julia package that wraps the API of preCICE.

## Adding and using the package

The Julia bindings for preCICE can be used by either by adding them as a package in a Julia environment or also directly including the package in a Julia script. For both type of usages preCICE needs to be installed on the system. For preCICE installation, have a look at the [installation documentation](https://precice.org/installation-overview.html).

### Adding the package

Add the Julia bindings to the Julia environment in the following way:

```julia
julia> ]
pkg> add PreCICE 
Then exit the package mode with 🔙 or Ctrl + c
julia> using PreCICE
```

Alternatively you can also include the package in a Julia script in the following way:

```julia
import Pkg; Pkg.add(url="https://github.com/precice/julia-bindings.git")
using PreCICE
```

### Adding the package from a local folder

If you have cloned or downloaded the Julia bindings on your local machine, add the Julia bindings to your Julia environment in the following way:

```julia
julia> ]
pkg> add <path-to-repository>
Then exit the package mode with 🔙 or Ctrl + c
julia> using PreCICE
```

## Troubleshooting

If preCICE is installed at a custom path, errors of the form ```ERROR: could not load library "/..."``` can occur after adding the Julia bindings package. Make sure the preCICE library is in the system library path through `echo $LD_LIBRARY_PATH` and otherwise update the variable with the correct path.

```bash
~$ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<path-to-precice.so>
```

A different way to fix this error is to set the custom path of the preCICE installation through the environment variable `PRECICE_JL_BINARY`. Afterwards you need to rebuild this package:

```julia-repl
~$ export PRECICE_JL_BINARY=/usr/lib/x86_64-linux-gnu/
~$ julia (--project)
julia> ]
pkg> build PreCICE
julia> using PreCICE
...
```

## Usage

The [solverdummy](https://github.com/precice/julia-bindings/tree/main/solverdummy) shows an example of how to use the Julia bindings for preCICE.

## Testing new features that are on branches of this repository

To use a certain branch of this package, add `#branchname` after the package url, for example if the branch `mpi-parallelization` is to be tested:

```julia-repl
julia> ]
pkg> add https://github.com/precice/julia-bindings.git#mpi-parallelization
Then exit the package mode with 🔙 or Ctrl + c
julia> using PreCICE
```

## Dependencies

This package works with official Julia binaries listed below. See the [Platform Specific Instructions for official Binaries](https://julialang.org/downloads/platform/)  or [Julia's documentation](https://docs.julialang.org/en/v1/manual/getting-started/) if you are not sure how to download them.

## Supported versions

The package is tested for Julia versions `1.6.0`, `1.6.5`, `1.7.0` and the two newest [Julia releases](https://github.com/JuliaLang/julia/releases). Julia versions prior to `v1.6.0` are not supported.

[Unofficial Julia binaries](https://julialang.org/downloads/platform/#platform_specific_instructions_for_unofficial_binaries) may not be compatible.
