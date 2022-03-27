# PreCICE.jl

<a style="text-decoration: none" href="https://github.com/precice/julia-bindings/blob/main/LICENSE" target="_blank">
    <img src="https://img.shields.io/github/license/precice/julia-bindings.svg" alt="GNU GPL license">
</a>

This package provides Julia language bindings for the C++ library [preCICE](https://github.com/precice/precice). It is a Julia package that wraps the API of preCICE.

## Adding the package to a Julia environment or script

You can use the Julia bindings for preCICE by adding them as a package in a Julia environment or also directly including the package in a Julia script. For both usages you need to have preCICE installed on the system. For preCICE installation you can look at the [installation documentation](https://precice.org/installation-overview.html). You can directly add the Julia bindings to your Julia environment in the following way:

```julia
julia> ]
pkg> add https://github.com/precice/julia-bindings.git 
Then exit the package mode with 🔙 or Ctrl + c
julia> using PreCICE
```

Once the package is added you can directly access preCICE API commands in the Julia environment, for example `getVersionInformation()`. Alternatively you can also include the package in your Julia script in the following way:

```julia
import Pkg; Pkg.add(url="https://github.com/precice/julia-bindings.git")
using PreCICE
```

Once the package is added at the beginning of the Julia script you can access the preCICE API commands in the script.

## Adding the package when preCICE is installed at custom paths

If you installed preCICE at a custom path, errors like ```ERROR: could not load library "/..."``` can occur after adding the Julia bindings package. 

Set your custom path through the environment variable `PRECICE_JL_BINARY` and rebuild this package:

```julia
~$ export PRECICE_JL_BINARY=/usr/lib/x86_64-linux-gnu/
~$ julia (--project)
julia> ]
pkg> build PreCICE
julia> using PreCICE
...
```


## Usage

You can look at [solverdummy](https://github.com/precice/julia-bindings/tree/main/solverdummy) as an example of how to use the Julia bindings for preCICE.

## Testing new features that are on branches of this repository

To use a certain branch of this package, add `#branchname` after the package url, for example if the branch `mpi-parallelization` is to be tested:

```julia
julia> ]
pkg> add https://github.com/precice/julia-bindings.git#mpi-parallelization
Then exit the package mode with 🔙 or Ctrl + c
julia> using PreCICE
```

## Dependencies

This package works with official Julia binaries listed below. See the [Platform Specific Instructions for official Binaries](https://julialang.org/downloads/platform/)  or [Julia's documentation](https://docs.julialang.org/en/v1/manual/getting-started/) if you are not sure how to download them.

## Supported versions

The package is tested for Julia versions `1.6.0`, `1.6.5`, `1.7.0` and the newest release Julia releasse according to the official [`versions.json`](https://julialang-s3.julialang.org/bin/versions.json).

It is known that versions `<1.6` are not supported.

[Unofficial Julia binaries](https://julialang.org/downloads/platform/#platform_specific_instructions_for_unofficial_binaries) may not be compatible.
