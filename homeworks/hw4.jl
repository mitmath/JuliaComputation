### A Pluto.jl notebook ###
# v0.19.13

#> [frontmatter]
#> title = "HW4 - Callable structs & ODEs"
#> date = "2022-10-15"

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

# ╔═╡ b3b707d2-4a5b-11ed-1266-97264478041b
begin
	using AbstractTrees
	using BenchmarkTools
	using CSV
	using DataFrames
	using Dates
	using DifferentialEquations
	using ForwardDiff
	using Interpolations
	using Plots
	using PlutoTeachingTools
	using PlutoUI
end

# ╔═╡ c6bd612e-21c4-4e2d-91ac-42fe4f611364
md"""
Homework 4 of the MIT Course [_Julia: solving real-world problems with computation_](https://github.com/mitmath/JuliaComputation)

Release date: Saturday, Oct 15, 2022 (version 1)

**Due date: Saturday, Oct 22, 2022 at 11:59pm EST**

Submission by: Jazzy Doe (jazz@mit.edu)
"""

# ╔═╡ 98f2eed8-89ad-4b5c-9fbd-790e8c322940
student = (name = "Jazzy Doe", kerberos_id = "jazz")

# ╔═╡ 3b74812e-b8d0-482e-bedf-f49c54a1b92f
md"""
The following cell can take some time to run, so don't freak out and grab a cup of tea.
"""

# ╔═╡ c41ae1ce-2e04-4936-98f0-48c95468743a
PlutoUI.TableOfContents()

# ╔═╡ 866fddf0-7894-4688-9e58-34442fa96b23
md"""
# HW4: Callable structs and climate modeling
"""

# ╔═╡ 6f764336-6459-4df6-ae4c-839aa8dccac8
md"""
Section 3 of this homework lets you implement differential equations that are used to predict climate change.
For such temporal evolution problems, we often face a dilemma: the numerical solution we obtain is sampled at discrete instants, and yet it corresponds to a continuous function of time.

Section 2 shows you how to turn one representation into the other, by exploiting a very elegant feature of Julia: callable structs.

Section 1 uses callable structs as an excuse to teach you more about types in general, and to give you some important performance tricks.
"""

# ╔═╡ 8d740a6f-f809-4171-b4fd-615cd0faaa99
md"""
# 1. More on types & performance
"""

# ╔═╡ 401d487a-b297-41fd-9719-2b76cc9d1385
md"""
Consider this section as a warm up with lots of useful Julia-related tips.
It does not have a direct connection to climate modeling, but at the end, you will be able to write your first neural network from scratch and apply automatic differentiation on it.
How about that!
"""

# ╔═╡ fd240f6c-fee4-4300-89ae-6372e671da43
md"""
## 1.0 Abstract and concrete types
"""

# ╔═╡ 949c2c07-8ee0-4294-8839-7353d4db213b
md"""
Remember from HW1 that Julia has a type hierarchy with two ingredients: abstract types and concrete types.
Concrete types (like `Float64` or `Int`) are the ones that you can actually instantiate, while abstract types (like `Real` or `Number`) serve to define generic methods for several concrete types at once.
"""

# ╔═╡ 41141c4e-c331-41a6-8165-3547da5e8d07
md"""
Why does the difference matter?
Because with a concrete type, the memory layout of the object is well specified.
If the compiler knows it will work on `Float64` numbers, it can generate very efficient code that is taylored to this representation.
But if the compiler only knows it will work on `Real` numbers, then it must generate a very clunky code that works for all possible subtypes of real numbers: integers, rationals, floating point, etc.
"""

# ╔═╡ 90c072fe-8013-48f8-9a7e-4c81e2708fe3
md"""
It is very simple to check whether you are dealing with an abstract or concrete type.
"""

# ╔═╡ 7cb286ce-da0c-4058-90ee-144f85b68315
isconcretetype(Float64), isconcretetype(Real)

# ╔═╡ 4c6877be-4fcd-4e15-b1f5-4569209a3f39
md"""
Since multiple subtyping / inheritance does not exist in Julia, the type hierarchy can be represented as a tree, with `Any` (the most generic type) as its root.
Abstract types correspond to internal nodes of the tree, while concrete types are the leaves (they have no children).
"""

# ╔═╡ 8a04b937-c501-428c-9a08-f9b59c2066e2
AbstractTrees.children(x::Type) = subtypes(x)

# ╔═╡ d8b330af-1991-4fb9-a8db-e833c326d173
print_tree(Real)

# ╔═╡ 04ef7d70-a4a9-4d9f-add0-7b22aeb28b79
md"""
You can explore the relations between types with the functions `supertypes` and `subtypes`.
"""

# ╔═╡ c7677c6d-44fd-4bcc-91ef-911a8a513bb6
subtypes(Real)  # gives all the children of a type

# ╔═╡ dd22a20e-5db4-4a97-9572-ccc157c9d592
supertypes(Float64)  # gives the chain of ancestors of a type

# ╔═╡ 23a229b1-dcf2-4803-9bd6-8df2e60ba8f5
md"""
!!! danger "Task 1.0.1"
	Implement a function `count_descendants(T)` which outputs the number of descendants (the node itself + all of its children, grandchildren, etc.) of a type `T` in the type tree.
	How many descendants does `Real` have?
	Does this number depend on the packages we have imported?
"""

# ╔═╡ 29550224-6f26-4e87-bfe2-e621802cc8d0


# ╔═╡ 61c97fd4-c964-4347-90ca-a7e952b02ad6
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

# ╔═╡ 29c9d2bc-3e90-4558-8e81-7b979be68d2b
md"""
## 1.1 Callable structs
"""

# ╔═╡ e831ff8c-93fc-437b-a5da-338fb37a8ac8
md"""
By now, you know how to define functions in Julia, using the syntax below.
"""

# ╔═╡ f90e05ad-2c19-40dd-952e-bb9ca485aeef
function my_identity(x)
	return x
end

# ╔═╡ d74a5724-def9-4c87-9fee-23544dc7b745
md"""
!!! danger "Task 1.1.1"
	What is the type of `my_identity`? What are its supertypes?
"""

# ╔═╡ c03c8cc6-36d8-4102-a737-885e1a838ca2


# ╔═╡ cb502def-3d5c-46cb-b921-549a44d4dc9c
md"""
Functions are just a particular kind of callable object (or "functor").
But as it turns out, every type can be made callable using a very simple trick: just define a function whose "name" is an instance of the type.
This is very useful when you want to perform operations with some internal parameters (like weights in a neural network, see below).
"""

# ╔═╡ 02656905-39a5-45ca-ab90-4450147be7e2
md"""
Here's a simple example, in which we define a `Multiplier` struct with a single attribute `a`.
When we call an instance `mult` of this type on a value `x`, we want to obtain the product `mult.a * x`.
"""

# ╔═╡ 74be726b-51a1-4ea3-8124-8cd3dcf3519d
begin
	struct Multiplier
		a
	end

	function (mult::Multiplier)(x)
		return mult.a * x
	end
end

# ╔═╡ b9194069-682c-4f66-94d3-64d3c85a89cf
md"""
Note that we put both definitions in the same cell because of Pluto quirks.
Now let's check that everything works as intended.
"""

# ╔═╡ 8bc9e29d-873c-4866-b8ac-814bcef8da16
let
	scalar_mult = Multiplier(2.0)
	(
		scalar_mult(3),
		scalar_mult(4 + 5im),
		scalar_mult(6 * ones(2, 2))
	)
end

# ╔═╡ 8e49c403-73e2-4011-ae06-1c20a3aa9157
let
	matrix_mult = Multiplier([1 2; 3 4])
	(
		matrix_mult(3),
		matrix_mult(4 + 5im),
		matrix_mult(6 * ones(2, 2))
	)
end

# ╔═╡ 0f2b0835-264d-412a-b53b-2d0d8bd987e1
md"""
We will encounter callable structs again in Sections 2 and 3, when we discuss time series and solutions to differential equations.
"""

# ╔═╡ 65c11552-7eee-4216-9f39-fe2a63478835
md"""
!!! danger "Task 1.1.2"
	Implement a callable struct `FunctionWrapper` with a single field `f`.
	Whenever it is called, it should simply apply the function `f` to the input arguments.
"""

# ╔═╡ 30bad66b-0021-4bed-af8e-bbffebe2f84d
hint(md"If you want a function to accept any number of positional and keyword arguments, the syntax is `f(args...; kwargs...)`")

# ╔═╡ b53f9a8a-8253-4326-ae8d-41c9c9f349c6


# ╔═╡ d4b252e6-5be7-4b93-b678-9a60ee27e67e
let
	if @isdefined FunctionWrapper
		fw = FunctionWrapper(sin)
		fw(1), sin(1)
	end
end

# ╔═╡ f093e439-0671-435c-bf08-4622901fc0d8
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

# ╔═╡ 103e3f01-14e0-440e-abde-0f464cb69055
md"""
## 1.2 Type-stability
"""

# ╔═╡ bf2706b0-7c2e-4829-9667-13d037a258ca
md"""
Remember HW2, when I told you that there were more secrets to writing high-perfomance Julia code?
Well, today is your lucky day, because I'm going to teach you about type stability.
Yay!

Type inference is the process by which Julia tries to deduce the type of every variable in your code before actually running it.
A code that enables successful type inference is called type-stable.

For each function you write, can you deduce the type of every intermediate and output quantity based only on the _types_ (not the _values_) of the inputs?
If the answer is yes, then your code is type-stable.
"""

# ╔═╡ 3d5590db-de13-4b83-8925-3ea1f813a9ec
md"""
!!! danger "Task 1.2.1"
	Try to explain why the following function is type-unstable.
"""

# ╔═╡ c4447d2d-cbe8-4146-a886-b8a531445d85
function choice(x)
	if x < 0
		return "negative number"
	else
		return x
	end
end

# ╔═╡ 5b4e99ea-2d3d-4841-b792-7c08dea43110


# ╔═╡ 41780c0a-2fb3-4329-a24d-86e5714600b7
md"""
The `Multiplier` defined above works, but it is far from perfect.
Its biggest fault is that it doesn't "know" the type of the field `a`.
As a result, it generates type-unstable calls because Julia cannot predict the type of the output `a * x`.

Such problems can often be diagnosed with the `@code_warntype` macro, which is used before a function call.
As a rule of thumb, blue is good and red is bad, while yellow is "meh".
"""

# ╔═╡ c32c2e53-1689-4b9f-9e5e-4f2d7d62f43f
let
	a = 2.0
	x = 1.0
	@code_warntype a * x
end

# ╔═╡ b4b96d78-7f6f-4e3a-a711-51782c3a6cda
md"""
This is not easy to read, but what is important is the type of every intermediate quantity is correctly inferred as `Float64`.
"""

# ╔═╡ 86af8c5c-3bc8-4802-a934-22b487f74d2e
let
	a = 2.0
	mult = Multiplier(a)
	x = 1.0
	@code_warntype mult(x)
end

# ╔═╡ 49b09ba2-a276-430d-8cc1-74efc1a44f6f
md"""
On the other hand, since the type of `mult.a` is forgotten by the `Multiplier`, all we can infer is that it will be of type `Any`, which is a supertype of everything else (see `%1`).
As a consequence, the type of `Body` (which is the output of the function) is also inferred as `Any` (see `%2`).
"""

# ╔═╡ 75e3d3ca-4705-464d-ac26-5dab7116e7cf
md"""
But why is it bad to have type-instability?
Because Julia has to prepare for every possible type, which generates very lengthy and inefficient machine code.
This can be confirmed with the `@code_llvm` macro.
"""

# ╔═╡ e2427de0-bb05-4e97-be61-7ff5eb7bf425
let
	a = 2.0
	x = 1.0
	@code_llvm a * x
end

# ╔═╡ 83b3f372-e366-411f-9b27-58e1d400a57d
md"""
This low-level code is only a few lines long.
"""

# ╔═╡ cb290544-fa39-4766-b332-5c4f99165d29
let
	a = 2.0
	mult = Multiplier(a)
	x = 1.0
	@code_llvm mult(x)
end

# ╔═╡ 164737a4-60eb-425a-b608-515067760fcb
md"""
Whereas this one is the stuff of nightmares.
"""

# ╔═╡ efaa6ba6-0ed6-4a9b-8654-77e305297885
md"""
!!! danger "Task 1.2.2"
	Test the type-stability of your `FunctionWrapper`.
"""

# ╔═╡ f1e8f11b-18e6-4d4e-9fa1-1e8dcdc16444
hint(md"Don't worry if it is not type-stable: that's okay for now.")

# ╔═╡ ebbe26b6-66b4-4c75-8c11-d69aabda0064


# ╔═╡ 1dc083e8-be0a-4b71-b898-b0b4f6788d7d
md"""
## 1.3 Parametric types
"""

# ╔═╡ f8f06daa-74aa-4195-8085-23262aa822b8
md"""
So how do we solve the type-instability issue?
Well, the general idea is to [avoid fields with abstract types](https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-fields-with-abstract-type) in user-defined structs.
The sames principle applies to [arrays and other containers](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-abstract-container).
If the type of each field (or element) is concrete, then type inference suceeds, which leads to better performance.
"""

# ╔═╡ b86fbfea-d1ca-4226-8f01-3c903df66e6f
md"""
Let's see if this criterion is satisfied by our `Multiplier` (spoiler alert: no it isn't).
"""

# ╔═╡ dfd0c11e-f5bb-4cfa-ba09-71dadc7a54e7
let
	scalar_mult = Multiplier(2.0)
	fieldnames(typeof(scalar_mult)), fieldtypes(typeof(scalar_mult))
end

# ╔═╡ 1822a76e-994d-482e-8b60-f07183781f8f
md"""
Of course, the easy way out would be to add a concrete type annotation for the field `a`.
"""

# ╔═╡ d738fc0f-bb2f-437b-9040-4f5ea4867918
begin
	struct SpecificMultiplier
		a::Float64
	end

	function (mult::SpecificMultiplier)(x)
		return mult.a * x
	end
end

# ╔═╡ 608f973b-a502-4e8c-baa8-ce175c3d4688
let
	scalar_mult = SpecificMultiplier(2.0)
	(
		scalar_mult(3),
		scalar_mult(4 + 5im),
		scalar_mult(6 * ones(2, 2))
	)
end

# ╔═╡ fcc54748-62f9-44f3-9e73-c3da9efe0dc5
md"""
This time, we can check that our struct has a concrete field type.
"""

# ╔═╡ ab4a8076-21ae-4521-b18e-6cd5f05671da
let
	scalar_mult = SpecificMultiplier(2.0)
	fieldnames(typeof(scalar_mult)), fieldtypes(typeof(scalar_mult))
end

# ╔═╡ de549344-4979-425a-bc28-3572a4d9deb1
md"""
But if we go down that road, we will need a different struct for every possible type of `a`.
That seems a bit tedious, especially since the multiplication code does not change.
What we really need is a single struct that somehow "adapts" to the type of the field `a`.

You've already seen that kind of construct before, when we introduced arrays.
Vectors and matrices have a "type parameter", which refers to the elements they contain.
"""

# ╔═╡ e13edf4e-0c88-4fb6-8955-1f4099c36761
typeof([1, 2]), typeof([1.0, 2.0]), typeof([[1, 2]])

# ╔═╡ 3b4634a0-bcdf-4dff-8d3c-4fe7da7b11d4
md"""
As a result, `Vector`, `Matrix` and `Array` are called [parametric types](https://docs.julialang.org/en/v1/manual/types/#Parametric-Types).
We can define our own parametric type with the following syntax.
"""

# ╔═╡ 7c28b7f1-0fe6-4022-939c-f478a93b7dac
begin
	struct GenericMultiplier{T}
		a::T
	end

	function (mult::GenericMultiplier)(x)
		return mult.a * x
	end
end

# ╔═╡ 51cc15b4-c9ec-458f-81d5-b4648b0dd660
md"""
Every time we create a `GenericMultiplier`, it will automatically choose the right type parameter based on the type of `a`.
"""

# ╔═╡ 41cbc589-ab18-4bba-a374-efdc46e04b3b
typeof(GenericMultiplier(2.0))

# ╔═╡ 5cbe0f25-baa1-4f78-996d-fa57818448fc
typeof(GenericMultiplier([1 2; 3 4]))

# ╔═╡ e151decd-531a-4b91-9ad1-803fe825d024
md"""
We can also be picky and specify the parameter ourselves at construction.
"""

# ╔═╡ 9f725037-e90f-4c7d-b4c1-7a3f8cb51f8d
typeof(GenericMultiplier{Matrix{Float64}}([1 2; 3 4]))

# ╔═╡ d433526c-e6fd-4f84-a391-bba29883d893
md"""
This new struct works as expected, no matter what we throw at it.
"""

# ╔═╡ bbf06920-80bd-4a5d-b937-10d22abc4526
let
	scalar_mult = GenericMultiplier(2.0)
	(
		scalar_mult(3),
		scalar_mult(4 + 5im),
		scalar_mult(6 * ones(2, 2))
	)
end

# ╔═╡ 32fb7990-93f3-4101-b056-1725a615b495
let
	matrix_mult = GenericMultiplier([1 2; 3 4])
	(
		matrix_mult(3),
		matrix_mult(4 + 5im),
		matrix_mult(6 * ones(2, 2))
	)
end

# ╔═╡ 48aee5a5-bad9-4462-a238-9666698ece3f
md"""
Importantly, this generic approach does not prevent type inference.
"""

# ╔═╡ f866ed9e-1a6d-4c9c-a3f6-91c8675aec21
all(isconcretetype, fieldtypes(GenericMultiplier{Float64}))

# ╔═╡ d84713bf-08b5-4083-98d3-dda9ecc97b00
let
	a = 2.0
	mult = GenericMultiplier(a)
	x = 1.0
	@code_warntype mult(x)
end

# ╔═╡ f1c42709-576e-4180-bb8b-a66c31f6c440
md"""
As a result, the generated machine code is about as efficient as can be.
"""

# ╔═╡ 091ab1b7-ee29-440e-80de-e87eb50739b2
let
	a = 2.0
	mult = GenericMultiplier(a)
	x = 1.0
	@code_llvm mult(x)
end

# ╔═╡ ee6e7754-6a8f-4e73-966b-2e09dba67ca3
md"""
But don't take my word for it, check it yourself!
"""

# ╔═╡ cf61e96a-8e3f-4655-a9aa-85c39da060a3
md"""
!!! danger "Task 1.3.1"
	Compare the performance of `Multiplier`, `SpecificMultiplier` and `GenericMultiplier{T}` with `BenchmarkTools.jl`.
"""

# ╔═╡ aca07c02-db3a-44e4-bb33-73047f726f9d
hint(md"
You already know the `@btime` and `@belapsed` macros, why not try `@benchmark` this time?
And don't forget the dollar signs!
")

# ╔═╡ 5ab1bea3-049e-4765-8323-f9ece4424230


# ╔═╡ 64e4786c-1f13-4cf6-a6e6-016b9d595d26
md"""
In other words, `GenericMultiplier` combines the generic capabilities of `Multiplier` with the type-specific performance of `SpecificMultiplier`.
That is called having your cake and eating it too, which is a Julia specialty.
"""

# ╔═╡ edefd92d-4e63-4f4e-be96-ea9d6c74ab00
md"""
## 1.4 Type constraints
"""

# ╔═╡ 0c60b420-63d5-4a33-86c2-5dd460b55caa
md"""
In some cases, we want to enforce constraints on the type parameters.
This is done with the `<:` operator, which indicates subtyping.
"""

# ╔═╡ 0b1a6b6a-a376-4a1b-a078-11d879541902
Float64 <: AbstractFloat <: Real <: Number <: Any

# ╔═╡ 1b9b4c90-ec5d-4342-8451-3d19101ae942
Int <: Signed <: Integer <: Real <: Number <: Any

# ╔═╡ 6a5b2f84-81eb-48fa-a61e-1f289d5a3535
md"""
In more complex situations, the subtyping behavior can seem a bit counterintuitive, as described in the documentation for [parametric types](https://docs.julialang.org/en/v1/manual/types/#man-parametric-composite-types).
Even if `T1 <: T2`, we don't have `ParametricType{T1} <: ParametricType{T2}`.
See for yourself.
"""

# ╔═╡ e2bcfb79-a4d5-4c3b-b77d-d2a8f3e42d71
Vector{Float64} <: Vector{Real}

# ╔═╡ 7404efda-a9ba-40e6-b3c8-f7733d42ad1d
md"""
Here is a way to overcome this difficulty.
"""

# ╔═╡ de0c1b6a-adda-45c2-b1cc-43de3abeda63
Vector{Float64} <: Vector{<:Real}  # note the <: before Real

# ╔═╡ f6f766a7-d859-420f-8c51-0ccb96df75f0
md"""
And here is another equivalent one, with a keyword you already encountered in HW1.
"""

# ╔═╡ db19c2e4-7f13-4fec-9971-82a6e0268bc3
Vector{Float64} <: Vector{T} where {T<:Real}

# ╔═╡ 35ce934e-0b06-4d73-a4b1-4a7ad82f1574
md"""
Now say we want to define a `Multiplier` that only works when `a` is a matrix containing any subtype of real numbers.
Here are several ways to do it.
"""

# ╔═╡ 018a1a45-7ec8-4994-b2dc-c2e3d22074cc
struct MatrixMultiplier1
	a::Matrix{Real}
end

# ╔═╡ b14f9d57-ce80-4920-b680-7034dcd047b8
struct MatrixMultiplier2
	a::Matrix{<:Real}
end

# ╔═╡ 54348524-df5b-4375-b7ec-fdb3d0126a10
struct MatrixMultiplier3{T<:Real}
	a::Matrix{T}
end

# ╔═╡ 780a8a88-6fce-431d-bcb4-08b3a4ea9985
struct MatrixMultiplier4{M<:Matrix{Real}}
	a::M
end

# ╔═╡ cf10a39a-9187-4923-95ce-a9bf63833a7e
struct MatrixMultiplier5{M<:Matrix{<:Real}}
	a::M
end

# ╔═╡ 1429926d-6f98-458d-aafe-7e40a17f17f4
struct MatrixMultiplier6{T<:Real,M<:Matrix{T}}
	a::M
end

# ╔═╡ 9a074f51-00b7-4d31-a885-911a17e7d4d6
md"""
!!! danger "Task 1.4.1"
	Based on our discussion sofar, experiment with these various `MatrixMultiplier` structs and decide which ones a) have the correct behavior with respect to our specification, and b) are type-stable.

	Sum up your answers in the table below.
	If you think a given `MatrixMultiplier` is incorrect, provide a code example where it throws an error.
	If you think a given `MatrixMultiplier` is type-unstable, provide a code example where `@code_warntype` contains red flags.
"""

# ╔═╡ 6695c9f5-d171-4079-b9c3-284d82623dbd
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

# ╔═╡ 261d51ea-322e-4573-a11c-5b215759fef5
md"""
## 1.5 Your first neural network
"""

# ╔═╡ ed355794-73f4-4882-8a3c-21f65c7c1114
md"""
Callable structs come up a lot in deep learning, whenever we construct layers of a [neural network](https://en.wikipedia.org/wiki/Artificial_neural_network).
A neural network layer is a function of the form $x \in \mathbb{R}^n \longmapsto \sigma.(W x + b) \in \mathbb{R}^m$, where
- the matrix $W \in \mathbb{R}^{m \times n}$ contains connection weights
- the vector $b \in \mathbb{R}^m$ contains biases
- the function $\sigma: \mathbb{R} \longrightarrow \mathbb{R}$ is a nonlinear activation applied elementwise
"""

# ╔═╡ 39423543-2d79-4f18-b905-fb20a9a9dee1
md"""
!!! danger "Task 1.5.1"
	Implement a callable struct `Layer` with three fields `W`, `b` and `σ`, such that:

	- `W` must be a matrix containing any subtype of `Real` numbers
	- `b` must be a vector containing any subtype of `Real` numbers
	- `σ` can be anything.

	Whenever it is called, it should perform the operation described above.
"""

# ╔═╡ 85e63ff9-9a91-40a8-97f1-f7f9eeca3abf


# ╔═╡ fee314d5-75da-4aa5-8ea9-c6b03f0783c2
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

# ╔═╡ d1672de6-d58e-44d3-9d12-2a59f49481a3
md"""
!!! danger "Task 1.5.2"
	Test the type-stability of your `Layer`.
"""

# ╔═╡ 846597f0-6840-4312-84a7-d877aada2589


# ╔═╡ 3fff69fd-25f4-4abf-938f-f06d02cfd83e
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

# ╔═╡ 0e86e043-c7b0-4015-8cb0-b9d6e1103778
md"""
A feedforward neural network is just a sequence of layers applied one after the other.
"""

# ╔═╡ d0c9d740-253e-4a5f-9519-a4a476b22319
md"""
!!! danger "Task 1.5.3"
	Implement a callable struct `Network` with a single field `layers`, which is a vector whose elements are all `Layer`s
	Whenever it is called, it should apply each layer sequentially.
"""

# ╔═╡ c4ee99b6-dd9e-48b0-8652-8ac52f3082d3


# ╔═╡ 24a208e9-e967-4523-97e5-6202e398cdd6
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

# ╔═╡ a77d1576-cd43-4de5-ad5d-e1b3698dcbc8
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

# ╔═╡ c0a970a3-fd0a-4180-bfba-7537c41e4c78
md"""
!!! danger "Task 1.5.4"
	Test the type-stability of your `Network`.
"""

# ╔═╡ 0767d676-efd0-479c-a551-10463e36b61c


# ╔═╡ dfe05823-f0ef-4df6-9fa3-0301f4069f56
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

# ╔═╡ 9fbf0b87-6af8-40ce-952f-05f4d9f89b8c
md"""
Why is it so important to use parametric types?
For one thing, if you remember HW2, it is essential for forward-mode automatic differentiation.
And if you coded your `Layer` properly, the following snippet will work just fine.
"""

# ╔═╡ 48809f4a-1ced-48e9-90cb-b1f27ff83a58
function loss(W, x)
	b = zeros(size(W, 1))
	σ = tanh
	layer = Layer(W, b, σ)
	y = layer(x)
	ℓ = sum(abs2, y)
	return ℓ
end

# ╔═╡ 78af5e63-0c95-49b5-9997-da5536a79897
let
	if @isdefined Layer
		n, m = 3, 4
		W = rand(m, n)
		x = rand(n)
		ForwardDiff.gradient(W_ -> loss(W_, x), W)
	end
end

# ╔═╡ 49ffc7b2-ffbf-4a8d-a12b-37ab558b7f1c
md"""
# 2. Temperature interpolation
"""

# ╔═╡ f66872a9-5280-44d5-9ef9-1529135e0984
md"""
We start by downloading a time series of global land and ocean temperature values from <https://www.ncei.noaa.gov/cag/global/time-series/globe/land_ocean/ann/12/1880-2022>.
"""

# ╔═╡ b5470cd4-d8cc-47e5-8167-c03f0f974100
temp_path = download("https://www.ncei.noaa.gov/cag/global/time-series/globe/land_ocean/12/12/1880-2022/data.csv")

# ╔═╡ 83cc679d-514a-41de-97ce-f9181fd67c70
md"""
We store this data into two vectors: `temp_years`, which contains the measurement years, and `temp_values`, which contain the temperature anomalies (in °C) compared to the 1901-2000 base period.
"""

# ╔═╡ 320fe764-45ce-4f09-bea1-f77cccc11a9b
begin
	temp_df = CSV.read(temp_path, DataFrame, header=5, skipto=6)
	temp_years = temp_df[!, :Year]  # select a column from the dataframe
	temp_values = temp_df[!, :Value]
end;

# ╔═╡ 702c37fc-4607-4a72-9ca3-af99d59de028
md"""
We first give a simple data visualization, and then we use callable structs to make the plot nicer.
"""

# ╔═╡ 07fa38bf-a00d-49cd-bd56-891936cda37a
md"""
## 2.1 Data visualization
"""

# ╔═╡ 5d4b8e42-7e9d-4069-b3f6-28a4c060f117
md"""
!!! danger "Task 2.1.1"
	Try to reproduce the plot from <https://www.ncei.noaa.gov/access/monitoring/climate-at-a-glance/global/time-series/globe/land_ocean/ann/12/1880-2022> as best you can.
	In particular, your plot should be a bar chart, and have the following features: a title, axis labels, different colors for positive and negative anomalies, as well as a legend in the top left corner.
"""

# ╔═╡ 5308dcf7-aa8b-4b23-adec-33564d33c325
hint(md"Check out the `Plots.jl` [tutorial](https://docs.juliaplots.org/latest/tutorial/)")

# ╔═╡ e5a95033-c389-4023-a02c-d448f1f2bc16
hint(md"If you want to select a part of an array `x` for plotting, for instance the subset of positive elements, you can create a boolean array with `x .> 0` and then use it for indexing: `x[x .> 0]`")

# ╔═╡ 0d7426e1-620c-4096-906b-a9d1b9088740


# ╔═╡ 8e26636f-728b-43f4-9859-82a7734c95a6
md"""
In the following subsections, the plots should appear automatically as soon as your struct definition is correct.
"""

# ╔═╡ 6f33f798-c0d3-46cd-9dd2-71b8a31bf617
md"""
## 2.2 Piecewise constant interpolation
"""

# ╔═╡ e25e329e-4481-4b39-b895-93c82f9ea2c3
md"""
!!! danger "Task 2.2.1"
	Implement a callable struct `TemperatureSeriesConstant` with two fields `years` (for a vector of years) and `values` (for a vector of temperature values).

	Whenever it is called on an input `t`, it should find the first year larger than `t` in `years`, and return the corresponding element from `values`
"""

# ╔═╡ 5f8ee73f-d729-4be2-ba20-00f8b453cdd4
hint(md"You may want to look up the documentation for the function `searchsortedfirst`")

# ╔═╡ 31b05bd7-34e3-4612-9734-916d5a708bc0


# ╔═╡ 085a5767-dee5-47e2-9d7c-101c188e92cf
md"""
!!! danger "Task 2.2.2"
	Check the type-stability of your `TemperatureSeriesConstant`.
"""

# ╔═╡ b69b8ce2-ff6d-4405-b9db-f9169f5f44ae


# ╔═╡ f0f3bfe2-dcec-40f6-87c1-a5538c354dd0
md"""
## 2.3 Linear interpolation
"""

# ╔═╡ 85e93187-d7d5-4023-a243-d9b986f2e0a6
md"""
!!! danger "Task 2.3.1"
	Implement a callable struct `TemperatureSeriesLinear` with the same fields as `TemperatureSeriesConstant`.

	Whenever it is called on an input `t`, it should find the years below and above `t` in `years`, and linearly interpolate the corresponding elements from `values`.
"""

# ╔═╡ 45329aaf-8bff-4381-bf60-ec68515f5e42
hint(md"Don't worry about boundary conditions, we will make sure not to call this function outside of the safe interval of years")

# ╔═╡ f08ae9c1-8b1b-4f49-ace3-b40b5d4f47bc


# ╔═╡ 2f2b457e-8f81-4886-8684-b80474676386
md"""
!!! danger "Task 2.3.2"
	Check the type-stability of your `TemperatureSeriesLinear`.
"""

# ╔═╡ eb0eadbe-8b13-4bd8-b65e-4966e4a85f3d


# ╔═╡ 5aa70c8a-60fe-4bfa-aa1a-68a9204be4eb
md"""
## 2.4 Spline interpolation
"""

# ╔═╡ 539f779e-0d6f-45e0-8e98-a3a1f5a3b50a
md"""
Just for fun, here is what we could obtain if we went beyond a linear interpolation to higher-order (local) polynomials.
"""

# ╔═╡ 92cd9bc2-4757-4495-8c56-2ec5e30e9f06
md"""
# 3. Differential equations
"""

# ╔═╡ 1e48645c-ffab-4120-baf8-b4dd556330aa
md"""
We now get to the heart of the matter: differential equations for temperature evolution.
"""

# ╔═╡ 21b3a806-696d-45a6-a3dd-8e17f202355e
md"""
## 3.1 The model
"""

# ╔═╡ e9403765-d42a-40aa-8c13-5cc3fc3754b8
md"""
A simplified model for land and ocean temperature is the following:
```math
C \frac{\mathrm{d} T}{\mathrm{d} t} = B(T_0 - T) + G(t) \quad \text{where} \quad \begin{cases} \text{$C$ is the heat capacity} \\ \text{$B$ is the feedback} \\ \text{$G(t)$ is the effect of greenhouse gases} \end{cases}
```
"""

# ╔═╡ b9f9f8ca-feeb-4b23-b5ee-f07204cb8daa
md"""
Let's consider a period of $170$ years, starting after the industrial revolution at $t_0 = 1850$, and going all the way to $t_f = 2020$.
"""

# ╔═╡ 8dc428d8-8dab-4143-94b3-56c7d29e95e6
t0, tf = 1850, 2020

# ╔═╡ 26694aa3-415a-4ae6-87a3-82a16481f15a
md"""
Here is the climate situation we start with.
"""

# ╔═╡ 4ec83bfa-6d40-4b3f-92d4-79916e9c07ed
begin
	CO₂_preindustrial = 280.0  # [ppm]
	T_preindustrial = 14.0 # [°C]
	T_equilibrium = T_preindustrial
end;

# ╔═╡ 5d51ab5a-5cd1-4157-b210-95ad9b96412c
md"""
We give the following default values for the parameters, feel free to play with them!
"""

# ╔═╡ 4a7ce64e-fbad-497c-a7bf-42464815bfd6
md"""
Heat capacity [Wyr/m²/°C]: $(@bind heat_capacity Slider(10:200; default=51, show_value=true))
"""

# ╔═╡ 3e1ccc36-29bc-4c06-bf38-8197259fe68f
md"""
Feedback [W/m²/°C]: $(@bind feedback Slider(0.0:0.1:4.0; default=1.3, show_value=true))
"""

# ╔═╡ 2f9fad1c-c233-4d41-85f5-dbe76676a073
md"""
Forcing [W/m²]: $(@bind forcing Slider(0.0:0.1:20.0; default=5.0, show_value=true))
"""

# ╔═╡ da91aa4a-8516-4f17-9026-21fb323338eb
md"""
We consider the following models for $\text{CO}_2$ emissions and greenhouse effect.
"""

# ╔═╡ d5ca36a4-3467-43e2-b8d2-f367b9d23f45
CO₂(t) = CO₂_preindustrial * (1 + ((t - t0) / 220)^3)

# ╔═╡ 5a0b53b1-0fc9-4fae-bc65-09dc256f4efa
greenhouse_effect(t) = forcing * log(CO₂(t) / CO₂_preindustrial)

# ╔═╡ 88ba3961-bc7d-4257-a1a4-7d6686e1a583
md"""
## 3.2 The solver
"""

# ╔═╡ 171aecd0-76e3-4118-bb3b-ac29945ef1b7
md"""
Even though Julia is a young programming language, its package ecosystem for solving differential equations (and [scientific machine learning](https://sciml.ai/) in general) is easily one of the best.

Here, we are going to use [`DifferentialEquations.jl`](https://github.com/SciML/DifferentialEquations.jl), which expects a very precise formulation for our model.
We must provide it as
```math
\frac{\mathrm{d} u}{\mathrm{d} t} = f(u, p, t)
```
where $u$ is the function of interest (in our case the temperature $T$) and $p$ is a set of parameters influencing the dynamics.
"""

# ╔═╡ 7b1e1d6e-8aeb-4503-a619-f69cbbde7025
md"""
We start by giving an example without greenhouse effect.
"""

# ╔═╡ 6079c292-c38b-4cb9-8e09-e6fed033c42f
function dynamics1(T, p, t)
	return inv(heat_capacity) * feedback * (T_equilibrium - T)
end

# ╔═╡ 4dce1ab4-fcf4-4e91-a9f9-f15c784b2501
md"""
To completely describe the problem, we also need the initial condition and the time interval on which to solve it.
"""

# ╔═╡ 67e283d3-9dd9-468f-97cd-16c0706aca00
problem1 = ODEProblem(dynamics1, T_preindustrial, (t0, tf))

# ╔═╡ e232b56e-d4bd-491f-baa0-15c63a7e7c0f
md"""
Once we have a problem, solving it could not be simpler.
"""

# ╔═╡ 711f732d-d6eb-4128-9765-b1580e1238b4
solution1 = solve(problem1)

# ╔═╡ 2426f0f6-c663-4718-8126-e76a2afce236
md"""
Now of course that is rather boring, because in this model the starting temperature is also the equilibrium temperature.
"""

# ╔═╡ 097613af-c9da-4285-99f4-56ff325acbbc
md"""
!!! danger "Task 3.2.1"
	Implement a new function `dynamics2` which takes the greenhouse effect into account.
	Create a `problem2` accordingly, and store the solution in `solution2`.
"""

# ╔═╡ 3b0e364e-e3ea-4c73-8b3a-9b4e4528d8d3


# ╔═╡ 26cf28b4-6fe9-4560-be5b-cb8fd2bba414


# ╔═╡ a2e7dc49-151d-43fd-a2cf-17d7d83900a6


# ╔═╡ 926b3d7c-aea8-4c50-8eb5-0afc2f516af7
md"""
OK, so now things are happening!
Granted, these are bad things, but at least we're no longer bored.
"""

# ╔═╡ 14fd83e4-3ebb-4445-848d-3c864b0549fe
md"""
## 3.3 Dissecting a solution object
"""

# ╔═╡ e50e6d8d-9bfe-4702-ac72-89d45e6eeb84
md"""
Time to investigate what this solution object contains.
The first thing to notice is that it has a very complicated type with lots of parameters (thanks Chris!).
"""

# ╔═╡ ab033e74-b244-445a-a9c6-fbcbd441d499
typeof(solution1)

# ╔═╡ 7d0c71c3-bd47-4e43-abee-ad34db5c5f9e
md"""
So let's try to see what the interesting fields are.
"""

# ╔═╡ 85c86abd-03bc-42c3-a6b4-22e9d5269caa
fieldnames(typeof(solution1))

# ╔═╡ e10b46dd-bbe1-45fb-9077-f82219e82af0
md"""
I don't know about you, but I'm mostly interested in checking out `solution.u` (the function values) and `solution.t` (the instants at which these values are computed).
"""

# ╔═╡ 52191ad7-195d-449d-96be-8a25cc674d87
md"""
!!! danger "Task 3.3.1"
	Using the fields mentioned above, create a plot that compares `solution2` with the measurements you studied in Section 2.
	Don't forget the title, legend, etc.
"""

# ╔═╡ d49a7c24-887d-4d5d-81a8-ff0d08937189
hint(md"Section 2 dealt with temperature _anomalies_ wrt to the 20th century.
If you want both time series to be comparable, you need to subtract the 20th century temperature average from `solution2`.
To do that, use the function `mean` on a subvector of `solution2.u`.")

# ╔═╡ f8ad6892-f1f1-4231-82ed-14f4fe3878e7


# ╔═╡ 1e398d0c-4b25-4a05-abbc-2d0d6916bd77
md"""
!!! danger "Task 3.3.2"
	In your opinion, why are the temporal instants `solution2.t` not evenly spaced?
"""

# ╔═╡ e018dd21-07e6-4c1d-ad04-9b45d2f991b5


# ╔═╡ e080aa6d-2ac8-472f-b3b2-84d454cdb6c4
md"""
!!! danger "Task 3.3.3"
	What happens when you do `plot(solution2)` directly?
	Why is it not a scatter plot?
	Based on what we have seen sofar in the homework, how can you explain it?
"""

# ╔═╡ 1b66d8d2-f534-4f78-9640-9800eddc0e20


# ╔═╡ 9cf65bc1-872c-40c3-9448-255ebaa2b3a3
md"""
!!! danger "Task 3.3.4"
	By playing with the sliders in Section 3.1, figure out the role of the heat capacity, the feedback and the forcing.
"""

# ╔═╡ 1600e9c7-0aa7-4079-94ec-7a2a8b896d1b
hint(md"You can drag the slider cells next to the plots for quicker experiments")

# ╔═╡ 270be245-30c8-4404-ba1c-52646e98742e


# ╔═╡ 1c98ff24-681f-4c76-ba8a-b89e82eb41e3
md"""
# Utilities
"""

# ╔═╡ b5726056-d2a8-46f3-bf0f-a5959da92c6d
begin
	struct MyFunctionWrapper{F}
		f::F
	end

	(mfw::MyFunctionWrapper)(args...; kwargs...) = mfw.f(args...; kwargs...)
end

# ╔═╡ fe81dc2e-1f2f-49db-97d9-0faf5c8db8fd
let
	n, m = 3, 4
	x = rand(n)
	W = rand(m, n)
	b = rand(m)
	σ = tanh
	W_tricky = BigFloat.(W)
	b_tricky = BigFloat.(b)
	σ_tricky = MyFunctionWrapper(σ)

	if @isdefined Layer
		try
			layer = Layer(W, b, σ)
			Layer(W_tricky, b, σ)
			Layer(W, b_tricky, σ)
			Layer(W, b, σ_tricky)
			try
				Layer(b, W, σ)
				almost(md"The `Layer` constructor should only accept a matrix for `W` and a vector for `b`")
			catch e
				try
					Layer(Complex.(W), b, σ)
					almost(md"The `Layer` constructor should only accept real elements for the matrix `W` and the vector `b`")
				catch e
					try
						output = layer(x)
						check = output ≈ σ.(W * x + b)
						if check
							correct()
						else
							almost(md"Calling the `Layer` returns an incorrect result")
						end
					catch e
						almost(md"Calling the `Layer` throws an error")
					end
				end
			end
		catch e
			almost(md"The `Layer` constructor should accept generic element types for `W` and `b`, as well as a generic callable for `σ` (not just a function)")
		end
	else
		almost(md"You need to define `Layer`")
	end
end

# ╔═╡ a21dcf25-9321-439c-9e3d-6fcc6fc6909b
begin
	struct TemperatureSeriesSpline{Y<:Number,V<:Number,I}
		years::Vector{Y}
		values::Vector{V}
		interp::I
	end

	function TemperatureSeriesSpline(years, values)
		interp = cubic_spline_interpolation(first(years):last(years), values)
		return TemperatureSeriesSpline(years, values, interp)
	end

	function (temp::TemperatureSeriesSpline)(t::Number)
		return temp.interp(t)
	end
end

# ╔═╡ d5f81c9e-930e-4272-8e95-48e2de5f255a
function plot_temperature_series(temp; step=0.1)
	times = 1881+step:step:2021-step
	values = temp.(times)
	colors = ["blue", "red"]
	pl = plot(
		xlabel="Year",
		ylabel="Temperature anomaly [°C]",
		title="Global warming is real",
		legend=:topleft
	)
	plot!(
		pl,
		times,
		values,
		color=colors[Int.(values .> 0) .+ 1],
		label=nothing
	)
	return pl
end

# ╔═╡ f6f46184-904c-41f6-8664-2e132ea63287
let
	if @isdefined TemperatureSeriesConstant
		temp_constant = TemperatureSeriesConstant(temp_years, temp_values)
		plot_temperature_series(temp_constant)
	end
end

# ╔═╡ e42ebdbe-e374-4aad-ba0f-46d3a20c3e5f
let
	if @isdefined TemperatureSeriesLinear
		temp_linear = TemperatureSeriesLinear(temp_years, temp_values)
		plot_temperature_series(temp_linear)
	end
end

# ╔═╡ 0162de19-4c4c-4aba-9d56-cd7d67e58ef6
let
	temp_spline = TemperatureSeriesSpline(temp_years, temp_values)
	plot_temperature_series(temp_spline)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractTrees = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
DifferentialEquations = "0c46a032-eb83-5123-abaf-570d42b7fbaa"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
Interpolations = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
AbstractTrees = "~0.4.2"
BenchmarkTools = "~1.3.1"
CSV = "~0.10.4"
DataFrames = "~1.4.1"
DifferentialEquations = "~7.5.0"
ForwardDiff = "~0.10.32"
Interpolations = "~0.14.6"
Plots = "~1.35.3"
PlutoTeachingTools = "~0.2.3"
PlutoUI = "~0.7.44"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "cc1277bb8fd1db37f7efde6a37cfe1490bc7caf5"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "5c0b629df8a5566a06f5fef5100b53ea56e465a0"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.2"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.ArrayInterface]]
deps = ["ArrayInterfaceCore", "Compat", "IfElse", "LinearAlgebra", "Static"]
git-tree-sha1 = "d6173480145eb632d6571c148d94b9d3d773820e"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "6.0.23"

[[deps.ArrayInterfaceCore]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "e9f7992287edfc27b3cbe0046c544bace004ca5b"
uuid = "30b0a656-2188-435a-8636-2ec0e6a096e2"
version = "0.1.22"

[[deps.ArrayInterfaceGPUArrays]]
deps = ["Adapt", "ArrayInterfaceCore", "GPUArraysCore", "LinearAlgebra"]
git-tree-sha1 = "fc114f550b93d4c79632c2ada2924635aabfa5ed"
uuid = "6ba088a2-8465-4c0a-af30-387133b534db"
version = "0.2.2"

[[deps.ArrayInterfaceOffsetArrays]]
deps = ["ArrayInterface", "OffsetArrays", "Static"]
git-tree-sha1 = "c49f6bad95a30defff7c637731f00934c7289c50"
uuid = "015c0d05-e682-4f19-8f0a-679ce4c54826"
version = "0.1.6"

[[deps.ArrayInterfaceStaticArrays]]
deps = ["Adapt", "ArrayInterface", "ArrayInterfaceStaticArraysCore", "LinearAlgebra", "Static", "StaticArrays"]
git-tree-sha1 = "efb000a9f643f018d5154e56814e338b5746c560"
uuid = "b0d46f97-bff5-4637-a19a-dd75974142cd"
version = "0.1.4"

[[deps.ArrayInterfaceStaticArraysCore]]
deps = ["Adapt", "ArrayInterfaceCore", "LinearAlgebra", "StaticArraysCore"]
git-tree-sha1 = "93c8ba53d8d26e124a5a8d4ec914c3a16e6a0970"
uuid = "dd5226c6-a4d4-4bc7-8575-46859f9c95b9"
version = "0.1.3"

[[deps.ArrayLayouts]]
deps = ["FillArrays", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9a8017694c92ca097b23b3b43806be560af4c2ce"
uuid = "4c555306-a7a7-4459-81d9-ec55ddd5c99a"
version = "0.8.12"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.BandedMatrices]]
deps = ["ArrayLayouts", "FillArrays", "LinearAlgebra", "Random", "SparseArrays"]
git-tree-sha1 = "d37d493a1fc680257f424e656da06f4704c4444b"
uuid = "aae01518-5342-5314-be14-df237901396f"
version = "0.17.7"

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

[[deps.BitTwiddlingConvenienceFunctions]]
deps = ["Static"]
git-tree-sha1 = "eaee37f76339077f86679787a71990c4e465477f"
uuid = "62783981-4cbd-42fc-bca8-16325de8dc4b"
version = "0.1.4"

[[deps.BoundaryValueDiffEq]]
deps = ["BandedMatrices", "DiffEqBase", "FiniteDiff", "ForwardDiff", "LinearAlgebra", "NLsolve", "Reexport", "SciMLBase", "SparseArrays"]
git-tree-sha1 = "2f80b70bd3ddd9aa3ec2d77604c1121bd115650e"
uuid = "764a87c0-6b3e-53db-9096-fe964310641d"
version = "2.9.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.CPUSummary]]
deps = ["CpuId", "IfElse", "Static"]
git-tree-sha1 = "9bdd5aceea9fa109073ace6b430a24839d79315e"
uuid = "2a0fbf3d-bb9c-48f3-b0a9-814d99fd7ab9"
version = "0.1.27"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "873fb188a4b9d76549b81465b1f75c82aaf59238"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.4"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

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

[[deps.CloseOpenIntervals]]
deps = ["ArrayInterface", "Static"]
git-tree-sha1 = "5522c338564580adf5d58d91e43a55db0fa5fb39"
uuid = "fb6a15b2-703c-40df-9091-08a04967cfa9"
version = "0.1.10"

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

[[deps.CommonSolve]]
git-tree-sha1 = "332a332c97c7071600984b3c31d9067e1a4e6e25"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.1"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "fb21ddd70a051d882a1686a5a550990bbe371a95"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.4.1"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.CpuId]]
deps = ["Markdown"]
git-tree-sha1 = "fcbb72b032692610bfbdb15018ac16a36cf2e406"
uuid = "adafc99b-e345-5852-983c-f28acb93d879"
version = "0.3.1"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "46d2680e618f8abd007bce0c3026cb0c4a8f2032"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.12.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "558078b0b78278683a7445c626ee78c86b9bb000"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.1"

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

[[deps.DelayDiffEq]]
deps = ["ArrayInterface", "DataStructures", "DiffEqBase", "LinearAlgebra", "Logging", "NonlinearSolve", "OrdinaryDiffEq", "Printf", "RecursiveArrayTools", "Reexport", "SciMLBase", "UnPack"]
git-tree-sha1 = "02685529c5b22478e50c981d679f12d5e03808c6"
uuid = "bcd4f6db-9728-5f36-b5f7-82caef46ccdb"
version = "5.38.2"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.DiffEqBase]]
deps = ["ArrayInterfaceCore", "ChainRulesCore", "DataStructures", "Distributions", "DocStringExtensions", "FastBroadcast", "ForwardDiff", "FunctionWrappers", "FunctionWrappersWrappers", "LinearAlgebra", "Logging", "MuladdMacro", "NonlinearSolve", "Parameters", "Printf", "RecursiveArrayTools", "Reexport", "Requires", "SciMLBase", "Setfield", "SparseArrays", "Static", "StaticArrays", "Statistics", "Tricks", "ZygoteRules"]
git-tree-sha1 = "c272e6fb3c3558d807886d5247ed2a0b9c6f3823"
uuid = "2b5f629d-d688-5b77-993f-72d75c75574e"
version = "6.105.1"

[[deps.DiffEqCallbacks]]
deps = ["DataStructures", "DiffEqBase", "ForwardDiff", "LinearAlgebra", "Markdown", "NLsolve", "Parameters", "RecipesBase", "RecursiveArrayTools", "SciMLBase", "StaticArrays"]
git-tree-sha1 = "16cecaff5228c6cb22cda8e81aa96442395cdfc5"
uuid = "459566f4-90b8-5000-8ac3-15dfb0a30def"
version = "2.24.2"

[[deps.DiffEqNoiseProcess]]
deps = ["DiffEqBase", "Distributions", "GPUArraysCore", "LinearAlgebra", "Markdown", "Optim", "PoissonRandom", "QuadGK", "Random", "Random123", "RandomNumbers", "RecipesBase", "RecursiveArrayTools", "ResettableStacks", "SciMLBase", "StaticArrays", "Statistics"]
git-tree-sha1 = "d0762f43a0c75a0b168547f7e4cc47abf6ea6a30"
uuid = "77a26b50-5914-5dd7-bc55-306e6241c503"
version = "5.13.1"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "992a23afdb109d0d2f8802a30cf5ae4b1fe7ea68"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.11.1"

[[deps.DifferentialEquations]]
deps = ["BoundaryValueDiffEq", "DelayDiffEq", "DiffEqBase", "DiffEqCallbacks", "DiffEqNoiseProcess", "JumpProcesses", "LinearAlgebra", "LinearSolve", "OrdinaryDiffEq", "Random", "RecursiveArrayTools", "Reexport", "SciMLBase", "SteadyStateDiffEq", "StochasticDiffEq", "Sundials"]
git-tree-sha1 = "f6b75cc940e8791b5cef04d29eb88731955e759c"
uuid = "0c46a032-eb83-5123-abaf-570d42b7fbaa"
version = "7.5.0"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "04db820ebcfc1e053bd8cbb8d8bccf0ff3ead3f7"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.76"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "5158c2b41018c5f7eb1470d558127ac274eca0c9"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.ExponentialUtilities]]
deps = ["ArrayInterfaceCore", "GPUArraysCore", "GenericSchur", "LinearAlgebra", "Printf", "SparseArrays", "libblastrampoline_jll"]
git-tree-sha1 = "b19c3f5001b11b71d0f970f354677d604f3a1a97"
uuid = "d4d017d3-3776-5f7e-afef-a10c40355c18"
version = "1.19.0"

[[deps.ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

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

[[deps.FastBroadcast]]
deps = ["ArrayInterface", "ArrayInterfaceCore", "LinearAlgebra", "Polyester", "Static", "StrideArraysCore"]
git-tree-sha1 = "21cdeff41e5a1822c2acd7fc7934c5f450588e00"
uuid = "7034ab61-46d4-4ed7-9d0f-46aef9175898"
version = "0.2.1"

[[deps.FastClosures]]
git-tree-sha1 = "acebe244d53ee1b461970f8910c235b259e772ef"
uuid = "9aa1b823-49e4-5ca5-8b0f-3971ec8bab6a"
version = "0.3.2"

[[deps.FastLapackInterface]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "14a6f7a21125f715d935fe8f83560ee833f7d79d"
uuid = "29a986be-02c6-4525-aec4-84b980013641"
version = "1.2.7"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "87519eb762f85534445f5cda35be12e32759ee14"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.4"

[[deps.FiniteDiff]]
deps = ["ArrayInterfaceCore", "LinearAlgebra", "Requires", "Setfield", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "5a2cff9b6b77b33b89f3d97a4d367747adce647e"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.15.0"

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

[[deps.FunctionWrappers]]
git-tree-sha1 = "d62485945ce5ae9c0c48f124a84998d755bae00e"
uuid = "069b7b12-0de2-55c6-9aab-29f3d0a68a2e"
version = "1.1.3"

[[deps.FunctionWrappersWrappers]]
deps = ["FunctionWrappers"]
git-tree-sha1 = "a5e6e7f12607e90d71b09e6ce2c965e41b337968"
uuid = "77dc65aa-8811-40c2-897b-53d922fa7daf"
version = "0.1.1"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "6872f5ec8fd1a38880f027a26739d42dcda6691f"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.2"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "00a9d4abadc05b9476e937a5557fcce476b9e547"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.69.5"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "bc9f7725571ddb4ab2c4bc74fa397c1c5ad08943"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.69.1+0"

[[deps.GenericSchur]]
deps = ["LinearAlgebra", "Printf"]
git-tree-sha1 = "fb69b2a645fa69ba5f474af09221b9308b160ce6"
uuid = "c145ed77-6b09-5dd9-b285-bf645a82121e"
version = "0.5.3"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "fb83fbe02fe57f2c068013aa94bcdf6760d3a7a7"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+1"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "ba2d094a88b6b287bd25cfa86f301e7693ffae2f"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.7.4"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "e8c58d5f03b9d9eb9ed7067a2f34c7c371ab130b"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.4.1"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HostCPUFeatures]]
deps = ["BitTwiddlingConvenienceFunctions", "IfElse", "Libdl", "Static"]
git-tree-sha1 = "b7b88a4716ac33fe31d6556c02fc60017594343c"
uuid = "3e5b6fbb-0976-4d2c-9146-d79de83f2fb0"
version = "0.1.8"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

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

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "db619c421554e1e7e07491b85a8f4b96b3f04ca0"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "842dd89a6cb75e02e85fdd75c760cdc43f5d6863"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.6"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterativeSolvers]]
deps = ["LinearAlgebra", "Printf", "Random", "RecipesBase", "SparseArrays"]
git-tree-sha1 = "1169632f425f79429f245113b775a0e3d121457c"
uuid = "42fd0dbc-a981-5370-80f2-aaf504508153"
version = "0.9.2"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

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

[[deps.JumpProcesses]]
deps = ["ArrayInterfaceCore", "DataStructures", "DiffEqBase", "DocStringExtensions", "FunctionWrappers", "Graphs", "LinearAlgebra", "Markdown", "PoissonRandom", "Random", "RandomNumbers", "RecursiveArrayTools", "Reexport", "SciMLBase", "StaticArrays", "TreeViews", "UnPack"]
git-tree-sha1 = "5a6e6c522e8a7b39b24be8eebcc13cc7885c6f2c"
uuid = "ccbc3e58-028d-4f4c-8cd5-9ae44345cda5"
version = "9.2.0"

[[deps.KLU]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse_jll"]
git-tree-sha1 = "cae5e3dfd89b209e01bcd65b3a25e74462c67ee0"
uuid = "ef3ab10e-7fda-4108-b977-705223b18434"
version = "0.3.0"

[[deps.Krylov]]
deps = ["LinearAlgebra", "Printf", "SparseArrays"]
git-tree-sha1 = "92256444f81fb094ff5aa742ed10835a621aef75"
uuid = "ba0b0d4f-ebba-5204-a429-3ac8c609bfb7"
version = "0.8.4"

[[deps.KrylovKit]]
deps = ["LinearAlgebra", "Printf"]
git-tree-sha1 = "49b0c1dd5c292870577b8f58c51072bd558febb9"
uuid = "0b1a1467-8014-51b9-945f-bf0ae24f4b77"
version = "0.5.4"

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

[[deps.LayoutPointers]]
deps = ["ArrayInterface", "ArrayInterfaceOffsetArrays", "ArrayInterfaceStaticArrays", "LinearAlgebra", "ManualMemory", "SIMDTypes", "Static"]
git-tree-sha1 = "b67e749fb35530979839e7b4b606a97105fe4f1c"
uuid = "10f19ff3-798f-405d-979b-55457f8fc047"
version = "0.1.10"

[[deps.LevyArea]]
deps = ["LinearAlgebra", "Random", "SpecialFunctions"]
git-tree-sha1 = "56513a09b8e0ae6485f34401ea9e2f31357958ec"
uuid = "2d8b4e74-eb68-11e8-0fb9-d5eb67b50637"
version = "1.0.0"

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

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "7bbea35cec17305fc70a0e5b4641477dc0789d9d"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.2.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LinearSolve]]
deps = ["ArrayInterfaceCore", "DocStringExtensions", "FastLapackInterface", "GPUArraysCore", "IterativeSolvers", "KLU", "Krylov", "KrylovKit", "LinearAlgebra", "RecursiveFactorization", "Reexport", "SciMLBase", "Setfield", "SnoopPrecompile", "SparseArrays", "SuiteSparse", "UnPack"]
git-tree-sha1 = "d1a5a61fa3728fcf63c5798458bce6ec57129065"
uuid = "7ed4a6bd-45f5-4d41-b270-4a48e9bafcae"
version = "1.26.1"

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

[[deps.LoopVectorization]]
deps = ["ArrayInterface", "ArrayInterfaceCore", "ArrayInterfaceOffsetArrays", "ArrayInterfaceStaticArrays", "CPUSummary", "ChainRulesCore", "CloseOpenIntervals", "DocStringExtensions", "ForwardDiff", "HostCPUFeatures", "IfElse", "LayoutPointers", "LinearAlgebra", "OffsetArrays", "PolyesterWeave", "SIMDDualNumbers", "SIMDTypes", "SLEEFPirates", "SnoopPrecompile", "SpecialFunctions", "Static", "ThreadingUtilities", "UnPack", "VectorizationBase"]
git-tree-sha1 = "39af6a1e398a29f568dc9fe469f459ad3aacb03b"
uuid = "bdcacae8-1622-11e9-2a5c-532679323890"
version = "0.12.133"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "dedbebe234e06e1ddad435f5c6f4b85cd8ce55f7"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.2.2"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.ManualMemory]]
git-tree-sha1 = "bcaef4fc7a0cfe2cba636d84cda54b5e4e4ca3cd"
uuid = "d125e4d3-2237-4719-b19c-fa641b8a4667"
version = "0.1.8"

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

[[deps.MuladdMacro]]
git-tree-sha1 = "c6190f9a7fc5d9d5915ab29f2134421b12d24a68"
uuid = "46d2c3a1-f734-5fdb-9937-b9b9aeba4221"
version = "0.2.2"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "50310f934e55e5ca3912fb941dec199b49ca9b68"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.2"

[[deps.NLsolve]]
deps = ["Distances", "LineSearches", "LinearAlgebra", "NLSolversBase", "Printf", "Reexport"]
git-tree-sha1 = "019f12e9a1a7880459d0173c182e6a99365d7ac1"
uuid = "2774e3e8-f4cf-5e23-947b-6d7e65073b56"
version = "4.5.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.NonlinearSolve]]
deps = ["ArrayInterfaceCore", "FiniteDiff", "ForwardDiff", "IterativeSolvers", "LinearAlgebra", "RecursiveArrayTools", "RecursiveFactorization", "Reexport", "SciMLBase", "Setfield", "StaticArrays", "UnPack"]
git-tree-sha1 = "a754a21521c0ab48d37f44bbac1eefd1387bdcfc"
uuid = "8913a72c-1f9b-4ce2-8d82-65094dcecaec"
version = "0.3.22"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "f71d8950b724e9ff6110fc948dff5a329f901d64"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.8"

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
git-tree-sha1 = "ebe81469e9d7b471d7ddb611d9e147ea16de0add"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.2.1"

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

[[deps.Optim]]
deps = ["Compat", "FillArrays", "ForwardDiff", "LineSearches", "LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "b9fe76d1a39807fdcf790b991981a922de0c3050"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.7.3"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.OrdinaryDiffEq]]
deps = ["Adapt", "ArrayInterface", "ArrayInterfaceCore", "ArrayInterfaceGPUArrays", "ArrayInterfaceStaticArrays", "ArrayInterfaceStaticArraysCore", "DataStructures", "DiffEqBase", "DocStringExtensions", "ExponentialUtilities", "FastBroadcast", "FastClosures", "FiniteDiff", "ForwardDiff", "FunctionWrappersWrappers", "LinearAlgebra", "LinearSolve", "Logging", "LoopVectorization", "MacroTools", "MuladdMacro", "NLsolve", "NonlinearSolve", "Polyester", "PreallocationTools", "Preferences", "RecursiveArrayTools", "Reexport", "SciMLBase", "SnoopPrecompile", "SparseArrays", "SparseDiffTools", "StaticArrays", "UnPack"]
git-tree-sha1 = "787caae52aed673c126237264fda1b5d9086b87d"
uuid = "1dea7af3-3e70-54e6-95c3-0bf5283fa5ed"
version = "6.29.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

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
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "524d9ff1b2f4473fef59678c06f9f77160a204b1"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.35.3"

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
git-tree-sha1 = "6e33d318cf8843dade925e35162992145b4eb12f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.44"

[[deps.PoissonRandom]]
deps = ["Random"]
git-tree-sha1 = "9ac1bb7c15c39620685a3a7babc0651f5c64c35b"
uuid = "e409e4f3-bfea-5376-8464-e040bb5c01ab"
version = "0.4.1"

[[deps.Polyester]]
deps = ["ArrayInterface", "BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "ManualMemory", "PolyesterWeave", "Requires", "Static", "StrideArraysCore", "ThreadingUtilities"]
git-tree-sha1 = "cb2ede4b9cc432c1cba4d4452a62ae1d2a4141bb"
uuid = "f517fe37-dbe3-4b94-8317-1923a5111588"
version = "0.6.16"

[[deps.PolyesterWeave]]
deps = ["BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "Static", "ThreadingUtilities"]
git-tree-sha1 = "b42fb2292fbbaed36f25d33a15c8cc0b4f287fcf"
uuid = "1d0040c9-8b98-4ee7-8388-3f51789ca0ad"
version = "0.1.10"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

[[deps.PreallocationTools]]
deps = ["Adapt", "ArrayInterfaceCore", "ForwardDiff"]
git-tree-sha1 = "3953d18698157e1d27a51678c89c88d53e071a42"
uuid = "d236fae5-4411-538c-8e31-a6e3d9e00b46"
version = "0.4.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "460d9e154365e058c4d886f6f7d6df5ffa1ea80e"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.1.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "3c009334f45dfd546a16a57960a821a1a023d241"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.5.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Random123]]
deps = ["Random", "RandomNumbers"]
git-tree-sha1 = "7a1a306b72cfa60634f03a911405f4e64d1b718b"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.6.0"

[[deps.RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "612a4d76ad98e9722c8ba387614539155a59e30c"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.0"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "9b1c0c8e9188950e66fc28f40bfe0f8aac311fe0"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.7"

[[deps.RecursiveArrayTools]]
deps = ["Adapt", "ArrayInterfaceCore", "ArrayInterfaceStaticArraysCore", "ChainRulesCore", "DocStringExtensions", "FillArrays", "GPUArraysCore", "IteratorInterfaceExtensions", "LinearAlgebra", "RecipesBase", "StaticArraysCore", "Statistics", "Tables", "ZygoteRules"]
git-tree-sha1 = "3004608dc42101a944e44c1c68b599fa7c669080"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "2.32.0"

[[deps.RecursiveFactorization]]
deps = ["LinearAlgebra", "LoopVectorization", "Polyester", "SnoopPrecompile", "StrideArraysCore", "TriangularSolve"]
git-tree-sha1 = "0a2dfb3358fcde3676beb75405e782faa8c9aded"
uuid = "f2c3362d-daeb-58d1-803e-2bc74f2840b4"
version = "0.2.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.ResettableStacks]]
deps = ["StaticArrays"]
git-tree-sha1 = "256eeeec186fa7f26f2801732774ccf277f05db9"
uuid = "ae5879a3-cd67-5da8-be7f-38c6eb64a37b"
version = "1.1.1"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "dad726963ecea2d8a81e26286f625aee09a91b7c"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.4.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.RuntimeGeneratedFunctions]]
deps = ["ExprTools", "SHA", "Serialization"]
git-tree-sha1 = "cdc1e4278e91a6ad530770ebb327f9ed83cf10c4"
uuid = "7e49a35a-f44a-4d26-94aa-eba1b4ca6b47"
version = "0.5.3"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMDDualNumbers]]
deps = ["ForwardDiff", "IfElse", "SLEEFPirates", "VectorizationBase"]
git-tree-sha1 = "dd4195d308df24f33fb10dde7c22103ba88887fa"
uuid = "3cdde19b-5bb0-4aaf-8931-af3e248e098b"
version = "0.1.1"

[[deps.SIMDTypes]]
git-tree-sha1 = "330289636fb8107c5f32088d2741e9fd7a061a5c"
uuid = "94e857df-77ce-4151-89e5-788b33177be4"
version = "0.1.0"

[[deps.SLEEFPirates]]
deps = ["IfElse", "Static", "VectorizationBase"]
git-tree-sha1 = "938c9ecffb28338a6b8b970bda0f3806a65e7906"
uuid = "476501e8-09a2-5ece-8869-fb82de89a1fa"
version = "0.6.36"

[[deps.SciMLBase]]
deps = ["ArrayInterfaceCore", "CommonSolve", "ConstructionBase", "Distributed", "DocStringExtensions", "FunctionWrappersWrappers", "IteratorInterfaceExtensions", "LinearAlgebra", "Logging", "Markdown", "Preferences", "RecipesBase", "RecursiveArrayTools", "RuntimeGeneratedFunctions", "StaticArraysCore", "Statistics", "Tables"]
git-tree-sha1 = "e078c600cb15f9ad1a21cd58fc1c01a29aecb908"
uuid = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
version = "1.62.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "efd23b378ea5f2db53a55ae53d3133de4e080aa9"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.16"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

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

[[deps.SparseDiffTools]]
deps = ["Adapt", "ArrayInterfaceCore", "ArrayInterfaceStaticArrays", "Compat", "DataStructures", "FiniteDiff", "ForwardDiff", "Graphs", "LinearAlgebra", "Requires", "SparseArrays", "StaticArrays", "VertexSafeGraphs"]
git-tree-sha1 = "a434a4a3a5757440cb3b6500eb9690ff5a516cf6"
uuid = "47a9eef4-7e08-11e9-0b38-333d64bd3804"
version = "1.27.0"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "de4f0a4f049a4c87e4948c04acff37baf1be01a6"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.7.7"

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

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.SteadyStateDiffEq]]
deps = ["DiffEqBase", "DiffEqCallbacks", "LinearAlgebra", "NLsolve", "Reexport", "SciMLBase"]
git-tree-sha1 = "f4492f790434f405139eb3a291fdbb45997857c6"
uuid = "9672c7b4-1e72-59bd-8a11-6ac3964bc41f"
version = "1.9.0"

[[deps.StochasticDiffEq]]
deps = ["Adapt", "ArrayInterface", "DataStructures", "DiffEqBase", "DiffEqNoiseProcess", "DocStringExtensions", "FillArrays", "FiniteDiff", "ForwardDiff", "JumpProcesses", "LevyArea", "LinearAlgebra", "Logging", "MuladdMacro", "NLsolve", "OrdinaryDiffEq", "Random", "RandomNumbers", "RecursiveArrayTools", "Reexport", "SciMLBase", "SparseArrays", "SparseDiffTools", "StaticArrays", "UnPack"]
git-tree-sha1 = "8062351f645bb23725c494be74619ef802a2ffa8"
uuid = "789caeaf-c7a9-5a7d-9973-96adeb23e2a0"
version = "6.54.0"

[[deps.StrideArraysCore]]
deps = ["ArrayInterface", "CloseOpenIntervals", "IfElse", "LayoutPointers", "ManualMemory", "SIMDTypes", "Static", "ThreadingUtilities"]
git-tree-sha1 = "ac730bd978bf35f9fe45daa0bd1f51e493e97eb4"
uuid = "7792a7ef-975c-4747-a70f-980b88e8d1da"
version = "0.3.15"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+0"

[[deps.Sundials]]
deps = ["CEnum", "DataStructures", "DiffEqBase", "Libdl", "LinearAlgebra", "Logging", "Reexport", "SnoopPrecompile", "SparseArrays", "Sundials_jll"]
git-tree-sha1 = "5717b2c13ddc167d7db931bfdd1a94133ee1d4f0"
uuid = "c3572dad-4567-51f8-b174-8c6c989267f4"
version = "4.10.1"

[[deps.Sundials_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS_jll", "Pkg", "SuiteSparse_jll"]
git-tree-sha1 = "04777432d74ec5bc91ca047c9e0e0fd7f81acdb6"
uuid = "fb77eaff-e24c-56d4-86b1-d163f2edb164"
version = "5.2.1+0"

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
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

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

[[deps.ThreadingUtilities]]
deps = ["ManualMemory"]
git-tree-sha1 = "f8629df51cab659d70d2e5618a430b4d3f37f2c3"
uuid = "8290d209-cae3-49c0-8002-c8c24d57dab5"
version = "0.5.0"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.TreeViews]]
deps = ["Test"]
git-tree-sha1 = "8d0d7a3fe2f30d6a7f833a5f19f7c7a5b396eae6"
uuid = "a2a6695c-b41b-5b7d-aed9-dbfdeacea5d7"
version = "0.3.0"

[[deps.TriangularSolve]]
deps = ["CloseOpenIntervals", "IfElse", "LayoutPointers", "LinearAlgebra", "LoopVectorization", "Polyester", "SnoopPrecompile", "Static", "VectorizationBase"]
git-tree-sha1 = "fdddcf6b2c7751cd97de69c18157aacc18fbc660"
uuid = "d5829a12-d9aa-46ab-831f-fb7c9ab06edf"
version = "0.1.14"

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

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

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

[[deps.VectorizationBase]]
deps = ["ArrayInterface", "CPUSummary", "HostCPUFeatures", "IfElse", "LayoutPointers", "Libdl", "LinearAlgebra", "SIMDTypes", "Static"]
git-tree-sha1 = "3bc5ea8fbf25f233c4c49c0a75f14b276d2f9a69"
uuid = "3d5dd08c-fd9d-11e8-17fa-ed2836048c2f"
version = "0.21.51"

[[deps.VertexSafeGraphs]]
deps = ["Graphs"]
git-tree-sha1 = "8351f8d73d7e880bfc042a8b6922684ebeafb35c"
uuid = "19fa3120-7c27-5ec5-8db8-b0b0aa330d6f"
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

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

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

[[deps.ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "8c1a8e4dfacb1fd631745552c8db35d0deb09ea0"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.2"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

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
# ╠═c6bd612e-21c4-4e2d-91ac-42fe4f611364
# ╠═98f2eed8-89ad-4b5c-9fbd-790e8c322940
# ╟─3b74812e-b8d0-482e-bedf-f49c54a1b92f
# ╠═b3b707d2-4a5b-11ed-1266-97264478041b
# ╠═c41ae1ce-2e04-4936-98f0-48c95468743a
# ╟─866fddf0-7894-4688-9e58-34442fa96b23
# ╟─6f764336-6459-4df6-ae4c-839aa8dccac8
# ╟─8d740a6f-f809-4171-b4fd-615cd0faaa99
# ╟─401d487a-b297-41fd-9719-2b76cc9d1385
# ╟─fd240f6c-fee4-4300-89ae-6372e671da43
# ╟─949c2c07-8ee0-4294-8839-7353d4db213b
# ╟─41141c4e-c331-41a6-8165-3547da5e8d07
# ╟─90c072fe-8013-48f8-9a7e-4c81e2708fe3
# ╠═7cb286ce-da0c-4058-90ee-144f85b68315
# ╟─4c6877be-4fcd-4e15-b1f5-4569209a3f39
# ╠═8a04b937-c501-428c-9a08-f9b59c2066e2
# ╠═d8b330af-1991-4fb9-a8db-e833c326d173
# ╟─04ef7d70-a4a9-4d9f-add0-7b22aeb28b79
# ╠═c7677c6d-44fd-4bcc-91ef-911a8a513bb6
# ╠═dd22a20e-5db4-4a97-9572-ccc157c9d592
# ╟─23a229b1-dcf2-4803-9bd6-8df2e60ba8f5
# ╠═29550224-6f26-4e87-bfe2-e621802cc8d0
# ╟─61c97fd4-c964-4347-90ca-a7e952b02ad6
# ╟─29c9d2bc-3e90-4558-8e81-7b979be68d2b
# ╟─e831ff8c-93fc-437b-a5da-338fb37a8ac8
# ╠═f90e05ad-2c19-40dd-952e-bb9ca485aeef
# ╟─d74a5724-def9-4c87-9fee-23544dc7b745
# ╠═c03c8cc6-36d8-4102-a737-885e1a838ca2
# ╟─cb502def-3d5c-46cb-b921-549a44d4dc9c
# ╟─02656905-39a5-45ca-ab90-4450147be7e2
# ╠═74be726b-51a1-4ea3-8124-8cd3dcf3519d
# ╟─b9194069-682c-4f66-94d3-64d3c85a89cf
# ╠═8bc9e29d-873c-4866-b8ac-814bcef8da16
# ╠═8e49c403-73e2-4011-ae06-1c20a3aa9157
# ╟─0f2b0835-264d-412a-b53b-2d0d8bd987e1
# ╟─65c11552-7eee-4216-9f39-fe2a63478835
# ╟─30bad66b-0021-4bed-af8e-bbffebe2f84d
# ╠═b53f9a8a-8253-4326-ae8d-41c9c9f349c6
# ╠═d4b252e6-5be7-4b93-b678-9a60ee27e67e
# ╟─f093e439-0671-435c-bf08-4622901fc0d8
# ╟─103e3f01-14e0-440e-abde-0f464cb69055
# ╟─bf2706b0-7c2e-4829-9667-13d037a258ca
# ╟─3d5590db-de13-4b83-8925-3ea1f813a9ec
# ╠═c4447d2d-cbe8-4146-a886-b8a531445d85
# ╠═5b4e99ea-2d3d-4841-b792-7c08dea43110
# ╟─41780c0a-2fb3-4329-a24d-86e5714600b7
# ╠═c32c2e53-1689-4b9f-9e5e-4f2d7d62f43f
# ╟─b4b96d78-7f6f-4e3a-a711-51782c3a6cda
# ╠═86af8c5c-3bc8-4802-a934-22b487f74d2e
# ╟─49b09ba2-a276-430d-8cc1-74efc1a44f6f
# ╟─75e3d3ca-4705-464d-ac26-5dab7116e7cf
# ╠═e2427de0-bb05-4e97-be61-7ff5eb7bf425
# ╟─83b3f372-e366-411f-9b27-58e1d400a57d
# ╠═cb290544-fa39-4766-b332-5c4f99165d29
# ╟─164737a4-60eb-425a-b608-515067760fcb
# ╟─efaa6ba6-0ed6-4a9b-8654-77e305297885
# ╟─f1e8f11b-18e6-4d4e-9fa1-1e8dcdc16444
# ╠═ebbe26b6-66b4-4c75-8c11-d69aabda0064
# ╟─1dc083e8-be0a-4b71-b898-b0b4f6788d7d
# ╟─f8f06daa-74aa-4195-8085-23262aa822b8
# ╟─b86fbfea-d1ca-4226-8f01-3c903df66e6f
# ╠═dfd0c11e-f5bb-4cfa-ba09-71dadc7a54e7
# ╟─1822a76e-994d-482e-8b60-f07183781f8f
# ╠═d738fc0f-bb2f-437b-9040-4f5ea4867918
# ╠═608f973b-a502-4e8c-baa8-ce175c3d4688
# ╟─fcc54748-62f9-44f3-9e73-c3da9efe0dc5
# ╠═ab4a8076-21ae-4521-b18e-6cd5f05671da
# ╟─de549344-4979-425a-bc28-3572a4d9deb1
# ╠═e13edf4e-0c88-4fb6-8955-1f4099c36761
# ╟─3b4634a0-bcdf-4dff-8d3c-4fe7da7b11d4
# ╠═7c28b7f1-0fe6-4022-939c-f478a93b7dac
# ╟─51cc15b4-c9ec-458f-81d5-b4648b0dd660
# ╠═41cbc589-ab18-4bba-a374-efdc46e04b3b
# ╠═5cbe0f25-baa1-4f78-996d-fa57818448fc
# ╟─e151decd-531a-4b91-9ad1-803fe825d024
# ╠═9f725037-e90f-4c7d-b4c1-7a3f8cb51f8d
# ╟─d433526c-e6fd-4f84-a391-bba29883d893
# ╠═bbf06920-80bd-4a5d-b937-10d22abc4526
# ╠═32fb7990-93f3-4101-b056-1725a615b495
# ╟─48aee5a5-bad9-4462-a238-9666698ece3f
# ╠═f866ed9e-1a6d-4c9c-a3f6-91c8675aec21
# ╠═d84713bf-08b5-4083-98d3-dda9ecc97b00
# ╟─f1c42709-576e-4180-bb8b-a66c31f6c440
# ╟─091ab1b7-ee29-440e-80de-e87eb50739b2
# ╟─ee6e7754-6a8f-4e73-966b-2e09dba67ca3
# ╟─cf61e96a-8e3f-4655-a9aa-85c39da060a3
# ╟─aca07c02-db3a-44e4-bb33-73047f726f9d
# ╠═5ab1bea3-049e-4765-8323-f9ece4424230
# ╟─64e4786c-1f13-4cf6-a6e6-016b9d595d26
# ╟─edefd92d-4e63-4f4e-be96-ea9d6c74ab00
# ╟─0c60b420-63d5-4a33-86c2-5dd460b55caa
# ╠═0b1a6b6a-a376-4a1b-a078-11d879541902
# ╠═1b9b4c90-ec5d-4342-8451-3d19101ae942
# ╟─6a5b2f84-81eb-48fa-a61e-1f289d5a3535
# ╠═e2bcfb79-a4d5-4c3b-b77d-d2a8f3e42d71
# ╟─7404efda-a9ba-40e6-b3c8-f7733d42ad1d
# ╠═de0c1b6a-adda-45c2-b1cc-43de3abeda63
# ╟─f6f766a7-d859-420f-8c51-0ccb96df75f0
# ╠═db19c2e4-7f13-4fec-9971-82a6e0268bc3
# ╟─35ce934e-0b06-4d73-a4b1-4a7ad82f1574
# ╠═018a1a45-7ec8-4994-b2dc-c2e3d22074cc
# ╠═b14f9d57-ce80-4920-b680-7034dcd047b8
# ╠═54348524-df5b-4375-b7ec-fdb3d0126a10
# ╠═780a8a88-6fce-431d-bcb4-08b3a4ea9985
# ╠═cf10a39a-9187-4923-95ce-a9bf63833a7e
# ╠═1429926d-6f98-458d-aafe-7e40a17f17f4
# ╟─9a074f51-00b7-4d31-a885-911a17e7d4d6
# ╠═6695c9f5-d171-4079-b9c3-284d82623dbd
# ╟─261d51ea-322e-4573-a11c-5b215759fef5
# ╟─ed355794-73f4-4882-8a3c-21f65c7c1114
# ╟─39423543-2d79-4f18-b905-fb20a9a9dee1
# ╠═85e63ff9-9a91-40a8-97f1-f7f9eeca3abf
# ╠═fee314d5-75da-4aa5-8ea9-c6b03f0783c2
# ╟─fe81dc2e-1f2f-49db-97d9-0faf5c8db8fd
# ╟─d1672de6-d58e-44d3-9d12-2a59f49481a3
# ╠═846597f0-6840-4312-84a7-d877aada2589
# ╟─3fff69fd-25f4-4abf-938f-f06d02cfd83e
# ╟─0e86e043-c7b0-4015-8cb0-b9d6e1103778
# ╟─d0c9d740-253e-4a5f-9519-a4a476b22319
# ╠═c4ee99b6-dd9e-48b0-8652-8ac52f3082d3
# ╠═24a208e9-e967-4523-97e5-6202e398cdd6
# ╟─a77d1576-cd43-4de5-ad5d-e1b3698dcbc8
# ╟─c0a970a3-fd0a-4180-bfba-7537c41e4c78
# ╠═0767d676-efd0-479c-a551-10463e36b61c
# ╟─dfe05823-f0ef-4df6-9fa3-0301f4069f56
# ╟─9fbf0b87-6af8-40ce-952f-05f4d9f89b8c
# ╠═48809f4a-1ced-48e9-90cb-b1f27ff83a58
# ╠═78af5e63-0c95-49b5-9997-da5536a79897
# ╟─49ffc7b2-ffbf-4a8d-a12b-37ab558b7f1c
# ╟─f66872a9-5280-44d5-9ef9-1529135e0984
# ╠═b5470cd4-d8cc-47e5-8167-c03f0f974100
# ╟─83cc679d-514a-41de-97ce-f9181fd67c70
# ╠═320fe764-45ce-4f09-bea1-f77cccc11a9b
# ╟─702c37fc-4607-4a72-9ca3-af99d59de028
# ╟─07fa38bf-a00d-49cd-bd56-891936cda37a
# ╟─5d4b8e42-7e9d-4069-b3f6-28a4c060f117
# ╟─5308dcf7-aa8b-4b23-adec-33564d33c325
# ╟─e5a95033-c389-4023-a02c-d448f1f2bc16
# ╠═0d7426e1-620c-4096-906b-a9d1b9088740
# ╟─8e26636f-728b-43f4-9859-82a7734c95a6
# ╟─6f33f798-c0d3-46cd-9dd2-71b8a31bf617
# ╟─e25e329e-4481-4b39-b895-93c82f9ea2c3
# ╟─5f8ee73f-d729-4be2-ba20-00f8b453cdd4
# ╠═31b05bd7-34e3-4612-9734-916d5a708bc0
# ╠═f6f46184-904c-41f6-8664-2e132ea63287
# ╟─085a5767-dee5-47e2-9d7c-101c188e92cf
# ╠═b69b8ce2-ff6d-4405-b9db-f9169f5f44ae
# ╟─f0f3bfe2-dcec-40f6-87c1-a5538c354dd0
# ╟─85e93187-d7d5-4023-a243-d9b986f2e0a6
# ╟─45329aaf-8bff-4381-bf60-ec68515f5e42
# ╠═f08ae9c1-8b1b-4f49-ace3-b40b5d4f47bc
# ╠═e42ebdbe-e374-4aad-ba0f-46d3a20c3e5f
# ╟─2f2b457e-8f81-4886-8684-b80474676386
# ╠═eb0eadbe-8b13-4bd8-b65e-4966e4a85f3d
# ╟─5aa70c8a-60fe-4bfa-aa1a-68a9204be4eb
# ╟─539f779e-0d6f-45e0-8e98-a3a1f5a3b50a
# ╠═0162de19-4c4c-4aba-9d56-cd7d67e58ef6
# ╟─92cd9bc2-4757-4495-8c56-2ec5e30e9f06
# ╟─1e48645c-ffab-4120-baf8-b4dd556330aa
# ╟─21b3a806-696d-45a6-a3dd-8e17f202355e
# ╟─e9403765-d42a-40aa-8c13-5cc3fc3754b8
# ╟─b9f9f8ca-feeb-4b23-b5ee-f07204cb8daa
# ╠═8dc428d8-8dab-4143-94b3-56c7d29e95e6
# ╟─26694aa3-415a-4ae6-87a3-82a16481f15a
# ╠═4ec83bfa-6d40-4b3f-92d4-79916e9c07ed
# ╟─5d51ab5a-5cd1-4157-b210-95ad9b96412c
# ╟─4a7ce64e-fbad-497c-a7bf-42464815bfd6
# ╟─3e1ccc36-29bc-4c06-bf38-8197259fe68f
# ╟─2f9fad1c-c233-4d41-85f5-dbe76676a073
# ╟─da91aa4a-8516-4f17-9026-21fb323338eb
# ╠═d5ca36a4-3467-43e2-b8d2-f367b9d23f45
# ╠═5a0b53b1-0fc9-4fae-bc65-09dc256f4efa
# ╟─88ba3961-bc7d-4257-a1a4-7d6686e1a583
# ╟─171aecd0-76e3-4118-bb3b-ac29945ef1b7
# ╟─7b1e1d6e-8aeb-4503-a619-f69cbbde7025
# ╠═6079c292-c38b-4cb9-8e09-e6fed033c42f
# ╟─4dce1ab4-fcf4-4e91-a9f9-f15c784b2501
# ╠═67e283d3-9dd9-468f-97cd-16c0706aca00
# ╟─e232b56e-d4bd-491f-baa0-15c63a7e7c0f
# ╠═711f732d-d6eb-4128-9765-b1580e1238b4
# ╟─2426f0f6-c663-4718-8126-e76a2afce236
# ╟─097613af-c9da-4285-99f4-56ff325acbbc
# ╠═3b0e364e-e3ea-4c73-8b3a-9b4e4528d8d3
# ╠═26cf28b4-6fe9-4560-be5b-cb8fd2bba414
# ╠═a2e7dc49-151d-43fd-a2cf-17d7d83900a6
# ╟─926b3d7c-aea8-4c50-8eb5-0afc2f516af7
# ╟─14fd83e4-3ebb-4445-848d-3c864b0549fe
# ╟─e50e6d8d-9bfe-4702-ac72-89d45e6eeb84
# ╠═ab033e74-b244-445a-a9c6-fbcbd441d499
# ╟─7d0c71c3-bd47-4e43-abee-ad34db5c5f9e
# ╠═85c86abd-03bc-42c3-a6b4-22e9d5269caa
# ╟─e10b46dd-bbe1-45fb-9077-f82219e82af0
# ╟─52191ad7-195d-449d-96be-8a25cc674d87
# ╟─d49a7c24-887d-4d5d-81a8-ff0d08937189
# ╠═f8ad6892-f1f1-4231-82ed-14f4fe3878e7
# ╟─1e398d0c-4b25-4a05-abbc-2d0d6916bd77
# ╠═e018dd21-07e6-4c1d-ad04-9b45d2f991b5
# ╟─e080aa6d-2ac8-472f-b3b2-84d454cdb6c4
# ╠═1b66d8d2-f534-4f78-9640-9800eddc0e20
# ╟─9cf65bc1-872c-40c3-9448-255ebaa2b3a3
# ╟─1600e9c7-0aa7-4079-94ec-7a2a8b896d1b
# ╠═270be245-30c8-4404-ba1c-52646e98742e
# ╟─1c98ff24-681f-4c76-ba8a-b89e82eb41e3
# ╟─b5726056-d2a8-46f3-bf0f-a5959da92c6d
# ╟─a21dcf25-9321-439c-9e3d-6fcc6fc6909b
# ╟─d5f81c9e-930e-4272-8e95-48e2de5f255a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
