module PreCICE
"""
The `PreCICE` module provides the bindings for using the preCICE api. For more information, visit https://precice.org/.
"""


libprecicePath = "/usr/lib/x86_64-linux-gnu/libprecice.so.2.2.0"
defaultLibprecicePath = "/usr/lib/x86_64-linux-gnu/libprecice.so.2.2.0" 


# TODO add 'return nothing' keyword to void functions
# TODO add Julia's exception handling to the ccalls
# TODO maybe load libprecice.so only once with Libdl.dlopen() instead of calling it in each method?
# TODO get rid of global variables
# TODO add documentation

export 
    # construction and configuration
    setPathToLibprecice, resetPathToLibprecice, createSolverInterface, createSolverInterfaceWithCommunicator,

    # steering methods
    initialize, initializeData, advance, finalize,

    # status queries
    getDimensions, isCouplingOngoing, isReadDataAvailable, isWriteDataRequired, isTimeWindowComplete, hasToEvaluateSurrogateModel, hasToEvaluateFineModel,

    # action methods
    isActionRequired, markActionFulfilled,

    # mesh access
    hasMesh, getMeshID, setMeshVertex, getMeshVertexSize, setMeshVertices, getMeshVertices, getMeshVertexIDsFromPositions, setMeshEdge, setMeshTriangle, 
    setMeshTriangleWithEdges, setMeshQuad, setMeshQuadWithEdges,

    # data access
    hasData, getDataID, mapReadDataTo, mapWriteDataFrom, writeBlockVectorData, writeVectorData, writeBlockScalarData, writeScalarData, readBlockScalarData,
    readVectorData, readBlockScalarData, readScalarData,

    # constants
    getVersionInformation, actionWriteInitialData, actionWriteIterationCheckpoint, actionReadIterationCheckpoint



function setPathToLibprecice(pathToPrecice::String) 
    global libprecicePath = pathToPrecice
end


function resetPathToLibprecice() 
    global libprecicePath = defaultLibprecicePath
end


function createSolverInterface(participantName::String, 
                                configFilename::String,   
                                solverProcessIndex::Int,  
                                solverProcessSize::Int)
    ccall((:precicec_createSolverInterface, libprecicePath), 
            Cvoid, 
            (Ptr{Int8},Ptr{Int8}, Int, Int), 
            participantName, 
            configFilename, 
            solverProcessIndex, 
            solverProcessSize)
end


function createSolverInterfaceWithCommunicator(participantName::String, 
                                                configFilename::String, 
                                                solverProcessIndex::Int,  
                                                solverProcessSize::Int, 
                                                communicator::Union{Ptr{Cvoid}, Ref{Cvoid}, Ptr{Nothing}}) # test if type of com is correct
    ccall((:precicec_createSolverInterface_withCommunicator, libprecicePath), 
            Cvoid, 
            (Ptr{Int8}, Ptr{Int8}, Int, Int, Union{Ptr{Cvoid}, Ref{Cvoid}, Ptr{Nothing}}), 
            participantName, 
            configFilename, 
            solverProcessIndex, 
            solverProcessSize, communicator)
end


function initialize()::Float64
    dt::Float64 = ccall((:precicec_initialize, libprecicePath), Cdouble, ())
    return dt
end


function initializeData()
    ccall((:precicec_initialize_data, libprecicePath), Cvoid, ())
end


function advance(computedTimestepLength::Float64)::Float64
    dt::Float64 = ccall((:precicec_advance, libprecicePath), Cdouble, (Float64,), computedTimestepLength)
    return dt
end


function finalize()
    ccall((:precicec_finalize, libprecicePath), Cvoid, ())
end


function getDimensions()::Int # int or int32 ?
    dim::Int = ccall((:precicec_getDimensions, libprecicePath), Cint, ())
    return dim
end


function isCouplingOngoing()::Bool
    ans::Int = ccall((:precicec_isCouplingOngoing, libprecicePath), Cint, ())
    return ans
end


function isTimeWindowComplete()::Bool
    ans::Int = ccall((:precicec_isTimeWindowComplete, libprecicePath), Cint, ())
    return ans
end


function hasToEvaluateSurrogateModel()::Bool
    ans::Int = ccall((:precicec_hasToEvaluateSurrogateModel, libprecicePath), Cint, ())
    return ans
end


function hasToEvaluateFineModel()::Bool
    ans::Int = ccall((:precicec_hasToEvaluateFineModel, libprecicePath), Cint, ())
    return ans
end


function isReadDataAvailable()::Bool
    ans::Int = ccall((:precicec_isReadDataAvailable, libprecicePath), Cint, ())
    return ans
end


function isWriteDataRequired(computedTimestepLength::Float64)::Bool
    ans::Int = ccall((:precicec_isWriteDataRequired, libprecicePath), Cint, (Float64,), computedTimestepLength)
    return ans
end


function isActionRequired(action::String)::Bool
    ans::Int = ccall((:precicec_isActionRequired, libprecicePath), Cint, (Ptr{Int8},), action)
    return ans
end


function markActionFulfilled(action::String)
    ccall((:precicec_markActionFulfilled, libprecicePath), Cvoid, (Ptr{Int8},), action)
end


function hasMesh(meshName::String)::Bool
    ans::Int = ccall((:precicec_hasMesh, libprecicePath), Cint, (Ptr{Int8},), meshName)
    return ans
end


function getMeshID(meshName::String)
    ans::Int = ccall((:precicec_getMeshID, libprecicePath), Cint, (Ptr{Int8},), meshName)
    return ans
end


function hasData(dataName::String, meshID::Int)::Bool
    ans::Int = ccall((:precicec_hasData, libprecicePath), Cint, (Ptr{Int8}, Int), dataName, meshID)
    return ans
end


function getDataID(dataName::String, meshID::Int)
    id::Int = ccall((:precicec_getDataID, libprecicePath), Cint, (Ptr{Int8}, Int), dataName, meshID)
    return id
end


function setMeshVertex(meshID::Int, position::AbstractArray{Float64})
    id::Int = ccall((:precicec_setMeshVertex, libprecicePath), Cint, (Int, Ref{Float64}), meshID, position)
    return id
end


function getMeshVertices(meshID::Int, size::Int, ids::AbstractArray{Int}, positions::AbstractArray{Float64})
    ccall((:precicec_getMeshVertices, libprecicePath), Cvoid, (Int, Int, Ref{Int}, Ref{Float64}), meshID, size, ids, positions)
end


function setMeshVertices(meshID::Int, size::Int, positions::AbstractArray{Float64},  ids::AbstractArray{Int})
    ccall((:precicec_setMeshVertices, libprecicePath), Cvoid, (Int, Int, Ref{Float64}, Ref{Int}), meshID, size, positions, ids)
end


function getMeshVertexSize(size::Int)::Int
    size::Int = ccall((:precicec_getMeshVertexSize, libprecicePath), Cint, (Int,), size)
    return size
end


function getMeshVertexIDsFromPositions(meshID::Int, size::Int, positions::AbstractArray{Float64}, ids::AbstractArray{Int})
    ccall((:precicec_getMeshVertexIDsFromPositions, libprecicePath), Cvoid, (Int, Int, Ref{Float64}, Ref{Int}), meshID, size, positions, ids)
end


function setMeshEdge(meshID::Int, firstVertexID::Int, secondVertexID::Int)::Int
    edgeID::Int = ccall((:precicec_setMeshEdge, libprecicePath), Cint, (Int, Int, Int), meshID, firstVertexID, secondVertexID)
    return edgeID
end


function setMeshTriangle(meshID::Int, firstEdgeID::Int, secondEdgeID::Int, thirdEdgeID::Int)
    ccall((:precicec_setMeshTriangle, libprecicePath), Cvoid, (Int, Int, Int, Int), meshID, firstEdgeID, secondEdgeID, thirdEdgeID)
end


function setMeshTriangleWithEdges(meshID::Int, firstEdgeID::Int, secondEdgeID::Int, thirdEdgeID::Int)
    ccall((:precicec_setMeshTriangleWithEdges, libprecicePath), Cvoid, (Int, Int, Int, Int), meshID, firstEdgeID, secondEdgeID, thirdEdgeID)
end


function setMeshQuad(meshID::Int, firstEdgeID::Int, secondEdgeID::Int, thirdEdgeID, fourthEdgeID::Int)
    ccall((:precicec_setMeshQuad, libprecicePath), Cvoid, (Int, Int, Int, Int, Int), meshID, firstEdgeID, secondEdgeID, thirdEdgeID, fourthEdgeID)
end


function setMeshQuadWithEdges(meshID::Int, firstEdgeID::Int, secondEdgeID::Int, thirdEdgeID::Int)
    ccall((:precicec_setMeshQuadWithEdges, libprecicePath), Cvoid, (Int, Int, Int, Int, Int), meshID, firstEdgeID, secondEdgeID, thirdEdgeID, fourthEdgeID)
end


function writeBlockVectorData(dataID::Int, size::Int, valueIndices::AbstractArray{Int}, values::AbstractArray{Float64})
    ccall((:precicec_writeBlockVectorData, libprecicePath), Cvoid, (Int, Int, Ref{Int}, Ref{Float64}), dataID, size, valueIndices, values)
end


function writeVectorData(dataID::Int, valueIndex::Int, dataValue::AbstractArray{Float64})
    ccall((:precicec_writeVectorData, libprecicePath), Cvoid, (Int, Int, Ref{Float64}), dataID, valueIndex, dataValue)
end


function writeBlockScalarData(dataID::Int, size::Int, valueIndices::AbstractArray{Int}, values::AbstractArray{Float64})
    ccall((:precicec_writeBlockScalarData, libprecicePath), Cvoid, (Int, Int, Ref{Int}, Ref{Float64}), dataID, size, valueIndices, values)
end


function writeScalarData(dataID::Int, valueIndex::Int, dataValue::AbstractArray{Float64})
    ccall((:precicec_writeScalarData, libprecicePath), Cvoid, (Int, Int, Ref{Float64}), dataID, valueIndex, dataValue)
end


function readBlockVectorData(dataID::Int, size::Int, valueIndices::AbstractArray{Int}, values::AbstractArray{Float64})
    ccall((:precicec_readBlockVectorData, libprecicePath), Cvoid, (Int, Int, Ref{Int}, Ref{Float64}), dataID, size, valueIndices, values)
end


function readVectorData(dataID::Int, valueIndex::Int, dataValue::AbstractArray{Float64})
    ccall((:precicec_readVectorData, libprecicePath), Cvoid, (Int, Int, Ref{Float64}), dataID, valueIndex, dataValue)
end


function readBlockScalarData(dataID::Int, size::Int, valueIndices::AbstractArray{Int}, values::AbstractArray{Float64})
    ccall((:precicec_readScalarVectorData, libprecicePath), Cvoid, (Int, Int, Ref{Int}, Ref{Float64}), dataID, size, valueIndices, values)
end


function readScalarData(dataID::Int, valueIndex::Int, dataValue::AbstractArray{Float64})
    ccall((:precicec_readScalarData, libprecicePath), Cvoid, (Int, Int, Ref{Float64}), dataID, valueIndex, dataValue)
end


function getVersionInformation()
    versionCstring = ccall((:precicec_getVersionInformation, libprecicePath), Cstring, ())
    return unsafe_string(versionCstring)
end


function mapWriteDataFrom(fromMeshID::Int)
    ccall((:precicec_mapWriteDataFrom, libprecicePath), Cvoid, (Int,), fromMeshID)
end


function mapReadDataTo(fromMeshID::Int)
    ccall((:precicec_mapReadDataTo, libprecicePath), Cvoid, (Int,), fromMeshID)
end


function actionWriteInitialData()
    msgCstring = ccall((:precicec_actionWriteInitialData, libprecicePath), Cstring, ())
    return unsafe_string(msgCstring)
end


function actionWriteIterationCheckpoint()
    msgCstring = ccall((:precicec_actionWriteIterationCheckpoint, libprecicePath), Cstring, ())
    return unsafe_string(msgCstring)
end


function actionReadIterationCheckpoint()
    msgCstring = ccall((:precicec_actionReadIterationCheckpoint, libprecicePath), Cstring, ())
    return unsafe_string(msgCstring)
end


end # module
