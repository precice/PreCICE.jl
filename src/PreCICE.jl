module PreCICE
"""
The `PreCICE` module provides the bindings for using the preCICE api. For more information, visit https://precice.org/.
"""


# TODO add 'return nothing' keyword to void functions
# TODO add Julia's exception handling to the ccalls

# TODO createParticipantWithCommunicator documentation

export
    # construction and configuration
    createParticipant,
    createParticipantWithCommunicator,

    # steering methods
    initialize,
    advance,
    finalize,

    # status queries
    getMeshDimensions,
    getDataDimensions,
    isCouplingOngoing,
    isTimeWindowComplete,
    getMaxTimeStepSize,

    # action methods
    requiresReadingCheckpoint,
    requiresWritingCheckpoint,
    requiresInitialData,


    # mesh access
    hasMesh,
    hasData,
    requiresMeshConnectivityFor,
    setMeshVertex,
    setMeshVertices,
    getMeshVertexSize,
    setMeshEdge,
    setMeshEdges,
    setMeshTriangle,
    setMeshTriangles,
    setMeshQuad,
    setMeshQuads,
    setMeshTetrahedron,
    setMeshTetrahedra,
    setMeshAccessRegion,
    getMeshVertexIDsAndCoordinates,

    # data access
    writeData,
    readData,

    # constants
    getVersionInformation,

    # Gradient related 
    requiresGradientDataFor,
    writeGradientData


@doc """

    createParticipant(participantName::String, configFilename::String, solverProcessIndex::Integer, solverProcessSize::Integer)

Create the coupling interface and configure it. Must get called before any other method of this interface.

# Arguments
- `participantName::String`: Name of the participant from the xml configuration that is using the interface.
- `configFilename::String`: Name (with path) of the xml configuration file.
- `solverProcessIndex::Integer`: If the solver code runs with several processes, each process using preCICE has to specify its index, which has to start from 0 and end with solverProcessSize - 1.
- `solverProcessSize::Integer`: The number of solver processes of this participant using preCICE.

# Examples
```julia
createParticipant("SolverOne", "./precice-config.xml", 0, 1)
```
"""
function createParticipant(
    participantName::String,
    configFilename::String,
    solverProcessIndex::Integer,
    solverProcessSize::Integer,
)
    ccall(
        (:precicec_createParticipant, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Cint),
        participantName,
        configFilename,
        solverProcessIndex,
        solverProcessSize,
    )
end

@doc """
    createParticipantWithCommunicator(participantName::String, configFilename::String, solverProcessIndex::Integer, solverProcessSize::Integer, communicator::Union{Ptr{Cvoid}, Ref{Cvoid}, Ptr{Nothing}})

TODO: Documentation or [WIP] tag. The data types of the communicator are not yet verified.

# See also:

[`createParticipant`](@ref)

# Arguments

- `participantName::String`: Name of the participant from the xml configuration that is using the interface.
- `configFilename::String`: Name (with path) of the xml configuration file.
- `solverProcessIndex::Integer`: If the solver code runs with several processes, each process using preCICE has to specify its index, which has to start from 0 and end with solverProcessSize - 1.
- `solverProcessSize::Integer`: The number of solver processes of this participant using preCICE.
- `communicator::Union{Ptr{Cvoid}, Ref{Cvoid}, Ptr{Nothing}}`: TODO ?
"""
function createParticipantWithCommunicator(
    participantName::String,
    configFilename::String,
    solverProcessIndex::Integer,
    solverProcessSize::Integer,
    communicator::Union{Ptr{Cvoid},Ref{Cvoid},Ptr{Nothing}},
) # test if type of com is correct
    ccall(
        (:precicec_createParticipant_withCommunicator, "libprecice"),
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

    initialize()

Fully initializes preCICE and coupling data.

This function does the following:
- Sets up a connection to the other participants of the coupled simulation.
- Creates all meshes, solver meshes need to be submitted before.
- Receives first coupling data. The starting values for coupling data are zero by default.
- Determines maximum allowed size of the first time step to be computed.

# Notes

See also:
- [`getMaxTimeStepSize`](@ref)
"""
function initialize()
    dt::Float64 = ccall((:precicec_initialize, "libprecice"), Cdouble, ())
    return dt
end


@doc """
    
    advance(computedTimestepLength::Float64)

Advances preCICE after the solver has computed one time step.

This function does the following:
- Sends and resets coupling data written by solver to coupling partners.
- Receives coupling data read by solver.
- Computes and applies data mappings.
- Computes acceleration of coupling data.
- Exchanges and computes information regarding the state of the coupled simulation.

# Arguments
 - `computed_timestep_length::Float64`: Size of time step used by the solver.

# Notes

Previous calls:
 - [`initialize`](@ref) has been called successfully.
 - The solver has computed one timestep.
 - The solver has written all coupling data.
 - [`finalize`](@ref) has not yet been called.
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

If initialize() has been called:
- synchronizes with remote participants
- handles final exports
- cleans up general state
- closes communication channels

Always:
- flushes and finalizes Events
- finalizes managed PETSc
- finalizes managed MPI
"""
function finalize()
    ccall((:precicec_finalize, "libprecice"), Cvoid, ())
end


@doc """

    getMeshDimensions(meshName::String)::Integer

Returns the spatial dimensionality of the given mesh.

# Arguments
 - `meshName::String`: Name of the mesh.
"""
function getMeshDimensions(meshName::String)::Integer
    dim::Integer =
        ccall((:precicec_getMeshDimensions, "libprecice"), Cint, (Ptr{Int8},), meshName)
    return dim
end


@doc """

    getDataDimensions(meshName::String, dataName::String)::Integer

Returns the spatial dimensionality of the given data on the given mesh.
Note that vectorial data dimensionality directly depends on the spacial dimensionality of the mesh.

# Arguments
 - `meshName::String`: Name of the associated mesh.
 - `dataName::String`: Name of the data to get the dimensionality of.
"""
function getDataDimensions(meshName::String, dataName::String)::Integer
    dim::Integer = ccall(
        (:precicec_getDataDimensions, "libprecice"),
        Cint,
        (Ptr{Int8}, Ptr{Int8}),
        meshName,
        dataName,
    )
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

    getMaxTimeStepSize()::Float64

Get the maximum allowed time step size of the current window.
This should be used to compute the actual time step that the solver uses.
"""
function getMaxTimeStepSize()::Float64
    dt::Float64 = ccall((:precicec_getMaxTimeStepSize, "libprecice"), Cdouble, ())
    return dt
end


@doc """

    requiresInitialData()::Bool

Check if the solver has to provide initial data.

# Notes

 - [`initialize`](@ref) has *not* yet been called.
"""
function requiresInitialData()::Bool
    ans::Integer = ccall((:precicec_requiresInitialData, "libprecice"), Cint, ())
    return ans
end


@doc """ 

    requiresReadingCheckpoint()::Bool

Check if the solver has to read an iteration checkpoint.
preCICE refuses to proceed if reading a checkpoint is required, but this method isn't called prior to advance().
"""
function requiresReadingCheckpoint()::Bool
    ans::Integer = ccall((:precicec_requiresReadingCheckpoint, "libprecice"), Cint, ())
    return ans
end

@doc """

    requiresWritingCheckpoint()::Bool

Check if the solver has to write a checkpoint.
preCICE refuses to proceed if writing a checkpoint is required, but this method isn't called prior to advance().
"""
function requiresWritingCheckpoint()::Bool
    ans::Integer = ccall((:precicec_requiresWritingCheckpoint, "libprecice"), Cint, ())
    return ans
end


@doc """

    hasMesh(meshName::String)::Bool

Check if the mesh with given name is used by a solver.

# Arguments
 - `meshName::String`: Name of the mesh.
"""
function hasMesh(meshName::String)::Bool
    ans::Integer = ccall((:precicec_hasMesh, "libprecice"), Cint, (Ptr{Int8},), meshName)
    return ans
end


@doc """

    hasData(dataName::String, meshName::String)::Bool

Checks if the data with given name is used by a solver and mesh.

# Arguments
 - `dataName::String`: Name of the data.
 - `meshName::String`: Name of the associated mesh.

"""
function hasData(dataName::String, meshName::String)::Bool
    ans::Integer = ccall(
        (:precicec_hasData, "libprecice"),
        Cint,
        (Ptr{Int8}, Ptr{Int8}),
        dataName,
        meshName,
    )
    return ans
end

@doc """

    requiresMeshConnectivityFor(meshName::String)::Bool

Checks if the given mesh requires connectivity.

preCICE may require connectivity information from the solver and
ignores any API calls regarding connectivity if it is not required.
Use this function to conditionally generate this connectivity.
"""
function requiresMeshConnectivityFor(meshName::String)::Bool
    ans::Integer = ccall(
        (:precicec_requiresMeshConnectivityFor, "libprecice"),
        Cint,
        (Ptr{Int8},),
        meshName,
    )
    return ans
end


@doc """

    setMeshVertex(meshName::String, position::AbstractArray{Float64})::Integer

Create a mesh vertex on a coupling mesh and return its id.

# Arguments
- `meshName::String`: The name of the mesh to add the vertex to. 
- `position::AbstractArray{Float64}`: An array with the coordinates of the vertex. Depending on the dimension, either [x1, x2] or [x1,x2,x3].

# Notes

Previous calls:
 - Count of available elements at position matches the configured dimension.

# Examples
```julia
v1_id = setMeshVertex(mesh_name, [1,1,1])
```
"""
function setMeshVertex(meshName::String, position::AbstractArray{Float64})::Integer
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

    setMeshVertices(meshName::String, positions::AbstractArray{Float64})::AbstractArray{Int32,1}

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
function setMeshVertices(
    meshName::String,
    positions::AbstractArray{Float64},
)::AbstractArray{Int32,1}
    _size, dimensions = size(positions)
    @assert dimensions == getMeshDimensions(meshName) "Dimensions of vector data in write_vector_data does not match with dimensions in problem definition. Provided dimensions: $dimensions, expected dimensions: $(getMeshDimensions(meshName))"

    positions = permutedims(positions) # transpose

    vertexIDs = Array{Int32,1}(undef, _size)
    ccall(
        (:precicec_setMeshVertices, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Cint, Ref{Cdouble}, Ref{Cint}),
        meshName,
        _size,
        reshape(permutedims(positions), :),
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

Set mesh edge from vertex IDs, return edge ID. Ignored if preCICE doesn't require connectivity for the mesh.

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

    setMeshEdges(meshName::String, vertices::AbstractArray{Cint})

Create multiple mesh edges

# Arguments
- `meshName::String`: Name of the mesh to add the edge to.
- `vertices::AbstractArray{Cint}`: An array holding the vertex IDs of the edges.
                                   It has the shape [N x 2] where N = number of edges.

# Examples
Set mesh edges for a problem with 4 mesh vertices in the form of a square with both diagonals which are fully interconnected.
```julia-repl
julia> vertices = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4]
julia> vertices.shape
(6,2)
julia> setMeshEdges("MeshOne", vertices)
```
"""
function setMeshEdges(meshName::String, vertices::AbstractArray{Cint})
    _size, n = size(vertices)
    @assert n == 2 "Vertices pairs need to be provided while setting mesh edges. Provided shape: ($_size, $n), expected shape: ($_size, 2)"

    ccall(
        (:precicec_setMeshEdges, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Cint, Ref{Cint}),
        meshName,
        _size,
        reshape(permutedims(vertices), :),
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

# Examples
Set mesh triangles for a problem with 4 mesh vertices in the form of a square with both diagonals which are fully interconnected.
```julia-repl
julia> vertices = [1 2 3; 1 3 4; 1 2 4; 1 3 4]
julia> vertices.shape
(4,3)
julia> setMeshTriangles("MeshOne", vertices)
```
"""
function setMeshTriangles(meshName::String, vertices::AbstractArray{Integer})
    _size, n = size(vertices)
    @assert n == 3 "Vertices triplets need to be provided while setting mesh triangles. Provided shape: ($_size, $n), expected shape: ($_size, 3)"

    ccall(
        (:precicec_setMeshTriangles, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Cint, Ref{Cint}),
        meshName,
        _size,
        reshape(permutedims(vertices), :),
    )
end


@doc """

    setMeshQuad(meshName::String, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID, fourthEdgeID::Integer)

Set mesh Quad from edge IDs.

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
    thirdEdgeID::Integer,
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
- `vertices::AbstractArray{Integer}`: IDs of the edges of the Quads. It has the shape [N x 4] where N = number of Quads.

"""
function setMeshQuads(meshName::String, vertices::AbstractArray{Integer})
    _size, n = size(vertices)
    @assert n == 4 "Vertices quadruplets need to be provided while setting mesh quads. Provided shape: ($_size, $n), expected shape: ($_size, 4)"
    ccall(
        (:precicec_setMeshQuads, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Cint, Ref{Cint}),
        meshName,
        _size,
        reshape(permutedims(vertices), :),
    )

end

@doc """

    setMeshTetrahedron(meshName::String, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer, fourthEdgeID::Integer)

Set mesh Tetrahedron from edge IDs.

# Arguments
- `meshName::String`: Name of the mesh to add the Tetrahedron to.
- `firstEdgeID::Integer`: ID of the first edge of the Tetrahedron.
- `secondEdgeID::Integer`: ID of the second edge of the Tetrahedron.
- `thirdEdgeID::Integer`: ID of the third edge of the Tetrahedron.
- `fourthEdgeID::Integer`: ID of the fourth edge of the Tetrahedron.

# Notes

Previous calls:
 - Edges with `first_edge_id`, `second_edge_id`, `third_edge_id`, and `fourth_edge_id` were added
    to the mesh with the ID `mesh_id`
"""
function setMeshTetrahedron(
    meshName::String,
    firstEdgeID::Integer,
    secondEdgeID::Integer,
    thirdEdgeID::Integer,
    fourthEdgeID::Integer,
)
    ccall(
        (:precicec_setMeshTetrahedron, "libprecice"),
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

    setMeshTetrahedra(meshName::String, vertices::AbstractArray{Integer})

Set mesh Tetrahedron from vertex IDs.

# Arguments
- `meshName::String`: Name of the mesh to add the Tetrahedron to.
- `vertices::AbstractArray{Integer}`: IDs of the edges of the Tetrahedra. It has the shape [N x 4] where N = number of Tetrahedra.

"""
function setMeshTetrahedra(meshName::String, vertices::AbstractArray{Integer})
    _size, n = size(vertices)
    @assert n == 4 "Vertices quadruplets need to be provided while setting mesh tetrahedra. Provided shape: ($_size, $n), expected shape: ($_size, 4)"
    ccall(
        (:precicec_setMeshTetrahedra, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Cint, Ref{Cint}),
        meshName,
        _size,
        reshape(permutedims(vertices), :),
    )
end


@doc """

        writeData(meshName::String, dataName::String, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})

Writes values of specified vertices to data of a mesh.
Values are provided as a matrix.
The order of the provided data follows the order specified by vertices.

The 1D/Scalar-format of values is a vector of length N.
The 2D-format of values is [N x 2].
The 3D-format of values is [N x 3].
Where N is the number of vertices.

# Arguments
- `meshName::String`: Name of the mesh to write the data to.
- `dataName::String`: Name of the data to be written.
- `valueIndices::AbstractArray{Cint}`: The vertex ids of the vertices to write data to. Shape [N x 1] where N = number of vertices.
- `values::AbstractArray{Float64}`: The values to be written to preCICE. Shape [N x D] where N = number of vertices and D = number of data dimensions.

# Notes

Previous calls:
- Every VertexID in `valueIndices` is return value of setMeshVertex or setMeshVertices
- `size(values) == (length(valueIndices), getDataDimensions(meshName, dataName))`

See also:
- [`setMeshVertex`](@ref)
- [`setMeshVertices`](@ref)
- [`getDataDimensions`](@ref)
"""
function writeData(
    meshName::String,
    dataName::String,
    valueIndices::AbstractArray{Cint},
    values::AbstractArray{Float64},
)
    _size, n = size(values)
    @assert n == getDataDimensions(meshName, dataName) "The number of columns of values must match the number of data dimensions. Provided shape: ($_size, $n), expected shape: ($_size, $(getDataDimensions(meshName, dataName)))"
    ccall(
        (:precicec_writeData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cint}, Ref{Float64}),
        meshName,
        dataName,
        _size,
        reshape(permutedims(valueIndices), :),
        reshape(permutedims(values), :),
    )
end

@doc """
        readData(meshName::String, dataName::String, valueIndices::AbstractArray{Cint}, relativeReadTime::Float64)

Reads values of specified vertices from data of a mesh.
Values are read into a matrix in the order specified by vertices.

The 1D/Scalar-format of values is a vector of length N.
The 2D-format of values is [N x 2].
The 3D-format of values is [N x 3].
Where N is the number of vertices.

The data is read at relativeReadTime, which indicates the point in time measured from the beginning of the current time step.
`relativeReadTime = 0` corresponds to data at the beginning of the time step. Assuming that the user will call `advance(dt)` at the
end of the time step, `dt` indicates the size of the current time step. Then `relativeReadTime = dt` corresponds to the data at
the end of the time step.

# Arguments
- `meshName::String`: Name of the mesh to read the data from.
- `dataName::String`: Name of the data to be read from
- `valueIndices::AbstractArray{Cint}`: The vertex ids of the vertices to read data from.
- `relativeReadTime::Float64`: The point in time relative to the beginning of the current time step to read the data from.

# Returns
- `values::AbstractArray{Float64}`: The values read from preCICE. Shape [N x D] where N = number of vertices and D = number of data dimensions.

# Notes
- Every VertexID in vertices is a return value of setMeshVertex or setMeshVertices
- `size(values) == (length(valueIndices), getDataDimensions(meshName, dataName))`
"""
function readData(
    meshName::String,
    dataName::String,
    valueIndices::AbstractArray{Cint},
    relativeReadTime::Float64,
)
    _size = length(valueIndices)
    values = Array{Float64,1}(undef, _size * getDataDimensions(meshName, dataName))
    ccall(
        (:precicec_readData, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ptr{Int8}, Cint, Ref{Cint}, Float64, Ref{Float64}),
        meshName,
        dataName,
        _size,
        valueIndices,
        relativeReadTime,
        values,
    )
    return permutedims(reshape(values, (getDataDimensions(meshName, dataName), _size)))
end


@doc """

    setMeshAccessRegion(meshName::String, boundingBox::AbstractArray{Float64})

This function is required if you don't want to use the mapping schemes in preCICE, but rather
want to use your own solver for data mapping. As opposed to the usual preCICE mapping, only a
single mesh (from the other participant) is now involved in this situation since an 'own'
mesh defined by the participant itself is not required any more. In order to re-partition the
received mesh, the participant needs to define the mesh region it wants read data from and
write data to. The mesh region is specified through an axis-aligned bounding box given by the
lower and upper [min and max] bounding-box limits in each space dimension [x, y, z]. This function is still
experimental


# Arguments
- `meshName::String`: Name of the mesh to define the access region for.
- `boundingBox::AbstractArray{Float64}`: Axis-aligned bounding box. Example for 3D the format: [x_min, x_max, y_min, y_max, z_min, z_max]

# Notes
Defining a bounding box for serial runs of the solver (not to be confused with serial coupling
mode) is valid. However, a warning is raised in case vertices are filtered out completely
on the receiving side, since the associated data values of the filtered vertices are filled
with zero data.
This function can only be called once per participant and rank and trying to call it more than
once results in an error.
If you combine the direct access with a mapping (say you want to read data from a defined
mesh, as usual, but you want to directly access and write data on a received mesh without a
mapping) you may not need this function at all since the region of interest is already defined
through the defined mesh used for data reading. This is the case if you define any mapping
involving the directly accessed mesh on the receiving participant. (In parallel, only the cases
read-consistent and write-conservative are relevant, as usual).
The safety factor scaling (see safety-factor in the configuration file) is not applied to the
defined access region and a specified safety will be ignored in case there is no additional
mapping involved. However, in case a mapping is in addition to the direct access involved, you
will receive (and gain access to) vertices inside the defined access region plus vertices inside
the safety factor region resulting from the mapping. The default value of the safety factor is
0.5, i.e. the defined access region as computed through the involved provided mesh is by 50%
enlarged.
"""
function setMeshAccessRegion(meshName::String, boundingBox::AbstractArray{Float64})
    @assert length(boundingBox) > 0 "The bounding box must not be empty"
    @assert length(boundingBox) == getMeshDimensions(meshName) * 2 "The bounding box must have the same dimension as the mesh"
    ccall(
        (:precicec_setMeshAccessRegion, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Ref{Cdouble}),
        meshName,
        boundingBox,
    )
end

@doc """

    getMeshVertexIDsAndCoordinates(meshName::String)::Tuple{AbstractArray{Integer}, AbstractArray{Float64}}

Iterating over the region of interest defined by bounding boxes and reading the corresponding
coordinates omitting the mapping. This function is still experimental.

# Arguments
- `meshName::String`: Name of the mesh to get the vertices and IDs for.

# Returns
- `vertexIDs::AbstractArray{Integer}`: IDs of the vertices.
- `vertexCoordinates::AbstractArray{Float64}`: Coordinates of the vertices and corresponding data values. Shape [N x D] where N = number of vertices and D = number of data dimensions.
"""
function getMeshVertexIDsAndCoordinates(
    meshName::String,
)::Tuple{AbstractArray{Integer},AbstractArray{Float64}}
    _size = getMeshVertexSize(meshName)
    vertexIDs = zeros(Cint, _size)
    vertexCoordinates = zeros(Float64, _size * getMeshDimensions(meshName))
    ccall(
        (:precicec_getMeshVertexIDsAndCoordinates, "libprecice"),
        Cvoid,
        (Ptr{Int8}, Cint, Ref{Cint}, Ref{Cdouble}),
        meshName,
        _size,
        vertexIDs,
        vertexCoordinates,
    )
    return vertexIDs,
    permutedims(reshape(vertexCoordinates, (_size, getMeshDimensions(meshName))))
end

@doc """

    getVersionInformation()::String

Return a semicolon-separated String containing: 
 - the version of preCICE
 - the revision information of preCICE
 - the configuration of preCICE including MPI, PETSC, PYTHON
"""
function getVersionInformation()::String
    versionCstring = ccall((:precicec_getVersionInformation, "libprecice"), Cstring, ())
    return unsafe_string(versionCstring)
end


@doc """

    requiresGradientDataFor(meshName::String, dataName::String)::Bool
        
Checks if the given data set requires gradient data. We check if the data object has been intialized with the gradient flag.
# Arguments
- `meshName::String`: Name of the mesh to be checked.
- `dataName::String`: Name of the data to be checked.

"""
function requiresGradientDataFor(meshName::String, dataName::String)::Bool
    return ccall(
        (:precicec_requiresGradientDataFor, "libprecice"),
        Cint,
        (Ptr{Int8}, Ptr{Int8}),
        meshName,
        dataName,
    )
end

@doc """

    writeGradientData(meshName::String, dataName::String, valueIndices::AbstractArray{Cint}, gradientValues::AbstractArray{Float64})


Write gradient values of specified vertices to data of a mesh.

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
PreCICE.writeGradientData("MeshOne", "DataOne", valueIndices, gradientValue)
```

"""
function writeGradientData(
    meshName::String,
    dataName::String,
    valueIndices::AbstractArray{Cint},
    gradientValues::AbstractArray{Float64},
)
    _size, dimensions = size(gradientValues)
    @assert dimensions == getMeshDimensions(meshName) * getMeshDimensions(meshName) "Dimensions of vector data in write_block_vector_gradient_data does not match with dimensions in problem definition. Provided dimensions: $dimensions, expected dimensions: $(getMeshDimensions(meshName)*getMeshDimensions(meshName))"
    gradientValues = reshape(permutedims(gradientValues), :)
    ccall(
        (:precicec_writeGradientData, "libprecice"),
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
