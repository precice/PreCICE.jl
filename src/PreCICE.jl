module PreCICE
"""
The `PreCICE` module provides the bindings for using the preCICE api. For more information, visit https://precice.org/.
"""


# TODO add 'return nothing' keyword to void functions
# TODO add Julia's exception handling to the ccalls
# TODO maybe load libprecice.so only once with Libdl.dlopen() instead of calling it in each method?

# TODO createSolverInterfaceWithCommunicator documentation
# TODO does it make sense to set the data_id by hand in the example

libprecicePath = string(split(readlines(`whereis libprecice`)[], ' ')[2])
defaultLibprecicePath = string(split(readlines(`whereis libprecice`)[], ' ')[2])

export 
    # construction and configuration
    createSolverInterface, createSolverInterfaceWithCommunicator,

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


@doc """

setPathToLibprecice(pathToPrecice::String) 

Configure which preCICE binary to use. Set it if preCICE was installed at a custom directory.
"""
function setPathToLibprecice(pathToPrecice::String) 
global libprecicePath = pathToPrecice
end


@doc """
Reset custom path configurations and use the binary at the default path "/usr/local/lib/libprecice.so".
"""
function resetPathToLibprecice() 
global libprecicePath = defaultLibprecicePath
end


@doc """

    createSolverInterface(participantName::String, configFilename::String, solverProcessIndex::Integer, solverProcessSize::Integer)

Create the coupling interface and configure it. Must get called before any other method of this interface.

# Arguments
- `participantName::String`: Name of the participant from the xml configuration that is using the interface.
- `configFilename::String`: Name (with path) of the xml configuration file.
- `solverProcessIndex::Integer`: If the solver code runs with several processes, each process using preCICE has to specify its index, which has to start from 0 and end with solverProcessSize - 1.
- `solverProcessSize::Integer`: The number of solver processes of this participant using preCICE.

# Examples
```julia
createSolverInterface("SolverOne", "./precice-config.xml", 0, 1)
```
"""
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

@doc """
    createSolverInterfaceWithCommunicator(participantName::String, configFilename::String, solverProcessIndex::Integer, solverProcessSize::Integer, communicator::Union{Ptr{Cvoid}, Ref{Cvoid}, Ptr{Nothing}})

TODO: Documentation or [WIP] tag. The data types of the communicator are not yet verified.

# See also:

[`createSolverInterface`](@ref)

# Arguments

- `participantName::String`: Name of the participant from the xml configuration that is using the interface.
- `configFilename::String`: Name (with path) of the xml configuration file.
- `solverProcessIndex::Integer`: If the solver code runs with several processes, each process using preCICE has to specify its index, which has to start from 0 and end with solverProcessSize - 1.
- `solverProcessSize::Integer`: The number of solver processes of this participant using preCICE.
- `communicator::Union{Ptr{Cvoid}, Ref{Cvoid}, Ptr{Nothing}}`: TODO ?
"""
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


@doc """

    initialize()::Float64

Fully initializes preCICE.
This function handles:
- Parallel communication to the coupling partner/s is setup.
- Meshes are exchanged between coupling partners and the parallel partitions are created.
- **Serial Coupling Scheme:** If the solver is not starting the simulation, coupling data is received from the coupling partner's first computation.

Return the maximum length of first timestep to be computed by the solver.
"""
function initialize()::Float64
    dt::Float64 = ccall((:precicec_initialize, libprecicePath), Cdouble, ())
    return dt
end


@doc """

    initializeData()

Initializes coupling data. The starting values for coupling data are zero by default.
To provide custom values, first set the data using the Data Access methods and
call this method to finally exchange the data.

Serial Coupling Scheme: 
- Only the first participant has to call this method, the second participant
receives the values on calling [`initialize`](@ref).

Parallel Coupling Scheme:
- Values in both directions are exchanged.
- Both participants need to call [`initializeData`](@ref).

# Notes

Previous calls:
 - [`initialize`](@ref) has been called successfully.
 - The action `WriteInitialData` is required
 - [`advance`](@ref) has not yet been called.
 - [`finalize`](@ref) has not yet been called.

Tasks completed:
 - Initial coupling data was exchanged.
"""
function initializeData()
    ccall((:precicec_initialize_data, libprecicePath), Cvoid, ())
end


@doc """
    
    advance(computedTimestepLength::Float64)::Float64

Advances preCICE after the solver has computed one timestep.

# Arguments
 - `computed_timestep_length::Float64`: Length of timestep used by the solver.

Return the maximum length of next timestep to be computed by solver.

# Notes

Previous calls:
 - [`initialize`](@ref) has been called successfully.
 - The solver has computed one timestep.
 - The solver has written all coupling data.
 - [`finalize`](@ref) has not yet been called.

Tasks completed:
 - Coupling data values specified in the configuration are exchanged.
 - Coupling scheme state (computed time, computed timesteps, ...) is updated.
 - The coupling state is logged.
 - Configured data mapping schemes are applied.
 - [Second Participant] Configured post processing schemes are applied.
 - Meshes with data are exported to files if configured.
"""
function advance(computedTimestepLength::Float64)::Float64
    dt::Float64 = ccall((:precicec_advance, libprecicePath), Cdouble, (Cdouble,), computedTimestepLength)
    return dt
end


@doc """

    finalize()

Finalize the coupling to the coupling supervisor.

# Notes

Previous calls:
 - [`initialize`](@ref) has been called successfully.

Tasks completed:
 - Communication channels are closed.
 - Meshes and data are deallocated.
"""
function finalize()
    ccall((:precicec_finalize, libprecicePath), Cvoid, ())
end


@doc """

    getDimensions()::Integer

Return the number of spatial dimensions configured. Currently, two and three dimensional problems
can be solved using preCICE. The dimension is specified in the XML configuration.
"""
function getDimensions()::Integer
    dim::Integer = ccall((:precicec_getDimensions, libprecicePath), Cint, ())
    return dim
end


@doc """

    isCouplingOngoing()::Bool

Check if the coupled simulation is still ongoing.
A coupling is ongoing as long as
 - the maximum number of timesteps has not been reached, and
 - the final time has not been reached.

The user should call [`finalize`](@ref) after this function returns false.

# Notes

Previous calls:
 - [`initialize`](@ref) has been called successfully.
"""
function isCouplingOngoing()::Bool
    ans::Integer = ccall((:precicec_isCouplingOngoing, libprecicePath), Cint, ())
    return ans
end



@doc """

    isTimeWindowComplete()::Bool

Check if the current coupling timewindow is completed.

The following reasons require several solver time steps per coupling time step:
- A solver chooses to perform subcycling.
- An implicit coupling timestep iteration is not yet converged.

# Notes

Previous calls:
 - [`initialize`](@ref) has been called successfully.

"""
function isTimeWindowComplete()::Bool
    ans::Integer = ccall((:precicec_isTimeWindowComplete, libprecicePath), Cint, ())
    return ans
end


@doc """

    hasToEvaluateSurrogateModel()::Bool

Return whether the solver has to evaluate the surrogate model representation.
The solver may still have to evaluate the fine model representation.

DEPRECATED: Only necessary for deprecated manifold mapping.
"""
function hasToEvaluateSurrogateModel()::Bool
    ans::Integer = ccall((:precicec_hasToEvaluateSurrogateModel, libprecicePath), Cint, ())
    return ans
end


@doc """

    hasToEvaluateFineModel()::Bool

Check if the solver has to evaluate the fine model representation.
The solver may still have to evaluate the surrogate model representation.
DEPRECATED: Only necessary for deprecated manifold mapping.

Return whether the solver has to evaluate the fine model representation.
"""
function hasToEvaluateFineModel()::Bool
    ans::Integer = ccall((:precicec_hasToEvaluateFineModel, libprecicePath), Cint, ())
    return ans
end


@doc """

    isReadDataAvailable()::Bool

Check if new data to be read is available. Data is classified to be new, if it has been received
while calling [`initialize`](@ref) and before calling [`advance`](@ref), or in the last call of [`advance`](@ref).
This is always true, if a participant does not make use of subcycling, i.e. choosing smaller
timesteps than the limits returned in [`intitialize`](@ref) and [`advance`](@ref).
It is allowed to read data even if this function returns false. This is not recommended
due to performance reasons. Use this function to prevent unnecessary reads.

#Notes

Previous calls:
 - [`initialize`](@ref) has been called successfully.
"""
function isReadDataAvailable()::Bool
    ans::Integer = ccall((:precicec_isReadDataAvailable, libprecicePath), Cint, ())
    return ans
end



@doc """

    isWriteDataRequired(computedTimestepLength::Float64)::Bool

Check if new data has to be written before calling [`advance`](@ref).
This is always true, if a participant does not make use of subcycling, i.e. choosing smaller
timesteps than the limits returned in [`intitialize`](@ref) and [`advance`](@ref).
It is allowed to write data even if this function returns false. This is not recommended
due to performance reasons. Use this function to prevent unnecessary writes.

# Arguments

 - `computed_timestep_length::double`: Length of timestep used by the solver.

Return whether new data has to be written.

# Notes

Previous calls:
 - [`initialize`](@ref) has been called successfully.
"""
function isWriteDataRequired(computedTimestepLength::Float64)::Bool
    ans::Integer = ccall((:precicec_isWriteDataRequired, libprecicePath), Cint, (Cdouble,), computedTimestepLength)
    return ans
end


@doc """

    isActionRequired(action::String)::Bool

Checks if the provided action is required.
    
Some features of preCICE require a solver to perform specific actions, in order to be
in valid state for a coupled simulation. A solver is made eligible to use those features,
by querying for the required actions, performing them on demand, and calling [`markActionfulfilled`](@ref)
to signalize preCICE the correct behavior of the solver.

# Arguments
 - `action:: PreCICE action`: Name of the action

"""
function isActionRequired(action::String)::Bool
    ans::Integer = ccall((:precicec_isActionRequired, libprecicePath), Cint, (Ptr{Int8},), action)
    return ans
end


@doc """

    markActionFulfilled(action::String)

Indicate preCICE that a required action has been fulfilled by a solver. 

# Arguments
 - `action::String`: Name of the action.

# Notes

Previous calls:
 - The solver fulfilled the specified action.
"""
function markActionFulfilled(action::String)
    ccall((:precicec_markActionFulfilled, libprecicePath), Cvoid, (Ptr{Int8},), action)
end


@doc """

    hasMesh(meshName::String)::Bool

Check if the mesh with given name is used by a solver. 
"""
function hasMesh(meshName::String)::Bool
    ans::Integer = ccall((:precicec_hasMesh, libprecicePath), Cint, (Ptr{Int8},), meshName)
    return ans
end


@doc """

    getMeshID(meshName::String)::Integer

Return the ID belonging to the given mesh name.

# Examples

```julia
meshid = getMeshID("MeshOne")
```
"""
function getMeshID(meshName::String)
    ans::Integer = ccall((:precicec_getMeshID, libprecicePath), Cint, (Ptr{Int8},), meshName)
    return ans
end


@doc """

    hasData(dataName::String, meshID::Integer)::Bool

Check if the data with given name is used by a solver and mesh.
Return true if the mesh is already used.

# Arguments
 - `dataName::String`: Name of the data.
 - `meshID::Integer`: ID of the associated mesh.

"""
function hasData(dataName::String, meshID::Integer)::Bool
    ans::Integer = ccall((:precicec_hasData, libprecicePath), Cint, (Ptr{Int8}, Cint), dataName, meshID)
    return ans
end


@doc """

    getDataID(dataName::String, meshID::Integer)::Integer

# Arguments
- `dataName::String`: Name of the data.
- `meshID::Integer`: ID of the associated mesh.

Return the data id belonging to the given name.

The given name (`dataName`) has to be one of the names specified in the configuration file. The data ID obtained can be used to read and write data to and from the coupling mesh.
"""
function getDataID(dataName::String, meshID::Integer)
    id::Integer = ccall((:precicec_getDataID, libprecicePath), Cint, (Ptr{Int8}, Cint), dataName, meshID)
    return id
end


@doc """

    setMeshVertex(meshID::Integer, position::AbstractArray{Float64})

Create a mesh vertex on a coupling mesh and return its id.

# Arguments
- `meshID::Integer`: The id of the mesh to add the vertex to. 
- `position::AbstractArray{Float64}`: An array with the coordinates of the vertex. Depending on the dimension, either [x1, x2] or [x1,x2,x3].

# See also

[`getDimensions`](@ref), [`setMeshVertices`](@ref)

# Notes

Previous calls:
 - Count of available elements at position matches the configured dimension.

# Examples
```julia
v1_id = setMeshVertex(mesh_id, [1,1,1])
```
"""
function setMeshVertex(meshID::Integer, position::AbstractArray{Float64})
    id::Integer = ccall((:precicec_setMeshVertex, libprecicePath), Cint, (Cint, Ref{Float64}), meshID, position)
    return id
end


@doc """

    getMeshVertices(meshID::Integer, ids::AbstractArray{Cint})::AbstractArray{Float64}

Return vertex positions for multiple vertex ids from a given mesh.

The 2D-format for positions is (d0x, d0y, d1x, d1y, ..., dnx, dny),
the 3D-format for positions is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz).


# Arguments
- `meshID::Integer`:  The id of the mesh to read the vertices from.
- `ids::AbstractArray{Cint}`:  The ids of the vertices to get the positions from.

# Examples

Return data structure for a 2D problem with 5 vertices:
```julia-repl
julia> meshID = getMeshID("MeshOne")
julia> vertexIDs = [1,2,3,4,5]
julia> positions = getMeshVertices(meshID, vertexIDs)
julia> size(positions)
(10,)
```
Return data structure for a 3D problem with 5 vertices:

```julia-repl
julia> mesh_id = getMeshID("MeshOne")
julia> vertex_ids = [1, 2, 3, 4, 5]
julia> positions = getMeshVertices(mesh_id, vertex_ids)
julia> size(positions)
(15,)
```
"""
function getMeshVertices(meshID::Integer, ids::AbstractArray{Cint})
    _size = length(ids)
    positions = Array{Float64,1}(undef,_size*getDimensions())
    ccall((:precicec_getMeshVertices, libprecicePath), Cvoid, (Cint, Cint, Ref{Cint}, Ref{Cdouble}), meshID, _size, ids, positions)
    return positions
end


@doc """

    setMeshVertices(meshID::Integer, positions::AbstractArray{Float64})

Create multiple mesh vertices on a coupling mesh and return an array holding their ids.


# Arguments
- `meshID::Integer`: The id of the mesh to add the vertices to. 
- `positions::AbstractArray{Float64}`: An array holding the coordinates of the vertices.
                                    The 2D-format is (d0x, d0y, d1x, d1y, ..., dnx, dny), 
                                    the 3D-format is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz).
                 
# Notes
Previous calls:
 - [`initialize`](@ref) has not yet been called
 - count of available elements at positions matches the configured `dimension` * `size`
 - count of available elements at ids matches size


# See also
[`getDimensions`](@ref), [`setMeshVertex`](@ref)

# Examples
```julia
vertices = [1,1,1,2,2,2,3,3,3]
vertex_ids = setMeshVertices(mesh_id, vertices)
```
"""
function setMeshVertices(meshID::Integer, positions::AbstractArray{Float64})
    _size =Cint(length(positions)/PreCICE.getDimensions())
    vertexIDs = Array{Int32, 1}(undef, _size)
    ccall((:precicec_setMeshVertices, libprecicePath), Cvoid, (Cint, Cint, Ref{Cdouble}, Ref{Cint}), meshID, _size, positions, vertexIDs)
    return vertexIDs 
end


@doc """

    getMeshVertexSize(meshID::Integer)::Integer

Return the number of vertices of a mesh.

"""
function getMeshVertexSize(meshID::Integer)::Integer
    _size ::Integer = ccall((:precicec_getMeshVertex_size, libprecicePath), Cint, (Cint,), meshID)
    return _size
end


# TODO Example has the wrong arguments
@doc """

    getMeshVertexIDsFromPositions(meshID::Integer, positions::AbstractArray{Float64})::AbstractArray{Int}

Return mesh vertex IDs from positions.

Prefer to reuse the IDs returned from calls to [`setMeshVertex`](@ref) and [`setMeshVertices`](@ref).

# Arguments
- `meshID::Integer`: ID of the mesh to retrieve positions from.
- `positions::AbstractArray{Float64}`: Positions to find ids for.
                                       The 2D-format is (d0x, d0y, d1x, d1y, ..., dnx, dny),
                                       the 3D-format is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz).

# Examples

Get mesh vertex ids from positions for a 2D (D=2) problem with 5 (N=5) mesh vertices.
```julia
meshID = getMeshID("MeshOne")
positions = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
vertex_ids = getMeshVertexIDsFromPositions(meshID, positions)
```
"""
function getMeshVertexIDsFromPositions(meshID::Integer, positions::AbstractArray{Float64})
    _size = Cint(length(positions)/getDimensions())
    ids = Array{Cint,1}(undef,_size)
    ccall((:precicec_getMeshVertexIDsFromPositions, libprecicePath), Cvoid, (Cint, Cint, Ref{Cdouble}, Ref{Cint}), meshID, _size, positions, ids)
    return ids
end


@doc """

    setMeshEdge(meshID::Integer, firstVertexID::Integer, secondVertexID::Integer)::Integer

Set mesh edge from vertex IDs, return edge ID.

# Arguments
- `meshID::Integer`: ID of the mesh to add the edge to.
- `firstVertexID::Integer`: ID of the first vertex of the edge.
- `secondVertexID::Integer`: ID of the second vertex of the edge.

# Notes

Previous calls:
 - Vertices with `firstVertexID` and `secondVertexID` were added to the mesh with the ID `meshID`

"""
function setMeshEdge(meshID::Integer, firstVertexID::Integer, secondVertexID::Integer)::Integer
    edgeID::Integer = ccall((:precicec_setMeshEdge, libprecicePath), Cint, (Cint, Cint, Cint), meshID, firstVertexID, secondVertexID)
    return edgeID
end


@doc """

    setMeshTriangle(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer)

Set mesh triangle from edge IDs.

# Arguments
- `meshID::Integer`: ID of the mesh to add the edge to.
- `firstVertexID::Integer`: ID of the first vertex of the edge.
- `secondVertexID::Integer`: ID of the second vertex of the edge.
- `thirdEdgeID::Integer`: ID of the third edge of the triangle.

# Notes

Previous calls:
 - Edges with `first_edge_id`, `second_edge_id`, and `third_edge_id` were added to the mesh with the ID `meshID`
"""
function setMeshTriangle(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer)
    ccall((:precicec_setMeshTriangle, libprecicePath), Cvoid, (Cint, Cint, Cint, Cint), meshID, firstEdgeID, secondEdgeID, thirdEdgeID)
end


@doc """

    setMeshTriangleWithEdges(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer)

Set a triangle from vertex IDs. Create missing edges.

WARNING: This routine is supposed to be used, when no edge information is available per se.
        Edges are created on the fly within preCICE. This routine is significantly slower than the one
        using edge IDs, since it needs to check, whether an edge is created already or not.

# Arguments
- `meshID::Integer`: ID of the mesh to add the edge to.
- `firstVertexID::Integer`: ID of the first vertex of the edge.
- `secondVertexID::Integer`: ID of the second vertex of the edge.
- `thirdEdgeID::Integer`: ID of the third edge of the triangle.

# Notes

Previous calls:
 - Edges with `firstVertexID`, `secondVertexID`, and `thirdEdgeID` were added to the mesh with the ID `meshID`
"""
function setMeshTriangleWithEdges(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer)
    ccall((:precicec_setMeshTriangleWithEdges, libprecicePath), Cvoid, (Cint, Cint, Cint, Cint), meshID, firstEdgeID, secondEdgeID, thirdEdgeID)
end


@doc """

    setMeshQuad(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID, fourthEdgeID::Integer)

Set mesh Quad from edge IDs.

WARNING: Quads are not fully implemented yet.

# Arguments
- `meshID::Integer`: ID of the mesh to add the Quad to.
- `firstVertexID::Integer`: ID of the first edge of the Quad.
- `secondVertexID::Integer`: ID of the second edge of the Quad.
- `thirdEdgeID::Integer`: ID of the third edge of the Quad.
- `fourthEdgeID::Integer`: ID of the fourth edge of the Quad.

# Notes

Previous calls:
 - Edges with `first_edge_id`, `second_edge_id`, `third_edge_id`, and `fourth_edge_id` were added
    to the mesh with the ID `mesh_id`
"""
function setMeshQuad(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID, fourthEdgeID::Integer)
    ccall((:precicec_setMeshQuad, libprecicePath), Cvoid, (Cint, Cint, Cint, Cint, Cint), meshID, firstEdgeID, secondEdgeID, thirdEdgeID, fourthEdgeID)
end


@doc """

    setMeshQuadWithEdges(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer)

Set surface mesh quadrangle from vertex IDs.

WARNING: This routine is supposed to be used, when no edge information is available per se. Edges are
created on the fly within preCICE. This routine is significantly slower than the one using
edge IDs, since it needs to check, whether an edge is created already or not.

# Arguments
- `meshID::Integer`: ID of the mesh to add the Quad to.
- `firstVertexID::Integer`: ID of the first edge of the Quad.
- `secondVertexID::Integer`: ID of the second edge of the Quad.
- `thirdEdgeID::Integer`: ID of the third edge of the Quad.
- `fourthEdgeID::Integer`: ID of the fourth edge of the Quad.

# Notes

Previous calls:
 - Edges with `firstVertexID`, `secondEdgeID`, `thirdVertexID`, and `fourthEdgeID` were added
    to the mesh with the ID `mesh_id`
"""
function setMeshQuadWithEdges(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer)
    ccall((:precicec_setMeshQuadWithEdges, libprecicePath), Cvoid, (Cint, Cint, Cint, Cint, Cint), meshID, firstEdgeID, secondEdgeID, thirdEdgeID, fourthEdgeID)
end


# TODO is the form of the vector correct? or can this be passed as a matrix instead of a vector?
@doc """

    writeBlockVectorData(dataID::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})

Write vector data values given as block. This function writes values of specified vertices to a `dataID`.
Values are provided as a block of continuous memory. Values are stored in a Matrix [N x D] where N = number
of vertices and D = dimensions of geometry 

The block must contain the vector values in the following form: 

values = (d0x, d0y, d0z, d1x, d1y, d1z, ...., dnx, dny, dnz), where n is the number of vector values. In 2D, the z-components are removed.

# Arguments
- `dataID::Integer`: ID of the data to be written.
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices. 
- `values::AbstractArray{Float64}`: Values of the data to be written.

# Notes

Previous calls:
 - [`initialize`](@ref) has been called

# Examples

Write block vector data for a 2D problem with 5 vertices:
```julia
data_id = 1
vertex_ids = [1, 2, 3, 4, 5]
values = [v1_x, v1_y; v2_x, v2_y; v3_x, v3_y; v4_x, v4_y; v5_x, v5_y])
writeBlockVectorData(data_id, vertex_ids, values)
```
Write block vector data for a 3D (D=3) problem with 5 (N=5) vertices:
```julia
data_id = 1
vertex_ids = [1, 2, 3, 4, 5]
values = [v1_x, v1_y, v1_z; v2_x, v2_y, v2_z; v3_x, v3_y, v3_z; v4_x, v4_y, v4_z; v5_x, v5_y, v5_z]
writeBlockVectorData(data_id, vertex_ids, values)
```
"""
function writeBlockVectorData(dataID::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})
    _size =length(valueIndices)
    ccall((:precicec_writeBlockVectorData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cint}, Ref{Cdouble}), dataID, _size, valueIndices, values)
end


# TODO Are they provided as a block of continuous memory?
@doc """

    writeVectorData(dataID::Integer, valueIndex::Integer, dataValue::AbstractArray{Float64})

Write vectorial floating-point data to a vertex. This function writes a value of a specified vertex to a dataID.
Values are provided as a block of continuous memory.

The 2D-format of value is a array of shape 2

The 3D-format of value is a array of shape 3

# Arguments
- `dataID::Integer`: ID of the data to be written. Obtained by [`getDataID`](@ref).
- `valueIndex::Integer`: Index of the vertex. 
- `dataValue::AbstractArray{Float64}`: The array holding the values.

# Notes
        
Previous calls:
 - Count of available elements at `value` matches the configured dimension
 - [`initialize`](@ref) has been called

# Examples:

Write vector data for a 2D problem with 5 vertices:
```julia
data_id = 1
vertex_id = 5
value = [v5_x, v5_y]
writeVectorData(data_id, vertex_id, value)
```

Write vector data for a 3D (D=3) problem with 5 (N=5) vertices:
```julia
data_id = 1
vertex_id = 5
value = [v5_x, v5_y, v5_z]
writeVectorData(data_id, vertex_id, value)
```
"""
function writeVectorData(dataID::Integer, valueIndex::Integer, dataValue::AbstractArray{Float64})
    ccall((:precicec_writeVectorData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cdouble}), dataID, valueIndex, dataValue)
end

# TODO same as above
@doc """

    writeBlockScalarData(dataID::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})

Write scalar data given as block.

This function writes values of specified vertices to a dataID. Values are provided as a block of continuous memory. `valueIndices` contains the indices of the vertices.

# Arguments
- `dataID::Integer`: ID of the data to be written. Obtained by getDataID().
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices.
- `values::AbstractArray{Float64}`: The array holding the values.
    
# Notes

Previous calls:
 - [`initialize`](@ref) has been called

# Examples

Write block scalar data for a 2D and 3D problem with 5 (N=5) vertices:
```julia
data_id = 1
vertex_ids = [1, 2, 3, 4, 5]
values = [1, 2, 3, 4, 5]
writeBlockScalarData(data_id, vertex_ids, values)
```
"""
function writeBlockScalarData(dataID::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})
    _size =length(valueIndices)
    ccall((:precicec_writeBlockScalarData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cint}, Ref{Cdouble}), dataID, _size, valueIndices, values)
end

@doc """

    writeScalarData(dataID::Integer, valueIndex::Integer, dataValue::Float64)

Write scalar data, the value of a specified vertex to a dataID.

# Arguments
- `dataID::Integer`: ID of the data to be written. Obtained by [`getDataID`](@ref).
- `valueIndex::AbstractArray{Cint}`: Indicex of the vertex.
- `value::Float64`: The value to write.

# Notes

Previous calls:
 - [`initialize`](@ref) 

# Examples

Write scalar data for a 2D or 3D problem with 5 vertices:

```julia
data_id = 1
vertex_id = 5
value = 1.0
writeScalarData(data_id, vertex_id, value)
```
"""
function writeScalarData(dataID::Integer, valueIndex::Integer, dataValue::Float64)
    ccall((:precicec_writeScalarData, libprecicePath), Cvoid, (Cint, Cint, Cdouble), dataID, valueIndex, dataValue)
end

@doc """

    readBlockVectorData(dataID::Integer, valueIndices::AbstractArray{Cint})::AbstractArray{Float64}

Read and return vector data values given as block.

The block contains the vector values in the following form:

values = (d0x, d0y, d0z, d1x, d1y, d1z, ...., dnx, dny, dnz), where n is 
the number of vector values. In 2D, the z-components are removed.

# Arguments
- `dataID::Integer`: ID of the data to be read.
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices.

# Notes

Previous calls:
- [`initialize`](@ref) has been called

# Examples

Read block vector data for a 2D problem with 5 vertices:
```julia-repl
julia> data_id = 1
julia> vertex_ids = [1, 2, 3, 4, 5]
julia> values = readBlockVectorData(data_id, vertex_ids)
julia> size(values)
(10,)
```
Read block vector data for a 3D system with 5 vertices:
```julia-repl
julia> data_id = 1
julia> vertex_ids = [1, 2, 3, 4, 5]
julia> values = readBlockVectorData(data_id, vertex_ids)
julia> size(values)
(15,)
```
"""
function readBlockVectorData(dataID::Integer, valueIndices::AbstractArray{Cint})
    _size =length(valueIndices)
    values = Array{Float64,1}(undef,_size*getDimensions())
    ccall((:precicec_readBlockVectorData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cint}, Ref{Cdouble}), dataID, _size, valueIndices, values)
    return values
end

@doc """

    readVectorData(dataID::Integer, valueIndex::Integer, dataValue::AbstractArray{Float64})::AbstractArray{Float64}

Read and return vector data from a vertex.

# Arguments
- `dataID::Integer`: ID of the data to be read.
- `valueIndex::AbstractArray{Cint}`: Indicex of the vertex.

# Notes

Previous calls:
 - count of available elements at value matches the configured dimension
 - [`initialize`](@ref) has been called

# Examples

```julia
data_id = 1
vertex_id = 5
value = readVectorData(data_id, vertex_id)
```
"""
function readVectorData(dataID::Integer, valueIndex::Integer)
    dataValue = Array{Float64,1}(undef,getDimensions())
    ccall((:precicec_readVectorData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cdouble}), dataID, valueIndex, dataValue)
    return dataValue
end


@doc """

    readBlockScalarData(dataID::Integer, valueIndices::AbstractArray{Cint})::AbstractArray{Float64}

Read and return scalar data as a block, values of specified vertices from a dataID.

# Arguments
- `dataID::Integer`: ID of the data to be read.
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices.

# Notes

Previous calls:
- [`initialize`](@ref) has been called

# Examples

Read block scalar data for 2D and 3D problems with 5 vertices:
```julia
data_id = 1
vertex_ids = [1, 2, 3, 4, 5]
values = readBlockScalarData(data_id, vertex_ids)
```
"""
function readBlockScalarData(dataID::Integer, valueIndices::AbstractArray{Cint})
    _size =length(valueIndices)
    values = Array{Float64,1}(undef,size)
    ccall((:precicec_readScalarVectorData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cint}, Ref{Cdouble}), dataID, _size, valueIndices, values)
    return values
end


@doc """

    readScalarData(dataID::Integer, valueIndex::Integer)::Float64

Read and return scalar data of a vertex.

# Arguments
- `dataID::Integer`: ID of the data to be read.
- `valueIndex::AbstractArray{Cint}`: Indicex of the vertex.

# Notes

Previous calls:
- [`initialize`](@ref) has been called.

# Examples

Read scalar data for 2D and 3D problems:
```julia
data_id = 1
vertex_id = 5
value = readScalarData(data_id, vertex_id)
```
"""
function readScalarData(dataID::Integer, valueIndex::Integer)
    dataValue = Float64(0.0)
    ccall((:precicec_readScalarData, libprecicePath), Cvoid, (Cint, Cint, Ref{Cdouble}), dataID, valueIndex, dataValue)
    return dataValue
end


@doc """

    getVersionInformation()

Return a semicolon-separated String containing: 
 - the version of preCICE
 - the revision information of preCICE
 - the configuration of preCICE including MPI, PETSC, PYTHON
"""
function getVersionInformation()
    versionCstring = ccall((:precicec_getVersionInformation, libprecicePath), Cstring, ())
    return unsafe_string(versionCstring)
end


@doc """

    mapReadDataFrom(fromMeshID::Integer)

Compute and map all write data mapped from the mesh with given ID. This is an explicit request
to map write data from the Mesh associated with [`fromMeshID`](@ref). It also computes the mapping if necessary.

# Notes

Previous calls:
 - A mapping to [`fromMeshID`](@ref) was configured
"""
function mapWriteDataFrom(fromMeshID::Integer)
    ccall((:precicec_mapWriteDataFrom, libprecicePath), Cvoid, (Cint,), fromMeshID)
end


@doc """

    mapReadDataTo(fromMeshID::Integer)

Compute and map all read data mapped to the mesh with given ID.
This is an explicit request to map read data to the Mesh associated with [`toMeshID`](@ref).
It also computes the mapping if necessary.

# Notes

Previous calls:
 - A mapping to [`toMeshID`](@ref) was configured.
"""
function mapReadDataTo(fromMeshID::Integer)
    ccall((:precicec_mapReadDataTo, libprecicePath), Cvoid, (Cint,), fromMeshID)
end


@doc """

    actionWriteInitialData()

Return the name of action for writing initial data.

"""
function actionWriteInitialData()
    msgCstring = ccall((:precicec_actionWriteInitialData, libprecicePath), Cstring, ())
    return unsafe_string(msgCstring)
end


@doc """

    actionWriteIterationCheckpoint()

Return name of action for writing iteration checkpoint.
"""
function actionWriteIterationCheckpoint()
    msgCstring = ccall((:precicec_actionWriteIterationCheckpoint, libprecicePath), Cstring, ())
    return unsafe_string(msgCstring)
end


@doc """

    actionReadIterationCheckpoint()

Return name of action for reading iteration checkpoint
"""
function actionReadIterationCheckpoint()
    msgCstring = ccall((:precicec_actionReadIterationCheckpoint, libprecicePath), Cstring, ())
    return unsafe_string(msgCstring)
end


end # module
