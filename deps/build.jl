
# using PreCICE

# libprecicePath = split(readlines(`whereis libprecice`)[], ' ')[2]
# @info "will use PreCICE library at: $libprecicePath"
# PreCICE.setPathToLibprecice(string(libprecicePath))
# @info PreCICE.libprecicePath


# TODO check if environmental variable is set and is a real path, if not throw error
if haskey(ENV, "PRECICE_JL_BINARY")
    libprecicePath = ENV["PRECICE_JL_BINARY"]
    @info("detected custom preCICE binary configuration: $libprecicePath")
    libprecice = joinpath(libprecicePath, "libprecice.so")
    try
        Libc.Libdl.dlopen(libprecice)
        push!(Libc.Libdl.DL_LOAD_PATH, libprecice)
    catch e 
        @warn "could not load custom preCICE binary at location: $libprecice"
        @warn "will search the system locations for a valid library."
        throw(e)
    end
    
end
