using Distributed

if size(ARGS, 1) < 3
    println("ERROR: pass total processes number N, config path and solver name, 
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

if solverName == "SolverOne"
    meshName = "MeshOne"
    dataWriteName = "dataOne"
    dataReadName = "dataTwo"
else
    meshName = "MeshTwo"
    dataReadName = "dataOne"
    dataWriteName = "dataTwo"
end

println("""DUMMY ($commRank): Running solver dummy with preCICE config file "$configFileName", 
            participant name "$solverName", and mesh name "$meshName" """)

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
            println("DUMMY ($commRank): Writing iteration checkpoint")
            PreCICE.markActionFulfilled(PreCICE.actionWriteIterationCheckpoint())
        end

        if PreCICE.isReadDataAvailable()
            readData = PreCICE.readBlockVectorData(readDataID, vertexIDs)
        end

        writeData = readData .+ 1.0

        if PreCICE.isWriteDataRequired(dt)
            PreCICE.writeBlockVectorData(writeDataID, vertexIDs, writeData)
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

end # begin
