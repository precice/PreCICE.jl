module PreCICE
"""
The `PreCICE` module provides the bindings for using the preCICE api. For more information, visit https://precice.org/.
""" 


# TODO add 'return nothing' keyword to void functions
# TODO add Julia's exception handling to the ccalls
# TODO maybe load libprecice.so only once with Libdl.dlopen() instead of calling it in each method?
# TODO get rid of global variables


libprecicePath = "/usr/lib/x86_64-linux-gnu/libprecice.so"
defaultLibprecicePath = "/usr/lib/x86_64-linux-gnu/libprecice.so"




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
                                solverProcessIndex::Integer,  
                                solverProcessSize::Integer)
    ccall((:precicec_createSolverInterface, libprecicePath), 
            Cvoid, 
            (Ptr{Int8},Ptr{Int8}, Cint, Cint), 
            participantName, 
            configFilename, 
            solverProcessIndex, 
            solverProcessSize)
end


function createSolverInterfaceWithCommunicator(participantName::String, 
                                                configFilename::String, 
                                                solverProcessIndex::Integer,  
                                                solverProcessSize::Integer, 
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
    dt::Float64 = ccall((:precicec_advance, libprecicePath), Cdouble, (Cdouble,), computedTimestepLength)
    return dt
end


function finalize()
    ccall((:precicec_finalize, libprecicePath), Cvoid, ())
end


function getDimensions()::Integer
    dim::Integer = ccall((:precicec_getDimensions, libprecicePath), Cint, ())
    return dim
end


function isCouplingOngoing()::Bool
    ans::Integer = ccall((:precicec_isCouplingOngoing, libprecicePath), Cint, ())
    return ans
end


function isTimeWindowComplete()::Bool
    ans::Integer = ccall((:precicec_isTimeWindowComplete, libprecicePath), Cint, ())
    return ans
end


function hasToEvaluateSurrogateModel()::Bool
    ans::Integer = ccall((:precicec_hasToEvaluateSurrogateModel, libprecicePath), Cint, ())
    return ans
end


function hasToEvaluateFineModel()::Bool
    ans::Integer = ccall((:precicec_hasToEvaluateFineModel, libprecicePath), Cint, ())
    return ans
end


function isReadDataAvailable()::Bool
    ans::Integer = ccall((:precicec_isReadDataAvailable, libprecicePath), Cint, ())
    return ans
end


function isWriteDataRequired(computedTimestepLength::Float64)::Bool
    ans::Integer = ccall((:precicec_isWriteDataRequired, libprecicePath), Cint, (Cdouble,), computedTimestepLength)
    return ans
end


function isActionRequired(action::String)::Bool
    ans::Integer = ccall((:precicec_isActionRequired, libprecicePath), Cint, (Ptr{Int8},), action)
    return ans
end


function markActionFulfilled(action::String)
    ccall((:precicec_markActionFulfilled, libprecicePath), Cvoid, (Ptr{Int8},), action)
end


function hasMesh(meshName::String)::Bool
    ans::Integer = ccall((:precicec_hasMesh, libprecicePath), Cint, (Ptr{Int8},), meshName)
    return ans
end


function getMeshID(meshName::String)
    ans::Integer = ccall((:precicec_getMeshID, libprecicePath), Cint, (Ptr{Int8},), meshName)
    return ans
end


function hasData(dataName::String, meshID::Integer)::Bool
    ans::Integer = ccall((:precicec_hasData, libprecicePath), Cint, (Ptr{Int8}, Cint), dataName, meshID)
    return ans
end


function getDataID(dataName::String, meshID::Integer)
    id::Integer = ccall((:precicec_getDataID, libprecicePath), Cint, (Ptr{Int8}, Cint), dataName, meshID)
    return id
end


function setMeshVertex(meshID::Integer, position::AbstractArray{Float64})
    id::Integer = ccall((:precicec_setMeshVertex, libprecicePath), Cint, (Cint, Ref{Float64}), meshID, position)
    return id
end


function getMeshVertices(meshID::Integer, size::Integer, ids::AbstractArray{Cint}, positions::AbstractArray{Float64})
    ccall((:precicec_getMeshVertices, libprecicePath), Cvoid, (Cint, Cint, Ref{Cint}, Ref{Cdouble}), meshID, size, ids, positions)
end


function setMeshVertices(meshID::Integer, size::Integer, positions::AbstractArray{Float64})
    vertexIDs = Array{Int32, 1}(undef, size)
    ccall((:precicec_setMeshVertices, libprecicePath), Cvoid, (Cint, Cint, Ref{Cdouble}, Ref{Cint}), meshID, size, positions, vertexIDs)
    return vertexIDs 
end

function getMeshVertexSize(meshID::Integer)::Integer
    size::Integer = ccall((:precicec_getMeshVertexSize, libprecicePath), Cint, (Cint,), meshID)
    return size
end


function getMeshVertexIDsFromPositions(meshID::Integer, size::Integer, positions::AbstractArray{Float64}, ids::AbstractArray{Cint})
    ccall((:precicec_getMeshVertexIDsFromPositions, libprecicePath), Cvoid, (Cint, Cint, Ref{Cdouble}, Ref{Cint}), meshID, size, positions, ids)
end


function setMeshEdge(meshID::Integer, firstVertexID::Integer, secondVertexID::Integer)::Integer
    edgeID::Integer = ccall((:precicec_setMeshEdge, libprecicePath), Cint, (Cint, Cint, Cint), meshID, firstVertexID, secondVertexID)
    return edgeID
end


function setMeshTriangle(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer)
    ccall((:precicec_setMeshTriangle, libprecicePath), Cvoid, (Cint, Cint, Cint, Cint), meshID, firstEdgeID, secondEdgeID, thirdEdgeID)
end


function setMeshTriangleWithEdges(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer)
    ccall((:precicec_setMeshTriangleWithEdges, libprecicePath), Cvoid, (Cint, Cint, Cint, Cint), meshID, firstEdgeID, secondEdgeID, thirdEdgeID)
end


function setMeshQuad(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID, fourthEdgeID::Integer)
    ccall((:precicec_setMeshQuad, libprecicePath), Cvoid, (Cint, Cint, Cint, Cint, Cint), meshID, firstEdgeID, secondEdgeID, thirdEdgeID, fourthEdgeID)
end


function setMeshQuadWithEdges(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer)
    ccall((:precicec_setMeshQuadWithEdges, libprecicePath), Cvoid, (Cint, Cint, Cint, Cint, Cint), meshID, firstEdgeID, secondEdgeID, thirdEdgeID, fourthEdgeID)
end


function writeBlockVectorData(dataID::Integer, size::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})
    ccall((:precicec_writeBlockVectorData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cint}, Ref{Cdouble}), dataID, size, valueIndices, values)
end


function writeVectorData(dataID::Integer, valueIndex::Integer, dataValue::AbstractArray{Float64})
    ccall((:precicec_writeVectorData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cdouble}), dataID, valueIndex, dataValue)
end


function writeBlockScalarData(dataID::Integer, size::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})
    ccall((:precicec_writeBlockScalarData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cint}, Ref{Cdouble}), dataID, size, valueIndices, values)
end


function writeScalarData(dataID::Integer, valueIndex::Integer, dataValue::Float64)
    ccall((:precicec_writeScalarData, libprecicePath), Cvoid, (Cint, Cint, Cdouble), dataID, valueIndex, dataValue)
end


function readBlockVectorData(dataID::Integer, size::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})
    ccall((:precicec_readBlockVectorData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cint}, Ref{Cdouble}), dataID, size, valueIndices, values)
end


function readVectorData(dataID::Integer, valueIndex::Integer, dataValue::AbstractArray{Float64})
    ccall((:precicec_readVectorData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cdouble}), dataID, valueIndex, dataValue)
end


function readBlockScalarData(dataID::Integer, size::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})
    ccall((:precicec_readScalarVectorData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cint}, Ref{Cdouble}), dataID, size, valueIndices, values)
end


function readScalarData(dataID::Integer, valueIndex::Integer, dataValue::AbstractArray{Float64})
    ccall((:precicec_readScalarData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cdouble}), dataID, valueIndex, dataValue)
end


function getVersionInformation()
    versionCstring = ccall((:precicec_getVersionInformation, libprecicePath), Cstring, ())
    return unsafe_string(versionCstring)
end


function mapWriteDataFrom(fromMeshID::Integer)
    ccall((:precicec_mapWriteDataFrom, libprecicePath), Cvoid, (Cint,), fromMeshID)
end


function mapReadDataTo(fromMeshID::Integer)
    ccall((:precicec_mapReadDataTo, libprecicePath), Cvoid, (Cint,), fromMeshID)
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


include("documentation.jl")

end # module
