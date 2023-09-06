### A Pluto.jl notebook ###
# v0.19.12

#> [frontmatter]
#> title = "HW2 - Automatic differentiation"
#> date = "2022-09-23"

using Markdown
using InteractiveUtils

# ╔═╡ ddbf8ae6-39b6-11ed-226e-0d38991ed784
begin
	using BenchmarkTools
	using ChainRulesCore
	using ForwardDiff
	using LinearAlgebra
	using Plots  # may take a long time to load
	using PlutoTeachingTools
	using PlutoUI
	using ProgressLogging
	using Zygote  # may take a long time to load
end

# ╔═╡ ddbba011-f413-4804-b29b-fdc4efe2b3b3
md"""
Homework 2 of the MIT Course [_Julia: solving real-world problems with computation_](https://github.com/mitmath/JuliaComputation)

Release date: Friday, Sep 24, 2022 (version 2)

**Due date: Friday, Oct 1, 2022 at 11:59pm EST**

Submission by: Jazzy Doe (jazz@mit.edu)
"""

# ╔═╡ 9a1453a3-bfad-4212-ac19-a4b6c7df5b16
student = (name = "Jazzy Doe", kerberos_id = "jazz")

# ╔═╡ 9f6254b5-bc06-469c-a0ef-5ee31ac75233
md"""
The following cell is quite slow, so go grab a coffee while it runs!
Package loading times are one of the main pain points of Julia, and people are actively working to make them shorter.
"""

# ╔═╡ f447c167-2bcb-4bf3-86cd-0f40f4e54c97
TableOfContents()

# ╔═╡ a405d214-4348-4692-999e-0e890bd91e5d
md"""
# HW2 - Automatic differentiation
"""

# ╔═╡ d19834fc-edd1-433b-8bfc-6022fd7e3239
md"""
Throughout this homework, whenever a new function (or macro) is introduced, it is a good idea to check out its documentation using Pluto.
Just create a new cell and type in `?` followed by the function name, then the "Live docs" tab will open automatically.
Once the "Live docs" tab is open, clicking on a function name also displays its documentation.

We also try to include the link to the GitHub repository of every external package we use.
Once you're on the repository, look for a badge like [![docs-stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://youtu.be/dQw4w9WgXcQ) or [![docs-dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://youtu.be/dQw4w9WgXcQ), it will take you to the appropriate documentation page.
"""

# ╔═╡ 7493915c-53b4-4284-bb7f-33cac680f759
md"""
# 0. Calculus refresher
"""

# ╔═╡ 1cfba628-aa7b-4851-89f1-84b1a45802b3
md"""
## Scalar functions
"""

# ╔═╡ 3829f016-a7cd-4ce6-b2d4-1c84da8fdb97
md"""
Let $f : \mathbb{R} \longrightarrow \mathbb{R}$ be a function with scalar input and output.
When we say that $f$ is differentiable at $x \in \mathbb{R}$, we mean that there is a _number_ $f'(x) \in \mathbb{R}$ such that for any perturbation $h \in \mathbb{R}$,

$$f(x+h) = f(x) + f'(x)h + o(h)$$

In other words, $f$ can be approximated with a straight tangent line around $x$.
Furthermore, the error is negligible compared with the distance $\lvert h \rvert$ to $x$, at least for small enough values of $\lvert h \rvert$ (that is what the $o(h)$ means).

The number $f'(x)$ is called the _derivative_ of $f$ at $x$, and it gives the slope of the tangent.
"""

# ╔═╡ 755ff203-43d8-488f-a075-14a858b0a096
md"""
To generalize derivatives in higher dimensions, we will need to shift our focus from lines to functions.
Indeed, a straight line with slope $f'(x)$ is nothing but a linear function $h \longmapsto f'(x)h$.
So computing a derivative boils down to the following question:

_What is the best linear approximation of my function around a given point?_
"""

# ╔═╡ fd6dd009-2a52-46d1-b1a8-5f094e8c1d98
md"""
## Vector functions
"""

# ╔═╡ 4d9d2f52-c406-4a7c-8b0e-ba5af7ebc3d8
md"""
Let $f: \mathcal{A} \longrightarrow \mathcal{B}$ be a function between two normed vector spaces.
When we say that $f$ is differentiable at $x \in \mathcal{A}$, we mean that there is a _linear function_ $f'(x): \mathcal{A} \longrightarrow \mathcal{B}$ such that for any perturbation $h \in \mathcal{A}$,

$$f(x + h) = f(x) + f'(x)(h) + o(\lVert h \rVert)$$

The linear function $f'(x)$ is called the _derivative_ of $f$ at $x$.
"""

# ╔═╡ de4df88a-2a55-4a02-aeaf-f02242b6c52f
md"""
When $\mathcal{A} = \mathbb{R}^n$ and $\mathcal{B} = \mathbb{R}^m$ are both Euclidean spaces, we can always find a matrix $J_f(x) \in \mathbb{R}^{m \times n}$ that satisfies

$$f'(x)(h) = J_f(x) h$$

In the previous equation, the left hand side is the application of the function $f'(x)$ to the vector $h$, while the right hand side is a product between the matrix $J_f(x)$ and the same vector $h$.
The matrix $J_f(x)$ is called the _Jacobian_ of $f$ at $x$.
"""

# ╔═╡ e22cec4a-03d3-4821-945b-9283e16207a8
md"""
It can be expressed with partial derivatives: if $x = (x_1, ..., x_n)$ and $f(x) = (f_1(x), ..., f_m(x))$, then

$$J_f(x) = \begin{pmatrix}
\frac{\partial f_1(x)}{\partial x_1} & \frac{\partial f_1(x)}{\partial x_2} & \cdots & \frac{\partial f_1(x)}{\partial x_n} \\
\frac{\partial f_2(x)}{\partial x_1} & \frac{\partial f_2(x)}{\partial x_2} & \cdots & \frac{\partial f_2(x)}{\partial x_n} \\
\vdots & \vdots & \ddots & \vdots \\
\frac{\partial f_m(x)}{\partial x_1} & \frac{\partial f_m(x)}{\partial x_2} & \cdots & \frac{\partial f_m(x)}{\partial x_n} \\
\end{pmatrix}$$

However, it is good practice to learn how to manipulate Jacobians in matrix form, without needing to compute individual coefficients.
"""

# ╔═╡ 19fd4ce6-fc2e-4047-b265-7b54e9bbdad4
md"""
# 1. Memory & performance
"""

# ╔═╡ 38a6618a-00e9-4565-aaef-4893afcb3181
md"""
Many people use Julia for high performance scientific computations.
But it takes some knowledge and practice to get to that level.
So buckle up, because your journey to lightning fast code starts... now!

In this section, we discuss two topics:
- How to measure code performance
- How to improve it with a clever use of memory

There are other tricks you can learn, mostly related to types and dispatch, but we will get to them later in the class.
"""

# ╔═╡ 9ba8d153-e2c9-4387-a487-fb5a25f5808b
md"""
## Benchmarking
"""

# ╔═╡ 25d27d5a-dcaa-464c-ba44-9aea9ea8be38
md"""
To start with, let us note that Julia already has a useful built-in macro called `@time`.
When you put it before a function call, it measures the CPU time, memory use and number of allocations required.
"""

# ╔═╡ d0263b55-0f11-4a37-9837-bb4f9e322aa8
@time rand(1000, 1000);

# ╔═╡ d1079990-5d9a-495c-9dbf-d9ea07c5c8f7
md"""
But `@time` has a few drawbacks:
- it only runs the function one time, which means estimates are noisy
- it includes compilation time if the function has never been run before
- it can be biased by [global variables](https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-untyped-global-variables)

Here are some examples.
"""

# ╔═╡ 751234f4-6957-4273-84e9-9d048c756fa7
@time cos.(rand(1000, 1000));

# ╔═╡ 2e4ac856-fe22-426d-b58b-f3adbacdee8a
md"""
The first time you run the previous cell, most of the time will actually be spent compiling the function.
If you run it a second time, the benchmarking result will be completely different.
"""

# ╔═╡ e75e2ea0-bf1a-4519-87a2-efb61736ab44
let
	x = rand(1000, 1000)
	sum(abs2, x)  # run once to compile
	@time sum(abs2, x)
end; 

# ╔═╡ 6ebe2c16-400b-40a0-bec6-e52d2858e83a
md"""
In the previous cell, there is no reason for the sum to allocate anything: this is just an artefact due to the global variable `x`.
"""

# ╔═╡ 9aa600b1-9c39-430a-88d4-169c5d84e145
md"""
For all of these reasons, [`BenchmarkTools.jl`](https://github.com/JuliaCI/BenchmarkTools.jl) is a much better option.
Its `@btime` macro does basically the same job as `@time`, but runs the function several times and circumvents global variables, as long as they are "interpolated" with a `$` sign.
"""

# ╔═╡ 43cfe774-4ed1-4f4f-985a-c261c4d569bf
@btime rand(1000, 1000);

# ╔═╡ 88103471-6f2c-4604-83cc-0d76645776d7
md"""
This benchmark is pretty comparable to the one given by `@time`.
"""

# ╔═╡ 5d9c5359-d0a9-4a0a-853e-3fd0028f23df
@btime sin.(rand(1000, 1000));

# ╔═╡ 6bacff8b-ac8c-46b0-adeb-7d8b1aab85f2
md"""
This benchmark does not include compilation time, because the first run of the function is just one of many.
"""

# ╔═╡ 86399001-e7c4-4733-b476-503650c11e0c
let; x = randn(1000, 1000); @btime sum(abs2, $x); end; 

# ╔═╡ 0817247f-f9ae-48cc-9966-dd451c136d43
md"""
This benchmark shows zero allocation, which is what we actually expect.
"""

# ╔═╡ 1d1d83b0-8669-452c-90ca-26c1396c822a
md"""
!!! danger "Task"
	Write a function that compares matrix addition and multiplication based on the time per operation.
"""

# ╔═╡ 2ded206d-e563-4752-a0b1-19402e1e4f52
hint(md"
Unlike `@btime`, which prints a bunch of information but returns the result of the function, `@belapsed` actually returns the elapsed CPU time.
Don't forget to interpolate the arguments.

Remember that for a given size $n$, addition requires $n^2$ operations while multiplication requires $2n^3$ operations.
You should divide the output of `@belapsed` by these factors.
")

# ╔═╡ 5b47082b-d080-4243-90a2-5d98b82451d4
function compare_add_mul(n)
	# write your code here
end

# ╔═╡ 89b1f353-523a-4a4c-aee4-9b6e36b944fb
compare_add_mul(10)

# ╔═╡ 4b1a6ce2-b57d-466a-97cd-35036689fe43
compare_add_mul(100)

# ╔═╡ fe1f4c0e-becb-4058-a069-be213622aa92
md"""
!!! danger "Task"
	Plot the normalized time per operation for matrix addition and multiplication, using sizes $n \in \{3, 10, 30, 100, 300\}$. Comment on what you observe.
"""

# ╔═╡ eb0d58fc-3348-47f9-966c-e7f9f316ddb7
hint(md"
The loop over $n$ may take a little time, don't be scared.
You can put the `@progress` macro from [`ProgressLogging`](https://github.com/JuliaLogging/ProgressLogging.jl) in front of the `for` keyword if you want to track its progress.

Use the [`Plots.jl`](https://github.com/JuliaPlots/Plots.jl) package for visualization.
The function `plot` will let you create an empty plot with the properties you need (like `xscale=:log10` or `xlabel=\"size\"`).
The function `scatter!` will allow you to modify it by adding series of dots.
")

# ╔═╡ 11f3c0d4-0609-4446-aa84-4db3d93e93b0
# write your code here

# ╔═╡ c22a890c-a308-4d1b-be4b-d78f93693a9c
md"""
## Memory management
"""

# ╔═╡ 48511240-20d1-41b6-bc7b-a8ecfc3aa06d
md"""
Since Julia is a high-level language, you don't need to care about memory to write correct code.
New objects are allocated transparently, and once you no longer need them, the Garbage Collector (GC) automatically frees their memory slots.

However, in many cases, memory management is a performance bottleneck.
If you want to write fast code, you might need to work "in place" (mutating existing arrays), as opposed to "out of place" (creating many temporary arrays).
This is emphasized [several](https://docs.julialang.org/en/v1/manual/performance-tips/#Measure-performance-with-[@time](@ref)-and-pay-attention-to-memory-allocation) [times](https://docs.julialang.org/en/v1/manual/performance-tips/#Pre-allocating-outputs) in the Julia performance tips.
"""

# ╔═╡ ffb8851d-c7e8-47ae-ac9d-96baf0774ca3
md"""
A common pattern is broadcasted operations, which can look like `x .+ y` (the `.` goes in front for short operators) or `exp.(x)` (the `.` goes behind for functions).
They allow you to work directly with array components, instead of allocating new arrays.
This leads to performance gains, as explained [here](https://docs.julialang.org/en/v1/manual/performance-tips/#More-dots:-Fuse-vectorized-operations).
"""

# ╔═╡ a6eb6028-acca-447a-9e55-e60ecd3c6f84
md"""
!!! danger "Task"
	Try to explain the difference in speed and memory use between the following code snippets.
"""

# ╔═╡ f2bedf2b-2dfe-4392-ba2a-add10882af07
let
	x = rand(100, 100)
	y = rand(100, 100)
	@btime $x += 2 * $y
end;

# ╔═╡ f504954b-ac63-4843-8891-b1ca0e5ae58b
let
	x = rand(100, 100)
	y = rand(100, 100)
	@btime $x .+= 2 .* $y
end;

# ╔═╡ 1da14b09-5d62-42cc-b9b4-a5a6ddc34181
hint(md"`x += y` is syntactically equivalent to `x = x + y`.")

# ╔═╡ a9472534-e32b-4323-8dfc-e00b9f31f8e0
md"""
> Write your answer here
"""

# ╔═╡ ecfe4d79-b1c6-4a6d-a9d7-a563a26e32cd
md"""
Whenever possible, you may also want to use or write mutating versions of critical functions.
By convention, such functions get a `!` suffix to warn about their side effects.
"""

# ╔═╡ 83423082-2d3a-42a1-b1db-ed267399cb31
md"""
!!! danger "Task"
	Write a function that compares mutating and non-mutating matrix multiplication.
"""

# ╔═╡ fb416cfd-f9ee-4d7d-9e83-056e81c422e0
hint(md"
Take a look at the documentation for the three-argument function `mul!(C, A, B)`, and compare it with `A * B`.
Don't forget to interpolate the arguments
")

# ╔═╡ d0020df6-62a1-4000-b8cf-ceacb8014a0b
# write your code here

# ╔═╡ d8301150-7b08-45b6-a986-d21574eee91b
md"""
# 2. Autodiff works... almost always
"""

# ╔═╡ 1f40437c-0419-4fc0-96ae-a8130efaa36a
md"""
## Differentiable programming
"""

# ╔═╡ 8419603a-3c5c-45a0-9a70-4a74347a7ad7
md"""
In scientific computing, differentiation plays a central role.
Gradients, Jacobians and Hessians are used everywhere, from optimization algorithms to differential equations or sensitivity analysis.
Unfortunately, the functions involved may be very complicated, sometimes without an explicit formula.

That is where _differentiable programming_ comes into play: the idea that you can use computer programs to represent complex functions, and then differentiate through these programs with automatic differentiation.
"""

# ╔═╡ 4f9d3c2e-1ec8-4337-b49b-e0dc1d63bc62
md"""
The Julia ecosystem is very interesting in this regard, because its autodiff packages are compatible with a large fraction of the language itself.
Conversely, major Python autodiff packages like `PyTorch` or `TensorFlow` expect the user to only manipulate custom tensors, which restricts their generality. 

An extensive list of packages is available on the JuliaDiff [web page](https://juliadiff.org/).
Right now, the most widely used are probably:
- [`ForwardDiff.jl`](https://github.com/JuliaDiff/ForwardDiff.jl) for forward mode autodiff
- [`Zygote.jl`](https://github.com/FluxML/Zygote.jl) for reverse mode autodiff

Here is an example showing how to use them for Jacobian computation.
"""

# ╔═╡ 7476a638-5eca-47cc-9a01-41f30b9dbf9d
function powersum(x; p=5)
	return sum(x .^ i for i in 0:p)
end

# ╔═╡ d0d580d4-8e92-4d46-8177-67f52fbb3934
powersum(1:3)

# ╔═╡ c5784ec1-17cf-4897-8cd3-ff81998b9d9c
let
	x = rand(3)
	J1 = ForwardDiff.jacobian(powersum, x)
	J2 = Zygote.jacobian(powersum, x)[1]
	J1, J2
end

# ╔═╡ 387d145f-e77c-4e13-89b7-fc8733215694
md"""
## The limitations of autodiff packages
"""

# ╔═╡ 3790f106-9895-4425-a16f-5c5e0857e99e
md"""
Alas, every autodiff package comes with its own limitations.
Here are the main ones you should be aware of:
- `ForwardDiff.jl` requires functions that work with generic number types, not just `Float64` for example. The reason is that forward mode relies on numbers of type `Dual` (which store both a quantity and its derivative)
- `Zygote.jl` requires functions that avoid mutating arrays. The reason is that array mutation gives rise to several nodes in the computational graph for a single variable in the code, which is complicated to handle from an implementation perspective. 
"""

# ╔═╡ 945a16d3-805c-40c9-9166-5120743bd3d7
md"""
!!! danger "Task"
	Write a function that does the same computation as `powersum`, but for which `ForwardDiff.jl` will throw an error.
"""

# ╔═╡ 728c8956-9911-47d5-a021-df224e3f5b90
hint(md"
Modify the type annotation of `x` to avoid accepting generic numbers.
")

# ╔═╡ 3716d3cc-8706-41bf-873d-193543cb0514
function powersum_breakforwarddiff(x; p=5)
	# write your code here
end

# ╔═╡ 87c72b22-8c81-4062-8a9c-40902f83a623
powersum(1:3), powersum_breakforwarddiff(1:3)

# ╔═╡ 1362cd95-6a87-44e3-980d-014496afce85
let
	x = rand(3)
	# this should throw "No method matching powersum_breakforwarddiff(Vector{Dual})"
	ForwardDiff.jacobian(powersum_breakforwarddiff, x)
end

# ╔═╡ 46075912-60b7-46d2-88c9-a13a8b015e0b
md"""
!!! danger "Task"
	Write a function that does the same computation as `powersum`, but for which `Zygote.jl` will throw an error.
"""

# ╔═╡ f8ba8857-ece1-4cec-b7f2-2a8bc8bfb1d9
hint(md"
Set up an answer vector `y` initialized to `ones(eltype(x), length(x))`, and write a loop that updates it with successive powers of `x`.
")

# ╔═╡ cf13543a-9dd4-40ef-9523-5953e9db2c78
function powersum_breakzygote(x; p=5)
	# write your code here
end

# ╔═╡ 0736648c-a181-4352-8b4e-bacf745fda64
powersum(1:3), powersum_breakzygote(1:3)

# ╔═╡ 95dd7822-ef43-4629-bb42-ddb15bd1f965
let
	x = rand(3)
	# this should throw "Mutating arrays is not supported..."
	Zygote.jacobian(powersum_breakzygote, x)[1]  
end

# ╔═╡ 786b7ea2-7827-4cab-abbb-786abe935cc3
md"""
Usually, it is quite easy to write type-generic code that works with `ForwardDiff.jl`.
On the other hand, sometimes mutation is inevitable for performance reasons, which means `Zygote.jl` will be mad at us.
So how do we get the best of both worlds, _performance AND differentiability_?
The answer is: by teaching `Zygote.jl` a custom differentiation rule.
"""

# ╔═╡ 4440f39c-51e5-4ffd-8031-96d4a760270c
md"""
## The role of custom differentiation rules
"""

# ╔═╡ bfb3280e-638f-4e8f-8e37-d5f8fd75541d
md"""
Autodiff packages have two main ingredients:

- a set of differentiation rules for built-in functions (`+`, `-`, `*`, `/`, `exp`, ...)
- a way to compose these basic functions and their derivatives (using the chain rule)
"""

# ╔═╡ 7f6e72fd-aacc-47a8-a496-25794c60343c
md"""
The [`ChainRules.jl`](https://github.com/JuliaDiff/ChainRules.jl) package is an attempt to provide unified differentiation rules for Julia's whole autodiff ecosystem.
It contains rules for most of the functions in the Julia standard library, but also allows users to define custom rules.

Since `Zygote.jl` cannot handle mutation out of the box, we must define a custom reverse rule for any function involving mutation.
This will allow `Zygote.jl` to differentiate it "blindly", without looking inside.
"""

# ╔═╡ 55160454-2738-4911-be15-29f484f610db
md"""
Without further ado, we show the definition of a custom reverse rule for the following function.
It probably similar to the one that you used to break `Zygote.jl` earlier, so of course it will behave in the same way until we give it a differentiation rule.
"""

# ╔═╡ e90098ec-a9c3-4204-95f7-88adeb74ee50
function powersum_okayzygote(x; p=5)
	y = zeros(eltype(x), length(x))
	for i in 0:p
		y .+= x .^ i
	end
	return y
end

# ╔═╡ 7b92051d-4015-4e22-b6b9-41462e2cc54f
powersum(1:3), powersum_okayzygote(1:3)

# ╔═╡ 4eef090f-29b1-44e1-929a-98162719ae93
md"""
If we want to teach a derivative to `Zygote.jl`, we have to know how to compute it.
"""

# ╔═╡ 32f6a219-f69b-4085-ba4b-5c7dc3ca2155
function powersum_okayzygote_jacobian(x; p=5)
	J = zeros(eltype(x), length(x), length(x))
	for i in 1:p
		J .+= Diagonal(i .* (x .^ (i-1)))
	end
	return J
end

# ╔═╡ ffffadbb-5fcd-443d-97fb-b6d372029814
md"""
Custom reverse rules are created by writing a new method for the `ChainRulesCore.rrule` function.
For technical reasons, the reverse rule does not work with the Jacobian directly, but instead computes _vector-Jacobian products_ (VJPs) of the form $v^\top J_f(x)$ (see section 4).
"""

# ╔═╡ 19198826-15a0-432d-abe2-ae5ead6869f5
function ChainRulesCore.rrule(fun::typeof(powersum_okayzygote), x; p=5)
	y = powersum_okayzygote(x; p=p)
	J = powersum_okayzygote_jacobian(x; p=p)
	function vector_jacobian_product(v)
		return (NoTangent(), J' * v)
	end
	return y, vector_jacobian_product
end

# ╔═╡ 0d762ed4-dfb9-433f-8ded-1ae653ad87c2
begin
	rrule_syntax = md"""
	The arguments given to `rrule` are all the arguments of the function we want to differentiate (in this case `powersum_okayzygote`), plus an additional first argument `fun` which is a function.
	We define our method to only accept the type of `powersum_okayzygote` itself, so that autodiff packages can recognize it and dispatch on the appropriate rule for each function.
	So we actually do not need `fun` in the body of the `rrule`, and we could also have used an empty argument:
	```
	function ChainRulesCore.rrule(::typeof(powersum_okayzygote), x; p=5)
		...
	end
	```

	The output of `rrule` is a couple that contains 1) the return value of the function `powersum_okayzygote` and 2) a nested function called `vector_jacobian_product`, which is used during reverse mode autodiff.

	This nested function computes a VJP for each positional argument of `rrule`, in this case `fun` and `x`.
	By convention, we do not compute VJPs for keyword arguments, since one does not usually differentiate with respect to those.
	Most of the time, the VJP with respect to `fun` is `NoTangent()`, since the function `fun` rarely has internal parameters.
	On the other hand, the VJP with respect to `x` is the interesting part.
	It is given as `J' * v` instead of `v' * J` because we want a column vector instead of a row vector.
	We precompute the Jacobian matrix `J` outside of the `vector_jacobian_product` because it can be reused with several vectors `v`.
	"""
	Foldable("Unfold to understand the syntax of the reverse rule", rrule_syntax)
end

# ╔═╡ ef28a71e-74f4-40dd-a72d-1a51628fd01b
md"""
Thanks to this new rule, `Zygote.jl` is now able to differentiate through our mutating power sum.
"""

# ╔═╡ f9ca3e33-243c-45c8-b646-587aa7d2d902
md"""
By now, you may have a question on your mind.
What is the point of autodiff if I need to work out derivatives by hand anyway?
Indeed, when `Zygote.jl` is unable to handle your function, you may need to provide derivatives manually.

But then, you can insert your function within a larger computational graph (like a neural network), and the rest of the derivatives will be computed without your help.
In other words, your efforts are only required for a few performance-critical functions, and the rest is taken care of automatically.
"""

# ╔═╡ c7a0dbbe-89e6-4759-a57f-b367fbeba62e
md"""
Let us see what that looks like by composing several functions.
"""

# ╔═╡ 9a8f7f42-2677-43ff-a280-3b75df6258e1
function big_composition(x)
	y = vcat(x, -x)
	z = powersum_okayzygote(x)
	return sum(abs, z)
end

# ╔═╡ 7b3551c2-22f7-47dd-82dc-b817d7e0f1fb
md"""
Isn't that wonderful?
"""

# ╔═╡ f6330892-3379-4e0d-a007-c451a465bd06
md"""
# 3. Application to linear regression
"""

# ╔═╡ 6d848043-e5bc-4beb-a18a-004d4cac5c23
md"""
Linear regression is perhaps the most basic form of machine learning.
Given a matrix of features $M \in \mathbb{R}^{m \times n}$ and a vector of targets $y \in \mathbb{R}^m$, we approximate $y$ by $M x$, where $x \in \mathbb{R}^n$ is a vector of parameters (feature weights).
"""

# ╔═╡ fc84dce4-779c-4377-af2a-cda7e453f382
md"""
## Computing the squared errors
"""

# ╔═╡ d76d5ddc-fe59-47f4-8b56-6f704b486ebc
md"""

One way to measure the quality of the approximation for a given $x$ is to compute the squared error on all components of $y$.
Let us denote by $\odot$ the componentwise product between vectors (which is the same as `.*` in Julia).
We define the function

$$f: x \in \mathbb{R}^n \longmapsto (Mx - y) \odot (Mx - y) = \begin{pmatrix} (Mx - y)_1^2 \\ \vdots \\ (Mx - y)_m^2 \end{pmatrix} \in \mathbb{R}^m$$
"""

# ╔═╡ 9ef1e014-5a7d-4b17-98de-0cf51d788bfa
md"""
!!! danger "Task"
	Implement the function $f$ in a way that does not mutate arrays.
"""

# ╔═╡ f8cd5dce-6a4c-4c6c-b2d5-7ec56132e95e
function f(x; M, y)
	# write your code here
end

# ╔═╡ c7ee9795-2c7a-480a-9269-440a9227c591
let
	n, m = 3, 5
	M = rand(m, n)
	y = rand(m)
	x = rand(n)
	f(x; M=M, y=y)
end

# ╔═╡ 28f31ef9-27ea-4e94-8f03-89b0f6cfa0d1
md"""
!!! danger "Task"
	Implement the function $f$ in the most efficient way you can, by pre-allocating and mutating the output vector `e`.
	Compare the performance of both implementations.
"""

# ╔═╡ 1676ec54-bd96-4892-aa08-3ae831b537bb
hint(md"Modify `e` step-by-step: start with $Mx$, then $Mx-y$, and finally $(Mx-y) \odot (Mx-y)$.")

# ╔═╡ ea16d4c6-d6e4-46fa-a721-fa5a0f2ff021
function f!(e, x; M, y)
	# write your code here
end

# ╔═╡ bd37c58d-8544-40b1-a0b5-ea03ec5692a8
let
	n, m = 3, 5
	M = rand(m, n)
	y = rand(m)
	x = rand(n)
	e = rand(m)
	f(x; M=M, y=y), f!(e, x; M=M, y=y)
end

# ╔═╡ 5bbd690b-6a98-4dbf-a8c4-581ac77a4da5
let
	n, m = 3, 5
	M = rand(m, n)
	y = rand(m)
	x = rand(n)
	e = rand(m)
	@btime f($x; M=$M, y=$y)
	@btime f!($e, $x; M=$M, y=$y)
end;

# ╔═╡ cc224a30-81bf-4a2c-b636-40ff5c941bb6
md"""
## Differentiating the squared errors
"""

# ╔═╡ 3d20c24c-469b-4f0d-9936-705e42033ded
md"""
If we want to find the best possible $x$, we can do it by minimizing the sum of the components of $f(x)$ (_e.g._ with gradient descent).
We may also wish to use the function $f$ within a neural network.
In both cases, it is essential to differentiate $f$ with respect to its input $x$ (assuming $M$ and $y$ are fixed).
"""

# ╔═╡ bf6c5fc8-8283-46d4-aa67-416d53f7d315
md"""
!!! danger "Task"
	Try to compute the Jacobian of `f` and `f!` with `Zygote.jl`.
"""

# ╔═╡ d00bf3fd-9bd8-4b11-b755-a85f0f8644cb
let
	n, m = 3, 5
	M = rand(m, n)
	y = rand(m)
	x = rand(n)
	Zygote.jacobian(x -> f(x; M=M, y=y), x)[1]
end

# ╔═╡ a80b3a0f-53d1-473e-9bea-2494a85ac511
let
	n, m = 3, 5
	M = rand(m, n)
	y = rand(m)
	x = rand(n)
	e = rand(m)
	# this should throw "Mutating arrays is not supported..."
	Zygote.jacobian(x -> f!(e, x; M=M, y=y), x)[1]
end

# ╔═╡ ab398337-adb5-48fa-ae1b-4c9499438097
md"""
Once you are done with this section, you will be able to do this without encountering an error. Yay!
"""

# ╔═╡ ae7b2114-de91-4f1b-8765-af5e02cc1b63
md"""
!!! danger "Task"
	Work out the derivative of the function $f$ at a point $x$.
"""

# ╔═╡ e4aedbd4-a609-4eaf-812b-d2f3d6f4df3d
hint(md"
Write $f(x+h)$ as a componentwise product, and then expand it as you would do with a regular product.
You are allowed to do that since the componentwise product is bilinear.
Then identify three parts in the resulting expression: $f(x)$, a linear function of $h$, and a term that is of order $\lVert h \rVert^2$ (in other words, negligible).
")

# ╔═╡ b8974b20-d8dc-4109-a64e-585c7afdb484
md"""
> Write your answer here
"""

# ╔═╡ bd10d753-eea6-4798-939c-8e5551d40c5c
md"""
!!! danger "Task"
	Deduce the Jacobian matrix of the function $f$ at a point $x$. Check that its size is coherent.
"""

# ╔═╡ 2f95afd6-1418-44bb-9868-970dbe888500
hint(md"
A componentwise product between two vectors $a \odot b$ can also be interpreted as the multiplication by a diagonal matrix $D(a) b$.
Using this with $a = 2(Mx - y)$ and $b = Mh$ should help you recognize the Jacobian matrix.
For checking, remember that $M$ has size $m \times n$.
")

# ╔═╡ 06e91432-935f-4d7c-899f-d7968a10a78e
md"""
> Write your answer here
"""

# ╔═╡ c7efc656-ae9b-4eef-b0cd-3afe3852d396
md"""
!!! danger "Task"
	Implement a function computing the Jacobian matrix $J_f(x)$ at a point $x$.
	Check your result using finite differences.
"""

# ╔═╡ ca4b41dd-353e-498d-a461-648c582cb999
hint(md"You may want to use the `Diagonal` constructor from [`LinearAlgebra`](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/).")

# ╔═╡ c5fc8f3a-ed90-41ec-b4b9-1172a41e3adc
function Jf(x; M, y)
	# write your code here
end

# ╔═╡ 40e13883-dd9a-43b9-9ef7-1069ef036846
let
	n, m = 3, 5
	M = rand(m, n)
	y = rand(m)
	x = rand(n)
	h = 0.001 .* rand(n)
	diff1 = f(x + h; M=M, y=y) .- f(x; M=M, y=y)
	diff2 = Jf(x; M=M, y=y) * h
	diff1, diff2
end

# ╔═╡ 7c7bdbd9-edd5-4142-a765-4c498761f7e7
md"""
## Custom rule, from slow to fast
"""

# ╔═╡ 8569cd7b-890f-4b04-a6d5-c92a70a226ab
md"""
!!! danger "Task"
	Define a custom reverse rule for `f2!` (because of a Pluto bug we couldn't use `f!` directly). Check that `Zygote.jl` is now able to compute its Jacobian.
"""

# ╔═╡ cf250e37-ed37-47cd-b689-8e2596f9fdc5
f2!(e, x; M, y) = f!(e, x; M, y)

# ╔═╡ 8f46db4a-cc94-4497-aad8-0fc4b0cfa1e3
hint(md"Beware: you will need to give a VJP with respect to `rrule` arguments `fun`, `e` and `x`. Use `NoTangent()` for `fun` and `ZeroTangent()` for `e`.")

# ╔═╡ dccf9f6d-82a6-423c-bbe5-22c5a8c2f5e4
function ChainRulesCore.rrule(::typeof(f2!), e, x; M, y)
	# write some code here
	function vector_jacobian_product(v)
		# and some code there
	end
	return e, vector_jacobian_product
end

# ╔═╡ ffd6df27-c0e5-44be-aee9-2c7a9d4fb5c0
let
	x = rand(3)
	ChainRulesCore.rrule(powersum_okayzygote, x)  # trick Pluto's dependency handler
	J = powersum_okayzygote_jacobian(x)
	J_zygote = Zygote.jacobian(powersum_okayzygote, x)[1]
	J, J_zygote
end

# ╔═╡ 0cee5c93-266c-4be3-9997-20728cf11921
let
	x = rand(3)
	ChainRulesCore.rrule(powersum_okayzygote, x)  # trick Pluto's dependency handler
	Zygote.gradient(big_composition, x)[1]
end

# ╔═╡ bbe25d4e-952b-4ed5-b20e-24b3dcd30495
md"""
!!! danger "Task"
	Uncomment and run the following cell once the `rrule` above is complete.
"""

# ╔═╡ 77eac64f-eac5-4d12-8acf-5b5070e60858
# let
# 	n, m = 3, 5
# 	M = rand(m, n)
# 	y = rand(m)
# 	x = rand(n)
# 	e = rand(m)
# 	ChainRulesCore.rrule(f2!, e, x; M=M, y=y)  # trick Pluto's dependency handler
# 	J1 = Zygote.jacobian(x -> f(x; M=M, y=y), x)[1]
# 	J2 = Zygote.jacobian(x -> f2!(e, x; M=M, y=y), x)[1]
# 	J1, J2
# end

# ╔═╡ aa4194d6-2f8c-4367-850e-22ebcf1b72e4
md"""
Although we managed to get reverse mode autodiff working, the end result is still not very satisfactory.
On the one hand, the function `f2!` is fast and requires zero allocation.
On the other hand, the custom reverse rule still involves computing and storing a full Jacobian matrix, which is pretty expensive.
Luckily, we can do better.
"""

# ╔═╡ f66a0ea7-70fd-4340-8b02-6fbaab847dfc
md"""
!!! danger "Task"
	Explain why a VJP can be computed for the function $f$ without ever storing the full Jacobian.
"""

# ╔═╡ 8cca11ed-a61c-4cc8-af4b-350137073756
hint(md"Try to think in terms of computer program instead of mathematics. Describe the sequence of intermediate operations that you would perform for each of these computations.")

# ╔═╡ 7144c6c8-79dd-437d-a201-bac143f6a261
md"""
> Write your answer here
"""

# ╔═╡ 45765f4a-536d-4e9d-be9d-144b7ccd4dcf
md"""
!!! danger "Task"
	Implement a VJP function for $f$, following the efficient method you just suggested.
"""

# ╔═╡ df89f509-cfd7-46b3-9dd1-cdcfcea68053
hint(md"
Now you should revert to `.*` for componentwise products instead of using diagonal matrices.
Remember that you must return a column vector, so technically $J_f(x)^\top v$ instead of $v^\top J_f(x)$.
")

# ╔═╡ 0b51e23e-a015-4e86-ba48-6475a9ee9779
function f_vjp(v, x; M, y)
	# write your code here
end

# ╔═╡ 14dcad57-23ae-4905-aac4-d29066f2a085
md"""
!!! danger "Task"
	Check the correctness of your VJP function against the naive version provided below.
"""

# ╔═╡ 06a59777-b6ec-4808-9105-7a2542a629ea
function f_vjp_naive(v, x; M, y)
	J = Jf(x; M=M, y=y)
	return v' * J
end

# ╔═╡ 9222d644-5d20-474a-83db-4b2e3bed45e2
# write your code here

# ╔═╡ c511e1c4-0306-46c7-800f-8257266c0091
md"""
!!! danger "Task"
	Compare the performance of both VJP implementations.
"""

# ╔═╡ c79e7017-4acc-4562-817a-50245ce654dc
# write your code here

# ╔═╡ ac115404-0115-4c94-9b51-9a8674ac4b05
md"""
Now, if you wanted to, you could implement an `rrule` for `f2!` that uses `f_vjp`, and observe that Jacobian computations are accelerated.
And as it turns out, you could even go one step further.
"""

# ╔═╡ dd01d4b4-b05a-43a3-9b76-65e13076535f
md"""
!!! danger "Task"
	Explain how yet another speed up can be achieved within the `rrule` by mutualizing computations between $f$ and its VJP.
"""

# ╔═╡ 766e1909-5063-4ce2-821d-1f93be4db789
hint(md"Try to identify a quantity that appears in both. Do we really need to compute it twice?")

# ╔═╡ 2b83cccd-bdaf-4481-a7f5-391434220bd5
md"""
> Write your answer here
"""

# ╔═╡ 69a9ec45-d2ff-4362-9c3c-5c004e46ceb3
md"""
# 4. Going further
"""

# ╔═╡ cc167cfd-b776-4280-a308-d5908ceaec4b
md"""
## Why VJPs?
"""

# ╔═╡ 8923a5ad-ddba-4ae2-886e-84526a3521ba
md"""
In concrete applications, the dimensions $n$ and $m$ often make it impossible to store a full Jacobian (of size $m \times n$) in memory.
As a result, autodiff systems only manipulate Jacobians "lazily" by computing their products with vectors.

In machine learning, we are mostly interested in loss functions with many inputs ($n \gg 1$) and a single scalar output ($m = 1$).
This means the Jacobian matrix only has one row, and it can be seen as the transpose of the gradient: $J_f(x) = \nabla f(x)^\top$.
Thus we only need one VJP (with $v = 1$) to retrieve the gradient.
"""

# ╔═╡ e1b9f114-58e7-4546-a3c0-5e07fb1665e7
md"""
!!! danger "Task"
	How many VJPs would it take to compute the full Jacobian for a function $f : \mathbb{R}^n \longrightarrow \mathbb{R}^m$, and which vectors $v$ should you choose?
"""

# ╔═╡ ba07ccda-ae66-4fce-837e-00b2b039b404
md"""
> Write your answer here
"""

# ╔═╡ d0ae8c14-b341-4220-8a1c-79fed9758f64
md"""
## Why reverse mode?
"""

# ╔═╡ f843b77d-8160-4d87-8641-eeb04549af8f
md"""
Let us now consider a composite function $f = f_3 \circ f_2 \circ f_1$ with $3$ layers.
The _chain rule_ yields the following derivative:

$$f'(x) = f_3'((f_2 \circ f_1)(x)) \circ f_2'(f_1(x)) \circ f_1'(x)$$

In the Euclidean case, we can re-interpret this function composition as a matrix product:

$$\underbrace{J_f(x)}_J = \underbrace{J_{f_3}((f^2 \circ f^1) (x))}_{J_3} ~ \underbrace{J_{f_2}(f^1(x))}_{J_2} ~ \underbrace{J_{f_1}(x)}_{J_1}$$
"""

# ╔═╡ 9b34a8f9-6afa-4712-bde8-a94f4d5e7a33
md"""
But again, storing and multiplying full Jacobian matrices is expensive in high dimension.
Assuming we know how to manipulate the $J_k$ lazily, can we do the same for $J$?
In other words, can we deduce a VJP for $f$ based on a  VJP for the $f_k$?

The answer is yes, but only if we do it in the right direction.
Indeed, we can accumulate the product from last to first layer:

$$v^\top J = v^\top J^3 J^2 J^1 \quad \implies \quad \begin{cases} v^3 = v^\top J^3 \\ v^2 = (v^3)^\top J^2 \\ v^1 = (v^2)^\top J^1 \end{cases}$$

This is why reverse mode autodiff uses VJPs, as shown in the `ChainRulesCore.rrule` syntax.
They allow efficient propagation of derivative information from the last layer to the first, which is particularly appropriate to compute gradients of high-dimensional loss functions.

Congrats, you now know how neural networks are trained!
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
ProgressLogging = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[compat]
BenchmarkTools = "~1.3.1"
ChainRulesCore = "~1.15.5"
ForwardDiff = "~0.10.32"
Plots = "~1.33.0"
PlutoTeachingTools = "~0.2.3"
PlutoUI = "~0.7.40"
ProgressLogging = "~0.1.4"
Zygote = "~0.6.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "0358675a58c2ec698bf356c09ed6e927f5069cd9"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

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

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "4c10eee4af024676200bc7752e536f858c6b8f93"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.1"

[[deps.BitFlags]]
git-tree-sha1 = "84259bb6172806304b9101094a7cc4bc6f56dbc6"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.5"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ChainRules]]
deps = ["Adapt", "ChainRulesCore", "Compat", "Distributed", "GPUArraysCore", "IrrationalConstants", "LinearAlgebra", "Random", "RealDot", "SparseArrays", "Statistics", "StructArrays"]
git-tree-sha1 = "a5fd229d3569a6600ae47abe8cd48cbeb972e173"
uuid = "082447d4-558c-5d27-93f4-14fc19e9eca2"
version = "1.44.6"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "dc4405cee4b2fe9e1108caec2d760b7ea758eca2"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.5"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "1833bda4a027f4b2a1c984baddcf755d77266818"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.1.0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "5856d3031cdb1f3b2b6340dfdc66b6d9a149a374"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.2.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "1106fa7e1256b402a86a8e7b15c00c85036fef49"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.11.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "992a23afdb109d0d2f8802a30cf5ae4b1fe7ea68"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.11.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "5158c2b41018c5f7eb1470d558127ac274eca0c9"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "87519eb762f85534445f5cda35be12e32759ee14"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.4"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "187198a4ed8ccd7b5d99c41b69c679269ea2b2d4"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.32"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GPUArrays]]
deps = ["Adapt", "GPUArraysCore", "LLVM", "LinearAlgebra", "Printf", "Random", "Reexport", "Serialization", "Statistics"]
git-tree-sha1 = "45d7deaf05cbb44116ba785d147c518ab46352d7"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "8.5.0"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "6872f5ec8fd1a38880f027a26739d42dcda6691f"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.2"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "cf0a9940f250dc3cb6cc6c6821b4bf8a4286cf9c"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.66.2"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "0eb5ef6f270fb70c2d83ee3593f56d02ed6fc7ff"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.68.0+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "4abede886fcba15cd5fd041fef776b230d004cee"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.4.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

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

[[deps.IRTools]]
deps = ["InteractiveUtils", "MacroTools", "Test"]
git-tree-sha1 = "af14a478780ca78d5eb9908b263023096c2b9d64"
uuid = "7869d1d1-7146-5819-86e3-90919afe41df"
version = "0.4.6"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "b3364212fb5d870f724876ffcd34dd8ec6d98918"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.7"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

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

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0f960b1404abb0b244c1ece579a0ec78d056a5d1"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.15"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

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

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

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

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "5d4d2d9904227b8bd66386c1138cf4d5ffa826bf"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.9"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "dedbebe234e06e1ddad435f5c6f4b85cd8ce55f7"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.2.2"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "6872f9594ff273da6d13c7c1a1545d5a8c7d0c1c"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.6"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "fa44e6aa7dfb963746999ca8129c1ef2cf1c816b"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.1.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e60321e3f2616584ff98f0a4f18d98ae6f89bbb3"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.17+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "3d5bf43e3e8b412656404ed9466f1dcbf7c50269"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "8162b2f8547bc23876edd0c5181b27702ae58dce"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.0.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "6062b3b25ad3c58e817df0747fc51518b9110e5f"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.33.0"

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
git-tree-sha1 = "d8be3432505c2febcea02f44e5f4396fae017503"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.3"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "a602d7b0babfca89005da04d89223b867b55319f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.40"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.ProgressLogging]]
deps = ["Logging", "SHA", "UUIDs"]
git-tree-sha1 = "80d919dee55b9c50e8d9e2da5eeafff3fe58b539"
uuid = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
version = "0.1.4"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "e7eac76a958f8664f2718508435d058168c7953d"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.3"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "22c5201127d7b243b9ee1de3b43c408879dff60f"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.3.0"

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

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "efa8acd030667776248eabb054b1836ac81d92f0"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.7"

[[deps.StaticArraysCore]]
git-tree-sha1 = "ec2bd695e905a3c755b33026954b119ea17f2d22"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.3.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArraysCore", "Tables"]
git-tree-sha1 = "8c6ac65ec9ab781af05b08ff305ddc727c25f680"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.12"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "7149a60b01bf58787a1b83dad93f90d4b9afbe5d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.8.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

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

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.Zygote]]
deps = ["AbstractFFTs", "ChainRules", "ChainRulesCore", "DiffRules", "Distributed", "FillArrays", "ForwardDiff", "GPUArrays", "GPUArraysCore", "IRTools", "InteractiveUtils", "LinearAlgebra", "LogExpFunctions", "MacroTools", "NaNMath", "Random", "Requires", "SparseArrays", "SpecialFunctions", "Statistics", "ZygoteRules"]
git-tree-sha1 = "a789623d84d72551b791bbd9daae37cc1fc0f7ad"
uuid = "e88e6eb3-aa80-5325-afca-941959d7151f"
version = "0.6.48"

[[deps.ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "8c1a8e4dfacb1fd631745552c8db35d0deb09ea0"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.2"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╠═ddbba011-f413-4804-b29b-fdc4efe2b3b3
# ╠═9a1453a3-bfad-4212-ac19-a4b6c7df5b16
# ╟─9f6254b5-bc06-469c-a0ef-5ee31ac75233
# ╠═ddbf8ae6-39b6-11ed-226e-0d38991ed784
# ╠═f447c167-2bcb-4bf3-86cd-0f40f4e54c97
# ╟─a405d214-4348-4692-999e-0e890bd91e5d
# ╟─d19834fc-edd1-433b-8bfc-6022fd7e3239
# ╟─7493915c-53b4-4284-bb7f-33cac680f759
# ╟─1cfba628-aa7b-4851-89f1-84b1a45802b3
# ╟─3829f016-a7cd-4ce6-b2d4-1c84da8fdb97
# ╟─755ff203-43d8-488f-a075-14a858b0a096
# ╟─fd6dd009-2a52-46d1-b1a8-5f094e8c1d98
# ╟─4d9d2f52-c406-4a7c-8b0e-ba5af7ebc3d8
# ╟─de4df88a-2a55-4a02-aeaf-f02242b6c52f
# ╟─e22cec4a-03d3-4821-945b-9283e16207a8
# ╟─19fd4ce6-fc2e-4047-b265-7b54e9bbdad4
# ╟─38a6618a-00e9-4565-aaef-4893afcb3181
# ╟─9ba8d153-e2c9-4387-a487-fb5a25f5808b
# ╟─25d27d5a-dcaa-464c-ba44-9aea9ea8be38
# ╠═d0263b55-0f11-4a37-9837-bb4f9e322aa8
# ╟─d1079990-5d9a-495c-9dbf-d9ea07c5c8f7
# ╠═751234f4-6957-4273-84e9-9d048c756fa7
# ╟─2e4ac856-fe22-426d-b58b-f3adbacdee8a
# ╠═e75e2ea0-bf1a-4519-87a2-efb61736ab44
# ╟─6ebe2c16-400b-40a0-bec6-e52d2858e83a
# ╟─9aa600b1-9c39-430a-88d4-169c5d84e145
# ╠═43cfe774-4ed1-4f4f-985a-c261c4d569bf
# ╟─88103471-6f2c-4604-83cc-0d76645776d7
# ╠═5d9c5359-d0a9-4a0a-853e-3fd0028f23df
# ╟─6bacff8b-ac8c-46b0-adeb-7d8b1aab85f2
# ╠═86399001-e7c4-4733-b476-503650c11e0c
# ╟─0817247f-f9ae-48cc-9966-dd451c136d43
# ╟─1d1d83b0-8669-452c-90ca-26c1396c822a
# ╟─2ded206d-e563-4752-a0b1-19402e1e4f52
# ╠═5b47082b-d080-4243-90a2-5d98b82451d4
# ╠═89b1f353-523a-4a4c-aee4-9b6e36b944fb
# ╠═4b1a6ce2-b57d-466a-97cd-35036689fe43
# ╟─fe1f4c0e-becb-4058-a069-be213622aa92
# ╟─eb0d58fc-3348-47f9-966c-e7f9f316ddb7
# ╠═11f3c0d4-0609-4446-aa84-4db3d93e93b0
# ╟─c22a890c-a308-4d1b-be4b-d78f93693a9c
# ╟─48511240-20d1-41b6-bc7b-a8ecfc3aa06d
# ╟─ffb8851d-c7e8-47ae-ac9d-96baf0774ca3
# ╟─a6eb6028-acca-447a-9e55-e60ecd3c6f84
# ╠═f2bedf2b-2dfe-4392-ba2a-add10882af07
# ╠═f504954b-ac63-4843-8891-b1ca0e5ae58b
# ╟─1da14b09-5d62-42cc-b9b4-a5a6ddc34181
# ╠═a9472534-e32b-4323-8dfc-e00b9f31f8e0
# ╟─ecfe4d79-b1c6-4a6d-a9d7-a563a26e32cd
# ╟─83423082-2d3a-42a1-b1db-ed267399cb31
# ╟─fb416cfd-f9ee-4d7d-9e83-056e81c422e0
# ╠═d0020df6-62a1-4000-b8cf-ceacb8014a0b
# ╟─d8301150-7b08-45b6-a986-d21574eee91b
# ╟─1f40437c-0419-4fc0-96ae-a8130efaa36a
# ╟─8419603a-3c5c-45a0-9a70-4a74347a7ad7
# ╟─4f9d3c2e-1ec8-4337-b49b-e0dc1d63bc62
# ╠═7476a638-5eca-47cc-9a01-41f30b9dbf9d
# ╠═d0d580d4-8e92-4d46-8177-67f52fbb3934
# ╠═c5784ec1-17cf-4897-8cd3-ff81998b9d9c
# ╟─387d145f-e77c-4e13-89b7-fc8733215694
# ╟─3790f106-9895-4425-a16f-5c5e0857e99e
# ╟─945a16d3-805c-40c9-9166-5120743bd3d7
# ╟─728c8956-9911-47d5-a021-df224e3f5b90
# ╠═3716d3cc-8706-41bf-873d-193543cb0514
# ╠═87c72b22-8c81-4062-8a9c-40902f83a623
# ╠═1362cd95-6a87-44e3-980d-014496afce85
# ╟─46075912-60b7-46d2-88c9-a13a8b015e0b
# ╟─f8ba8857-ece1-4cec-b7f2-2a8bc8bfb1d9
# ╠═cf13543a-9dd4-40ef-9523-5953e9db2c78
# ╠═0736648c-a181-4352-8b4e-bacf745fda64
# ╠═95dd7822-ef43-4629-bb42-ddb15bd1f965
# ╟─786b7ea2-7827-4cab-abbb-786abe935cc3
# ╟─4440f39c-51e5-4ffd-8031-96d4a760270c
# ╟─bfb3280e-638f-4e8f-8e37-d5f8fd75541d
# ╟─7f6e72fd-aacc-47a8-a496-25794c60343c
# ╟─55160454-2738-4911-be15-29f484f610db
# ╠═e90098ec-a9c3-4204-95f7-88adeb74ee50
# ╠═7b92051d-4015-4e22-b6b9-41462e2cc54f
# ╟─4eef090f-29b1-44e1-929a-98162719ae93
# ╠═32f6a219-f69b-4085-ba4b-5c7dc3ca2155
# ╟─ffffadbb-5fcd-443d-97fb-b6d372029814
# ╠═19198826-15a0-432d-abe2-ae5ead6869f5
# ╟─0d762ed4-dfb9-433f-8ded-1ae653ad87c2
# ╟─ef28a71e-74f4-40dd-a72d-1a51628fd01b
# ╠═ffd6df27-c0e5-44be-aee9-2c7a9d4fb5c0
# ╟─f9ca3e33-243c-45c8-b646-587aa7d2d902
# ╟─c7a0dbbe-89e6-4759-a57f-b367fbeba62e
# ╠═9a8f7f42-2677-43ff-a280-3b75df6258e1
# ╠═0cee5c93-266c-4be3-9997-20728cf11921
# ╟─7b3551c2-22f7-47dd-82dc-b817d7e0f1fb
# ╟─f6330892-3379-4e0d-a007-c451a465bd06
# ╟─6d848043-e5bc-4beb-a18a-004d4cac5c23
# ╟─fc84dce4-779c-4377-af2a-cda7e453f382
# ╟─d76d5ddc-fe59-47f4-8b56-6f704b486ebc
# ╟─9ef1e014-5a7d-4b17-98de-0cf51d788bfa
# ╠═f8cd5dce-6a4c-4c6c-b2d5-7ec56132e95e
# ╠═c7ee9795-2c7a-480a-9269-440a9227c591
# ╟─28f31ef9-27ea-4e94-8f03-89b0f6cfa0d1
# ╟─1676ec54-bd96-4892-aa08-3ae831b537bb
# ╠═ea16d4c6-d6e4-46fa-a721-fa5a0f2ff021
# ╠═bd37c58d-8544-40b1-a0b5-ea03ec5692a8
# ╠═5bbd690b-6a98-4dbf-a8c4-581ac77a4da5
# ╟─cc224a30-81bf-4a2c-b636-40ff5c941bb6
# ╟─3d20c24c-469b-4f0d-9936-705e42033ded
# ╟─bf6c5fc8-8283-46d4-aa67-416d53f7d315
# ╠═d00bf3fd-9bd8-4b11-b755-a85f0f8644cb
# ╠═a80b3a0f-53d1-473e-9bea-2494a85ac511
# ╟─ab398337-adb5-48fa-ae1b-4c9499438097
# ╟─ae7b2114-de91-4f1b-8765-af5e02cc1b63
# ╟─e4aedbd4-a609-4eaf-812b-d2f3d6f4df3d
# ╠═b8974b20-d8dc-4109-a64e-585c7afdb484
# ╟─bd10d753-eea6-4798-939c-8e5551d40c5c
# ╟─2f95afd6-1418-44bb-9868-970dbe888500
# ╠═06e91432-935f-4d7c-899f-d7968a10a78e
# ╟─c7efc656-ae9b-4eef-b0cd-3afe3852d396
# ╟─ca4b41dd-353e-498d-a461-648c582cb999
# ╠═c5fc8f3a-ed90-41ec-b4b9-1172a41e3adc
# ╠═40e13883-dd9a-43b9-9ef7-1069ef036846
# ╟─7c7bdbd9-edd5-4142-a765-4c498761f7e7
# ╟─8569cd7b-890f-4b04-a6d5-c92a70a226ab
# ╠═cf250e37-ed37-47cd-b689-8e2596f9fdc5
# ╟─8f46db4a-cc94-4497-aad8-0fc4b0cfa1e3
# ╠═dccf9f6d-82a6-423c-bbe5-22c5a8c2f5e4
# ╟─bbe25d4e-952b-4ed5-b20e-24b3dcd30495
# ╠═77eac64f-eac5-4d12-8acf-5b5070e60858
# ╟─aa4194d6-2f8c-4367-850e-22ebcf1b72e4
# ╟─f66a0ea7-70fd-4340-8b02-6fbaab847dfc
# ╟─8cca11ed-a61c-4cc8-af4b-350137073756
# ╠═7144c6c8-79dd-437d-a201-bac143f6a261
# ╟─45765f4a-536d-4e9d-be9d-144b7ccd4dcf
# ╟─df89f509-cfd7-46b3-9dd1-cdcfcea68053
# ╠═0b51e23e-a015-4e86-ba48-6475a9ee9779
# ╟─14dcad57-23ae-4905-aac4-d29066f2a085
# ╠═06a59777-b6ec-4808-9105-7a2542a629ea
# ╠═9222d644-5d20-474a-83db-4b2e3bed45e2
# ╟─c511e1c4-0306-46c7-800f-8257266c0091
# ╠═c79e7017-4acc-4562-817a-50245ce654dc
# ╟─ac115404-0115-4c94-9b51-9a8674ac4b05
# ╟─dd01d4b4-b05a-43a3-9b76-65e13076535f
# ╟─766e1909-5063-4ce2-821d-1f93be4db789
# ╠═2b83cccd-bdaf-4481-a7f5-391434220bd5
# ╟─69a9ec45-d2ff-4362-9c3c-5c004e46ceb3
# ╟─cc167cfd-b776-4280-a308-d5908ceaec4b
# ╟─8923a5ad-ddba-4ae2-886e-84526a3521ba
# ╟─e1b9f114-58e7-4546-a3c0-5e07fb1665e7
# ╠═ba07ccda-ae66-4fce-837e-00b2b039b404
# ╟─d0ae8c14-b341-4220-8a1c-79fed9758f64
# ╟─f843b77d-8160-4d87-8641-eeb04549af8f
# ╟─9b34a8f9-6afa-4712-bde8-a94f4d5e7a33
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
