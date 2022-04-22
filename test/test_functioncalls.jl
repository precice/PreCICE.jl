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
    expectedOutput = range(0, nFakeVertices)
    actualOutput = PreCICE.setMeshVertices(fakeMeshId, positions)
    return expectedOutput == actualOutput
end

function setMeshVerticesEmpty()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshId = 0  # compare to test/SolverInterface.c, fake_mesh_id
    fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
    nFakeVertices = 0  # compare to test/SolverInterface.c, n_fake_vertices
    positions = rand(Cdouble, (nFakeVertices, fakeDimension))
    expectedOutput = range(0, nFakeVertices)
    actualOutput = PreCICE.setMeshVertices(fakeMeshId, positions)
    return expectedOutput == actualOutput
end

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

function getMeshVertexIdsFromPositions()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshId = 0  # compare to test/SolverInterface.c, fake_mesh_id
    fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
    nFakeVertices = 3  # compare to test/SolverInterface.c, n_fake_vertices
    positions = rand(Cdouble, (nFakeVertices, fakeDimension))
    fakeVertexIds = range(0, nFakeVertices)
    vertexIds = PreCICE.getMeshVertexIdsFromPositions(fakeMeshId, positions)
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
    for i in 0:nFakeVertices
        fakeVertices[i, 1] = i
        fakeVertices[i, 2] = i + nFakeVertices
        fakeVertices[i, 3] = i + 2 * nFakeVertices
    end
    vertices = PreCICE.getMeshVertices(fakeMeshId, range(0, nFakeVertices))
    return fakeVertices == vertices
end

function readWriteBlockScalarData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    writeData = [3.0, 7.0, 8.0]
    PreCICE.writeBlockScalarData(1, [1, 2, 3], writeData)
    readData = PreCICE.readBlockScalarData(1, [1, 2, 3])
    return writeData == readData
end

function readWriteBlockScalarDataEmpty()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    writeData = []
    PreCICE.writeBlockScalarData(1, [], writeData)
    readData = PreCICE.readBlockScalarData(1, [])
    return isempty(readData) == 0
end

function readWriteScalarData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    writeData = 3
    PreCICE.writeScalarData(1, 1, writeData)
    readData = PreCICE.readScalarData(1, 1)
    return writeData == readData
end

function readWriteBlockVectorData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    writeData = [3.0 7.0 8.0; 7.0 6.0 5.0]
    PreCICE.writeBlockVectorData(1, [1, 2], writeData)
    readData = PreCICE.readBlockVectorData(1, [1, 2])
    return writeData == readData
end

function readWriteBlockVectorDataEmpty()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    writeData = []
    PreCICE.writeBlockVectorData(1, [], writeData)
    readData = PreCICE.readBlockVectorData(1, [])
    return isempty(readData) == 0
end

function readWriteVectorData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    writeData = [1, 2, 3.0]
    PreCICE.writeVectorData(1, 1, writeData)
    readData = PreCICE.readVectorData(1, 1)
    return writeData == readData
end

function getDataId()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshId = 0  # compare to test/SolverInterface.c, fake_mesh_id
    fakeDataName = "FakeData"  # compare to test/SolverInterface.c, fake_data_name
    fakeData_ID = 15  # compare to test/SolverInterface.c, fake_data_id
    data_ID = PreCICE.getDataId(fakeDataName, fakeMeshId)
    return data_ID == fakeData_ID
end

function getVersionInformation()
    versionInfo = PreCICE.getVersionInformation()
    fakeVersionInfo = "dummy"  # compare to test/SolverInterface.c
    return versionInfo == fakeVersionInfo
end

function actionWriteInitialData()
    returnConstant = PreCICE.actionWriteInitialData()
    # compare to test/SolverInterface.c
    dummyConstant = "dummyWriteInitialData"
    return returnConstant == dummyConstant
end

function actionWriteIterationCheckpoint()
    returnConstant = PreCICE.actionWriteIterationCheckpoint()
    dummyConstant = "dummyWriteIteration"  # compare to test/SolverInterface.c
    return returnConstant == dummyConstant
end

function actionReadIterationCheckpoint()
    returnConstant = PreCICE.actionReadIterationCheckpoint()
    dummyConstant = "dummyReadIteration"  # compare to test/SolverInterface.c
    return returnConstant == dummyConstant
end
