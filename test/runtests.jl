using PreCICE
using Test


@testset "PreCICE.jl" begin

    @testset "Build" begin
        include("test_build.jl")
        @test isnothing(test_binary_location_found())
    end

    @testset "Function calls" begin
        # add fake libprecice.so into load path
        # TODO: if tested with `test PreCICE` the PROGRAM_FILE is ""
        push!(Libc.Libdl.DL_LOAD_PATH, dirname(PROGRAM_FILE))

        include("test_functioncalls.jl")
        @test constructor()
        @test version()
        @test getDimensions()
        @test getMeshId()
        @test setMeshVertices()
        @test setMeshVerticesEmpty()
        @test setMeshVertex()
        @test setMeshVertexEmpty()
        @test getMeshVertexIdsFromPositions()
        @test getMeshVertexSize()
        @test getMeshVertices()
        @test readWriteBlockScalarData()
        @test readWriteBlockScalarDataEmpty()
        @test readWriteScalarData()
        @test readWriteBlockVectorData()
        @test readWriteBlockVectorDataEmpty()
        @test readWriteVectorData()
        @test getDataId()
        @test getVersionInformation()
        @test actionWriteInitialData()
        @test actionWriteIterationCheckpoint()
        @test actionReadIterationCheckpoint()

        pop!(Libc.Libdl.DL_LOAD_PATH)
    end

    @testset "Solverdummies" begin
        include("test_solverdummy.jl")
        @test isnothing(test_solverdummy())
    end
end
