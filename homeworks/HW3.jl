### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 0d4205ec-fec1-4ef4-af48-7dae51ab31ee
begin
	using BenchmarkTools
	using FileIO
	using ImageIO
	using ImageShow
	using KrylovKit
	using LinearAlgebra
	using PlutoUI
	using PlutoTeachingTools
	using AbstractTrees
end

# ╔═╡ d5cd95f9-6728-47e2-bba4-00298c78d50c
student = (name = "Jazzy Doe", kerberos_id = "jazz")

# ╔═╡ 1b452080-14eb-41f7-969b-e2727af54fa3
PlutoUI.TableOfContents()

# ╔═╡ 03909b0c-c701-418a-ae68-7e99a52604e6
if VERSION >= v"1.11" 
	@error "This notebook will not function on Julia 1.11, please use version 1.10"
end

# ╔═╡ 7bdbb031-882b-4168-9e9f-2b54a1fc444c
isconcretetype(Float64), isconcretetype(Real)

# ╔═╡ 3e69e0e6-7d43-4adc-9ec7-5a37d9f006da
AbstractTrees.children(x::Type) = subtypes(x)

# ╔═╡ 2bf50413-2707-4a2e-9a5e-57ea3da1974f
print_tree(Real)

# ╔═╡ dbe0fdef-f845-4513-9ed7-283c0843036f
subtypes(Real)  # gives all the children of a type

# ╔═╡ a8ba06ad-772d-4534-9d73-f017bc01945f
supertypes(Float64)  # gives the chain of ancestors of a type

# ╔═╡ f13ad51a-466f-4963-a209-9b38e781f672


# ╔═╡ b6601d8d-623b-4945-ad53-557c99d13e4e
function my_identity(x)
	return x
end

# ╔═╡ 8e696410-7637-44aa-941b-986f50ac9a96


# ╔═╡ b71c3fa3-5b04-469f-bff1-db9f2c9dfbb0
begin
	struct Multiplier
		a
	end

	function (mult::Multiplier)(x)
		return mult.a * x
	end
end

# ╔═╡ 9f89d77b-c38c-40d6-b449-ef8baaa10481
let
	scalar_mult = Multiplier(2.0)
	(
		scalar_mult(3),
		scalar_mult(4 + 5im),
		scalar_mult(6 * ones(2, 2))
	)
end

# ╔═╡ 27d6041f-7174-4e80-a24c-b71b4a0caf6e
let
	matrix_mult = Multiplier([1 2; 3 4])
	(
		matrix_mult(3),
		matrix_mult(4 + 5im),
		matrix_mult(6 * ones(2, 2))
	)
end

# ╔═╡ b514a411-cc7d-4e11-a2a5-06f13fccb468


# ╔═╡ 82a9d34e-2dc5-41a7-86ca-075810733787
let
	if @isdefined FunctionWrapper
		fw = FunctionWrapper(sin)
		fw(1), sin(1)
	end
end

# ╔═╡ d809ced6-d076-4b11-a536-5795279a4bdf
function choice(x)
	if x < 0
		return "negative number"
	else
		return x
	end
end

# ╔═╡ 35a7588d-e83e-4e7d-a034-e8cd8f861498


# ╔═╡ 5e68691a-1ed2-4655-91c7-bcdc2309f253
let
	a = 2.0
	x = 1.0
	@code_warntype a * x
end

# ╔═╡ de7f4d78-2538-42f9-ba02-58656bd76f48
let
	a = 2.0
	mult = Multiplier(a)
	x = 1.0
	@code_warntype mult(x)
end

# ╔═╡ 0f073958-35f2-43bb-92c8-ffaac28f6e9a
let
	a = 2.0
	x = 1.0
	@code_llvm a * x
end

# ╔═╡ 96b6f3de-d3ba-4bd4-8f1b-79c7e9b4d9f4
let
	a = 2.0
	mult = Multiplier(a)
	x = 1.0
	@code_llvm mult(x)
end

# ╔═╡ ea46208b-66bb-4976-b124-f20412816549


# ╔═╡ 8b953dfc-4503-43f0-be33-51fa246033d0
let
	scalar_mult = Multiplier(2.0)
	fieldnames(typeof(scalar_mult)), fieldtypes(typeof(scalar_mult))
end

# ╔═╡ bd09874f-cdf4-489e-bbc3-f60281f75083
begin
	struct SpecificMultiplier
		a::Float64
	end

	function (mult::SpecificMultiplier)(x)
		return mult.a * x
	end
end

# ╔═╡ 326582ac-bfeb-4225-99ff-b4d2a6f2ea03
let
	scalar_mult = SpecificMultiplier(2.0)
	(
		scalar_mult(3),
		scalar_mult(4 + 5im),
		scalar_mult(6 * ones(2, 2))
	)
end

# ╔═╡ da8f2fee-d628-40db-b3a0-cd3621698108
let
	scalar_mult = SpecificMultiplier(2.0)
	fieldnames(typeof(scalar_mult)), fieldtypes(typeof(scalar_mult))
end

# ╔═╡ e944147b-1aa7-4d1f-862f-74a902482178
typeof([1, 2]), typeof([1.0, 2.0]), typeof([[1, 2]])

# ╔═╡ 48ade0de-dca2-466c-8d7f-d33d58c2e9dc
begin
	struct GenericMultiplier{T}
		a::T
	end

	function (mult::GenericMultiplier)(x)
		return mult.a * x
	end
end

# ╔═╡ e7fb5372-7b21-4106-abc2-ad7b34ed8804
typeof(GenericMultiplier(2.0))

# ╔═╡ 8da955c1-a8c3-4749-aff9-18000ffbc1a1
typeof(GenericMultiplier([1 2; 3 4]))

# ╔═╡ d76d6aab-68ec-437e-a9f8-ede88d4a1d98
typeof(GenericMultiplier{Matrix{Float64}}([1 2; 3 4]))

# ╔═╡ 4494c54f-af32-4a85-8cb3-c9f0fd4b0910
let
	scalar_mult = GenericMultiplier(2.0)
	(
		scalar_mult(3),
		scalar_mult(4 + 5im),
		scalar_mult(6 * ones(2, 2))
	)
end

# ╔═╡ cd81bb0c-0713-4637-b093-8f234ecbbf99
let
	matrix_mult = GenericMultiplier([1 2; 3 4])
	(
		matrix_mult(3),
		matrix_mult(4 + 5im),
		matrix_mult(6 * ones(2, 2))
	)
end

# ╔═╡ 1eda3e74-c1c9-49b9-9c2a-d7a0a251e97e
all(isconcretetype, fieldtypes(GenericMultiplier{Float64}))

# ╔═╡ 8472cb44-e8c6-458f-bea8-b47928a4ba5f
let
	a = 2.0
	mult = GenericMultiplier(a)
	x = 1.0
	@code_warntype mult(x)
end

# ╔═╡ 2c6ed9ad-0b1e-40df-99f7-99261007d91f
let
	a = 2.0
	mult = GenericMultiplier(a)
	x = 1.0
	@code_llvm mult(x)
end

# ╔═╡ 9169dfb0-ab50-4034-95c4-bde5a8d19c29
Float64 <: AbstractFloat <: Real <: Number <: Any

# ╔═╡ f35f2817-8189-4378-b9c6-f3cc0f45291b
Int <: Signed <: Integer <: Real <: Number <: Any

# ╔═╡ 75603535-9442-4700-95d9-46ef9eafd872
Vector{Float64} <: Vector{Real}

# ╔═╡ 59dba8ad-6683-4dfd-8e91-ae2d189c48ed
Vector{Float64} <: Vector{<:Real}  # note the <: before Real

# ╔═╡ 1dc15d70-0319-4ffd-82d9-e329278b60da
Vector{Float64} <: Vector{T} where {T<:Real}

# ╔═╡ fb1f2a48-8621-41c4-b21e-57148d008a6e
struct MatrixMultiplier1
	a::Matrix{Real}
end

# ╔═╡ 3c0d15d2-4b32-4810-85c2-16ae6e235d66
struct MatrixMultiplier2
	a::Matrix{<:Real}
end


# ╔═╡ 66d4f793-df8c-4d6f-8096-b3b8be8120c1
struct MatrixMultiplier3{T<:Real}
	a::Matrix{T}
end

# ╔═╡ f682b8d0-a8be-4dd2-a561-034116aa0aac
struct MatrixMultiplier4{M<:Matrix{Real}}
	a::M
end

# ╔═╡ ec2c0f09-04c5-42c2-82e3-5ac92eb3ce6c
struct MatrixMultiplier5{M<:Matrix{<:Real}}
	a::M
end

# ╔═╡ bb921d09-b0d3-4367-9dd9-4a2ee99fb94c
struct MatrixMultiplier6{T<:Real,M<:Matrix{T}}
	a::M
end

# ╔═╡ 52223495-60cf-4946-8da3-89fc82ea9478


# ╔═╡ 2966e2f6-f66a-4f00-896d-9d58a6de7514
let
	if @isdefined Layer
		n, m = 3, 4
		W = rand(m, n)
		b = rand(m)
		σ = tanh
		x = rand(n)
		layer = Layer(W, b, σ)
		layer(x)
	end
end

# ╔═╡ a5854c6d-c204-4008-a227-8ad968445dfb


# ╔═╡ f501a904-42a0-4e3a-8a51-756df71fdabe


# ╔═╡ 6d690104-a588-4636-959d-f0ba569923c9
let
	if @isdefined Network
		n, m1, m2 = 3, 4, 5
		W1 = rand(m1, n)
		b1 = rand(m1)
		W2 = rand(m2, m1)
		b2 = rand(m2)
		σ = tanh
		x = rand(n)

		layer1 = Layer(W1, b1, σ)
		layer2 = Layer(W2, b2, σ)
		network = Network([layer1, layer2])
		network(x)
	end
end

# ╔═╡ ecb6775b-8197-49ef-85e6-3d58c32b81e0


# ╔═╡ 355479cd-7598-48e9-8283-da36d0e84393
PlutoUI.Resource("https://raw.githubusercontent.com/mitmath/JuliaComputation/main/homeworks/images/lineland.png")

# ╔═╡ f205fe06-9849-435f-963c-d7596592c979
# Your code here

# ╔═╡ fab7a339-a43c-4209-b15a-fe64e670636f
if @isdefined meeting_matrix
	let
		p = collect(1:5) ./ 5
		M = meeting_matrix(p)
	end
end

# ╔═╡ fe962381-6010-4c9c-8893-c51ce0ce17e4
function meeting_matrix5(p::Vector{R}) where {R}
	@assert length(p) == 5
	p̄ = one(R) .- p
	M = [
	zero(R)  p[1]*p[2]  p[1]*p̄[2]*p[3]  p[1]*p̄[2]*p̄[3]*p[4]  p[1]*p̄[2]*p̄[3]*p̄[4]*p[5]
	p[2]*p[1]  zero(R)  p[2]*p[3]  p[2]*p̄[3]*p[4]  p[2]*p̄[3]*p̄[4]*p[5]
	p[3]*p̄[2]*p[1]  p[3]*p[2]  zero(R)  p[3]*p[4]  p[3]*p̄[4]*p[5]
	p[4]*p̄[3]*p̄[2]*p[1]  p[4]*p̄[3]*p[2]  p[4]*p[3]  zero(R) p[4]*p[5]
	p[5]*p̄[4]*p̄[3]*p̄[2]*p[1]  p[5]*p̄[4]*p̄[3]*p[2]  p[5]*p̄[4]*p[3]  p[5]*p[4]  zero(R)
	]
	return M
end

# ╔═╡ f90861ce-0854-44aa-b064-d59b1d113528
# Your code here

# ╔═╡ 2bf674a4-d039-48af-8642-1160873b2f70
# Your code here

# ╔═╡ 02f7ec49-1ab9-4ae0-a3ee-baee0dd25ea6
# Your code here

# ╔═╡ 2d3f2591-3d7b-41b6-9129-777168379510
# Your code here

# ╔═╡ 8686e348-f608-4b2f-aec5-c524444d6ce5
if @isdefined MeetingMatrix
	let
		p = collect(1:5) ./ 5
		M = MeetingMatrix(p)
	end
end

# ╔═╡ efa37d3b-b556-419e-a8ab-5e627975cca4
# Your code here

# ╔═╡ e029e040-b0f9-41ed-9474-7f31bd21bf06
if @isdefined MeetingMatrix
	let
		p = collect(1:4) ./ 5
		M = MeetingMatrix(p)
		det(M), tr(M)
	end
end

# ╔═╡ d3f9486e-1ad5-4062-845a-76e6cfeb715c
# Your code here

# ╔═╡ 1821f496-c065-468e-a206-c0fd2e75e539
function multiply_neighbors_matrix(p::Vector, x)
	return [multiply_row_neighbors_matrix(p, i, x) for i in 1:length(p)]
end

# ╔═╡ 8b896d3d-7796-468d-ae6e-553ed4eb84e4
function neighbors_matrix5(p::Vector{R}) where {R}
	p̄ = one(R) .- p
	N = [
		zero(R)         one(R)     p̄[2]     p̄[2]*p̄[3]  p̄[2]*p̄[3]*p̄[4]
		one(R)          zero(R)    one(R)   p̄[3]       p̄[3]*p̄[4]
		p̄[2]            one(R)     zero(R)  one(R)     p̄[4]
		p̄[3]*p̄[2]       p̄[3]       one(R)   zero(R)    one(R)
		p̄[4]*p̄[3]*p̄[2]  p̄[4]*p̄[3]  p̄[4]     one(R)     zero(R)
	]
	return N
end

# ╔═╡ af29b6cc-ed69-466d-98eb-62fa41806cae
function one_hot(n, i)
	x = zeros(n)
	x[i] = 1.0
	return x
end

# ╔═╡ 28d69223-f7a3-4b9f-8eb9-8dc1239ba04a
# Your code here

# ╔═╡ def18cb7-29db-4de6-b896-69923c038f74
if (@isdefined meeting_matrix) && (@isdefined multiply_meeting_matrix)
	let
		p = collect(1:5) ./ 5
		x = rand(5)
		meeting_matrix(p) * x, multiply_meeting_matrix(p, x)
	end
end

# ╔═╡ 51bdc11d-8bcb-4a31-b455-af176e4adf1a
let
	A = rand(4, 4)
	b = rand(4)
	x = A \ b
	A * x - b
end

# ╔═╡ 047d66ac-64fa-47e9-a566-89d840b8ea07
let
	A = rand(4, 4)
	b = rand(4)
	x1 = @btime $A \ $b
	x2 = @btime inv($A) * $b
	@assert A * x1 ≈ b
	@assert A * x2 ≈ b
	x1, x2
end

# ╔═╡ a94d571f-a983-474e-b4e2-f9044dd87be0
let
	A = rand(4, 8)
	b = rand(4)
	x1 = A \ b
	x2 = pinv(A) * b
	@assert A * x1 ≈ b
	@assert A * x2 ≈ b
	x1, x2
end

# ╔═╡ 2af6a3a0-6ccc-40d6-9af1-9046551a85d1
let
	A = rand(8, 4)
	b = rand(8)
	x1 = A \ b
	x2 = pinv(A) * b
	@assert !(A * x1 ≈ b)
	@assert !(A * x2 ≈ b)
	x1, x2
end

# ╔═╡ a876ca5b-1b10-420e-b070-bfc5126e9065
let
	A = rand(4, 4)
	b = rand(4)
	@which A \ b
end

# ╔═╡ bb3e3399-a7bc-49a2-8e10-88e6e7f82751
let
	A = Symmetric(rand(4, 4))
	b = rand(4)
	@which A \ b
end

# ╔═╡ 87300b00-cb9b-4584-8d17-fe9e8a9359de
let
	A = Diagonal(rand(4, 4))
	b = rand(4)
	@which A \ b
end

# ╔═╡ 8151780e-6e83-473f-ae88-fb991ce35ec7
let
	A = rand(4, 4)  # matrix
	A_fun = (x -> A * x)  # function
	b = rand(4)
	x1 = A \ b
	x2, _ = linsolve(A_fun, b)
	x1, x2
end

# ╔═╡ 480252e0-0815-45b0-b1c4-51bdbd02561c
struct LazyMatrixSum{
	R,M1<:AbstractMatrix{R},M2<:AbstractMatrix{R}
} <: AbstractMatrix{R}
	m1::M1
	m2::M2
	function LazyMatrixSum(m1, m2)
		@assert eltype(m1) == eltype(m2)
		@assert size(m1) == size(m2)
		return new{eltype(m1),typeof(m1),typeof(m2)}(m1, m2)
	end
end

# ╔═╡ a201234a-65e0-42d9-8b4a-619243542cb7
Base.size(ls::LazyMatrixSum) = size(ls.m1)

# ╔═╡ d52efd79-490b-400c-a81d-709bb6703b62
function loss(W, x)
	b = zeros(size(W, 1))
	σ = tanh
	layer = Layer(W, b, σ)
	y = layer(x)
	ℓ = sum(abs2, y)
	return ℓ
end

# ╔═╡ c87724ba-f81c-4c51-9aae-d24f2caafd72
let
	if @isdefined Layer
		n, m = 3, 4
		W = rand(m, n)
		x = rand(n)
		ForwardDiff.gradient(W_ -> loss(W_, x), W)
	end
end

# ╔═╡ e4c988de-2d03-43c8-ae5d-c708e76dc463
Base.getindex(ls::LazyMatrixSum, i, j) = ls.m1[i, j] + ls.m2[i, j]

# ╔═╡ d4f96362-7945-4a18-99dd-52a94f6cc65b
md"""
Homework 3 of the MIT Course [_Julia: solving real-world problems with computation_](https://github.com/mitmath/JuliaComputation)

Release date: Thursday, Oct 10, 2024 (version 3)

**Due date: Wednesday, Oct 23, 2024 at 11:59pm EST**

Submission by: Jazzy Doe (jazz@mit.edu)
"""

# ╔═╡ 332586f5-f1c5-461e-bfeb-ad3c72e77162
md"""
# 0. More on types & performance
"""

# ╔═╡ 7921ba43-e3c5-49e0-8312-c598e22f5a77
md"""
Consider this section as a warm up with lots of useful Julia-related tips.
It does not have a direct connection to climate modeling, but at the end, you will be able to write your first neural network from scratch and apply automatic differentiation on it.
How about that!
"""

# ╔═╡ 96a552b4-07f6-49d5-bbb9-af20de05e118
md"""
## 1.0 Abstract and concrete types
"""

# ╔═╡ f0d4ba8a-5ba4-4c99-9909-566f6ad9bc6a
md"""
Remember from HW1 that Julia has a type hierarchy with two ingredients: abstract types and concrete types.
Concrete types (like `Float64` or `Int`) are the ones that you can actually instantiate, while abstract types (like `Real` or `Number`) serve to define generic methods for several concrete types at once.
"""

# ╔═╡ 3801285b-1d77-4d30-b09c-33bc2479a9a4
md"""
Why does the difference matter?
Because with a concrete type, the memory layout of the object is well specified.
If the compiler knows it will work on `Float64` numbers, it can generate very efficient code that is taylored to this representation.
But if the compiler only knows it will work on `Real` numbers, then it must generate a very clunky code that works for all possible subtypes of real numbers: integers, rationals, floating point, etc.
"""

# ╔═╡ 350b49a6-138b-40ce-a1e9-bfa4c338cb0b
md"""
It is very simple to check whether you are dealing with an abstract or concrete type.
"""

# ╔═╡ 984405b9-102d-4a5c-b935-1a1c6a5850f2
md"""
Since multiple subtyping / inheritance does not exist in Julia, the type hierarchy can be represented as a tree, with `Any` (the most generic type) as its root.
Abstract types correspond to internal nodes of the tree, while concrete types are the leaves (they have no children).
"""

# ╔═╡ 04e9635e-e8c1-4c4c-b0ce-45d45d08bce3
md"""
You can explore the relations between types with the functions `supertypes` and `subtypes`.
"""

# ╔═╡ 187472ae-8504-465e-a3d9-88903adf6276
md"""
!!! danger "Task 1.0.1"
	Implement a function `count_descendants(T)` which outputs the number of descendants (the node itself + all of its children, grandchildren, etc.) of a type `T` in the type tree.
	How many descendants does `Real` have?
	Does this number depend on the packages we have imported?
"""

# ╔═╡ 1219c77e-339e-4d8b-ae00-ef3c5c5c21ef
let
	if @isdefined count_descendants
		try
			check = count_descendants(Integer) == 17
			if check
				correct()
			else
				almost(md"`count_descendants(Integer)` should be equal to 17")
			end
		catch e
			almost(md"`count_descendants(Integer)` throws an error")
		end
	else
		almost(md"You need to define `count_descendants`")
	end
end

# ╔═╡ a19bd1a1-03dc-4cd4-a8f3-b2794a0bc023
md"""
## 0.1 Callable structs
"""

# ╔═╡ 45fcb8df-60bc-407c-88fe-8c04676cac73
md"""
By now, you know how to define functions in Julia, using the syntax below.
"""

# ╔═╡ 285d0e09-0734-444a-a996-59ff6aa99454
md"""
!!! danger "Task 0.1.1"
	What is the type of `my_identity`? What are its supertypes?
"""

# ╔═╡ cf7bbffd-5d50-4081-adfb-a83f29ae3ae1
md"""
Functions are just a particular kind of callable object (or "functor").
But as it turns out, every type can be made callable using a very simple trick: just define a function whose "name" is an instance of the type.
This is very useful when you want to perform operations with some internal parameters (like weights in a neural network, see below).
"""

# ╔═╡ 64cbe24b-3d7b-4baf-ab3c-36532e272d3f
md"""
Here's a simple example, in which we define a `Multiplier` struct with a single attribute `a`.
When we call an instance `mult` of this type on a value `x`, we want to obtain the product `mult.a * x`.
"""

# ╔═╡ 982fe485-5fe4-4a0b-8efd-6acf2d8fb725
md"""
Note that we put both definitions in the same cell because of Pluto quirks.
Now let's check that everything works as intended.
"""

# ╔═╡ b612120a-57e3-4e27-84b8-c9bc583273a7
md"""
!!! danger "Task 0.1.2"
	Implement a callable struct `FunctionWrapper` with a single field `f`.
	Whenever it is called, it should simply apply the function `f` to the input arguments.
"""

# ╔═╡ 8500b18f-6dd1-419f-b4d8-3b6226139edd
hint(md"If you want a function to accept any number of positional and keyword arguments, the syntax is `f(args...; kwargs...)`")

# ╔═╡ 314305f5-7d35-42e0-b021-e673a1e9e12e
let
	if @isdefined FunctionWrapper
		try
			fw = FunctionWrapper(sin)
			try
				check = fw(1) == sin(1)
				if check
					correct()
				else
					almost(md"`FunctionWrapper(sin)(1)` should be equal to`sin(1)`")
				end
			catch e
				almost(md"`FunctionWrapper(sin)(1)` throws an error")
			end
		catch e
			almost(md"`FunctionWrapper(sin)` throws an error")
		end
	else
		almost(md"You need to define `FunctionWrapper`")
	end
end

# ╔═╡ e03e6ddd-5472-4756-9be4-98f88bc6efd0
md"""
## 0.2 Type-stability
"""

# ╔═╡ f1a9d3a5-cacb-4209-a245-20fa0f830fda
md"""
Remember when I told you that there were more secrets to writing high-perfomance Julia code?
Well, today is your lucky day, because I'm going to teach you about type stability.
Yay!

Type inference is the process by which Julia tries to deduce the type of every variable in your code before actually running it.
A code that enables successful type inference is called type-stable.

For each function you write, can you deduce the type of every intermediate and output quantity based only on the _types_ (not the _values_) of the inputs?
If the answer is yes, then your code is type-stable.
"""

# ╔═╡ 21119b23-ec97-4685-a560-df04ae356a2d
md"""
!!! danger "Task 0.2.1"
	Try to explain why the following function is type-unstable.
"""

# ╔═╡ 6777c1e7-3872-4e1a-ac2d-6c15bdd67bd1
md"""
The `Multiplier` defined above works, but it is far from perfect.
Its biggest fault is that it doesn't "know" the type of the field `a`.
As a result, it generates type-unstable calls because Julia cannot predict the type of the output `a * x`.

Such problems can often be diagnosed with the `@code_warntype` macro, which is used before a function call.
As a rule of thumb, blue is good and red is bad, while yellow is "meh".
"""

# ╔═╡ f7aa5fbf-5ad6-4683-be58-e36122c44c0d
md"""
This is not easy to read, but what is important is the type of every intermediate quantity is correctly inferred as `Float64`.
"""

# ╔═╡ 60ba39a0-3053-4218-bb97-5c48691b1a87
md"""
On the other hand, since the type of `mult.a` is forgotten by the `Multiplier`, all we can infer is that it will be of type `Any`, which is a supertype of everything else (see `%1`).
As a consequence, the type of `Body` (which is the output of the function) is also inferred as `Any` (see `%2`).
"""

# ╔═╡ a7ed6d02-1df6-42d0-8682-b2e8de65a5df
md"""
But why is it bad to have type-instability?
Because Julia has to prepare for every possible type, which generates very lengthy and inefficient machine code.
This can be confirmed with the `@code_llvm` macro.
"""

# ╔═╡ 4af31359-e631-4463-81ea-6db8a12ff6f9
md"""
This low-level code is only a few lines long.
"""

# ╔═╡ 0f822f2e-4303-4e2f-b89e-5480b91cc05e
md"""
Whereas this one is the stuff of nightmares.
"""

# ╔═╡ 7016769d-b4a5-47ad-bc4f-23fb78c9cf92
md"""
!!! danger "Task 0.2.2"
	Test the type-stability of your `FunctionWrapper`.
"""

# ╔═╡ b208b16b-7c93-4eae-a78a-2085c92ebd15
hint(md"Don't worry if it is not type-stable: that's okay for now.")

# ╔═╡ 00e39c74-3016-4acd-93df-6118ff8805d2
md"""
## 0.3 Parametric types
"""

# ╔═╡ ad87780c-55cc-4292-b02c-f346858b56e2
md"""
So how do we solve the type-instability issue?
Well, the general idea is to [avoid fields with abstract types](https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-fields-with-abstract-type) in user-defined structs.
The sames principle applies to [arrays and other containers](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-abstract-container).
If the type of each field (or element) is concrete, then type inference suceeds, which leads to better performance.
"""

# ╔═╡ 2c374578-67bf-4076-835b-ace79dd6e9f5
md"""
Let's see if this criterion is satisfied by our `Multiplier` (spoiler alert: no it isn't).
"""

# ╔═╡ d29cf227-fcc6-42a2-b29a-5438c9a8afa1
md"""
Of course, the easy way out would be to add a concrete type annotation for the field `a`.
"""

# ╔═╡ 4be0eca7-4da8-465a-ab84-013d0d650c90
md"""
This time, we can check that our struct has a concrete field type.
"""

# ╔═╡ 12eee95d-3e13-4fd0-94d2-deac8bf16541
md"""
But if we go down that road, we will need a different struct for every possible type of `a`.
That seems a bit tedious, especially since the multiplication code does not change.
What we really need is a single struct that somehow "adapts" to the type of the field `a`.

You've already seen that kind of construct before, when we introduced arrays.
Vectors and matrices have a "type parameter", which refers to the elements they contain.
"""

# ╔═╡ 45dab6b3-a0d7-4e7b-8c7e-8d7639295832
md"""
As a result, `Vector`, `Matrix` and `Array` are called [parametric types](https://docs.julialang.org/en/v1/manual/types/#Parametric-Types).
We can define our own parametric type with the following syntax.
"""

# ╔═╡ 609c22b1-c5e3-4e0e-bfc7-ab6d8ab729fd
md"""
Every time we create a `GenericMultiplier`, it will automatically choose the right type parameter based on the type of `a`.
"""

# ╔═╡ e48d4a41-86c1-4b08-afcd-d3558d44ed1b
md"""
We can also be picky and specify the parameter ourselves at construction.
"""

# ╔═╡ 0b8f06cd-3aec-49dc-b55b-420a6b2928f4
md"""
This new struct works as expected, no matter what we throw at it.
"""

# ╔═╡ bbe3a16c-3f86-4fe5-870e-b352847e8a8a
md"""
Importantly, this generic approach does not prevent type inference.
"""

# ╔═╡ b206b71c-c53c-4cb7-ba89-b955f7e54317
md"""
As a result, the generated machine code is about as efficient as can be.
"""

# ╔═╡ 768b2538-4f84-4678-9b0b-b47e396f0b04
md"""
But don't take my word for it, check it yourself!
"""

# ╔═╡ 44f991d0-3cda-471c-a4ef-306ddbc28ff4
md"""
!!! danger "Task 0.3.1"
	Compare the performance of `Multiplier`, `SpecificMultiplier` and `GenericMultiplier{T}` with `BenchmarkTools.jl`.
"""

# ╔═╡ ffde71b8-0074-4a68-a2ae-f17bb93ecaba
hint(md"
You already know the `@btime` and `@belapsed` macros, why not try `@benchmark` this time?
And don't forget the dollar signs!
")

# ╔═╡ fde230ba-99f0-4a9f-a496-2bb66fabd923
md"""
In other words, `GenericMultiplier` combines the generic capabilities of `Multiplier` with the type-specific performance of `SpecificMultiplier`.
That is called having your cake and eating it too, which is a Julia specialty.
"""

# ╔═╡ b62cf9b5-abd1-468f-97ec-baa0e3c8eaee
md"""
## 0.4 Type constraints
"""

# ╔═╡ 28a6f048-858d-4175-8832-e7b616c02ec3
md"""
In some cases, we want to enforce constraints on the type parameters.
This is done with the `<:` operator, which indicates subtyping.
"""

# ╔═╡ bb36265c-62db-49a1-93d4-8c63bee1e047
md"""
In more complex situations, the subtyping behavior can seem a bit counterintuitive, as described in the documentation for [parametric types](https://docs.julialang.org/en/v1/manual/types/#man-parametric-composite-types).
Even if `T1 <: T2`, we don't have `ParametricType{T1} <: ParametricType{T2}`.
See for yourself.
"""

# ╔═╡ 11bf0eed-424d-4504-bbf6-a843c964827f
md"""
Here is a way to overcome this difficulty.
"""

# ╔═╡ 21bc1fe6-41da-4989-996c-34ad6fa00620
md"""
And here is another equivalent one, with a keyword you already encountered in HW1.
"""

# ╔═╡ b5ba5479-d23b-4be7-a038-6160aad2edaf
md"""
Now say we want to define a `Multiplier` that only works when `a` is a matrix containing any subtype of real numbers.
Here are several ways to do it.
"""

# ╔═╡ eaef1e36-13f8-4e02-bd82-48e9509d0ac4
md"""
!!! danger "Task 0.4.1"
	Based on our discussion sofar, experiment with these various `MatrixMultiplier` structs and decide which ones a) have the correct behavior with respect to our specification, and b) are type-stable.

	Sum up your answers in the table below.
	If you think a given `MatrixMultiplier` is incorrect, provide a code example where it throws an error.
	If you think a given `MatrixMultiplier` is type-unstable, provide a code example where `@code_warntype` contains red flags.
"""

# ╔═╡ df9afa07-1351-4ead-8ac8-5479179e7ab8
md"""
| Struct | Correct | Performance |
| --- | --- | --- |
| `MatrixMultiplier1` | yes/no | bad/good |
| `MatrixMultiplier2` | yes/no | bad/good |
| `MatrixMultiplier3` | yes/no | bad/good |
| `MatrixMultiplier4` | yes/no | bad/good |
| `MatrixMultiplier5` | yes/no | bad/good |
| `MatrixMultiplier6` | yes/no | bad/good |
"""

# ╔═╡ dadfa60b-ca6c-409d-8a8d-d0b5923a8b47
md"""
## 0.5 Your first neural network
"""

# ╔═╡ 7bee5d0b-e4db-4ab4-94cc-fd2ffaff5136
md"""
Callable structs come up a lot in deep learning, whenever we construct layers of a [neural network](https://en.wikipedia.org/wiki/Artificial_neural_network).
A neural network layer is a function of the form $x \in \mathbb{R}^n \longmapsto \sigma.(W x + b) \in \mathbb{R}^m$, where
- the matrix $W \in \mathbb{R}^{m \times n}$ contains connection weights
- the vector $b \in \mathbb{R}^m$ contains biases
- the function $\sigma: \mathbb{R} \longrightarrow \mathbb{R}$ is a nonlinear activation applied elementwise
"""

# ╔═╡ f426d2d9-1b03-4be1-b69d-2b3d7e98a833
md"""
!!! danger "Task 0.5.1"
	Implement a callable struct `Layer` with three fields `W`, `b` and `σ`, such that:

	- `W` must be a matrix containing any subtype of `Real` numbers
	- `b` must be a vector containing any subtype of `Real` numbers
	- `σ` can be anything.

	Whenever it is called, it should perform the operation described above.
"""

# ╔═╡ b20afd9f-ede7-4b64-acdd-5202d70b6e9b
md"""
!!! danger "Task 0.5.2"
	Test the type-stability of your `Layer`.
"""

# ╔═╡ 608126ef-be59-42b1-8e5d-7a297d327c26
let
	n, m = 3, 4
	W = rand(m, n)
	b = rand(m)
	σ = tanh

	if @isdefined Layer
		try
			layer = Layer(W, b, σ)
			if all(isconcretetype, fieldtypes(typeof(layer)))
				correct()
			else
				almost(md"The `Layer` struct has abstract field types")
			end
		catch e
			almost(md"The `Layer` constructor throws an error")
		end
	else
		almost(md"You need to define `Layer`")
	end
end

# ╔═╡ c9126c15-d506-4f25-9e1d-80f55ab133ea
md"""
A feedforward neural network is just a sequence of layers applied one after the other.
"""

# ╔═╡ 3d6f376a-d9fc-4e3e-bce0-8efb3bc36ce5
md"""
!!! danger "Task 0.5.3"
	Implement a callable struct `Network` with a single field `layers`, which is a vector whose elements are all `Layer`s
	Whenever it is called, it should apply each layer sequentially.
"""

# ╔═╡ b5000c7c-302f-41ed-a5aa-91e0abe89d76
let
	n, m1, m2 = 3, 4, 5
	W1 = rand(m1, n)
	b1 = rand(m1)
	W2 = rand(m2, m1)
	b2 = rand(m2)
	σ = tanh
	x = rand(n)

	if (@isdefined Layer) && (@isdefined Network)
		try
			layer1 = Layer(W1, b1, σ)
			layer2 = Layer(W2, b2, σ)
			try
				network = Network([layer1, layer2])
				try
					y = network(x)
					check = y ≈ σ.(W2 * σ.(W1 * x + b1) + b2)
					if check
						correct()
					else
						almost(md"Calling the `Network` returns an incorrect result")
					end
				catch e
					almost(md"Calling the `Network` throws an error")
				end
			catch e
				almost(md"The `Network` constructor throws an error")
			end
		catch e
			almost(md"The `Layer` constructor throws an error")
		end
	else
		almost(md"You need to define `Layer` and `Network`")
	end
end

# ╔═╡ c682343b-abb4-4ede-ae11-034306f7b880
md"""
!!! danger "Task 0.5.4"
	Test the type-stability of your `Network`.
"""

# ╔═╡ c058e0f0-39a1-44c8-9c73-64c522973447
let
	n, m1, m2 = 3, 4, 5
	W1 = rand(m1, n)
	b1 = rand(m1)
	W2 = rand(m2, m1)
	b2 = rand(m2)
	σ = tanh

	if (@isdefined Layer) && (@isdefined Network)
		try
			layer1 = Layer(W1, b1, σ)
			layer2 = Layer(W2, b2, σ)
			network = Network([layer1, layer2])
			network.layers
			if (
				all(isconcretetype, fieldtypes(typeof(network))) &&
				all(isconcretetype, fieldtypes(eltype(network.layers)))
			)
				correct()
			else
				almost(md"The `Network` struct has abstract field types")
			end
		catch e
			almost(md"The `Layer` or `Network` constructor throws an error")
		end
	else
		almost(md"You need to define `Layer` and `Network`")
	end
end

# ╔═╡ 22aaddf3-c541-438c-9800-5c8f0621ff07
md"""
Why is it so important to use parametric types?
For one thing, if you remember, it is essential for forward-mode automatic differentiation.
And if you coded your `Layer` properly, the following snippet will work just fine.
"""

# ╔═╡ c0f57380-f746-4d22-8403-8d9d4606012f
md"""
# 1. Social gatherings on a street
"""

# ╔═╡ fedf534f-24b2-43ea-96dd-86f678987ec9
md"""
## 1.1 Problem description
"""

# ╔═╡ 36976d68-1684-4123-a663-8b0407ee31ee
md"""
Welcome to Julia Street, the beating heart of Julia Town!
In this charming neighborhood, the residents are numbered from $1$ to $n$, as they should be.
They like to visit each other for a cup of tea, but due to their random moods, things rarely go as planned...

Every day, each resident $i \in [n]$ chooses their mood following a coin flip: good with probability $p_i$, and bad with probability $1-p_i$.
For residents $i$ and $j$ to meet, the following conditions must be satisfied (we assume $i < j$):
- both $i$ and $j$ must be in a good mood
- all the other $k \in \{i+1,...,j-1\}$ must be in a bad mood
Indeed, if even one resident $k$ between them is also in a good mood, $i$ will stop at $k$'s house on the way to $j$'s, and so the meeting between $i$ and $j$ will never happen.

"""

# ╔═╡ 33845853-3597-4998-b04b-c6886d64adea
md"""
In other words, the probability that $i$ and $j$ meet on a given day is
```math
	M_{ij}(p) = p_i \left(\prod_{k=\min(i,j)+1}^{\max(i,j)-1} (1-p_k)\right) p_j
```
We also define $M_{ii}(p) = 0$.
As an example, for $n = 5$, we have
```math
M(p) = \begin{pmatrix}
0 & p_1 p_2 & p_1 \bar{p}_2 p_3 & p_1 \bar{p}_2 \bar{p}_3 p_4 & p_1 \bar{p}_2 \bar{p}_3 \bar{p}_4 p_5 \\
p_2 p_1 & 0 & p_2 p_3 & p_2 \bar{p}_3 p_4 & p_2 \bar{p}_3 \bar{p}_4 p_5 \\
p_3 \bar{p}_2 p_1 & p_3 p_2 & 0 & p_3 p_4 & p_3 \bar{p}_4 p_5 \\
p_4 \bar{p}_3 \bar{p}_2 p_1 & p_4 \bar{p}_3 p_2 & p_4 p_3 & 0 & p_4 p_5 \\
p_5 \bar{p}_4 \bar{p}_3 \bar{p}_2 p_1 & p_5 \bar{p}_4 \bar{p}_3 p_2 & p_5 \bar{p}_4 p_3 & p_5 p_4 & 0
\end{pmatrix}
```
where we wrote $\bar{p}_i = 1-p_i$ for convenience.
"""

# ╔═╡ 36ba0cd6-61e7-46ea-92af-bec8758b2f0a
md"""
## 1.2 Matrix representations
"""

# ╔═╡ df267206-71ee-47b1-b732-5adbad023cea
md"""
The goal of this section is to present several ways to manipulate a matrix.
"""

# ╔═╡ e1d3d726-0f2b-437f-831c-521e9c105176
md"""
!!! danger "Task 1.2.1"
	Define a function `meeting_matrix(p)` which takes a vector $p$ of mood probabilities and returns the matrix $M(p)$ of meeting probabilities.
	The output matrix should have the same element type as the input vector.
"""

# ╔═╡ 363b3a59-4e7c-4532-a52d-aa1ece8a2237
hint(md"""
Use the `prod` function to compute a product.
You will probably get a `MethodError`, which can be solved by supplying an `init` keyword argument (what is the neutral element for multiplication?)
""")

# ╔═╡ 625b8ace-cbbc-4dfe-aa71-0d60ad9786b6
if @isdefined meeting_matrix
	let
		p = collect(1:5) ./ 5
		M_true = meeting_matrix5(p)
		try
			M = meeting_matrix(p)
			if M ≈ M_true
				correct()
			else
				almost(md"`meeting_matrix` returns an incorrect result")
			end
		catch e
			almost(md"`meeting_matrix` throws an error")
		end
	end
else
	almost(md"You need to define `meeting_matrix`")
end

# ╔═╡ dc47f817-b451-4055-bb8e-3bd6687f0e3c
md"""
!!! danger "Task 1.2.2"
	Does $M(p)$ have any interesting structural property?
	How can we express it in Julia code?
"""

# ╔═╡ c6cf31d9-dfe1-4b9a-acb3-0ad199b7f03a
hint(md"Take a look at the documentation on [special matrices](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/#Special-matrices)")

# ╔═╡ 59381db6-4f7c-4255-9e4a-6b116d6542fa
md"""
> Your answer here
"""

# ╔═╡ 641c4d16-445e-41e6-b978-b7acb2a31981
md"""
This special format is interesting because
- it enforces equality between the upper and lower triangular parts of a matrix
- it can influence the efficiency of numerical linear algebra (more on this below)
"""

# ╔═╡ 1fecaaac-7c37-4032-af5e-f784b9977765
md"""
Unfortunately, even a symmetric matrix still needs to store $\frac{n(n+1)}{2}$ coefficients.
For our specific use case, this is a bit overkill, because $M(p)$ is entirely defined by $n$ coefficients.
This means we can save memory thanks to a custom struct which "behaves like a matrix".
The way to do that is by extending the [`AbstractArray` interface](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array).
"""

# ╔═╡ 36fc7d25-77b9-4088-b46c-6e718528ffa0
md"""
!!! danger "Task 1.2.3"
	Define a parametric struct `MeetingMatrix{R}` whose only field `p` is a vector with elements of type `R`.
	Make this struct a subtype of `AbstractMatrix{R}`.
"""

# ╔═╡ 5e68a931-0306-4581-b256-a193658439a5
md"""
!!! danger "Task 1.2.4"
	Implement the methods `Base.size(M)` and `Base.getindex(M, i, j)` for the type `MeetingMatrix`.
"""

# ╔═╡ eb5404f6-8f4d-449e-959f-fc81debbef7f
if @isdefined MeetingMatrix
	let
		p = collect(1:5) ./ 5
		M_true = meeting_matrix5(p)
		try
			M = MeetingMatrix(p)
			if Matrix(M) ≈ M_true
				correct()
			else
				almost(md"`MeetingMatrix` returns an incorrect result")
			end
		catch e
			almost(md"`MeetingMatrix` throws an error")
		end
	end
else
	almost(md"You need to define `MeetingMatrix`")
end

# ╔═╡ ddf2584f-63e0-4fe7-a895-a850ed97a0b8
md"""
Note that the Pluto (and REPL) display will compute a few coefficients of the `MeetingMatrix`, but these coefficients are not actually stored within the struct.
"""

# ╔═╡ 55d51ebf-8172-414f-b868-b7b24cbb787d
md"""
!!! danger "Task 1.2.5"
	Compare the memory footprint of `M1 = meeting_matrix(p)` and `M2 = MeetingMatrix(p)`.
	What did we sacrifice for this gain?
"""

# ╔═╡ 3403402f-7a4c-4d00-873e-17a44ca8f7aa
hint(md"Use the function `Base.summarysize`")

# ╔═╡ aef77331-eaea-4b34-a944-537f1c0b53a0
md"""
> Your answer here
"""

# ╔═╡ 7d39ac63-708b-4374-902f-cedf3d9df384
md"""
Now that our struct "behaves like a matrix", the whole universe of linear algebra becomes accessible without further effort!
"""

# ╔═╡ f6b41ff9-d362-469d-a714-2b85acba2b03
md"""
In some situations, it might be more efficient to consider matrices as linear operators, i.e. functions that apply to vectors.
We have seen an example in HW2 with vector-Jacobian products, and now we give another one.
"""

# ╔═╡ 9177bb33-0240-41a7-8732-85b0471d5548
md"""
!!! danger "Task 1.2.6"
	Look at the formula for $M(p)$ with $n = 5$.
	What do you notice about the first term in the products on a given row? And the last term in the products on a given column?
"""

# ╔═╡ 5e8c1a90-7461-4116-a6aa-fff4d8f2def6
md"""
> Your answer here
"""

# ╔═╡ f2a9da31-8c31-4a72-9f2b-9541ee3931fc
md"""
!!! danger "Task 1.2.7"
	Give another expression for $M(p)$ of the form $D(p) N(p) D(p)$, where
	- the term $D(p)$ is a diagonal matrix whose coefficients only involve $p$
	- the term $N(p)$ is the neighbors matrix whose coefficients only involve $\bar{p}$
"""

# ╔═╡ 3f6001f1-3bf3-4a89-92ca-07a8ee0bab75
md"""
> Your answer here
"""

# ╔═╡ 2befedaf-5fd2-471c-8e8b-574f741277ef
md"""
!!! danger "Task 1.2.8"
	Define a function `multiply_row_neighbors_matrix(p, i, x)` which returns the dot product between the $i$-th row of $N(p)$ and a vector $x$.
	Your function must be efficient: avoid recomputing products of the $\bar{p}_j$ whenever possible.
"""

# ╔═╡ 80030ad9-956d-464a-87d3-e5b6083e8113
hint(md"Use two loops: one for indices $j \in \{i+1, ..., n\}$ and one for indices $j \in \{i-1, ..., 1\}$. In each one, accumulate the product of the $\bar{p}_j$ in a temporary variable.")

# ╔═╡ 7a2d0d30-4dc1-4701-bb7f-04ef9e46974a
if @isdefined multiply_row_neighbors_matrix
	let
		p = collect(1:5) ./ 5
		N_true = neighbors_matrix5(p)
		try
			N = hcat(
				(multiply_neighbors_matrix(p, one_hot(5, i)) for i in 1:5)...
			)
			if N ≈ N_true
				correct()
			else
				almost(md"`multiply_row_neighbors_matrix` returns an incorrect result")
			end
		catch e
			almost(md"`multiply_row_neighbors_matrix` throws an error")
		end
	end
else
	almost(md"You need to define `multiply_row_neighbors_matrix`")
end

# ╔═╡ 4ea6b4f9-3f7c-4d23-b911-f7f2a4e23135
md"""
!!! danger "Task 1.2.9"
	Define a function `multiply_meeting_matrix(p, x)` which computes the product $M(p)x$.
"""

# ╔═╡ ffdca609-1047-46fa-a2d2-8ca0db26371f
hint(md"Use the function `multiply_neighbors_matrix` as a subroutine")

# ╔═╡ d44754fe-6c16-4561-9b4e-c64cad147b8d
if (
	(@isdefined multiply_row_neighbors_matrix) &&
	(@isdefined multiply_meeting_matrix)
)
	let
		p = collect(1:5) ./ 5
		M_true = meeting_matrix5(p)
		try
			M = hcat(
				(multiply_meeting_matrix(p, one_hot(5, i)) for i in 1:5)...
			)
			if M ≈ M_true
				correct()
			else
				almost(md"`multiply_row_neighbors_matrix` or `multiply_meeting_matrix` returns an incorrect result")
			end
		catch e
			almost(md"`multiply_row_neighbors_matrix` or `multiply_meeting_matrix` throws an error")
		end
	end
else
	almost(md"You need to define `multiply_row_neighbors_matrix` and `multiply_meeting_matrix`")
end

# ╔═╡ 4988e048-4846-498a-86b5-da54a61b247c
md"""
## 1.3 Linear systems of equations
"""

# ╔═╡ 3407e79e-96bd-4425-8655-a6bbff21173b
md"""
Linear systems are the backbone of many numerical routines, from differential equations to implicit differentiation.
The Julia ecosystem offers a plethora of possibilities for solving them.
"""

# ╔═╡ 26e252b6-956d-428f-9228-f705095ac946
md"""
The [binary `\` operator](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/#Base.:\\-Tuple{AbstractMatrix,%20AbstractVecOrMat}) is a very versatile way to solve a linear system $Ax = b$.
Let us see it in action.
"""

# ╔═╡ 20979a07-b6c9-4b7b-987f-266e900c8543
md"""
When $A$ is square and nonsingular, it returns the same solution one would get with the matrix inverse `inv(A)`, but much faster.
"""

# ╔═╡ f0bec76f-d70b-41b0-859c-645a40b3733c
md"""
When $A$ is rectangular and fat (many variables, few equations), then the solution may not be unique.
In this case, `\` returns the solution $x$ with smallest Euclidean norm.
This solution can also be obtained with the [Moore-Penrose pseudoinverse](https://en.wikipedia.org/wiki/Moore–Penrose_inverse) `pinv(A)`.
"""

# ╔═╡ 2b4b2084-1c38-490d-b3f8-215963b87d82
md"""
Finally, when $A$ is rectangular and thin (many equations, few variables), then the solution may not exist.
In this case, `\` returns a vector minimizing the squared Euclidean error between $Ax$ and $b$, breaking ties by the Euclidean norm of $x$.
Again, this solution can be obtained with the Moore-Penrose pseudoinverse `pinv(A)`.
"""

# ╔═╡ f942b9c0-b40a-4d9f-aedb-73b1848d9709
md"""
!!! danger "Task 1.3.1"
	Explain the behavior of the following code cells using the concept of multiple dispatch.
"""

# ╔═╡ 2063fdfc-120b-4603-983f-f1abb2790ad2
hint(md"The macro `@which` shows you which method was called by a given function")

# ╔═╡ d306cee2-6261-4125-8c5f-52d8e46f8a54
md"""
> Your answer here
"""

# ╔═╡ f3a64b98-e901-4f06-bdfc-0f2b99014049
md"""
In fact, `\` is compatible with any matrix satisfying the `AbstractMatrix` interface.
This includes the `MeetingMatrix` you defined earlier!
"""

# ╔═╡ fbcba267-24ed-461c-bd3e-4a3a8182c32c
md"""
!!! danger "Task 1.3.2"
	Can multiple dispatch choose a linear solve algorithm based on the size of the matrix $A$?
"""

# ╔═╡ 0a0afd07-6ab4-418e-80e0-d0cc4eccce54
md"""
> Your answer here
"""

# ╔═╡ 02d10c6b-a987-4f8f-ba00-45a38df9abe1
md"""
For high-dimensional applications, factorization-based methods no longer work, and solvers often rely on iterative methods, also called Krylov subspace methods.
You may have encountered some of them before, like "conjugate gradient" or "GMRES".
Their main strength is that they do not require a full matrix, only a linear operator.

The most modern package in this area is [LinearSolve.jl](https://github.com/SciML/LinearSolve.jl), but here we present [KrylovKit.jl](https://github.com/Jutho/KrylovKit.jl) which we deem more accessible.
"""

# ╔═╡ 16061b47-c086-4f38-a6d8-685872504f72
md"""
Of course, the previous example is rather contrived.
But remember your `multiply_meeting_matrix` function: Krylov methods are a typical scenario where it could come in handy.
And guess what?
It actually will come in handy... in the next section!
"""

# ╔═╡ de4508fc-7549-4ced-91cd-9f7166ebffc1
md"""
## 1.4 Utilities
"""

# ╔═╡ 8f0da298-9bb4-491e-8be7-e8def8ded6e5
md"""
You can safely skip to the beginning of section 2, there is no task to be found here.
"""

# ╔═╡ 466cb64c-0570-4951-9c1e-31afec1aef49
let
	m1 = rand(4, 4)
	m2 = rand(4, 4)
	ls = @btime LazyMatrixSum($m1, $m2)
	@assert ls ≈ m1 .+ m2
end

# ╔═╡ bfad99bc-3805-4037-8f3b-600e978c3976
fahrenheit(T) = (T - 273.15) * (9/5) + 32

# ╔═╡ fa0c41c6-ad85-48e8-a9e0-d88539199355
md"""
# 2. Layered atmospheric model
"""

# ╔═╡ c1b7f2e0-7095-40e8-8077-515378261c90
md"""
In a few weeks we will have a few lectures on climate modeling in-class. Ordinarily we would assign this segment of the problem set after those lectures, but this year we will think of them as a sort of preview of the lectures :). 

If you have any questions about the mathematics please post on Piazza, or come to office hours!
"""

# ╔═╡ 4ec40d1a-66d6-4d3c-9e45-a7432082083f
md"""
## 2.1 Problem description
"""

# ╔═╡ b7ea1640-01e3-4f9b-9232-51764024dcb0
md"""
In our study of the role of the atmosphere on Earth’s energy budget, we only considered the lower layer of the atmosphere, the troposphere.
It contains most of the atmospheric mass and dominates the absorption/emission of thermal/longwave radiation.

In this problem, we will also consider the role played by the stratosphere, the atmospheric layer above the troposphere.
Observations suggest that the stratosphere has been cooling over the last century, a trend opposite to what has been well documented in the troposphere.
The stratosphere is rich in ozone, a gas that absorbs shortwave radiation.
Thus, unlike the troposphere, whose main source of radiative forcing is longwave radiation from the surface, the stratosphere is also heated by absorbed shortwave radiation.
This leads to a different stratospheric response to an increase in $\text{CO}_2$ concentrations.

To see different effects at play in the atmosphere we have to switch to a _layered_ model, in which shortwave and longwave radiations are modeled separately
"""

# ╔═╡ 6e8b5dbe-4f1a-11ed-1d6d-898b90885e3d
md"""
$(PlutoUI.Resource("https://raw.githubusercontent.com/mitmath/JuliaComputation/main/homeworks/images/atmosphere.png"))
**Figure:** Schematic showing the pathways of longwave (blue) and shortwave (red) radiation in a 4-layer climate model (1 surface layer + 3 atmosphere layers).
"""

# ╔═╡ 047f32ac-c8bf-4f36-9f9c-3a4ab2998371
md"""
Longwave radiation is emitted by each atmospheric layer $i$ with energy $\sigma \varepsilon_i T_i^4$, where $T_i$ is the temperature of the layer.
When passing through layer $i$, a fraction $\varepsilon_i$ of the radiation is absorbed and the remaining fraction $1-\varepsilon_i$ is transmitted.
Each layer $i \geq 1$ emits in both directions, so the total energy emitted amounts to $2\sigma \varepsilon_i T_i^4$.
The surface layer $i = 1$ emits only upwards and we consider it to be a perfect blackbody with $\varepsilon_1=1$.

Shortwave radiation comes from the sun and hits the upper atmosphere with energy $S_0 / 4$.
When passing through layer $i$, a fraction $\beta_i$ of the radiation is absorbed and the remaining fraction $1-\beta_i$ is transmitted.
When hitting the surface, this remaining fraction $1-\beta_1$ is reflected upwards instead.
"""

# ╔═╡ f1faf89a-58ef-445e-b7f3-cc15391a127e
md"""
## 2.2 Numerical values
"""

# ╔═╡ 7de00277-3dc9-4c87-8b4b-fcbeeed8656d
md"""
Here are the physical parameters we will work with.
"""

# ╔═╡ 1eebce33-d71d-4a8d-be22-843e2ee283ea
σ_val = 5.67e-8

# ╔═╡ 9b8f0c49-aff6-4705-be09-134784bee7ad
S₀_val = 1356.2

# ╔═╡ 83af51e5-b8d7-4487-9664-2052a7ef21c5
ε_val = [1.0, 0.66, 0.50, 0.31, 0.22]

# ╔═╡ 149140f0-8849-4011-adf9-b50b24052e16
β_val  = [0.7, 0.015, 0.018, 0.021, 0.043]

# ╔═╡ 7a3b31ea-dee5-4d90-96e5-83fcb4f98f53
md"""
## 2.3 Energy balance
"""

# ╔═╡ 7ec215a8-3f60-4752-833d-85dafc71ad3d
md"""
Here are the energy balance equations for a 4-layer atmosphere.
They are obtained by applying the following principle to each layer:
```math
0 = \text{absorbed longwave} - \text{emitted longwave} + \text{absorbed shortwave}
```
To save space, we write $\bar{\varepsilon}_i = 1 - \varepsilon_i$ and $\bar{\beta}_i = 1 - \beta_i$.
We also define $\bar{B} = \prod_{k=1}^{n} \bar{\beta}_k$
"""

# ╔═╡ 017d0901-9045-4622-bc73-13a74ecf38ad
md"""
```math
\begin{array}{llllllll}
0 =
& - \varepsilon_1 T_1^4
& + \varepsilon_2 T_2^4 \varepsilon_1
& + \varepsilon_3 T_3^4 \bar{\varepsilon}_2 \varepsilon_1
& + \varepsilon_4 T_4^4 \bar{\varepsilon}_3 \bar{\varepsilon}_2 \varepsilon_1
& + \frac{S_0}{4\sigma} \bar{\beta}_4 \bar{\beta}_3 \bar{\beta}_2 \beta_1
& + 0
\\
0 =
& + \varepsilon_1 T_1^4 \varepsilon_2
& - 2\varepsilon_2 T_2^4
& + \varepsilon_3 T_3^4 \varepsilon_2
& + \varepsilon_4 T_4^4 \bar{\varepsilon}_3 \varepsilon_2
& + \frac{S_0}{4\sigma} \bar{\beta}_4 \bar{\beta}_3 \beta_2
& + \frac{S_0}{4\sigma} \bar{\beta}_4 \bar{\beta}_3 \bar{\beta}_2 \bar{\beta}_1 \beta_2
\\
0 =
& + \varepsilon_1 T_1^4 \bar{\varepsilon}_2 \varepsilon_3
& + \varepsilon_2 T_2^4 \varepsilon_3
& - 2\varepsilon_3 T_3^4
& + \varepsilon_4 T_4^4 \varepsilon_3
& + \frac{S_0}{4\sigma} \bar{\beta}_4 \beta_3
& + \frac{S_0}{4\sigma} \bar{\beta}_4 \bar{\beta}_3 \bar{\beta}_2 \bar{\beta}_1 \bar{\beta}_2 \beta_3
\\
0 =
& + \varepsilon_1 T_1^4 \bar{\varepsilon}_2 \bar{\varepsilon}_3 \varepsilon_4
& + \varepsilon_2 T_2^4 \bar{\varepsilon}_3 \varepsilon_4
& + \varepsilon_3 T_3^4 \varepsilon_4
& - 2\varepsilon_4 T_4^4
& + \frac{S_0}{4\sigma} \beta_4
& + \frac{S_0}{4\sigma} \bar{\beta}_4 \bar{\beta}_3 \bar{\beta}_2 \bar{\beta}_1 \bar{\beta}_2 \bar{\beta}_3 \beta_4
\end{array}
```
"""

# ╔═╡ 6dce25d0-907c-45ec-a73d-6ed0948dd112
md"""
We can rephrase this as a nonlinear system of equations $A T^4 = b$, where
"""

# ╔═╡ a4d6fe4b-cbac-4165-9467-606035bbf70f
md"""
```math
A = \begin{pmatrix}
& - \varepsilon_1
& \varepsilon_2 \varepsilon_1
& \varepsilon_3 \bar{\varepsilon}_2 \varepsilon_1
& \varepsilon_4 \bar{\varepsilon}_3 \bar{\varepsilon}_2 \varepsilon_1
\\
& \varepsilon_1 \varepsilon_2
& - 2\varepsilon_2
& \varepsilon_3 \varepsilon_2
& \varepsilon_4 \bar{\varepsilon}_3 \varepsilon_2
\\
& \varepsilon_1 \bar{\varepsilon}_2 \varepsilon_3
& \varepsilon_2 \varepsilon_3
& - 2\varepsilon_3
& \varepsilon_4 \varepsilon_3
\\
& \varepsilon_1 \bar{\varepsilon}_2 \bar{\varepsilon}_3 \varepsilon_4
& \varepsilon_2 \bar{\varepsilon}_3 \varepsilon_4
& \varepsilon_3 \varepsilon_4
& -2\varepsilon_4
\end{pmatrix}
```
"""

# ╔═╡ 8eb52f83-ff89-4dc0-a90f-99d1bfb59b20
md"""
```math
b = \frac{-S_0}{4\sigma} \begin{pmatrix}
 \bar{\beta}_4 \bar{\beta}_3 \bar{\beta}_2 \beta_1
& + & 0
\\
\bar{\beta}_4 \bar{\beta}_3 \beta_2
& + & \bar{B} \beta_2
\\
\bar{\beta}_4 \beta_3
& + & \bar{B} \bar{\beta}_2 \beta_3
\\
\beta_4
& + & \bar{B} \bar{\beta}_2 \bar{\beta}_3 \beta_4
\end{pmatrix}
\qquad \text{and} \qquad
T = \begin{pmatrix}
T_1 \\
T_2 \\
T_3 \\
T_4
\end{pmatrix}
```
"""

# ╔═╡ a0a6bacc-26d9-4c65-b218-9616db10f856
md"""
Solving the nonlinear system $AT^4 = b$ will give us the equilibrium temperatures $T^*$.
Of course, in practice, we solve the linear system $Ax = b$, and then retrieve $T^* = (x^*)^{1/4}$.
"""

# ╔═╡ c53630b5-0b7e-4fcb-ac96-affb16e1b9f0
md"""
From now on, we call $A$ the "longwave radiation matrix" and $b$ the "shortwave radiation vector".
"""

# ╔═╡ 5098783f-75fd-4373-9ad9-dd39b5a86aa8
md"""
!!! danger "Task 2.3.1"
	Give a formula for $A$ based on the meeting matrix $M$ defined earlier.
"""

# ╔═╡ 0205887c-69ed-4e1e-84df-0d1b4b935ddc
md"""
> Your answer here
"""

# ╔═╡ 3caa1420-97f9-40c7-bc0e-0243c845ee59
md"""
Because I'm a nice person, here is an implementation of the shortwave radiation vector.
You're welcome.
"""

# ╔═╡ e49db03e-ca45-4c7f-a93c-bc679c1fd01a
function shortwave_vector(β::Vector{R}, S₀, σ) where {R}
	n = length(β)
	β̄ = one(R) .- β
	B̄ = prod(β̄)
	b = Vector{R}(undef, n)
	b[1] = @views prod(β̄[2:n]; init=β[1])
	for i in 2:n
		b[i] = @views prod(β̄[(i+1):n]; init=β[i]) + B̄ * prod(β̄[2:(i-1)]; init=β[i])
	end
	return (-S₀ / (4σ)) .* b
end

# ╔═╡ a7096c5e-d409-490c-8caf-d064427a5265
shortwave_vector(β_val, S₀_val, σ_val)

# ╔═╡ 563bc60a-019f-42be-a311-84547a851b81
md"""
## 2.4 Matrix representations
"""

# ╔═╡ 7a0dc9b7-d4cc-415c-83a6-7d50f17d89f6
md"""
We now put your knowledge of matrix representations to good use on the case of the longwave radiation matrix.
"""

# ╔═╡ b5cdbbb4-b186-4124-be6a-be18bbc754ff
md"""
!!! danger "Task 2.4.1"
	Define a function `longwave_matrix(ε)` which computes $A$ and stores it as a symmetric matrix.
"""

# ╔═╡ 8f710f8a-afe2-454a-9f2c-15cfffb1c50e
hint(md"Use `meeting_matrix`")

# ╔═╡ 27c38ade-61d3-409f-ad7a-16a2361397ce
# Your code here

# ╔═╡ d0a4f988-271c-41e0-a0c7-fd013eb8aabe
if @isdefined longwave_matrix
	longwave_matrix(ε_val)
end

# ╔═╡ d2e80eee-db09-4711-b542-205b38248b57
function longwave_matrix5()
	return [
		-1.0        0.66       0.17     0.0527   0.025806
		0.66      -1.32       0.33     0.1023   0.050094
		0.17       0.33      -1.0      0.155    0.0759
		0.0527     0.1023     0.155   -0.62     0.0682
		0.025806   0.050094   0.0759   0.0682  -0.44
	]
end

# ╔═╡ f47a9a12-65ef-44f4-bc77-1b852f61986e
if @isdefined longwave_matrix
	let
		L_true = longwave_matrix5()
		try
			L = longwave_matrix(ε_val)
			if isapprox(L, L_true; atol=1e-2)
				correct()
			else
				almost(md"`longwave_matrix` returns an incorrect result")
			end
		catch e
			almost(md"`longwave_matrix` throws an error")
		end
	end
else
	almost(md"You need to define `longwave_matrix`")
end

# ╔═╡ 6e0c6e9f-ef00-44bb-956b-923af174000c
md"""
!!! danger "Task 2.4.2"
	Define a function `LongwaveMatrix(ε)` (yes, it looks like a type constructor) which stores $A$ in a memory-efficient way.
"""

# ╔═╡ 3ab919ee-6d9a-47e1-93fe-d1ce25c63236
hint(md"Use `MeetingMatrix` and `LazyMatrixSum`")

# ╔═╡ 85de703d-d9c9-40bc-a414-e8c3920800d7
# Your code here

# ╔═╡ 499623fe-6a87-4b41-9f31-355c486c7ce4
if @isdefined LongwaveMatrix
	LongwaveMatrix(ε_val)
end

# ╔═╡ 447a7da7-c087-43fe-8abf-5b9079e711d8
if @isdefined LongwaveMatrix
	let
		L_true = longwave_matrix5()
		try
			L = Matrix(LongwaveMatrix(ε_val))
			if isapprox(L, L_true; atol=1e-2)
				correct()
			else
				almost(md"`LongwaveMatrix` returns an incorrect result")
			end
		catch e
			almost(md"`LongwaveMatrix` throws an error")
		end
	end
else
	almost(md"You need to define `LongwaveMatrix`")
end

# ╔═╡ f3de07e7-9421-4eb5-b52b-8c450ece3511
md"""
!!! danger "Task 2.4.3"
	Define a function `multiply_longwave_matrix(ε, x)` which takes a vector $x$ and returns $Ax$.
"""

# ╔═╡ 3c98b50b-decb-4e0a-88a4-a08166e450cc
hint(md"Use `multiply_meeting_matrix`")

# ╔═╡ 388af3f8-527d-4f1a-ad21-2fb1295bc265
# Your code here

# ╔═╡ 5ce016da-1336-49ae-8735-7e73f4ef9031
if (@isdefined longwave_matrix) && (@isdefined multiply_longwave_matrix)
	let
		x = rand(length(ε_val))
		longwave_matrix(ε_val) * x, multiply_longwave_matrix(ε_val, x)
	end
end

# ╔═╡ c4bdbbf9-1c7a-43ee-8a21-93d6324902f6
if @isdefined multiply_longwave_matrix
	let
		L_true = longwave_matrix5()
		try
			L = hcat(
				(multiply_longwave_matrix(ε_val, one_hot(5, i)) for i in 1:5)...
			)
			if isapprox(L, L_true; atol=1e-2)
				correct()
			else
				almost(md"`multiply_longwave_matrix` returns an incorrect result")
			end
		catch e
			almost(md"`multiply_longwave_matrix` throws an error")
		end
	end
else
	almost(md"You need to define `multiply_longwave_matrix`")
end

# ╔═╡ ae4bc271-0ca2-4d66-a8ca-cf63474aef0b
md"""
## 2.5 Finding the equilibrium
"""

# ╔═╡ d93ca9c1-81f9-47dc-9b5c-8a682deb672e
md"""
!!! danger "Task 2.5.1"
	Compute the equilibrium temperatures for a 4-layer atmosphere with the numerical values given in section 2.2.
	Use the three matrix representations you defined above, and check that you obtain the same results.
"""

# ╔═╡ 9d4bb825-ec3f-4c12-9db0-8067d2facb25
hint(md"Depending on the representation, you might have to choose between `\` and `linsolve`")

# ╔═╡ 7c5abef9-382a-4947-ab9f-c6e721828615
# Your code here

# ╔═╡ 243ae79c-3a94-48f2-b9b4-11e7e74cbea8
# Your code here

# ╔═╡ 0cd01e96-5cd6-4200-83e2-5dfd1fc874c2
# Your code here

# ╔═╡ 659b2aa6-c95f-4d88-ae58-17f520250791
if (
	(@isdefined longwave_matrix) &&
	(@isdefined LongwaveMatrix) &&
	(@isdefined multiply_longwave_matrix)
)
	let
		b = shortwave_vector(β_val, S₀_val, σ_val)
		F_true = [89.3755, 38.494, 1.30706, -25.7982, -32.3701]
		try
			A1 = A = longwave_matrix(ε_val)
			A2 = LongwaveMatrix(ε_val)
			A3 = x -> multiply_longwave_matrix(ε_val, x)
			x1 = A1 \ b
			x2 = A2 \ b
			x3, _ = linsolve(A3, b)
			T1 = x1 .^ (1/4)
			T2 = x2 .^ (1/4)
			T3 = x3 .^ (1/4)
			F1 = fahrenheit.(T1)
			F2 = fahrenheit.(T2)
			F3 = fahrenheit.(T3)
			if !isapprox(F1, F_true; atol=1e-2)
				almost(md"The equilibrium temperatures deduced from `longwave_matrix` are incorrect")
			elseif !isapprox(F2, F_true; atol=1e-2)
				almost(md"The equilibrium temperatures deduced from `LongwaveMatrix` are incorrect")
			elseif !isapprox(F3, F_true; atol=1e-2)
				almost(md"The equilibrium temperatures deduced from `multiply_longwave_matrix` are incorrect")
			else
				correct()
			end
		catch e
			almost(md"Either `longwave_matrix`, `LongwaveMatrix`, `multiply_longwave_matrix` or one of the linear systems throws an error.")
		end
	end
else
	almost(md"You need to define `longwave_matrix`, `LongwaveMatrix` and `multiply_longwave_matrix`")
end

# ╔═╡ 685fa229-5cd1-432b-8dc6-fe5beb47fa67
md"""
## 2.6 Anthopogenic climate change?
"""

# ╔═╡ 99c61fe1-6ac3-4e66-95a7-0750426f6eac
md"""
In our simple model, the surface of the earth can heat up because of 2 different causes:
- an increase in solar flux $S_0$ (natural fluctuations of the sun's activity)
- an increase in $\varepsilon$ (anthropogenic modifications of the atmosphere)
"""

# ╔═╡ 371bb174-3757-4809-8ec8-73ca27c5b3ba
md"""
`ΔS₀ = ` $(@bind ΔS₀ Slider(0.0:1e0:2e2; default=0.0, show_value=true))
"""

# ╔═╡ b0bebbb7-83bc-456a-a125-206922b667bb
md"""
`Δε = ` $(@bind Δε Slider(0.0:1e-2:0.1; default=0.0, show_value=true))
"""

# ╔═╡ 623889cd-937c-44e0-9e47-17d5eb05bb68
if (@isdefined longwave_matrix)
	let
		A = longwave_matrix(min.(1.0, ε_val .+ Δε))
		b = shortwave_vector(β_val, S₀_val + ΔS₀, σ_val)
		x = A \ b
		T = x .^ (1/4)
		fahrenheit.(T)
	end
end

# ╔═╡ c6d3945c-9e16-4c4c-a07b-b7070226e936
md"""
!!! danger "Task 2.6.1"
	Increase the solar flux `S₀_val` and look at the effect on the equilibrium temperatures.
	Verify that the surface layer heats up.
	What happens to the upper layer?
"""

# ╔═╡ b7e239c4-00e1-4083-983c-9364f3fdf57e
md"""
> Your answer here
"""

# ╔═╡ 3baed377-7b8f-4d31-bc6b-84b41724e76c
md"""
!!! danger "Task 2.6.2"
	Increase all the coefficients `ε_val` (except that of the surface) and look at the effect on the equilibrium temperatures.
	Verify that the surface layer heats up.
	What happens to the upper layer?
"""

# ╔═╡ 06a7b2ed-1693-4a68-979d-2ff9eeda8d94
md"""
> Your answer here
"""

# ╔═╡ 86daab2d-695c-4f62-9e8c-8dd13939e008
md"""
!!! danger "Task 2.6.3"
	Observations clearly show that the upper atmosphere is cooling down.
	Which of our two candidate causes for global heating is confirmed by the data?
"""

# ╔═╡ 330aceeb-147a-423f-81ff-462c0cd3aeda
md"""
> Your answer here
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractTrees = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
ImageIO = "82e4d734-157c-48bb-816b-45c225c6df19"
ImageShow = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
KrylovKit = "0b1a1467-8014-51b9-945f-bf0ae24f4b77"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
AbstractTrees = "~0.4.5"
BenchmarkTools = "~1.5.0"
FileIO = "~1.16.3"
ImageIO = "~0.6.8"
ImageShow = "~0.3.8"
KrylovKit = "~0.5.4"
PlutoTeachingTools = "~0.2.3"
PlutoUI = "~0.7.60"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.5"
manifest_format = "2.0"
project_hash = "c72c2bdbd50f533a24d702fcc2a9059cc1e3e4b6"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "f1dff6729bc61f4d49e140da1af55dcd1ac97b2f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.5.0"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "7eee164f122511d3e4e1ebadb7956939ea7e1c77"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.6"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b5278586822443594ff615963b0c09755771b3e0"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.26.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "82d8afa92ecf4b52d78d869f038ebfb881267322"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.3"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Formatting]]
deps = ["Logging", "Printf"]
git-tree-sha1 = "fb409abab2caf118986fc597ba84b50cbaf00b87"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.3"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "2e4520d67b0cef90865b3ef727594d2a58e0e1f8"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.11"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageCore]]
deps = ["ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "b2a7eaa169c13f5bcae8131a83bc30eff8f71be0"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.2"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "437abb322a41d527c197fa800455f79d414f0a3c"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.8"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "355e2b974f2e3212a75dfb60519de21361ad3cb7"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.9"

[[deps.ImageShow]]
deps = ["Base64", "ColorSchemes", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "3b5344bcdbdc11ad58f3b1956709b5b9345355de"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.8"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0936ba688c6d201805a83da835b55c61a180db52"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.11+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IntervalSets]]
git-tree-sha1 = "dba9ddf07f77f60450fe5d2e2beb9854d9a49bd0"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.10"

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

    [deps.IntervalSets.weakdeps]
    Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "f389674c99bfcde17dc57454011aa44d5a260a40"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "fa6d0bcff8583bac20f1ffa708c3913ca605c611"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.5"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "25ee0be4d43d0269027024d75a24c24d6c6e590c"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.4+0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "2984284a8abcfcc4784d95a9e2ea4e352dd8ede7"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.36"

[[deps.KrylovKit]]
deps = ["LinearAlgebra", "Printf"]
git-tree-sha1 = "49b0c1dd5c292870577b8f58c51072bd558febb9"
uuid = "0b1a1467-8014-51b9-945f-bf0ae24f4b77"
version = "0.5.4"

[[deps.LaTeXStrings]]
git-tree-sha1 = "50901ebc375ed41dbf8058da26f9de442febbbec"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.1"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "8c57307b5d9bb3be1ff2da469063628631d4d51e"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.21"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    DiffEqBiologicalExt = "DiffEqBiological"
    ParameterizedFunctionsExt = "DiffEqBase"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    DiffEqBase = "2b5f629d-d688-5b77-993f-72d75c75574e"
    DiffEqBiological = "eb300fae-53e8-50a0-950c-e21f52c2b7e0"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "c2b5e92eaf5101404a58ce9c6083d595472361d6"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "3.0.2"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.MappedArrays]]
git-tree-sha1 = "2dab0221fe2b0f2cb6754eaa743cc266339f527e"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.2"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
git-tree-sha1 = "1a27764e945a152f7ca7efa04de513d473e9542e"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.14.1"

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

    [deps.OffsetArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "8292dd5c8a38257111ada2174000a33745b06d4e"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.2.4+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "67186a2bc9a90f9f85ff3cc8277868961fb57cbd"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.3"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

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
git-tree-sha1 = "d8be3432505c2febcea02f44e5f4396fae017503"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.3"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eba4810d5e6a01f612b948c9fa94f905b49087b0"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.60"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "8f6bc219586aef8baf0ff9a5fe16ee9c70cb65e4"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.10.2"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

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
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "2d4e5de3ac1c348fd39ddf8adbef82aa56b65576"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.6.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "98ca7c29edd6fc79cd74c61accb7010a4e7aee33"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.6.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "2da10356e31327c7096832eb9cd86307a50b1eb6"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "bc7fd5c91041f44636b2c134041f7e5263ce58ae"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.10.0"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "b70c870239dc3d7bc094eb2d6be9b73d27bef280"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.44+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "7dfa0fd9c783d3d0cc43ea1af53d69ba45c447df"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╟─d4f96362-7945-4a18-99dd-52a94f6cc65b
# ╠═d5cd95f9-6728-47e2-bba4-00298c78d50c
# ╠═0d4205ec-fec1-4ef4-af48-7dae51ab31ee
# ╠═1b452080-14eb-41f7-969b-e2727af54fa3
# ╟─03909b0c-c701-418a-ae68-7e99a52604e6
# ╟─332586f5-f1c5-461e-bfeb-ad3c72e77162
# ╟─7921ba43-e3c5-49e0-8312-c598e22f5a77
# ╟─96a552b4-07f6-49d5-bbb9-af20de05e118
# ╟─f0d4ba8a-5ba4-4c99-9909-566f6ad9bc6a
# ╟─3801285b-1d77-4d30-b09c-33bc2479a9a4
# ╟─350b49a6-138b-40ce-a1e9-bfa4c338cb0b
# ╠═7bdbb031-882b-4168-9e9f-2b54a1fc444c
# ╟─984405b9-102d-4a5c-b935-1a1c6a5850f2
# ╠═3e69e0e6-7d43-4adc-9ec7-5a37d9f006da
# ╠═2bf50413-2707-4a2e-9a5e-57ea3da1974f
# ╟─04e9635e-e8c1-4c4c-b0ce-45d45d08bce3
# ╠═dbe0fdef-f845-4513-9ed7-283c0843036f
# ╠═a8ba06ad-772d-4534-9d73-f017bc01945f
# ╟─187472ae-8504-465e-a3d9-88903adf6276
# ╠═f13ad51a-466f-4963-a209-9b38e781f672
# ╟─1219c77e-339e-4d8b-ae00-ef3c5c5c21ef
# ╟─a19bd1a1-03dc-4cd4-a8f3-b2794a0bc023
# ╟─45fcb8df-60bc-407c-88fe-8c04676cac73
# ╠═b6601d8d-623b-4945-ad53-557c99d13e4e
# ╟─285d0e09-0734-444a-a996-59ff6aa99454
# ╠═8e696410-7637-44aa-941b-986f50ac9a96
# ╟─cf7bbffd-5d50-4081-adfb-a83f29ae3ae1
# ╟─64cbe24b-3d7b-4baf-ab3c-36532e272d3f
# ╠═b71c3fa3-5b04-469f-bff1-db9f2c9dfbb0
# ╟─982fe485-5fe4-4a0b-8efd-6acf2d8fb725
# ╠═9f89d77b-c38c-40d6-b449-ef8baaa10481
# ╠═27d6041f-7174-4e80-a24c-b71b4a0caf6e
# ╟─b612120a-57e3-4e27-84b8-c9bc583273a7
# ╟─8500b18f-6dd1-419f-b4d8-3b6226139edd
# ╠═b514a411-cc7d-4e11-a2a5-06f13fccb468
# ╠═82a9d34e-2dc5-41a7-86ca-075810733787
# ╟─314305f5-7d35-42e0-b021-e673a1e9e12e
# ╟─e03e6ddd-5472-4756-9be4-98f88bc6efd0
# ╟─f1a9d3a5-cacb-4209-a245-20fa0f830fda
# ╟─21119b23-ec97-4685-a560-df04ae356a2d
# ╠═d809ced6-d076-4b11-a536-5795279a4bdf
# ╠═35a7588d-e83e-4e7d-a034-e8cd8f861498
# ╟─6777c1e7-3872-4e1a-ac2d-6c15bdd67bd1
# ╠═5e68691a-1ed2-4655-91c7-bcdc2309f253
# ╟─f7aa5fbf-5ad6-4683-be58-e36122c44c0d
# ╠═de7f4d78-2538-42f9-ba02-58656bd76f48
# ╟─60ba39a0-3053-4218-bb97-5c48691b1a87
# ╟─a7ed6d02-1df6-42d0-8682-b2e8de65a5df
# ╠═0f073958-35f2-43bb-92c8-ffaac28f6e9a
# ╟─4af31359-e631-4463-81ea-6db8a12ff6f9
# ╠═96b6f3de-d3ba-4bd4-8f1b-79c7e9b4d9f4
# ╟─0f822f2e-4303-4e2f-b89e-5480b91cc05e
# ╟─7016769d-b4a5-47ad-bc4f-23fb78c9cf92
# ╟─b208b16b-7c93-4eae-a78a-2085c92ebd15
# ╠═ea46208b-66bb-4976-b124-f20412816549
# ╟─00e39c74-3016-4acd-93df-6118ff8805d2
# ╟─ad87780c-55cc-4292-b02c-f346858b56e2
# ╟─2c374578-67bf-4076-835b-ace79dd6e9f5
# ╠═8b953dfc-4503-43f0-be33-51fa246033d0
# ╟─d29cf227-fcc6-42a2-b29a-5438c9a8afa1
# ╠═bd09874f-cdf4-489e-bbc3-f60281f75083
# ╠═326582ac-bfeb-4225-99ff-b4d2a6f2ea03
# ╟─4be0eca7-4da8-465a-ab84-013d0d650c90
# ╠═da8f2fee-d628-40db-b3a0-cd3621698108
# ╟─12eee95d-3e13-4fd0-94d2-deac8bf16541
# ╠═e944147b-1aa7-4d1f-862f-74a902482178
# ╟─45dab6b3-a0d7-4e7b-8c7e-8d7639295832
# ╠═48ade0de-dca2-466c-8d7f-d33d58c2e9dc
# ╟─609c22b1-c5e3-4e0e-bfc7-ab6d8ab729fd
# ╠═e7fb5372-7b21-4106-abc2-ad7b34ed8804
# ╠═8da955c1-a8c3-4749-aff9-18000ffbc1a1
# ╟─e48d4a41-86c1-4b08-afcd-d3558d44ed1b
# ╠═d76d6aab-68ec-437e-a9f8-ede88d4a1d98
# ╟─0b8f06cd-3aec-49dc-b55b-420a6b2928f4
# ╠═4494c54f-af32-4a85-8cb3-c9f0fd4b0910
# ╠═cd81bb0c-0713-4637-b093-8f234ecbbf99
# ╟─bbe3a16c-3f86-4fe5-870e-b352847e8a8a
# ╠═1eda3e74-c1c9-49b9-9c2a-d7a0a251e97e
# ╠═8472cb44-e8c6-458f-bea8-b47928a4ba5f
# ╟─b206b71c-c53c-4cb7-ba89-b955f7e54317
# ╠═2c6ed9ad-0b1e-40df-99f7-99261007d91f
# ╟─768b2538-4f84-4678-9b0b-b47e396f0b04
# ╟─44f991d0-3cda-471c-a4ef-306ddbc28ff4
# ╟─ffde71b8-0074-4a68-a2ae-f17bb93ecaba
# ╟─fde230ba-99f0-4a9f-a496-2bb66fabd923
# ╟─b62cf9b5-abd1-468f-97ec-baa0e3c8eaee
# ╟─28a6f048-858d-4175-8832-e7b616c02ec3
# ╠═9169dfb0-ab50-4034-95c4-bde5a8d19c29
# ╠═f35f2817-8189-4378-b9c6-f3cc0f45291b
# ╟─bb36265c-62db-49a1-93d4-8c63bee1e047
# ╠═75603535-9442-4700-95d9-46ef9eafd872
# ╟─11bf0eed-424d-4504-bbf6-a843c964827f
# ╠═59dba8ad-6683-4dfd-8e91-ae2d189c48ed
# ╟─21bc1fe6-41da-4989-996c-34ad6fa00620
# ╠═1dc15d70-0319-4ffd-82d9-e329278b60da
# ╟─b5ba5479-d23b-4be7-a038-6160aad2edaf
# ╠═fb1f2a48-8621-41c4-b21e-57148d008a6e
# ╠═3c0d15d2-4b32-4810-85c2-16ae6e235d66
# ╠═66d4f793-df8c-4d6f-8096-b3b8be8120c1
# ╠═f682b8d0-a8be-4dd2-a561-034116aa0aac
# ╠═ec2c0f09-04c5-42c2-82e3-5ac92eb3ce6c
# ╠═bb921d09-b0d3-4367-9dd9-4a2ee99fb94c
# ╟─eaef1e36-13f8-4e02-bd82-48e9509d0ac4
# ╠═df9afa07-1351-4ead-8ac8-5479179e7ab8
# ╟─dadfa60b-ca6c-409d-8a8d-d0b5923a8b47
# ╟─7bee5d0b-e4db-4ab4-94cc-fd2ffaff5136
# ╟─f426d2d9-1b03-4be1-b69d-2b3d7e98a833
# ╠═52223495-60cf-4946-8da3-89fc82ea9478
# ╠═2966e2f6-f66a-4f00-896d-9d58a6de7514
# ╟─b20afd9f-ede7-4b64-acdd-5202d70b6e9b
# ╠═a5854c6d-c204-4008-a227-8ad968445dfb
# ╟─608126ef-be59-42b1-8e5d-7a297d327c26
# ╟─c9126c15-d506-4f25-9e1d-80f55ab133ea
# ╟─3d6f376a-d9fc-4e3e-bce0-8efb3bc36ce5
# ╠═f501a904-42a0-4e3a-8a51-756df71fdabe
# ╠═6d690104-a588-4636-959d-f0ba569923c9
# ╟─b5000c7c-302f-41ed-a5aa-91e0abe89d76
# ╟─c682343b-abb4-4ede-ae11-034306f7b880
# ╠═ecb6775b-8197-49ef-85e6-3d58c32b81e0
# ╟─c058e0f0-39a1-44c8-9c73-64c522973447
# ╟─22aaddf3-c541-438c-9800-5c8f0621ff07
# ╠═d52efd79-490b-400c-a81d-709bb6703b62
# ╠═c87724ba-f81c-4c51-9aae-d24f2caafd72
# ╟─c0f57380-f746-4d22-8403-8d9d4606012f
# ╟─fedf534f-24b2-43ea-96dd-86f678987ec9
# ╟─36976d68-1684-4123-a663-8b0407ee31ee
# ╟─355479cd-7598-48e9-8283-da36d0e84393
# ╟─33845853-3597-4998-b04b-c6886d64adea
# ╟─36ba0cd6-61e7-46ea-92af-bec8758b2f0a
# ╟─df267206-71ee-47b1-b732-5adbad023cea
# ╟─e1d3d726-0f2b-437f-831c-521e9c105176
# ╟─363b3a59-4e7c-4532-a52d-aa1ece8a2237
# ╠═f205fe06-9849-435f-963c-d7596592c979
# ╠═fab7a339-a43c-4209-b15a-fe64e670636f
# ╟─fe962381-6010-4c9c-8893-c51ce0ce17e4
# ╟─625b8ace-cbbc-4dfe-aa71-0d60ad9786b6
# ╟─dc47f817-b451-4055-bb8e-3bd6687f0e3c
# ╟─c6cf31d9-dfe1-4b9a-acb3-0ad199b7f03a
# ╠═59381db6-4f7c-4255-9e4a-6b116d6542fa
# ╠═f90861ce-0854-44aa-b064-d59b1d113528
# ╟─641c4d16-445e-41e6-b978-b7acb2a31981
# ╟─1fecaaac-7c37-4032-af5e-f784b9977765
# ╟─36fc7d25-77b9-4088-b46c-6e718528ffa0
# ╠═2bf674a4-d039-48af-8642-1160873b2f70
# ╟─5e68a931-0306-4581-b256-a193658439a5
# ╠═02f7ec49-1ab9-4ae0-a3ee-baee0dd25ea6
# ╠═2d3f2591-3d7b-41b6-9129-777168379510
# ╠═8686e348-f608-4b2f-aec5-c524444d6ce5
# ╟─eb5404f6-8f4d-449e-959f-fc81debbef7f
# ╟─ddf2584f-63e0-4fe7-a895-a850ed97a0b8
# ╟─55d51ebf-8172-414f-b868-b7b24cbb787d
# ╟─3403402f-7a4c-4d00-873e-17a44ca8f7aa
# ╠═efa37d3b-b556-419e-a8ab-5e627975cca4
# ╠═aef77331-eaea-4b34-a944-537f1c0b53a0
# ╟─7d39ac63-708b-4374-902f-cedf3d9df384
# ╠═e029e040-b0f9-41ed-9474-7f31bd21bf06
# ╟─f6b41ff9-d362-469d-a714-2b85acba2b03
# ╟─9177bb33-0240-41a7-8732-85b0471d5548
# ╠═5e8c1a90-7461-4116-a6aa-fff4d8f2def6
# ╟─f2a9da31-8c31-4a72-9f2b-9541ee3931fc
# ╠═3f6001f1-3bf3-4a89-92ca-07a8ee0bab75
# ╟─2befedaf-5fd2-471c-8e8b-574f741277ef
# ╟─80030ad9-956d-464a-87d3-e5b6083e8113
# ╠═d3f9486e-1ad5-4062-845a-76e6cfeb715c
# ╠═1821f496-c065-468e-a206-c0fd2e75e539
# ╟─8b896d3d-7796-468d-ae6e-553ed4eb84e4
# ╟─af29b6cc-ed69-466d-98eb-62fa41806cae
# ╟─7a2d0d30-4dc1-4701-bb7f-04ef9e46974a
# ╟─4ea6b4f9-3f7c-4d23-b911-f7f2a4e23135
# ╟─ffdca609-1047-46fa-a2d2-8ca0db26371f
# ╠═28d69223-f7a3-4b9f-8eb9-8dc1239ba04a
# ╠═def18cb7-29db-4de6-b896-69923c038f74
# ╟─d44754fe-6c16-4561-9b4e-c64cad147b8d
# ╟─4988e048-4846-498a-86b5-da54a61b247c
# ╟─3407e79e-96bd-4425-8655-a6bbff21173b
# ╟─26e252b6-956d-428f-9228-f705095ac946
# ╠═51bdc11d-8bcb-4a31-b455-af176e4adf1a
# ╟─20979a07-b6c9-4b7b-987f-266e900c8543
# ╠═047d66ac-64fa-47e9-a566-89d840b8ea07
# ╟─f0bec76f-d70b-41b0-859c-645a40b3733c
# ╠═a94d571f-a983-474e-b4e2-f9044dd87be0
# ╟─2b4b2084-1c38-490d-b3f8-215963b87d82
# ╠═2af6a3a0-6ccc-40d6-9af1-9046551a85d1
# ╟─f942b9c0-b40a-4d9f-aedb-73b1848d9709
# ╟─2063fdfc-120b-4603-983f-f1abb2790ad2
# ╠═a876ca5b-1b10-420e-b070-bfc5126e9065
# ╠═bb3e3399-a7bc-49a2-8e10-88e6e7f82751
# ╠═87300b00-cb9b-4584-8d17-fe9e8a9359de
# ╠═d306cee2-6261-4125-8c5f-52d8e46f8a54
# ╟─f3a64b98-e901-4f06-bdfc-0f2b99014049
# ╟─fbcba267-24ed-461c-bd3e-4a3a8182c32c
# ╠═0a0afd07-6ab4-418e-80e0-d0cc4eccce54
# ╟─02d10c6b-a987-4f8f-ba00-45a38df9abe1
# ╠═8151780e-6e83-473f-ae88-fb991ce35ec7
# ╟─16061b47-c086-4f38-a6d8-685872504f72
# ╟─de4508fc-7549-4ced-91cd-9f7166ebffc1
# ╟─8f0da298-9bb4-491e-8be7-e8def8ded6e5
# ╠═480252e0-0815-45b0-b1c4-51bdbd02561c
# ╠═a201234a-65e0-42d9-8b4a-619243542cb7
# ╠═e4c988de-2d03-43c8-ae5d-c708e76dc463
# ╠═466cb64c-0570-4951-9c1e-31afec1aef49
# ╠═bfad99bc-3805-4037-8f3b-600e978c3976
# ╟─fa0c41c6-ad85-48e8-a9e0-d88539199355
# ╟─c1b7f2e0-7095-40e8-8077-515378261c90
# ╟─4ec40d1a-66d6-4d3c-9e45-a7432082083f
# ╟─b7ea1640-01e3-4f9b-9232-51764024dcb0
# ╟─6e8b5dbe-4f1a-11ed-1d6d-898b90885e3d
# ╟─047f32ac-c8bf-4f36-9f9c-3a4ab2998371
# ╟─f1faf89a-58ef-445e-b7f3-cc15391a127e
# ╟─7de00277-3dc9-4c87-8b4b-fcbeeed8656d
# ╠═1eebce33-d71d-4a8d-be22-843e2ee283ea
# ╠═9b8f0c49-aff6-4705-be09-134784bee7ad
# ╠═83af51e5-b8d7-4487-9664-2052a7ef21c5
# ╠═149140f0-8849-4011-adf9-b50b24052e16
# ╟─7a3b31ea-dee5-4d90-96e5-83fcb4f98f53
# ╟─7ec215a8-3f60-4752-833d-85dafc71ad3d
# ╟─017d0901-9045-4622-bc73-13a74ecf38ad
# ╟─6dce25d0-907c-45ec-a73d-6ed0948dd112
# ╟─a4d6fe4b-cbac-4165-9467-606035bbf70f
# ╟─8eb52f83-ff89-4dc0-a90f-99d1bfb59b20
# ╟─a0a6bacc-26d9-4c65-b218-9616db10f856
# ╟─c53630b5-0b7e-4fcb-ac96-affb16e1b9f0
# ╟─5098783f-75fd-4373-9ad9-dd39b5a86aa8
# ╠═0205887c-69ed-4e1e-84df-0d1b4b935ddc
# ╟─3caa1420-97f9-40c7-bc0e-0243c845ee59
# ╠═e49db03e-ca45-4c7f-a93c-bc679c1fd01a
# ╠═a7096c5e-d409-490c-8caf-d064427a5265
# ╟─563bc60a-019f-42be-a311-84547a851b81
# ╟─7a0dc9b7-d4cc-415c-83a6-7d50f17d89f6
# ╟─b5cdbbb4-b186-4124-be6a-be18bbc754ff
# ╟─8f710f8a-afe2-454a-9f2c-15cfffb1c50e
# ╠═27c38ade-61d3-409f-ad7a-16a2361397ce
# ╠═d0a4f988-271c-41e0-a0c7-fd013eb8aabe
# ╟─d2e80eee-db09-4711-b542-205b38248b57
# ╟─f47a9a12-65ef-44f4-bc77-1b852f61986e
# ╟─6e0c6e9f-ef00-44bb-956b-923af174000c
# ╟─3ab919ee-6d9a-47e1-93fe-d1ce25c63236
# ╠═85de703d-d9c9-40bc-a414-e8c3920800d7
# ╠═499623fe-6a87-4b41-9f31-355c486c7ce4
# ╟─447a7da7-c087-43fe-8abf-5b9079e711d8
# ╟─f3de07e7-9421-4eb5-b52b-8c450ece3511
# ╟─3c98b50b-decb-4e0a-88a4-a08166e450cc
# ╠═388af3f8-527d-4f1a-ad21-2fb1295bc265
# ╠═5ce016da-1336-49ae-8735-7e73f4ef9031
# ╟─c4bdbbf9-1c7a-43ee-8a21-93d6324902f6
# ╟─ae4bc271-0ca2-4d66-a8ca-cf63474aef0b
# ╟─d93ca9c1-81f9-47dc-9b5c-8a682deb672e
# ╟─9d4bb825-ec3f-4c12-9db0-8067d2facb25
# ╠═7c5abef9-382a-4947-ab9f-c6e721828615
# ╠═243ae79c-3a94-48f2-b9b4-11e7e74cbea8
# ╠═0cd01e96-5cd6-4200-83e2-5dfd1fc874c2
# ╟─659b2aa6-c95f-4d88-ae58-17f520250791
# ╟─685fa229-5cd1-432b-8dc6-fe5beb47fa67
# ╟─99c61fe1-6ac3-4e66-95a7-0750426f6eac
# ╟─371bb174-3757-4809-8ec8-73ca27c5b3ba
# ╟─b0bebbb7-83bc-456a-a125-206922b667bb
# ╠═623889cd-937c-44e0-9e47-17d5eb05bb68
# ╟─c6d3945c-9e16-4c4c-a07b-b7070226e936
# ╠═b7e239c4-00e1-4083-983c-9364f3fdf57e
# ╟─3baed377-7b8f-4d31-bc6b-84b41724e76c
# ╠═06a7b2ed-1693-4a68-979d-2ff9eeda8d94
# ╟─86daab2d-695c-4f62-9e8c-8dd13939e008
# ╠═330aceeb-147a-423f-81ff-462c0cd3aeda
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
