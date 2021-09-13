using Distributed
@everywhere newARGS = ["./precice-config-parallel.xml", "SolverOne", "MeshOne"]
@everywhere include("solverdummy-parallel.jl")