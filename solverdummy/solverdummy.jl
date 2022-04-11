using PreCICE

commRank = 0
commSize = 1

if size(ARGS, 1) < 2
    println(
        "ERROR: pass config path, solver name and mesh name, example: julia solverdummy.jl ./precice-config.xml SolverOne MeshOne",
    )
    exit(1)
end

configFileName = ARGS[1]
solverName = ARGS[2]


if solverName == "SolverOne"
    meshName = "MeshOne"
    dataWriteName = "dataOne"
    dataReadName = "dataTwo"
else
    meshName = "MeshTwo"
    dataReadName = "dataOne"
    dataWriteName = "dataTwo"
end


println(
    """DUMMY: Running solver dummy with preCICE config file "$configFileName", participant name "$solverName", and mesh name "$meshName" """,
)
PreCICE.createSolverInterface(solverName, configFileName, commRank, commSize)

meshID = PreCICE.getMeshID(meshName)
dimensions = PreCICE.getDimensions()


numberOfVertices = 3


readDataID = PreCICE.getDataID(dataReadName, meshID)
writeDataID = PreCICE.getDataID(dataWriteName, meshID)

writeData = zeros(numberOfVertices, dimensions)

vertices = Array{Float64,2}(undef, numberOfVertices, dimensions)

for i = 1:numberOfVertices, j = 1:dimensions
    vertices[i, j] = i
end

vertexIDs = PreCICE.setMeshVertices(meshID, vertices)

let # setting local scope for dt outside of the while loop

    dt = PreCICE.initialize()
    readData = zeros(numberOfVertices, dimensions)

    while PreCICE.isCouplingOngoing()

        if PreCICE.isActionRequired(PreCICE.actionWriteIterationCheckpoint())
            println("DUMMY: Writing iteration checkpoint")
            PreCICE.markActionFulfilled(PreCICE.actionWriteIterationCheckpoint())
        end

        if PreCICE.isReadDataAvailable()
            readData = PreCICE.readBlockVectorData(readDataID, vertexIDs)
        end

        for i = 1:numberOfVertices, j = 1:dimensions
            writeData[i, j] = readData[i, j] + 1.0
        end

        if PreCICE.isWriteDataRequired(dt)
            PreCICE.writeBlockVectorData(writeDataID, vertexIDs, writeData)
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
