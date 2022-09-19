### A Pluto.jl notebook ###
# v0.19.11

using Markdown
using InteractiveUtils

# ╔═╡ 5b0d8c7e-5b74-4bc5-9f3a-d84d44b68605
begin
	using AbstractTrees
	using LinearAlgebra
	using Plots
	using PlutoUI
end

# ╔═╡ 05b0eb5c-37ae-11ed-2a1e-e565ae78b5db
md"""
# Julia Basics Tutorial
This is a tutorial notebook designed for [Julia: Solving Real-World Problems with Computation, Fall 2022](https://github.com/mitmath/JuliaComputation).

This notebook is targeted at students who are already experienced with basic programming language concepts and have used one or more languages but are new to Julia. We focus on the semantics that are different from other languages and may be surprising to new Julia programmers. More advanced topics such as generic types, macros, multithreaded code, and performance analysis will be saved for later in the term.
"""

# ╔═╡ e1f9ae36-225e-42dd-8206-41c8a1a8e97c
TableOfContents()

# ╔═╡ 3ebc35e4-73be-48c1-9d3b-b99d89413810
md"""
# Pluto
"""

# ╔═╡ ec2750c6-bcd6-40bd-b09c-4055852e186b
md"""
This document you see is a notebook created with [Pluto.jl](https://github.com/fonsp/Pluto.jl).
It is a mixture of Julia code and web components, designed to make the programming experience more fun and interactive.

In this notebook, you have access to a structured equivalent of Julia's REPL (Read-Eval-Print Loop), i.e. the interactive console. Here, you can divide your code in cells to modify and run each one separately.
Press `Ctrl + Shift + ?` (or `Cmd + Shift + ?` on a Mac) to open the list of keyboard shortcuts.
"""

# ╔═╡ f0bcdf1c-f77d-4ffe-b5b7-fd7ec2bbf815
md"""
## Some quirks

The behaviors described below are specific to Pluto notebooks and do not apply to Julia as a whole:
-  To put several lines in a Pluto cell, you must wrap them in a `begin ... end` block.
- You cannot redefine a variable with the same name twice in the same notebook.
- If you want interactivity to work, avoid modifying variables in another cell that the one containing their definition.
- By default, the output of a cell is the value of its last expression, you can hide it by ending the cell with `;`.
- Usually, packages have to be installed (with `import Pkg; Pkg.add("MyPackage")`) before they can be used. However, Pluto takes care of that for us, so when you need a package, just write `using MyPackage` in a cell. This package will then be downloaded and installed in a local environment specific to the current notebook.
"""

# ╔═╡ 9c801be7-2387-4665-8421-c1eee596a592
md"""
## Help and documentation

Pluto offers you a `Live Docs` tab on the bottom right corner of the screen. If you expand it and click a function or variable, you will be able to explore the documentation associated with it. The same goes if you type `?` before a command in the REPL.

For details on Pluto itself, check out the [FAQ](https://github.com/fonsp/Pluto.jl/wiki).
"""

# ╔═╡ 1b5740a7-d0c3-487f-8a6a-8b2a9861ddc7
md"""
# Basic syntax
"""

# ╔═╡ a2998593-f16c-4dc0-abb6-0534dd3e710a
md"""
Julia has Unicode support for identifiers
"""

# ╔═╡ 08e99dfa-61c9-49b7-93db-3546a2850eef
let
	α = 3  # type \alpha <TAB>
	👽 = "abc"  # type \:alien: <TAB>
end;

# ╔═╡ 43fb2f38-3150-44e1-90fd-cdf68d4c8f89
md"""
Loops, `if/then` statements, functions and other blocks are not delimited by the indentation, but by an `end` keyword. Don't forget it!
"""

# ╔═╡ 026c9439-5ffa-459d-8353-63bffc80306f
begin
	# You can use =, in, or ∈ (\in)
	# start:step:end is the syntax for a range literal in Julia (includes both ends)
	for i = 1:3, j in 2:2:6, k ∈ 2:-1:0
		println((i, j, k))
	end
	# Notice that you can put multiple loop iterators in one line.
end

# ╔═╡ 29098bf7-6a4f-4819-8b1b-d569b7bbfbc3
md"""
Null object
"""

# ╔═╡ fb1f9e35-4538-44f9-8795-ab60805c3211
isnothing(nothing)

# ╔═╡ 8028f4e6-4e16-4004-b1cd-80793920b12c
typeof(nothing)

# ╔═╡ 0589e51d-e420-4e9a-ba6d-e08dd063fc0f
md"""
Integer types have a fixed number of bits, so they can overflow. The default `Int` type uses 64 bits, so it can express an integer in the range $[-2^{63}, 2^{63} - 1]$. If you actually need arbitrary-precision integers, you can use `BigInt`.
"""

# ╔═╡ 8ed5706e-1b2c-4c83-8c6c-7e8190d31405
typemax(Int)

# ╔═╡ 7166a14e-87bf-42ff-a88f-bde7a1d3c6ca
2^63 - 1

# ╔═╡ f55948fa-ae0e-4d5d-b9ca-347dd39ed138
typemax(Int) + 1

# ╔═╡ ceddc242-445d-4bbf-bcb5-2bf9a264ea3d
- 2^63

# ╔═╡ 7890c7b6-0d66-4b25-b30b-98542de9a32f
md"""
For more surprises, check out the [noteworthy differences from Python](https://docs.julialang.org/en/v1/manual/noteworthy-differences/#Noteworthy-differences-from-Python).
"""

# ╔═╡ e8906a7c-18e6-469c-99a8-0d21b76182e2
md"""
# Arrays
"""

# ╔═╡ cd88584f-c46b-414c-84a7-53038a6b8e38
md"""
## Terminology
In Julia, `Array` is meant in the mathematical sense (unlike in some languages where arrays only have one dimension). `Vector` and `Matrix` are also meant in the mathematical sense. So `Vector` is the special case of `Array` where there is only one dimension and `Matrix` is the special case of `Array` where there are two dimensions.
"""

# ╔═╡ 9df547e0-5c95-474f-b74a-f6dfe0e9fc39
# See in the output that `Vector` is really an alias for `Array`
Vector{Int}

# ╔═╡ 7c57e8b0-36e1-45a2-942a-6aa013af80c9
# See in the output that `Matrix` is really an alias for `Array`
Matrix{Int}

# ╔═╡ 850e864c-3a0d-42c9-afe4-4149208c18b2
md"""
## Initialization
There are many ways to initialize an array in Julia.
"""

# ╔═╡ cd0b2fdf-8a6e-4096-8161-df408f92767e
md"""
### Literals
"""

# ╔═╡ 25202060-8199-4405-915a-a01389f04545
[1, 2, 3]  # Vector literal (treated as column vector if used for linear algebra)

# ╔═╡ 5d2a5942-607a-428e-9257-3a1fe5fbc3c6
[1 2 3]  # row vector literal (1x3 Matrix)

# ╔═╡ a70d1718-f546-43e4-8553-045dcffd1ad3
[1 2
 3 4]  # Matrix literal

# ╔═╡ 736f87c1-f8db-4d16-bad6-95baaa6dd908
[1 2; 3 4]  # ; works the same way as the newline in the previous example

# ╔═╡ 0987f560-01ae-468e-ba50-3ede19bc2ed9
md"""
### Vector Comprehension
"""

# ╔═╡ 8cae53e5-e5d0-48ef-b33f-c9c78200dcbc
[x for x in 1:10 if x % 3 == 1]  # (same syntax list comprehension in Python)

# ╔═╡ 3df5875a-55e2-4a6f-bf6d-aa2192126a30
[i + j for i in 1:4, j in 1:3]  # (also works for matrices)

# ╔═╡ 459b8c60-e16d-429a-ae1d-9a99d57cf554
md"""
### Constructors
"""

# ╔═╡ 0ddcd01a-dc34-48b6-83e5-6def28fce78e
Char[]  # empty Vector that can only store Chars in the future

# ╔═╡ f3c3ad60-9c87-40e5-ba15-d9f72c3bae60
Vector{Int}(undef, 5)  # new 5 Vector of Int64s
                       # uses whatever memory is convenient for the compiler

# ╔═╡ 0e7ce1f3-510d-44ad-bd7c-a25a840eda5e
Matrix{Float64}(undef, 2, 3)  # new 2x3 Matrix of Float64s
							  # uses whatever memory is convenient for the compiler

# ╔═╡ c2dd2043-df98-45ab-a4e3-a73f31b03cbd
Array{Bool}(undef, 1, 2, 3)  # new 1x2x3 Array of Bools
							 # uses whatever memory is convenient for the compiler

# ╔═╡ bd5060ec-758f-418a-98a5-f57f424d64d5
md"""
### `zeros` and `fill`
"""

# ╔═╡ 9b17807e-a18f-4735-bdae-0924d28fd5ee
zeros(Complex, 4)  # 4 Vector of zeros of type Complex

# ╔═╡ 8c25ac44-6a59-4442-be4c-3ed8effdb20d
zeros(3, 2)  # defaults to Float64 if a type isn't specified

# ╔═╡ 1b1d8481-0eff-446d-b932-8bd52817cbfc
fill(5, 4, 2)  # 4x2 Matrix of the value 5

# ╔═╡ 59cd4167-d100-4dfc-ac7c-02e1887af0c8
let
	# beware of filling with mutable values!
	x = fill([1,2,3], 3)  # this just creates one vector that is aliased
	x[1][2] = 10
	x
end

# ╔═╡ 6d4e8e1f-9fa3-440d-bf83-c8b3e07fc71d
md"""
### The `rand` function
"""

# ╔═╡ 8842dd3f-9b7f-4916-aaf7-067a4be8bb0c
rand(UInt8)  # single random number of type UInt8

# ╔═╡ 96e678e9-ff11-4cec-a115-15d4a334b7fe
rand(3)  # random 3-vector of Float64

# ╔═╡ c45ba9aa-13ab-4d03-a345-955659c6ff41
rand(Int16, 2, 3, 4)  # random 2x3x4 Array of Int16

# ╔═╡ 7f303cbc-22e4-4b4f-be9c-2585f50dd166
let
	x = [:🐱, :🐶, :🐟, :🐹]
	rand(x)  # random selection from the collection x
end

# ╔═╡ 1a3ef85c-116a-4a74-9c96-28e88829fb7d
md"""
## Basic Array Functions
"""

# ╔═╡ 7ca9e326-064f-4f2e-9eb3-746e347fc693
length([1 2; 3 4])

# ╔═╡ 185c0731-3c06-4640-b19c-cdb1b3e0f3a5
size([1 2; 3 4])

# ╔═╡ 060f65c7-40ac-4ad5-8a86-21d1931b7a2a
vec([1 2; 3 4])

# ╔═╡ 03f4a36c-669e-47e8-96f1-b58b1df8afb0
reshape([1, 2, 3, 4], 2, 2)

# ╔═╡ f0351fc7-d3ce-4036-9be6-14e0458418c6
reshape(1:12, 2, 3, 2)

# ╔═╡ 5947547b-96f7-4e3e-bf61-87aea647eab0
vcat([1, 2, 3], [4, 5, 6])

# ╔═╡ 383d0c2c-42f0-484d-8292-b6f6abae50cf
[[1, 2, 3]; [4, 5, 6]]  # [a ; b] is the same as vcat(a, b)

# ╔═╡ 632f9251-f2a8-4549-b0e0-bd965a0c513b
vcat([1 2
      3 4],
     [5 6
	  7 8])

# ╔═╡ 48c2ddcf-5d02-499d-ba69-e1cc38391443
hcat([1, 2, 3], [4, 5, 6])

# ╔═╡ c3b13f6e-c245-49e6-b892-bc1b446d7a52
[[1, 2, 3] [4, 5, 6]]  # [a b] is the same as hcat(a, b)

# ╔═╡ 5c8effcd-a6fe-4ed7-b06a-68494f378136
hcat([1 2
      3 4],
     [5 6
	  7 8])

# ╔═╡ 3d054687-0739-4c73-b578-4b7baa8ba8c7
# enumerate gives us index-value tuples which can be useful when iterating
# collect converts a generator into an Array
collect(enumerate(['a', 'b', 'c']))

# ╔═╡ d70faeb4-e75d-4598-b1fd-986dacadf190
let
	v = Int[]
	push!(v, 1)  # the ! is a Julia convention to indicate
	             # that the function mutates its arguments
	append!(v, [2.0, false, 'a'])  # notice how all the types are converted
	                               # to match the type of the Vector
end

# ╔═╡ 42e14b85-28cc-429e-8267-25107cca6101
md"""
## Other Data Structures
Dictionaries, Sets, and other common data structures exist in Julia just like other programming languages. See the docs for more: [https://docs.julialang.org/en/v1/base/collections/](https://docs.julialang.org/en/v1/base/collections/)
"""

# ╔═╡ 41ab85eb-67c2-440c-8f1a-8e365981418f
md"""
# Operators
"""

# ╔═╡ 3cd02837-36d6-496d-a08a-e83c65135530
md"""
For the most part, the characters used for operators in Julia are what you would expect from math.
"""

# ╔═╡ 9d3f74e2-18f2-4c86-bd48-12ca01972539
md"""
## Basic Operators
"""

# ╔═╡ 87d9312a-5ece-4ea4-8d98-bac120273155
3 ^ 2  # exponentiation

# ╔═╡ 3ac2a971-7029-4de1-955e-16bb0dd9a9aa
8 / 3  # true division

# ╔═╡ 406dd220-54a6-4aa2-95ec-a7d533252a5a
8 ÷ 3  # floor division (\div <TAB>)

# ╔═╡ 966ebaa7-da63-41f9-bfde-951dd6ab9c8c
8 // 3  # Rational literal

# ╔═╡ 830f0714-171e-4115-9f83-953560cf9a2e
begin
	3 >= 2
	3 ≥ 2  # \geq <TAB>
end

# ╔═╡ deee9c05-2e58-4a94-bbe5-3244c272dfaa
begin
	3 <= 2
	3 ≤ 2  # \leq <TAB>
end

# ╔═╡ b3bf3e26-f80f-482d-b93f-b37f61a63cb3
begin
	3 != 2
	3 ≠ 2  # \ne <TAB>
end

# ╔═╡ cdfef9ad-ef97-4130-8ba0-bae7d76127bf
5 < 7 ? "yes" : "no"  # ternary operator

# ╔═╡ 8dc47309-5355-41bc-aa9f-b92af247a4ed
md"""
## Linear Algebra Operators
"""

# ╔═╡ 7ead5eb1-391a-4422-b75a-3908e1c30321
[1 2
 3 4]'  # transpose

# ╔═╡ 64d33d2e-8079-458f-926a-d9db16ae72c4
let
	A = [1 2; 3 4]
	b = [1, 1]
	x = A \ b  # linear solve (solution to Ax = b)
end

# ╔═╡ 4257aac6-ba4a-4df7-9a93-1c091ab55b70
[1, 2, 3] ⋅ [1, 4, 9]  # dot product (\cdot <TAB>)

# ╔═╡ 897bfd00-bc16-4c6f-8d10-eaa17a74e9fc
md"""
## Set Theory Operators
"""

# ╔═╡ c8a252b5-c7a0-4403-9636-e8459c1251be
4 in 1:2:7

# ╔═╡ 76ea45e0-f8ca-495f-bdbb-8ace33a76cbf
4 ∈ 1:2:7  # \in <TAB>

# ╔═╡ b137aa6f-a683-4d73-8c56-2f052e7cc534
4 ∉ 1:2:7  # \notin <TAB>

# ╔═╡ e3368777-ecca-4273-9501-836789ccdb3f
(1, 3, 4) ⊆ (3, 4, 5)  # \subseteq <TAB>

# ╔═╡ 33756b2a-24f7-49cb-8616-c2fa6c716f52
(1, 3, 4) ⊊ (3, 4, 5)  # \subsetneq <TAB>

# ╔═╡ 111e1e15-c462-4c33-89b6-3d55597ee092
(1, 3, 4) ⊈ (3, 4, 5)  # \nsubseteq <TAB>

# ╔═╡ 9a0971e9-3625-4a87-b5cb-23ebfaafb042
(1, 3, 4) ∩ (3, 4, 5)  # \cap <TAB>

# ╔═╡ 88e9f3b1-adda-4a0f-bc16-4d144bbd28c3
(1, 3, 4) ∪ (3, 4, 5)  # \cup <TAB>

# ╔═╡ 19672d03-80ff-4997-8f08-b0dc8405cf24
md"""
# Functions
"""

# ╔═╡ 4f66a82d-b9bd-469f-b327-56c40c8baa17
md"""
## Function Definitions
There are a few different ways to define a function in Julia.
"""

# ╔═╡ bf6fba34-2a52-47e1-820a-d17339f17379
let
	function f(a::Int)
		return a + 1
	end
	f(10)
end

# ╔═╡ e0146124-eac2-45c6-99e8-90f6cf82e294
let
	function f(a)  # by excluding the type we are able to use generic programming
		a + 1  # the evaluation of the last line is implicitly returned,
		       # so the return keyword is optional in this case
	end
	(f(10), f(1 + 3im), f(3.7))
end

# ╔═╡ e8d60909-6dd6-4841-b4c3-9dfa5c18f41e
let
	f(a) = a + 1  # This is a short-hand syntax that looks more like math
	(f(10), f(1 + 3im), f(3.7))
end

# ╔═╡ b8827029-2561-4883-ae95-05ea9f3d2b1b
let
	f = a -> a + 1  # and this is a lambda function
	(f(10), f(1 + 3im), f(3.7))
end

# ╔═╡ ee85e0bf-f985-41b0-be55-92d6faa4eede
md"""
## Function Arguments
"""

# ╔═╡ b8c22481-c851-4abb-986b-6766d7e71b88
let
	# arguments before the ; are positional, after are keyword
	# there can be defaults in both categories
	# anything without a default must be assigned when the function is called
	# ... before the ; accepts any number of positional arguments
	# ... after the ; accepts any keyword arguments
	# the names args and kwargs are conventional for these extra arguments
	function f(a, b=0, args...; c, d=1, kwargs...)
		println(a)
		println(b)
		println(args)
		println(c)
		println(d)
		println(kwargs)
	end
	f('a', 2, 3, 4; c=3, e=7)
	println()
	f(1; c=7)
	# f(0)  # this would be an error because c is not assigned
end

# ╔═╡ c1c8dd57-0b8e-4d76-ae1e-f7f93452aeb0
let
	f(a, b, c) = a + b + c
	x = (1, 2, 3)
	f(x...)  # this is the splat operator
end

# ╔═╡ 3a0151a0-c837-44ea-8d2a-529756550989
let
	f(; a, b, c) = a + b + c
	x = (; a=1, b=2, c=3)
	f(; x...)  # works for kwargs too
end

# ╔═╡ f4244d75-9d09-4a38-aa97-53062b0fe388
md"""
## Mutating functions
"""

# ╔═╡ 83070622-c71b-4757-8349-e7364ec5cb55
md"""
You will often come across functions with a `!` at the end of their name.
This is a style convention which indicates that at least one of the function's arguments is modified in-place.
"""

# ╔═╡ 33d8d8d2-4343-4ae2-8174-ac245a5d3de9
let
	a = [3, 2, 1]
	b = sort(a)
	a, b
end

# ╔═╡ 27049ede-8943-4e3c-9538-c9b67dd3da05
let
	a = [3, 2, 1]
	sort!(a)
	a
end

# ╔═╡ 171d4a16-ea05-42ff-ba10-081500ef4b2f
md"""
## Higher-Order Functions
"""

# ╔═╡ 67ef0b42-e3fd-4777-a49e-090a6a874ffe
let
	function f(a)  # f is called a higher-order function because it returns a function
		g(b) = a + b
	end
	f(3)(4)
end

# ╔═╡ fea409ec-e042-4723-8cd5-48cc6ac94a1b
let
	f(a) = b -> a + b  # more concise syntax for the same thing as above
	f(3)(4)
end

# ╔═╡ 9a835c95-685e-4155-836c-d4c1273a06c3
# filter is a higher-order function because it takes a function as a parameter
filter(x -> x % 3 == 1, [1, 5, 43, 2, 51, 2, 19])

# ╔═╡ b031b745-aabc-46e7-a15f-bb50a5977779
map(sqrt, [1, 16, 4, 25])

# ╔═╡ 075c5a43-0af8-441b-b831-7faba2f48f0c
# you can also use do ... end syntax to define the first argument to the function
map(1:10, 11:20) do x, y
	x + y
end

# ╔═╡ 1ac98406-dc58-4594-a462-93525a6cf2d0
reduce(*, [3, 4, 5, 6])
# see maximum, minimum, sum, prod, any, all

# ╔═╡ 56c58e54-2276-44fc-89b0-5f86e1c4fd15
mapreduce(abs2, +, [1, 2, 3])

# ╔═╡ a2643fe2-b2cb-41ef-8557-d2a901239708
let
	f(x) = x * x
	g(x) = x + 2
	h = f ∘ g  # function composition: h(x) = f(g(x)) (\circ <TAB>)
	h(3)
end

# ╔═╡ 69ac8b2f-7c43-4f33-9b32-6033457467df
(sqrt ∘ +)(9, 16)

# ╔═╡ 897679bf-ef08-4c7d-8078-2de9adfedcf9
# |> is the pipe operator which is used for function chaining
"PooRly formattED TEXT  " |> strip |> lowercase

# ╔═╡ f0a08ec8-3c3a-4fc2-9efe-6eb5c55b96e8
md"""
## Broadcasting
"""

# ╔═╡ 61e4b1a1-2d2a-42fb-91cd-c245d6c54399
# f.(collection) means apply f to each element of collection
sqrt.(1:9)

# ╔═╡ bf292bf8-5a3e-4913-a1b2-dfe55f46e438
[1, 2, 3] .* [3, 2, 1]  # works for functions of multiple variables as well
						# in this case multiplication

# ╔═╡ fadb3713-3ab3-44d7-a8e6-e0b146a86c75
[1, 2, 3] .+ zeros(Int, 3, 2, 2)  # for arrays of different sizes,
                                  # the leading dimensions must match

# ╔═╡ c1072ede-5c7a-4c1f-82f6-ac81fcf037d3
let
	# Broadcasting can also be used for assignment
	A = collect(1:10)
	A[3:5] .= 100
	A
end

# ╔═╡ e21a076f-3dcd-466e-be82-d00646f2457f
md"""
# Structs and types
"""

# ╔═╡ 98a825e8-b0a6-483f-b980-1b9600a42c9a
md"""
## Types
"""

# ╔═╡ 0202b549-7960-4e4d-b76a-71b3b4256473
md"""
Julia's type system does not have classes and inheritance like in Python or Java.
Instead, it is built as hierarchy of abstract types, which can be thought of as interfaces, and concrete types (or structs), which actually store data.
"""

# ╔═╡ 669a2b4f-0faa-4c67-8def-ee762b521eb3
AbstractTrees.children(x::Type) = subtypes(x)

# ╔═╡ 025a2137-8fee-435b-a295-853ce8b29b77
print_tree(Number)

# ╔═╡ d7a5d1b5-e67f-4b4b-b299-987a031fd9a4
md"""
In the cell above, only the rightmost types (at the bottom of the hierarchy) are concrete, which means you can instantiate them.
The other levels are mainly used for dispatch purposes.
More on this in HW1.
"""

# ╔═╡ 26c08688-8966-42d6-84b9-a96d17e9f41b
isconcretetype(Number)

# ╔═╡ 1582f8d6-95e7-4b07-a7a5-927dda90ee43
isconcretetype(Float64)

# ╔═╡ ba8e4203-f889-4036-b042-35c4c160f75a
md"""
## Structs
"""

# ╔═╡ e3d1b330-b678-45e9-b0c4-ab1d2bd842e6
md"""
We now show how to define a concrete type.
"""

# ╔═╡ 370d3ce1-467b-4caa-a10b-d13218dfb1fe
# basic struct definition
struct Point1
	x
	y
end

# ╔═╡ 60ced228-90d5-460c-95c0-8ddea2e9e9fc
# this is how we create an instance
p1 = Point1(0, 5)

# ╔═╡ 6c80fe2d-c465-45aa-b3fe-94fe904b0903
# access fields with the . syntax
p1.x

# ╔═╡ df9f3334-2227-47e6-a7cb-fdc1b9a5ce21
# we can restrict the types of fields like this
struct Point2
	x::Float64
	y::Number
end

# ╔═╡ 457b7225-c4ad-4d76-92a1-ff2b0b2ea372
# by default, fields are immutable (which can make our code faster!)
p1.x = 2

# ╔═╡ e5804ae5-cf1f-47b3-9fe2-532fb0f9665a
# if you want your entire struct to be mutable use the mutable keyword
begin
	mutable struct Point3
		x
		y
	end
	p3 = Point3(7, 3)
	p3.x = 2
	p3
end

# ╔═╡ fdcec36b-4cdc-4994-8703-00ff708f6070
# new in 1.8: we can now mark individual fields as constant
# this is good for readability, encapsulation, and compiler optimizations
mutable struct Record1
	const id::Int
	name::String
end

# ╔═╡ 645eed27-1cb8-4b7f-8590-539f543e63a1
md"""
## Constructors
There are two types of Constructors in Julia: inner constructors and outer constructors.
"""

# ╔═╡ b55497bd-bd4e-4d31-b4f6-8c2832aeb35e
# Inner Constructors are special methods that restrict the ways that a struct can be created
# these are especially useful if you want to enforce some sort of invariant
begin
	struct Point4
		x
		y
		d
		Point4(x,y) = new(x, y, sqrt(x*x + y*y))
	end
	
	mutable struct Record2
		const id::UInt64
		name::String
		function Record2(name::String)
			name == "" ? error("empty name is not allowed") : new(rand(UInt64), name)
		end
	end
end

# ╔═╡ d2032057-1269-4b32-b489-8c90608e8dd5
Point4(3, 4)

# ╔═╡ f861c4fa-5453-44d2-af30-b9376a95cf2b
Point4(3, 4, 5)

# ╔═╡ c04c353d-8db8-4e1d-a409-df10e46a5c21
Record2("Hello World")

# ╔═╡ e83e153f-8269-4020-a8b4-afc4c5cd6828
Record2("")

# ╔═╡ edf980c3-a838-4c3f-9321-2c5142bce2e2
# Outer Constructors are just the same as any other method
# they are basically used as a convenient way to initialize a struct
begin
	struct Point5
		x
		y
	end
	Point5(pair::Tuple) = Point5(pair...)
	coordinates = (10, 100)
	Point5(coordinates)
end

# ╔═╡ 501d14cd-3747-4997-99cb-6bbca56b31b5
md"""
# Miscellaneous
"""

# ╔═╡ a9244d09-d458-44c9-9c9f-a271e7951b35
md"""
## Macros
"""

# ╔═╡ fd8a9c43-9ab5-4b80-931c-9b772656c186
md"""
In Julia, macros are special language constructs that transform the source code itself.
You don't need to understand them, just learn to recognize them: they always begin with a `@` character.
Here are some useful examples:
"""

# ╔═╡ b5c66512-6b86-4342-9816-05ff6bc649e8
begin
	@info "Hello"
	@warn "Goodbye"
end

# ╔═╡ 4b17015d-d56b-43d9-a86a-82c25a7bb4f5
let
	x = 1
	y = 2
	@error "Noooooo" x y
end

# ╔═╡ ec7bec64-3d25-421f-878e-60b381bdaee0
md"""
## Plots
"""

# ╔═╡ 351813ef-6075-4d38-be38-e53a5651209f
md"""
The standard plotting library in Julia is called Plots.jl, and its syntax is quite similar to Python's Matplotlib.
"""

# ╔═╡ 4a96d787-de19-4beb-aeb5-ba92bc54502f
plot(1:10, exp.(1:10), xlabel="x", ylabel="exp(x)", title="this grows fast", label=nothing)

# ╔═╡ c6ef3656-e026-42ed-82e0-a85499bdfe02
md"""
It is very easy to build plots incrementally by using the in-place syntax, which implicitly modify the current plot.
"""

# ╔═╡ d062c5e3-7261-4ff4-b16d-764744be9924
begin
	plot(1:10, rand(10), color="blue", label="line1")
	plot!(1:10, rand(10), color="green", label="line2")
	scatter!(1:10, rand(10), color="red", label="dots")
end

# ╔═╡ 850492bd-baf6-49db-aae4-23bfdb544528
md"""
There are a lot of different options available to get your plot looking just how you want it. Here is some documentation that you can check out for more:
- [https://docs.juliaplots.org/stable/](https://docs.juliaplots.org/stable/)
- [https://github.com/sswatson/cheatsheets/blob/master/plotsjl-cheatsheet.pdf](https://github.com/sswatson/cheatsheets/blob/master/plotsjl-cheatsheet.pdf)
"""

# ╔═╡ abbf92ab-6261-4cbf-bbfd-8d5257b2b268
md"""
# More Resources

**Cheatsheets**
- [https://juliadocs.github.io/Julia-Cheat-Sheet](https://juliadocs.github.io/Julia-Cheat-Sheet)
- [https://cheatsheets.quantecon.org](https://cheatsheets.quantecon.org)

**Documentation**
- [Julia Documentation](https://docs.julialang.org/en/v1/)
- in the REPL, press `?` to enter help mode then type any symbol to see documentation
- in Pluto, put your cursor on a symbol and open the 'live docs' menu in the bottom right to see documentation
- in VSCode hover your mouse over a symbol to see documentation

**Forums**
- [Julia Discourse](https://discourse.julialang.org)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractTrees = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
AbstractTrees = "~0.4.2"
Plots = "~1.33.0"
PlutoUI = "~0.7.40"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.1"
manifest_format = "2.0"
project_hash = "0965981cedbde2a482a8025d1912fff804545dff"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "5c0b629df8a5566a06f5fef5100b53ea56e465a0"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

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
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

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
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "ccd479984c7838684b3ac204b716c89955c76623"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

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

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "cf0a9940f250dc3cb6cc6c6821b4bf8a4286cf9c"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.66.2"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "3697c23d09d5ec6f2088faa68f0d926b6889b5be"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.67.0+0"

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
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "59ba44e0aa49b87a8c7a8920ec76f8afe87ed502"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.3.3"

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

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

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
# ╟─05b0eb5c-37ae-11ed-2a1e-e565ae78b5db
# ╠═5b0d8c7e-5b74-4bc5-9f3a-d84d44b68605
# ╠═e1f9ae36-225e-42dd-8206-41c8a1a8e97c
# ╟─3ebc35e4-73be-48c1-9d3b-b99d89413810
# ╟─ec2750c6-bcd6-40bd-b09c-4055852e186b
# ╟─f0bcdf1c-f77d-4ffe-b5b7-fd7ec2bbf815
# ╟─9c801be7-2387-4665-8421-c1eee596a592
# ╟─1b5740a7-d0c3-487f-8a6a-8b2a9861ddc7
# ╟─a2998593-f16c-4dc0-abb6-0534dd3e710a
# ╠═08e99dfa-61c9-49b7-93db-3546a2850eef
# ╟─43fb2f38-3150-44e1-90fd-cdf68d4c8f89
# ╠═026c9439-5ffa-459d-8353-63bffc80306f
# ╟─29098bf7-6a4f-4819-8b1b-d569b7bbfbc3
# ╠═fb1f9e35-4538-44f9-8795-ab60805c3211
# ╠═8028f4e6-4e16-4004-b1cd-80793920b12c
# ╟─0589e51d-e420-4e9a-ba6d-e08dd063fc0f
# ╠═8ed5706e-1b2c-4c83-8c6c-7e8190d31405
# ╠═7166a14e-87bf-42ff-a88f-bde7a1d3c6ca
# ╠═f55948fa-ae0e-4d5d-b9ca-347dd39ed138
# ╠═ceddc242-445d-4bbf-bcb5-2bf9a264ea3d
# ╟─7890c7b6-0d66-4b25-b30b-98542de9a32f
# ╟─e8906a7c-18e6-469c-99a8-0d21b76182e2
# ╟─cd88584f-c46b-414c-84a7-53038a6b8e38
# ╠═9df547e0-5c95-474f-b74a-f6dfe0e9fc39
# ╠═7c57e8b0-36e1-45a2-942a-6aa013af80c9
# ╟─850e864c-3a0d-42c9-afe4-4149208c18b2
# ╟─cd0b2fdf-8a6e-4096-8161-df408f92767e
# ╠═25202060-8199-4405-915a-a01389f04545
# ╠═5d2a5942-607a-428e-9257-3a1fe5fbc3c6
# ╠═a70d1718-f546-43e4-8553-045dcffd1ad3
# ╠═736f87c1-f8db-4d16-bad6-95baaa6dd908
# ╟─0987f560-01ae-468e-ba50-3ede19bc2ed9
# ╠═8cae53e5-e5d0-48ef-b33f-c9c78200dcbc
# ╠═3df5875a-55e2-4a6f-bf6d-aa2192126a30
# ╟─459b8c60-e16d-429a-ae1d-9a99d57cf554
# ╠═0ddcd01a-dc34-48b6-83e5-6def28fce78e
# ╠═f3c3ad60-9c87-40e5-ba15-d9f72c3bae60
# ╠═0e7ce1f3-510d-44ad-bd7c-a25a840eda5e
# ╠═c2dd2043-df98-45ab-a4e3-a73f31b03cbd
# ╟─bd5060ec-758f-418a-98a5-f57f424d64d5
# ╠═9b17807e-a18f-4735-bdae-0924d28fd5ee
# ╠═8c25ac44-6a59-4442-be4c-3ed8effdb20d
# ╠═1b1d8481-0eff-446d-b932-8bd52817cbfc
# ╠═59cd4167-d100-4dfc-ac7c-02e1887af0c8
# ╟─6d4e8e1f-9fa3-440d-bf83-c8b3e07fc71d
# ╠═8842dd3f-9b7f-4916-aaf7-067a4be8bb0c
# ╠═96e678e9-ff11-4cec-a115-15d4a334b7fe
# ╠═c45ba9aa-13ab-4d03-a345-955659c6ff41
# ╠═7f303cbc-22e4-4b4f-be9c-2585f50dd166
# ╟─1a3ef85c-116a-4a74-9c96-28e88829fb7d
# ╠═7ca9e326-064f-4f2e-9eb3-746e347fc693
# ╠═185c0731-3c06-4640-b19c-cdb1b3e0f3a5
# ╠═060f65c7-40ac-4ad5-8a86-21d1931b7a2a
# ╠═03f4a36c-669e-47e8-96f1-b58b1df8afb0
# ╠═f0351fc7-d3ce-4036-9be6-14e0458418c6
# ╠═5947547b-96f7-4e3e-bf61-87aea647eab0
# ╠═383d0c2c-42f0-484d-8292-b6f6abae50cf
# ╠═632f9251-f2a8-4549-b0e0-bd965a0c513b
# ╠═48c2ddcf-5d02-499d-ba69-e1cc38391443
# ╠═c3b13f6e-c245-49e6-b892-bc1b446d7a52
# ╠═5c8effcd-a6fe-4ed7-b06a-68494f378136
# ╠═3d054687-0739-4c73-b578-4b7baa8ba8c7
# ╠═d70faeb4-e75d-4598-b1fd-986dacadf190
# ╟─42e14b85-28cc-429e-8267-25107cca6101
# ╟─41ab85eb-67c2-440c-8f1a-8e365981418f
# ╟─3cd02837-36d6-496d-a08a-e83c65135530
# ╟─9d3f74e2-18f2-4c86-bd48-12ca01972539
# ╠═87d9312a-5ece-4ea4-8d98-bac120273155
# ╠═3ac2a971-7029-4de1-955e-16bb0dd9a9aa
# ╠═406dd220-54a6-4aa2-95ec-a7d533252a5a
# ╠═966ebaa7-da63-41f9-bfde-951dd6ab9c8c
# ╠═830f0714-171e-4115-9f83-953560cf9a2e
# ╠═deee9c05-2e58-4a94-bbe5-3244c272dfaa
# ╠═b3bf3e26-f80f-482d-b93f-b37f61a63cb3
# ╠═cdfef9ad-ef97-4130-8ba0-bae7d76127bf
# ╟─8dc47309-5355-41bc-aa9f-b92af247a4ed
# ╠═7ead5eb1-391a-4422-b75a-3908e1c30321
# ╠═64d33d2e-8079-458f-926a-d9db16ae72c4
# ╠═4257aac6-ba4a-4df7-9a93-1c091ab55b70
# ╟─897bfd00-bc16-4c6f-8d10-eaa17a74e9fc
# ╠═c8a252b5-c7a0-4403-9636-e8459c1251be
# ╠═76ea45e0-f8ca-495f-bdbb-8ace33a76cbf
# ╠═b137aa6f-a683-4d73-8c56-2f052e7cc534
# ╠═e3368777-ecca-4273-9501-836789ccdb3f
# ╠═33756b2a-24f7-49cb-8616-c2fa6c716f52
# ╠═111e1e15-c462-4c33-89b6-3d55597ee092
# ╠═9a0971e9-3625-4a87-b5cb-23ebfaafb042
# ╠═88e9f3b1-adda-4a0f-bc16-4d144bbd28c3
# ╟─19672d03-80ff-4997-8f08-b0dc8405cf24
# ╟─4f66a82d-b9bd-469f-b327-56c40c8baa17
# ╠═bf6fba34-2a52-47e1-820a-d17339f17379
# ╠═e0146124-eac2-45c6-99e8-90f6cf82e294
# ╠═e8d60909-6dd6-4841-b4c3-9dfa5c18f41e
# ╠═b8827029-2561-4883-ae95-05ea9f3d2b1b
# ╟─ee85e0bf-f985-41b0-be55-92d6faa4eede
# ╠═b8c22481-c851-4abb-986b-6766d7e71b88
# ╠═c1c8dd57-0b8e-4d76-ae1e-f7f93452aeb0
# ╠═3a0151a0-c837-44ea-8d2a-529756550989
# ╟─f4244d75-9d09-4a38-aa97-53062b0fe388
# ╟─83070622-c71b-4757-8349-e7364ec5cb55
# ╠═33d8d8d2-4343-4ae2-8174-ac245a5d3de9
# ╠═27049ede-8943-4e3c-9538-c9b67dd3da05
# ╟─171d4a16-ea05-42ff-ba10-081500ef4b2f
# ╠═67ef0b42-e3fd-4777-a49e-090a6a874ffe
# ╠═fea409ec-e042-4723-8cd5-48cc6ac94a1b
# ╠═9a835c95-685e-4155-836c-d4c1273a06c3
# ╠═b031b745-aabc-46e7-a15f-bb50a5977779
# ╠═075c5a43-0af8-441b-b831-7faba2f48f0c
# ╠═1ac98406-dc58-4594-a462-93525a6cf2d0
# ╠═56c58e54-2276-44fc-89b0-5f86e1c4fd15
# ╠═a2643fe2-b2cb-41ef-8557-d2a901239708
# ╠═69ac8b2f-7c43-4f33-9b32-6033457467df
# ╠═897679bf-ef08-4c7d-8078-2de9adfedcf9
# ╟─f0a08ec8-3c3a-4fc2-9efe-6eb5c55b96e8
# ╠═61e4b1a1-2d2a-42fb-91cd-c245d6c54399
# ╠═bf292bf8-5a3e-4913-a1b2-dfe55f46e438
# ╠═fadb3713-3ab3-44d7-a8e6-e0b146a86c75
# ╠═c1072ede-5c7a-4c1f-82f6-ac81fcf037d3
# ╟─e21a076f-3dcd-466e-be82-d00646f2457f
# ╟─98a825e8-b0a6-483f-b980-1b9600a42c9a
# ╟─0202b549-7960-4e4d-b76a-71b3b4256473
# ╠═669a2b4f-0faa-4c67-8def-ee762b521eb3
# ╠═025a2137-8fee-435b-a295-853ce8b29b77
# ╟─d7a5d1b5-e67f-4b4b-b299-987a031fd9a4
# ╠═26c08688-8966-42d6-84b9-a96d17e9f41b
# ╠═1582f8d6-95e7-4b07-a7a5-927dda90ee43
# ╟─ba8e4203-f889-4036-b042-35c4c160f75a
# ╟─e3d1b330-b678-45e9-b0c4-ab1d2bd842e6
# ╠═370d3ce1-467b-4caa-a10b-d13218dfb1fe
# ╠═60ced228-90d5-460c-95c0-8ddea2e9e9fc
# ╠═6c80fe2d-c465-45aa-b3fe-94fe904b0903
# ╠═df9f3334-2227-47e6-a7cb-fdc1b9a5ce21
# ╠═457b7225-c4ad-4d76-92a1-ff2b0b2ea372
# ╠═e5804ae5-cf1f-47b3-9fe2-532fb0f9665a
# ╠═fdcec36b-4cdc-4994-8703-00ff708f6070
# ╟─645eed27-1cb8-4b7f-8590-539f543e63a1
# ╠═b55497bd-bd4e-4d31-b4f6-8c2832aeb35e
# ╠═d2032057-1269-4b32-b489-8c90608e8dd5
# ╠═f861c4fa-5453-44d2-af30-b9376a95cf2b
# ╠═c04c353d-8db8-4e1d-a409-df10e46a5c21
# ╠═e83e153f-8269-4020-a8b4-afc4c5cd6828
# ╠═edf980c3-a838-4c3f-9321-2c5142bce2e2
# ╟─501d14cd-3747-4997-99cb-6bbca56b31b5
# ╟─a9244d09-d458-44c9-9c9f-a271e7951b35
# ╟─fd8a9c43-9ab5-4b80-931c-9b772656c186
# ╠═b5c66512-6b86-4342-9816-05ff6bc649e8
# ╠═4b17015d-d56b-43d9-a86a-82c25a7bb4f5
# ╟─ec7bec64-3d25-421f-878e-60b381bdaee0
# ╟─351813ef-6075-4d38-be38-e53a5651209f
# ╠═4a96d787-de19-4beb-aeb5-ba92bc54502f
# ╟─c6ef3656-e026-42ed-82e0-a85499bdfe02
# ╠═d062c5e3-7261-4ff4-b16d-764744be9924
# ╟─850492bd-baf6-49db-aae4-23bfdb544528
# ╟─abbf92ab-6261-4cbf-bbfd-8d5257b2b268
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
