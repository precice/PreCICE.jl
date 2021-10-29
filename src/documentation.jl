# Documentation of PreCICE.jl API functions
# for extending this documentation follow the guidelines at https://docs.julialang.org/en/v1/manual/documentation/


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
```julia
createSolverInterface("SolverOne", "./precice-config.xml", 0, 1)
```
"""
createSolverInterface



@doc """

"""
createSolverInterfaceWithCommunicator



@doc """

    initialize()::Float64

Initiate the coupling to the coupling supervisor. Return the maximal length of first timestep to be computed by solver.

"""
initialize



@doc """

    initializeData()

Initializes coupling data.

"""
initializeData



@doc """
    
    advance(computedTimestepLength::Float64)::Float64

Exchange data between solver and coupling supervisor. Return maximal length of next timestep to be computed by solver.

# Arguments
- `computedTimestepLength::Float64`: Length of timestep computed by solver.
"""
advance



@doc """

    finalize()

Finalize the coupling to the coupling supervisor.
"""
finalize



@doc """

    getDimensions()::Integer

Return the number of spatial configurations for the coupling.
"""
getDimensions



@doc """

    isCouplingOngoing()::Bool

Return true if the coupled simulation is ongoing.
"""
isCouplingOngoing



@doc """

    isTimeWindowComplete()::Bool

Return true if new data to read is available.
"""
isTimeWindowComplete



@doc """

    hasToEvaluateSurrogateModel()::Bool

Return whether the solver has to evaluate the surrogate model representation.
"""
hasToEvaluateSurrogateModel



@doc """

    hasToEvaluateFineModel()::Bool

Return whether the solver has to evaluate the fine model representation.
"""
hasToEvaluateFineModel



@doc """

    isReadDataAvailable()::Bool

Return true if new data to read is available.
"""
isReadDataAvailable



@doc """

    isWriteDataRequired(computedTimestepLength::Float64)::Bool

Check if new data has to be written before calling advance().
"""
isWriteDataRequired



@doc """

    isActionRequired(action::String)::Bool

Check if the provided action is required. Takes the name of the action.
"""
isActionRequired



@doc """

    markActionFulfilled(action::String)

Indicate preCICE that a required action has been fulfilled by a solver. Takes the name of the action.
"""
markActionFulfilled



@doc """

    hasMesh(meshName::String)::Bool

Check if the mesh with given name is used by a solver.

"""
hasMesh



@doc """

    getMeshID(meshName::String)

Return id belonging to the given mesh name
"""
getMeshID



@doc """

    hasData(dataName::String, meshID::Integer)::Bool

Check if the data with given name is used by a solver and mesh. 
"""
hasData



@doc """

    getDataID(dataName::String, meshID::Integer)

Return the data id belonging to the given name.

The given name (dataName) has to be one of the names specified in the configuration file. The data id obtained can be used to read and write data to and from the coupling mesh.

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

# Examples
```jldoctest
julia> v1_id = setMeshVertex(mesh_id, [1,1,1])
```

"""
setMeshVertex



@doc """

    getMeshVertices(meshID::Integer, size::Integer, ids::AbstractArray{Cint}, positions::AbstractArray{Float64})

Get vertex positions for multiple vertex ids from a given mesh.

# Arguments
- `meshID::Integer, size::Integerr`:  The id of the mesh to read the vertices from.
- `size::Integer`:  Number of vertices to lookup.
- `ids::AbstractArray{Cint}`:  The id of the mesh to read the vertices from.
- `positions::AbstractArray{Float64}`:  Positions to write the coordinates to.
                                        The 2D-format is (d0x, d0y, d1x, d1y, ..., dnx, dny),
                                        the 3D-format is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz).

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

# Arguments
- `meshID::Integer`: ID of the mesh to retrieve positions from.
- `size::Integer`: Number of vertices to lookup.
- `positions::AbstractArray{Float64}`: Positions to find ids for.
                                       The 2D-format is (d0x, d0y, d1x, d1y, ..., dnx, dny),
                                       the 3D-format is (d0x, d0y, d0z, d1x, d1y, d1z, ..., dnx, dny, dnz).
- `ids::AbstractArray{Cint}`: IDs corresponding to positions.
"""
getMeshVertexIDsFromPositions



@doc """

    setMeshEdge(meshID::Integer, firstVertexID::Integer, secondVertexID::Integer)::Integer

Set mesh edge from vertex IDs, return edge ID.

# Arguments
- `meshID::Integer`: ID of the mesh to add the edge to.
- `firstVertexID::Integer`: ID of the first vertex of the edge.
- `secondVertexID::Integer`: ID of the second vertex of the edge.

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


"""
setMeshTriangle



@doc """

    setMeshTriangleWithEdges(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer)

Set a triangle from vertex IDs. Create missing edges.

# Arguments
- `meshID::Integer`: ID of the mesh to add the edge to.
- `firstVertexID::Integer`: ID of the first vertex of the edge.
- `secondVertexID::Integer`: ID of the second vertex of the edge.
- `thirdEdgeID::Integer`: ID of the third edge of the triangle.
"""
setMeshTriangleWithEdges



@doc """

    setMeshQuad(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID, fourthEdgeID::Integer)

Set mesh Quad from edge IDs.

# Arguments
- `meshID::Integer`: ID of the mesh to add the Quad to.
- `firstVertexID::Integer`: ID of the first edge of the Quad.
- `secondVertexID::Integer`: ID of the second edge of the Quad.
- `thirdEdgeID::Integer`: ID of the third edge of the Quad.
- `fourthEdgeID::Integer`: ID of the fourth edge of the Quad.
"""
setMeshQuad



@doc """

    setMeshQuadWithEdges(meshID::Integer, firstEdgeID::Integer, secondEdgeID::Integer, thirdEdgeID::Integer)

Set surface mesh quadrangle from vertex IDs.

# Arguments
- `meshID::Integer`: ID of the mesh to add the Quad to.
- `firstVertexID::Integer`: ID of the first edge of the Quad.
- `secondVertexID::Integer`: ID of the second edge of the Quad.
- `thirdEdgeID::Integer`: ID of the third edge of the Quad.
- `fourthEdgeID::Integer`: ID of the fourth edge of the Quad.
"""
setMeshQuadWithEdges



@doc """

    writeBlockVectorData(dataID::Integer, size::Integer, valueIndices::AbstractArray{Cint}, values::AbstractArray{Float64})

Write vector data values given as block.

The block must contain the vector values in the following form: 

values = (d0x, d0y, d0z, d1x, d1y, d1z, ...., dnx, dny, dnz), where n is the number of vector values. In 2D, the z-components are removed.

# Arguments
- `dataID::Integer`: ID of the data to be written.
- `size::Integer`: Number n of vertices. 
- `valueIndices::AbstractArray{Cint}`: Indices of the vertices. 
- `values::AbstractArray{Float64}`: Values of the data to be written.

"""
writeBlockVectorData



@doc """

    writeVectorData(dataID::Integer, valueIndex::Integer, dataValue::AbstractArray{Float64})

Write vectorial floating-point data to the coupling mesh.

# Arguments
- `dataID::Integer`: ID of the data to be written. Obtained by getDataID().
- `valueIndex::Integer`: Index of the vertex. 
- `dataValue::AbstractArray{Float64}`: The array holding the values.

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

