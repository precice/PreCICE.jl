# PreCICEC.jl

This is a WIP Julia binding for the c++ library preCICE, using its C interface. Contrary to [julia-bindings-for-preCICE](https://github.com/pavelkharitenko/julia-binding-for-preCICE) this solution is relies on no other packages. May or may not be slower.

## Usage


Since this repository has the structure of a Julia package, you can directly add it to your environment in a Julia REPL:

```julia
julia
julia> ]
pkg> add https://github.com/pavelkharitenko/julia-binding-for-preCICE.git
julia> using PreCICEC
julia> getVersionInformation()
...
```

Or put the following on top of your Julia script:

```julia
import Pkg; Pkg.add(url="https://github.com/pavelkharitenko/julia-binding-for-preCICE.git")
using PreCICEC
getVersionInformation()
...
```

This package is WIP and has no release yet. Bugs may occur.

## Solverdummy example

For a coupling example see the solverdummy.jl in the example/ directory

## I installed my preCICE library to a different location

Right know this package just simply takes the libprecice.so at `/usr/lib/x86_64-linux-gnu/libprecice.so.2.2.0`.

Changing the path through a method is not working yet, but you can clone this package and change `libprecicePath` in `src/PreCICE.jl` to the location of your libprecice.so. 