using PreCICE
using Test


@doc """
    test_binary_location_found()

Tests whether Julia is able to locate the PreCICE shared object library.
"""
function test_binary_location_found()
    try
        PreCICE.getVersionInformation()
    catch err    
            return err
    end
    return nothing
end

