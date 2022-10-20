### A Pluto.jl notebook ###
# v0.19.13

using Markdown
using InteractiveUtils

# ╔═╡ 87973dfc-5085-11ed-1aa0-89dd62f142b1
using PlutoUI

# ╔═╡ 16b249a7-f5fe-40f2-abac-8b39faf55a89
TableOfContents()

# ╔═╡ ff7ed6ed-1a12-472b-bff0-499a9ec1a023
html"<button onclick=present()>Present</button>"

# ╔═╡ 77654c48-7f68-46c0-a8da-1f69fec31401
md"""
# Optimization
"""

# ╔═╡ 6bcb5e14-36ce-4ac5-89c8-11f9406b49ae
md"""
## Convex optimization
"""

# ╔═╡ 65748ef6-47a8-4eda-bf9f-b56a6f36c5e7
md"""
- Modeling with convex problems
- First-order methods
- Second-order methods
- `Convex.jl`
"""

# ╔═╡ a5010060-ce60-4673-bf4e-e8e64b1cbb0b
md"""
## Linear optimization
"""

# ╔═╡ a28c32f9-58d8-4918-bc42-03b6c941988d
md"""
- Modeling with LPs
- Geometric interpretation
- Simplex algorithm
- `JuMP.jl`
"""

# ╔═╡ 2d63686a-ca59-457b-952a-0713d0ffc2a5
md"""
## Integer optimization
"""

# ╔═╡ d5db4a3c-a8b0-4430-a50b-4937b5c57ea2
md"""
- Modeling with ILPs
- Branch & Bound algorithm
- `JuMP.jl`
"""

# ╔═╡ 64fdafb0-6e59-4002-96e0-6ee15350ca2d
md"""
## Graph theory
"""

# ╔═╡ b98b61e2-9c8f-4bcd-a555-1e426891c9ef
md"""
- Graph storage
- Shortest paths
- Flows
- Traveling salesman
- `Graphs.jl`
"""

# ╔═╡ c37edebd-6e3b-4f22-a26d-abcdabe251b1
md"""
# Machine learning
"""

# ╔═╡ ea9d8f0c-76c4-4c96-bbc4-64cbaeebb8e6
md"""
## Structured learning
"""

# ╔═╡ a1c12b36-ebb2-4269-9f9b-2abe1445117e
md"""
- Differentiable optimization layers
- `DiffOpt.jl`
- `InferOpt.jl`
"""

# ╔═╡ b3724577-4fd9-4cb9-b224-5eb121f42646
md"""
## Probabilistic programming
"""

# ╔═╡ 8c70dfde-4578-4a59-88d8-cb735204e1fe
md"""
- Probabilistic programming languages
- MCMC
- Variational inference
- `Turing.jl`
"""

# ╔═╡ 93dc585f-a4bd-4fb5-b4ad-c6a3163eebf7
md"""
# More about Julia
"""

# ╔═╡ 2ea00728-e344-48e6-aa20-5ea3446d3417
md"""
## Good programming practices
"""

# ╔═╡ 4a09354e-c269-4e93-a4b9-edb89b14b19e
md"""
## Performance recap / exercises
"""

# ╔═╡ 349dceb2-66c4-4647-aff1-cd6545ef96e6
md"""
# Project?
"""

# ╔═╡ a6581c2e-6e0d-440d-99c3-507a49122326
md"""
- Google Hash Code archive: [street view routing](https://storage.googleapis.com/coding-competitions.appspot.com/HC/2014/hashcode2014_final_task.pdf), [self-driving rides](https://storage.googleapis.com/coding-competitions.appspot.com/HC/2018/hashcode2018_qualification_task.pdf)
- Advent of code?
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "97be6e027681c6ecfa37671630e179d506eb1167"

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

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

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
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

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
# ╠═87973dfc-5085-11ed-1aa0-89dd62f142b1
# ╠═16b249a7-f5fe-40f2-abac-8b39faf55a89
# ╟─ff7ed6ed-1a12-472b-bff0-499a9ec1a023
# ╟─77654c48-7f68-46c0-a8da-1f69fec31401
# ╟─6bcb5e14-36ce-4ac5-89c8-11f9406b49ae
# ╟─65748ef6-47a8-4eda-bf9f-b56a6f36c5e7
# ╟─a5010060-ce60-4673-bf4e-e8e64b1cbb0b
# ╟─a28c32f9-58d8-4918-bc42-03b6c941988d
# ╟─2d63686a-ca59-457b-952a-0713d0ffc2a5
# ╟─d5db4a3c-a8b0-4430-a50b-4937b5c57ea2
# ╟─64fdafb0-6e59-4002-96e0-6ee15350ca2d
# ╟─b98b61e2-9c8f-4bcd-a555-1e426891c9ef
# ╟─c37edebd-6e3b-4f22-a26d-abcdabe251b1
# ╟─ea9d8f0c-76c4-4c96-bbc4-64cbaeebb8e6
# ╟─a1c12b36-ebb2-4269-9f9b-2abe1445117e
# ╟─b3724577-4fd9-4cb9-b224-5eb121f42646
# ╟─8c70dfde-4578-4a59-88d8-cb735204e1fe
# ╟─93dc585f-a4bd-4fb5-b4ad-c6a3163eebf7
# ╟─2ea00728-e344-48e6-aa20-5ea3446d3417
# ╟─4a09354e-c269-4e93-a4b9-edb89b14b19e
# ╟─349dceb2-66c4-4647-aff1-cd6545ef96e6
# ╟─a6581c2e-6e0d-440d-99c3-507a49122326
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
