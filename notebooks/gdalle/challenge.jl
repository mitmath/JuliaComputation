### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 35580339-744e-422a-b474-47dda002390a
begin
	using PlutoTeachingTools
	using PlutoUI
end

# ╔═╡ fcc41a80-b44a-4eb8-ade6-13f075c5b72f
TableOfContents()

# ╔═╡ 51d9bad9-aebd-40bb-8682-688a57c876db
html"<button onclick=present()>Present</button>"

# ╔═╡ 633fc28a-6138-11ed-2bf2-9fc45fc9a926
md"""
# Optimization challenge
"""

# ╔═╡ 6fdbc050-ed89-48af-9b21-43aeb5bc103a
md"""
# 1. Overview
"""

# ╔═╡ bf76e4a9-8319-4aca-91fc-93d31952906f
md"""
## Street view routing
"""

# ╔═╡ 5b096f1a-b5b7-4db0-855a-de39ddb5ef4c
md"""
The problem we chose for you is taken from [Google Hash Code](https://codingcompetitions.withgoogle.com/hashcode), an annual team programming competition.
Its 2014 final round was about the routing of [Google Street View](https://www.google.com/streetview/) cars through Paris.
In a nutshell, the goal is to define itineraries that capture as much image data as possible within a limited time frame.
See the official [task description](https://storage.googleapis.com/coding-competitions.appspot.com/HC/2014/hashcode2014_final_task.pdf) and the [data file](https://storage.googleapis.com/coding-competitions.appspot.com/HC/2014/paris_54000.txt).
"""

# ╔═╡ e103f446-d3f9-432d-9fb6-dd0f67ee716b
md"""
We wrote a small package called [HashCode2014.jl](https://github.com/gdalle/HashCode2014.jl) to help you get started.
It is not available on the general registry, so to install it, you need to use the URL:
```julia
pkg> add https://github.com/gdalle/HashCode2014.jl
```
In addition to basic utilities, it includes a parser for text files, a very simple random walk algorithm, and a visualization function based on [folium](https://python-visualization.github.io/folium/).
Check out the [documentation](https://gdalle.github.io/HashCode2014.jl/dev/) for more details.
"""

# ╔═╡ ed66c4e6-17e8-4706-9cf4-56f4bc1d7b6c
md"""
## Problem statement
"""

# ╔═╡ 9a15943f-5dad-4043-b540-546d0fc2f025
md"""
Your task is to solve Hash Code 2014 by developing a Julia package.
This package should contain (at least) the following elements:
- New structs for storing problem instances and solutions (the ones from HashCode2014.jl are very dumb)
- Functions that check the feasibility and value of a solution
- One or more functions that compute a good solution
- One or more functions that compute an upper bound on the value of an optimal solution
- Unit tests that verify feasibility of your solutions and coherence of the bounds
- A documentation made with [Documenter.jl](https://github.com/gdalle/HashCode2014.jl)
"""

# ╔═╡ 5aea0b2d-c3da-4496-9a9f-2fbc31fecf19
md"""
The documentation will serve as a report.
It should not only contain function docstrings, but also present a mathematical description of your algorithms and a discussion of their performance, both in terms of solution quality and speed.

In this project, a major focus should be code efficiency.
Make use of all the tools that you have discovered in the class.
Don't be afraid to discuss the questions that you faced, and the answers that you found.
"""

# ╔═╡ 3eff3936-4713-43a8-b4c5-ac0245086fab
md"""
## Deliverable
"""

# ╔═╡ a7cd1bb9-44b3-44ce-bf2e-e3575ae73efe
md"""
Your deliverable for the challenge must be a _public_ GitHub repository containing your Julia package and its documentation.
We ask you to make it public because open source development produces code that is accessible, auditable and reusable by everyone.
In addition, GitHub offers many more services for public repositories than for private ones, and they're usually free of charge (one example being unlimited CI).
Finally, this will allow instructors to check in on your work regularly and give you advice if you need it.
"""

# ╔═╡ 3cc76524-62e7-4476-9a62-02ad93915172
md"""
## Tools
"""

# ╔═╡ 49ce7a51-815b-4d96-b217-e0bf65472828
md"""
As long as you write your code in Julia, you can use any package from the ecosystem.
We also allow the use of mathematical programming solvers, for instance through JuMP.jl, even when these solvers are not written in Julia.

In terms of hardware, you should run your code on your personal laptop, and not on an MIT cluster or on JuliaHub.
Multithreading is allowed, but GPU computing probably won't be necessary.
As is often the case in combinatorial optimization, the biggest differences come from clever algorithms and implementations, not from having a bigger computer.

As a rule of thumb, your entire code should never take more than one hour to run on your laptop, ideally less.
"""

# ╔═╡ b268179b-a2ea-481d-be0d-e1aed35d6a6c
md"""
# 2. Rules and advice
"""

# ╔═╡ cd6d305e-f5fb-46f7-abbc-3b175f42a325
md"""
## Teams
"""

# ╔═╡ 1e0f6c1a-694c-4802-91b2-45c67baa0305
md"""
This challenge can be tackled individually, or in teams of up to 3 students.
If you struggle to find teammates, you can check out this [Piazza post](https://piazza.com/class/l6xyasad2hl2z7/post/120).
"""

# ╔═╡ 648389db-8498-4848-b4aa-d3703facc2a7
md"""
## Leaderboard
"""

# ╔═╡ 0f2d2902-a4d9-4a25-96ac-685e6a1da5dd
md"""
To make this challenge more fun, we encourage teams to compete against each other.
We thus created a [Google Sheets](https://docs.google.com/spreadsheets/d/1aiFdtYymErgXhLLqcXC50fYtiBA16Gzb8NaxFVOqxPo/edit?usp=sharing) where you can enter your team information and your current best performance.
The computation time column is mostly intended for orders of magnitude: since you all have different hardware, precise comparison is impossible.

To verify solution values, we will set up another Canvas submission that you can keep updated with your best solution sofar.
The challenge instructions provide very clear guidelines to export this solution as a text file, and HashCode2014.jl has a function to do just that.
"""

# ╔═╡ cdb75786-4fc0-491f-bbd7-fdf59d36b668
md"""
## Ethics
"""

# ╔═╡ 6802a897-1be1-4d93-a432-b783ca648830
md"""
Since each team is expected to work in a public repository, plagiarism is technically possible, but we will not tolerate it.
If you draw inspiration from the work of others, we demand that you:
1. cite the source explicitly to separate their contributions
2. make their method better / faster in the process, and explain how you did it
"""

# ╔═╡ d3175bdd-74dd-4c83-8540-a32323580d67
md"""
## Grading
"""

# ╔═╡ d011f5a4-3d5d-4bba-af45-de15efac5f98
md"""
The grading rubric is not defined yet, but the following items will be taken into account:
- Code quality
- Clarity of the documentation
- Cleverness of the algorithms
- Efficiency considerations
- Actual performance and leaderboard ranking (for a small part)
"""

# ╔═╡ a71422ea-f656-4338-a943-3ecf3e8ecf61
md"""
## Deadlines
"""

# ╔═╡ 22701912-d47b-4baf-a97c-57d8d4a763be
md"""
| Date | Objective | Assignment | Consequences |
| --- | --- | --- | --- |
| Thursday 11/17 | Package initialized | Submit your team and repository URL | |
| Tuesday 11/22 | Package operational | Submit your first solution file | We will review your repository to give advice |
| Friday 12/09 | Package and documentation complete | Submit your final solution file | We will download and evaluate your repository |

All dates are to be understood as 11:59 PM
"""

# ╔═╡ 4ad8e4c2-080d-496f-8b54-8a55ebd23923
md"""
## Troubleshooting
"""

# ╔═╡ cf53067e-dfe4-42a3-b433-27ca7b3dbec8
md"""
We recommend you initialize your package with [PkgTemplates.jl](https://github.com/JuliaCI/PkgTemplates.jl), as discussed in the tutorial on good coding practices.
Before pushing, try running the tests and building the documentation locally.

**Ignoring files**

PkgTemplates.jl generates a file called `.gitignore`, which tells Git to avoid tracking certain files.
You will need to insert a line in this file containing `.CondaPkg`. When you add HashCode2014.jl as a dependency, some Python packages will be stored there, but you don't need to push them to GitHub.

**Testing**

You should copy the basic `runtests.jl` structure we suggested in the course on good programming practices.
While doing so, you might find that

- You need to set up additional test-specific dependencies (see the documentation for Pkg.jl to learn how)
- [Aqua.jl](https://github.com/JuliaTesting/Aqua.jl) is very picky on certain aspects. Read its documentation to understand why and how you can get the tests to pass.
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
# ╠═35580339-744e-422a-b474-47dda002390a
# ╠═fcc41a80-b44a-4eb8-ade6-13f075c5b72f
# ╟─51d9bad9-aebd-40bb-8682-688a57c876db
# ╟─633fc28a-6138-11ed-2bf2-9fc45fc9a926
# ╟─6fdbc050-ed89-48af-9b21-43aeb5bc103a
# ╟─bf76e4a9-8319-4aca-91fc-93d31952906f
# ╟─5b096f1a-b5b7-4db0-855a-de39ddb5ef4c
# ╟─e103f446-d3f9-432d-9fb6-dd0f67ee716b
# ╟─ed66c4e6-17e8-4706-9cf4-56f4bc1d7b6c
# ╟─9a15943f-5dad-4043-b540-546d0fc2f025
# ╟─5aea0b2d-c3da-4496-9a9f-2fbc31fecf19
# ╟─3eff3936-4713-43a8-b4c5-ac0245086fab
# ╟─a7cd1bb9-44b3-44ce-bf2e-e3575ae73efe
# ╟─3cc76524-62e7-4476-9a62-02ad93915172
# ╟─49ce7a51-815b-4d96-b217-e0bf65472828
# ╟─b268179b-a2ea-481d-be0d-e1aed35d6a6c
# ╟─cd6d305e-f5fb-46f7-abbc-3b175f42a325
# ╟─1e0f6c1a-694c-4802-91b2-45c67baa0305
# ╟─648389db-8498-4848-b4aa-d3703facc2a7
# ╟─0f2d2902-a4d9-4a25-96ac-685e6a1da5dd
# ╟─cdb75786-4fc0-491f-bbd7-fdf59d36b668
# ╟─6802a897-1be1-4d93-a432-b783ca648830
# ╟─d3175bdd-74dd-4c83-8540-a32323580d67
# ╟─d011f5a4-3d5d-4bba-af45-de15efac5f98
# ╟─a71422ea-f656-4338-a943-3ecf3e8ecf61
# ╟─22701912-d47b-4baf-a97c-57d8d4a763be
# ╟─4ad8e4c2-080d-496f-8b54-8a55ebd23923
# ╟─cf53067e-dfe4-42a3-b433-27ca7b3dbec8
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
