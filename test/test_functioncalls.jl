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

function requiresMeshConnectivityFor()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fameMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    return false == PreCICE.requiresMeshConnectivityFor(fameMeshName)
end


function setMeshVertices()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
    nFakeVertices = 3  # compare to test/SolverInterface.c, n_fake_vertices
    positions = rand(Cdouble, (nFakeVertices, fakeDimension))
    expectedOutput = 0:(nFakeVertices-1)
    actualOutput = PreCICE.setMeshVertices(fakeMeshName, positions)
    return expectedOutput == actualOutput
end

# function setMeshVerticesEmpty()
#     PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
#     fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
#     fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
#     nFakeVertices = 0  # compare to test/SolverInterface.c, n_fake_vertices
#     positions = rand(Cdouble, (nFakeVertices, fakeDimension))
#     expectedOutput = []
#     actualOutput = PreCICE.setMeshVertices(fakeMeshName, positions)
#     return expectedOutput == actualOutput
# end

function setMeshVertex()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
    position = rand(Cdouble, fakeDimension)
    vertexId = PreCICE.setMeshVertex(fakeMeshName, position)
    return 0 == vertexId
end

function setMeshVertexEmpty()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDimension = 0  # compare to test/SolverInterface.c, fake_dimensions
    position = rand(Cdouble, fakeDimension)
    vertexId = PreCICE.setMeshVertex(fakeMeshName, position)
    return 0 == vertexId
end

function getMeshVertexSize()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    nFakeVertices = 3  # compare to test/SolverInterface.c, n_fake_vertices
    nVertices = PreCICE.getMeshVertexSize(fakeMeshName)
    return nFakeVertices == nVertices
end

function getMeshVertices()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    nFakeVertices = 3  # compare to test/SolverInterface.c, n_fake_vertices
    fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
    fakeVertices = zeros(Cdouble, nFakeVertices, fakeDimension)
    for i = 1:nFakeVertices
        fakeVertices[i, 1] = i - 1
        fakeVertices[i, 2] = i - 1 + nFakeVertices
        fakeVertices[i, 3] = i - 1 + 2 * nFakeVertices
    end
    vertices = PreCICE.getMeshVertices(fakeMeshName, Cint[0:(nFakeVertices-1)...])
    return fakeVertices == vertices
end

function readWriteBlockScalarData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/SolverInterface.c, fake_data_name
    writeData = [3.0, 7.0, 8.0]
    PreCICE.writeBlockScalarData(fakeMeshName, fakeDataName, Cint[1, 2, 3], writeData)
    readData = PreCICE.readBlockScalarData(fakeMeshName, fakeDataName, Cint[1, 2, 3])
    return writeData == readData
end

function readWriteBlockScalarDataEmpty()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/SolverInterface.c, fake_data_name
    writeData = Float64[]
    PreCICE.writeBlockScalarData(fakeMeshName, fakeDataName, Cint[], writeData)
    readData = PreCICE.readBlockScalarData(fakeMeshName, fakeDataName, Cint[])
    return isempty(readData)
end

function readWriteScalarData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/SolverInterface.c, fake_data_name
    writeData = 3.0
    PreCICE.writeScalarData(fakeMeshName, fakeDataName, 1, writeData)
    readData = PreCICE.readScalarData(fakeMeshName, fakeDataName, 1)
    return writeData == readData
end

function readWriteBlockVectorData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/SolverInterface.c, fake_data_name
    writeData = [3.0 7.0 8.0; 7.0 6.0 5.0]
    PreCICE.writeBlockVectorData(fakeMeshName, fakeDataName, Cint[1, 2], writeData)
    readData = PreCICE.readBlockVectorData(fakeMeshName, fakeDataName, Cint[1, 2])
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
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/SolverInterface.c, fake_data_name
    writeData = [1.0, 2.0, 3.0]
    PreCICE.writeVectorData(fakeMeshName, fakeDataName, 1, writeData)
    readData = PreCICE.readVectorData(fakeMeshName, fakeDataName, 1)
    return writeData == readData
end

function getVersionInformation()
    versionInfo = PreCICE.getVersionInformation()
    fakeVersionInfo = "dummy"  # compare to test/SolverInterface.c
    return versionInfo == fakeVersionInfo
end

function setMeshAccessRegion()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeBoundingBox = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
    PreCICE.setMeshAccessRegion(fakeMeshName, fakeBoundingBox)
    return true
end

function getMeshVerticesAndIDs()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDimension = 3  # compare to test/SolverInterface.c, fake_dimensions
    nFakeVertices = 3 # compare to test/SolverInterface.c, fake_n_vertices
    vertexIDs = Cint[0, 1, 2]
    vertices = zeros(nFakeVertices, fakeDimension)
    for i = 1:nFakeVertices
        for j = 1:fakeDimension
            vertices[i, j] = (i - 1) * fakeDimension + j - 1
        end
    end
    fakeIDs, fakeVertices = PreCICE.getMeshVerticesAndIDs(fakeMeshName)
    return fakeIDs == vertexIDs && fakeVertices == vertices
end

function requiresGradientDataFor()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/SolverInterface.c, fake_data_name
    returnConstant = PreCICE.requiresGradientDataFor(fakeMeshName, fakeDataName)
    dummyConstant = 0
    return returnConstant == dummyConstant
end

function writeBlockScalarGradientData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/SolverInterface.c, fake_data_name
    gradientData = [1.0 2 3; 6 7 8; 9 10 11]
    nVertices = 3
    ndims = 3
    fakeIndices = Cint[0:(nVertices-1)...]
    PreCICE.writeBlockScalarGradientData(
        fakeMeshName,
        fakeDataName,
        fakeIndices,
        gradientData,
    )
    readData = PreCICE.readBlockScalarData(
        fakeMeshName,
        fakeDataName,
        Cint[0:(nVertices*ndims-1)...],
    )
    return reshape(permutedims(gradientData), :) == readData
end

function writeScalarGradientData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/SolverInterface.c, fake_data_name
    gradientData = [1.0, 2, 3]
    ndims = 3
    fakeIndex = 0
    PreCICE.writeScalarGradientData(fakeMeshName, fakeDataName, fakeIndex, gradientData)
    readData = PreCICE.readBlockScalarData(fakeMeshName, fakeDataName, Cint[0:(ndims-1)...])
    return gradientData == readData
end

function writeBlockVectorGradientData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/SolverInterface.c, fake_data_name
    nVertices = 2
    ndims = 3
    gradientData = rand(nVertices, ndims * ndims)
    fakeIndices = Cint[0:(nVertices-1)...]
    PreCICE.writeBlockVectorGradientData(
        fakeMeshName,
        fakeDataName,
        fakeIndices,
        gradientData,
    )
    readData = PreCICE.readBlockVectorData(
        fakeMeshName,
        fakeDataName,
        Cint[0:(nVertices*ndims-1)...],
    )
    return reshape(permutedims(gradientData), :) == reshape(permutedims(readData), :)
end

function writeVectorGradientData()
    PreCICE.createSolverInterface("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/SolverInterface.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/SolverInterface.c, fake_data_name
    ndims = 3
    gradientData = rand(ndims * ndims)
    fakeIndex = 0
    PreCICE.writeVectorGradientData(fakeMeshName, fakeDataName, fakeIndex, gradientData)
    readData = PreCICE.readBlockVectorData(fakeMeshName, fakeDataName, Cint[0:(ndims-1)...])
    return gradientData == reshape(permutedims(readData), :)
end
