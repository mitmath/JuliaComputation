### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 510bdffa-6367-11ed-23ca-9d49e3f3543f
begin
	using BenchmarkTools
	using DataStructures
	using PlutoTeachingTools
	using PlutoUI
	using SparseArrays
end

# ╔═╡ 66106324-994f-4751-8a1e-0b307380bd11
TableOfContents()

# ╔═╡ 683da7e5-2794-4766-a026-cb55bd23690f
html"<button onclick=present()>Present</button>"

# ╔═╡ 63c6ffc0-17cb-4732-9fae-b7eb233f8fdc
md"""
# Graph theory
"""

# ╔═╡ 4799ca44-7847-41cc-a101-f8ce5c4f255e
md"""
In this notebook, we give an overview of graph optimization problems and explain the fundamental principle behind [Graphs.jl](https://github.com/JuliaGraphs/Graphs.jl), the reference library for graphs in Julia.
"""

# ╔═╡ 823205a4-170a-4b69-bce4-3ce39d17d469
md"""
# 1. Graphs as an interface
"""

# ╔═╡ bec05993-17de-4121-af30-2ae15956c6e1
md"""
Most graph algorithms only make use of a few basic subroutines, which can be implemented in lots of different ways depending on our needs.
That is what allows you to [create your own graph format](https://juliagraphs.org/Graphs.jl/dev/ecosystem/interface/) and make it compatible with the entire ecosystem very easily.
"""

# ╔═╡ 86d3573e-5ea3-4fd3-a0a9-32e8dd946cc4
md"""
## Graph definition
"""

# ╔═╡ c6310180-499a-4dd1-bda3-8d86f791c1b0
md"""
A weighted graph $G = (V, E, w)$ is composed of:

- a set $V$ of vertices, often called $u$ or $v$, with $|V|=n$
- a set $E$ of edges, often denoted by $e = (u, v)$, with $|E|=m$
- a vector $w$ of weight values $w_e$

If the edges are directed ($u \to v$) we speak of "nodes" and "arcs" instead.

Visualisation: [here](https://visualgo.net/en/graphds)
"""

# ╔═╡ 5230069e-a2aa-40fe-a2e5-aceefe6b6635
md"""
## Dijkstra's algorithm
"""

# ╔═╡ abc30a8b-b728-4936-a9b3-cdbf210a265d
md"""
A path $P = (v_1, ..., v_k)$ is a sequence of vertices linked by edges.
Many concrete problems boil down to finding the shortest path between two vertices $s$ (source) and $d$ (destination) in a weighted graph.
The most famous algorithm for shortest paths is [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm), which works on graphs with nonnegative edge weights.

Visualization: [here](https://visualgo.net/en/sssp)
"""

# ╔═╡ 789c7a0a-870d-4fdb-a11d-4ab314cbbce9
md"""
## Necessary methods
"""

# ╔═╡ 1c6fd34c-80c7-4b8f-b9fb-9ac1aa74db04
md"""
For Dijkstra's algorithm, we only need our graph structure to provide a handful of methods.
"""

# ╔═╡ 981d2bc0-3030-4d4a-a2c3-ae6c3819838d
"""
	AbstractWeightedGraph

To satisfy this interface, a concrete type must implement the following methods:
- `nb_vertices(g)`
- `edge_weight(g, u, v)`
- `outneighbors(g, u)`
"""
abstract type AbstractWeightedGraph end

# ╔═╡ 1de57dcb-85c0-44c0-b225-f81194ffea06
"""
	nb_vertices(g)

Count the vertices in `g`.
"""
function nb_vertices end

# ╔═╡ caa8f63c-ec6c-45c4-9f23-c853bce3a929
"""
	edge_weight(g, u, v)

Return the weight of the edge `(u, v)` in `g`.
"""
function edge_weight end

# ╔═╡ c4d83106-f940-4c69-bb95-8effe7e8bd50
"""
	outneighbors(g, u)

Return an iterable of the vertices `v` such that `(u, v)` is an edge of `g`.
"""
function outneighbors end

# ╔═╡ dbeda7e3-ce02-49c2-93b1-1e2e712c9c09
md"""
# 2. Graph storage types
"""

# ╔═╡ f4fc6854-a44d-4bfd-88bd-a3b9eaf95332
md"""
For simplicity, we assume that the graph vertices are numbered from $1$ to $n$, i.e. that $V = \{1, ..., n\}$.
"""

# ╔═╡ 055d49e6-8b2e-462d-abe3-bf3c5c97f61c
md"""
Our test graph is a grid of size `(I,J)`.
"""

# ╔═╡ 24722797-ae00-4066-8838-43e9eb4b5ee3
grid_coord_to_index(i, j; I, J) = (j-1) * I + (i-1) + 1

# ╔═╡ 95df5658-24d0-440d-b157-e4cf54c11d1a
grid_index_to_coord(v; I, J) = ((v-1) % I + 1, (v-1) ÷ I + 1)

# ╔═╡ 3931bfba-cb35-487d-a798-923e8ee454d2
function grid_edges(I, J)
	edges = Tuple{Int,Int,Float64}[]
	for iᵤ in 1:I, jᵤ in 1:J
		u = grid_coord_to_index(iᵤ, jᵤ; I, J)
		for (iᵥ, jᵥ) in ((iᵤ+1, jᵤ), (iᵤ-1, jᵤ), (iᵤ, jᵤ+1), (iᵤ, jᵤ-1))
			if 1 <= iᵥ <= I && 1 <= jᵥ <= J
				v = grid_coord_to_index(iᵥ, jᵥ; I, J)
				wᵤᵥ = rand(Float64)
				push!(edges, (u, v, wᵤᵥ))
			end
		end
	end
	return edges
end

# ╔═╡ 57f66ed6-b4aa-4ab0-9eaa-02f12983594a
I, J = 50, 100

# ╔═╡ 570f7368-5464-4817-8040-f95dddf8da05
edges = grid_edges(I, J)

# ╔═╡ de48b3f3-3cba-45b9-b0ef-eb7cfbb2c7aa
md"""
## Edge list
"""

# ╔═╡ 669c587c-c877-4e9e-a934-2850c4208147
struct ListGraph <: AbstractWeightedGraph
	n::Int
	edges::Vector{Tuple{Int,Int,Float64}}
end

# ╔═╡ 55252064-0f58-44ac-a836-981a6cd8227a
nb_vertices(g::ListGraph) = g.n

# ╔═╡ a1bde286-3806-4203-a461-81fb6c595492
function edge_weight(g::ListGraph, u, v)
	for (x, y, w) in g.edges
		if (x, y) == (u, v)
			return w
		end
	end
end

# ╔═╡ f775760a-1311-4060-a347-aa2d631be0e4
function outneighbors(g::ListGraph, u)
	out = Int[]
	for (x, y, w) in g.edges
		if x == u
			push!(out, y)
		end
	end
	return out
end

# ╔═╡ db189e71-79af-48d4-bd94-6c30bef943a3
md"""
## Dense adjacency matrix
"""

# ╔═╡ 971fe1f5-7b9c-477c-9a0e-dd1a574487e5
md"""
The adjacency matrix $A \in \mathbb{R}^{n \times n}$ of a weighted graph $G = (V, E, w)$ is defined as follows:

$$A_{u,v} = \begin{cases} w_{(u,v)} & \text{if $(u, v) \in E$} \\ 0 & \text{otherwise} \end{cases}$$
"""

# ╔═╡ 8ad780bf-0a3c-4fff-8a5c-154a576ee45a
begin
	struct DenseMatrixGraph <: AbstractWeightedGraph
		A::Matrix{Float64}
	end
	
	function DenseMatrixGraph(n, edges)
		A = zeros(Float64, n, n)
		for (u, v, wᵤᵥ) in edges
			A[u, v] = wᵤᵥ
		end
		return DenseMatrixGraph(A)
	end
end

# ╔═╡ 33609b23-0e1d-411d-a950-fbc964727fe7
nb_vertices(g::DenseMatrixGraph) = size(g.A, 1)

# ╔═╡ 49639fa6-5e65-47ec-ba47-51717e73827c
edge_weight(g::DenseMatrixGraph, u, v) = g.A[u, v]

# ╔═╡ 37c5bb0b-6fca-45fc-9c3d-8806bf1c2ee6
md"""
**What if we transpose?**
"""

# ╔═╡ 71c5d9e4-2785-406c-8c6d-3d88a541b0f0
begin
	struct TransposedDenseMatrixGraph <: AbstractWeightedGraph
		Aᵀ::Matrix{Float64}
	end
	
	function TransposedDenseMatrixGraph(n, edges)
		Aᵀ = zeros(Float64, n, n)
		for (u, v, wᵤᵥ) in edges
			Aᵀ[v, u] = wᵤᵥ
		end
		return TransposedDenseMatrixGraph(Aᵀ)
	end
end

# ╔═╡ 6fb680c3-986c-4fd4-b6b3-5164eb73cc30
nb_vertices(g::TransposedDenseMatrixGraph) = size(g.Aᵀ, 1)

# ╔═╡ 66f24701-1556-4881-a1fb-6f0e41165adf
edge_weight(g::TransposedDenseMatrixGraph, u, v) = g.Aᵀ[v, u]

# ╔═╡ 778d9984-f09e-4b65-8b6d-07323dc0e39c
md"""
## Sparse adjacency matrix
"""

# ╔═╡ abb0457d-4201-41df-957e-6d1d18fd29a1
md"""
When the average degree of a vertex is small compared to $n$, the adjacency matrix is sparse.
"""

# ╔═╡ 2c7772f2-e12a-4c9f-aede-19620d6fa03a
begin
	struct SparseMatrixGraph <: AbstractWeightedGraph
		A::SparseMatrixCSC{Float64,Int}
	end
	
	function SparseMatrixGraph(n, edges)
		U, V, W = Int[], Int[], Float64[]
		for (u, v, wᵤᵥ) in edges
			push!(U, u); push!(V, v); push!(W, wᵤᵥ)
		end
		A = sparse(U, V, W, n, n)
		return SparseMatrixGraph(A)
	end
end

# ╔═╡ 0633e202-4ebf-4fdf-b0e9-581b075510fc
nb_vertices(g::SparseMatrixGraph) = size(g.A, 1)

# ╔═╡ 15cd794b-598c-4066-ae1f-2dd3e40c7eff
edge_weight(g::SparseMatrixGraph, u, v) = g.A[u, v]

# ╔═╡ 44642265-f22f-4b55-ba31-a5979f386b30
function outneighbors(g::SparseMatrixGraph, u)
	return g.A[u, :].nzind
end

# ╔═╡ 232739d5-f984-4679-a7bb-09f9066df9bf
md"""
**What if we transpose?**
"""

# ╔═╡ 8cf9e88b-ad56-4e9e-93b4-61c99f5fe00a
md"""
We can take advantage of the [CSC format](https://docs.julialang.org/en/v1/stdlib/SparseArrays/#man-csc) for sparse matrices by storing the transpose of the adjacency matrix instead.
"""

# ╔═╡ e35d80c1-043b-4152-b005-c579f2c1557d
begin
	struct TransposedSparseMatrixGraph <: AbstractWeightedGraph
		Aᵀ::SparseMatrixCSC{Float64,Int}
	end
	
	function TransposedSparseMatrixGraph(n, edges)
		U, V, W = Int[], Int[], Float64[]
		for (u, v, wᵤᵥ) in edges
			push!(U, u); push!(V, v); push!(W, wᵤᵥ)
		end
		Aᵀ = sparse(V, U, W, n, n)
		return TransposedSparseMatrixGraph(Aᵀ)
	end
end

# ╔═╡ 1f8b678c-dbb5-4155-806c-fd072846bf56
nb_vertices(g::TransposedSparseMatrixGraph) = size(g.Aᵀ, 1)

# ╔═╡ 0e48f9d6-04e9-4d88-9949-43066c31d0c2
edge_weight(g::TransposedSparseMatrixGraph, u, v) = g.Aᵀ[v, u]

# ╔═╡ 5ca4bfab-13a5-4455-92cf-289ebfbb61a9
function outneighbors(g::TransposedSparseMatrixGraph, u)
    return @view g.Aᵀ.rowval[nzrange(g.Aᵀ, u)]
end

# ╔═╡ d99f2290-bd32-4737-b2c2-e33c679be313
md"""
## Adjacency lists
"""

# ╔═╡ e9d703a4-de01-4417-a9ef-464d29149937
begin
	struct AdjacencyGraph <: AbstractWeightedGraph
		outneighbors::Vector{Vector{Int}}
		weights::Vector{Vector{Float64}}
	end
	
	function AdjacencyGraph(n, edges)
		outneighbors = [Int[] for v in 1:n]
		weights = [Float64[] for v in 1:n]
		for (u, v, w) in sort(edges)
			push!(outneighbors[u], v)
			push!(weights[u], w)
		end
		return AdjacencyGraph(outneighbors, weights)
	end
end

# ╔═╡ 52a26992-2ea7-404b-bf18-299fabfa8038
nb_vertices(g::AdjacencyGraph) = length(g.outneighbors)

# ╔═╡ 417566e9-b377-4e2a-811c-84b019f7e157
function edge_weight(g::AdjacencyGraph, u, v)
	k = searchsortedfirst(g.outneighbors[u], v)
	return g.weights[u][k]
end

# ╔═╡ ae582e38-7b70-4ae2-bb98-ec43a24f4bfd
function outneighbors(g::DenseMatrixGraph, u)
	return (v for v in 1:nb_vertices(g) if edge_weight(g, u, v) > 0)
end

# ╔═╡ 03c46a8e-a10a-4754-8136-421927f8d911
function outneighbors(g::TransposedDenseMatrixGraph, u)
	return (v for v in 1:nb_vertices(g) if edge_weight(g, u, v) > 0)
end

# ╔═╡ f8daa411-9ec2-4789-adf9-d3a3017d9a78
function outneighbors(g::AdjacencyGraph, u)
	return g.outneighbors[u]
end

# ╔═╡ 755b8709-4a86-4b79-a61c-605ba8ecdd8b
"""
	dijkstra(g, s)

Return the lengths of shortest paths from `s` to all other vertices in the weighted graph `g`.
"""
function dijkstra(g::AbstractWeightedGraph, s)
    dist = fill(Inf, nb_vertices(g))  # here
	queue = PriorityQueue{Int,Float64}()
    enqueue!(queue, s => 0.0)
	while !isempty(queue)
        u, dist[u] = dequeue_pair!(queue)
        for v in outneighbors(g, u)  # here
            dist_v = dist[u] + edge_weight(g, u, v)  # here
            if dist_v < dist[v]
                dist[v] = dist_v
                queue[v] = dist_v
            end
        end
    end
    return dist
end

# ╔═╡ 643c4cd5-6a96-4859-8a91-142946c880e4
let
	g = ListGraph(I*J, edges)
	dijkstra(g, 1)
end

# ╔═╡ caba823b-2cb8-4760-9d18-31ab7a065d82
let
	g = ListGraph(I*J, edges)
	@benchmark dijkstra($g, 1)
end

# ╔═╡ 04a938be-c786-42c1-bcdd-45d8e714adcd
let
	g = DenseMatrixGraph(I*J, edges)
	@assert dijkstra(g, 1) ≈ dijkstra(ListGraph(I*J, edges), 1)
	@benchmark dijkstra($g, 1)
end

# ╔═╡ 3ac9e1f0-15aa-4d51-8449-130755ce16b1
let
	g = TransposedDenseMatrixGraph(I*J, edges)
	@assert dijkstra(g, 1) ≈ dijkstra(ListGraph(I*J, edges), 1)
	@benchmark dijkstra($g, 1)
end

# ╔═╡ 47850682-5d83-4cd2-bf9b-4dcbffc999bb
let
	g = SparseMatrixGraph(I*J, edges)
	@assert dijkstra(g, 1) ≈ dijkstra(ListGraph(I*J, edges), 1)
	@benchmark dijkstra($g, 1)
end

# ╔═╡ c4c2597b-08a5-4806-aeb2-a083ce6db5be
let
	g = TransposedSparseMatrixGraph(I*J, edges)
	@assert dijkstra(g, 1) ≈ dijkstra(ListGraph(I*J, edges), 1)
	@benchmark dijkstra($g, 1)
end

# ╔═╡ e8a84b3b-bb63-4aec-9c9d-3e6657d15703
let
	g = AdjacencyGraph(I*J, edges)
	@assert dijkstra(g, 1) ≈ dijkstra(ListGraph(I*J, edges), 1)
	@benchmark dijkstra($g, 1)
end

# ╔═╡ fd13066b-35f0-4c5c-91fe-fbacbfdb6bb7
md"""
## The trouble with metadata
"""

# ╔═╡ 652eb695-e549-417d-8085-65d8276dd479
md"""
There are plenty of concurrent packages for graphs with metadata:
- [SimpleWeightedGraphs.jl](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl)
- [MetaGraphs.jl](https://github.com/JuliaGraphs/MetaGraphs.jl)
- [MetaGraphsNext.jl](https://github.com/JuliaGraphs/MetaGraphsNext.jl)

An intense discussion is ongoing regarding the future of the Graphs.jl interface for version 2.0 (see [issue 35](https://github.com/JuliaGraphs/Graphs.jl/issues/35) or [issue 128](https://github.com/JuliaGraphs/Graphs.jl/issues/128))
"""

# ╔═╡ 0d5d033a-5410-4717-8c15-e9723b39e603
md"""
# 3. Zoo of graph problems
"""

# ╔═╡ 1ddf887d-1597-46b1-b883-bf7a969d71bd
md"""
Which ones seem related to the course challenge?
"""

# ╔═╡ 9a7f16ba-0c9a-481f-880d-7b34be5b8f3f
md"""
**Coloring**
"""

# ╔═╡ 24a4e090-9a99-4764-bf94-23baca78f9a8
md"""
**Matching**
"""

# ╔═╡ 42f019c0-6e8b-4f02-91e2-c7d1de6cc822
md"""
**Shortest path**
"""

# ╔═╡ b663ae74-24b6-47f1-ae59-cb988f7ba796
md"""
**Network flow**
"""

# ╔═╡ 3d5a8f4b-26de-425c-8f57-365bf87f0393
md"""
**Eulerian path**
"""

# ╔═╡ e173413a-4f4d-4004-abcd-a662dbd59b37
md"""
**Hamiltonian path (TSP)**
"""

# ╔═╡ 89b98e6c-9a7d-4bd4-9524-977bb0b91086
md"""
**Vehicle routing**
"""

# ╔═╡ 7bf9221a-26a8-41f5-8c9e-a3c5de948f3e
md"""
**Arc routing**
"""

# ╔═╡ 4b36ed7c-4fd9-41b2-a87d-48c740c5afa3
md"""
**Spanning tree**
"""

# ╔═╡ 06f4116d-7032-4822-b52e-2926192c9da8
md"""
**Steiner tree**
"""

# ╔═╡ 5ad847d0-9968-42a6-9bcc-41064ab0d4e2
md"""
# 4. Toolbox for hard problems
"""

# ╔═╡ 79372f18-6cd3-4fa8-a847-1d0d676ad29f
md"""
## Greedy algorithms
"""

# ╔═╡ d9eab403-ac57-4dc7-b3eb-75463ad555db
md"""
## Relaxation / simplification
"""

# ╔═╡ f3199889-eb95-44be-ab98-828272f2bb73
md"""
## Repair
"""

# ╔═╡ 60e444b5-1928-46ae-831b-8408b9a04fd0
md"""
## Local search (hill climbing)
"""

# ╔═╡ 2336a8cc-43fa-459c-96a5-57878d58b113
md"""
Once you have a feasible solution, you can improve it iteratively through [local search](https://en.wikipedia.org/wiki/Local_search_(optimization)): at each iteration,

1. Define a set of neighbor solutions by making small changes to the current one
2. Pick one of the neighbors according to some objective
"""

# ╔═╡ f69050d0-df95-4f29-858e-46bbc7252745
md"""
## Metaheuristics
"""

# ╔═╡ e7d83aca-2b42-4747-99b9-9648b74d6718
md"""
In many situations, always picking the best neighbor quickly traps the search at a local optimum.
Several strategies have been designed to enhance exploration, mostly thanks to randomness.
These strategies take a local search heuristic and tweak it, which is why they are called [metaheuristics](https://en.wikipedia.org/wiki/Metaheuristic).
The most famous ones are probably [simulated annealing](https://en.wikipedia.org/wiki/Simulated_annealing) and evolutionary / generic algorithms.
"""

# ╔═╡ 3d2673e1-d1af-44d3-8441-7825504102be
md"""
# References
"""

# ╔═╡ 7eb7606b-2f65-41c8-a510-6e40f4c306cf
md"""
**Books**

- Korte, B., and Vygen, J. (2006), *[Combinatorial Optimization: Theory and Algorithms](https://www.mathematik.uni-muenchen.de/~kpanagio/KombOpt/book.pdf)*
- Cormen, T. H., Leiserson, C. E., Rivest, R. L., and Stein, C. (2009), *[Introduction to Algorithms](https://edutechlearners.com/download/Introduction_to_algorithms-3rd%20Edition.pdf)*
- Cook, W. J. (2012), *[In Pursuit of the Traveling Salesman: Mathematics at the Limits of Computation](https://viterbik12.usc.edu/wp-content/uploads/2017/06/Carlsson-Pages-from-William_Cook_In_pursuit_of_the_traveling_salesman.pdf)*
- Bona, M. (2016), *[A Walk Through Combinatorics: An Introduction To Enumeration And Graph Theory](https://www.microlinkcolleges.net/elib/files/undergraduate/Mathematics/A%20Walk%20Through%20Combinatorics%20An%20Introduction%20to%20Enumeration%20and%20Graph%20Theory.pdf)*

**Other**

- [VisuAlgo](https://visualgo.net/en): Visualize many combinatorial algorithms with pseudocode indications and correctness proofs
- [WilliamFiset](https://www.youtube.com/channel/UCD8yeTczadqdARzQUp29PJw): A YouTube channel with a great series of short videos on graph theory
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
DataStructures = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[compat]
BenchmarkTools = "~1.3.2"
DataStructures = "~0.18.13"
PlutoTeachingTools = "~0.2.5"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "e1214ca6559f10c9284c988db8157654cf5b8a62"

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

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "78bee250c6826e1cf805a88b7f1e86025275d208"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.46.0"

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

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

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

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

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

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

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
# ╠═510bdffa-6367-11ed-23ca-9d49e3f3543f
# ╠═66106324-994f-4751-8a1e-0b307380bd11
# ╟─683da7e5-2794-4766-a026-cb55bd23690f
# ╟─63c6ffc0-17cb-4732-9fae-b7eb233f8fdc
# ╟─4799ca44-7847-41cc-a101-f8ce5c4f255e
# ╟─823205a4-170a-4b69-bce4-3ce39d17d469
# ╟─bec05993-17de-4121-af30-2ae15956c6e1
# ╟─86d3573e-5ea3-4fd3-a0a9-32e8dd946cc4
# ╟─c6310180-499a-4dd1-bda3-8d86f791c1b0
# ╟─5230069e-a2aa-40fe-a2e5-aceefe6b6635
# ╟─abc30a8b-b728-4936-a9b3-cdbf210a265d
# ╠═755b8709-4a86-4b79-a61c-605ba8ecdd8b
# ╟─789c7a0a-870d-4fdb-a11d-4ab314cbbce9
# ╟─1c6fd34c-80c7-4b8f-b9fb-9ac1aa74db04
# ╠═981d2bc0-3030-4d4a-a2c3-ae6c3819838d
# ╠═1de57dcb-85c0-44c0-b225-f81194ffea06
# ╠═caa8f63c-ec6c-45c4-9f23-c853bce3a929
# ╠═c4d83106-f940-4c69-bb95-8effe7e8bd50
# ╟─dbeda7e3-ce02-49c2-93b1-1e2e712c9c09
# ╟─f4fc6854-a44d-4bfd-88bd-a3b9eaf95332
# ╟─055d49e6-8b2e-462d-abe3-bf3c5c97f61c
# ╠═24722797-ae00-4066-8838-43e9eb4b5ee3
# ╠═95df5658-24d0-440d-b157-e4cf54c11d1a
# ╠═3931bfba-cb35-487d-a798-923e8ee454d2
# ╠═57f66ed6-b4aa-4ab0-9eaa-02f12983594a
# ╠═570f7368-5464-4817-8040-f95dddf8da05
# ╟─de48b3f3-3cba-45b9-b0ef-eb7cfbb2c7aa
# ╠═669c587c-c877-4e9e-a934-2850c4208147
# ╠═55252064-0f58-44ac-a836-981a6cd8227a
# ╠═a1bde286-3806-4203-a461-81fb6c595492
# ╠═f775760a-1311-4060-a347-aa2d631be0e4
# ╠═643c4cd5-6a96-4859-8a91-142946c880e4
# ╠═caba823b-2cb8-4760-9d18-31ab7a065d82
# ╟─db189e71-79af-48d4-bd94-6c30bef943a3
# ╟─971fe1f5-7b9c-477c-9a0e-dd1a574487e5
# ╠═8ad780bf-0a3c-4fff-8a5c-154a576ee45a
# ╠═33609b23-0e1d-411d-a950-fbc964727fe7
# ╠═49639fa6-5e65-47ec-ba47-51717e73827c
# ╠═ae582e38-7b70-4ae2-bb98-ec43a24f4bfd
# ╠═04a938be-c786-42c1-bcdd-45d8e714adcd
# ╟─37c5bb0b-6fca-45fc-9c3d-8806bf1c2ee6
# ╠═71c5d9e4-2785-406c-8c6d-3d88a541b0f0
# ╠═6fb680c3-986c-4fd4-b6b3-5164eb73cc30
# ╠═66f24701-1556-4881-a1fb-6f0e41165adf
# ╠═03c46a8e-a10a-4754-8136-421927f8d911
# ╠═3ac9e1f0-15aa-4d51-8449-130755ce16b1
# ╟─778d9984-f09e-4b65-8b6d-07323dc0e39c
# ╟─abb0457d-4201-41df-957e-6d1d18fd29a1
# ╠═2c7772f2-e12a-4c9f-aede-19620d6fa03a
# ╠═0633e202-4ebf-4fdf-b0e9-581b075510fc
# ╠═15cd794b-598c-4066-ae1f-2dd3e40c7eff
# ╠═44642265-f22f-4b55-ba31-a5979f386b30
# ╠═47850682-5d83-4cd2-bf9b-4dcbffc999bb
# ╟─232739d5-f984-4679-a7bb-09f9066df9bf
# ╟─8cf9e88b-ad56-4e9e-93b4-61c99f5fe00a
# ╠═e35d80c1-043b-4152-b005-c579f2c1557d
# ╠═1f8b678c-dbb5-4155-806c-fd072846bf56
# ╠═0e48f9d6-04e9-4d88-9949-43066c31d0c2
# ╠═5ca4bfab-13a5-4455-92cf-289ebfbb61a9
# ╠═c4c2597b-08a5-4806-aeb2-a083ce6db5be
# ╟─d99f2290-bd32-4737-b2c2-e33c679be313
# ╠═e9d703a4-de01-4417-a9ef-464d29149937
# ╠═52a26992-2ea7-404b-bf18-299fabfa8038
# ╠═417566e9-b377-4e2a-811c-84b019f7e157
# ╠═f8daa411-9ec2-4789-adf9-d3a3017d9a78
# ╠═e8a84b3b-bb63-4aec-9c9d-3e6657d15703
# ╟─fd13066b-35f0-4c5c-91fe-fbacbfdb6bb7
# ╟─652eb695-e549-417d-8085-65d8276dd479
# ╟─0d5d033a-5410-4717-8c15-e9723b39e603
# ╟─1ddf887d-1597-46b1-b883-bf7a969d71bd
# ╟─9a7f16ba-0c9a-481f-880d-7b34be5b8f3f
# ╟─24a4e090-9a99-4764-bf94-23baca78f9a8
# ╟─42f019c0-6e8b-4f02-91e2-c7d1de6cc822
# ╟─b663ae74-24b6-47f1-ae59-cb988f7ba796
# ╟─3d5a8f4b-26de-425c-8f57-365bf87f0393
# ╟─e173413a-4f4d-4004-abcd-a662dbd59b37
# ╟─89b98e6c-9a7d-4bd4-9524-977bb0b91086
# ╟─7bf9221a-26a8-41f5-8c9e-a3c5de948f3e
# ╟─4b36ed7c-4fd9-41b2-a87d-48c740c5afa3
# ╟─06f4116d-7032-4822-b52e-2926192c9da8
# ╟─5ad847d0-9968-42a6-9bcc-41064ab0d4e2
# ╟─79372f18-6cd3-4fa8-a847-1d0d676ad29f
# ╟─d9eab403-ac57-4dc7-b3eb-75463ad555db
# ╟─f3199889-eb95-44be-ab98-828272f2bb73
# ╟─60e444b5-1928-46ae-831b-8408b9a04fd0
# ╟─2336a8cc-43fa-459c-96a5-57878d58b113
# ╟─f69050d0-df95-4f29-858e-46bbc7252745
# ╟─e7d83aca-2b42-4747-99b9-9648b74d6718
# ╟─3d2673e1-d1af-44d3-8441-7825504102be
# ╟─7eb7606b-2f65-41c8-a510-6e40f4c306cf
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
