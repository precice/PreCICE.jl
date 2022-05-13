using PreCICE
using Test


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
        println(dirname(abspath(PROGRAM_FILE)) ∉ Libc.Libdl.DL_LOAD_PATH)
        println(Libc.Libdl.DL_LOAD_PATH)
        if dirname(abspath(PROGRAM_FILE)) ∉ Libc.Libdl.DL_LOAD_PATH
            error("""Please run:
        ` cd $(dirname(abspath(PROGRAM_FILE))) && make && julia
        push!(Libc.Libdl.DL_LOAD_PATH, "$(dirname(abspath(PROGRAM_FILE)))") `
        And then test PreCICE again
        """)
        end
        println("Make sure you ran `make` in $(dirname(abspath(PROGRAM_FILE))))")
        push!(Libc.Libdl.DL_LOAD_PATH, dirname(abspath(PROGRAM_FILE)))
        # add fake libprecice.so into load path
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

        # pop!(Libc.Libdl.DL_LOAD_PATH)
    end

end
