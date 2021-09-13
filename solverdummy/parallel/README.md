# Native Parallel Solver Example

This directory tests two solvers started in parallel mode. 

# Usage

To run the python solver, change into this directory and type:

```
mpirun -n N python3 python-solverdummy-parallel.py ./precice-config-parallel.xml SolverOne MeshOne
```
or

```
mpirun -n N python3 python-solverdummy-parallel.py ./precice-config-parallel.xml SolverTwo MeshTwo
```


To run the Julia solver, change into this directory and type:

```
julia -p M
```
to launch Julia with M additional processes and then

```julia
julia> include("solverOne.jl")         # or include("solverTwo.jl")
```

You can also do the two steps above for Julia in one:

```julia
julia -n M solverOne.jl
```




