# PreCICE.jl

This is a WIP Julia binding for the C++ library preCICE, using its C interface. Contrary to [julia-bindings-for-preCICE](https://github.com/pavelkharitenko/julia-binding-for-preCICE) this solution relies on no other packages.

## Usage


Since this repository has the structure of a Julia package, you can directly add it to your environment in a Julia REPL:

```julia
julia> ]
pkg> add https://github.com/pavelkharitenko/julia-bindings.git
julia> using PreCICE
julia> getVersionInformation()
...
```

Or put the following on top of your Julia script:

```julia
import Pkg; Pkg.add(url="https://github.com/pavelkharitenko/julia-bindings.git")
using PreCICE
getVersionInformation()
...
```

This package is WIP and has no release yet. Bugs may occur.

## Solverdummy example

For a coupling example see the solverdummy.jl in the example/ directory

## I installed my preCICE library to a different location

By default this package assumes the `libprecice.so` is at `/usr/lib/x86_64-linux-gnu/libprecice.so.2.2.0`.

Change the path with `PreCICE.setPathToLibprecice("path/to/my/libprecice.so")` or reset it with `PreCICE.resetPathToLibprecice()`
