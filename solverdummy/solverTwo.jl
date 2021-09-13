using Distributed
@everywhere newARGS = ["./precice-config-parallel.xml", "SolverTwo", "MeshTwo"]
@everywhere include("solverdummy-parallel.jl")