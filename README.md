# PreCICE.jl

<a style="text-decoration: none" href="https://github.com/precice/julia-bindings/blob/main/LICENSE" target="_blank">
    <img src="https://img.shields.io/github/license/precice/julia-bindings.svg" alt="GNU GPL license">
</a>

This package provides Julia language bindings for the C++ library [preCICE](https://github.com/precice/precice). It is a Julia package that wraps the API of preCICE.


# Adding the package to a Julia environment or script
You can use the Julia bindings for preCICE can be used by adding them as a package in a Julia environment or also directly including the package in a Julia script. For both usages you need to have preCICE installed on the system. For preCICE installation you can look at the [installation documentation](https://precice.org/installation-overview.html). You can directly add the Julia bindings to your Julia environment in the following way:

```julia
julia> ]
pkg> add https://github.com/precice/julia-bindings.git 
Then exit the package mode with 🔙 or Ctrl + c
julia> using PreCICE
```

Once the package is added you can directly access preCICE API commands in the Julia environment, for example `getVersionInformation()`. Alternative to the environment you can also inclue the package in your Julia script in the following way:

```julia
import Pkg; Pkg.add(url="https://github.com/precice/julia-bindings.git")
using PreCICE
```

Once the package is added at the beginning of the Julia script you can access the preCICE API commands in the script.

## Adding when preCICE is installed at custom paths
If you installed preCICE at a custom path, errors like ```ERROR: could not load library "/..."``` can be seen after adding the Julia bindings package. In such cases set the path to your library with `PreCICE.setPathToLibprecice("path/to/my/libprecice.so")` or reset it with `PreCICE.resetPathToLibprecice()`

By default this package assumes the `libprecice.so` is at `/usr/lib/x86_64-linux-gnu/`.

# Usage
You can look at [solverdummy](https://github.com/precice/julia-bindings/tree/main/solverdummy) as an example of how to use the Julia bindings for preCICE


# Testing new features that are on branches of this repository

To use a certain branch of this package, add `#branchname` after the package url, example downloading the `mpi-parallelization` branch:


```julia
julia> ]
pkg> add https://github.com/precice/julia-bindings.git#mpi-parallelization
Then exit the package mode with 🔙 or Ctrl + c
julia> using PreCICE
```



