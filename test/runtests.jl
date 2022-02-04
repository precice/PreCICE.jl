using PreCICE
using Test


@testset "PreCICE.jl" begin
    
    @testset "Low-Level-API" begin
        include("low-level-api.jl")
        @test test_binary_location_found() == nothing
    end

    @testset "Solverdummies" begin
        
    end
end



