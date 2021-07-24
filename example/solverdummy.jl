import Pkg; Pkg.activate("..")
using PreCICEC

commRank = 0
commSize = 1

if sizeof(ARGS) < 3
    println("ERROR: pass config path, solver name and mesh name, example: julia solverdummy.jl ./precice-config.xml SolverOne MeshOne")
    exit(1)
end

configFileName = ARGS[1]
solverName = ARGS[2]
meshName = ARGS[3]

println("""DUMMY: Running solver dummy with preCICE config file "$configFileName", participant name "$solverName", and mesh name "$meshName" """)

PreCICEC.createSolverInterface(solverName, configFileName, commRank, commSize)

meshID = PreCICEC.getMeshID(meshName)
dimensions = PreCICEC.getDimensions()

println("-----------")
println(dimensions)

dataWriteName = nothing
dataReadName = nothing

numberOfVertices = 3

if solverName == "SolverOne"
    dataWriteName = "dataOne"
    dataReadName  = "dataTwo"
end

if solverName == "SolverTwo"
    dataReadName  = "dataOne"
    dataWriteName = "dataTwo"
end

readDataID  = PreCICEC.getDataID(dataReadName, meshID)
writeDataID = PreCICEC.getDataID(dataWriteName, meshID)

readData = Array{Float64, 1}(undef, numberOfVertices * dimensions)
writeData = Array{Float64, 1}(undef, numberOfVertices * dimensions)
vertices = Array{Float64, 1}(undef, numberOfVertices * dimensions)
vertexIDs = Array{Int, 1}(undef, numberOfVertices)


for i in 1:numberOfVertices
    for j in 1:dimensions
        vertices[j+ dimensions * (i-1)] = i
        readData[j+ dimensions * (i-1)] = i
        writeData[j+ dimensions * (i-1)] = i
    end
end


println("VertexIds before setMeshVertices:")
println(vertexIDs)

println("Vertices before setMeshVertices:")
println(vertices)

PreCICEC.setMeshVertices(meshID, numberOfVertices, vertices, vertexIDs) 



println("VertexIds after setMeshVertices:")
println(vertexIDs)


println("Vertices after setMeshVertices:")
println(vertices)



let # setting local scope for dt outside of the while loop

dt = PreCICEC.initialize()

while PreCICEC.isCouplingOngoing()
    
    if PreCICEC.isActionRequired(PreCICEC.actionWriteIterationCheckpoint())
        println("DUMMY: Writing iteration checkpoint")
        PreCICEC.markActionFulfilled(PreCICEC.actionWriteIterationCheckpoint())
    end

    if PreCICEC.isReadDataAvailable()
        PreCICEC.readBlockVectorData(readDataID, numberOfVertices, vertexIDs, readData) # investigate, why vertexIDs must be a pointer in rBVD(), but not sMV()
    end

    for i in 1:(numberOfVertices * dimensions)
        writeData[i] = readData[i] + 1
    end

    if PreCICEC.isWriteDataRequired(dt)
        PreCICEC.writeBlockVectorData(writeDataID, numberOfVertices, vertexIDs, writeData)
    end

    dt = PreCICEC.advance(dt)

    if PreCICEC.isActionRequired(PreCICEC.actionReadIterationCheckpoint())
        println("DUMMY: Reading iteration checkpoint")
        PreCICEC.markActionFulfilled(PreCICEC.actionReadIterationCheckpoint())
    else
        println("DUMMY: Advancing in time")
    end

end # while

end # let scope

PreCICEC.finalize()
println("DUMMY: Closing Julia solver dummy...")
