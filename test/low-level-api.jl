using PreCICE
using Test



function test_binary_location_found()
    try
        PreCICE.getVersionInformation()
    catch err    
            return err
    end
    return nothing
end

