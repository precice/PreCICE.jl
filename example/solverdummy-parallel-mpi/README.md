## This is an example for using preCICE.jl with a distributed Julia solver, using multiple executables.


### Installation
First let MPI.jl point to a OpenMPI implementation of your machine:
- Install MPI.jl in your Julia enviroment with `Pkg.add("MPI")` or activate this environment with `Pkg.activate("../..")` (from this directory).
- Run `julia --project -e 'ENV["JULIA_MPI_BINARY"]="system"; using Pkg; Pkg.build("MPI"; verbose=true)'`

Note: MPI.jl comes with MPI implementation version 3.4.2, which seems not to be compatible with this solver example. This example was tested on Open MPI version 4.0.3.

### Usage
From this directory, run 
```
mpirun -n N julia --project solverdummy-parallel-mpi.jl ./precice-config-parallel-mpi.xml SolverOne MeshOne
```

or 

```
mpirun -n M julia --project solverdummy-parallel-mpi.jl ./precice-config-parallel-mpi.xml SolverTwo MeshTwo
```

respectively.