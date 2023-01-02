using PreCICE

function constructor()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    return true
end

# TODO: Not sure if MPI is possible at the moment
# function constructorCustomMpiComm()
#     solverInterface = PreCICE.createSolverInterfaceWithCommunicator("test", "dummy.xml", 0, 1, MPI.COMM_WORLD)
#     return true
# end

function version()
    PreCICE.getVersionInformation()
    return true
end

function getDimensions()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
    return fakeDimension == PreCICE.getDimensions()
end

function getMeshId()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshId = 0  # compare to test/SolverInterface.c, fake_mesh_id
    actualOutput = PreCICE.getMeshID("testMesh")
    return fakeMeshId == actualOutput
end

function setMeshVertices()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshId = 0  # compare to test/SolverInterface.c, fake_mesh_id
    fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
    nFakeVertices = 3  # compare to test/SolverInterface.c, n_fake_vertices
    positions = rand(Cdouble, (nFakeVertices, fakeDimension))
    expectedOutput = 0:(nFakeVertices-1)
    actualOutput = PreCICE.setMeshVertices(fakeMeshId, positions)
    return expectedOutput == actualOutput
end

# function setMeshVerticesEmpty()
#     PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
#     fakeMeshId = 0  # compare to test/SolverInterface.c, fake_mesh_id
#     fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
#     nFakeVertices = 0  # compare to test/SolverInterface.c, n_fake_vertices
#     positions = rand(Cdouble, (nFakeVertices, fakeDimension))
#     expectedOutput = []
#     actualOutput = PreCICE.setMeshVertices(fakeMeshId, positions)
#     return expectedOutput == actualOutput
# end

function setMeshVertex()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshId = 0  # compare to test/SolverInterface.c, fake_mesh_id
    fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
    position = rand(Cdouble, fakeDimension)
    vertexId = PreCICE.setMeshVertex(fakeMeshId, position)
    return 0 == vertexId
end

function setMeshVertexEmpty()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshId = 0  # compare to test/SolverInterface.c, fake_mesh_id
    fakeDimension = 0  # compare to test/SolverInterface.c, fake_dimensions
    position = rand(Cdouble, fakeDimension)
    vertexId = PreCICE.setMeshVertex(fakeMeshId, position)
    return 0 == vertexId
end

function getMeshVertexIDsFromPositions()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshId = 0  # compare to test/SolverInterface.c, fake_mesh_id
    fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
    nFakeVertices = 3  # compare to test/SolverInterface.c, n_fake_vertices
    positions = rand(Cdouble, (nFakeVertices, fakeDimension))
    fakeVertexIds = 0:(nFakeVertices-1)
    vertexIds = PreCICE.getMeshVertexIDsFromPositions(fakeMeshId, positions)
    return fakeVertexIds == vertexIds
end

function getMeshVertexSize()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshId = 0  # compare to test/SolverInterface.c, fake_mesh_id
    nFakeVertices = 3  # compare to test/SolverInterface.c, n_fake_vertices
    nVertices = PreCICE.getMeshVertexSize(fakeMeshId)
    return nFakeVertices == nVertices
end

function getMeshVertices()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshId = 0  # compare to test/SolverInterface.c, fake_mesh_id
    nFakeVertices = 3  # compare to test/SolverInterface.c, n_fake_vertices
    fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
    fakeVertices = zeros(Cdouble, nFakeVertices, fakeDimension)
    for i = 1:nFakeVertices
        fakeVertices[i, 1] = i - 1
        fakeVertices[i, 2] = i - 1 + nFakeVertices
        fakeVertices[i, 3] = i - 1 + 2 * nFakeVertices
    end
    vertices = PreCICE.getMeshVertices(fakeMeshId, Cint[0:(nFakeVertices-1)...])
    return fakeVertices == vertices
end

function readWriteBlockScalarData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    writeData = [3.0, 7.0, 8.0]
    PreCICE.writeBlockScalarData(1, Cint[1, 2, 3], writeData)
    readData = PreCICE.readBlockScalarData(1, Cint[1, 2, 3])
    return writeData == readData
end

function readWriteBlockScalarDataEmpty()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    writeData = Float64[]
    PreCICE.writeBlockScalarData(1, Cint[], writeData)
    readData = PreCICE.readBlockScalarData(1, Cint[])
    return isempty(readData)
end

function readWriteScalarData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    writeData = 3.0
    PreCICE.writeScalarData(1, 1, writeData)
    readData = PreCICE.readScalarData(1, 1)
    return writeData == readData
end

function readWriteBlockVectorData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    writeData = [3.0 7.0 8.0; 7.0 6.0 5.0]
    PreCICE.writeBlockVectorData(1, Cint[1, 2], writeData)
    readData = PreCICE.readBlockVectorData(1, Cint[1, 2])
    return writeData == readData
end

# function readWriteBlockVectorDataEmpty()
#     PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
#     writeData = Float64[]
#     PreCICE.writeBlockVectorData(1, Int[], writeData)
#     readData = PreCICE.readBlockVectorData(1, Int[])
#     return isempty(readData)
# end

function readWriteVectorData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    writeData = [1.0, 2.0, 3.0]
    PreCICE.writeVectorData(1, 1, writeData)
    readData = PreCICE.readVectorData(1, 1)
    return writeData == readData
end

function getDataID()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshId = 0  # compare to test/SolverInterface.c, fake_mesh_id
    fakeDataName = "FakeData"  # compare to test/SolverInterface.c, fake_data_name
    fakeData_ID = 15  # compare to test/SolverInterface.c, fake_data_id
    data_ID = PreCICE.getDataID(fakeDataName, fakeMeshId)
    return data_ID == fakeData_ID
end

function getVersionInformation()
    versionInfo = PreCICE.getVersionInformation()
    fakeVersionInfo = "dummy"  # compare to test/SolverInterface.c
    return versionInfo == fakeVersionInfo
end

function requiresGradientDataFor()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeDataId = 0  # compare to test/SolverInterface.c, fake_data_id
    returnConstant = PreCICE.requiresGradientDataFor(fakeDataId)
    dummyConstant = 0
    return returnConstant == dummyConstant
end

function writeBlockScalarGradientData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeDataId = 0  # compare to test/SolverInterface.c, fake_data_id
    gradientData = [1.0 2 3; 6 7 8; 9 10 11]
    nVertices = 3
    ndims = 3
    fakeIndices = Cint[0:(nVertices-1)...]
    PreCICE.writeBlockScalarGradientData(fakeDataId, fakeIndices, gradientData)
    readData = PreCICE.readBlockScalarData(fakeDataId, Cint[0:(nVertices*ndims-1)...])
    return reshape(permutedims(gradientData), :) == readData
end

function writeScalarGradientData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeDataId = 0  # compare to test/SolverInterface.c, fake_data_id
    gradientData = [1.0, 2, 3]
    ndims = 3
    fakeIndex = 0
    PreCICE.writeScalarGradientData(fakeDataId, fakeIndex, gradientData)
    readData = PreCICE.readBlockScalarData(fakeDataId, Cint[0:(ndims-1)...])
    return gradientData == readData
end

function writeBlockVectorGradientData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeDataId = 0  # compare to test/SolverInterface.c, fake_data_id
    nVertices = 2
    ndims = 3
    gradientData = rand(nVertices, ndims * ndims)
    fakeIndices = Cint[0:(nVertices-1)...]
    PreCICE.writeBlockVectorGradientData(fakeDataId, fakeIndices, gradientData)
    readData = PreCICE.readBlockVectorData(fakeDataId, Cint[0:(nVertices*ndims-1)...])
    return reshape(permutedims(gradientData), :) == reshape(permutedims(readData), :)
end

function writeVectorGradientData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeDataId = 0  # compare to test/SolverInterface.c, fake_data_id
    ndims = 3
    gradientData = rand(ndims * ndims)
    fakeIndex = 0
    PreCICE.writeVectorGradientData(fakeDataId, fakeIndex, gradientData)
    readData = PreCICE.readBlockVectorData(fakeDataId, Cint[0:(ndims-1)...])
    return gradientData == reshape(permutedims(readData), :)
end
