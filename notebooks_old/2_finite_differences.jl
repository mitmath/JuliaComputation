### A Pluto.jl notebook ###
# v0.19.11

using Markdown
using InteractiveUtils

# ╔═╡ 1e8197f6-3355-11ed-3e7c-e5184ff0442c
using PlutoUI, LinearAlgebra

# ╔═╡ 9835214d-cc0d-45cc-8894-2487b943566a
TableOfContents(title="📚 Table of Contents", indent=true, depth=4, aside=true)

# ╔═╡ d5a3aa08-9f8a-4cb6-8407-7942faf08f4c
md"""
The purpose of this notebook is to help understand the concept of gradients
through finite differences, but not to suggest that this is a modern method to compute gradients.  (Though finite differences can still serve nicely as a way of checking)
"""

# ╔═╡ 9a65a337-77e5-45c5-a11f-dd3b95a1407c
md"# Simple Neural Network"

# ╔═╡ 964c7bcb-98df-4955-8751-d1815fcf1ca5
x₃(W₁,W₂,b₁,b₂,x₀,h::Function) =    W₂ * h.(W₁*x₀ .+ b₁)  .+ b₂

# ╔═╡ a8e7902b-2ad4-4599-9d81-3f28e0c6c5dc
loss(x₃,y) = norm(x₃ .- y)

# ╔═╡ c87a3ffa-774c-401f-8845-93c502363b14
NN(x₀,y,W₁,W₂,b₁,b₂,h) = loss(x₃(W₁,W₂,b₁,b₂,x₀,h) ,  y )

# ╔═╡ 91477641-d4c7-48c9-ada9-b7576558ae86
sizes = 3, 5, 7

# ╔═╡ 87d01d74-ab2f-4634-a2c1-b11a8b674de3
begin
	x₀ = rand( sizes[1])
	W₁ = rand( sizes[2], sizes[1])
	W₂ = rand( sizes[3], sizes[2])
	b₁ = rand( sizes[2])
	b₂ = rand( sizes[3])
	h =  sin
	y = rand( sizes[3] )
end

# ╔═╡ 2d0d42b4-0a43-4aa3-a089-4343f2864abf
NN(x₀,y,W₁,W₂,b₁,b₂,h)

# ╔═╡ d5ab569c-f498-41db-b85c-1829bd046399
begin
	md"""## Old Fashioned Gradient Computation
	(We don't want to do this anymore)
		"""
end

# ╔═╡ 006de347-5f29-4b5a-baac-a13df0848943
begin  # Create storage for the gradient
	∇W₁ = zeros( size(W₁))
	∇W₂ = zeros( size(W₂))
	∇b₁ = zeros( size(b₁))
	∇b₂ = zeros( size(b₂))
end

# ╔═╡ 221bb602-77f5-4ecf-95c4-3f9fba654eff
function compute∇(W₁,W₂,b₁,b₂,x₀,h,y  )
	ϵ = .001
	# W₁ gradient
	for i=1:size(W₁,1), j=1:size(W₁,2)
		dW₁ = zeros( size(W₁))
		dW₁[i,j] = ϵ
		∇W₁[i,j] = (NN(x₀,y, W₁.+dW₁ ,W₂,b₁,b₂,h) - NN(x₀,y, W₁, W₂,b₁,b₂,h))/ϵ
	end
	# W₂ gradient
	for i=1:size(W₂,1), j=1:size(W₂,2)
		dW₂ = zeros( size(W₂))
		dW₂[i,j] = ϵ
		∇W₂[i,j] = (NN(x₀,y, W₁ ,W₂.+dW₂,b₁,b₂,h) - NN(x₀,y, W₁, W₂,b₁,b₂,h))/ϵ
	end
	# b₁ gradient
	for i=1:size(b₁,1)
		db₁ = zeros( size(b₁))
		db₁[i] = ϵ
		∇b₁[i] = (NN(x₀,y, W₁ ,W₂,b₁.+db₁,b₂,h) - NN(x₀,y, W₁, W₂,b₁,b₂,h))/ϵ
	end
	# b₂ gradient
	for i=1:size(b₁,1)
		db₂ = zeros( size(b₂))
		db₂[i] = ϵ
		∇b₂[i] = (NN(x₀,y, W₁ ,W₂,b₁,b₂.+db₂,h) - NN(x₀,y, W₁, W₂,b₁,b₂,h))/ϵ
	end
	return ∇W₁,∇W₂,∇b₁,∇b₂
end

# ╔═╡ 0acbaeed-3f9c-4a35-b178-8a443a5882e9
compute∇(W₁,W₂,b₁,b₂,x₀,h,y  )

# ╔═╡ 13750938-b1b7-4914-867b-a77895389a10
md"""
## What about dx₃/d(W₁,W₂,b₁,b₂) ???
(When the output function is not a scalar we call this a Jacobian)
(Sometimes when it's too klunky to put in the form of a matrix, it is called a linearization but also Jacobian can be used)
"""

# ╔═╡ 586b13fa-d7b7-4d2e-b27d-46f744ebeccb
md"""
## For starters think about the matrix Square Function A→A²
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.40"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0-rc4"
manifest_format = "2.0"
project_hash = "3731524a0be8981c0b3969f8e7511b0d5e2849dc"

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
git-tree-sha1 = "3d5bf43e3e8b412656404ed9466f1dcbf7c50269"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "a602d7b0babfca89005da04d89223b867b55319f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.40"

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

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

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
# ╠═1e8197f6-3355-11ed-3e7c-e5184ff0442c
# ╠═9835214d-cc0d-45cc-8894-2487b943566a
# ╟─d5a3aa08-9f8a-4cb6-8407-7942faf08f4c
# ╠═9a65a337-77e5-45c5-a11f-dd3b95a1407c
# ╠═964c7bcb-98df-4955-8751-d1815fcf1ca5
# ╠═a8e7902b-2ad4-4599-9d81-3f28e0c6c5dc
# ╠═c87a3ffa-774c-401f-8845-93c502363b14
# ╠═91477641-d4c7-48c9-ada9-b7576558ae86
# ╠═87d01d74-ab2f-4634-a2c1-b11a8b674de3
# ╠═2d0d42b4-0a43-4aa3-a089-4343f2864abf
# ╟─d5ab569c-f498-41db-b85c-1829bd046399
# ╠═006de347-5f29-4b5a-baac-a13df0848943
# ╠═221bb602-77f5-4ecf-95c4-3f9fba654eff
# ╠═0acbaeed-3f9c-4a35-b178-8a443a5882e9
# ╟─13750938-b1b7-4914-867b-a77895389a10
# ╟─586b13fa-d7b7-4d2e-b27d-46f744ebeccb
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
