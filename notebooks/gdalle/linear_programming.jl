### A Pluto.jl notebook ###
# v0.19.16

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

# ╔═╡ 7b87b7c8-6442-11ed-371a-87f5a11b2fab
begin
	using HiGHS
	using JuMP
	using LaTeXStrings
	using LinearAlgebra
	using Plots
	using PlutoTeachingTools
	using PlutoUI
	using Polyhedra
end

# ╔═╡ 4249a0c2-a780-4422-9e9b-b6799dd8efa5
TableOfContents()

# ╔═╡ bea5deba-2a27-4a69-aaf8-400c4dc04675
html"<button onclick=present()>Present</button>"

# ╔═╡ c61fcac0-ad63-49b6-8abd-dd274dbda898
md"""
# Linear Programming
"""

# ╔═╡ 6821789e-761c-4a19-bbb2-42afd0456bc5
md"""
In this notebook, we present an optimization framework which encompasses numerous questions of huge practical interest.
We also demonstrate the use of [JuMP.jl](https://github.com/jump-dev/JuMP.jl) to model and solve such optimization problems.
"""

# ╔═╡ 7335dcd2-bbef-464f-b88a-ad7d2a3c01da
md"""
# 1. Problem zoo
"""

# ╔═╡ 9e8cb5f5-6def-40db-bfd8-7e4693fcce25
md"""
## Optimization vocabulary
"""

# ╔═╡ 9cbf2977-a5de-4e4a-b5c8-1e9e1c156704
md"""
An optimization problem is formulated as
```math
\min_x ~ f(x) \quad \text{s.t.} \quad x \in \mathcal{X} \tag{P}
```
- "s.t." means "subject to"
- ``x`` is the decision variable
- ``\mathcal{X}`` is the set of feasible solutions
- ``x \in \mathcal{X}`` is the constraint
- ``f(x)`` is the objective / cost function
"""

# ╔═╡ cf5e0bb0-46ab-4d62-b30a-3a1c6b110924
md"""
Solving the problem means finding

- the optimal value $\mathrm{val}(P)$
- an optimal solution $x^* \in \mathrm{argmin}\{f(x): x \in \mathcal{X}\}$

Instance of a problem = one particular input with its numerical values.
"""

# ╔═╡ eafd6112-50e1-41ca-a8ef-d70ff9b923a4
md"""
## Formulating optimization problems
"""

# ╔═╡ d8ddc081-595f-4ffe-8a79-1aca945fe14e
md"""
**Knapsack**
"""

# ╔═╡ 1be613ed-6dbf-4a1f-969c-b18317918cd9
md"""
**Bin packing**
"""

# ╔═╡ 7acb80e5-52ce-4f4a-8f25-eab05a6bce3f
md"""
**Coloring**
"""

# ╔═╡ fdeccf04-b336-481e-bde3-c29138f1f824
md"""
**Shortest path**
"""

# ╔═╡ da436d05-8ba3-410e-a00b-5dbf29795771
md"""
**Network flow**
"""

# ╔═╡ b408eed8-0533-4e68-82c9-9c037a840b4b
md"""
**Quadratic assignment**
"""

# ╔═╡ 5423ae84-54f7-4685-b130-08cb938c3e56
md"""
# 2. Theoretical background
"""

# ╔═╡ 560d047c-ae49-43ba-bd82-7bb9cc4504c9
md"""
## Polyhedra
"""

# ╔═╡ 67dacadf-59be-46bf-9ab0-86f2e193e11e
md"""
A polyhedron $\mathcal{P} = \{x \in \mathbb{R}^d: Ax \leq b\}$ is a finite intersection of closed half-spaces:
```math
\mathcal{P} = \bigcap_{i \in [m]} \{x \in \mathbb{R}^d: a_i x \leq b_i\}
```
"""

# ╔═╡ 8e163dba-4b0f-4509-b9af-fe603b3bf639
begin
	m_choice = md"""
	m = $(@bind m Slider(1:20, default=10, show_value=true))
	"""
	legend_choice = md"""
	legend = $(@bind display_legend CheckBox(true))
	"""
	TwoColumn(m_choice, legend_choice)
end

# ╔═╡ 4985e6b2-5def-416e-8616-87e7052834ee
random_A, random_b = randn(m, 2), ones(m);

# ╔═╡ 471d1b01-8bb7-4b4e-aab0-a4b2726c9bf6
let
	half_spaces = [HalfSpace(Vector(aᵢ), bᵢ) for (aᵢ, bᵢ) in zip(eachrow(random_A), random_b)];
	P = polyhedron(intersect(half_spaces...));
	square = polyhedron(convexhull([-2., -2.], [-2., 2.], [2., -2], [2., 2.]))
	plot(xlim=(-2, 2), ylim=(-2, 2), aspect_ratio=:equal,)
	plot!(Float64[], Float64[], color=:blue, label="hyperplanes")
	for (aᵢ, bᵢ) in zip(eachrow(random_A), random_b)
		plot!(
			[-2, 2],
			[-2aᵢ[1]-bᵢ, 2aᵢ[1]-bᵢ] ./ (-aᵢ[2]),
			color=:blue, label=nothing
		)
	end
	plot!(intersect(P, square), ratio=:equal, color=:blue, alpha=0.3, label="polyhedron")
	plot!(title="Intersection of $m half-spaces", legend=display_legend)
end

# ╔═╡ f18f72d7-79c8-41ac-ba54-db0021773d70
md"""
The Minkowski-Weyl theorem gives another possible representation of a polyhedron: every bounded polyhedron can be expressed as the convex hull of its extreme points, or vertices.
"""

# ╔═╡ 009fd841-932f-4c13-853b-577c04d462c2
begin
	n_choice = md"""
	``n = `` $(@bind n Slider(1:20, default=10, show_value=true))
	"""
	TwoColumn(n_choice, legend_choice)
end

# ╔═╡ 520dabd5-edef-4356-b0c3-0809dcbfe32c
random_points = [randn(2) for k = 1:n];

# ╔═╡ 5d7d7a26-1ac6-460d-84c7-423d828c8640
let
	P = polyhedron(convexhull(random_points...));
	removevredundancy!(P)
	plot(aspect_ratio=:equal)
	scatter!(
		first.(random_points),
		last.(random_points),
		ratio=:equal, color=:blue, label="points"
	)
	plot!(P, color=:blue, alpha=0.3, label="polyhedron")
	plot!(title="Convex hull of $n points", legend=display_legend)
end

# ╔═╡ 911e5476-c6a6-4b9c-887f-cfc86a790c06
md"""
The second representation is more informative, but unfortunately the number of vertices grows exponentially with the dimension.
"""

# ╔═╡ d8c97227-d897-4b35-83a4-04befa9a9200
md"""
``d = `` $(@bind nb_dimensions Slider(1:10, default=2, show_value=true))
"""

# ╔═╡ c0f3355a-b68f-448d-b885-04ba6f9cba06
let
	a_vals, b_vals = [randn(nb_dimensions) for k = 1:20], ones(20)
	half_spaces = [HalfSpace(a, b) for (a, b) in zip(a_vals, b_vals)];
	P = polyhedron(intersect(half_spaces...));
	md"""
	A random polyhedron with 20 constraints in **dimension $nb_dimensions** has **$(npoints(P)) vertices**.
	"""
end

# ╔═╡ 4d6745e1-f61d-4ffe-b637-4cf1e9055ef0
md"""
## Linear Programs
"""

# ╔═╡ 588c18f2-ee3b-495d-b71c-d9987fcf286f
md"""
The optimization problem $(\mathrm{P})$ is called a Linear Program (LP) if:
1. The objective $f(x) = c^\top x$ is linear
2. The feasible set $\mathcal{X} = \{x \in \mathbb{R}^d: Ax \leq b\}$ is a _polyhedron_
"""

# ╔═╡ b6eb9f03-d9df-40d2-8dd4-b6818bfcd18f
md"""
### The simplex algorithm
"""

# ╔═╡ 0cc01ce5-3f94-4bc0-9c21-0b78a189d584
md"""
If an LP has an optimal solution, then at least one of the vertices of the polyhedron is also an optimal solution.
"""

# ╔═╡ 18785e7c-79a9-4b2d-914a-f88f93c3e096
TwoColumn(n_choice, legend_choice)

# ╔═╡ 2e0a8059-5021-48e5-91bc-1061ac4692dd
theta_choice = md"""
``\theta = `` $(@bind angle Slider(0:360, default=180, show_value=true))
"""

# ╔═╡ 6719c6a0-a12b-481a-8698-561d73d5a80d
let
	plot(aspect_ratio=:equal)
	
	P = polyhedron(convexhull(random_points...));
	removevredundancy!(P)
	plot!(P, ratio=:equal, color=:blue, alpha=0.3, label="polyhedron")
	
	c = 0.5 * [cosd(angle), sind(angle)]
	plot!([0, c[1]], [0, c[2]], color=:black, lw=2, arrow=true, label=L"objective $-c$")

	real_vertices = collect(points(P))
	scatter!(
		first.(real_vertices),
		last.(real_vertices),
		ratio=:equal, color=:blue, label="vertices"
	)

	optimum = real_vertices[argmax([dot(c, cand) for cand in real_vertices])]
	scatter!(
		[optimum[1]], [optimum[2]],
		color=:red, markershape=:square, markersize=5, label="optimum"
	)
	
	plot!(title="Solving a Linear Program", legend=display_legend)
end

# ╔═╡ c52707fa-e636-42eb-8374-184783afb310
md"""
The [simplex algorithm](https://en.wikipedia.org/wiki/Simplex_algorithm) for LPs jumps between neighboring polyhedron vertices until the objective can no longer be improved.
Although its worst-case complexity is exponential, it is extremely fast on average.

[Interior point methods](https://en.wikipedia.org/wiki/Interior-point_method) are another class of algorithm for LPs with polynomial worst-case complexity.
In other words, LPs are easy to solve both in theory and in practice.
"""

# ╔═╡ 3e1520af-f119-4620-8d28-baa29cc88c6a
md"""
## Integer Linear Programs
"""

# ╔═╡ ddc30da9-2b66-4c66-b32c-f6513134199f
md"""
The optimization problem $(\mathrm{P})$ is called an Integer Linear Program (ILP) if:
1. The objective $f(x) = c^\top x$ is linear
2. The feasible set $\mathcal{X} = \{x \in \mathbb{Z}^d: Ax \leq b\}$ is the intersection of a polyhedron with the integer lattice
"""

# ╔═╡ f0bdf06d-41bc-4d60-b773-c6de357dd025
TwoColumn(n_choice, legend_choice)

# ╔═╡ 8032f005-c043-4180-ab58-78e7df9fc85a
begin
	scale_choice = md"""
	scale = $(@bind scale Slider(1:6; default=3, show_value=true))
	"""
	TwoColumn(theta_choice, scale_choice)
end

# ╔═╡ 20941d80-614a-40e9-9a90-7931fc076d49
let
	plot(aspect_ratio=:equal)
	
	P = polyhedron(convexhull(scale .* random_points...));
	removevredundancy!(P)
	plot!(P, color=:blue, alpha=0.3, label="polyhedron")

	real_vertices = collect(points(P))

	xmin = minimum(first, real_vertices)
	xmax = maximum(first, real_vertices)
	ymin = minimum(last, real_vertices)
	ymax = maximum(last, real_vertices)
	
	c = 0.5 * scale * [cosd(angle), sind(angle)]
	plot!([0., c[1]], [0., c[2]], color=:black, lw=2, arrow=true, label=L"objective $-c$")

	integer_points = Vector{Float64}[]
	for x in floor(Int, xmin):ceil(Int, xmax)
		for y in floor(Int, ymin):ceil(Int, ymax)
			point = [x, y]
			if point in P
				push!(integer_points, point)
			end
		end
	end

	scatter!(
		first.(integer_points),
		last.(integer_points),
		ratio=:equal, color=:blue, label="integer points"
	)
	
	optimum = integer_points[argmax([dot(c, cand) for cand in integer_points])]
	scatter!(
		[optimum[1]], [optimum[2]],
		color=:red, markershape=:square, markersize=5, label="optimum"
	)
	
	plot!(title="Solving an Integer Linear Program", legend=display_legend)
end

# ╔═╡ 9545e44c-3451-4b98-98fa-22621ab04974
md"""
Unlike LPs, ILPs are not easy to solve in theory: they are NP-hard, which means it is likely that no polynomial algorithm exists.
"""

# ╔═╡ 2860aec8-77a9-4f50-bb66-88f54615fb63
md"""
### The notion of relaxation
"""

# ╔═╡ 5da62499-8f00-4424-9fde-e260b551291c
md"""
To every ILP
```math
\min_x c^\top x \quad \text{s.t.} \quad x \in \mathbb{Z}^d \text{ and } Ax \leq b \tag{ILP}
```
we can associate a continuous relaxation
```math
\min_x c^\top x \quad \text{s.t.} \quad x \in \mathbb{R}^d \text{ and } Ax \leq b \tag{LP}
```
where the integrality constraints are removed.
It is much faster to solve and provides a lower bound on the value of the original problem:
```math
\mathrm{val}(\mathrm{LP}) \leq \mathrm{val}(\mathrm{ILP})
```
"""

# ╔═╡ ad833a42-52ca-4c7a-a79b-a80aac1c4fd1
md"""
### The Branch & Bound algorithm
"""

# ╔═╡ 9337cc5c-47b2-4429-928c-adc74997aacc
md"""
The [Branch & Bound](https://en.wikipedia.org/wiki/Branch_and_bound) algorithm for ILPs enumerates integer solutions during an arborescent search.
To avoid exploring the full tree, it splits the initial polyhedron into smaller ones, using continuous relaxations to compute bounds and prune useless branches.
Its success depends heavily on the quality of the relaxation (how close it is to the original problem).
"""

# ╔═╡ 3b7279a2-fedb-40f4-88de-360d9ba762ec
md"""
### Total unimodularity
"""

# ╔═╡ d1e89f1c-b76e-4443-876c-4fd162677125
md"""
For some problem structures, it just happens that the polyhedron vertices all have integer components.
In that case, the ILP and its continuous relaxations are equivalent, which is very good news in terms of complexity.
No need to use Branch & Bound, a simplex will be enough!

A sufficient condition for this to happen is [total unimodularity](https://en.wikipedia.org/wiki/Unimodular_matrix#Total_unimodularity) of the constraint matrix $A$.
The following types of constraints display this kind of behavior:
- shortest path
- network flow
- matching
- spanning tree
"""

# ╔═╡ 7433d1d8-3c9b-44b8-9d78-4392ea08739f
md"""
## Key takeaways

!!! danger "In theory"
	- Linear Programs are easy to solve
	- Most Integer Linear Programs are hard to solve
	- Some ILPs are easy to solve thanks to special structure
"""

# ╔═╡ ebb7978d-7e5c-4692-99c1-2df75c8cc301
md"""
!!! info "In practice"
	- Commercial solvers can tackle very large ILPs, out of the box or with some additional work by the user (e.g. decomposition methods).
	- Oftentimes an approximate solution (e.g. from a heuristic) is more than enough
"""

# ╔═╡ 1bfb3dd8-4a50-4a89-b9bc-19126de7f095
md"""
# 3. The JuMP.jl ecosystem
"""

# ╔═╡ 79e62b31-920a-4e3b-af2c-acdf0919a569
md"""
JuMP.jl is a modeling language that provides a common interface to many different mathematical optimization solvers.
It helps you write models easily by providing a syntax that is close to the mathematical formulation but standard enough for solvers to use it.
The package [documentation](https://jump.dev/) is a very useful read.
"""

# ╔═╡ 7b16eb29-0034-47d9-a5d0-30de5943fbeb
md"""
## A simple example
"""

# ╔═╡ a54b93ca-48f1-49b2-af34-a1d8d7f7c415
md"""
To tackle an (I)LP using JuMP.jl, we first have to initialize the model and define which solver will be used.
We then add variables, constraints and an objective (in any order).

Since this is Pluto, we need to create and modify the model in a single cell to avoid confusing its cell dependency tracker.
"""

# ╔═╡ 0afb035d-da9b-4d36-a7db-bedd10a3dbbb
integer_variables_choice = md"""
integer variables = $(@bind integer_variables CheckBox())
"""

# ╔═╡ f66442b9-18da-4917-8536-8403f13d8b59
simple_model = let
	model = Model()

	@variable(model, x >= 0)
	@variable(model, y >= 0)
	
	@constraint(model, -x + y <= 2)
	@constraint(model, 8x + 2y <= 17)
	
	@objective(model, Max, 5.5x + 2.1y)

	if integer_variables
		set_integer(x)
		set_integer(y)
	end

	set_optimizer(model, HiGHS.Optimizer)
	set_silent(model)
	optimize!(model)

	model
end;

# ╔═╡ 8b3bcac2-7942-4749-9dd2-d930687cf407
simple_model

# ╔═╡ dddb8989-7e6b-4e3c-9748-604034d26409
Print(simple_model)

# ╔═╡ 5f29131d-ba5e-4bbd-af6e-e02eab7f39c4
termination_status(simple_model)

# ╔═╡ 4a5dad31-466a-4ec6-a2e9-e81f2471aa26
value(simple_model[:x]), value(simple_model[:y])

# ╔═╡ 4f897915-9045-42f3-bbc7-44efbf5d5522
integer_variables_choice

# ╔═╡ 3092ff36-abc2-4702-8977-06ec23565a44
let
	plot(
		polyhedron(simple_model),
		aspect_ratio=:equal,
		color=:blue, alpha=0.3, label="feasible set"
	)
	plot!(
		0.2 .* [0, objective_function(simple_model).terms[simple_model[:x]]],
		0.2 .* [0, objective_function(simple_model).terms[simple_model[:y]]],
		arrow=true, color=:black, lw=2, label=L"objective $c$"
	)
	scatter!(
		[value(simple_model[:x])], 
		[value(simple_model[:y])],
		color=:red, markershape=:square, markersize=5, label="optimum"
	)
	plot!(title="Plotting a JuMP model and its solution", legend=:topleft)
end

# ╔═╡ b4082060-e48c-49e4-bf42-8f1d3664afd0
md"""
## The role of macros
"""

# ╔═╡ 968401ab-7763-4dd0-b45b-1ec916ba2b13
md"""
In the model above, variables, constraints and objectives are added with macros.
This is an illustration of [metaprogramming](https://docs.julialang.org/en/v1/manual/metaprogramming/): using Julia to interact with your code itself.
This [tutorial](https://en.wikibooks.org/wiki/Introducing_Julia/Metaprogramming) is perhaps clearer than the official docs.
"""

# ╔═╡ ff17fdb2-da29-48dc-9ca3-02d87d7053cb
md"""
### Looking under the hood
"""

# ╔═╡ e0477bbd-c279-4fb9-8420-df4c9a7e74df
md"""
You have already encountered macros before.
Let's take a look at what they do with `@macroexpand`.
"""

# ╔═╡ b42c5e0d-b5f4-4687-8bc8-8a3777a645be
@assert 1 == 1

# ╔═╡ e937dfae-9506-4684-b3fa-f621a2d72afd
@macroexpand @assert 1 == 1

# ╔═╡ 1c752a29-c431-4c8f-bafe-a091008e8f40
@show exp(1)

# ╔═╡ 6f4b8552-9f61-4156-838a-053b53d87725
@macroexpand @show exp(1)

# ╔═╡ 5b412b36-ff71-4789-b7aa-402581838b92
@elapsed exp(1)

# ╔═╡ fffb66f7-e917-4747-abcc-9f02a9a98e6d
@macroexpand @elapsed exp(1)

# ╔═╡ a8f80d4f-428f-4a37-97bb-0b0d78afad27
md"""
### Expressions
"""

# ╔═╡ 06592404-aa03-411f-98f9-c9d4ec521063
md"""
Expressions are an intermediate representation of Julia syntax that is parsed but not executed.
An expression can be created with `:(...)` or with `quote; ...; end`. 
"""

# ╔═╡ 20d68b54-5c6d-4ba3-bd2a-1b71c4c31b66
let
	ex = :(1 + 2)
	ex, eval(ex)
end

# ╔═╡ af560292-243e-4bea-907d-e8bb4658093b
md"""
Julia expressions are stored as trees.
"""

# ╔═╡ 6e84c401-2c73-4193-ae2f-27a6530a6aca
let
	ex = :(a * b + c / d)
	dump(ex)
end

# ╔═╡ 14314c03-3fd7-40bf-9f5e-8c2c640628ee
md"""
### Why macros?
"""

# ╔═╡ 99f141e0-6eec-48b9-9bff-f55a5c77b3d7
md"""
Macros are nothing but functions that take arguments and generate expressions based on them.
They are necessary because their output is generated before runtime, which gives it the same status as run of the mill code that you could write.

In the case of JuMP.jl, macros save the user a lot of boilerplate. 
"""

# ╔═╡ 76a742b0-842f-441a-bb42-6fbc3f5488d2
let
	model = Model()
	@macroexpand @variable(model, x)
end

# ╔═╡ 67337333-4ac9-4708-bf61-80b9fee557d2
let
	model = Model()
	@variable(model, x)
	@macroexpand @constraint(model, x >= 0)
end

# ╔═╡ 47be698b-c86b-4997-9ce7-8fdec47d49f7
md"""
But in general macros make it possible to do things that would be impossible with plain functions.
For instance, `@show` displays both the expression and the result of evaluating it, which requires interacting with the code itself (a function cannot do that).
"""

# ╔═╡ 65f2cdb7-80ff-43cf-82cb-9106d26627b1
md"""
## A more advanced example
"""

# ╔═╡ a7e23cfe-5604-4b29-ac5f-0f8ca750e34b
md"""
### Network flow with JuMP.jl and Graphs.jl
"""

# ╔═╡ 415c49e2-b972-4764-a24b-87856cdf3a6b
md"""
See [GraphsOptim.jl](https://github.com/gdalle/GraphsOptim.jl).
"""

# ╔═╡ 4f12214b-25ff-4947-ba1e-75b768c73c0d
md"""
### The flow polytope
"""

# ╔═╡ e97e0b7e-d95d-430d-b0bb-8fda6b0dcc90
md"""
# References

- Boyd, S. and Vandenberghe, L. (2004), *[Convex optimization](https://web.stanford.edu/~boyd/cvxbook/bv_cvxbook.pdf)*
- Matousek, I. and Gärtner, B. (2007), *[Understanding and using Linear Programming](https://blogs.epfl.ch/extrema/documents/Maison%2020.05.10.pdf)*
- Williams, H. P. (2013), *[Model building in mathematical programming](https://www.researchgate.net/file.PostFileLoader.html?id=546b5d0bd685cc9e2b8b45d4&assetKey=AS:273636437495809@1442251418466)*
- Conforti, M., Cornuéjols, G. and Zambelli, G. (2014), *[Integer programming](https://solab.kaist.ac.kr/files/IP/IP2017/2014_Integer%20Prog_Conforti-Cornuejols-Zambelli.pdf)*
- Kochenderfer, M. J. and Wheeler, T. A. (2019), *[Algorithms for optimization](https://algorithmsbook.com/optimization/)*
- Kochenderfer, M. J., Wheeler, T. A. and Wray, K. H. (2022), *[Algorithms for decision-making](https://algorithmsbook.com/)*
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HiGHS = "87dc4568-4c63-4d18-b0c0-bb2238e4078b"
JuMP = "4076af6c-e467-56ae-b986-b466b2749572"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Polyhedra = "67491407-f73d-577b-9b50-8179a7c68029"

[compat]
HiGHS = "~1.2.0"
JuMP = "~1.4.0"
LaTeXStrings = "~1.3.0"
Plots = "~1.36.1"
PlutoTeachingTools = "~0.2.5"
PlutoUI = "~0.7.48"
Polyhedra = "~0.7.5"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "1436da2614f78dc0d3475123a6ef51084c5bb010"

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
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.BitFlags]]
git-tree-sha1 = "629c6e4a7be8f427d268cebef2a5e3de6c50d462"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.6"

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

[[deps.CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "2e62a725210ce3c3c2e1a3080190e7ca491f18d7"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.7.2"

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
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

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
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "c5b6685d53f933c11404a3ae9822afe30d522494"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.12.2"

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

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

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
git-tree-sha1 = "10fa12fe96e4d76acfa738f4df2126589a67374f"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.33"

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
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "00a9d4abadc05b9476e937a5557fcce476b9e547"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.69.5"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "bc9f7725571ddb4ab2c4bc74fa397c1c5ad08943"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.69.1+0"

[[deps.GenericLinearAlgebra]]
deps = ["LinearAlgebra", "Printf", "Random", "libblastrampoline_jll"]
git-tree-sha1 = "3d58ea2e65e2b3b284e722a5131e4434ca10fa69"
uuid = "14197337-ba66-59df-a3e3-ca00e7dcff7a"
version = "0.3.4"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "fb28b5dc239d0174d7297310ef7b84a11804dfab"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.0.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "12a584db96f1d460421d5fb8860822971cdb8455"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.4"

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

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "8c7e6b82abd41364b8ffe40ffc63b33e590c8722"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.5.3"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HiGHS]]
deps = ["HiGHS_jll", "MathOptInterface", "SparseArrays"]
git-tree-sha1 = "d40a9e8db6438481915261a378fc2c8ca70bb63a"
uuid = "87dc4568-4c63-4d18-b0c0-bb2238e4078b"
version = "1.2.0"

[[deps.HiGHS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3e24275666fcc2e24d1a58a9f02acd9d2e23d3a"
uuid = "8fd58aa0-07eb-5a78-9b36-339c94fd15ea"
version = "1.3.0+0"

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
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

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

[[deps.JuMP]]
deps = ["LinearAlgebra", "MathOptInterface", "MutableArithmetics", "OrderedCollections", "Printf", "SparseArrays"]
git-tree-sha1 = "9a57156b97ed7821493c9c0a65f5b72710b38cf7"
uuid = "4076af6c-e467-56ae-b986-b466b2749572"
version = "1.4.0"

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

[[deps.MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "DataStructures", "ForwardDiff", "JSON", "LinearAlgebra", "MutableArithmetics", "NaNMath", "OrderedCollections", "Printf", "SparseArrays", "SpecialFunctions", "Test", "Unicode"]
git-tree-sha1 = "ceed48edffe0325a6e9ea00ecf3607af5089c413"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "1.9.0"

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
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "1d57a7dc42d563ad6b5e95d7a8aebd550e5162c0"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.0.5"

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
git-tree-sha1 = "5628f092c6186a80484bfefdf89ff64efdaec552"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

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

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "cceb0257b662528ecdf0b4b4302eb00e767b38e7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.0"

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
git-tree-sha1 = "47e70b391ff314cc36e7c2400f7d2c5455dc9496"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.36.1"

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
git-tree-sha1 = "ea3e4ac2e49e3438815f8946fa7673b658e35bdb"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.5"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.Polyhedra]]
deps = ["GenericLinearAlgebra", "GeometryBasics", "JuMP", "LinearAlgebra", "MutableArithmetics", "RecipesBase", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "d6aaf7dd794fdcd7896cfc98301f6ffe84a99f56"
uuid = "67491407-f73d-577b-9b50-8179a7c68029"
version = "0.7.5"

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

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "d12e612bba40d189cead6ff857ddb67bd2e6a387"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "a030182cccc5c461386c6f055c36ab8449ef1340"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.10"

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
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

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

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArraysCore", "Tables"]
git-tree-sha1 = "13237798b407150a6d2e2bce5d793d7d9576e99e"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.13"

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
# ╠═7b87b7c8-6442-11ed-371a-87f5a11b2fab
# ╠═4249a0c2-a780-4422-9e9b-b6799dd8efa5
# ╟─bea5deba-2a27-4a69-aaf8-400c4dc04675
# ╟─c61fcac0-ad63-49b6-8abd-dd274dbda898
# ╟─6821789e-761c-4a19-bbb2-42afd0456bc5
# ╟─7335dcd2-bbef-464f-b88a-ad7d2a3c01da
# ╟─9e8cb5f5-6def-40db-bfd8-7e4693fcce25
# ╟─9cbf2977-a5de-4e4a-b5c8-1e9e1c156704
# ╟─cf5e0bb0-46ab-4d62-b30a-3a1c6b110924
# ╟─eafd6112-50e1-41ca-a8ef-d70ff9b923a4
# ╟─d8ddc081-595f-4ffe-8a79-1aca945fe14e
# ╟─1be613ed-6dbf-4a1f-969c-b18317918cd9
# ╟─7acb80e5-52ce-4f4a-8f25-eab05a6bce3f
# ╟─fdeccf04-b336-481e-bde3-c29138f1f824
# ╟─da436d05-8ba3-410e-a00b-5dbf29795771
# ╟─b408eed8-0533-4e68-82c9-9c037a840b4b
# ╟─5423ae84-54f7-4685-b130-08cb938c3e56
# ╟─560d047c-ae49-43ba-bd82-7bb9cc4504c9
# ╟─67dacadf-59be-46bf-9ab0-86f2e193e11e
# ╟─8e163dba-4b0f-4509-b9af-fe603b3bf639
# ╠═4985e6b2-5def-416e-8616-87e7052834ee
# ╟─471d1b01-8bb7-4b4e-aab0-a4b2726c9bf6
# ╟─f18f72d7-79c8-41ac-ba54-db0021773d70
# ╟─009fd841-932f-4c13-853b-577c04d462c2
# ╠═520dabd5-edef-4356-b0c3-0809dcbfe32c
# ╟─5d7d7a26-1ac6-460d-84c7-423d828c8640
# ╟─911e5476-c6a6-4b9c-887f-cfc86a790c06
# ╟─d8c97227-d897-4b35-83a4-04befa9a9200
# ╟─c0f3355a-b68f-448d-b885-04ba6f9cba06
# ╟─4d6745e1-f61d-4ffe-b637-4cf1e9055ef0
# ╟─588c18f2-ee3b-495d-b71c-d9987fcf286f
# ╟─b6eb9f03-d9df-40d2-8dd4-b6818bfcd18f
# ╟─0cc01ce5-3f94-4bc0-9c21-0b78a189d584
# ╟─18785e7c-79a9-4b2d-914a-f88f93c3e096
# ╟─2e0a8059-5021-48e5-91bc-1061ac4692dd
# ╟─6719c6a0-a12b-481a-8698-561d73d5a80d
# ╟─c52707fa-e636-42eb-8374-184783afb310
# ╟─3e1520af-f119-4620-8d28-baa29cc88c6a
# ╟─ddc30da9-2b66-4c66-b32c-f6513134199f
# ╟─f0bdf06d-41bc-4d60-b773-c6de357dd025
# ╟─8032f005-c043-4180-ab58-78e7df9fc85a
# ╟─20941d80-614a-40e9-9a90-7931fc076d49
# ╟─9545e44c-3451-4b98-98fa-22621ab04974
# ╟─2860aec8-77a9-4f50-bb66-88f54615fb63
# ╟─5da62499-8f00-4424-9fde-e260b551291c
# ╟─ad833a42-52ca-4c7a-a79b-a80aac1c4fd1
# ╟─9337cc5c-47b2-4429-928c-adc74997aacc
# ╟─3b7279a2-fedb-40f4-88de-360d9ba762ec
# ╟─d1e89f1c-b76e-4443-876c-4fd162677125
# ╟─7433d1d8-3c9b-44b8-9d78-4392ea08739f
# ╟─ebb7978d-7e5c-4692-99c1-2df75c8cc301
# ╟─1bfb3dd8-4a50-4a89-b9bc-19126de7f095
# ╟─79e62b31-920a-4e3b-af2c-acdf0919a569
# ╟─7b16eb29-0034-47d9-a5d0-30de5943fbeb
# ╟─a54b93ca-48f1-49b2-af34-a1d8d7f7c415
# ╟─0afb035d-da9b-4d36-a7db-bedd10a3dbbb
# ╠═f66442b9-18da-4917-8536-8403f13d8b59
# ╠═8b3bcac2-7942-4749-9dd2-d930687cf407
# ╠═dddb8989-7e6b-4e3c-9748-604034d26409
# ╠═5f29131d-ba5e-4bbd-af6e-e02eab7f39c4
# ╠═4a5dad31-466a-4ec6-a2e9-e81f2471aa26
# ╟─4f897915-9045-42f3-bbc7-44efbf5d5522
# ╟─3092ff36-abc2-4702-8977-06ec23565a44
# ╟─b4082060-e48c-49e4-bf42-8f1d3664afd0
# ╟─968401ab-7763-4dd0-b45b-1ec916ba2b13
# ╟─ff17fdb2-da29-48dc-9ca3-02d87d7053cb
# ╟─e0477bbd-c279-4fb9-8420-df4c9a7e74df
# ╠═b42c5e0d-b5f4-4687-8bc8-8a3777a645be
# ╠═e937dfae-9506-4684-b3fa-f621a2d72afd
# ╠═1c752a29-c431-4c8f-bafe-a091008e8f40
# ╠═6f4b8552-9f61-4156-838a-053b53d87725
# ╠═5b412b36-ff71-4789-b7aa-402581838b92
# ╠═fffb66f7-e917-4747-abcc-9f02a9a98e6d
# ╟─a8f80d4f-428f-4a37-97bb-0b0d78afad27
# ╟─06592404-aa03-411f-98f9-c9d4ec521063
# ╠═20d68b54-5c6d-4ba3-bd2a-1b71c4c31b66
# ╟─af560292-243e-4bea-907d-e8bb4658093b
# ╠═6e84c401-2c73-4193-ae2f-27a6530a6aca
# ╟─14314c03-3fd7-40bf-9f5e-8c2c640628ee
# ╟─99f141e0-6eec-48b9-9bff-f55a5c77b3d7
# ╠═76a742b0-842f-441a-bb42-6fbc3f5488d2
# ╠═67337333-4ac9-4708-bf61-80b9fee557d2
# ╟─47be698b-c86b-4997-9ce7-8fdec47d49f7
# ╟─65f2cdb7-80ff-43cf-82cb-9106d26627b1
# ╟─a7e23cfe-5604-4b29-ac5f-0f8ca750e34b
# ╟─415c49e2-b972-4764-a24b-87856cdf3a6b
# ╟─4f12214b-25ff-4947-ba1e-75b768c73c0d
# ╟─e97e0b7e-d95d-430d-b0bb-8fda6b0dcc90
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
