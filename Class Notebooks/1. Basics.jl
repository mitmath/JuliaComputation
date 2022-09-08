### A Pluto.jl notebook ###
# v0.19.11

#> [frontmatter]
#> title = "IntroJulia"
#> description = "An interactive introduction to the Julia programming language"

using Markdown
using InteractiveUtils

# ╔═╡ c35189d5-fbe8-4637-b004-2d15b7399af5
using PlutoUI; TableOfContents()

# ╔═╡ 69f4feb4-a170-4a79-a316-8697021770c9
md"""
!!! danger "Introduction to Julia"
	🏠[Course home](https://gdalle.github.io/IntroJulia/)
	
This website is an introduction to the Julia programming language, written by [Guillaume Dalle](https://gdalle.github.io).
"""

# ╔═╡ 2ffec8d3-6168-4261-8846-e8269125077d
md"""
## What is Julia?

Maybe the solution to the two-language problem:

- User-friendly syntax for easy programming
- C-level speed (when done right) for high-performance computing

See the [Julia manifesto](https://julialang.org/blog/2012/02/why-we-created-julia/) or this [Nature article](https://www.nature.com/articles/d41586-019-02310-3) for more details.
"""

# ╔═╡ 79c1ea6e-112c-47e2-a676-437f24298664
md"""
# Getting started
"""

# ╔═╡ a5430a82-913f-439b-966d-73bad7f17283
md"""
## Installation

To install the latest version of Julia, follow the [platform-specific instructions](https://julialang.org/downloads/platform/).
If you need multiple versions of Julia to coexist on your system, or if you don't want to bother with manual updates, take a look at [juliaup](https://github.com/JuliaLang/juliaup) (which will soon be the default installer), [jill](https://github.com/abelsiqueira/jill) or [jill.py](https://github.com/johnnychen94/jill.py).

If you want to run the notebooks of this course yourself, you will also need to install the [Pluto.jl](https://github.com/fonsp/Pluto.jl) package.
"""

# ╔═╡ cf6f6e8e-dc13-4473-9cdd-fa8604b6a9e2
md"""
## Learning the ropes

The Julia website has a great list of [resources for beginners](https://julialang.org/learning/) and [tutorials](https://julialang.org/learning/tutorials/)., as well as free [MOOCs](https://juliaacademy.com/) contributed by the community.
The official [Julia YouTube channel](https://www.youtube.com/c/TheJuliaLanguage/playlists) also boasts lots of introductory content.

If you just need a quick refresher about syntax, this [cheat sheet](https://juliadocs.github.io/Julia-Cheat-Sheet/) is the place to go.
For more involved questions, the primary source of knowledge is the [Julia manual](https://docs.julialang.org/en/v1/).
And for the ultimate list of Julia resources, go to [Julia.jl](https://svaksha.github.io/Julia.jl/).
"""

# ╔═╡ 0def1275-d89d-49c1-97bf-2181ff351e52
md"""
## Coding environment

When developing in Julia, you need to select a comfortable code editor.
I strongly recommend using [Visual Studio Code](https://code.visualstudio.com/) with the [Julia for VSCode extension](https://www.julia-vscode.org/), but other IDEs also have [Julia support](https://github.com/JuliaEditorSupport).

If you want something a bit lighter, here are two browser-based options:
- [Pluto.jl](https://github.com/fonsp/Pluto.jl) is a Julia-based reactive notebook server (which we are using right now)
- [IJulia.jl](https://github.com/JuliaLang/IJulia.jl) allows you to harness the power of [Jupyter](https://jupyter.org/). By the way, did you know that the "Ju" in "Jupyter" stands for Julia?
"""

# ╔═╡ c6bfaf1e-61a6-4d48-a169-58359ac8229d
md"""
## Getting help

The Julia [community](https://julialang.org/community/) is very active and welcoming, so don't hesitate to [ask for help](https://julialang.org/about/help/)!
"""

# ╔═╡ b293430c-8ebf-4c0e-9408-18c0bfdf8353
md"""
# Course notebooks
"""

# ╔═╡ b8667519-5a04-48da-ae79-cb2efc51f56d
md"""
All the links below point to notebooks that can be visualized in your browser without any prerequisites. To edit or run a notebook, click on `Edit or run this notebook` and follow the instructions given there.
"""

# ╔═╡ 6160429a-6b98-4bfc-ab85-2f8109e99182
md"""
## General stuff

1. [Basics of Julia](basics.html)
1. [Developing packages](package.html)
1. [Writing efficient code](efficiency.html)
"""

# ╔═╡ 813cd7f7-85e1-4cdf-bde3-af259d9aa429
md"""
## Optimization (_work in progress_)

1. [Graph theory](graphs.html)
1. [Polyhedra](polyhedra.html)
1. [Linear Programming](jump.html)
1. [Branch & Bound](branch_bound.html)
"""

# ╔═╡ e014d07e-a798-450b-b779-2cb4d027a011
md"""
## Miscellaneous (_work in progress_)
"""

# ╔═╡ 8f379769-4c9a-4152-aba9-88bc6fc4fae7
md"""
# Going further
"""

# ╔═╡ 67cff2eb-1636-448c-b99f-a93c76571b73
md"""
## MIT courses

Since Julia originated at MIT, it is no wonder that MIT researchers are teaching it well.
Check out [Introduction to Computational Thinking](https://computationalthinking.mit.edu/Spring21/) for your first steps, and [Parallel Computing and Scientific Machine Learning](https://book.sciml.ai/) when you feel more confident.
"""

# ╔═╡ 5a361b3d-d3e3-4406-a949-f091af1ab566
md"""
## Other resources

- [Introducing Julia](https://en.wikibooks.org/wiki/Introducing_Julia) (WikiBooks)
- [ThinkJulia: How to think like a computer scientist](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html) (Ben Lauwens)
- [Quantitative economics with Julia](https://julia.quantecon.org/intro.html) (Jesse Perla, Thomas J. Sargent and John Stachurski)
- [From Zero to Julia](https://techytok.com/from-zero-to-julia/) (Aurelio Amerio)
- [A Deep Introduction to Julia for Data Science and Scientific Computing](https://ucidatascienceinitiative.github.io/IntroToJulia/) (Chris Rackauckas)
- [Introduction to the Julia programming language](https://github.com/mfherbst/2022-rwth-julia-workshop) (Michael Herbst)
"""

# ╔═╡ a4be17de-7154-4788-be2b-5c17ce78b6a9
md"""
## Examples of Julia code

- [Algorithms for Optimization & Algorithms for Decision-Making](Algorithms for Optimization) (Mykel J. Kochenderfer)
- [BeautifulAlgorithms.jl](https://github.com/mossr/BeautifulAlgorithms.jl#newtons-method) (Robert Moss)
- [TheAlgorithms](https://github.com/TheAlgorithms/Julia) (GitHub community)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.32"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0-rc4"
manifest_format = "2.0"
project_hash = "843496cd44fbdabc30a5724f73519a3ea6a74f55"

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

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

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

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

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

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "85b5da0fa43588c75bb1ff986493443f821c70b7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "bf0a1121af131d9974241ba53f601211e9303a9e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.37"

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

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

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
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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
# ╟─c35189d5-fbe8-4637-b004-2d15b7399af5
# ╟─69f4feb4-a170-4a79-a316-8697021770c9
# ╟─2ffec8d3-6168-4261-8846-e8269125077d
# ╟─79c1ea6e-112c-47e2-a676-437f24298664
# ╟─a5430a82-913f-439b-966d-73bad7f17283
# ╟─cf6f6e8e-dc13-4473-9cdd-fa8604b6a9e2
# ╟─0def1275-d89d-49c1-97bf-2181ff351e52
# ╟─c6bfaf1e-61a6-4d48-a169-58359ac8229d
# ╟─b293430c-8ebf-4c0e-9408-18c0bfdf8353
# ╟─b8667519-5a04-48da-ae79-cb2efc51f56d
# ╠═6160429a-6b98-4bfc-ab85-2f8109e99182
# ╟─813cd7f7-85e1-4cdf-bde3-af259d9aa429
# ╟─e014d07e-a798-450b-b779-2cb4d027a011
# ╟─8f379769-4c9a-4152-aba9-88bc6fc4fae7
# ╟─67cff2eb-1636-448c-b99f-a93c76571b73
# ╟─5a361b3d-d3e3-4406-a949-f091af1ab566
# ╟─a4be17de-7154-4788-be2b-5c17ce78b6a9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
