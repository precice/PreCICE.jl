import Pkg; Pkg.activate("..")
using PreCICE

commRank = 0
commSize = 1

if size(ARGS, 1) < 2
    println("ERROR: pass config path, solver name and mesh name, example: julia solverdummy.jl ./precice-config.xml SolverOne MeshOne")
    exit(1)
end

configFileName = ARGS[1]
solverName = ARGS[2]


if solverName == "SolverOne"
    meshName = "MeshOne"
    dataWriteName = "dataOne"
    dataReadName  = "dataTwo"
else
    meshName = "MeshTwo"
    dataReadName  = "dataOne"
    dataWriteName = "dataTwo"
end


println("""DUMMY: Running solver dummy with preCICE config file "$configFileName", participant name "$solverName", and mesh name "$meshName" """)
PreCICE.createSolverInterface(solverName, configFileName, commRank, commSize)

meshID = PreCICE.getMeshID(meshName)
dimensions = PreCICE.getDimensions()


numberOfVertices = 3


readDataID  = PreCICE.getDataID(dataReadName, meshID)
writeDataID = PreCICE.getDataID(dataWriteName, meshID)

readData = zeros(numberOfVertices * dimensions)
writeData = zeros(numberOfVertices * dimensions)

vertices = Array{Float64, 1}(undef, numberOfVertices * dimensions)


# create array of vertices v_i = (i,i,i)
for i in 1:numberOfVertices, j in 1:dimensions
        vertices[j + dimensions * (i-1)] = i
end


vertexIDs = PreCICE.setMeshVertices(meshID, numberOfVertices, vertices)

let # setting local scope for dt outside of the while loop

dt = PreCICE.initialize()

while PreCICE.isCouplingOngoing()
    
    if PreCICE.isActionRequired(PreCICE.actionWriteIterationCheckpoint())
        println("DUMMY: Writing iteration checkpoint")
        PreCICE.markActionFulfilled(PreCICE.actionWriteIterationCheckpoint())
    end

    if PreCICE.isReadDataAvailable()
        PreCICE.readBlockVectorData(readDataID, numberOfVertices, vertexIDs, readData) 
    end

    for i in 1:(numberOfVertices * dimensions)
        writeData[i] = readData[i] + 1.0
    end

    if PreCICE.isWriteDataRequired(dt)
        PreCICE.writeBlockVectorData(writeDataID, numberOfVertices, vertexIDs, writeData)
    end

    dt = PreCICE.advance(dt)

    if PreCICE.isActionRequired(PreCICE.actionReadIterationCheckpoint())
        println("DUMMY: Reading iteration checkpoint")
        PreCICE.markActionFulfilled(PreCICE.actionReadIterationCheckpoint())
    else
        println("DUMMY: Advancing in time")
    end

end # while

end # let

PreCICE.finalize()
println("DUMMY: Closing Julia solver dummy...")
