using PreCICE
using Test


push!(Libc.Libdl.DL_LOAD_PATH, dirname(abspath(PROGRAM_FILE)))
@testset "PreCICE.jl" begin

    @testset "Build" begin
        include("test_build.jl")
        @test isnothing(test_binary_location_found())
    end

    # @testset "Solverdummies" begin
    #     include("test_solverdummy.jl")
    #     println(test_solverdummy())
    #     @test isnothing(test_solverdummy())
    # end

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
            @test getMeshDimensions()
            @test getDataDimensions()
            @test isCouplingOngoing()
            @test isTimeWindowComplete()
            @test getMaxTimeStepSize()
            @test requiresInitialData()
            @test requiresWritingCheckpoint()
            @test requiresReadingCheckpoint()
            @test hasMesh()
            @test hasData()
            @test requiresMeshConnectivityFor()
            @test setMeshVertex()
            @test setMeshVertices()
            # @test setMeshVerticesEmpty()
            @test getMeshVertexSize()
            @test readWriteData()
            # @test readWriteDataEmpty()
            @test requiresGradientDataFor()
            @test writeGradientData()
            @test getVersionInformation()
            @test setMeshAccessRegion()
            @test getMeshVerticesAndIDs()
        end #if
    end # testset

end
pop!(Libc.Libdl.DL_LOAD_PATH)
