### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 19f74853-2f50-4e89-b8c2-a238f12fbf65
using PlutoUI

# ╔═╡ 9f23d5e7-5cc3-4ba3-8fae-7c4786d65347
using KernelAbstractions

# ╔═╡ 569dadd3-c97c-4311-b9c7-1f6df16e4e58
# Making an object callable

# ╔═╡ 270d7deb-fb38-4dc6-a991-9696aeca5f0b
(A::Array)(i,j) = A[i,j] * 10

# ╔═╡ 293c977a-97f6-43a6-afaf-b9a1595139c9
[1 2 3;4 5 6]

# ╔═╡ 7dfefc08-6e10-431b-b393-93403b399e85
[1 2 3;4 5 6][2,2]

# ╔═╡ 60ed4508-8aaf-4d59-a9b2-859d2318cb83
[1 2 3;4 5 6](2,2)

# ╔═╡ 086a74b8-d61a-4c93-a3c2-68dfccded570
md"""
  Make sin callable
"""

# ╔═╡ b38218ff-b59a-4fcd-97f9-d5bc09bd3382
md"""
 Wrap functions in a kernel so we can get control over it
"""

# ╔═╡ 087a1ecc-59d1-11ed-1edc-c9d2f1082687
begin

	struct VectorizeMe{F}
	    func::F
	end

	# Make any f callable on a vector
	(f::VectorizeMe)(A::Array) = f.func.(A)
	  


end

# ╔═╡ 955492bf-5e9d-4c3c-92fb-a8f437324b3c
VectorizeMe(x->x^2)([1,2,3])
	

# ╔═╡ 26c44e57-6fa2-44f0-92f1-b2923e630c9b
typeof(VectorizeMe(x->x^2))

# ╔═╡ 1aba26a0-1add-4c1a-bfc2-0c84efac31c3
md"""
Suppose I want this behavior for all functions:
   f(i,v) = f(v[i])
"""

# ╔═╡ a65f191d-f6a4-46af-9a89-6c7e3aa16455
begin

	struct Kernel1{F}
	    func::F
	end

	# Make any f take on both an index
	(f::Kernel1)(i,A::Vector) = f.func(A[i])
	  


end

# ╔═╡ 97c1cde2-7a68-4152-a826-f8de8eab1b25
atan.([1,2,3],6)

# ╔═╡ 81e236e5-79f2-4bb0-9700-7f54b04c02e4
Kernel1(atan)(3,[1,2,3],6)

# ╔═╡ 84ee162b-4f3a-4cc8-b7b2-0f54f1942d3b
begin

	struct Kernel2{F}
	    func::F
	end

	# Make any f take on both an index
	(f::Kernel2)(i,A::Vector,args...) = f.func(A[i],args...)
	  

end

# ╔═╡ a51db5e5-271d-4128-ad72-9c386d10fba0
Kernel2(atan)(3,[1,2,3],6)

# ╔═╡ 04ad73b2-dd1d-46ea-b2cf-23f68233c716
begin

	struct Kernel3{F}
	    func::F
	end

	# Make any f take on both an index
	(f::Kernel3)(A::Vector,args...) = [ f.func(A[i],args...) for i=1:length(A) ]
	  

end

# ╔═╡ 72c0348e-f807-4495-836b-33b4364674ac
Kernel3(atan)([1,2,3],6)

# ╔═╡ 0eb8df71-abb9-4802-8631-61877bb592cf
md"""
 now in place
"""

# ╔═╡ 573a73ac-8403-4876-88f4-fb2619148178
function sin(A,i)
 A[i]=i
	A
end

# ╔═╡ f1b0a547-fca0-44ad-a6ac-c43a2f719562
(s::typeof(sin))(x::Vector) =  sin.(x)

# ╔═╡ 3730edfa-4c3c-43db-a5f4-9808a37e587d
sin([1,2,3])

# ╔═╡ 740a224d-6fef-4c49-8d2c-da1dc1d41725
VectorizeMe(sin)(rand(3))

# ╔═╡ 8a449e8a-2132-47e6-ab0f-69bd39de9dd6
typeof(VectorizeMe(sin))

# ╔═╡ b49f4ba9-bf80-4f84-8a14-de5beefc65e4
Kernel1(sin)(3,[1,2,3]), sin(3)

# ╔═╡ 80a9d6f9-9401-4a21-b980-d0fc8028d52f
sin([5,6,7],2)

# ╔═╡ b06403f7-dcca-4bee-8eae-ce94671b6294
function atan!(i,A,args...)
  A[i] = atan(A[i],args...)
end

# ╔═╡ 9497351d-1a4f-4eb2-a1b7-7153bfbbdadb
begin

	struct Kernel4{F}
	    func!::F
	end

	# Make any f take on both an index
	function (f::Kernel4)(A::Vector,args...) 
		 for i=1:length(A) 
			 f.func!(i,A,args...)
		 end
	end
	  

end

# ╔═╡ 4f391154-4333-45f2-908f-3bf6c839e410
begin
	v = [1.0,2,3]
	Kernel4(atan!)(v,6)
end

# ╔═╡ a095a1a3-f758-4ac2-a37e-81177b299388
v

# ╔═╡ def1145d-c455-49a6-9f3d-73794c41c3c7
atan.([1,2,3],6)

# ╔═╡ 4070b1b7-fd74-4f26-b01b-2922daed406a
begin
	n = 5
	#positions = rand(n)
end

# ╔═╡ 972f3f82-560d-469d-9215-069ef4167562
function myproblem1(x)
	y = zero(x)
	n = length(x)
	for i=1:n ,j=1:n 
		if j≠i
		  y[i] += 1. /abs(x[i]-x[j])
		end
	end
	y
end	  

# ╔═╡ d8c47d59-a5ce-4c6b-943f-6e73d522b209
function myproblem2(x)
	y = zero(x)
	n = length(x)
	for i=1:n 
		  y[i] = sum( 1/abs(x[i]-x[j]) for j=1:n if j≠i)
		end
	
	y
end	

# ╔═╡ 8286beee-54b6-471d-b27a-ce24dc6a8438
myproblem1([1.0,2,3])

# ╔═╡ 80dea46a-ceeb-4b15-8a6e-95232598cb53
myproblem2([1.0,2,3])

# ╔═╡ 975346eb-34cd-4457-8cbe-d4150aa039f6
function myproblem3(x) 
   
  A = 1 ./ abs.(x .- x') 
  A = ( x-> isinf(x) ? 0 : x).(A)
  sum(A, dims=1)
end

# ╔═╡ 65e04649-f79c-4421-97fc-bae6832705a2
myproblem3([1.0,2,3])

# ╔═╡ c3a361ae-3714-409e-ab0e-eb19bba53ab2
isinf(3.5)

# ╔═╡ 9c06aad4-7b94-41dd-baf0-9d8a0bfe0591
force_law(x,y) = 1/abs(x-y)

# ╔═╡ d33e625a-9c05-4180-9009-4e014d0fd2ec
num_cores = Threads.nthreads()

# ╔═╡ a9161a66-a19c-4a4d-a5e8-0ba120051ad7
begin
	positions = rand(n)
	forces = similar(positions)
end

# ╔═╡ e3736993-b7df-48ea-ac8c-2fec24f78537
@kernel function myproblem!(forces, positions,  force_law)
    tid = @index(Global, Linear)
    forces[tid] = 0.0
  
    for j = 1:length(positions)
        if j != tid
            forces[tid] += force_law(positions[tid], positions[j] )                            end
    end

end

# ╔═╡ 349b3418-e9b7-4044-9523-f1cbc9404987
 kernel! = myproblem!(CPU(),num_cores)

# ╔═╡ 07eee79f-f827-4e26-9fa8-5721dece1503
kernel!(forces, positions, force_law, ndrange=n)

# ╔═╡ 861f0dd3-3bb0-429a-8150-1ef7e3eaab04
forces

# ╔═╡ 18312733-02c4-44ce-a487-15799ee480e2
myproblem1(positions)

# ╔═╡ c1276493-ebff-4600-a5d4-728a903cd1ee
myproblem2(positions)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
KernelAbstractions = "~0.8.4"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0-rc4"
manifest_format = "2.0"
project_hash = "ffb6dfa41b7d6ca0e64373f4cd9305ae5eacd441"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Atomix]]
deps = ["UnsafeAtomics"]
git-tree-sha1 = "c06a868224ecba914baa6942988e2f2aade419be"
uuid = "a9b6321e-bd34-4604-b9c9-b65b8de01458"
version = "0.1.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

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

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.KernelAbstractions]]
deps = ["Adapt", "Atomix", "InteractiveUtils", "LinearAlgebra", "MacroTools", "SparseArrays", "StaticArrays", "UUIDs", "UnsafeAtomics", "UnsafeAtomicsLLVM"]
git-tree-sha1 = "eed4743b01ca88d23be3663bac121374940b475b"
uuid = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
version = "0.8.4"

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Printf", "Unicode"]
git-tree-sha1 = "e7e9184b0bf0158ac4e4aa9daf00041b5909bf1a"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "4.14.0"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg", "TOML"]
git-tree-sha1 = "771bfe376249626d3ca12bcd58ba243d3f961576"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.16+0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

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

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "f86b3a049e5d05227b10e15dbb315c5b90f14988"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.9"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

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

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnsafeAtomics]]
git-tree-sha1 = "6331ac3440856ea1988316b46045303bef658278"
uuid = "013be700-e6cd-48c3-b4a1-df204f14c38f"
version = "0.2.1"

[[deps.UnsafeAtomicsLLVM]]
deps = ["LLVM", "UnsafeAtomics"]
git-tree-sha1 = "33af9d2031d0dc09e2be9a0d4beefec4466def8e"
uuid = "d80eeb9a-aca5-4d75-85e5-170c8b632249"
version = "0.1.0"

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
# ╠═19f74853-2f50-4e89-b8c2-a238f12fbf65
# ╠═569dadd3-c97c-4311-b9c7-1f6df16e4e58
# ╠═270d7deb-fb38-4dc6-a991-9696aeca5f0b
# ╠═293c977a-97f6-43a6-afaf-b9a1595139c9
# ╠═7dfefc08-6e10-431b-b393-93403b399e85
# ╠═60ed4508-8aaf-4d59-a9b2-859d2318cb83
# ╠═086a74b8-d61a-4c93-a3c2-68dfccded570
# ╠═f1b0a547-fca0-44ad-a6ac-c43a2f719562
# ╠═3730edfa-4c3c-43db-a5f4-9808a37e587d
# ╠═b38218ff-b59a-4fcd-97f9-d5bc09bd3382
# ╠═087a1ecc-59d1-11ed-1edc-c9d2f1082687
# ╠═740a224d-6fef-4c49-8d2c-da1dc1d41725
# ╠═955492bf-5e9d-4c3c-92fb-a8f437324b3c
# ╠═8a449e8a-2132-47e6-ab0f-69bd39de9dd6
# ╠═26c44e57-6fa2-44f0-92f1-b2923e630c9b
# ╠═1aba26a0-1add-4c1a-bfc2-0c84efac31c3
# ╠═a65f191d-f6a4-46af-9a89-6c7e3aa16455
# ╠═b49f4ba9-bf80-4f84-8a14-de5beefc65e4
# ╠═97c1cde2-7a68-4152-a826-f8de8eab1b25
# ╠═81e236e5-79f2-4bb0-9700-7f54b04c02e4
# ╠═84ee162b-4f3a-4cc8-b7b2-0f54f1942d3b
# ╠═a51db5e5-271d-4128-ad72-9c386d10fba0
# ╠═04ad73b2-dd1d-46ea-b2cf-23f68233c716
# ╠═72c0348e-f807-4495-836b-33b4364674ac
# ╠═0eb8df71-abb9-4802-8631-61877bb592cf
# ╠═573a73ac-8403-4876-88f4-fb2619148178
# ╠═80a9d6f9-9401-4a21-b980-d0fc8028d52f
# ╠═b06403f7-dcca-4bee-8eae-ce94671b6294
# ╠═9497351d-1a4f-4eb2-a1b7-7153bfbbdadb
# ╠═4f391154-4333-45f2-908f-3bf6c839e410
# ╠═a095a1a3-f758-4ac2-a37e-81177b299388
# ╠═def1145d-c455-49a6-9f3d-73794c41c3c7
# ╠═4070b1b7-fd74-4f26-b01b-2922daed406a
# ╠═972f3f82-560d-469d-9215-069ef4167562
# ╠═d8c47d59-a5ce-4c6b-943f-6e73d522b209
# ╠═8286beee-54b6-471d-b27a-ce24dc6a8438
# ╠═80dea46a-ceeb-4b15-8a6e-95232598cb53
# ╠═975346eb-34cd-4457-8cbe-d4150aa039f6
# ╠═65e04649-f79c-4421-97fc-bae6832705a2
# ╠═c3a361ae-3714-409e-ab0e-eb19bba53ab2
# ╠═9f23d5e7-5cc3-4ba3-8fae-7c4786d65347
# ╠═9c06aad4-7b94-41dd-baf0-9d8a0bfe0591
# ╠═d33e625a-9c05-4180-9009-4e014d0fd2ec
# ╠═a9161a66-a19c-4a4d-a5e8-0ba120051ad7
# ╠═e3736993-b7df-48ea-ac8c-2fec24f78537
# ╠═349b3418-e9b7-4044-9523-f1cbc9404987
# ╠═07eee79f-f827-4e26-9fa8-5721dece1503
# ╠═861f0dd3-3bb0-429a-8150-1ef7e3eaab04
# ╠═18312733-02c4-44ce-a487-15799ee480e2
# ╠═c1276493-ebff-4600-a5d4-728a903cd1ee
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
