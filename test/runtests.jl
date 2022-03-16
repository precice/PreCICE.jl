using PreCICE
using Test


@testset "PreCICE.jl" begin
    
    @testset "Low-Level-API" begin
        include("low-level-api.jl")
        @test isnothing(test_binary_location_found())
    end

    @testset "Solverdummies" begin
        include("test_solverdummy.jl")
        @test isnothing(test_solverdummy())
    end
end



