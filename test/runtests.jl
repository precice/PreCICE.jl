using PreCICE
using Test


libprecicePath = split(readlines(`whereis libprecice`)[], ' ')[2]

PreCICE.setPathToLibprecice(string(libprecicePath))



@testset "PreCICE.jl" begin
    
    @testset "Low-Level-API" begin
        include("low-level-api.jl")
        @test test_binary_location_found() == nothing
    end

    @testset "Solverdummies" begin
        
    end
end



