using PreCICE

commRank = 0
commSize = 1

if size(ARGS, 1) < 1
    @error(
        "ERROR: pass config path and solver name, example: julia solverdummy.jl ./precice-config.xml SolverOne",
    )
    exit(1)
end

configFileName = ARGS[1]
solverName = ARGS[2]


if solverName == "SolverOne"
    meshName = "SolverOne-Mesh"
    dataWriteName = "Data-One"
    dataReadName = "Data-Two"
else
    meshName = "SolverTwo-Mesh"
    dataReadName = "Data-One"
    dataWriteName = "Data-Two"
end


println(
    """DUMMY: Running solver dummy with preCICE config file "$configFileName", participant name "$solverName", and mesh name "$meshName" """,
)
PreCICE.createParticipant(solverName, configFileName, commRank, commSize)

dimensions = PreCICE.getMeshDimensions(meshName)

numberOfVertices = 3

writeData = zeros(numberOfVertices, dimensions)

vertices = Array{Float64,2}(undef, numberOfVertices, dimensions)

for i = 1:numberOfVertices, j = 1:dimensions
    vertices[i, j] = i
end

vertexIDs = PreCICE.setMeshVertices(meshName, vertices)

let # setting local scope for dt outside of the while loop

    PreCICE.initialize()

    while PreCICE.isCouplingOngoing()

        if PreCICE.requiresWritingCheckpoint()
            println("DUMMY: Writing iteration checkpoint")
        end

        dt = PreCICE.getMaxTimeStepSize()
        readData = PreCICE.readData(meshName, dataReadName, vertexIDs, dt)

        for i = 1:numberOfVertices, j = 1:dimensions
            writeData[i, j] = readData[i, j] + 1.0
        end

        PreCICE.writeData(meshName, dataWriteName, vertexIDs, writeData)

        PreCICE.advance(dt)

        if PreCICE.requiresReadingCheckpoint()
            println("DUMMY: Reading iteration checkpoint")
        else
            println("DUMMY: Advancing in time")
        end

    end # while

end # let

PreCICE.finalize()
println("DUMMY: Closing Julia solver dummy...")
