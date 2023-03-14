module PreCICE
"""
The `PreCICE` module provides the bindings for using the preCICE api. For more information, visit https://precice.org/.
"""


# TODO add 'return nothing' keyword to void functions
# TODO add Julia's exception handling to the ccalls

# TODO createSolverInterfaceWithCommunicator documentation

export
    # construction and configuration
    createSolverInterface,
    createSolverInterfaceWithCommunicator,

    # steering methods
    initialize,
    advance,
    finalize,

    # status queries
    getDimensions,
    isCouplingOngoing,
    isTimeWindowComplete,

    # action methods
    requiresReadingCheckpoint,
    requiresWritingCheckpoint,
    requiresInitialData,


    # mesh access
    hasMesh,
    setMeshVertex,
    getMeshVertexSize,
    setMeshVertices,
    getMeshVertices,
    setMeshEdge,
    setMeshTriangle,
    setMeshQuad,

    # data access
    hasData,
    writeBlockVectorData,
    writeVectorData,
    writeBlockScalarData,
    writeScalarData,
    readBlockScalarData,
    readVectorData,
    readBlockScalarData,
    readScalarData,

    # constants
    getVersionInformation,

    # Gradient related 
    requiresGradientDataFor,
    writeScalarGradientData,
    writeVectorGradientData,
    writeBlockScalarGradientData,
    writeBlockVectorGradientData


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
function createSolverInterface(
    participantName::String,
    configFilename::String,
    solverProcessIndex::Integer,
    solverProcessSize::Integer,
)
    ccall(
        (:precicec_createSolverInterface, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Cint),
        participantName,
        configFilename,
        solverProcessIndex,
        solverProcessSize,
    )
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
function createSolverInterfaceWithCommunicator(
    participantName::String,
    configFilename::String,
    solverProcessIndex::Integer,
    solverProcessSize::Integer,
    communicator::Union{Ptr{Cvoid},Ref{Cvoid},Ptr{Nothing}},
) # test if type of com is correct
    ccall(
        (:precicec_createSolverInterface_withCommunicator, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Int, Int, Union{Ptr{Cvoid},Ref{Cvoid},Ptr{Nothing}}),
        participantName,
        configFilename,
        solverProcessIndex,
        solverProcessSize,
        communicator,
    )
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
    dt::Float64 = ccall((:precicec_initialize, "libprecice"), Cdouble, ())
    return dt
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
    dt::Float64 = ccall(
        (:precicec_advance, "libprecice"),
        Cdouble,
        (Cdouble,),
        computedTimestepLength,
    )
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
    ccall((:precicec_finalize, "libprecice"), Cvoid, ())
end


@doc """

    getDimensions()::Integer

Return the number of spatial dimensions configured. Currently, two and three dimensional problems
can be solved using preCICE. The dimension is specified in the XML configuration.
"""
function getDimensions()::Integer
    dim::Integer = ccall((:precicec_getDimensions, "libprecice"), Cint, ())
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
    ans::Integer = ccall((:precicec_isCouplingOngoing, "libprecice"), Cint, ())
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
    ans::Integer = ccall((:precicec_isTimeWindowComplete, "libprecice"), Cint, ())
    return ans
end


@doc """

    requiresInitialData()::Bool

Check if the solver has to provide initial data.
"""
function requiresInitialData()::Bool
    ans::Integer = ccall((:precicec_requiresInitialData, "libprecice"), Cint, ())
    return ans
end


@doc """ 

    requiresReadingCheckpoint()::Bool

Check if the solver has to read a checkpoint.
"""
function requiresReadingCheckpoint()::Bool
    ans::Integer = ccall((:precicec_requiresReadingCheckpoint, "libprecice"), Cint, ())
    return ans
end

@doc """

    requiresWritingCheckpoint()::Bool

Check if the solver has to write a checkpoint.
"""
function requiresWritingCheckpoint()::Bool
    ans::Integer = ccall((:precicec_requiresWritingCheckpoint, "libprecice"), Cint, ())
    return ans
end


@doc """

    hasMesh(meshName::String)::Bool

Check if the mesh with given name is used by a solver. 
"""
function hasMesh(meshName::String)::Bool
    ans::Integer = ccall((:precicec_hasMesh, "libprecice"), Cint, (Ptr{Int8},), meshName)
    return ans
end


@doc """

    hasData(dataName::String, meshName::String)::Bool

Check if the data with given name is used by a solver and mesh.
Return true if the mesh is already used.

# Arguments
 - `dataName::String`: Name of the data.
 - `meshName::String`: Name of the associated mesh.

"""
function hasData(dataName::String, meshName::String)::Bool
    ans::Integer =
        ccall((:precicec_hasData, "libprecice"), Cint, (Ptr{Int8}, Ptr{Int8}), dataName, meshName)
    return ans
end


@doc """

    setMeshVertex(meshName::String, position::AbstractArray{Float64})

Create a mesh vertex on a coupling mesh and return its id.

# Arguments
- `meshName::String`: The name of the mesh to add the vertex to. 
- `position::AbstractArray{Float64}`: An array with the coordinates of the vertex. Depending on the dimension, either [x1, x2] or [x1,x2,x3].

# See also

[`getDimensions`](@ref), [`setMeshVertices`](@ref)

# Notes

Previous calls:
 - Count of available elements at position matches the configured dimension.

# Examples
```julia
v1_id = setMeshVertex(mesh_name, [1,1,1])
```
"""
function setMeshVertex(meshName::String, position::AbstractArray{Float64})
    id::Integer = ccall(
        (:precicec_setMeshVertex, "libprecice"),
        Cint,
        (Ptr{Int8}, Ref{Float64}),
        meshName,
        position,
    )
    return id
end

@doc """

    getMeshVertices(meshName::String, ids::AbstractArray{Cint})::AbstractArray{Float64}

Return vertex positions for multiple vertex ids from a given mesh.

The shape for positions is [N x D] where N = number of vertices and D = dimensions of geometry

# Arguments
- `meshName::String`:  The name of the mesh to read the vertices from.
- `ids::AbstractArray{Cint}`:  The ids of the vertices to get the positions from.

# Examples

Return data structure for a 2D problem with 5 vertices:
```julia-repl
julia> vertexIDs = [1,2,3,4,5]
julia> positions = getMeshVertices("MeshOne", vertexIDs)
julia> size(positions)
(2,5)
```
Return data structure for a 3D problem with 5 vertices:

```julia-repl
julia> vertex_ids = [1, 2, 3, 4, 5]
julia> positions = getMeshVertices("MeshOne", vertex_ids)
julia> size(positions)
(5,3)
```
"""
function getMeshVertices(meshName::String, ids::AbstractArray{Cint})
    _size = length(ids)
    positions = Array{Float64,1}(undef, _size * getDimensions())
    ccall(
        (:precicec_getMeshVertices, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Cint, Ref{Cint}, Ref{Cdouble}),
        meshName,
        _size,
        ids,
        positions,
    )
    return permutedims(reshape(positions, (getDimensions(), _size)))
end


@doc """

    setMeshVertices(meshName::String, positions::AbstractArray{Float64})

Create multiple mesh vertices on a coupling mesh and return an array holding their ids.


# Arguments
- `meshName::String`: The name of the mesh to add the vertices to. 
- `positions::AbstractArray{Float64}`: An array holding the coordinates of the vertices.
                                       It has the shape [N x D] where N = number of vertices and D = dimensions of geometry
                 
# Notes
Previous calls:
 - [`initialize`](@ref) has not yet been called


# See also
[`getDimensions`](@ref), [`setMeshVertex`](@ref)

# Examples
Example for a 3D Problem with 5 vertices
```julia
vertices = [1 1 1;2 2 2;3 3 3]
vertex_ids = setMeshVertices("MeshOne", vertices)
```
"""
function setMeshVertices(meshName::String, positions::AbstractArray{Float64})
    _size, dimensions = size(positions)
    @assert dimensions == getDimensions() "Dimensions of vector data in write_vector_data does not match with dimensions in problem definition. Provided dimensions: $dimensions, expected dimensions: $(getDimensions())"

    positions = permutedims(positions) # transpose

    vertexIDs = Array{Int32,1}(undef, _size)
    ccall(
        (:precicec_setMeshVertices, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Cint, Ref{Cdouble}, Ref{Cint}),
        meshName,
        _size,
        reshape(positions, :),
        vertexIDs,
    )
    return vertexIDs
end


@doc """

    getMeshVertexSize(meshName::String)::Integer

Return the number of vertices of a mesh.

"""
function getMeshVertexSize(meshName::String)::Integer
    _size::Integer =
        ccall((:precicec_getMeshVertexSize, "libprecice"), Cint, (Ptr{Int8},), meshName)
    return _size
end


@doc """

    setMeshEdge(meshName::String, firstVertexID::Integer, secondVertexID::Integer)

Set mesh edge from vertex IDs, return edge ID.

# Arguments
- `meshName::String`: Name of the mesh to add the edge to.
- `firstVertexID::Integer`: ID of the first vertex of the edge.
- `secondVertexID::Integer`: ID of the second vertex of the edge.

# Notes

Previous calls:
 - Vertices with `firstVertexID` and `secondVertexID` were added to the mesh with `meshName`.

"""
function setMeshEdge(meshName::String, firstVertexID::Integer, secondVertexID::Integer)
    ccall(
        (:precicec_setMeshEdge, "libprecice"),
        Cint,
        (Ptr{Int8}, Cint, Cint),
        meshName,
        firstVertexID,
        secondVertexID,
    )
end


@doc """

    setMeshTriangle(meshName::String, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer)

Set mesh triangle from vertex IDs.

# Arguments
- `meshName::String`: Name of the mesh to add the edge to.
- `firstVertexID::Integer`: ID of the first vertex of the edge.
- `secondVertexID::Integer`: ID of the second vertex of the edge.
- `thirdVertexID::Integer`: ID of the third edge of the triangle.

# Notes

Previous calls:
 - Edges with `first_edge_id`, `second_edge_id`, and `third_edge_id` were added to the mesh with the name `meshName`
"""
function setMeshTriangle(
    meshName::String,
    firstVertexID::Integer,
    secondVertexID::Integer,
    thirdVertexID::Integer,
)
    ccall(
        (:precicec_setMeshTriangle, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Cint, Cint, Cint),
        meshName,
        firstVertexID,
        secondVertexID,
        thirdVertexID,
    )
end


@doc """

    setMeshTriangles(meshName::String, vertices::AbstractArray{Integer})

Set mesh triangle from vertex IDs.

# Arguments
- `meshName::String`: Name of the mesh to add the edge to.
- `vertices::AbstractArray{Integer}`: IDs of the vertices of the triangles.

"""
function setMeshTriangles(meshName::String, vertices::AbstractArray{Integer})
    ccall(
        (:precicec_setMeshTriangles, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Cint, Ref{Cint}),
        meshName,
        length(vertices),
        vertices,
    )
end


@doc """

    setMeshQuad(meshName::String, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID, fourthEdgeID::Integer)

Set mesh Quad from edge IDs.

WARNING: Quads are not fully implemented yet.

# Arguments
- `meshName::String`: Name of the mesh to add the Quad to.
- `firstVertexID::Integer`: ID of the first edge of the Quad.
- `secondVertexID::Integer`: ID of the second edge of the Quad.
- `thirdEdgeID::Integer`: ID of the third edge of the Quad.
- `fourthEdgeID::Integer`: ID of the fourth edge of the Quad.

# Notes

Previous calls:
 - Edges with `first_edge_id`, `second_edge_id`, `third_edge_id`, and `fourth_edge_id` were added
    to the mesh with the ID `mesh_id`
"""
function setMeshQuad(
    meshName::String,
    firstEdgeID::Integer,
    secondEdgeID::Integer,
    thirdEdgeID,
    fourthEdgeID::Integer,
)
    ccall(
        (:precicec_setMeshQuad, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Cint, Cint, Cint, Cint),
        meshName,
        firstEdgeID,
        secondEdgeID,
        thirdEdgeID,
        fourthEdgeID,
    )
end

@doc """

    setMeshQuads(meshName::String, vertices::AbstractArray{Integer})

Set mesh Quad from vertex IDs.

# Arguments
- `meshName::String`: Name of the mesh to add the Quad to.
- `vertices::AbstractArray{Integer}`: IDs of the edges of the Quads.

"""
function setMeshQuad(meshName::String, vertices::AbstractArray{Integer})
    ccall(
        (:precicec_setMeshQuads, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Cint, Ref{Cint}),
        meshName,
        length(vertices),
        vertices,
    )

end


@doc """

    writeBlockVectorData(meshName::String, dataName::String, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})

Write vector data values given as block. This function writes values of specified vertices to a `dataName`.
Values must be provided in a Matrix with shape [N x D] where N = number of vertices and D = dimensions of geometry 

# Arguments
- `meshName::String`: Name of the mesh to write the data to.
- `dataName::String`: Name of the data to be written.
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices. 
- `values::AbstractArray{Float64}`: Values of the data to be written.

# Notes

Previous calls:
 - [`initialize`](@ref) has been called

# Examples

Write block vector data for a 2D problem with 5 vertices:
```julia
vertex_ids = [1, 2, 3, 4, 5]
values = [v1_x v1_y; v2_x v2_y; v3_x v3_y; v4_x v4_y; v5_x v5_y])
writeBlockVectorData("MeshOne", "DataOne", vertex_ids, values)
```
Write block vector data for a 3D (D=3) problem with 5 (N=5) vertices:
```julia
vertex_ids = [1, 2, 3, 4, 5]
values = [v1_x v1_y v1_z; v2_x v2_y v2_z; v3_x v3_y v3_z; v4_x v4_y v4_z; v5_x v5_y v5_z]
writeBlockVectorData("MeshOne", "DataOne", vertex_ids, values)
```
"""
function writeBlockVectorData(
    meshName::String,
    dataName::String,
    valueIndices::AbstractArray{Cint},
    values::AbstractArray{Float64},
)
    _size, dimensions = size(values)
    @assert dimensions == getDimensions() "Dimensions of vector data in write_vector_data does not match with dimensions in problem definition. Provided dimensions: $dimensions, expected dimensions: $(getDimensions())"

    values = permutedims(values)

    ccall(
        (:precicec_writeBlockVectorData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cint}, Ref{Cdouble}),
        meshName,
        dataName,
        _size,
        valueIndices,
        reshape(values, :),
    )
end


@doc """

    writeVectorData(meshName::String, dataName::String, valueIndex::Integer, dataValue::AbstractArray{Float64})

Write vectorial floating-point data to a vertex. This function writes a value of a specified vertex to a dataName.
Values are provided as a block of continuous memory in the shape of (D,) with D = dimensions of geometry

# Arguments
- `meshName::String`: Name of the mesh to write the data to.
- `dataName::String`: Name of the data to be written.
- `valueIndex::Integer`: Index of the vertex. 
- `dataValue::AbstractArray{Float64}`: The array holding the values.

# Notes
        
Previous calls:
 - Count of available elements at `value` matches the configured dimension
 - [`initialize`](@ref) has been called

# Examples:

Write vector data for a 2D problem with 5 vertices:
```julia
vertex_id = 5
value = [v5_x, v5_y]
writeVectorData("MeshOne", "DataOne", vertex_id, value)
```

Write vector data for a 3D (D=3) problem with 5 (N=5) vertices:
```julia
vertex_id = 5
value = [v5_x, v5_y, v5_z]
writeVectorData("MeshOne", "DataOne", vertex_id, value)
```
"""
function writeVectorData(
    meshName::String,
    dataName::String,
    valueIndex::Integer,
    dataValue::AbstractArray{Float64},
)
    ccall(
        (:precicec_writeVectorData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cdouble}),
        meshName,
        dataName,
        valueIndex,
        dataValue,
    )
end


@doc """

    writeBlockScalarData(meshName::String, DataName::String, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})

Write scalar data given as block.

This function writes values of specified vertices to a dataName. Values are provided as a block of continuous memory. `valueIndices` contains the indices of the vertices.

# Arguments
- `meshName::String`: Name of the mesh to write the data to.
- `dataName::String`: Name of the data to be written.
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices.
- `values::AbstractArray{Float64}`: The array holding the values.

# Notes

Previous calls:
 - [`initialize`](@ref) has been called

# Examples

Write block scalar data for a 2D and 3D problem with 5 (N=5) vertices:
```julia
vertex_ids = [1, 2, 3, 4, 5]
values = [1, 2, 3, 4, 5]
writeBlockScalarData("MeshOne", "DataOne", vertex_ids, values)
```
"""
function writeBlockScalarData(
    meshName::String,
    dataName::String,
    valueIndices::AbstractArray{Cint},
    values::AbstractArray{Float64},
)
    _size = length(valueIndices)
    ccall(
        (:precicec_writeBlockScalarData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cint}, Ref{Cdouble}),
        meshName,
        dataName,
        _size,
        valueIndices,
        values,
    )
end


@doc """

    writeScalarData(meshName::String, dataName::String, valueIndex::Integer, dataValue::Float64)

Write scalar data, the value of a specified vertex to a dataName.

# Arguments
- `meshName::String`: Name of the mesh to write the data to.
- `dataName::String`: Name of the data to be written.
- `valueIndex::AbstractArray{Cint}`: Indicex of the vertex.
- `value::Float64`: The value to write.

# Notes

Previous calls:
 - [`initialize`](@ref) 

# Examples

Write scalar data for a 2D or 3D problem with 5 vertices:

```julia
vertex_id = 5
value = 1.0
writeScalarData("MeshOne", "DataOne", vertex_id, value)
```
"""
function writeScalarData(meshName::String, dataName::String, valueIndex::Integer, dataValue::Float64)
    ccall(
        (:precicec_writeScalarData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Cdouble),
        meshName,
        dataName,
        valueIndex,
        dataValue,
    )
end


@doc """

    readBlockVectorData(meshName::String, dataName::String, valueIndices::AbstractArray{Cint})::AbstractArray{Float64}

Read and return vector data values given as block.

The block contains the vector values in the following form:

`size(values) = (N, D)`, N = number of vertices and D = dimensions of geometry

# Arguments
- `meshName::String`: Name of the mesh to read the data from.
- `dataName::String`: Name of the data to be read.
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices.

# Notes

Previous calls:
- [`initialize`](@ref) has been called

# Examples

Read block vector data for a 2D problem with 5 vertices:
```julia-repl
julia> vertex_ids = [1, 2, 3, 4, 5]
julia> values = readBlockVectorData(meshName, dataName, vertex_ids)
julia> size(values)
(10,)
```
Read block vector data for a 3D system with 5 vertices:
```julia-repl
julia> vertex_ids = [1, 2, 3, 4, 5]
julia> values = readBlockVectorData(meshName, dataName, vertex_ids)
julia> size(values)
(15,)
```
"""
function readBlockVectorData(meshName::String, dataName::String, valueIndices::AbstractArray{Cint})
    _size = length(valueIndices)
    values = Array{Float64,1}(undef, _size * getDimensions())
    ccall(
        (:precicec_readBlockVectorData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cint}, Ref{Cdouble}),
        meshName,
        dataName,
        _size,
        valueIndices,
        values,
    )
    return permutedims(reshape(values, (getDimensions(), _size)))
end

@doc """

    readVectorData(meshName::String, dataName::String, valueIndex::Integer, dataValue::AbstractArray{Float64})::AbstractArray{Float64}

Read and return vector data from a vertex.

# Arguments
- `meshName::String`: Name of the mesh to read the data from.
- `dataName::String`: Name of the data to be read.
- `valueIndex::AbstractArray{Cint}`: Indicex of the vertex.

# Notes

Previous calls:
 - count of available elements at value matches the configured dimension
 - [`initialize`](@ref) has been called

# Examples

```julia
vertex_id = 5
value = readVectorData("DataOne", vertex_id)
```
"""
function readVectorData(meshName::String, dataName::String, valueIndex::Integer)
    dataValue = Array{Float64,1}(undef, getDimensions())
    ccall(
        (:precicec_readVectorData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cdouble}),
        meshName,
        dataName,
        valueIndex,
        dataValue,
    )
    return dataValue
end


@doc """

    readBlockScalarData(meshName::String, dataName::String, valueIndices::AbstractArray{Cint})::AbstractArray{Float64}

Read and return scalar data as a block, values of specified vertices from a dataName.

# Arguments
- `meshName::String`: Name of the mesh to read the data from.
- `dataName::String`: Name of the data to be read.
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices.

# Notes

Previous calls:
- [`initialize`](@ref) has been called

# Examples

Read block scalar data for 2D and 3D problems with 5 vertices:
```julia
vertex_ids = [1, 2, 3, 4, 5]
values = readBlockScalarData("DataOne", vertex_ids)
```
"""
function readBlockScalarData(meshName::String, dataName::String, valueIndices::AbstractArray{Cint})
    _size = length(valueIndices)
    values = Array{Float64,1}(undef, _size)
    ccall(
        (:precicec_readBlockScalarData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cint}, Ref{Cdouble}),
        meshName,
        dataName,
        _size,
        valueIndices,
        values,
    )
    return values
end


@doc """

    readScalarData(meshName::String, dataName::String, valueIndex::Integer)::Float64

Read and return scalar data of a vertex.

# Arguments
- `meshName::String`: Name of the mesh to read the data from.
- `dataName::String`: Name of the data to be read.
- `valueIndex::AbstractArray{Cint}`: Indicex of the vertex.

# Notes

Previous calls:
- [`initialize`](@ref) has been called.

# Examples

Read scalar data for 2D and 3D problems:
```julia
vertex_id = 5
value = readScalarData("DataOne", vertex_id)
```
"""
function readScalarData(meshName::String, dataName::String, valueIndex::Integer)
    dataValue = [Float64(0.0)]
    ccall(
        (:precicec_readScalarData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cdouble}),
        meshName,
        dataName,
        valueIndex,
        dataValue,
    )
    return dataValue[1]
end


@doc """

    getVersionInformation()

Return a semicolon-separated String containing: 
 - the version of preCICE
 - the revision information of preCICE
 - the configuration of preCICE including MPI, PETSC, PYTHON
"""
function getVersionInformation()
    versionCstring = ccall((:precicec_getVersionInformation, "libprecice"), Cstring, ())
    return unsafe_string(versionCstring)
end


@doc """

    requiresGradientDataFor(dataName::String)::Bool
        
Checks if the given data set requires gradient data. We check if the data object has been intialized with the gradient flag.
# Arguments
- `dataName::String`: Name of the data to be checked.

"""
function requiresGradientDataFor(dataName::String)::Bool
    return ccall((:precicec_requiresGradientDataFor, "libprecice"), Cint, (Ptr{Int8},), dataName)
end

@doc """

    writeBlockVectorGradientData(meshName::String, dataName::String, valueIndices::AbstractArray{Cint}, gradientValues::AbstractArray{Float64})


Write gradient data of a vector data as a block, the value of a specified vertices to a dataName.

The format for a 2D problem with 2 vertices is [v1x_dx v1y_dx v1x_dy v1y_dy; v2x_dx v2y_dx v2x_dy v2y_dy]
The format for a 3D problem with 2 vertices is [v1x_dx v1y_dx v1z_dx v1x_dy v1y_dy v1z_dy v1x_dz v1y_dz v1z_dz; v2x_dx v2y_dx v2z_dx v2x_dy v2y_dy v2z_dy v2x_dz v2y_dz v2z_dz]

# Arguments
- `meshName::String`: Name of the mesh to write the data to.
- `dataName::String`: Name of the data to be written.
- `valueIndices::AbstractArray{Cint}`: Indices of the vertex.
- `gradientValues::AbstractArray{Float64}`: The gradient values to write.

# Notes

Previous calls:
 - [`initialize`](@ref) 

# Examples

Write gradient values of a vector data for a 2D problem with 2 vertices:

```julia
valueIndices = [1, 2]
gradientValues = [1.0 2.0 3.0 4.0; 5.0 6.0 7.0 8.0]
PreCICE.writeBlockVectorGradientData("MeshOne", "DataOne", valueIndices, gradientValue)
```

"""
function writeBlockVectorGradientData(
    meshName::String,
    dataName::String,
    valueIndices::AbstractArray{Cint},
    gradientValues::AbstractArray{Float64},
)
    _size, dimensions = size(gradientValues)
    @assert dimensions == getDimensions() * getDimensions() "Dimensions of vector data in write_block_vector_gradient_data does not match with dimensions in problem definition. Provided dimensions: $dimensions, expected dimensions: $(getDimensions()*getDimensions())"
    gradientValues = reshape(permutedims(gradientValues), :)
    ccall(
        (:precicec_writeBlockVectorGradientData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cint}, Ref{Cdouble}),
        meshName,
        dataName,
        _size,
        valueIndices,
        gradientValues,
    )
end

@doc """

    writeScalarGradientData(meshName::String, dataName::String, valueIndex::Integer, gradientValues::AbstractArray{Float64})

Write gradient data of a scalar data, the value of a specified vertex to a dataName.

The 2D-format of gradientValues is [v_dx, v_dy] vector corresponding to the data block v = [v]
differentiated respectively in x-direction dx and y-direction dy

The 3D-format of gradientValues is [v_dx, v_dy, v_dz] vector
corresponding to the data block v = [v] differentiated respectively in spatial directions x-direction dx and y-direction dy and z-direction dz

# Arguments
- `meshName::String`: Name of the mesh to write the data to.
- `dataName::String`: Name of the data to be written.
- `valueIndex::Integer`: Indice of the vertex.
- `gradientValues::AbstractArray{Float64}`: The gradient values to write.

# Notes

Previous calls:
 - [`initialize`](@ref) 

# Examples

Write gradient values of a scalar data for a 3D problem with 5 vertices:

```julia
vertex_id = 5
gradientValues = [1.0 2.0 3.0]
PreCICE.writeScalarGradientData("MeshOne", "DataName", vertex_id, gradientValue)
```

"""
function writeScalarGradientData(
    meshName::String,
    dataName::String,
    valueIndex::Integer,
    gradientValues::AbstractArray{Float64},
)
    dimensions = length(gradientValues)
    @assert dimensions == getDimensions() "Dimensions of vector data in write_scalar_gradient_data does not match with dimensions in problem definition. Provided dimensions: $dimensions, expected dimensions: $(getDimensions())"

    ccall(
        (:precicec_writeScalarGradientData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cdouble}),
        meshName,
        dataName,
        valueIndex,
        gradientValues,
    )
end


@doc """

    writeVectorGradientData(meshName::String, dataName::String, valueIndex::Integer, gradientValues::AbstractArray{Float64})

Write gradient data of a vector data, the value of a specified vertex to a dataName.

The 2D-format of gradientValues is [vx_dx, vy_dx, vx_dy, vy_dy] vector corresponding to the data block v = [vx, vy]
differentiated respectively in x-direction dx and y-direction dy

The 3D-format of gradientValues is [vx_dx, vy_dx, vz_dx, vx_dy, vy_dy, vz_dy, vx_dz, vy_dz, vz_dz] vector
corresponding to the data block v = [vx, vy, vz] differentiated respectively in spatial directions x-direction dx and y-direction dy and z-direction dz

# Arguments
- `meshName::String`: Name of the mesh to write the data to.
- `dataName::String`: Name of the data to be written.
- `valueIndex::Integer`: Indice of the vertex.
- `gradientValues::AbstractArray{Float64}`: The gradient values to write.

# Notes

Previous calls:
 - [`initialize`](@ref) 

# Examples

Write gradient values of a vector data for a 3D problem with 5 vertices:

```julia
vertex_id = 5
gradientValues = [1.0 2.0 3.0 4.0 5.0 6.0 1.0 2.0 3.0]
PreCICE.writeVectorGradientData("MeshOne", "DataOne", vertex_id, gradientValue)
```
"""
function writeVectorGradientData(
    meshName::String,
    dataName::String,
    valueIndex::Integer,
    gradientValues::AbstractArray{Float64},
)
    dimensions = length(gradientValues)
    @assert dimensions == getDimensions() * getDimensions() "Dimensions of vector data in write_vector_gradient_data does not match with dimensions in problem definition. Provided dimensions: $dimensions, expected dimensions: $(getDimensions()*getDimensions())"

    ccall(
        (:precicec_writeVectorGradientData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cdouble}),
        meshName,
        dataName,
        valueIndex,
        gradientValues,
    )
end

@doc """

    writeBlockScalarGradientData(meshName::String, dataName::String, valueIndices::AbstractArray{Cint}, gradientValues::AbstractArray{Float64})


Write gradient data of a scalar data as a block, the value of a specified vertices to a dataName.

# Arguments
- `meshName::String`: Name of the mesh to write the data to.
- `dataName::String`: Name of the data to be written.
- `valueIndices::AbstractArray{Cint}`: Indices of the vertex.
- `gradientValues::AbstractArray{Float64}`: The gradient values to write. For example for a 2D problem use the format [v1_dx v1_dy; v2_dx v2_dy]

# Notes

Previous calls:
 - [`initialize`](@ref) 

# Examples

Write gradient values of a vector data for a 2D problem with 3 vertices:

```julia
valueIndices = [1,2,3]
gradientValues = [1.0 2.0; 3.0 4.0; 5.0 6.0]
PreCICE.writeBlockScalarGradientData("MeshOne", "DataOne", valueIndices, gradientValue)
```

"""
function writeBlockScalarGradientData(
    meshName::String,
    dataName::String,
    valueIndices::AbstractArray{Cint},
    gradientValues::AbstractArray{Float64},
)
    _size, dimensions = size(gradientValues)
    @assert dimensions == getDimensions() "Dimensions of vector data in write_block_scalar_gradient_data does not match with dimensions in problem definition. Provided dimensions: $dimensions, expected dimensions: $(getDimensions())"
    gradientValues = reshape(permutedims(gradientValues), :)
    ccall(
        (:precicec_writeBlockScalarGradientData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cint}, Ref{Cdouble}),
        meshName,
        dataName,
        _size,
        valueIndices,
        gradientValues,
    )
end

end # module
