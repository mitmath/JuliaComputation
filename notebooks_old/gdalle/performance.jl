### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 80266caa-6066-11ed-0d4e-a3b81a95bc95
begin
	using BenchmarkTools
	using JET
	using PlutoUI
	using PlutoTeachingTools
	using ProfileCanvas
	using ProgressLogging
end

# ╔═╡ fc5c6cb2-4d06-4922-90ca-553c562a6e16
TableOfContents()

# ╔═╡ 9604dcf7-b58e-4af5-9ecd-5bd3199c785d
html"<button onclick=present()>Present</button>"

# ╔═╡ be066ed7-7bd5-4d46-ae2c-4fca40f1cffb
md"""
# Writing fast Julia code
"""

# ╔═╡ 3da3826b-b7bd-4a27-a17a-2a121c51a857
md"""
# 1. Performance diagnosis
"""

# ╔═╡ 0fc7bece-72ec-4dc2-8205-0c588c4a856c
md"""
## Tracking loops
"""

# ╔═╡ fc67f478-87c0-44f2-8bbc-033ec5da5b3d
md"""
In long-running code, the best way to track loops is not a periodic `println(i)`. There are packages designed for this purpose, such as [ProgressMeter.jl](https://github.com/timholy/ProgressMeter.jl).
For a more high-level approach (that plays nicely with Pluto and VSCode), we can use the `@progress` macro of [ProgressLogging.jl](https://github.com/JuliaLogging/ProgressLogging.jl) instead.
"""

# ╔═╡ 28b66131-e901-4201-a9b7-fa99f203c7ca
@progress for i in 1:10
	sleep(0.2)
end

# ╔═╡ c64ea3e9-9d18-4668-97af-6aa1dd493433
md"""
Julia also has a built-in [logging system](https://docs.julialang.org/en/v1/stdlib/Logging/).
"""

# ╔═╡ 55fbb2e5-baf9-4102-a709-d6a23606fdb1
let
	x = 2
	@info "It's all good" x
	@warn "Be careful" x - 1
	@error "Something went wrong" x - 2
end

# ╔═╡ 8a5d4d94-efef-4b8c-b505-f3e58df9b654
md"""
## Benchmarking
"""

# ╔═╡ ced6a5f8-c16c-47ed-adb9-30d17b580e5e
md"""
To evaluate the efficiency of a function, we need to know how long it takes and how much memory it uses. Julia provides built-in macros for these tasks:
- `@elapsed` returns the computation time (in seconds)
- `@allocated` returns the allocated memory (in bytes)
- `@time` prints both (in the REPL!) and returns the function result

However, the built-in macros have shortcomings: they only run the function once, and their measurements may be biased by the presence of global variables.
We can get a more accurate evaluation thanks to the macros `@belapsed`, `@ballocated` and `@btime` (or `@benchmark` for a graphical summary) from [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl).
When using BenchmarkTools.jl, it is important to [interpolate](https://juliaci.github.io/BenchmarkTools.jl/stable/manual/#Interpolating-values-into-benchmark-expressions) any external (especially global) variables with a dollar sign, so that they're evaluated at definition time.
"""

# ╔═╡ 0fd5ccd7-ffbb-4a4b-a76a-b7375951e605
let
	x = rand(100, 100)
	@benchmark exp($x)
end

# ╔═╡ 553a93f4-0d1a-45db-8b56-83e071e3bb45
md"""
## Profiling
"""

# ╔═╡ 47a2b694-f5d0-438c-afb2-f757c5ebaf62
md"""
Profiling is more precise than benchmarking: it tells you how much time you spend _in each nested function call_.
Julia provides a sampling-based [profiler](https://docs.julialang.org/en/v1/manual/profile/), but it is hard to use without a good visualization.
We recommend using the [`@profview` macro](https://www.julia-vscode.org/docs/stable/userguide/profiler/) from the VSCode Julia extension (or from [ProfileCanvas.jl](https://github.com/pfitzseb/ProfileCanvas.jl) when you're working on a notebook).
However, there are many other options: see the [FlameGraphs.jl](https://github.com/timholy/FlameGraphs.jl) README for a list.

A profiling "flame graph" represents the entire call stack, with each layer corresponding to a call depth.
The width of a tile is proportional to its execution time, but you can click on it to make it fill the whole window.
Note that the first few layers are usually boilerplate code, and we need to scroll down to reach user-defined functions, usually below a tile called `eval`.
"""

# ╔═╡ fa393444-2ea0-4da9-a38d-da2d7a7c045b
md"""
The tile colors in the flame graph have special meanings:
- blue $\implies$ everything is fine
- gray $\implies$ compilation overhead from the first function call (just run the profiling step a second time)
- red $\implies$ "runtime dispatch" flag, a sign of bad type inference (except in the first layers where it is normal)
- yellow $\implies$ "garbage collection" (GC) flag, a sign of excessive allocations
"""

# ╔═╡ c258b419-da92-41d8-a68a-24cebf3f01cd
md"""
## Flame graph examples
"""

# ╔═╡ b3af8f8c-9008-47bd-ae99-9340b02e8e59
function matmul1(A, B)
	m, p = size(A, 1), size(B, 2)
	C = Matrix(undef, m, p)
	for i = 1:m, j = 1:p
		C[i, j] = sum(A[i, :] .* B[:, j])
	end
	return C
end

# ╔═╡ 91fdeabc-211f-4e82-9a5b-64155872c530
let
	A, B = rand(200, 100), rand(100, 300)
	@btime matmul1($A, $B)
	@profview for _ in 1:10; matmul1(A, B); end
end

# ╔═╡ 1b8283b1-c5b7-4d86-a87e-8408d0938eb4
function matmul2(A, B)
	m, n, p = size(A, 1), size(A, 2), size(B, 2)
	C = Matrix(undef, m, p)
	for i = 1:m, j = 1:p
		C[i, j] = 0
		for k in 1:n
			C[i, j] += A[i, k] * B[k, j]
		end
	end
	return C
end

# ╔═╡ efd77774-d93d-41b0-8283-1657435bb765
let
	A, B = rand(200, 100), rand(100, 300)
	@btime matmul2($A, $B)
	@profview for _ in 1:10; matmul2(A, B); end
end

# ╔═╡ 042b783a-a00a-401f-a4e2-e52c577fe384
function matmul3(A, B)
	m, n, p = size(A, 1), size(A, 2), size(B, 2)
	T = promote_type(eltype(A), eltype(B))
	C = Matrix{T}(undef, m, p)
	for i = 1:m, j = 1:p
		C[i, j] = zero(T)
		for k in 1:n
			C[i, j] += A[i, k] * B[k, j]
		end
	end
	return C
end

# ╔═╡ 969f2427-8089-4f1d-a533-c85c05e51834
let
	A, B = rand(200, 100), rand(100, 300)
	@btime matmul3($A, $B)
	@profview for _ in 1:10; matmul3(A, B); end
end

# ╔═╡ c838c62e-133c-4a11-93a0-8943abd475c2
md"""
## Type introspection
"""

# ╔═╡ 43924cc3-ffec-415c-8df9-03f81342fa5e
md"""
The built-in macro [`@code_warntype`](https://docs.julialang.org/en/v1/manual/performance-tips/#man-code-warntype) shows the result of type inference on a function call.
Non-concrete types are displayed in red: they are those for which inference failed.
"""

# ╔═╡ 05f496d7-5970-4408-979b-d4400ee21abc
let
	A, B = rand(200, 100), rand(100, 300)
	@code_warntype matmul2(A, B)
end

# ╔═╡ c69378e2-9f73-463e-b881-897b859c7741
md"""
Sometimes `@code_warntype` is not enough, because it only studies the outermost function and doesn't dive deeper into the call stack.
"""

# ╔═╡ 181fe5ea-1da6-41fe-99a7-f32f96cb621f
matmul2_wrapper(args...) = matmul2(args...)

# ╔═╡ 67fead56-530d-4853-860b-ff8645359b9c
let
	A, B = rand(200, 100), rand(100, 300)
	@code_warntype matmul2_wrapper(A, B)
end

# ╔═╡ 41fa32c8-4cb6-4632-b511-e32f57e795e8
let
	A, B = rand(200, 100), rand(100, 300)
	@report_opt matmul2_wrapper(A, B)
end

# ╔═╡ 62a57328-159f-42b3-b76b-0dfb6a245c25
let
	A, B = rand(200, 100), rand(100, 300)
	@report_opt matmul3(A, B)
end

# ╔═╡ fe829857-090c-4279-8812-a0c96f9d1d10
md"""
## Memory introspection
"""

# ╔═╡ a52a7793-6e61-428b-97dc-f8f0cba41ce3
md"""
A memory profiler was introduced in Julia 1.8, which mimics the behavior of the temporal profiler shown above.
To use it, just replace `@profview` with `@profview_allocs`.
"""

# ╔═╡ eddf2211-bd11-4487-b54f-7e6399507d8c
let
	A, B = rand(200, 100), rand(100, 300)
	@profview_allocs for _ in 1:10; matmul1(A, B); end
end

# ╔═╡ de4dc4f4-38cd-4e0d-acb3-dd1b2b623dff
let
	A, B = rand(200, 100), rand(100, 300)
	@profview_allocs for _ in 1:10; matmul3(A, B); end
end

# ╔═╡ d2c7c936-605d-4fe3-b7fa-09eb310407b1
md"""
Often, excessive memory allocations are also a telltale sign of bad type inference.
"""

# ╔═╡ 7074d2f5-ab4f-4e68-b0af-bc6ea6a223e0
md"""
# 2. Performance improvement
"""

# ╔═╡ 1b6ec1fa-06bf-47ab-8b83-6e7d5800b87b
md"""
Now that we know how to detect bad performance, we will list a few tips to achieve good performance.
But always remember the golden rule: only optimize code that works, and that needs optimizing!

The primary source for this section is the Julia manual page on [performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/) (read it after this!).
"""

# ╔═╡ a6b7aec2-e428-442d-b771-4972d71d6413
md"""
## General advice
"""

# ╔═╡ 4744db37-5c7d-4b6a-bc71-45b7b104ce45
md"""
- Avoid [global variables](https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-global-variables), or turn them into constants with the keyword `const`
- Put critical code [inside functions](https://docs.julialang.org/en/v1/manual/performance-tips/#Performance-critical-code-should-be-inside-a-function)
- Vectorized operations (using the [dot syntax](https://docs.julialang.org/en/v1/manual/functions/#man-vectorized)) are not faster than loops, except linear algebra routines
- Beware of [closures](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-captured) (i.e. functions that return functions)
"""

# ╔═╡ 76355967-d436-4136-8483-8ef873a045c6
md"""
## Facilitate type inference
"""

# ╔═╡ bc2fc918-088d-4bdb-b8d3-c7953e3884ee
md"""
Julia is fastest when it can infer the type of each variable during just-in-time compilation: then it can decide ahead of runtime (statically) which method to dispatch where.
When this fails, types have to be inferred at runtime (dynamically), and "runtime dispatch" of methods is much slower.

The key to successful type inference is simple to express.
In each function, the types of the arguments (*not their values*) should suffice to deduce the type of every other variable, especially the output.
Here are a few ways to make this happen.

- Always declare concrete or parametric types (no abstract types) in the following places:
  - [container initializations](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-abstract-container)
  - [`struct` field values](https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-fields-with-abstract-type)
  - [`struct` field containers](https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-fields-with-abstract-containers)
- Never write `if typeof(x) == ...`: exploit [multiple dispatch](https://docs.julialang.org/en/v1/manual/performance-tips/#Break-functions-into-multiple-definitions) or [function barriers](https://docs.julialang.org/en/v1/manual/performance-tips/#kernel-functions) instead
- Define functions that [do not change the type of variables](https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-changing-the-type-of-a-variable) and [always output the same type](https://docs.julialang.org/en/v1/manual/performance-tips/#Write-%22type-stable%22-functions)
"""

# ╔═╡ 7533366f-0a55-40c6-8754-ed4379658c5b
md"""
## Reduce memory allocations
"""

# ╔═╡ be939baf-f049-4684-805a-d1ac669bf164
md"""
Allocations and garbage collection are significant performance bottlenecks. Here are some ways to avoid them:

- Prefer in-place functions that reuse available containers (they name usually [ends with `!`](https://docs.julialang.org/en/v1/manual/style-guide/#bang-convention))
- [Pre-allocate](https://docs.julialang.org/en/v1/manual/performance-tips/#Pre-allocating-outputs) output memory
- Use [views instead of slices](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-views) when you don't need copies: `view(A, :, 1)` instead of `A[:, 1]`
- [Combine vectorized operations](https://docs.julialang.org/en/v1/manual/performance-tips/#More-dots:-Fuse-vectorized-operations)
- Fix type inference bugs (they often lead to increased memory use)
"""

# ╔═╡ db1a3f82-2ef1-432c-a087-175a23b0b11f
md"""
## Hardware considerations
"""

# ╔═╡ ae1e9d84-b605-4fe1-b7f5-be5fe843b4fd
md"""
In order to optimize Julia code to the limit, it quickly becomes useful to know how a modern computer works.
The following blog post is an absolute masterpiece on this topic: [What scientists must know about hardware to write fast code](https://viralinstruction.com/posts/hardware/) (Jakob Nybo Nissen).
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
JET = "c3a54625-cd67-489e-a8e7-0a5a0ff4e31b"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
ProfileCanvas = "efd6af41-a80b-495e-886c-e51b0c7d77a3"
ProgressLogging = "33c8b6b6-d38a-422a-b730-caa89a2f386c"

[compat]
BenchmarkTools = "~1.3.2"
JET = "~0.6.14"
PlutoTeachingTools = "~0.2.5"
PlutoUI = "~0.7.48"
ProfileCanvas = "~0.1.6"
ProgressLogging = "~0.1.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "36399a99bb78e29cd4be7c430c15ba142212a00f"

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

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

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

[[deps.JET]]
deps = ["InteractiveUtils", "JuliaInterpreter", "LoweredCodeUtils", "MacroTools", "Pkg", "Revise", "Test"]
git-tree-sha1 = "d79a04585f9db7e3d5bbe62c7ea1b9aadaf515e4"
uuid = "c3a54625-cd67-489e-a8e7-0a5a0ff4e31b"
version = "0.6.14"

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

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.ProfileCanvas]]
deps = ["Base64", "JSON", "Pkg", "Profile", "REPL"]
git-tree-sha1 = "e42571ce9a614c2fbebcaa8aab23bbf8865c624e"
uuid = "efd6af41-a80b-495e-886c-e51b0c7d77a3"
version = "0.1.6"

[[deps.ProgressLogging]]
deps = ["Logging", "SHA", "UUIDs"]
git-tree-sha1 = "80d919dee55b9c50e8d9e2da5eeafff3fe58b539"
uuid = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
version = "0.1.4"

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
# ╟─3da3826b-b7bd-4a27-a17a-2a121c51a857
# ╟─0fc7bece-72ec-4dc2-8205-0c588c4a856c
# ╟─fc67f478-87c0-44f2-8bbc-033ec5da5b3d
# ╠═28b66131-e901-4201-a9b7-fa99f203c7ca
# ╟─c64ea3e9-9d18-4668-97af-6aa1dd493433
# ╠═55fbb2e5-baf9-4102-a709-d6a23606fdb1
# ╟─8a5d4d94-efef-4b8c-b505-f3e58df9b654
# ╟─ced6a5f8-c16c-47ed-adb9-30d17b580e5e
# ╠═0fd5ccd7-ffbb-4a4b-a76a-b7375951e605
# ╟─553a93f4-0d1a-45db-8b56-83e071e3bb45
# ╟─47a2b694-f5d0-438c-afb2-f757c5ebaf62
# ╟─fa393444-2ea0-4da9-a38d-da2d7a7c045b
# ╟─c258b419-da92-41d8-a68a-24cebf3f01cd
# ╠═b3af8f8c-9008-47bd-ae99-9340b02e8e59
# ╠═91fdeabc-211f-4e82-9a5b-64155872c530
# ╠═1b8283b1-c5b7-4d86-a87e-8408d0938eb4
# ╠═efd77774-d93d-41b0-8283-1657435bb765
# ╠═042b783a-a00a-401f-a4e2-e52c577fe384
# ╠═969f2427-8089-4f1d-a533-c85c05e51834
# ╟─c838c62e-133c-4a11-93a0-8943abd475c2
# ╟─43924cc3-ffec-415c-8df9-03f81342fa5e
# ╠═05f496d7-5970-4408-979b-d4400ee21abc
# ╟─c69378e2-9f73-463e-b881-897b859c7741
# ╠═181fe5ea-1da6-41fe-99a7-f32f96cb621f
# ╠═67fead56-530d-4853-860b-ff8645359b9c
# ╠═41fa32c8-4cb6-4632-b511-e32f57e795e8
# ╠═62a57328-159f-42b3-b76b-0dfb6a245c25
# ╟─fe829857-090c-4279-8812-a0c96f9d1d10
# ╟─a52a7793-6e61-428b-97dc-f8f0cba41ce3
# ╠═eddf2211-bd11-4487-b54f-7e6399507d8c
# ╠═de4dc4f4-38cd-4e0d-acb3-dd1b2b623dff
# ╟─d2c7c936-605d-4fe3-b7fa-09eb310407b1
# ╟─7074d2f5-ab4f-4e68-b0af-bc6ea6a223e0
# ╟─1b6ec1fa-06bf-47ab-8b83-6e7d5800b87b
# ╟─a6b7aec2-e428-442d-b771-4972d71d6413
# ╟─4744db37-5c7d-4b6a-bc71-45b7b104ce45
# ╟─76355967-d436-4136-8483-8ef873a045c6
# ╟─bc2fc918-088d-4bdb-b8d3-c7953e3884ee
# ╟─7533366f-0a55-40c6-8754-ed4379658c5b
# ╟─be939baf-f049-4684-805a-d1ac669bf164
# ╟─db1a3f82-2ef1-432c-a087-175a23b0b11f
# ╟─ae1e9d84-b605-4fe1-b7f5-be5fe843b4fd
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
