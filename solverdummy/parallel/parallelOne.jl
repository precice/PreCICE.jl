import Pkg; Pkg.activate("../..")
using Distributed

addprocs(4; exeflags="--project" )

@everywhere begin

using PreCICE

commRank = myid() - 1
commSize = nprocs()


configFileName = "./precice-config-parallel.xml"
solverName = "SolverOne"
meshName = "MeshOne"

println("""DUMMY: Running solver dummy with preCICE config file "$configFileName", participant name "$solverName", and mesh name "$meshName" """)

PreCICE.createSolverInterface(solverName, configFileName, commRank, commSize)

meshID = PreCICE.getMeshID(meshName)
dimensions = PreCICE.getDimensions()

dataWriteName = nothing
dataReadName = nothing

numberOfVertices = 1


dataWriteName = "dataOne"
dataReadName  = "dataTwo"


readDataID  = PreCICE.getDataID(dataReadName, meshID)
writeDataID = PreCICE.getDataID(dataWriteName, meshID)

readData = Array{Float64, 1}(undef, numberOfVertices * dimensions)
writeData = Array{Float64, 1}(undef, numberOfVertices * dimensions)
vertices = Array{Float64, 1}(undef, numberOfVertices * dimensions)


for i in 1:numberOfVertices
    for j in 1:dimensions
        vertices[j+ dimensions * (i-1)] = i-1 + commRank
        readData[j+ dimensions * (i-1)] = i-1 + commRank
        writeData[j+ dimensions * (i-1)] = i-1 + commRank
    end
end


let # setting local scope for dt outside of the while loop
vertexIDs = PreCICE.setMeshVertices(meshID, numberOfVertices, vertices) 

dt = PreCICE.initialize()

while PreCICE.isCouplingOngoing()
    
    if PreCICE.isActionRequired(PreCICE.actionWriteIterationCheckpoint())
        println("DUMMY: Writing iteration checkpoint of rank ", commRank)
        PreCICE.markActionFulfilled(PreCICE.actionWriteIterationCheckpoint())
    end

    if PreCICE.isReadDataAvailable()
        PreCICE.readBlockVectorData(readDataID, numberOfVertices, vertexIDs, readData) 
        println("read data:", readData)
        println("type of", typeof(readData))
        
    end

    
    writeData = readData .+ 1.0
    

    if PreCICE.isWriteDataRequired(dt)
        println("write data:", writeData)
        println("type of", typeof(writeData))
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

end # let scope

PreCICE.finalize()
println("DUMMY: Closing Julia solver dummy...")

end