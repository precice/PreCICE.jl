# PreCICE.jl

<a style="text-decoration: none" href="https://github.com/precice/julia-bindings/blob/main/LICENSE" target="_blank">
    <img src="https://img.shields.io/github/license/precice/julia-bindings.svg" alt="GNU GPL license">
</a>

This package provides Julia language bindings for the C++ library [preCICE](https://github.com/precice/precice). It is a Julia package that wraps the API of preCICE.

Note that the first two digits of the version number of the bindings indicate the preCICE major and minor version that the bindings support. The last digit represents the version of the bindings. Example: `v2.5.1` and `v2.5.2` of the bindings represent versions `1` and `2` of the bindings that are compatible with preCICE `v2.5.0`.

Technical information about the initial design of these bindings can be found in the [Bachelor thesis of Pavel Kharitenko](http://dx.doi.org/10.18419/opus-11836).

## Adding and using the package

The Julia bindings for preCICE can be used by either by adding them as a package in a Julia environment or also directly including the package in a Julia script. For both type of usages preCICE needs to be installed on the system. For preCICE installation, have a look at the [installation documentation](https://precice.org/installation-overview.html).

### Adding the package

Add the Julia bindings to the Julia environment in the following way:

```julia
julia> ]
pkg> add PreCICE 
Then exit the package mode with 🔙 or Ctrl + c
julia> using PreCICE
```

Alternatively you can also include the package in a Julia script in the following way:

```julia
import Pkg; Pkg.add("PreCICE")
using PreCICE
```

### Adding the package from a local folder

If you have cloned or downloaded the Julia bindings on your local machine, add the Julia bindings to your Julia environment in the following way:

```julia-repl
julia> ]
pkg> add <path-to-repository>
Then exit the package mode with 🔙 or Ctrl + c
julia> using PreCICE
```

Alternatively, you can install a specific branch of this repository with the following command:

```julia-repl
pkg> add https://github.com/precice/PreCICE.jl#<branch-name>
```

## Troubleshooting

### Custom preCICE installation path

If preCICE is installed at a custom path, errors of the form ```ERROR: could not load library "/..."``` can occur after adding the Julia bindings package. Make sure the preCICE library is in the system library path through `echo $LD_LIBRARY_PATH` and otherwise update the variable with the correct path.

```bash
~$ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:<path-to-precice.so>
```

A different way to fix this error is to set the custom path of the preCICE installation through the environment variable `PRECICE_JL_BINARY`. Afterwards you need to rebuild this package:

```julia-repl
~$ export PRECICE_JL_BINARY=/usr/lib/x86_64-linux-gnu/
~$ julia (--project)
julia> ]
pkg> build PreCICE
julia> using PreCICE
...
```

### Incompatible version of libstdc++

If you get an error message like:

```julia-repl
ERROR: LoadError: could not load library "libprecice"
/usr/bin/../lib/libstdc++.so.6: version `GLIBCXX_3.4.30' not found (required by /usr/local/lib/libprecice.so)
```

It is caused by an incompatible version of `libstdc++` as described [in the issue](https://github.com/precice/PreCICE.jl/issues/44#issuecomment-1259655654). Julia ships its own libraries, which are older than the ones shipped by the system or the ones used to compile preCICE.

As a first solution, consider updating your julia version. The versions used in Julia are fairly up to date and should work with older systems. The problem is also known to the developers of Julia and they are [working on a solution](https://github.com/JuliaGL/GLFW.jl/issues/198). From Julia `v1.8.3` on, the problem [should be fixed](https://github.com/JuliaLang/julia/pull/46976).

If you cannot update your julia version, or the problem persists, you can try preloading the system `libstdc++`:

<details>
<summary>Click to expand</summary>

Preload the system `libstdc++` with

```bash
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 julia
```

You may have to [compile preCICE from source](https://precice.org/installation-source-preparation.html) for this to work.

On newer systems, preloading only the system `libstdc++` may not be sufficient. Errors of the form

```julia-repl
ERROR: ERROR: LoadError: LoadError: could not load library "libprecice"
/path/to/julia-1.8.1/bin/../lib/julia/libcurl.so: version `CURL_OPENSSL_4' not found (required by /lib/x86_64-linux-gnu/libhdf5_openmpi.so.103)could not load library "libprecice"
/path/to/julia-1.8.1/bin/../lib/julia/libcurl.so: version `CURL_OPENSSL_4' not found (required by /lib/x86_64-linux-gnu/libhdf5_openmpi.so.103)
```

can be resolved by preloading the system `libcurl`:

```bash
LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6:/usr/lib/x86_64-linux-gnu/libcurl.so.4" julia
```

Again, you may have to [compile preCICE from source](https://precice.org/installation-source-preparation.html).

Adding the following lines to your `~/.bashrc` will help to avoid this error in the future:

```bash
alias julia='LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6:/usr/lib/x86_64-linux-gnu/libcurl.so.4" julia'
```

You could instead move the julia libraries out of the way and create a symlink to the system libraries:

```bash
mv /path/to/julia/lib/julia/libstdc++.so.6 /path/to/julia/lib/julia/libstdc++.so.6.bak
ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /path/to/julia/lib/julia/libstdc++.so.6
```

If the above approaches do not work, you may have to [compile preCICE from source](https://precice.org/installation-source-preparation.html) using the version of `libstdc++` that is shipped with Julia.
</details>

## Usage

The [solverdummy](https://github.com/precice/julia-bindings/tree/main/solverdummy) shows an example of how to use the Julia bindings for preCICE.

## Testing PreCICE.jl

To test the bindings, run:

```julia-repl
julia> ]
pkg> test PreCICE
```

This checks if the preCICE bindings can be found and accessed correctly.
You can also test the full functionality of PreCICE.jl. If not set up, the output of the previous test shows an info on what command you need to execute. It will be along the lines of:

```bash
cd /home/<user>/.julia/packages/PreCICE/<code>/test && make
```

After this, you can run the tests again, resulting individual 22 tests being executed.

## Dependencies

This package works with official Julia binaries listed below. See the [Platform Specific Instructions for official Binaries](https://julialang.org/downloads/platform/)  or [Julia's documentation](https://docs.julialang.org/en/v1/manual/getting-started/) if you are not sure how to download them.

## Supported versions

The package is actively tested for Julia versions `1.8.0`, `1.9.0`, and `1.10.0`. Julia versions prior to `1.6.0` are not supported.

[Unofficial Julia binaries](https://julialang.org/downloads/platform/#platform_specific_instructions_for_unofficial_binaries) may not be compatible.
