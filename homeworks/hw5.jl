### A Pluto.jl notebook ###
# v0.19.14

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
end

# ╔═╡ d5cd95f9-6728-47e2-bba4-00298c78d50c
student = (name = "Jazzy Doe", kerberos_id = "jazz")

# ╔═╡ 1b452080-14eb-41f7-969b-e2727af54fa3
PlutoUI.TableOfContents()

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

# ╔═╡ e4c988de-2d03-43c8-ae5d-c708e76dc463
Base.getindex(ls::LazyMatrixSum, i, j) = ls.m1[i, j] + ls.m2[i, j]

# ╔═╡ d4f96362-7945-4a18-99dd-52a94f6cc65b
md"""
Homework 5 of the MIT Course [_Julia: solving real-world problems with computation_](https://github.com/mitmath/JuliaComputation)

Release date: Thursday, Oct 27, 2022 (version 1)

**Due date: Thursday, Nov 3, 2022 at 11:59pm EST**

Submission by: Jazzy Doe (jazz@mit.edu)
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
	M_{ij}(p) = p_i \left(\prod_{k=i+1}^{j-1} (1-p_k)\right) p_j
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
hint(md"Use the function `Base.summarisize`")

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

# ╔═╡ e902d91c-040b-4374-801b-a9f6e35abc4d
md"""
# 3. Hello world on a GPU
"""

# ╔═╡ ede76efa-36aa-4e4a-820c-b223276e4a91
md"""
We are now entering the HPC and GPU portion of the class.
Next week's homework will require you to work on a GPU, so this week we want to make sure everyone is able to access JuliaHub in order to avoid surprises.

Follow the steps outlined in [this document](https://docs.google.com/document/d/146_lPEcIq6WODdw8oPUVs6Bflp5ptjL6t0YQ6zuyG44/edit?usp=sharing) to log in to JuliaHub and connect to a GPU Pluto notebook.
Use this notebook URL: <https://raw.githubusercontent.com/mitmath/JuliaComputation/main/homeworks/hw5-gpu.jl>

Run the JuliaHub notebook and answer the following questions **here**.
You do not need to submit the JuliaHub notebook, only this one.
"""

# ╔═╡ b4e13749-640f-49bf-baba-3e6bb877c2c3
md"""
!!! danger "Task 3.1"
	What speedup did you observe when running matrix multiply on the GPU compared to the CPU? For example if the CPU calculation took 1 second and the GPU computation took 0.5 seconds, you would have a 2x speedup.
"""

# ╔═╡ 3b82d62e-26ca-42a2-b8dd-2e2cf53666e6
hint(md"
Look at the median time in the output of `@benchmark`.
")

# ╔═╡ 2cbe52a4-9959-4a96-bf65-39223aacefc7
md"""
> Your answer here
"""

# ╔═╡ 24d0d3a0-41d9-46b2-addb-2ef9292fb3a5
md"""
!!! danger "Task 3.2"
	What value did you observe for the mean deviation between the matrix elements computed on the CPU vs. GPU?
"""

# ╔═╡ b4c91b27-d1a9-4a77-a47d-9ed2c477b05e
md"""
> Your answer here
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
ImageIO = "82e4d734-157c-48bb-816b-45c225c6df19"
ImageShow = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
KrylovKit = "0b1a1467-8014-51b9-945f-bf0ae24f4b77"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BenchmarkTools = "~1.3.1"
FileIO = "~1.16.0"
ImageIO = "~0.6.6"
ImageShow = "~0.3.6"
KrylovKit = "~0.5.4"
PlutoTeachingTools = "~0.2.3"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "96c27fda5b3ffbfc2845104e3f62759ddf425b2b"

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

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

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

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

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

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

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

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "b51bb8cae22c66d0f6357e3bcb6363145ef20835"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.5"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "342f789fd041a55166764c351da1710db97ce0e0"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.6"

[[deps.ImageShow]]
deps = ["Base64", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "b563cf9ae75a635592fc73d3eb78b86220e55bd8"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.6"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

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

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "a77b273f1ddec645d1b7c4fd5fb98c8f90ad10a5"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.1"

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

[[deps.KrylovKit]]
deps = ["LinearAlgebra", "Printf"]
git-tree-sha1 = "49b0c1dd5c292870577b8f58c51072bd558febb9"
uuid = "0b1a1467-8014-51b9-945f-bf0ae24f4b77"
version = "0.5.4"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

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

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

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

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "f71d8950b724e9ff6110fc948dff5a329f901d64"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.8"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "f809158b27eba0c18c269cf2a2be6ed751d3e81d"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.17"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

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

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

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

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "8fb59825be681d451c246a795117f317ecbcaa28"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.2"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

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

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "70e6d2da9210371c927176cb7a56d41ef1260db7"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.1"

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

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

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
# ╠═d4f96362-7945-4a18-99dd-52a94f6cc65b
# ╠═d5cd95f9-6728-47e2-bba4-00298c78d50c
# ╠═0d4205ec-fec1-4ef4-af48-7dae51ab31ee
# ╠═1b452080-14eb-41f7-969b-e2727af54fa3
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
# ╟─e902d91c-040b-4374-801b-a9f6e35abc4d
# ╟─ede76efa-36aa-4e4a-820c-b223276e4a91
# ╟─b4e13749-640f-49bf-baba-3e6bb877c2c3
# ╟─3b82d62e-26ca-42a2-b8dd-2e2cf53666e6
# ╠═2cbe52a4-9959-4a96-bf65-39223aacefc7
# ╟─24d0d3a0-41d9-46b2-addb-2ef9292fb3a5
# ╠═b4c91b27-d1a9-4a77-a47d-9ed2c477b05e
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
