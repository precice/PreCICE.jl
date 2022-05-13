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
        @test isnothing(test_solverdummy())
    end

    @testset "Function calls" begin
        if dirname(abspath(PROGRAM_FILE)) ∉ Libc.Libdl.DL_LOAD_PATH
            println("""Please run:
            ``` 
            cd $(dirname(abspath(PROGRAM_FILE))) && make && julia
            push!(Libc.Libdl.DL_LOAD_PATH, "$(dirname(abspath(PROGRAM_FILE)))")
            ```
            And then test PreCICE again
            """)
            return
        end

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
    end

end
pop!(Libc.Libdl.DL_LOAD_PATH)
