# PreCICE.jl

PreCICE.jl is a WIP Julia binding for the C++ library [preCICE](https://github.com/pavelkharitenko/julia-binding-for-preCICE). It is a Julia package that depends on the core library of preCICE.


# Installation

1.  [Install preCICE](https://precice.org/installation-overview.html) or make sure it is installed. 

2. Install this Julia package. 
Since this repository has the structure of a Julia package, you can directly add it to your environment in a Julia REPL:

```julia
julia> ]
pkg> add https://github.com/precice/julia-bindings.git
julia> using PreCICE
julia> getVersionInformation()
...
```

Or put the following on top of your Julia script:

```julia
import Pkg; Pkg.add(url="https://github.com/precice/julia-bindings.git")
using PreCICE
getVersionInformation()
...
```

3. (optional) Link the installation path of the core preCICE shared library to PreCICE.jl:
If you are using a different version of preCICE or you installed it to a different location, and Errors like ```ERROR: could not load library "/..."``` are thrown, set the path to your library with `PreCICE.setPathToLibprecice("path/to/my/libprecice.so")` or reset it with `PreCICE.resetPathToLibprecice()`

By default this package assumes the `libprecice.so` is at `/usr/lib/x86_64-linux-gnu/`.

# Usage

## Solverdummy example

For a coupling example see the solverdummy.jl in the example/ directory


## Parallelization example

See the example/solverdummy-parallel-mpi/ folder on the `mpi-parallelization` branch of this repository for an example of how to use MPI communication with PreCICE.jl


