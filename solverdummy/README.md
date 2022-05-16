This is a minimal working example for using preCICEC.jl with Julia. The solverdummy.jl will couple with another solver using preCICE.

From this directory, run 
```
julia ./solverdummy.jl ./precice-config.xml SolverOne
```

or 

```
julia ./solverdummy.jl ./precice-config.xml SolverTwo
```

respectively.