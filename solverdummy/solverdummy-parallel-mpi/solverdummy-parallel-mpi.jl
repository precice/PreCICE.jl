import Pkg; Pkg.activate("../..")
#Pkg.build("MPI") # build MPI.jl for updating the MPI executable path
using PreCICE
using MPI


if size(ARGS, 1) < 2
    println("ERROR: pass config path, solver name, 
        example: julia solverdummy.jl ./precice-config.xml SolverOne")
    exit(1)
end

MPI.Init()
comm = MPI.COMM_WORLD

commRank = MPI.Comm_rank(comm)
commSize = MPI.Comm_size(comm)

configFileName = ARGS[1]
solverName = ARGS[2]

# set meshName depending on solverName
if solverName == "SolverOne"
    meshName = "MeshOne"
else 
    meshName = "MeshTwo"
end

println("""DUMMY ($(MPI.Comm_rank(comm))): Running solver dummy with preCICE config file 
        "$configFileName", participant name "$solverName", and mesh name "$meshName" """)

PreCICE.createSolverInterface(solverName, configFileName, commRank, commSize)

meshID = PreCICE.getMeshID(meshName)
dimensions = PreCICE.getDimensions()


numberOfVertices = 1

if solverName == "SolverOne"
    dataWriteName = "dataOne"
    dataReadName  = "dataTwo"
else
    dataReadName  = "dataOne"
    dataWriteName = "dataTwo"
end

readDataID  = PreCICE.getDataID(dataReadName, meshID)
writeDataID = PreCICE.getDataID(dataWriteName, meshID)

readData = zeros(numberOfVertices * dimensions)
writeData = zeros(numberOfVertices * dimensions)

vertices = Array{Float64, 1}(undef, numberOfVertices * dimensions)

# create different vertices coordinates for different procs
for i in 1:numberOfVertices, j in 1:dimensions
    offset = commRank * numberOfVertices
    vertices[j + dimensions * (i-1)] = i-1 + offset
end

vertexIDs = PreCICE.setMeshVertices(meshID, numberOfVertices, vertices)

let # setting local scope for dt outside of the while loop

dt = PreCICE.initialize()

while PreCICE.isCouplingOngoing()
    
    if PreCICE.isActionRequired(PreCICE.actionWriteIterationCheckpoint())
        #println("""DUMMY ($(MPI.Comm_rank(comm))): Writing iteration checkpoint""")
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
        println("""DUMMY ($(MPI.Comm_rank(comm))): Reading iteration checkpoint""")
        PreCICE.markActionFulfilled(PreCICE.actionReadIterationCheckpoint())
    else
        println("""DUMMY ($(MPI.Comm_rank(comm))): Advancing in time""")
    end

end # while

end # let 

PreCICE.finalize()

println("""DUMMY ($(MPI.Comm_rank(comm))): Closing Julia solver dummy...""")

