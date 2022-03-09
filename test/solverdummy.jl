using PreCICE

function test_solverdummy()
    try
        # run two seperate instances of the solverdummy
        path = "$(Sys.BINDIR)/julia"
        t=@task begin; run(`$path ../solverdummy/solverdummy.jl ../solverdummy/precice-config.xml SolverOne  MeshOne`);end;
        s=@task begin; run(`$path ../solverdummy/solverdummy.jl ../solverdummy/precice-config.xml SolverTwo  MeshTwo`);end;
        schedule(t)
        schedule(s)
        wait(t)
        wait(s)

        # cleanup
        rm("precice-run/",recursive=true)
        files = readdir()
        for file in files
            if (endswith(file, "json") || endswith(file,"log"))
                rm(file)
            end
        end

    catch err    
            return err
    end
    return nothing
end