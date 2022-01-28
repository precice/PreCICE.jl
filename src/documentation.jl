# Documentation of PreCICE.jl API functions
# for extending this documentation follow the guidelines at https://docs.julialang.org/en/v1/manual/documentation/


# TODO jldoctests: Make sure the tests work

@doc """

    setPathToLibprecice(pathToPrecice::String) 

Configure which preCICE binary to use. Set it if preCICE was installed at a custom directory.
"""
setPathToLibprecice

@doc """
Reset custom path configurations and use the binary at the default path "/usr/lib/x86_64-linux-gnu/libprecice.so".
"""
resetPathToLibprecice

@doc """

    createSolverInterface(participantName::String, configFilename::String, solverProcessIndex::Integer, solverProcessSize::Integer)

Create the coupling interface and configure it. Must get called before any other method of this interface.

# Arguments
- `participantName::String`: Name of the participant from the xml configuration that is using the interface.
- `configFilename::String`: Name (with path) of the xml configuration file.
- `solverProcessIndex::Integer`: If the solver code runs with several processes, each process using preCICE has to specify its index, which has to start from 0 and end with solverProcessSize - 1.
- `solverProcessSize::Integer`: The number of solver processes of this participant using preCICE.

# Examples
```jldoctest
julia>createSolverInterface("SolverOne", "./precice-config.xml", 0, 1)
```
"""
createSolverInterface



@doc """

"""
createSolverInterfaceWithCommunicator



@doc """

    initialize()::Float64

Fully initializes preCICE.
This function handles:
- Parallel communication to the coupling partner/s is setup.
- Meshes are exchanged between coupling partners and the parallel partitions are created.
- **Serial Coupling Scheme:** If the solver is not starting the simulation, coupling data is received from the coupling partner's first computation.

Return the maximum length of first timestep to be computed by the solver.
"""
initialize



@doc """

    initializeData()::nothing

Initializes coupling data. The starting values for coupling data are zero by default.
To provide custom values, first set the data using the Data Access methods and
call this method to finally exchange the data.
Serial Coupling Scheme: Only the first participant has to call this method, the second participant
receives the values on calling [`initialize`](@initialize).
Parallel Coupling Scheme:
- Values in both directions are exchanged.
- Both participants need to call [`initializeData`](@initializeData).

# Notes

Previous calls:
 - [`initialize`](@initialize) has been called successfully.
 - The action `WriteInitialData` is required
 - [`advance`](@advance) has not yet been called.
 - [`finalize`](@finalize) has not yet been called.

Tasks completed:
 - Initial coupling data was exchanged.
"""
initializeData



@doc """
    
    advance(computedTimestepLength::Float64)::Float64

Advances preCICE after the solver has computed one timestep.

# Arguments
 - `computed_timestep_length::Float64`: Length of timestep used by the solver.

Return the maximum length of next timestep to be computed by solver.

# Notes

Previous calls:
 - [`initialize`](@initialize) has been called successfully.
 - The solver has computed one timestep.
 - The solver has written all coupling data.
 - [`finalize`](@finalize) has not yet been called.
Tasks completed:
 - Coupling data values specified in the configuration are exchanged.
 - Coupling scheme state (computed time, computed timesteps, ...) is updated.
 - The coupling state is logged.
 - Configured data mapping schemes are applied.
 - [Second Participant] Configured post processing schemes are applied.
 - Meshes with data are exported to files if configured.

Exchange data between solver and coupling supervisor. Return maximal length of next timestep to be computed by solver.
"""
advance



@doc """

    finalize()::nothing

Finalize the coupling to the coupling supervisor.

# Notes

Previous calls:
 - [`initialize`](@initialize) has been called successfully.

Tasks completed:
 - Communication channels are closed.
 - Meshes and data are deallocated.
"""
finalize



@doc """

    getDimensions()::Integer

Return the number of spatial dimensions configured. Currently, two and three dimensional problems
can be solved using preCICE. The dimension is specified in the XML configuration.
"""
getDimensions



@doc """

    isCouplingOngoing()::Bool

Check if the coupled simulation is still ongoing.
A coupling is ongoing as long as
 - the maximum number of timesteps has not been reached, and
 - the final time has not been reached.
The user should call [`finalize`](@finalize) after this function returns false.

Return whether the coupling is ongoing.

# Notes

Previous calls:
 - [`initialize`](@initialize) has been called successfully.
"""
isCouplingOngoing



@doc """

    isTimeWindowComplete()::Bool

Check if the current coupling timewindow is completed.

The following reasons require several solver time steps per coupling time step:
- A solver chooses to perform subcycling.
- An implicit coupling timestep iteration is not yet converged.

Return whether the timestep is complete.

# Notes

Previous calls:
 - [`initialize`](@initialize) has been called successfully.

"""
isTimeWindowComplete



@doc """

    hasToEvaluateSurrogateModel()::Bool

Return whether the solver has to evaluate the surrogate model representation.
The solver may still have to evaluate the fine model representation.
DEPRECATED: Only necessary for deprecated manifold mapping.
"""
hasToEvaluateSurrogateModel



@doc """

    hasToEvaluateFineModel()::Bool

Check if the solver has to evaluate the fine model representation.
The solver may still have to evaluate the surrogate model representation.
DEPRECATED: Only necessary for deprecated manifold mapping.

Return whether the solver has to evaluate the fine model representation.
"""
hasToEvaluateFineModel



@doc """

    isReadDataAvailable()::Bool

Check if new data to be read is available. Data is classified to be new, if it has been received
while calling [`initialize`](@initialize) and before calling [`advance`](@advance), or in the last call of [`advance`](@advance).
This is always true, if a participant does not make use of subcycling, i.e. choosing smaller
timesteps than the limits returned in [`intitialize`](@initialize) and [`advance`](@advance).
It is allowed to read data even if this function returns false. This is not recommended
due to performance reasons. Use this function to prevent unnecessary reads.

Returns whether new data is available to be read. True if new data to read is available.

#Notes

Previous calls:
 - [`initialize`](@initialize) has been called successfully.
"""
isReadDataAvailable



@doc """

    isWriteDataRequired(computedTimestepLength::Float64)::Bool

Check if new data has to be written before calling [`advance`](@advance).
This is always true, if a participant does not make use of subcycling, i.e. choosing smaller
timesteps than the limits returned in [`intitialize`](@initialize) and [`advance`](@advance).
It is allowed to write data even if this function returns false. This is not recommended
due to performance reasons. Use this function to prevent unnecessary writes.

# Arguments

 - `computed_timestep_length::double`: Length of timestep used by the solver.

Return whether new data has to be written.

# Notes

Previous calls:
 - [`initialize`](@initialize) has been called successfully.
"""
isWriteDataRequired



@doc """

    isActionRequired(action::String)::Bool

Checks if the provided action is required.
Some features of preCICE require a solver to perform specific actions, in order to be
in valid state for a coupled simulation. A solver is made eligible to use those features,
by querying for the required actions, performing them on demand, and calling markActionfulfilled()
to signalize preCICE the correct behavior of the solver.

# Arguments
 - `action:: PreCICE action`: Name of the action

Return true if the action is required.
"""
isActionRequired



@doc """

    markActionFulfilled(action::String)::nothing

Indicate preCICE that a required action has been fulfilled by a solver. 

# Arguments
 - `action::String`: Name of the action.

# Notes

Previous calls:
 - The solver fulfilled the specified action.
"""
markActionFulfilled



@doc """

    hasMesh(meshName::String)::Bool

Check if the mesh with given name is used by a solver. 

# Arguments
 - `meshName::String`: Name of the mesh.
"""
hasMesh



@doc """

    getMeshID(meshName::String)::Integer

Return the ID belonging to the given mesh name.

# Arguments
 - `meshName::String`: Name of the mesh.

# Examples
```jldoctest
julia>meshid = getMeshID("MeshOne")
julia>meshid
0
```
"""
getMeshID



@doc """

    hasData(dataName::String, meshID::Integer)::Bool

Check if the data with given name is used by a solver and mesh.
 
# Arguments
 - `dataName::String`: Name of the data.
 - `meshID::Integer`: ID of the associated mesh.

Return true if the mesh is already used.
"""
hasData



@doc """

    getDataID(dataName::String, meshID::Integer)::Integer

    # Arguments
     - `dataName::String`: Name of the data.
     - `meshID::Integer`: ID of the associated mesh.

Return the data id belonging to the given name.

The given name (`dataName`) has to be one of the names specified in the configuration file. The data ID obtained can be used to read and write data to and from the coupling mesh.
"""
getDataID


@doc """

    setMeshVertex(meshID::Integer, position::AbstractArray{Float64})

Create a mesh vertex on a coupling mesh and return its id.

# Arguments
- `meshID::Integer`: The id of the mesh to add the vertex to. 
- `position::AbstractArray{Float64}`: An array with the coordinates of the vertex. Depending on the dimension, either [x1, x2] or [x1,x2,x3].

# See also
[`getDimensions`](@getDimensions), [`setMeshVertices`](@setMeshVertices)

# Notes

Previous calls:
 - Count of available elements at position matches the configured dimension.

# Examples
```jldoctest
julia> v1_id = setMeshVertex(mesh_id, [1,1,1])
```

"""
setMeshVertex



@doc """

    getMeshVertices(meshID::Integer, size::Integer, ids::AbstractArray{Cint}, positions::AbstractArray{Float64})::AbstractArray{Float64}

Get vertex positions for multiple vertex ids from a given mesh.

# Arguments
- `meshID::Integer`:  The id of the mesh to read the vertices from.
- `size::Integer`:  Number of vertices to lookup.
- `ids::AbstractArray{Cint}`:  The id of the mesh to read the vertices from.
- `positions::AbstractArray{Float64}`:  Positions to write the coordinates to.
                                        The 2D-format is (d0x, d0y, d1x, d1y, ..., dnx, dny),
                                        the 3D-format is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz).

# Notes

Previous calls:
 - count of available elements at positions matches the configured `dimension * size`.
 - count of available elements at ids matches size.

# Examples
Return data structure for a 2D problem with 5 vertices:
```jldoctest
julia>meshID = getMeshID("MeshOne")
julia>vertexIDs = [1,2,3,4]
julia>positions = getMeshVertices(meshID, vertexIDs)
julia>size(positions)
(5, 2)
```
Return data structure for a 3D problem with 5 vertices:

```jldoctest
julia> mesh_id = get_mesh_id("MeshOne")
julia> vertex_ids = [1, 2, 3, 4, 5]
julia> positions = get_mesh_vertices(mesh_id, vertex_ids)
julia> size(positions)
(5, 3)
```
"""
getMeshVertices



@doc """

    setMeshVertices(meshID::Integer, size::Integer, positions::AbstractArray{Float64})

Create multiple mesh vertices on a coupling mesh and return an array holding their ids.


# Arguments
- `meshID::Integer`: The id of the mesh to add the vertices to. 
- `size::Integer`: Number of vertices to create.
- `positions::AbstractArray{Float64}`: An array holding the coordinates of the vertices.
                                    The 2D-format is (d0x, d0y, d1x, d1y, ..., dnx, dny), 
                                    the 3D-format is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz).
                 
# Notes
Previous calls:
 - [`initialize`](@initialize) has not yet been called
 - count of available elements at positions matches the configured `dimension` * `size`
 - count of available elements at ids matches size


# See also
[`getDimensions`](@getDimensions), [`setMeshVertex`](@setMeshVertex)

# Examples
```jldoctest
julia> vertices = [1,1,1,2,2,2,3,3,3]
julia> vertex_ids = setMeshVertices(mesh_id, 3, vertices)
```
"""
setMeshVertices



@doc """

    getMeshVertexSize(meshID::Integer)::Integer

Return the number of vertices of a mesh.

"""
getMeshVertexSize


@doc """

    getMeshVertexIDsFromPositions(meshID::Integer, size::Integer, positions::AbstractArray{Float64}, ids::AbstractArray{Cint})

Get mesh vertex IDs from positions.
Prefer to reuse the IDs returned from calls to [`setMeshVertex`](@setMeshVertex) and [`setMeshVertices`](@setMeshVertices).

# Arguments
- `meshID::Integer`: ID of the mesh to retrieve positions from.
- `size::Integer`: Number of vertices to lookup.
- `positions::AbstractArray{Float64}`: Positions to find ids for.
                                       The 2D-format is (d0x, d0y, d1x, d1y, ..., dnx, dny),
                                       the 3D-format is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz).
- `ids::AbstractArray{Cint}`: IDs corresponding to positions.

# Notes

Previous calls:
 - count of available elements at positions matches the configured `dimension` * `size`
 - count of available elements at ids matches size

 # Examples
 Get mesh vertex ids from positions for a 2D (D=2) problem with 5 (N=5) mesh vertices.
```jldoctest
julia>meshID = getMeshID("MeshOne")
julia>positions = [1 1; 2 2; 3 3; 4 4; 5 5]
julia>size(positions)
(5, 2)
julia>vertex_ids = getMeshVertexIDsFromPositions(meshID, positions)
```
"""
getMeshVertexIDsFromPositions


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
setMeshEdge



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
setMeshTriangle



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
 - Edges with `first_vertex_id`, `second_vertex_id`, and `third_vertex_id` were added to the mesh with the ID `meshID`
"""
setMeshTriangleWithEdges



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
setMeshQuad



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

Notes

Previous calls:
 - Edges with `first_vertex_id`, `second_vertex_id`, `third_vertex_id`, and `fourth_vertex_id` were added
    to the mesh with the ID `mesh_id`
"""
setMeshQuadWithEdges


# TODO check this again, is this true?
@doc """

    writeBlockVectorData(dataID::Integer, size::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})

Write vector data values given as block. This function writes values of specified vertices to a `dataID`.
Values are provided as a block of continuous memory. Values are stored in a Matrix [N x D] where N = number
of vertices and D = dimensions of geometry 

The block must contain the vector values in the following form: 

values = (d0x, d0y, d0z, d1x, d1y, d1z, ...., dnx, dny, dnz), where n is the number of vector values. In 2D, the z-components are removed.

# Arguments
- `dataID::Integer`: ID of the data to be written.
- `size::Integer`: Number n of vertices. 
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices. 
- `values::AbstractArray{Float64}`: Values of the data to be written.

# Notes

Previous calls:
 - count of available elements at values matches the configured `dimension` * `size`
 - count of available elements at `vertex_ids` matches the given size
 - [`initialize`](@initialize) has been called

Examples

Write block vector data for a 2D problem with 5 vertices:
```jldoctest
julia> data_id = 1
julia> vertex_ids = [1, 2, 3, 4, 5]
julia> values = [v1_x, v1_y; v2_x, v2_y; v3_x, v3_y; v4_x, v4_y; v5_x, v5_y])
julia> write_block_vector_data(data_id, vertex_ids, values)
```
Write block vector data for a 3D (D=3) problem with 5 (N=5) vertices:
```jldoctest
julia> data_id = 1
julia> vertex_ids = [1, 2, 3, 4, 5]
julia> values = [v1_x, v1_y, v1_z; v2_x, v2_y, v2_z; v3_x, v3_y, v3_z; v4_x, v4_y, v4_z; v5_x, v5_y, v5_z]
julia> write_block_vector_data(data_id, vertex_ids, values)
```
"""
writeBlockVectorData



@doc """

    writeVectorData(dataID::Integer, valueIndex::Integer, dataValue::AbstractArray{Float64})

Write vectorial floating-point data to a vertex. This function writes a value of a specified vertex to a dataID.
Values are provided as a block of continuous memory.

The 2D-format of value is a numpy array of shape 2

The 3D-format of value is a numpy array of shape 3

# Arguments
- `dataID::Integer`: ID of the data to be written. Obtained by getDataID().
- `valueIndex::Integer`: Index of the vertex. 
- `dataValue::AbstractArray{Float64}`: The array holding the values.

# Notes
        
Previous calls:
 - Count of available elements at value matches the configured dimension
 - [`initialize`](@initialize) has been called

Examples:

Write vector data for a 2D problem with 5 vertices:
```jldoctest
julia> data_id = 1
julia> vertex_id = 5
julia> value = [v5_x, v5_y]
julia> write_vector_data(data_id, vertex_id, value)
```

Write vector data for a 3D (D=3) problem with 5 (N=5) vertices:
```jldoctest
julia> data_id = 1
julia> vertex_id = 5
julia> value = [v5_x, v5_y, v5_z]
julia> write_vector_data(data_id, vertex_id, value)
```
"""
writeVectorData



@doc """

    writeBlockScalarData(dataID::Integer, size::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})

Write scalar data given as block.

This function writes values of specified vertices to a dataID. Values are provided as a block of continuous memory. valueIndices contains the indices of the vertices

# Arguments
- `dataID::Integer`: ID of the data to be written. Obtained by getDataID().
- `size::Integer`: 	Number n of vertices. 
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices.
- `values::AbstractArray{Float64}`: The array holding the values.
    

"""
writeBlockScalarData



@doc """

    writeScalarData(dataID::Integer, valueIndex::Integer, dataValue::Float64)

Write scalar data, the value of a specified vertex to a dataID.

# Arguments
- `dataID::Integer`: ID of the data to be written. Obtained by getDataID().
- `valueIndex::AbstractArray{Cint}`: Indicex of the vertex.
- `value::Float64`: The value to write.

"""
writeScalarData



@doc """

    readBlockVectorData(dataID::Integer, size::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})

Read vector data values given as block.

The block contains the vector values in the following form:
values = (d0x, d0y, d0z, d1x, d1y, d1z, ...., dnx, dny, dnz), where n is 
the number of vector values. In 2D, the z-components are removed.

# Arguments
- `dataID::Integer`: ID of the data to be read.
- `size::Integer`: 	Number n of vertices. 
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices.
- `values::AbstractArray{Float64}`: Array where read values are written to.

"""
readBlockVectorData




@doc """

    readVectorData(dataID::Integer, valueIndex::Integer, dataValue::AbstractArray{Float64})

Read vector data form a vertex.

Read a value of a specified vertex from a dataID. Values are provided as a block of continuous memory.

# Arguments
- `dataID::Integer`: ID of the data to be read.
- `valueIndex::AbstractArray{Cint}`: Indicex of the vertex.
- `values::AbstractArray{Float64}`: Array where read values are written to.

"""
readVectorData



@doc """

    readBlockScalarData(dataID::Integer, size::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})

Read scalar data as a block, values of specified vertices from a dataID. Values are provided as a block of continuous memory. valueIndices contains the indices of the vertices.

# Arguments
- `dataID::Integer`: ID of the data to be read.
- `size::Integer`: 	Number n of vertices. 
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices.
- `values::AbstractArray{Float64}`: Array where read values are written to.
"""
readBlockScalarData



@doc """

    readScalarData(dataID::Integer, valueIndex::Integer, dataValue::AbstractArray{Float64})

Read scalar data of a vertex.

# Arguments
- `dataID::Integer`: ID of the data to be read.
- `valueIndex::AbstractArray{Cint}`: Indicex of the vertex.
- `values::AbstractArray{Float64}`: Array where read value is written to.

"""
readScalarData



@doc """

    getVersionInformation()

Return a semicolon-separated String containing: 
 - the version of preCICE
 - the revision information of preCICE
 - the configuration of preCICE including MPI, PETSC, PYTHON
"""
getVersionInformation




@doc """

    mapReadDataTo(fromMeshID::Integer)

Compute and map all write data mapped from mesh with given ID.

"""
mapWriteDataFrom



@doc """

    mapReadDataTo(fromMeshID::Integer)

Compute and map all read data mapped to mesh with given ID.
"""
mapReadDataTo



@doc """

    actionWriteInitialData()

Return the name of action for writing initial data.

"""
actionWriteInitialData




@doc """

    actionWriteIterationCheckpoint()

Return name of action for writing iteration checkpoint.
"""
actionWriteIterationCheckpoint




@doc """

    actionReadIterationCheckpoint()

Return name of action for reading iteration checkpoint
"""
actionReadIterationCheckpoint

