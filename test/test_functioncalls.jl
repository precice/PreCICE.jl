using PreCICE

function constructor()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    return true
end

# initialize is void

# advance is void

# finalize is void

function getMeshDimensions()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshDimension = 3  # compare to test/Participant.c, fake_dimensions
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    return fakeMeshDimension == PreCICE.getMeshDimensions(fakeMeshName)
end

function getDataDimensions()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/Participant.c, fake_data_name
    fakeDataDimension = 3  # compare to test/Participant.c, fake_dimensions
    return fakeDataDimension == PreCICE.getDataDimensions(fakeMeshName, fakeDataName)
end

function isCouplingOngoing()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    return false == PreCICE.isCouplingOngoing()
end

function isTimeWindowComplete()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    return false == PreCICE.isTimeWindowComplete()
end

function getMaxTimeStepSize()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    return 1.0 == PreCICE.getMaxTimeStepSize()
end

function requiresInitialData()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    return false == PreCICE.requiresInitialData()
end

function requiresWritingCheckpoint()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    return false == PreCICE.requiresWritingCheckpoint()
end

function requiresReadingCheckpoint()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    return false == PreCICE.requiresReadingCheckpoint()
end

function hasMesh()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    return false == PreCICE.hasMesh(fakeMeshName)
end

function hasData()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/Participant.c, fake_data_name
    return false == PreCICE.hasData(fakeMeshName, fakeDataName)
end

function requiresMeshConnectivityFor()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    return false == PreCICE.requiresMeshConnectivityFor(fakeMeshName)
end

function setMeshVertex()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    fakeMeshDimension = 3  # compare to test/Participant.c, fake_dimensions
    fakePosition = rand(Cdouble, fakeMeshDimension)
    fakeVertexId = PreCICE.setMeshVertex(fakeMeshName, fakePosition)
    return 0 == fakeVertexId
end


function setMeshVertices()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    fakeMeshDimension = 3  # compare to test/Participant.c, fake_dimensions
    nFakeVertices = 3  # compare to test/Participant.c, n_fake_vertices
    positions = rand(Cdouble, (nFakeVertices, fakeMeshDimension))
    expectedOutput = 0:(nFakeVertices-1)
    actualOutput = PreCICE.setMeshVertices(fakeMeshName, positions)
    return expectedOutput == actualOutput
end

# function setMeshVerticesEmpty()
#     PreCICE.createParticipant("test", "dummy.xml", 0, 1)
#     fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
#     fakeMeshDimension = 3  # compare to test/Participant.c, fake_dimensions
#     nFakeVertices = 0  # compare to test/Participant.c, n_fake_vertices
#     positions = rand(Cdouble, (nFakeVertices, fakeMeshDimension))
#     expectedOutput = []
#     actualOutput = PreCICE.setMeshVertices(fakeMeshName, positions)
#     return expectedOutput == actualOutput
# end

function getMeshVertexSize()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    nFakeVertices = 3  # compare to test/Participant.c, n_fake_vertices
    nVertices = PreCICE.getMeshVertexSize(fakeMeshName)
    return nFakeVertices == nVertices
end

# getMeshVertexSize is void

# setMeshEdge is void

# setMeshEdges is void

# setMeshTriangle, setMeshTriangles, setMeshQuad, setMeshQuads, setMeshTetrahedron, setMeshTetrahedra are void


function readWriteData()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/Participant.c, fake_data_name
    writeData = [3.0 7.0 8.0; 7.0 6.0 5.0]
    PreCICE.writeData(fakeMeshName, fakeDataName, Cint[1, 2], writeData)
    readData = PreCICE.readData(fakeMeshName, fakeDataName, Cint[1, 2], 1.0)
    return writeData == readData
end

# function readWriteDataEmpty()
#     PreCICE.createParticipant("test", "dummy.xml", 0, 1)
#     writeData = Float64[]
#     PreCICE.writeData(1, Int[], writeData)
#     readData = PreCICE.readData(1, Int[], 1.0)
#     return isempty(readData)
# end

function requiresGradientDataFor()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/Participant.c, fake_data_name
    return false == PreCICE.requiresGradientDataFor(fakeMeshName, fakeDataName)

end

function writeGradientData()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    fakeDataName = "FakeData"  # compare to test/Participant.c, fake_data_name
    nVertices = 2
    ndims = 3
    gradientData = rand(nVertices, ndims * ndims)
    fakeIndices = Cint[0:(nVertices-1)...]
    PreCICE.writeGradientData(fakeMeshName, fakeDataName, fakeIndices, gradientData)
    readData =
        PreCICE.readData(fakeMeshName, fakeDataName, Cint[0:(nVertices*ndims-1)...], 1.0)
    return reshape(permutedims(gradientData), :) == reshape(permutedims(readData), :)
end

function getVersionInformation()
    versionInfo = PreCICE.getVersionInformation()
    fakeVersionInfo = "dummy"  # compare to test/Participant.c
    return versionInfo == fakeVersionInfo
end

function setMeshAccessRegion()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    fakeBoundingBox = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
    PreCICE.setMeshAccessRegion(fakeMeshName, fakeBoundingBox)
    return true
end

function getMeshVertexIDsAndCoordinates()
    PreCICE.createParticipant("test", "dummy.xml", 0, 1)
    fakeMeshName = "FakeMesh"  # compare to test/Participant.c, fake_mesh_name
    fakeMeshDimension = 3  # compare to test/Participant.c, fake_dimensions
    nFakeVertices = 3 # compare to test/Participant.c, fake_n_vertices
    vertexIDs = Cint[0, 1, 2]
    expected_vertices =
        reshape(0:(nFakeVertices*fakeMeshDimension-1), (nFakeVertices, fakeMeshDimension))
    fakeIDs, fakeVertices = PreCICE.getMeshVertexIDsAndCoordinates(fakeMeshName)
    return fakeIDs == vertexIDs && fakeVertices == expected_vertices
end
