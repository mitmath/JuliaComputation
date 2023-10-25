### A Pluto.jl notebook ###
# v0.19.27

#> [frontmatter]
#> title = "HW1 - Automatic differentiation"
#> date = "2023-09-14"

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
	using Symbolics
end

# ╔═╡ ddbba011-f413-4804-b29b-fdc4efe2b3b3
md"""
Homework 1 of the MIT Course [_Julia: solving real-world problems with computation_](https://github.com/mitmath/JuliaComputation)

Release date: Thursday, Sep 14, 2023 (version 1)

**Due date: Thursday, Sep 21, 2023 at 11:59pm EST**

**Instructions: Submit a pdf to canvas by selecting Pluto export to PDF.**

Submission by: Jazzy Doe (jazz@mit.edu)
"""

# ╔═╡ 9a1453a3-bfad-4212-ac19-a4b6c7df5b16
student = (name = "Solutions Rock", kerberos_id = "18.C25") 

# ╔═╡ 9f6254b5-bc06-469c-a0ef-5ee31ac75233
md"""
The following cell is quite slow, so go grab a coffee while it runs!
Package loading times are one of the main pain points of Julia, and people are actively working to make them shorter.
"""

# ╔═╡ f447c167-2bcb-4bf3-86cd-0f40f4e54c97
TableOfContents()

# ╔═╡ c03b00c2-248c-4189-ba46-3d8f2fb168cb
md"""
## Arrays and Matrices in Julia
"""

# ╔═╡ 2ad7ef95-c243-4f80-bc45-7ca43f07fd86
md"""
### 0.1. Creating Arrays

Julia offers several ways to create arrays. Here are a few that are always available:

##### Manually
"""

# ╔═╡ 41d4b142-46f5-4124-97f3-85d38672eeb2
begin
	a = [1, 2, 3]
	b = [1 2 3; 4 5 6]  # 2x3 array
end

# ╔═╡ 4ef83bb5-9d2a-4cc0-8953-f7cde460fb1c
md"""
##### With Functions
"""

# ╔═╡ e56b8a12-fb43-4de3-a074-41988195e74c
begin
	M_ones = ones(3, 4);  # 3x4 array with all elements set to 1
	M_random = rand(2, 3);  # 2x3 array with random elements
end

# ╔═╡ 098f5c21-ca1e-46ee-a055-9f4978c479a2
md"""
##### Tranforming Iterables into Arrays
"""

# ╔═╡ bd6e838c-6784-456f-9464-963cd9679ffe
begin
	iter_collection = collect(1:3)
end

# ╔═╡ a71f9dc5-69f8-4950-b447-6fafc1d58003
md"""
### 0.3. Matrix Operations

Additionally, a rich set of matrix operations are readily available in raw Julia:

- `*` for matrix multiplication
- `.*` for element-wise multiplication
"""

# ╔═╡ c5d4b486-5385-4d35-9684-f55cf416f5a6
let
	A = [1 2; 3 4]
	B = [2 0; 1 2]
	
	C = A * B  # Matrix multiplication
	D = A .* B  # Element-wise multiplication
end

# ╔═╡ f1dc6427-0d25-42c6-a8c0-93ce8c0c7949
md"""
### 0.2. Indexing and Slicing

Julia is 1-indexed. You can access elements by their row and column number or slice by leaving a colon or iterable in a dimension.
"""

# ╔═╡ 1e4e8d17-57a5-47b2-b7da-f6046584682a
b[1, 2]  # Access the element in the first row and second column of b

# ╔═╡ 07d2a956-1cad-45fa-ae62-2c4f51a20092
b[:, 2]  # Get the second column

# ╔═╡ f8dc8d47-3f6d-4885-b8b6-632851d312e5
md"""
!!! danger "Task"
	Create a 3x3 matrix 🧮 where each element `🧮[i, j]` is `i + j` without the use of a for loop (creating an addition table).
"""

# ╔═╡ 6230bd21-9a4e-4936-a582-988839bbf0dd
🧮 = (1:3) .+ (1:3)'

# ╔═╡ 5f81a0f9-f847-48e9-a135-6b51b4655eec
hint(md"
Consider one of the following approaches:
- Utilize broadcasting to perform element-wise addition.
- Use a comprehension to generate the matrix in a single line.
- Take advantage of the repeat and reshape functions.
")

# ╔═╡ 14493c57-b329-417a-92a2-cf1b74063b01
md"""
!!! danger "Task"
	Extract the 2x2 bottom-right submatrix of matrix 🧮
"""

# ╔═╡ 577ee1d7-7613-48df-91c8-1248f77d1f97
m_corner = 🧮[end-1:end, end-1:end]

# ╔═╡ 801c951c-e91b-4643-9c5c-98dea7699d21
md"""
### 0.3 Composability and Custom Types

Julia matrices can hold any data type, even custom ones. Let's make a matrix containing complex numbers and integers.


"""

# ╔═╡ aa692948-4857-4968-bff4-68b7df2bb423
M_imag = [1+2im 2+3im; 3 4]

# ╔═╡ 35d66819-a21a-4d33-9ee6-e90cf47e82a2
md"""
!!! danger "Task"
	Create a 2x2 matrix where the first row contains strings and the second row contains integers.
"""

# ╔═╡ b2e328bf-3c2d-49f1-b684-06f72088636b
M_composed = [ "string1" "string2"; 1 2 ]

# ╔═╡ 32159541-a1b3-4ba6-a260-aac061a9ebf0
md"""
### 0.4. Useful Functions on Matrices

Julia provides some very useful built-in functions to work with matrices:

- `transpose(A)` or `A'` to get the transpose
- `inv(A)` to get the inverse
- `Diagonal(A)` to get a diagonal matrix with the diagonal elements of `A`
"""

# ╔═╡ bb6532ec-6ba8-4ec0-ba1e-f5f04884ca7e
let 
	A = [1 2; 3 4]
	B = [2 0; 1 2]
	
	E = transpose(A)  # Or A'
	F = inv(A)
	G = Diagonal([1, 2])
end

# ╔═╡ a405d214-4348-4692-999e-0e890bd91e5d
md"""
# HW1 - Automatic differentiation
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

# ╔═╡ d8301150-7b08-45b6-a986-d21574eee91b
md"""
# 1. Autodiff works... almost always
"""

# ╔═╡ 1f40437c-0419-4fc0-96ae-a8130efaa36a
md"""
## Autodiff isn't symbolic differentiation
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

Here is an example showing how to use them for Jacobian computation using the `powersum` function defined below.
"""

# ╔═╡ 7476a638-5eca-47cc-9a01-41f30b9dbf9d
function powersum(x; p=5)
	return sum(x .^ i for i in 0:p)
end

# ╔═╡ 0bdf20f5-dea6-47f2-8173-42b6a2a7159a
md"""
First, let's quickly get a handle on what this function does and what its derivative looks like.
We'll use [`Symbolics.jl`](https://github.com/JuliaSymbolics/Symbolics.jl) to trace the function.
The first step is establishing our symbolic variables $r$, $s$, and $t$.
"""

# ╔═╡ eac44292-32b9-4eed-a0f5-97781960c2fe
@variables r, s, t

# ╔═╡ 3fb595e8-13de-4d5d-9278-18e0134c4c2a
md"""
Now, we can call `powersum` using $t$ as the argument and computer will do all the symbolic computation for us.
"""

# ╔═╡ 2ad2b094-e3eb-40ac-8859-c7ef73694ad6
powersum(t)

# ╔═╡ 2d57cdc8-ec60-4b7a-ac11-f87a7748fe12
md"""
We can instead call the function with an array as the input and get an array for an output.
"""

# ╔═╡ 99dcdb27-975d-475c-b5aa-16758ee84f56
powersum([s, t]; p=3)

# ╔═╡ d0d580d4-8e92-4d46-8177-67f52fbb3934
powersum(1:3)

# ╔═╡ 4ea19469-071d-4b68-b173-9a04682d6d92
md"""
Now, let's use [`Symbolics.jl`](https://github.com/JuliaSymbolics/Symbolics.jl) to see what the derivative is.
You should be able to do this yourself using power rule, but we'll show you how to do it with the computer here to save you some algebra.

Recall that this is _**not**_ automatic differentiation.
This is symbolic differentiation.
As described in class, automatic differentiation does not need to be able to trace the function with symbolic variables or store a symbolic form of the function output.
That makes automatic differentiation much faster and more generally applicable.
Symbolic differentiation is good for investigating a simple mathematical function and saving yourself some algebra, as we are doing here.
"""

# ╔═╡ ff1ebb12-e1c7-420d-a0b6-3cec54a4a966
dpowersum = Symbolics.derivative(powersum(t), t)

# ╔═╡ 94a8574f-eee1-4252-93f1-e51f52505d22
md"""
Recall that if the input to `powersum` is a vector, so is the output.
In that case, we would be calculating a Jacobian.
"""

# ╔═╡ 256524da-724d-423e-837a-6d1ac765db9d
dpowersum3 = Symbolics.jacobian(powersum([r, s ,t]), [r, s ,t])

# ╔═╡ 502c8a6a-1124-4493-9caf-763584f9a5e2
md"""
We can make the symbolic derivative expression into a function by substituting in values numbers for the symbolic variables.
"""

# ╔═╡ da65160c-e1e8-4c9d-a462-60783b721a25
dpowersum3dt(x) = Symbolics.substitute(dpowersum3, Dict(r=>x[1], s=>x[2], t=>x[3]))

# ╔═╡ 3928791f-6a13-4db3-b45a-d21bf592c3b7
md"""
Finally, let's look at automatic differentation.
The following code block uses the two different AD packages described above to calculate the Jacobian.
Note that the results are the same as the symbolic answers, which you can verify by hand.
"""

# ╔═╡ c5784ec1-17cf-4897-8cd3-ff81998b9d9c
let
	x = rand(3)
	J1 = ForwardDiff.jacobian(powersum, x)
	J2 = Zygote.jacobian(powersum, x)[1]
	J3 = dpowersum3dt(x)
	J1, J2, J3
end

# ╔═╡ c7cb020f-97fd-4670-9a32-4d8a558a7711
md"""
One difference, in this case, between automatic differentiation and symbolic differentiation is the generality.
As you can see below, the AD methods work just fine no matter the size of `x`.
Meanwhile, when we constructed the symbolic Jacoabian we had to specify the size $(3 \times 3)$, so you'd have to construct a new symbolic Jacobian every time you got an input of a different size.

Symbolic algebra and differentiation is a useful tool for your own mathematical explorations, but automatic differentiation will often be the better option for scalable, reusable, performant code.
"""

# ╔═╡ a318519b-5a2d-48fd-a1e5-ba3f502fb210
let
	x = rand(4)
	J1 = ForwardDiff.jacobian(powersum, x)
	J2 = Zygote.jacobian(powersum, x)[1]
	J3 = dpowersum3dt(x)
	J1, J2, J3
end

# ╔═╡ ab124971-5135-4c20-ba1e-4bbd6046d94d
let
	x = rand(3)
	J1 = ForwardDiff.jacobian(powersum, x)
	J2 = Zygote.jacobian(powersum, x)[1]
	J3 = dpowersum3dt(x)
	J1, J2, J3
end

# ╔═╡ 24b668f5-e567-45ee-abd8-78acd9db0c55
md"""
Note: the above cell intentionally errors to show how the symbolic expression is specialized to length 3 vectors.
"""

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
function powersum_breakforwarddiff(x::AbstractVector{Float64}; p=5)
	return sum(x.^i for i in 0:p)
end

# ╔═╡ 87c72b22-8c81-4062-8a9c-40902f83a623
powersum(1:3), powersum_breakforwarddiff(1.:3.)

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
	y = ones(eltype(x), length(x))
	for i in 1:p
		y .+= x.^i
	end
	return y
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
# 2. Application to linear regression
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
	e = (M * x - y) .^ 2
	return e
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
	mul!(e, M, x)  # in-place matrix multiplication: now e = Mx
	e .-= y  # now e = Mx - y
	e .^= 2  # now e = (Mx - y) .^ 2
	return e
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
Now we pause for a minute and examine the three terms we obtained.

1. The first one is exactly the value of $f$ at $x$
2. The second one is a linear function of $h$
3. The third one is a quadratic function of $h$, which is negligible compared to the linear term (in the "small $h$" regime)

This means we can identify the derivative:

$$f'(x): h \in \mathbb{R}^n \longmapsto 2 (Mx - y) \odot (M h) \in \mathbb{R}^m$$
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
If $a \in \mathbb{R}^m$ is a vector, we denote by $D(a)$ the diagonal matrix with diagonal coefficients $a_1, ..., a_m$.
Using the hint above, we recognize that

$$f'(x)(h) = 2 D(Mx - y) (Mh) = \left[2 D(Mx-y)M\right] h$$

This yields the following Jacobian formula:

$$J_f(x) = 2D(Mx-y)M \in \mathbb{R}^{m \times n}$$
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
	return 2 * Diagonal(M * x .- y) * M
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
	f2!(e, x; M=M, y=y)
	J = Jf(x; M=M, y=y)
	function vector_jacobian_product(v)
		vjp_fun = NoTangent()
		vjp_e = ZeroTangent()
		vjp_x = J' * v
		return (vjp_fun, vjp_e, vjp_x)
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
let
	n, m = 3, 5
	M = rand(m, n)
	y = rand(m)
	x = rand(n)
	e = rand(m)
	ChainRulesCore.rrule(f2!, e, x; M=M, y=y)  # trick Pluto's dependency handler
	J1 = Zygote.jacobian(x -> f(x; M=M, y=y), x)[1]
	J2 = Zygote.jacobian(x -> f2!(e, x; M=M, y=y), x)[1]
	J1, J2
end

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
A VJP can be computed as follows:

$$v^\top J_f(x) = v^\top 2D(Mx-y)M \quad \implies \begin{cases} a = v^\top 2D(Mx - y) \\ b = a M \end{cases}$$

This means we only need to store a vector and not a full matrix.
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
	return M' * (v .* 2 .* (M * x .- y))
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
let
	n, m = 3, 5
	M = rand(m, n)
	y = rand(m)
	x = rand(n)
	v = rand(m)
	vjp1 = f_vjp(v, x; M=M, y=y)
	vjp2 = f_vjp_naive(v, x; M=M, y=y)
	vjp1, vjp2
end

# ╔═╡ c511e1c4-0306-46c7-800f-8257266c0091
md"""
!!! danger "Task"
	Compare the performance of both VJP implementations.
"""

# ╔═╡ c79e7017-4acc-4562-817a-50245ce654dc
let
	n, m = 3, 5
	M = rand(m, n)
	y = rand(m)
	x = rand(n)
	v = rand(m)
	@btime f_vjp($v, $x; M=$M, y=$y)
	@btime f_vjp_naive($v, $x; M=$M, y=$y)
end;

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
The quantity $Mx - y$ is used both in the function and in the VJP. We can compute it only once at the start of `rrule` and reuse it in both places.
"""

# ╔═╡ 69a9ec45-d2ff-4362-9c3c-5c004e46ceb3
md"""
# 3. Going further
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
If we cycle through the basis vectors $v = (0, ..., 0, 1, 0, ..., 0) \in \mathbb{R}^m$ of the output space, each product $v^\top J_f(x)$ gives us one row of the Jacobian matrix. Therefore, we need $m$ VJPs in total.
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
Symbolics = "0c5d862f-8b57-4792-8d23-62f2024744c7"
Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[compat]
BenchmarkTools = "~1.3.2"
ChainRulesCore = "~1.18.0"
ForwardDiff = "~0.10.36"
Plots = "~1.39.0"
PlutoTeachingTools = "~0.2.13"
PlutoUI = "~0.7.52"
ProgressLogging = "~0.1.4"
Symbolics = "~5.10.0"
Zygote = "~0.6.66"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "284f05ac873fd66fcbe4c209f5e3707f93a1c669"

[[deps.ADTypes]]
git-tree-sha1 = "5d2e21d7b0d8c22f67483ef95ebdc39c0e6b6003"
uuid = "47edcb42-4c32-4615-8424-f2b9edc5f35b"
version = "0.2.4"

[[deps.AbstractAlgebra]]
deps = ["GroupsCore", "InteractiveUtils", "LinearAlgebra", "MacroTools", "Preferences", "Random", "RandomExtensions", "SparseArrays", "Test"]
git-tree-sha1 = "c3c29bf6363b3ac3e421dc8b2ba8e33bdacbd245"
uuid = "c3fe647b-3220-5bb0-a1ea-a7954cac585d"
version = "0.32.5"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.AbstractTrees]]
git-tree-sha1 = "faa260e4cb5aba097a73fab382dd4b5819d8ec8c"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.4"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "76289dc51920fdc6e0013c872ba9551d54961c24"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra", "Requires", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "f83ec24f76d4c8f525099b2ac475fc098138ec31"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.4.11"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.Bijections]]
git-tree-sha1 = "71281c0c28f97e0adeed24fdaa6bf7d37177f297"
uuid = "e2ed5e7c-b2de-5872-ae92-c73ca462fb04"
version = "0.1.5"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

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
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRules]]
deps = ["Adapt", "ChainRulesCore", "Compat", "Distributed", "GPUArraysCore", "IrrationalConstants", "LinearAlgebra", "Random", "RealDot", "SparseArrays", "SparseInverseSubset", "Statistics", "StructArrays", "SuiteSparse"]
git-tree-sha1 = "01b0594d8907485ed894bc59adfc0a24a9cde7a3"
uuid = "082447d4-558c-5d27-93f4-14fc19e9eca2"
version = "1.55.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e0af648f0692ec1691b5d094b8724ba1346281cf"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.18.0"

[[deps.ChangesOfVariables]]
deps = ["InverseFunctions", "LinearAlgebra", "Test"]
git-tree-sha1 = "2fba81a302a7be671aefe194f0525ef231104e7f"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.8"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "c0216e792f518b39b22212127d4a84dc31e4e386"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.5"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "cd67fc487743b2f0fd4380d4cbd3a24660d0eec8"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.3"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "67c1f244b991cad9b0aa4b7540fb758c2488b129"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.24.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.CommonSolve]]
git-tree-sha1 = "0eee5eb66b1cf62cd6ad1b460238e60e4b09400c"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.4"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.CompositeTypes]]
git-tree-sha1 = "02d2316b7ffceff992f3096ae48c7829a8aa0638"
uuid = "b152e2b5-7a66-4b01-a709-34e65c35f657"
version = "0.1.3"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "5372dbbf8f0bdb8c700db5367132925c0771ef7e"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.2.1"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

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

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "3d5873f811f582873bb9871fc9c451784d5dc8c7"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.102"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.DomainSets]]
deps = ["CompositeTypes", "IntervalSets", "LinearAlgebra", "Random", "StaticArrays", "Statistics"]
git-tree-sha1 = "51b4b84d33ec5e0955b55ff4b748b99ce2c3faa9"
uuid = "5b8099bc-c8ec-5219-889f-1d9e522a28bf"
version = "0.6.7"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.DynamicPolynomials]]
deps = ["Future", "LinearAlgebra", "MultivariatePolynomials", "MutableArithmetics", "Pkg", "Reexport", "Test"]
git-tree-sha1 = "fea68c84ba262b121754539e6ea0546146515d4f"
uuid = "7c1d4256-1411-5781-91ec-d7bc3513ac07"
version = "0.5.3"

[[deps.EnumX]]
git-tree-sha1 = "bdb1942cd4c45e3c678fd11569d5cccd80976237"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.4"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

[[deps.ExprTools]]
git-tree-sha1 = "27415f162e6028e81c72b82ef756bf321213b6ec"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.10"

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
git-tree-sha1 = "35f0c0f345bff2c6d636f95fdb136323b5a796ef"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.7.0"

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
git-tree-sha1 = "cf0fe81336da9fb90944683b8c41984b08793dad"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.36"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d8db6a5a2fe1381c1ea4ef2cab7c69c2de7f9ea0"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.1+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.FunctionWrappers]]
git-tree-sha1 = "d62485945ce5ae9c0c48f124a84998d755bae00e"
uuid = "069b7b12-0de2-55c6-9aab-29f3d0a68a2e"
version = "1.1.3"

[[deps.FunctionWrappersWrappers]]
deps = ["FunctionWrappers"]
git-tree-sha1 = "b104d487b34566608f8b4e1c39fb0b10aa279ff8"
uuid = "77dc65aa-8811-40c2-897b-53d922fa7daf"
version = "0.1.3"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GPUArrays]]
deps = ["Adapt", "GPUArraysCore", "LLVM", "LinearAlgebra", "Printf", "Random", "Reexport", "Serialization", "Statistics"]
git-tree-sha1 = "8ad8f375ae365aa1eb2f42e2565a40b55a4b69a8"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "9.0.0"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "2d6ca471a6c7b536127afccfa7564b5b39227fe0"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.5"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "27442171f28c952804dede8ff72828a96f2bfc1f"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.10"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "025d171a2847f616becc0f84c8dc62fe18f0f6dd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.10+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "e94c92c7bf4819685eb80186d51c43e71d4afa17"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.76.5+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.Groebner]]
deps = ["AbstractAlgebra", "Combinatorics", "ExprTools", "Logging", "MultivariatePolynomials", "Primes", "Random", "SIMD", "SnoopPrecompile"]
git-tree-sha1 = "44f595de4f6485ab5ba71fe257b5eadaa3cf161e"
uuid = "0b43b601-686d-58a3-8a1c-6623616c7cd4"
version = "0.4.4"

[[deps.GroupsCore]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9e1a5e9f3b81ad6a5c613d181664a0efc6fe6dd7"
uuid = "d5909c97-4eac-4ecc-a3dc-fdd0858a4120"
version = "0.4.0"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "5eab648309e2e060198b45820af1a37182de3cce"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "f218fe3736ddf977e0e772bc9a586b2383da2685"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.23"

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
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.IRTools]]
deps = ["InteractiveUtils", "MacroTools", "Test"]
git-tree-sha1 = "8aa91235360659ca7560db43a7d57541120aa31d"
uuid = "7869d1d1-7146-5819-86e3-90919afe41df"
version = "0.4.11"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.IntegerMathUtils]]
git-tree-sha1 = "b8ffb903da9f7b8cf695a8bead8e01814aa24b30"
uuid = "18e54dd8-cb9d-406c-a71d-865a43cbb235"
version = "0.1.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "8e59ea773deee525c99a8018409f64f19fb719e6"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.7"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "68772f49f54b479fa88ace904f6127f0a3bb2e46"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.12"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "9fb0b890adab1c0a4a475d4210d51f228bfc250d"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.6"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0592b1810613d1c95eeebcd22dc11fba186c2a57"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.26"

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
git-tree-sha1 = "4ea2928a96acfcf8589e6cd1429eff2a3a82c366"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "6.3.0"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "e7c01b69bcbcb93fd4cbc3d0fea7d229541e18d2"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.26+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f689897ccbe049adb19a065c495e75f372ecd42b"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.4+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LabelledArrays]]
deps = ["ArrayInterface", "ChainRulesCore", "ForwardDiff", "LinearAlgebra", "MacroTools", "PreallocationTools", "RecursiveArrayTools", "StaticArrays"]
git-tree-sha1 = "cd04158424635efd05ff38d5f55843397b7416a9"
uuid = "2ee39098-c373-598a-b85f-a56591580800"
version = "1.14.0"

[[deps.LambertW]]
git-tree-sha1 = "c5ffc834de5d61d00d2b0e18c96267cffc21f648"
uuid = "984bce1d-4616-540c-a9ee-88d1112d94c9"
version = "0.4.6"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "f428ae552340899a935973270b8d98e5a31c49fe"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.1"

[[deps.Lazy]]
deps = ["MacroTools"]
git-tree-sha1 = "1370f8202dac30758f3c345f9909b97f53d87d3f"
uuid = "50d2b5c4-7a5e-59d5-8109-a42b560f39c0"
version = "0.15.1"

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
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "2da088d113af58221c52828a80378e16be7d037a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.5.1+1"

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
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "60168780555f3e663c536500aa790b6368adc02a"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.3.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.MultivariatePolynomials]]
deps = ["ChainRulesCore", "DataStructures", "LinearAlgebra", "MutableArithmetics"]
git-tree-sha1 = "6c2e970692b6f4fed2508865c43a0f67f3820cf4"
uuid = "102ac46a-7ee4-5c85-9060-abc95bfdeaa3"
version = "0.5.2"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "6985021d02ab8c509c841bb8b2becd3145a7b490"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.3.3"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

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
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a12e56c72edee3ce6b96667745e6cbbe5498f200"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.23+0"

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
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "66b2fcd977db5329aa35cac121e5b94dd6472198"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.28"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "64779bc4c9784fee475689a1752ef4d5747c5e87"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.42.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "f92e1315dadf8c46561fb9396e525f7200cdc227"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.5"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "ccee59c6e48e6f2edf8a5b64dc817b6729f99eb5"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.39.0"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "8f5fa7056e6dcfb23ac5211de38e6c03f6367794"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.6"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "542de5acb35585afcf202a6d3361b430bc1c3fbd"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.13"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

[[deps.PreallocationTools]]
deps = ["Adapt", "ArrayInterface", "ForwardDiff", "Requires"]
git-tree-sha1 = "f739b1b3cc7b9949af3b35089931f2b58c289163"
uuid = "d236fae5-4411-538c-8e31-a6e3d9e00b46"
version = "0.4.12"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Primes]]
deps = ["IntegerMathUtils"]
git-tree-sha1 = "4c9f306e5d6603ae203c2000dd460d81a5251489"
uuid = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"
version = "0.5.4"

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

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "7c29f0e8c575428bd84dc3c72ece5178caa67336"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.5.2+2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9ebcd48c498668c7fa0e97a9cae873fbee7bfee1"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.9.1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RandomExtensions]]
deps = ["Random", "SparseArrays"]
git-tree-sha1 = "b8a399e95663485820000f26b6a43c794e166a49"
uuid = "fb686558-2515-59ef-acaa-46db3789a887"
version = "0.4.4"

[[deps.RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.RecursiveArrayTools]]
deps = ["Adapt", "ArrayInterface", "DocStringExtensions", "GPUArraysCore", "IteratorInterfaceExtensions", "LinearAlgebra", "RecipesBase", "Requires", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface", "Tables"]
git-tree-sha1 = "d7087c013e8a496ff396bae843b1e16d9a30ede8"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "2.38.10"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "609c26951d80551620241c3d7090c71a73da75ab"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.6"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.RuntimeGeneratedFunctions]]
deps = ["ExprTools", "SHA", "Serialization"]
git-tree-sha1 = "6aacc5eefe8415f47b3e34214c1d79d2674a0ba2"
uuid = "7e49a35a-f44a-4d26-94aa-eba1b4ca6b47"
version = "0.5.12"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "0e270732477b9e551d884e6b07e23bb2ec947790"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.4.5"

[[deps.SciMLBase]]
deps = ["ADTypes", "ArrayInterface", "ChainRulesCore", "CommonSolve", "ConstructionBase", "Distributed", "DocStringExtensions", "EnumX", "FillArrays", "FunctionWrappersWrappers", "IteratorInterfaceExtensions", "LinearAlgebra", "Logging", "Markdown", "PrecompileTools", "Preferences", "RecipesBase", "RecursiveArrayTools", "Reexport", "RuntimeGeneratedFunctions", "SciMLOperators", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface", "Tables", "TruncatedStacktraces", "ZygoteRules"]
git-tree-sha1 = "9c4f861661e72d9257834d8e517d4511e91ca43b"
uuid = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
version = "2.4.2"

[[deps.SciMLOperators]]
deps = ["ArrayInterface", "DocStringExtensions", "Lazy", "LinearAlgebra", "Setfield", "SparseArrays", "StaticArraysCore", "Tricks"]
git-tree-sha1 = "65c2e6ced6f62ea796af251eb292a0e131a3613b"
uuid = "c0aeaf25-5076-4817-a8d5-81caf7dfa961"
version = "0.3.6"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

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
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "5165dfb9fd131cf0c6957a3a7605dede376e7b63"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SparseInverseSubset]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "91402087fd5d13b2d97e3ef29bbdf9d7859e678a"
uuid = "dc90abb0-5640-4711-901d-7e5b23a2fada"
version = "0.1.1"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "0adf069a2a490c47273727e029371b31d44b72b2"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.6.5"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "1d77abd07f617c4868c33d4f5b9e1dbb2643c9cf"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.2"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f625d686d5a88bcd2b15cd81f18f98186fdc0c9a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.0"

[[deps.StructArrays]]
deps = ["Adapt", "ConstructionBase", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "0a3db38e4cce3c54fe7a71f831cd7b6194a54213"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.16"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SymbolicIndexingInterface]]
deps = ["DocStringExtensions"]
git-tree-sha1 = "f8ab052bfcbdb9b48fad2c80c873aa0d0344dfe5"
uuid = "2efcf032-c050-4f8e-a9bb-153293bab1f5"
version = "0.2.2"

[[deps.SymbolicUtils]]
deps = ["AbstractTrees", "Bijections", "ChainRulesCore", "Combinatorics", "ConstructionBase", "DataStructures", "DocStringExtensions", "DynamicPolynomials", "IfElse", "LabelledArrays", "LinearAlgebra", "MultivariatePolynomials", "NaNMath", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArrays", "TimerOutputs", "Unityper"]
git-tree-sha1 = "2f3fa844bcd33e40d8c29de5ee8dded7a0a70422"
uuid = "d1185830-fcd6-423d-90d6-eec64667417b"
version = "1.4.0"

[[deps.Symbolics]]
deps = ["ArrayInterface", "Bijections", "ConstructionBase", "DataStructures", "DiffRules", "Distributions", "DocStringExtensions", "DomainSets", "DynamicPolynomials", "Groebner", "IfElse", "LaTeXStrings", "LambertW", "Latexify", "Libdl", "LinearAlgebra", "LogExpFunctions", "MacroTools", "Markdown", "NaNMath", "PrecompileTools", "RecipesBase", "RecursiveArrayTools", "Reexport", "Requires", "RuntimeGeneratedFunctions", "SciMLBase", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArrays", "SymbolicUtils", "TreeViews"]
git-tree-sha1 = "4d4e922e160827388c003a9a088a4c63f339f6c0"
uuid = "0c5d862f-8b57-4792-8d23-62f2024744c7"
version = "5.10.0"

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
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "a1f34829d5ac0ef499f6d84428bd6b4c71f02ead"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.0"

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

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "f548a9e9c490030e545f72074a41edfd0e5bcdd7"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.23"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "49cbf7c74fafaed4c529d47d48c8f7da6a19eb75"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.1"

[[deps.TreeViews]]
deps = ["Test"]
git-tree-sha1 = "8d0d7a3fe2f30d6a7f833a5f19f7c7a5b396eae6"
uuid = "a2a6695c-b41b-5b7d-aed9-dbfdeacea5d7"
version = "0.3.0"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.TruncatedStacktraces]]
deps = ["InteractiveUtils", "MacroTools", "Preferences"]
git-tree-sha1 = "ea3e54c2bdde39062abf5a9758a23735558705e1"
uuid = "781d530d-4396-4725-bb49-402e4bee1e77"
version = "1.4.0"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

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

[[deps.Unitful]]
deps = ["ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "Random"]
git-tree-sha1 = "a72d22c7e13fe2de562feda8645aa134712a87ee"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.17.0"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "e2d817cc500e960fdbafcf988ac8436ba3208bfd"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.3"

[[deps.Unityper]]
deps = ["ConstructionBase"]
git-tree-sha1 = "21c8fc7cd598ef49f11bc9e94871f5d7740e34b9"
uuid = "a7c27f48-0311-42f6-a7f8-2c11e75eb415"
version = "0.1.5"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "24b81b59bd35b3c42ab84fa589086e19be919916"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.11.5+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cf2c7de82431ca6f39250d2fc4aacd0daa1675c0"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.4.4+0"

[[deps.Xorg_libICE_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "e5becd4411063bdcac16be8b66fc2f9f6f1e8fe5"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.0.10+1"

[[deps.Xorg_libSM_jll]]
deps = ["Libdl", "Pkg", "Xorg_libICE_jll"]
git-tree-sha1 = "4a9d9e4c180e1e8119b5ffc224a7b59d3a7f7e18"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.3+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

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
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "b4bfde5d5b652e22b9c790ad00af08b6d042b97d"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.15.0+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.Zygote]]
deps = ["AbstractFFTs", "ChainRules", "ChainRulesCore", "DiffRules", "Distributed", "FillArrays", "ForwardDiff", "GPUArrays", "GPUArraysCore", "IRTools", "InteractiveUtils", "LinearAlgebra", "LogExpFunctions", "MacroTools", "NaNMath", "PrecompileTools", "Random", "Requires", "SparseArrays", "SpecialFunctions", "Statistics", "ZygoteRules"]
git-tree-sha1 = "90cc0e19831780e8a03623a59db4730d96045303"
uuid = "e88e6eb3-aa80-5325-afca-941959d7151f"
version = "0.6.66"

[[deps.ZygoteRules]]
deps = ["ChainRulesCore", "MacroTools"]
git-tree-sha1 = "977aed5d006b840e2e40c0b48984f7463109046d"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.3"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "47cf33e62e138b920039e8ff9f9841aafe1b733e"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.35.1+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3516a5630f741c9eecb3720b1ec9d8edc3ecc033"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+0"

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

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

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

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

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
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╟─ddbba011-f413-4804-b29b-fdc4efe2b3b3
# ╠═9a1453a3-bfad-4212-ac19-a4b6c7df5b16
# ╟─9f6254b5-bc06-469c-a0ef-5ee31ac75233
# ╠═ddbf8ae6-39b6-11ed-226e-0d38991ed784
# ╠═f447c167-2bcb-4bf3-86cd-0f40f4e54c97
# ╟─c03b00c2-248c-4189-ba46-3d8f2fb168cb
# ╟─2ad7ef95-c243-4f80-bc45-7ca43f07fd86
# ╠═41d4b142-46f5-4124-97f3-85d38672eeb2
# ╟─4ef83bb5-9d2a-4cc0-8953-f7cde460fb1c
# ╠═e56b8a12-fb43-4de3-a074-41988195e74c
# ╟─098f5c21-ca1e-46ee-a055-9f4978c479a2
# ╠═bd6e838c-6784-456f-9464-963cd9679ffe
# ╟─a71f9dc5-69f8-4950-b447-6fafc1d58003
# ╠═c5d4b486-5385-4d35-9684-f55cf416f5a6
# ╟─f1dc6427-0d25-42c6-a8c0-93ce8c0c7949
# ╠═1e4e8d17-57a5-47b2-b7da-f6046584682a
# ╠═07d2a956-1cad-45fa-ae62-2c4f51a20092
# ╟─f8dc8d47-3f6d-4885-b8b6-632851d312e5
# ╠═6230bd21-9a4e-4936-a582-988839bbf0dd
# ╟─5f81a0f9-f847-48e9-a135-6b51b4655eec
# ╟─14493c57-b329-417a-92a2-cf1b74063b01
# ╠═577ee1d7-7613-48df-91c8-1248f77d1f97
# ╟─801c951c-e91b-4643-9c5c-98dea7699d21
# ╠═aa692948-4857-4968-bff4-68b7df2bb423
# ╟─35d66819-a21a-4d33-9ee6-e90cf47e82a2
# ╟─b2e328bf-3c2d-49f1-b684-06f72088636b
# ╟─32159541-a1b3-4ba6-a260-aac061a9ebf0
# ╠═bb6532ec-6ba8-4ec0-ba1e-f5f04884ca7e
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
# ╟─d8301150-7b08-45b6-a986-d21574eee91b
# ╟─1f40437c-0419-4fc0-96ae-a8130efaa36a
# ╟─8419603a-3c5c-45a0-9a70-4a74347a7ad7
# ╟─4f9d3c2e-1ec8-4337-b49b-e0dc1d63bc62
# ╠═7476a638-5eca-47cc-9a01-41f30b9dbf9d
# ╟─0bdf20f5-dea6-47f2-8173-42b6a2a7159a
# ╠═eac44292-32b9-4eed-a0f5-97781960c2fe
# ╟─3fb595e8-13de-4d5d-9278-18e0134c4c2a
# ╠═2ad2b094-e3eb-40ac-8859-c7ef73694ad6
# ╟─2d57cdc8-ec60-4b7a-ac11-f87a7748fe12
# ╠═99dcdb27-975d-475c-b5aa-16758ee84f56
# ╠═d0d580d4-8e92-4d46-8177-67f52fbb3934
# ╟─4ea19469-071d-4b68-b173-9a04682d6d92
# ╠═ff1ebb12-e1c7-420d-a0b6-3cec54a4a966
# ╟─94a8574f-eee1-4252-93f1-e51f52505d22
# ╠═256524da-724d-423e-837a-6d1ac765db9d
# ╟─502c8a6a-1124-4493-9caf-763584f9a5e2
# ╠═da65160c-e1e8-4c9d-a462-60783b721a25
# ╟─3928791f-6a13-4db3-b45a-d21bf592c3b7
# ╠═c5784ec1-17cf-4897-8cd3-ff81998b9d9c
# ╟─c7cb020f-97fd-4670-9a32-4d8a558a7711
# ╠═a318519b-5a2d-48fd-a1e5-ba3f502fb210
# ╠═ab124971-5135-4c20-ba1e-4bbd6046d94d
# ╟─24b668f5-e567-45ee-abd8-78acd9db0c55
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
