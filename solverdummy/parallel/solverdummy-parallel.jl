import Pkg; Pkg.activate("../..")
using Distributed

if size(ARGS, 1) < 3
    println("ERROR: pass total processes number N, config path, solver name and mesh name, 
                example: julia solverdummy.jl 5 ./precice-config.xml SolverOne")
    exit(1)
end

numberWorkers = parse(Int, ARGS[1]) - 1
ConfigFileName = ARGS[2]
SolverName = ARGS[3]

# add --project flag if PreCICE is installed in a local Julia environment
addprocs(numberWorkers; exeflags="--project")

@everywhere begin

using PreCICE

commRank = myid() - 1
commSize = nprocs()

configFileName = $ConfigFileName
solverName = $SolverName

# set meshName depending on solverName
if solverName == "SolverOne"
    meshName = "MeshOne"
else 
    meshName = "MeshTwo"
end

println("""DUMMY ($commRank): Running solver dummy with preCICE config file "$configFileName", 
            participant name "$solverName", and mesh name "$meshName" """)

PreCICE.createSolverInterface(solverName, configFileName, commRank, commSize)

meshID = PreCICE.getMeshID(meshName)
dimensions = PreCICE.getDimensions()

dataWriteName = nothing
dataReadName = nothing

numberOfVertices = 1


if solverName == "SolverOne"
    dataWriteName = "dataOne"
    dataReadName  = "dataTwo"
end

if solverName == "SolverTwo"
    dataReadName  = "dataOne"
    dataWriteName = "dataTwo"
end

readDataID  = PreCICE.getDataID(dataReadName, meshID)
writeDataID = PreCICE.getDataID(dataWriteName, meshID)


writeData = zeros(numberOfVertices * dimensions)
readData = zeros(numberOfVertices * dimensions)

vertices = Array{Float64, 1}(undef, numberOfVertices * dimensions)

# create different vertices coordinates for different procs
for i in 1:numberOfVertices, j in 1:dimensions
    offset = commRank * numberOfVertices
    vertices[j + dimensions * (i-1)] = i-1 + offset
end




println(vertices)

let # setting local scope for dt outside of the while loop
vertexIDs = PreCICE.setMeshVertices(meshID, numberOfVertices, vertices) 

dt = PreCICE.initialize()

while PreCICE.isCouplingOngoing()
    
    if PreCICE.isActionRequired(PreCICE.actionWriteIterationCheckpoint())
        println("DUMMY ($commRank): Writing iteration checkpoint")
        PreCICE.markActionFulfilled(PreCICE.actionWriteIterationCheckpoint())
    end

    if PreCICE.isReadDataAvailable()
        PreCICE.readBlockVectorData(readDataID, numberOfVertices, vertexIDs, readData) 
    end

    writeData = readData .+ 1.0

    if PreCICE.isWriteDataRequired(dt)
        PreCICE.writeBlockVectorData(writeDataID, numberOfVertices, vertexIDs, writeData)
    end

    dt = PreCICE.advance(dt)

    if PreCICE.isActionRequired(PreCICE.actionReadIterationCheckpoint())
        println("DUMMY ($commRank): Reading iteration checkpoint")
        PreCICE.markActionFulfilled(PreCICE.actionReadIterationCheckpoint())
    else
       println("DUMMY ($commRank): Advancing in time")
    end

end # while

end # let scope

PreCICE.finalize()
println("DUMMY ($commRank): Closing Julia solver dummy...")

end