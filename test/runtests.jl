using PreCICE
using Test


push!(Libc.Libdl.DL_LOAD_PATH, dirname(abspath(PROGRAM_FILE)))
@testset "PreCICE.jl" begin

    @testset "Build" begin
        include("test_build.jl")
        @test isnothing(test_binary_location_found())
    end

    @testset "Solverdummies" begin
        include("test_solverdummy.jl")
        println(test_solverdummy())
        @test isnothing(test_solverdummy())
    end

    @testset "Function calls" begin
        if !isfile(joinpath(dirname(abspath(PROGRAM_FILE)), "libprecice.so"))
            @info("""
            To run the function tests, please run:
            ``` 
            cd $(dirname(abspath(PROGRAM_FILE))) && make
            ```
            And then test PreCICE again
            """)
        else
            include("test_functioncalls.jl")
            @test constructor()
            @test version()
            @test getDimensions()
            @test getMeshId()
            @test setMeshVertices()
            # @test setMeshVerticesEmpty()
            @test setMeshVertex()
            @test setMeshVertexEmpty()
            @test getMeshVertexIDsFromPositions()
            @test getMeshVertexSize()
            @test getMeshVertices()
            @test readWriteBlockScalarData()
            @test readWriteBlockScalarDataEmpty()
            @test readWriteScalarData()
            @test readWriteBlockVectorData()
            # @test readWriteBlockVectorDataEmpty()
            @test readWriteVectorData()
            @test getDataID()
            @test getVersionInformation()
            @test actionWriteInitialData()
            @test actionWriteIterationCheckpoint()
            @test actionReadIterationCheckpoint()
            @test isGradientDataRequired()
            @test writeBlockScalarGradientData()
            @test writeScalarGradientData()
            @test writeBlockVectorGradientData()
            @test writeVectorGradientData()
        end #if
    end # testset

end
pop!(Libc.Libdl.DL_LOAD_PATH)
