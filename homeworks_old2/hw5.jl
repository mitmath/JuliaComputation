### A Pluto.jl notebook ###
# v0.19.29

using Markdown
using InteractiveUtils

# ╔═╡ 5803a81e-5b75-11ed-08ff-17c142080826
begin
	using BenchmarkTools
	using CUDA
	using CUDAKernels
	using KernelAbstractions
	using LinearAlgebra
	using Plots
	using PlutoTeachingTools
	using PlutoUI
	using ProgressLogging
	using Random
	using StaticArrays
end

# ╔═╡ f984ae77-cd98-4002-bdbf-c532ad9fc1c6
md"""
Homework 5 of the MIT Course [_Julia: solving real-world problems with computation_](https://github.com/mitmath/JuliaComputation)

Release date: Thursday, Oct 19, 2023 (version 1.3)

**Due date: Thursday, Oct 26, 2023 at 11:59pm EST**

Submission by: Jazzy Doe (jazz@mit.edu)
"""

# ╔═╡ a353c90a-32c5-4cf7-aa3a-0a9c0e7e4f47
TableOfContents()

# ╔═╡ d79b1c88-73f6-462f-8bab-07c311c9cac1
md"""
# HW5: High-performance Computing and the $n$-body problem
"""

# ╔═╡ 6f256181-b70d-41f5-a0cf-8fbf0ff94ed4
md"""
In this homework, we will simulate the motion of $n$ interacting bodies.
This is an excellent excuse to talk about parallelism and GPU computing.
Thanks to James Schloss for his help!
"""

# ╔═╡ 8072b6c7-548c-4d8d-aac1-cf6ce268970b
md"# Checking for a GPU"

# ╔═╡ 2ae0f053-a759-4f09-b265-143003a7da1e
md"""
Let's start by checking if your computer has a GPU and if CUDA knows that.
Either way, the GPU sections of this homework are completely optional, but encouraged if you happen to have a GPU and are interested in seeing how to use them.
"""

# ╔═╡ ec43be3f-2ae1-41fa-b630-4de63271fbb3
CUDA.has_cuda_gpu()

# ╔═╡ 2e70ac93-80ac-44bb-a7e0-06a89a2a0188
try
	CUDA.versioninfo()
	@info "CUDA.jl is working correctly on this machine"
catch e
	@info "CUDA.jl is not working correctly on this machine"
end

# ╔═╡ 0c98d84e-00f4-43ce-847f-f1a3ff9b4e2a
md"# 1. Benchmarking"

# ╔═╡ a89ec761-8c1d-4984-944f-2e3b1cc7dbe9
md"""
To start with, let us note that Julia already has a useful built-in macro called `@time`.
When you put it before a function call, it measures the CPU time, memory use and number of allocations required.
"""

# ╔═╡ ee3e173f-a8d7-490d-966b-213c9678c99c
@time rand(1000, 1000);

# ╔═╡ db911c10-4f16-4a9b-ae75-77ed4b0fbcc7
md"""
But `@time` has a few drawbacks:
- it only runs the function one time, which means estimates are noisy
- it includes compilation time if the function has never been run before
- it can be biased by [global variables](https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-untyped-global-variables)

Here are some examples.
"""

# ╔═╡ e1af9a3e-792d-4557-b889-e38c95a8860a
@time cos.(rand(1000, 1000));

# ╔═╡ 41589942-1d0d-42cc-8523-24e582b3d3f6
md"""
The first time you run the previous cell, most of the time will actually be spent compiling the function.
If you run it a second time, the benchmarking result will be completely different.
"""

# ╔═╡ 71da98e7-b7a3-4b82-a551-5953ce001f73
let
	x = rand(1000, 1000)
	sum(abs2, x)  # run once to compile
	@time sum(abs2, x)
end; 

# ╔═╡ fc307c99-4444-4e9f-8194-c60634286b4e
md"""
In the previous cell, there is no reason for the sum to allocate anything: this is just an artefact due to the global variable `x`.
"""

# ╔═╡ 7652a2bd-27e9-4d47-93b5-4ada74516524
md"""
For all of these reasons, [`BenchmarkTools.jl`](https://github.com/JuliaCI/BenchmarkTools.jl) is a much better option.
Its `@btime` macro does basically the same job as `@time`, but runs the function several times and circumvents global variables, as long as they are "interpolated" with a `$` sign.
"""

# ╔═╡ 5b752d74-be2a-4e04-9a38-b566a28bf8a4
@btime rand(1000, 1000);

# ╔═╡ 333f28a1-0ae7-4933-a25d-dfea1f08d20b
md"""
This benchmark is pretty comparable to the one given by `@time`.
"""

# ╔═╡ 1ceffc88-f8a4-4b14-b7cb-23ca8e7a796e
@btime sin.(rand(1000, 1000));

# ╔═╡ 5e0b101f-a9fe-4702-9c7c-bf199c3ebf10
md"""
This benchmark does not include compilation time, because the first run of the function is just one of many.
"""

# ╔═╡ 56badd88-f661-4a6d-95b4-1c62709ada38
let
	x = randn(1000, 1000); 
	@btime sum(abs2, $x); 
end

# ╔═╡ 09156ec4-2146-4f8d-a5ac-7fed1951d9d1
md"""
This benchmark shows zero allocation, which is what we actually expect.
"""

# ╔═╡ 4d636f82-8330-41fe-80fc-e96bb66e503a
md"""
!!! danger "Task 1.1"
	Write a function that compares matrix addition and multiplication based on the time _per operation_.
"""

# ╔═╡ a35a7ec2-9ebf-4cdc-9ae4-b7954302fe20
hint(md"
Unlike `@btime`, which prints a bunch of information but returns the result of the function, `@belapsed` actually returns the elapsed CPU time.
Don't forget to interpolate the arguments.

Remember that for a given size $n$, addition requires $n^2$ operations while multiplication requires $2n^3$ operations.
You should divide the output of `@belapsed` by these factors.
")

# ╔═╡ 18e3412d-2195-4db7-b4dc-f8eeda903d49
function compare_add_mul(n)
	# write your code here
	time_add = 1.0 # change this line
	time_mul = 1.0 # change this line
	return time_add, time_mul
end

# ╔═╡ 44bf3996-78e5-4b20-830e-5ae1a87aacfc
answer_11 = compare_add_mul(10)

# ╔═╡ b7a09982-c27b-44ea-a3b6-447d0b5a2f8c
compare_add_mul(100)

# ╔═╡ 359d45f7-ca56-4249-a973-eb200249dc25
md"""
!!! danger "Task 1.2"
	Now, we'll use your function to plot the normalized time per operation for matrix addition and multiplication, using sizes $n \in \{3, 10, 30, 100, 300\}$.
	Comment on what you observe and explain the difference you see between matrix addition and multiplication.
"""

# ╔═╡ a9751721-6f63-44e3-ace5-9f01dcff0350
md"""
The loop over $n$ may take a little time, don't be scared.
We've put the `@progress` macro from [`ProgressLogging`](https://github.com/JuliaLogging/ProgressLogging.jl) in front of the `for` keyword to track its progress.
"""

# ╔═╡ 07e18600-b466-44fc-9835-ff2d4b0fd80f
begin
	n_values = [3, 10, 30, 100, 300]
	times_add = Float64[]
	times_mul = Float64[]
	@progress for n in n_values
		ta, tm = compare_add_mul(n)
		push!(times_add, ta)
		push!(times_mul, tm)
	end
end

# ╔═╡ 1d497d40-7e84-45e4-a914-5e443d51ff45
begin
	plot(
		xlabel="matrix size", ylabel="normalized operation cost (s)",
		xscale=:log10, yscale=:log10,
	)
	scatter!(n_values, times_add, label="matrix addition")
	scatter!(n_values, times_mul, label="matrix multiplication")
end

# ╔═╡ 9c4f44ef-fb59-4a21-950e-68eb456952e7
answer_12 = md"""
Your comment here
"""

# ╔═╡ 1e71d8ef-389d-46fe-8c34-976ac3b64b5e
md"""
# 2. Writing good serial code
"""

# ╔═╡ 333c4431-248c-44f6-a2f3-77d881bf4c7e
md"""
Before parallelizing our code, it's important to ensure the serial version is efficient.
Often, this is enough to get the speedup we were looking for from parallelism.
Even if it isn't, it's a necessary step to getting good parallel code (and it's easier to do now than after we've parallelized the code).
"""

# ╔═╡ db22c241-d99a-44e4-b5a2-c0283dc5d61a
md"""
## 2.1 Memory managment
"""

# ╔═╡ 438c1219-2171-466d-a425-f20fc775d856
md"""
Since Julia is a high-level language, you don't need to care about memory to write correct code.
New objects are allocated transparently, and once you no longer need them, the Garbage Collector (GC) automatically frees their memory slots.

However, in many cases, memory management is a performance bottleneck.
If you want to write fast code, you might need to work "in place" (mutating existing arrays), as opposed to "out of place" (creating many temporary arrays).
This is emphasized [several](https://docs.julialang.org/en/v1/manual/performance-tips/#Measure-performance-with-[@time](@ref)-and-pay-attention-to-memory-allocation) [times](https://docs.julialang.org/en/v1/manual/performance-tips/#Pre-allocating-outputs) in the Julia performance tips.
"""

# ╔═╡ 9ee41c2b-e4f3-4da2-b772-243f77cd5587
md"""
A common pattern is broadcasted operations, which can look like `x .+ y` (the `.` goes in front for short operators) or `exp.(x)` (the `.` goes behind for functions).
They allow you to work directly with array components, instead of allocating new arrays.
This leads to performance gains, as explained [here](https://docs.julialang.org/en/v1/manual/performance-tips/#More-dots:-Fuse-vectorized-operations).
"""

# ╔═╡ 049b57c3-9dd2-45ae-8b9f-438e7c896ac4
md"""
!!! danger "Task 2.1"
	Try to explain the difference in speed and memory use between the following code snippets.
"""

# ╔═╡ 52ed22c5-ef4e-4248-9615-3b250e5f83af
let
	x = rand(100, 100)
	y = rand(100, 100)
	@btime $x += 2 * $y
end;

# ╔═╡ 880659cd-1766-489b-8c9c-f5408b7cf760
let
	x = rand(100, 100)
	y = rand(100, 100)
	@btime $x .+= 2 .* $y
end;

# ╔═╡ fad5383e-83aa-4dbe-bbd7-67a9bef27cec
hint(md"`x += y` is syntactically equivalent to `x = x + y`.")

# ╔═╡ f216ae0d-eff2-4abf-b4bc-877f613dd1b1
answer_21 = md"""
Your answer here
"""

# ╔═╡ fa62fdab-36b4-4fc2-aee6-b4f2ee72be8d
md"""
Whenever possible, you may also want to use or write mutating versions of critical functions.
By convention, such functions get a `!` suffix to warn about their side effects.
"""

# ╔═╡ aceaf48e-2be3-4fde-855f-62e1a8e4eea0
md"""
!!! danger "Task 2.2"
	Write a function that compares mutating and non-mutating matrix multiplication.
"""

# ╔═╡ 6952a006-605b-463a-8d51-dbcb5c957b48
hint(md"
Take a look at the documentation for the three-argument function `mul!(C, A, B)`, and compare it with `A * B`.
Don't forget to interpolate the arguments
")

# ╔═╡ 2b9a78dd-fed1-4c82-8ef9-c18273639957
function compare_mul!_mul(n)
	# Your code goes here
	time_mul! = 0.0 # Change this line
	time_mul = 0.0 # Change this line
	return time_mul!, time_mul
end

# ╔═╡ d99166df-efa3-417c-965b-9ff9273de575
answer_22 = compare_mul!_mul(10)

# ╔═╡ 06fb0635-9ae4-4c22-b61a-da0737bf0a6d
compare_mul!_mul(100)

# ╔═╡ 5e31e98e-0688-4b9d-aa81-0f49a793c71a
md"""
## 2.2 Statically-sized arrays
"""

# ╔═╡ 0333d1f7-be89-4a26-931b-372f3085c618
md"""
You are already familiar with arrays from base Julia, which have variable size and can grow or shrink dynamically.
But in some situations, we might need arrays whose size is fixed and known statically, i.e. hardcoded in their type.
An interesting example is physical simulations, where we often deal with small vectors / matrices of dimensions 2 or 3.

If we provide static size information to the compiler, array operations can be made faster by "unrolling" the loops.
This is the role of the [StaticArrays.jl](https://github.com/JuliaArrays/StaticArrays.jl) package.
It defines the types `SArray` and `MArray` for immutable and mutable arrays respectively.
"""

# ╔═╡ b7f9507f-b956-4453-ba66-4787d6b2b313
md"""
!!! danger "Task 2.3"
	Benchmark the performance of `Vector` against `SVector` and `MVector` for adding two vectors of size $n$, with $n \in \{2, 20, 200\}$.
	What do you observe?
"""

# ╔═╡ f4760fa0-a0b5-41e9-b49d-0bd9cc7e2782
hint(md"Use `SVector(Tuple(x))` to convert `x` into a static vector")

# ╔═╡ eb61a025-c36f-4c96-bf3f-029bc3a2cecf
let
	# Your code here
end

# ╔═╡ 27f75a0b-3b90-4982-b411-2b7907f9b7d7
answer_23 = md"""
Your answer here
"""

# ╔═╡ e7fbd945-bd94-4639-a9b2-ef2aa78f6600
md"""
In practice, this means that computations involving small `SArray`s or `MArray`s are very fast and memory-efficient, even when we forget about the usual performance tips (which is what will happen in the rest of this homework).
"""

# ╔═╡ e75d3a86-604f-4502-b72a-6220e1543b64
md"""
# 3. Inroduction to parallelism
"""

# ╔═╡ 60907f8e-13a2-4b31-bf6f-6a7e06eacc01
md"""
Julia supports several flavors of [parallel computing](https://docs.julialang.org/en/v1/manual/parallel-computing/).
Here, we focus on multithreading and GPU computing.
"""

# ╔═╡ c2112a28-3b1a-4f1d-a9c3-474a20e6b1b1
md"""
## 3.1 Multithreading
"""

# ╔═╡ 6fb37947-c4dd-4807-9369-7e1d67b23b9e
md"""
[Multithreading](https://docs.julialang.org/en/v1/manual/multi-threading/) is part of base Julia and works out of the box on every computer.
To use it, you need to start Julia with several threads, but Pluto already takes care of that.
"""

# ╔═╡ ab60a366-44a3-4898-8b46-25a3d0fb7a38
Threads.nthreads()

# ╔═╡ 63fb4bd2-a25c-4f4b-aa26-17cf9dbbd64c
md"""
If, for some reason, the above cell evaluates to 1, try running Pluto using `Pluto.run(threads=N)` for some larger `N`.
"""

# ╔═╡ 7cd14a96-7894-4ed1-b002-48644f7c65ab
md"""
To parallelize a `for` loop, all you have to do is add the `Threads.@threads` macro in front of it, and the loop iterations will be split among the available threads (in this case, there are $(Threads.nthreads())).
"""

# ╔═╡ a44627dc-fdb5-478b-a695-11a2eb02d7f1
let
	a = zeros(Int, 20)
	Threads.@threads for i in 1:20
		a[i] = Threads.threadid()
	end
	a
end

# ╔═╡ 2c644f2a-6416-4a0e-8e38-2b4ef097abc3
md"""
Since all threads share the same memory, multithreading can give incorrect results when used carelessly, as in the example below.
"""

# ╔═╡ f32302b6-ead0-4a56-b0df-1776816815e3
let
	s = 0
	Threads.@threads for i in 1:1_000_000
		s += 1
	end
	s
end

# ╔═╡ 41fee41a-8b78-4337-aa37-b638a24448fb
md"""
The reason why `s != 1_000_000` is because threads step on each other's toes, a phenomenon also known as race conditions.
Check out the (short) explanation [here](https://en.wikipedia.org/wiki/Race_condition#Example).

To prevent such behavior, a simple method is to make sure that each thread writes to a separate part of memory, which is not accessible to the other threads.
On the other hand, reading from the same memory is usually okay.
"""

# ╔═╡ e2365d69-217f-46c8-8058-fcb2449f01aa
let
	s_by_thread = zeros(Int, Threads.nthreads())
	Threads.@threads for i in 1:1_000_000
		s_by_thread[Threads.threadid()] += 1
	end
	sum(s_by_thread)
end

# ╔═╡ 3b6ff29a-0d42-4441-ba49-f0e5adfbb583
md"""
The maximum speedup you can obtain from multithreading is the number of CPU cores on your machine (possibly x2 with [hyperthreading](https://en.wikipedia.org/wiki/Hyper-threading)).
However, depending on the underlying code, the actual speedup is usually lower, due to threading overhead or costly memory access.

So if you need to tune the number of threads for a given application, just increase it until you stop gaining performance.
"""

# ╔═╡ a3eea236-a688-433a-8a22-ccffc37ce4af
md"""
!!! danger "Task 3.1"
	Is the data structure `Dict` thread-safe?
"""

# ╔═╡ d62e68e2-13be-48f8-9599-49e358dbde59
hint(md"Try to modify a `Dict` from various threads and see what happens")

# ╔═╡ 7df074c1-1f24-475d-b446-1c16f9c86538
let
	# Your code here
end

# ╔═╡ 95dfeb17-7134-41e1-8015-dc14845f369a
answer_31 = md"""
Your answer here
"""

# ╔═╡ 570e7ebe-252f-4cd7-b3a5-31232e5642ec
md"""
It is useful to remember that memory management is the main difference between multithreading and [multiprocessing / distributed computing](https://docs.julialang.org/en/v1/manual/distributed-computing/).
The latter assumes that each process or machine has its own memory.
This makes it easier to write correct code, but the costs of exchanging information between processes are usually higher.
We will not give more details at this stage.
"""

# ╔═╡ d8611f20-387b-40d1-9490-f7bf0a93a437
md"""
## 3.2 GPU computing (optional)
"""

# ╔═╡ 56bac60c-65ff-4b5c-a5ca-29a723a79d89
md"""
GPU computing exploits the graphics card of a computer, which is why its implementation is hardware-dependent.
The most prominent package is [CUDA.jl](https://juliagpu.org/) for NVIDIA GPUs, but Intel and AMD GPUs can be used as well (see the JuliaGPU [website](https://juliagpu.org/)).
The CUDA.jl [tutorial](https://cuda.juliagpu.org/stable/tutorials/introduction/) is a very interesting read if you want to understand what happens under the hood.
"""

# ╔═╡ 51041f7e-19ce-482d-b993-4b9d80e0745c
md"""
Programming for GPUs relies on "kernels", basic routines that generate very efficient and highly parallel machine code.
The package [KernelAbstractions.jl](https://github.com/JuliaGPU/KernelAbstractions.jl) allows us to write generic kernels that can be specialized for several types of devices.

Here is a simple kernel that performs in-place elementwise multiplication.
"""

# ╔═╡ a151f96e-ab07-4b51-9213-45c36e588ab0
@kernel function double_kernel!(a)
    i = @index(Global, Linear)  # replaces the for loop, parallelizes along i
	a[i] *= 2
end

# ╔═╡ c736fb2c-3afc-456d-a0fa-44caa067dd2d
md"""
When looking at this kernel, it's important to note that there is no outer `for` loop.
Instead, we are essentially programming what each individual core (called a thread) does.
Because of this, the kernel needs to be configured to know:
- How many cores you want to run with, which is called the `workgroupsize` (or `blocksize` in CUDA.jl). In the case of GPU computing, the `workgroupsize` is often on the order of 100s (so 256, for example), whereas for CPU computing, we better choose something like the number `Threads.nthreads()` of available threads.
- The maximum size to "iterate over", which is called the `ndrange`. As an example, you might run a kernel with 256 unique computational threads (`workgroupsize = 256`) that needs to do something with an array of size 1024 (`ndrange = 1024`). In this case, each computational thread would need execute the kernel 4 times.
"""

# ╔═╡ 85be94f8-452b-4fdc-a195-4e9e474b83b8
md"""
We now show how to use this kernel on a specific device, in this case the CPU.
This is a good practice to debug your code locally before running it on a GPU-enabled machine.
"""

# ╔═╡ 150b90bd-47bb-4f34-ba88-ba3e1d458811
let
	a = ones(1024)
	device = KernelAbstractions.get_device(a)  # where the array is stored
	workgroupsize = device isa GPU ? 256 : Threads.nthreads()  # how much parallelism
	@info "Kernel" device workgroupsize
	kernel! = double_kernel!(device, workgroupsize)  # prepare kernel for device
	event = kernel!(a; ndrange=length(a))  # specify range for i & launch kernel
	wait(event)  # wait for the computation to finish on the device
	sum(a)
end

# ╔═╡ a8fa5ee2-0b88-4760-a7c1-3e7b8a31d6a2
md"""
If we want to migrate to the GPU, we only need to use the dedicated array type: `CuArray` from CUDA.jl. 
"""

# ╔═╡ a85927b0-152a-4a55-a23b-0ff560c40ead
md"""
!!! danger "Task 3.2"
	Copy the cell above and initialize `a` as a `CuVector` instead.
	- What is the new `device`?
	- What might happen if we removed the line `wait(event)`?
"""

# ╔═╡ e57cb666-08fd-40b1-9cff-fd19b82563d7
hint(md"In practice you won't see the effect of not waiting for this very fast kernel, but in other cases you might")

# ╔═╡ d7a4e9c6-2a39-4004-b3a6-0beb63d34a47
let
	# Your code here
end

# ╔═╡ 51ad839c-42cd-4da5-a92c-a6e047fd4ec8
answer_32 = md"""
Your answer here
"""

# ╔═╡ b1f56b3f-85dc-4580-aa30-ef2ba0021c4d
md"""
You may be wondering why we're going through all this trouble to multiply a vector by 2.
Indeed, in this simple case, `a .*=  2` gives rise to efficient GPU code when applied to a `CuArray`.
But there are many situations where vectorization is not so obvious, and things are easier to write as loops.
Besides, the broadcasting syntax is just a facade that generates new kernels on the fly for every operation, which means writing your own kernels is often more efficient.
"""

# ╔═╡ 8339952b-9ff4-48aa-9509-2740d1aaac8c
md"""
# 4. Simulating the $n$-body problem
"""

# ╔═╡ 38697a0b-0f70-4101-b7e1-c37d3ad98fbb
md"""
We'll now practice by writing a simulation for the [$n$-body problem](https://en.wikipedia.org/wiki/N-body_problem).
"""

# ╔═╡ 9b65f47f-f569-4aee-9250-af169d13d604
md"""
## 4.1 Serial simulation
"""

# ╔═╡ 01b6edaf-a83f-429f-9108-35b43f6d299c
md"""
We consider the [$n$-body problem](https://en.wikipedia.org/wiki/N-body_problem) in $\mathbb{R}^d$.
Let $m = (m_1, ..., m_n)$ be the vector of masses and $\mathbf{p}(t) = (\mathbf{p}_1(t), ..., \mathbf{p}_n(t))$ be the vector of positions at a given time $t$.
For each particle $i \in [n]$, Newton's second law gives us
```math
	m_i \overset{..}{\mathbf{p}}_i = \sum_{j \neq i} \frac{G m_j m_i}{\lVert \mathbf{p}_j - \mathbf{p}_i \rVert^2} \mathbf{u}_{ij} \quad \text{where} \quad \mathbf{u}_{ij} = \frac{\mathbf{p}_j - \mathbf{p}_i}{\lVert \mathbf{p}_j - \mathbf{p}_i \rVert}
```
We will simulate this system of ODEs using [Verlet integration](https://en.wikipedia.org/wiki/Verlet_integration), and to avoid extreme behavior we replace $r_{ij}^2 = \lVert \mathbf{p}_j - \mathbf{p}_i \rVert^2$ with $r_{ij}^2 + 1$ (this is called softening).
"""

# ╔═╡ 8429ef19-3306-4d85-b8f6-194a04711dd2
md"""
### 4.1.1 Storage
"""

# ╔═╡ 2087f4f2-9d85-4358-bf7f-9ea53db7eead
struct Particles{
    Mas<:AbstractVector{<:Real},
    Pos<:AbstractVector{<:AbstractVector{<:Real}},
    Acc<:AbstractVector{<:AbstractVector{<:Real}},
}
    masses::Mas
    positions::Pos
    last_positions::Pos
    accelerations::Acc
end

# ╔═╡ ac093aed-406b-4e78-b746-d61ee37829e7
"""
	initialize_particles(ArrayType; n, d, rng)

Create `n` particles in dimension `d` with random initial positions and masses (using the generator `rng`). Store them as `SVector`s within a vector of type `ArrayType`.
"""
function initialize_particles(
    ::Type{ArrayType}=Array; n, d, rng=Random.GLOBAL_RNG
) where {ArrayType<:AbstractArray}
    masses = ArrayType(rand(rng, Float32, n))
    positions = ArrayType([SVector(Tuple(rand(rng, Float32, d))) for i in 1:n])
    last_positions = copy(positions)
    accelerations = ArrayType([SVector(Tuple(zeros(Float32, d))) for i in 1:n])
    return Particles(masses, positions, last_positions, accelerations)
end

# ╔═╡ e7dc5fd6-6b12-453e-9ccf-910af73850e6
md"""
### 4.1.2 Simulation
"""

# ╔═╡ 2228ceb5-1f53-4e68-9913-e2edafa0979f
"""
	xsqrtx(y)

Compute `y^(3/2)` in an efficient way.
"""
xsqrtx(y) = y * sqrt(y)

# ╔═╡ 5559bdac-56be-4230-a7e0-2efcc14d03e0
"""
	update_acceleration!(accelerations, masses, positions, i)

Update the acceleration for particle `i` using Newton's 2nd law.
"""
function update_acceleration!(accelerations, masses, positions, i)
	n = length(masses)
    pᵢ = positions[i]
    aᵢ = zero(accelerations[i])  # zero vector of the same type
    for j in 1:n
        if j != i
            mⱼ, pⱼ = masses[j], positions[j]
			rᵢⱼ² = sum(abs2, pⱼ - pᵢ)
            aᵢ += (mⱼ / xsqrtx(rᵢⱼ² + 1)) * (pⱼ - pᵢ)  # acceleration = force / mass
        end
    end
    accelerations[i] = aᵢ
end

# ╔═╡ e7ea34ed-4dd5-4fa8-806f-af157bfb6590
"""
	update_positions!(positions, last_positions, accelerations, i, Δt)

Update all current and last positions for particle `i` for a time interval `Δt` using Verlet integration.
"""
function update_position!(positions, last_positions, accelerations, i, Δt)
    pᵢ, last_pᵢ, aᵢ = positions[i], last_positions[i], accelerations[i]
    positions[i] = 2 * pᵢ - last_pᵢ + aᵢ * Δt^2  # Verlet integration
    last_positions[i] = pᵢ
end

# ╔═╡ 4a0cba53-3e9c-4277-9a30-7455741a5f50
"""
	nbody!(particles; Δt, steps)

Run `steps` intervals of an n-body simulation on a set of `particles`, where each intervals has duration `Δt`.
"""
function nbody!(particles::Particles; Δt, steps)
	# the following syntax parses the fields of a struct
	(; masses, positions, last_positions, accelerations) = particles
	n = length(masses)
    for s in 1:steps
        for i in 1:n
            update_acceleration!(accelerations, masses, positions, i)
        end
        for i in 1:n
            update_position!(positions, last_positions, accelerations, i, Δt)
        end
    end
end

# ╔═╡ 51061846-6f58-479b-ab24-0a773c2af034
let
	n, d, Δt, steps = 5, 2, 0.01, 10
	particles = initialize_particles(Array; n=n, d=d)
	nbody!(particles; Δt=Δt, steps=steps)
end

# ╔═╡ fe4b8a41-02a2-4c7f-996f-6913fc62713e
md"""
!!! danger "Task 4.1"
	The `nbody!` function contains 3 nested loops: on `s`, `i` and `j`.
	(The loop on `j` is within `update_acceleration!`.)
	Which one of them
	1. can be parallelized easily?
	1. could be parallelized if we modified the code a little bit?
	1. should never be parallelized?
"""

# ╔═╡ 23ef2c59-6301-4e42-81e2-6c4481f4bb9b
answer_41 = md"""
1. Your answer here
2. Your answer here
3. Your answer here
"""

# ╔═╡ 3cd38682-aa95-4d27-831f-814641b92754
md"""
In what follows, we will focus on parallelizing the answer to 1., because it requires the least effort.
"""

# ╔═╡ 903e087d-a77e-4c56-9761-05c54a0cc81c
md"""
### 4.1.3 Plotting
"""

# ╔═╡ 48da2f41-d9e2-4c8b-b23f-9d7e1346769f
function plot_nbody(; n, d, Δt, steps)
	particles = initialize_particles(Array; n=n, d=d)
	(; masses, positions, last_positions, accelerations) = particles
	n = length(masses)
	trajectories = [copy(positions)]
	for s in 1:steps
        for i in 1:n
            update_acceleration!(accelerations, masses, positions, i)
        end
        for i in 1:n
            update_position!(positions, last_positions, accelerations, i, Δt)
        end
		push!(trajectories, copy(positions))
    end
	@gif for s in 1:steps
		scatter(
			map(first, trajectories[s]),
			map(last, trajectories[s]),
			markershape=:circle,
			xlim=(-0.5, 1.5),
			ylim=(-0.5, 1.5),
			label=nothing,
			title="n-body simulation, time=$s"
		)
	end every 10
end

# ╔═╡ 17c5ee50-7baa-4d28-a39a-b9f58eaf7f0a
plot_nbody(n=5, d=2, Δt=0.01, steps=1000)

# ╔═╡ 960288de-ab52-4bae-baa2-6c582c26c2b2
md"""
## 4.2 Multithreaded simulation
"""

# ╔═╡ cc734b56-93b2-40c3-acbb-2d18b028ae21
md"""
!!! danger "Task 4.2"
	Implement `nbody_threaded!` as a multithreaded version of `nbody!`
"""

# ╔═╡ cc92ac8f-8430-4ee1-8090-31b4dbd0253b
# Your code here

# ╔═╡ 9ffe6c48-20f7-4866-af2e-22977315fa60
let
	if @isdefined nbody_threaded!
		n, d, Δt, steps = 5, 2, 0.01, 10
		particles = initialize_particles(Array; n=n, d=d)
		nbody_threaded!(particles; Δt=Δt, steps=steps)
	end
end

# ╔═╡ 3fc6b27e-ad34-4fa2-8405-91261d7b3384
check_42 = let
	if @isdefined nbody_threaded!
		n, d, Δt, steps = 5, 2, 0.01, 10
		particles = initialize_particles(Array; n=n, d=d, rng=MersenneTwister(63))
		particles_ref = deepcopy(particles)
		nbody!(particles_ref; Δt=Δt, steps=steps)
		try
			nbody_threaded!(particles; Δt=Δt, steps=steps)
			if particles.positions ≈ particles_ref.positions
				correct(md"`nbody_threaded!` returns the same result as `nbody!`")
			else
				almost(md"`nbody_threaded!` returns an incorrect result")
			end
		catch e
			almost(md"`nbody_threaded!` throws a $(typeof(e))")
		end
	else
		almost(md"You need to define `nbody_threaded!`")
	end
end

# ╔═╡ c1ad1392-005d-4c99-826f-be9c7c240f88
md"""
!!! danger "Task 4.3"
	Benchmark `nbody_threaded!` against `nbody!` with `Vector` storage.
	Comment on the cases where a speedup is achieved
"""

# ╔═╡ 4a330f54-a220-466c-af5e-ad70d5387d5b
hint(md"Try playing with the number of particles")

# ╔═╡ 3313e718-9cd2-41d9-8615-b72871f9fda5
# Your code here

# ╔═╡ 904e5a60-65ce-419e-9f8c-32b29a98d0f4
answer_43 = md"""
Your answer here
"""

# ╔═╡ 09d5ed7f-5c78-470b-a832-d6ce951dc8a2
md"""
## 4.3 GPU simulation (optional)
"""

# ╔═╡ 449d8103-dc1f-4496-bd90-a4718d9f30ea
md"""
!!! danger "Task 4.4"
	Implement `nbody_gpu!` as a GPU-compatible version of `nbody!`
"""

# ╔═╡ 0b60df5e-732d-47cb-ad56-9c9a81fe374b
hint(md"Start by writing two kernels `update_accelerations_kernel!` and `update_positions_kernel!`. Then specialize both of them for the right device inside `nbody_gpu!`, as shown in section 1.2. Don't forget to `wait` until the first kernel is done running before launching the second one!")

# ╔═╡ f8eef0e0-eaa8-4161-be01-b8551af21f1f
@kernel function update_accelerations_kernel!(accelerations, masses, positions)
    # Your code here
end

# ╔═╡ f83755c7-d6ff-4438-b9a5-659561d1b6dc
@kernel function update_positions_kernel!(
	positions, last_positions, accelerations, Δt
)
    # Your code here
end

# ╔═╡ f7e8e7c9-d71d-48ee-9909-a6a5a4e06d1b
function nbody_gpu!(particles::Particles; Δt, steps)
	(; masses, positions, last_positions, accelerations) = particles
	# Your code here
end

# ╔═╡ ba83ffdd-480e-496e-b8d6-4475cffd9ea8
let
	if @isdefined nbody_gpu!
		n, d, Δt, steps = 5, 2, 0.01, 10
		particles = initialize_particles(Array; n=n, d=d)
		nbody_gpu!(particles; Δt=Δt, steps=steps)
	end
end

# ╔═╡ 04ac0905-2ab0-4e0c-abbb-343a96c10c16
let
	if (@isdefined nbody_gpu!) && CUDA.has_cuda_gpu()
		n, d, Δt, steps = 5, 2, 0.01, 10
		particles = initialize_particles(CuArray; n=n, d=d)
		nbody_gpu!(particles; Δt=Δt, steps=steps)
	end
end

# ╔═╡ a02b2923-bfb0-4cfa-bf05-c1e37d0f9420
check_44 = let
	if (@isdefined nbody_gpu!) && CUDA.has_cuda_gpu()
		n, d, Δt, steps = 5, 2, 0.01, 10
		particles_cpu = initialize_particles(Array; n=n, d=d, rng=MersenneTwister(63))
		particles_gpu = initialize_particles(CuArray; n=n, d=d, rng=MersenneTwister(63))
		particles_cpu_ref = deepcopy(particles_cpu)
		nbody!(particles_cpu_ref; Δt=Δt, steps=steps)
		try
			nbody_gpu!(particles_cpu; Δt=Δt, steps=steps)
			if particles_cpu.positions ≈ particles_cpu_ref.positions
				try
					nbody_gpu!(particles_gpu; Δt=Δt, steps=steps)
					if Array(particles_gpu.positions) ≈ particles_cpu_ref.positions
						correct(md"`nbody_threaded!` returns the same result as `nbody!` on both CPU and GPU arrays")
					else
						almost(md"`nbody_gpu!` returns an incorrect result on GPU arrays")
					end
				catch e
					almost(md"`nbody_gpu!` throws a $(typeof(e)) on GPU arrays")
				end
			else
				almost(md"`nbody_gpu!` returns an incorrect result on CPU arrays")
			end
		catch e
			almost(md"`nbody_gpu!` throws a $(typeof(e)) on CPU arrays")
		end
	else
		almost(md"You need to define `nbody_gpu!` and have a CUDA-enabled machine")
	end
end

# ╔═╡ 4c1f3efe-2374-4471-ae5f-48d7eff4d379
md"""
!!! danger "Task 4.5"
	Benchmark `nbody_gpu!` on a `CuVector` against `nbody_threaded!` on a `Vector`.
	Comment on the cases where a speedup is achieved
"""

# ╔═╡ 2db23a84-50f2-4b28-9ea2-218cd850a157
let
	# Your code here
end

# ╔═╡ dc7cfac4-2076-4b7b-b469-d3399cdb88e2
answer_45 = md"""
Your answer here
"""

# ╔═╡ ccce9e18-a32f-49c7-9cdf-b465d999272e
tick(done) = done ? "✓" : "∅"

# ╔═╡ 45e5d832-a12b-4512-903a-80899f3cc2a4
md"""
Task recap (measures progress, not accuracy):

| Task | Status                                             |            |
| ---- | -------------------------------------------------- | ---------- |
| 1.1  | $(tick(answer_11 != (1.0,1.0)))                    |            |
| 1.2  | $(tick(answer_12 != md"Your comment here"))        |            |
| 2.1  | $(tick(answer_21 != md"Your answer here"))         |            |
| 2.2  | $(tick(answer_22 != (0.0,0.0)))                    |            |
| 2.3  | $(tick(answer_23 != md"Your answer here"))         |            |
| 3.1  | $(tick(answer_31 != md"Your answer here"))         |            |
| 3.2  | $(tick(answer_32 != md"Your answer here"))         | (optional) |
| 4.1  | $(tick(string(answer_41) != "1. Your answer here\n2. Your answer here\n3. Your answer here\n"))         |            |
| 4.2  | $(tick(check_42.content[1].category == "correct")) |            |
| 4.3  | $(tick(answer_43 != md"Your answer here"))         |            |
| 4.4  | $(tick(check_44.content[1].category == "correct")) | (optional) |
| 4.5  | $(tick(answer_45 != md"Your answer here"))         | (optional) |
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
CUDAKernels = "72cfdca4-0801-4ab0-bf6a-d52aa10adc57"
KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
ProgressLogging = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[compat]
BenchmarkTools = "~1.3.2"
CUDA = "~4.0.1"
CUDAKernels = "~0.4.7"
KernelAbstractions = "~0.8.6"
Plots = "~1.39.0"
PlutoTeachingTools = "~0.2.13"
PlutoUI = "~0.7.52"
ProgressLogging = "~0.1.4"
StaticArrays = "~1.6.5"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "83a8d26084b46586c6ea07f3a8dbd2eff60b33fe"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

    [deps.AbstractFFTs.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "76289dc51920fdc6e0013c872ba9551d54961c24"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.2"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

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

[[deps.BFloat16s]]
deps = ["LinearAlgebra", "Printf", "Random", "Test"]
git-tree-sha1 = "dbf84058d0a8cbbadee18d25cf606934b22d7c66"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.4.2"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

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

[[deps.CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CUDA_Driver_jll", "CUDA_Runtime_Discovery", "CUDA_Runtime_jll", "CompilerSupportLibraries_jll", "ExprTools", "GPUArrays", "GPUCompiler", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "Preferences", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "SpecialFunctions"]
git-tree-sha1 = "edff14c60784c8f7191a62a23b15a421185bc8a8"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "4.0.1"

[[deps.CUDAKernels]]
deps = ["Adapt", "CUDA", "KernelAbstractions", "StaticArrays", "UnsafeAtomicsLLVM"]
git-tree-sha1 = "1680366a69e9c95744ef23a239e6cfe61cf2e1ca"
uuid = "72cfdca4-0801-4ab0-bf6a-d52aa10adc57"
version = "0.4.7"

[[deps.CUDA_Driver_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "75d7896d1ec079ef10d3aee8f3668c11354c03a1"
uuid = "4ee394cb-3365-5eb0-8335-949819d2adfc"
version = "0.2.0+0"

[[deps.CUDA_Runtime_Discovery]]
deps = ["Libdl"]
git-tree-sha1 = "d6b227a1cfa63ae89cb969157c6789e36b7c9624"
uuid = "1af6417a-86b4-443c-805f-a4643ffb695f"
version = "0.1.2"

[[deps.CUDA_Runtime_jll]]
deps = ["Artifacts", "CUDA_Driver_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "ed00f777d2454c45f5f49634ed0a589da07ee0b0"
uuid = "76a88914-d11a-5bdc-97e0-2f5a05c973a2"
version = "0.2.4+1"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "c0216e792f518b39b22212127d4a84dc31e4e386"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.5"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "02aa26a4cf76381be7f66e020a3eddeb27b0a092"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.2"

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
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "5372dbbf8f0bdb8c700db5367132925c0771ef7e"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.2.1"

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

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

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
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d8db6a5a2fe1381c1ea4ef2cab7c69c2de7f9ea0"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.1+0"

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
git-tree-sha1 = "2e57b4a4f9cc15e85a24d603256fe08e527f48d1"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "8.8.1"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "2d6ca471a6c7b536127afccfa7564b5b39227fe0"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.5"

[[deps.GPUCompiler]]
deps = ["ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "19d693666a304e8c371798f4900f7435558c7cde"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.17.3"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

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

[[deps.KernelAbstractions]]
deps = ["Adapt", "Atomix", "InteractiveUtils", "LinearAlgebra", "MacroTools", "SparseArrays", "StaticArrays", "UUIDs", "UnsafeAtomics", "UnsafeAtomicsLLVM"]
git-tree-sha1 = "cf9cae1c4c1ff83f6c02cfaf01698f05448e8325"
uuid = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
version = "0.8.6"

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
git-tree-sha1 = "f044a2796a9e18e0531b9b3072b0019a61f264bc"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "4.17.1"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "070e4b5b65827f82c16ae0916376cb47377aa1b5"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.18+0"

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

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "f428ae552340899a935973270b8d98e5a31c49fe"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.1"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

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
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

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
version = "2.28.2+0"

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
version = "2022.10.11"

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
version = "0.3.21+4"

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
version = "10.42.0+0"

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
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

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

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

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

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Random123]]
deps = ["Random", "RandomNumbers"]
git-tree-sha1 = "552f30e847641591ba3f39fd1bed559b9deb0ef3"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.6.1"

[[deps.RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

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

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

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

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e2cfc4012a19088254b3950b85c3c1d8882d864d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.3.1"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore"]
git-tree-sha1 = "0adf069a2a490c47273727e029371b31d44b72b2"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.6.5"
weakdeps = ["Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

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

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

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

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "f548a9e9c490030e545f72074a41edfd0e5bcdd7"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.23"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "b7a5e99f24892b6824a954199a45e9ffcc1c70f0"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.0"

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
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "a72d22c7e13fe2de562feda8645aa134712a87ee"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.17.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "e2d817cc500e960fdbafcf988ac8436ba3208bfd"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.3"

[[deps.UnsafeAtomics]]
git-tree-sha1 = "6331ac3440856ea1988316b46045303bef658278"
uuid = "013be700-e6cd-48c3-b4a1-df204f14c38f"
version = "0.2.1"

[[deps.UnsafeAtomicsLLVM]]
deps = ["LLVM", "UnsafeAtomics"]
git-tree-sha1 = "ead6292c02aab389cb29fe64cc9375765ab1e219"
uuid = "d80eeb9a-aca5-4d75-85e5-170c8b632249"
version = "0.1.1"

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
version = "1.2.13+0"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

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
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

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
# ╠═f984ae77-cd98-4002-bdbf-c532ad9fc1c6
# ╠═5803a81e-5b75-11ed-08ff-17c142080826
# ╠═a353c90a-32c5-4cf7-aa3a-0a9c0e7e4f47
# ╟─d79b1c88-73f6-462f-8bab-07c311c9cac1
# ╟─45e5d832-a12b-4512-903a-80899f3cc2a4
# ╟─6f256181-b70d-41f5-a0cf-8fbf0ff94ed4
# ╟─8072b6c7-548c-4d8d-aac1-cf6ce268970b
# ╟─2ae0f053-a759-4f09-b265-143003a7da1e
# ╠═ec43be3f-2ae1-41fa-b630-4de63271fbb3
# ╠═2e70ac93-80ac-44bb-a7e0-06a89a2a0188
# ╟─0c98d84e-00f4-43ce-847f-f1a3ff9b4e2a
# ╟─a89ec761-8c1d-4984-944f-2e3b1cc7dbe9
# ╠═ee3e173f-a8d7-490d-966b-213c9678c99c
# ╟─db911c10-4f16-4a9b-ae75-77ed4b0fbcc7
# ╠═e1af9a3e-792d-4557-b889-e38c95a8860a
# ╟─41589942-1d0d-42cc-8523-24e582b3d3f6
# ╠═71da98e7-b7a3-4b82-a551-5953ce001f73
# ╟─fc307c99-4444-4e9f-8194-c60634286b4e
# ╟─7652a2bd-27e9-4d47-93b5-4ada74516524
# ╠═5b752d74-be2a-4e04-9a38-b566a28bf8a4
# ╟─333f28a1-0ae7-4933-a25d-dfea1f08d20b
# ╠═1ceffc88-f8a4-4b14-b7cb-23ca8e7a796e
# ╟─5e0b101f-a9fe-4702-9c7c-bf199c3ebf10
# ╠═56badd88-f661-4a6d-95b4-1c62709ada38
# ╟─09156ec4-2146-4f8d-a5ac-7fed1951d9d1
# ╟─4d636f82-8330-41fe-80fc-e96bb66e503a
# ╟─a35a7ec2-9ebf-4cdc-9ae4-b7954302fe20
# ╠═18e3412d-2195-4db7-b4dc-f8eeda903d49
# ╠═44bf3996-78e5-4b20-830e-5ae1a87aacfc
# ╠═b7a09982-c27b-44ea-a3b6-447d0b5a2f8c
# ╟─359d45f7-ca56-4249-a973-eb200249dc25
# ╟─a9751721-6f63-44e3-ace5-9f01dcff0350
# ╠═07e18600-b466-44fc-9835-ff2d4b0fd80f
# ╠═1d497d40-7e84-45e4-a914-5e443d51ff45
# ╠═9c4f44ef-fb59-4a21-950e-68eb456952e7
# ╟─1e71d8ef-389d-46fe-8c34-976ac3b64b5e
# ╟─333c4431-248c-44f6-a2f3-77d881bf4c7e
# ╟─db22c241-d99a-44e4-b5a2-c0283dc5d61a
# ╟─438c1219-2171-466d-a425-f20fc775d856
# ╟─9ee41c2b-e4f3-4da2-b772-243f77cd5587
# ╟─049b57c3-9dd2-45ae-8b9f-438e7c896ac4
# ╠═52ed22c5-ef4e-4248-9615-3b250e5f83af
# ╠═880659cd-1766-489b-8c9c-f5408b7cf760
# ╟─fad5383e-83aa-4dbe-bbd7-67a9bef27cec
# ╠═f216ae0d-eff2-4abf-b4bc-877f613dd1b1
# ╟─fa62fdab-36b4-4fc2-aee6-b4f2ee72be8d
# ╟─aceaf48e-2be3-4fde-855f-62e1a8e4eea0
# ╟─6952a006-605b-463a-8d51-dbcb5c957b48
# ╠═2b9a78dd-fed1-4c82-8ef9-c18273639957
# ╠═d99166df-efa3-417c-965b-9ff9273de575
# ╠═06fb0635-9ae4-4c22-b61a-da0737bf0a6d
# ╟─5e31e98e-0688-4b9d-aa81-0f49a793c71a
# ╟─0333d1f7-be89-4a26-931b-372f3085c618
# ╟─b7f9507f-b956-4453-ba66-4787d6b2b313
# ╟─f4760fa0-a0b5-41e9-b49d-0bd9cc7e2782
# ╠═eb61a025-c36f-4c96-bf3f-029bc3a2cecf
# ╠═27f75a0b-3b90-4982-b411-2b7907f9b7d7
# ╟─e7fbd945-bd94-4639-a9b2-ef2aa78f6600
# ╟─e75d3a86-604f-4502-b72a-6220e1543b64
# ╟─60907f8e-13a2-4b31-bf6f-6a7e06eacc01
# ╟─c2112a28-3b1a-4f1d-a9c3-474a20e6b1b1
# ╟─6fb37947-c4dd-4807-9369-7e1d67b23b9e
# ╠═ab60a366-44a3-4898-8b46-25a3d0fb7a38
# ╟─63fb4bd2-a25c-4f4b-aa26-17cf9dbbd64c
# ╟─7cd14a96-7894-4ed1-b002-48644f7c65ab
# ╠═a44627dc-fdb5-478b-a695-11a2eb02d7f1
# ╟─2c644f2a-6416-4a0e-8e38-2b4ef097abc3
# ╠═f32302b6-ead0-4a56-b0df-1776816815e3
# ╟─41fee41a-8b78-4337-aa37-b638a24448fb
# ╠═e2365d69-217f-46c8-8058-fcb2449f01aa
# ╟─3b6ff29a-0d42-4441-ba49-f0e5adfbb583
# ╟─a3eea236-a688-433a-8a22-ccffc37ce4af
# ╟─d62e68e2-13be-48f8-9599-49e358dbde59
# ╠═7df074c1-1f24-475d-b446-1c16f9c86538
# ╠═95dfeb17-7134-41e1-8015-dc14845f369a
# ╟─570e7ebe-252f-4cd7-b3a5-31232e5642ec
# ╟─d8611f20-387b-40d1-9490-f7bf0a93a437
# ╟─56bac60c-65ff-4b5c-a5ca-29a723a79d89
# ╟─51041f7e-19ce-482d-b993-4b9d80e0745c
# ╠═a151f96e-ab07-4b51-9213-45c36e588ab0
# ╟─c736fb2c-3afc-456d-a0fa-44caa067dd2d
# ╟─85be94f8-452b-4fdc-a195-4e9e474b83b8
# ╠═150b90bd-47bb-4f34-ba88-ba3e1d458811
# ╟─a8fa5ee2-0b88-4760-a7c1-3e7b8a31d6a2
# ╟─a85927b0-152a-4a55-a23b-0ff560c40ead
# ╟─e57cb666-08fd-40b1-9cff-fd19b82563d7
# ╠═d7a4e9c6-2a39-4004-b3a6-0beb63d34a47
# ╠═51ad839c-42cd-4da5-a92c-a6e047fd4ec8
# ╟─b1f56b3f-85dc-4580-aa30-ef2ba0021c4d
# ╟─8339952b-9ff4-48aa-9509-2740d1aaac8c
# ╟─38697a0b-0f70-4101-b7e1-c37d3ad98fbb
# ╟─9b65f47f-f569-4aee-9250-af169d13d604
# ╟─01b6edaf-a83f-429f-9108-35b43f6d299c
# ╟─8429ef19-3306-4d85-b8f6-194a04711dd2
# ╠═2087f4f2-9d85-4358-bf7f-9ea53db7eead
# ╠═ac093aed-406b-4e78-b746-d61ee37829e7
# ╟─e7dc5fd6-6b12-453e-9ccf-910af73850e6
# ╠═2228ceb5-1f53-4e68-9913-e2edafa0979f
# ╠═5559bdac-56be-4230-a7e0-2efcc14d03e0
# ╠═e7ea34ed-4dd5-4fa8-806f-af157bfb6590
# ╠═4a0cba53-3e9c-4277-9a30-7455741a5f50
# ╠═51061846-6f58-479b-ab24-0a773c2af034
# ╟─fe4b8a41-02a2-4c7f-996f-6913fc62713e
# ╠═23ef2c59-6301-4e42-81e2-6c4481f4bb9b
# ╟─3cd38682-aa95-4d27-831f-814641b92754
# ╟─903e087d-a77e-4c56-9761-05c54a0cc81c
# ╠═48da2f41-d9e2-4c8b-b23f-9d7e1346769f
# ╠═17c5ee50-7baa-4d28-a39a-b9f58eaf7f0a
# ╟─960288de-ab52-4bae-baa2-6c582c26c2b2
# ╟─cc734b56-93b2-40c3-acbb-2d18b028ae21
# ╠═cc92ac8f-8430-4ee1-8090-31b4dbd0253b
# ╠═9ffe6c48-20f7-4866-af2e-22977315fa60
# ╟─3fc6b27e-ad34-4fa2-8405-91261d7b3384
# ╟─c1ad1392-005d-4c99-826f-be9c7c240f88
# ╟─4a330f54-a220-466c-af5e-ad70d5387d5b
# ╠═3313e718-9cd2-41d9-8615-b72871f9fda5
# ╠═904e5a60-65ce-419e-9f8c-32b29a98d0f4
# ╟─09d5ed7f-5c78-470b-a832-d6ce951dc8a2
# ╟─449d8103-dc1f-4496-bd90-a4718d9f30ea
# ╟─0b60df5e-732d-47cb-ad56-9c9a81fe374b
# ╠═f8eef0e0-eaa8-4161-be01-b8551af21f1f
# ╠═f83755c7-d6ff-4438-b9a5-659561d1b6dc
# ╠═f7e8e7c9-d71d-48ee-9909-a6a5a4e06d1b
# ╠═ba83ffdd-480e-496e-b8d6-4475cffd9ea8
# ╠═04ac0905-2ab0-4e0c-abbb-343a96c10c16
# ╟─a02b2923-bfb0-4cfa-bf05-c1e37d0f9420
# ╟─4c1f3efe-2374-4471-ae5f-48d7eff4d379
# ╠═2db23a84-50f2-4b28-9ea2-218cd850a157
# ╠═dc7cfac4-2076-4b7b-b469-d3399cdb88e2
# ╟─ccce9e18-a32f-49c7-9cdf-b465d999272e
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
