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
julia parallelOne.jl  # or julia parallelTwo.jl
```

parallelOne or parallelTwo starts three additional processes, that number can be changed.









