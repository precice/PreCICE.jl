# Native Parallel Solver Example

This directory tests two solvers started in parallel mode. 

# Usage

To run the parallel Julia solver, change into this directory and type:

```
julia solverdummy-parallel.jl N ./precice-config-parallel.xml <SolverName>
```

where `<SolverName>` is either SolverOne or SolverTwo
to start 1 master and N-1 workers computing distributed data.



You can combine the parallel python solver that uses MPI:

```
mpirun -n N python3 python-solverdummy-parallel.py ./precice-config-parallel.xml SolverOne MeshOne
```
or

```
mpirun -n 4 python3 python-solverdummy-parallel.py ./precice-config-parallel.xml SolverTwo MeshTwo
```

but you need to remove the `<master:sockets/>` tag from the participant that is the python solver, and make sure that the `vertices` list of python's solver has the same number of vertices and they have the same coordinates.





