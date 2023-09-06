### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 80266caa-6066-11ed-0d4e-a3b81a95bc95
begin
	using PlutoUI
	using PlutoTeachingTools
end

# ╔═╡ fc5c6cb2-4d06-4922-90ca-553c562a6e16
TableOfContents()

# ╔═╡ 9604dcf7-b58e-4af5-9ecd-5bd3199c785d
html"<button onclick=present()>Present</button>"

# ╔═╡ be066ed7-7bd5-4d46-ae2c-4fca40f1cffb
md"""
# Becoming a Julia developer
"""

# ╔═╡ e1812064-2ef0-46a7-976e-f51c51e72985
md"""
# 1. Good coding practices
"""

# ╔═╡ 25513b52-d96c-407a-a8a8-746b74eba72b
md"""
## Julia installation
"""

# ╔═╡ 6deb699e-c063-4af5-a67b-8d89397915b3
md"""
To install Julia, you can [download](https://julialang.org/downloads/) the latest release and follow the [installation instructions](https://julialang.org/downloads/platform/) specific to your platform, but that is not ideal.
If you go down that road, you will have to reinstall it anew for every release (for instance when the version is bumped from 1.8.2 to 1.8.3).
Plus the path manipulations are slightly cumbersome.

That is why we recommend you use [juliaup](https://github.com/JuliaLang/juliaup) instead, which will soon be the default installer.
It easily takes care of path management and updates without bothering the user.
Of course you should remove any trace of your previous Julia installation before switching to juliaup. 
"""

# ╔═╡ 4be9d59e-6e03-43ee-aeb2-5dc2553f9010
md"""
## Editor
"""

# ╔═╡ febfd7d3-622b-459e-985b-f8ede456673d
md"""
To write code comfortably, you need an Integrated Development Environment (IDE).
We strongly recommend you download [Visual Studio Code](https://code.visualstudio.com/) with the [Julia extension](https://marketplace.visualstudio.com/items?itemName=julialang.language-julia).
There are plenty of other extensions, and you will find one for whatever language you want to use (like [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python) or [LaTeX](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop)).
If you don't like Microsoft products, try [VSCodium](https://vscodium.com/) instead.

Note that other IDEs also have [Julia support](https://github.com/JuliaEditorSupport).
"""

# ╔═╡ 2b6a911b-c33b-4ca6-9ead-767b507ee708
md"""
## Code storage
"""

# ╔═╡ ccf7a7fa-ba31-48e3-9c40-f5e4aa8b8509
md"""
To write a complete Julia package, version control is essential.
When developing ambitious projects, you want to be able to reverse some changes or go back to an earlier idea that worked well.

[Git](https://git-scm.com/) is a cross-platform software that allows you to save various versions of your code.
[GitHub](https://github.com/) is a website that allows you to store and collaborate on your code.
If you're unfamiliar with these tools, the following [tutorial for beginners](https://product.hubspot.com/blog/git-and-github-tutorial-for-beginners) tells you all you need to know.
This [quick recap](https://up1.github.io/git-guide/index.html) is also very handy.
As a student, you are entitled to the [GitHub Student Developer pack](https://education.github.com/pack), which boasts lots of benefits for computer science courses.
"""

# ╔═╡ 0befc3d1-972d-4467-8f86-eafeb80b6754
md"""
## Package manager
"""

# ╔═╡ 0d7f1cd6-5b95-407f-ae07-8fe6265d4cdc
md"""
Unlike Python, the Julia language comes bundled with its own package and environment manager: [Pkg.jl](https://github.com/JuliaLang/Pkg.jl).
It can be accessed in the REPL by typing `]`.
Like conda for Python, it allows you to create individual environments for each of your projects, and add a particular set of dependencies to each one.
Before you start, please read sections 2 through 5 of the [Pkg.jl documentation](https://pkgdocs.julialang.org/v1/).
"""

# ╔═╡ ef9ca651-e823-4ca6-845a-a0588f79f940
md"""
## Default environment
"""

# ╔═╡ 9fe6028a-44ae-4b22-9b51-4100e23671fb
md"""
One thing to keep in mind is that packages installed into your default environment (called `@v1.8` and located at `~/.julia/environments/v1.8`) are accessible in every other environment.
That is why `@v1.8` be curated carefully, filled only with lightweight packages that are often useful.
Here is a good starting selection:
- [Aqua.jl](https://github.com/JuliaTesting/Aqua.jl): check code quality
- [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl): measure time and memory performance
- [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl): generate documentation
- [JET.jl](https://github.com/aviatesk/JET.jl): advanced debugger and performance diagnosis tool
- [JuliaFormatter.jl](https://github.com/domluna/JuliaFormatter.jl): clean up source code in a configurable way
- [OhMyREPL.jl](https://github.com/KristofferC/OhMyREPL.jl): put some color in your REPL
- [PackageCompatUI.jl](https://github.com/GunnarFarneback/PackageCompatUI.jl): browse and define compatibility requirements
- [Revise.jl](https://github.com/timholy/Revise.jl): incorporate source changes without restarting the REPL
- [TestEnv.jl](https://github.com/JuliaTesting/TestEnv.jl): activate the test environment of a package

You probably want to add the following lines to your `.julia/config/startup.jl` file, to load these packages whenever Julia starts:
```julia
using Revise
using OhMyREPL
```
"""

# ╔═╡ 7f36a436-1bd6-4b10-8df8-524724966da1
md"""
## Troubleshooting
"""

# ╔═╡ 4ec033b5-d9b1-4b65-9085-30666bd72d0a
md"""
Here are a few useful reflexes to keep in mind:
- a quick Google search will solve 95% of your problems
- the help mode (`?` in the REPL or Pluto) and this [cheat sheet](https://cheatsheet.juliadocs.org/) will solve 4% 
- for the last 1%, don't hesitate to [ask for help](https://julialang.org/about/help/)
"""

# ╔═╡ 9697d7af-b78a-42f1-b562-b0dff837bb1b
md"""
# 2. Your first package
"""

# ╔═╡ 5d4122b4-8795-49fc-b282-d064ab4ae5b5
md"""
## Git(Hub) boilerplate
"""

# ╔═╡ f2d70b0c-3fdd-483c-9e15-506d90f380b5
md"""
For the rest of this section, we assume that you have created a GitHub account, and gone through the following very short GitHub tutorials:
1. [Hello World](https://docs.github.com/en/get-started/quickstart/hello-world)
2. [Set up Git](https://docs.github.com/en/get-started/quickstart/set-up-git)

To get started on a Julia package, create a public repository on your GitHub account.
The following instructions are given with my own GitHub user name (`gdalle`) and an arbitrary repository name (`MyJuliaPackage.jl`).
"""

# ╔═╡ cbbe4adb-7c40-4675-8b8f-e69a771621d9
md"""
## Package structure
"""

# ╔═╡ c9fece4b-ac3e-4cb0-b83d-4c2603040047
md"""
[PkgTemplates.jl](https://github.com/JuliaCI/PkgTemplates.jl) enables you to initialize packages in a standardized way.
Open a Julia REPL in the parent folder where you want your package to appear, then run these commands.
```julia
julia> using PkgTemplates

julia> template = Template(interactive = true)
```
You will be presented with several questions.
Here is our recommendation of boxes to tick (check out the [PkgTemplates.jl documentation](https://juliaci.github.io/PkgTemplates.jl/stable/) for details on each plugin).
The three dots `...` mean that you shouldn't customize anything (leave the boxes blank).
"""

# ╔═╡ d55d4497-372a-4e3a-9587-07a560a5aad2
md"""
```
Template keywords to customize:
[press: d=done, a=all, n=none]
 > [X] user
   [X] authors
   [X] dir
   [X] host
   [X] julia
   [X] plugins
Enter value for 'user' (required): gdalle
Enter value for 'authors' (comma-delimited, default: Guillaume Dalle <99999999+gdalle@users.noreply.github.com> and contributors): 
Enter value for 'dir' (default: ~/.julia/dev): .
Select Git repository hosting service:
 > github.com
Select minimum Julia version:
 > 1.8
Select plugins:
[press: d=done, a=all, n=none]
   [ ] CompatHelper
   [X] ProjectFile
   [X] SrcDir
   [X] Git
   [X] License
   [X] Readme
   [X] Tests
   [ ] TagBot
   [ ] AppVeyor
   [ ] BlueStyleBadge
   [ ] CirrusCI
   [X] Citation
   [X] Codecov
   [ ] ColPracBadge
   [ ] Coveralls
   [ ] Develop
   [X] Documenter
   [ ] DroneCI
   [X] GitHubActions
   [ ] GitLabCI
   [ ] PkgEvalBadge
   [ ] RegisterAction
 > [ ] TravisCI
...
Documenter deploy style:
 > GitHubActions
...
```
"""

# ╔═╡ d38c9547-2545-439b-ba2c-0e6573e77776
md"""
Then, all you need to do is run
```julia
julia> template("MyJuliaPackage")
```
and a folder called `MyJuliaPackage` will appear in the current directory (which we decided by setting `dir` to `.` above).
If you did the setup correctly, it should automatically be linked to your GitHub repository `gdalle/MyJuliaPackage.jl`, and all you have to do is publish the new branch `main` to see everything appear online.
"""

# ╔═╡ 94b6676d-6a4f-406d-9595-edf5c659c305
md"""
## Continuous integration
"""

# ╔═╡ 7b8de8d7-36d3-477f-b4cc-ee6951c4fccd
md"""
PkgTemplates.jl is especially useful because it integrates with [GitHub Actions](https://docs.github.com/en/actions) to set up continuous integration (CI).
Basically, every time you push your code to the remote repository, a series of workflows will run automatically on the GitHub servers.
The results will be visible on the repository page, in the Actions tab.
Computation budget for CI workflows is unlimited for public repositories, but limited for private repositories.

Each workflow is defined by a YAML file located in the `.github/workflows` subfolder.
The most important ones are tests and documentation (see more below), both specified in `.github/workflows/CI.yml`.
"""

# ╔═╡ 245b7576-fb4f-4d1d-aa97-a5f23509ad88
md"""
## Code style
"""

# ╔═╡ f50e29d2-40ec-4316-91c5-eb1a99bea4f6
md"""
Julia has no universally agreed-upon style guide like Python.
A few official guidelines can be found [here](https://docs.julialang.org/en/v1/manual/style-guide/).
For an exhaustive style reference, have a look at the [BlueStyle](https://github.com/invenia/BlueStyle) by Invenia, or the new [SciMLStyle](https://github.com/SciML/SciMLStyle).

If you want to (partially) enforce a given style in your code, [JuliaFormatter.jl](https://github.com/domluna/JuliaFormatter.jl) can do that for you.
Just add a file called `.JuliaFormatter.toml` at the root of your package, and put a single line in it, for example
```
style = "blue"
```
Then JuliaFormatter.jl will be able to format all your files in the style that you chose, and the integrated formatting of VSCode will fall back on it for Julia files.
"""

# ╔═╡ c1ebe580-2d37-4de6-b2ff-d30d3a2e7bc9
md"""
## Documentation
"""

# ╔═╡ 4f9e4dab-6a23-43ff-a40a-376368089aba
md"""
Julia also has built-in support for [documentation](https://docs.julialang.org/en/v1/manual/documentation/), as you might have noticed when querying docstrings in the REPL.
Writing docstrings for your own functions is a good idea, not only for other users but also for yourself.

If you want to create a nice documentation website, [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl) is the way to go.
The configuration is given by the `docs/make.jl` file, and the page sources are stored in the folder `docs/src/`.
When you run `docs/make.jl`, the folder `docs/build` will be populated with the HTML files of the website (which are ignored by Git).
Check their [guide](https://documenter.juliadocs.org/stable/man/guide/) for details.

With our PkgTemplates.jl setup, a Documenter.jl website will be automatically generated and updated after every push.
It is stored on a separate branch to avoid cluttering your workspace with HTML files.
To make it accessible, all you need to do is activate GitHub pages (for the repository settings) and select the `gh-pages` branch as a build source.
"""

# ╔═╡ fa40ecc3-b877-467f-b33a-3c3e293907e9
md"""
## Tests
"""

# ╔═╡ 503e2eaf-3c93-4193-81ab-bb7d8a4facc8
md"""
Julia has built-in support for [unit testing](https://docs.julialang.org/en/v1/stdlib/Test/), which allows you to check that your code behaves in the way you expect.
Package tests are located in the `test/runtests.jl` file.

With our PkgTemplates.jl setup, tests are run automatically on each push.
"""

# ╔═╡ 45e6f619-d8f8-4cd8-a2da-1f06f2a83c40
md"""
Here is a typical `test/runtests.jl` file which performs a few automated checks in addition to your own handwritten ones.
It uses Aqua.jl, Documenter.jl and JuliaFormatter.jl in addition to the base module Test, which means all of these must be specified as [test dependencies](https://pkgdocs.julialang.org/v1/creating-packages/#Test-specific-dependencies-in-Julia-1.2-and-above).
"""

# ╔═╡ 0941a61e-529e-4633-aa69-c43e5648a572
md"""
```julia
using Aqua
using Documenter
using MyJuliaPackage
using JuliaFormatter
using Test

DocMeta.setdocmeta!(
	MyJuliaPackage,
	:DocTestSetup,
	:(using MyJuliaPackage);
	recursive=true
)

@testset verbose = true "MyJuliaPackage.jl" begin
    @testset verbose = true "Code quality (Aqua.jl)" begin
        Aqua.test_all(MyJuliaPackage; ambiguities=false)
    end

    @testset verbose = true "Code formatting (JuliaFormatter.jl)" begin
        @test format(MyJuliaPackage; verbose=true, overwrite=false)
    end

    @testset verbose = true "Doctests (Documenter.jl)" begin
        doctest(MyJuliaPackage)
    end

	@testset verbose = true "My own tests" begin
		@test 1 + 1 == 2
	end
end
```
"""

# ╔═╡ 8658cc4c-f121-4449-8c46-384deb72727b
md"""
You can also use `JET.report_package(MyJuliaPackage)` to look for possible errors, but I recommend doing it outside of the testing pipeline.
JET.jl is quite picky, including for things that don't matter much (like structs defined with `Base.@kwdef` or unassigned keyword arguments).
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoTeachingTools = "~0.2.5"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "a084e953ecc8d9d6d85465607b1a1d49f1e47fec"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "cc4bd91eba9cdbbb4df4746124c22c0832a460d6"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.1.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0f960b1404abb0b244c1ece579a0ec78d056a5d1"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.15"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "dedbebe234e06e1ddad435f5c6f4b85cd8ce55f7"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.2.2"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "cceb0257b662528ecdf0b4b4302eb00e767b38e7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "0e8bcc235ec8367a8e9648d48325ff00e4b0a545"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.5"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "ea3e4ac2e49e3438815f8946fa7673b658e35bdb"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.5"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "dad726963ecea2d8a81e26286f625aee09a91b7c"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.4.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═80266caa-6066-11ed-0d4e-a3b81a95bc95
# ╠═fc5c6cb2-4d06-4922-90ca-553c562a6e16
# ╟─9604dcf7-b58e-4af5-9ecd-5bd3199c785d
# ╟─be066ed7-7bd5-4d46-ae2c-4fca40f1cffb
# ╟─e1812064-2ef0-46a7-976e-f51c51e72985
# ╟─25513b52-d96c-407a-a8a8-746b74eba72b
# ╟─6deb699e-c063-4af5-a67b-8d89397915b3
# ╟─4be9d59e-6e03-43ee-aeb2-5dc2553f9010
# ╟─febfd7d3-622b-459e-985b-f8ede456673d
# ╟─2b6a911b-c33b-4ca6-9ead-767b507ee708
# ╟─ccf7a7fa-ba31-48e3-9c40-f5e4aa8b8509
# ╟─0befc3d1-972d-4467-8f86-eafeb80b6754
# ╟─0d7f1cd6-5b95-407f-ae07-8fe6265d4cdc
# ╟─ef9ca651-e823-4ca6-845a-a0588f79f940
# ╟─9fe6028a-44ae-4b22-9b51-4100e23671fb
# ╟─7f36a436-1bd6-4b10-8df8-524724966da1
# ╟─4ec033b5-d9b1-4b65-9085-30666bd72d0a
# ╟─9697d7af-b78a-42f1-b562-b0dff837bb1b
# ╟─5d4122b4-8795-49fc-b282-d064ab4ae5b5
# ╟─f2d70b0c-3fdd-483c-9e15-506d90f380b5
# ╟─cbbe4adb-7c40-4675-8b8f-e69a771621d9
# ╟─c9fece4b-ac3e-4cb0-b83d-4c2603040047
# ╟─d55d4497-372a-4e3a-9587-07a560a5aad2
# ╟─d38c9547-2545-439b-ba2c-0e6573e77776
# ╟─94b6676d-6a4f-406d-9595-edf5c659c305
# ╟─7b8de8d7-36d3-477f-b4cc-ee6951c4fccd
# ╟─245b7576-fb4f-4d1d-aa97-a5f23509ad88
# ╟─f50e29d2-40ec-4316-91c5-eb1a99bea4f6
# ╟─c1ebe580-2d37-4de6-b2ff-d30d3a2e7bc9
# ╟─4f9e4dab-6a23-43ff-a40a-376368089aba
# ╟─fa40ecc3-b877-467f-b33a-3c3e293907e9
# ╟─503e2eaf-3c93-4193-81ab-bb7d8a4facc8
# ╟─45e6f619-d8f8-4cd8-a2da-1f06f2a83c40
# ╟─0941a61e-529e-4633-aa69-c43e5648a572
# ╟─8658cc4c-f121-4449-8c46-384deb72727b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
