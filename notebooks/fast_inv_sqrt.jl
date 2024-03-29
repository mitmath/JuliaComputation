### A Pluto.jl notebook ###
# v0.19.29

#> [frontmatter]
#> title = "Fast Inverse Square Root"
#> date = "2023-11-28"
#> 
#>     [[frontmatter.author]]
#>     name = "Nicholas Klugman"

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

# ╔═╡ e0965f38-8d73-11ee-00ee-0f163204f5f6
begin
	using Plots
	plotly()
	using ImageShow, FileIO, ImageIO
	using PlutoUI, PlutoTeachingTools
	using HypertextLiteral
	using BenchmarkTools
end

# ╔═╡ a184e2ba-1618-473a-8ed5-631be9c8ffec
TableOfContents()

# ╔═╡ 99cd93dd-ae07-46da-8bc2-9ae2fdca2475
md"# Fast Inverse Square Root"

# ╔═╡ c94ff537-feb7-4555-acfc-5d82969a8c99
md"""
In 2005, the source code for the video game [Quake III Arena](https://en.wikipedia.org/wiki/Quake_III_Arena) was open sourced.
There was curious function, `Q_rsqrt` below, that was used when computing unit vectors.
The funciton supposedly takes in a floating point $x$ and returns $\frac{1}{\sqrt{x}}$, but it's hard to see how.
This notebook explores this strange algorithm.
"""

# ╔═╡ 6c433ba7-1456-49b7-a674-59056e36d805
md"""
```C
float Q_rsqrt( float number )
{
	long i;
	float x2, y;
	const float threehalfs = 1.5F;

	x2 = number * 0.5F;
	y  = number;
	i  = * ( long * ) &y;					// evil floating point bit level hacking
	i  = 0x5f3759df - ( i >> 1 );           // what the ****?
	y  = * ( float * ) &i;
	y  = y * ( threehalfs - ( x2 * y * y ) );  // 1st iteration
//	y  = y * ( threehalfs - ( x2 * y * y ) );  // 2nd iteration, this can be removed

	return y;
}
```
"""

# ╔═╡ 6fce0d3b-01db-4597-9bad-ce4a3df465ac
md"## Comparison with `1/sqrt(x)`"

# ╔═╡ 3f65daf9-96f9-44a8-b396-2b785e779a45
md"""
For this code to be worth talking about, it had better match the naive implementation pretty closely, and be faster.
Let's see how a Julia implementation of both compare:
"""

# ╔═╡ 1fce9542-b0d7-43cd-872e-964265b48a06
function inv_sqrt( number )
    return 1 / sqrt(number)
end

# ╔═╡ 689c5e83-bea8-4c55-afb7-4de66390cad5
md"### Accuracy comparison"

# ╔═╡ 450feb25-55ee-49ee-935a-f8d215f7a8ad
md"### Speed comparison"

# ╔═╡ 8ba712b7-85da-45e7-a361-5edc0432415e
let
	x = 0.001f0:0.001f0:1.0f0
	@btime inv_sqrt.($x)
end;

# ╔═╡ 86eacaf7-67f0-40a3-a29c-4669229cd47b
md"""
That's an impressive match across several orders of magnitude, and it's faster!
But, how does it work?
"""

# ╔═╡ c5f88b35-a63a-4f0e-bd2f-0844d256795e
md"""
**By the end of this lesson, not only will we have recreated this algorithm, but we will have *improved* upon it.**
"""

# ╔═╡ c4e3008c-d544-4a87-8659-93026a381584
md"## Julia implementation"

# ╔═╡ 8b923508-0369-42bf-8cc8-6d3166b1f307
md"""
Our first step in understanding the C code is writing it in Julia, since that's the language we'll use to build up our own version.
But, that leads us to one burning question:
"""

# ╔═╡ 57e2aec8-8c1f-46c3-8d5d-f9bac77a20e0
md"""
!!! danger "Activity 1: Does anyone here know C?"
	There's a lot going on in `Q_rsqrt`, but one of the most cofusing lines to someone who doesn't know C is the one labeled "evil floating point bit level hacking," but it's essential to understanding what's going on.
	Can anyone tell me what the following two lines do?
	```C
	i  = * ( long * ) &y;
	y  = * ( float * ) &i;
	```
"""

# ╔═╡ 255a2d77-f890-4bbd-90a6-cb7fcf7b920d
answer_box(md"""
Let's break down the line `i = * ( long * ) &y;` into its three parts:
1. `&y`: This gets the reference to `y`. 
   `y` is a floating point number stored somewhere in memory and `&y` gets a pointer to that piece of memory.
2. `( long * )`: This is a type casting in C.
   In particular, `&y` had type `float *`, since it was a pointer to a float.
   Here, the code casts that to a pointer to a `long` (a 32-bit signed integer in C).
3. ` * `: This derefernces the pointer; it reads from the place in memory that the pointer is pointing to.
   The type of the pointer tells this command how to read the memory.
   A 32-bit integer (`long`) and a 32-bit floating point number (`float`) are both stored as 32 0's or 1's, and how to interpret those 0's and 1's is the information stored in the type.

So, the line `i = * ( long * ) &y;` reads the bits of `y` as if they represented a 32-bit integer instead of a 32-bit floating point number, and stores that integer in `i`.
It "reinterprets" the bits.

The line `y  = * ( float * ) &i;` does the same thing in reverse---it reads the bits of `i` as if they represented a 32-bit floating point number instead of a 32-bit integer, and stores that floating point number in `y`.
""")

# ╔═╡ 24ce88da-c4e6-4e84-92f7-49ba3b3491ac
md"""
Below is $$\frac{1}{\sqrt{x}}$$ implemented in Julia using the [fast inverse square root algorithm](https://en.wikipedia.org/wiki/Fast_inverse_square_root) [from](https://github.com/id-Software/Quake-III-Arena/blob/master/code/game/q_math.c#L552) [Quake III Arena](https://en.wikipedia.org/wiki/Quake_III_Arena).
"""

# ╔═╡ b655a525-f832-4c51-8980-cf8aeb4ef4d6
function Q_rsqrt( number::Float32 )
    threehalfs = 1.5f0

    x2 = number * 0.5f0
    y = number

    i = reinterpret(Int32, y)                   # evil floating point bit level hacking
    i  = 0x5f3759df - ( i >> 1 )                # what the ****?
    y = reinterpret(Float32, i) 

	y  = y * ( threehalfs - ( x2 * y * y ) );   # 1st iteration
#	y  = y * ( threehalfs - ( x2 * y * y ) );   # 2nd iteration, this can be removed

    return y
end

# ╔═╡ 9aef30cc-1661-48ce-b26c-b7e7a0fa81a4
let
	x = 0.063f0:0.001f0:1.0f0
	y_normal = inv_sqrt.(x)
	y_quake = Q_rsqrt.(x)

	scatter(x, y_normal, label="Using sqrt")
	plot!(x, y_quake, label="Quake", linewidth=3, title="From 2^-4 to 2^0")
end

# ╔═╡ 8a95044d-4e6a-4e59-bf5a-322b2f7274ab
let
	x = 1.0f0:0.1f0:16.0f0
	y_normal = inv_sqrt.(x)
	y_quake = Q_rsqrt.(x)

	scatter(x, y_normal, label="Using sqrt")
	plot!(x, y_quake, label="Quake", linewidth=3, title="From 2^0 to 2^4")
end

# ╔═╡ 12f8bc93-8dfa-4e0c-b037-7d09093a63b8
let
	x = 16.0f0:1.0f0:256.0f0
	y_normal = inv_sqrt.(x)
	y_quake = Q_rsqrt.(x)

	scatter(x, y_normal, label="Using sqrt")
	plot!(x, y_quake, label="Quake", linewidth=3, title="From 2^4 to 2^8")
end

# ╔═╡ dffd72a2-a814-4c3d-9dd1-c0e1d58b1c51
let
	x = 0.001f0:0.001f0:1.0f0
	@btime Q_rsqrt.($x)
end;

# ╔═╡ c6c400af-9021-44a3-9039-7ef81c178caf
md"""
Comments in `Q_rsqrt` are taken from the original code and are only moderately informative (and have been censored).

The original C code had `i  = * ( long * ) &y;` and `y  = * ( float * ) &i;` instead of `i = reinterpret(Int32, y)` and `y = reinterpret(Float32, i)`, respectively.
Since pointers don't exist in the same way in Julia, we use the `reinterpret` function, which is also more readable, as it says what the code is doing (though certainly not why).
Those lines reinterpret the same bits stored in memory as either representing a 32-bit integer (`long`) or a 32-bit floating point number (`float`).
"""

# ╔═╡ 62d19499-2346-4920-926d-72b899035598
md"# Recreating the algorithm"

# ╔═╡ 8fd356b9-eea8-40c2-8513-916344c63dc9
md"""
Already, from the Julia implementation, we've gotten a hint about how it works that isn't clear from the C code.
A key step is to reinterpret the bits representing the input as if they represented an integer instead of a floating point number.
To understand why that's helpful, let's look at how that floating point number was represented in the first place.

Below, we have the IEEE 754 floating point standard. Graphic courtesy of Wikimedia Commons: Vectorization:  Stannered, CC BY-SA 3.0 <http://creativecommons.org/licenses/by-sa/3.0/>
"""

# ╔═╡ ca6e2b22-d244-4925-ac25-065fc1178df9
let url = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Float_example.svg/2560px-Float_example.svg.png"
	img = download(url)
	load(img)
end

# ╔═╡ cb14ccc4-be9a-447f-860a-6b307de799fc
md"""
Letting the sign bit be $\sigma$, the exponent be $e$, and the fraction (also known as the mantissa) be $m$, the stored value is:

$$\chi_{float} = (-1)^\sigma \left(2^{e - 127}\right) \left(1 + \frac{m}{2^{23}}\right).$$
"""

# ╔═╡ a31c585d-21ce-468e-a18f-0ed2cbbb03b7
aside(md"""
!!! question "Check your understanding"
	Look at the (base-2) scientific notation for $-12$.
	Can you guess the values of $\sigma, e,$ and $\frac{m}{2^{23}}$?

	Check your guesses by changing `false` to `true` in the code to get the full description.
""")

# ╔═╡ 5008eef1-861e-4010-828c-2dacdbdeacff
md"## First try: Ignore the mantissa"

# ╔═╡ b4b8f416-18c8-40d5-89fc-39f99d732ec6
md"""
!!! danger "Activity 2: Start simple"
	For which of the following numbers can compute the inverse square root in your head?
	Your answers should be in scientific notation.
	1. $100$
	2. $4.8 \times 10^4$
	3. $10^5$
	4. $100^{-3}$
	5. $10^8$
	6. $2^{30}$

	What some easy and some difficult?
	Would any be easier with our floating point representation?
"""

# ╔═╡ 2006d955-773f-47be-84c7-008e2a2734a2
answer_box(md"""
You should probably be able to do the inverse square roots of $100, 100^{-3}, 10^8,$ and $2^{30}$ in your head (they're $\frac{1}{10}, 1000, 10^{-4},$ and $2^{-15}$, respectively), but the last one you probably can't convert to scientific notation in your head.

Whenver the number can be written as $m^{2n}$, we can quickly do the inverse square root to get $m^{-n}$.
Since scientific notation is $a \times 10^b$, whenever our input has $a=1$ and an even $b$ (i.e., is a power of 100), we can very quickly just halve and negate $b$ to give the answer.

Our floating point representation is instead $a \times 2^b$, so the easy numbers in this format will be powers of four, because then we can just think about the exponent.
""")

# ╔═╡ 775be446-ea43-4c92-9508-34c6d1bd8d62
aside(md"""
!!! question "Check your understanding"
	When you represent a power of four in the floating point representation above, 24 of the bits are 0.
	Can you figure out which 24?

	Hint: if you think it's actually 25, you may be forgetting the offset.
	And if you thought it was 24, but after reading this hint you thing it might be 23, there's something else you're forgetting.
""")

# ╔═╡ 83ce84ed-ea45-4df1-a8ca-2a20fe18d610
md"""
As a first attempt at calculating an inverse square root, let's assume we're given a power of 4.
Then, we know that the inverse square root is a power of two and it's pretty trivial to calculate.

For a power of four, the mantissa is $0$.
Additionally, since square root is only defined for nonnegative numbers, the sign bit is $0$.
Also, the exponent ($e - 127$) is even.
We therefore have 

$$\chi_{float} = 2^{e - 127}.$$
One simple algorithm in this case would be to find exponent by bit shifting and undoing the offset, then divide it by two and negate it, then re-offset and shift it back.

Let's see how that works!
"""

# ╔═╡ f0ba969b-fa16-42e8-997b-654c4f71e7fd
function first_try(number::Float32)
	i = reinterpret(Int32, number)      # get the bits
	e = i >> 23                         # get just the exponent bits
	exponent = e - Int32(127)           # offset to get the exponent
	new_exponent = -(exponent >> 1)     # bitshift by one is the same as divide by two
	new_e = new_exponent + Int32(127)   # re-offset
	new_i = new_e << 23                 # put the exponent bits back where they belong
	return reinterpret(Float32, new_i) 
end

# ╔═╡ 01d979b5-4dce-4ab2-98de-02424788a8ce
md"Let's start by checking just on powers of 4."

# ╔═╡ 3bde82cf-4995-4ae1-82ac-cd8e62c8576a
let
	x = Float32.(4.0 .^ (-3:3))
	y_exact = inv_sqrt.(x)
	y_approx = first_try.(x)

	scatter(x, y_exact, label="Exact")
	plot!(x, y_approx, label="First try", linewidth=3)
end

# ╔═╡ b9b2f39b-b114-4ae8-8c15-e0482b68c55e
md"""
As expcted, it's exact for powers of four!
Let's see how it does between powers of four.
"""

# ╔═╡ 3b651cb4-f2f2-430e-b670-5834421706c6
md"""
!!! danger "Wait!"
	Before you look at the following graphs, try to predict what our code will do between powers of two.
	What part of the floating point representation stored the information about where we are between powers of two?
    What happened to those bits in `first_try`?
"""

# ╔═╡ c904916d-119e-4eb5-8ae3-4e837be97cef
let
	x = 0.063f0:0.001f0:1.0f0
	y_exact = inv_sqrt.(x)
	y_approx = first_try.(x)

	scatter(x, y_exact, label="Exact", linewidth=3)
	plot!(x, y_approx, label="First try", linewidth=3)
end

# ╔═╡ 0448cc27-38a3-4b86-9506-2e072078b562
let
	x = 1.0f0:0.1f0:16.0f0
	y_exact = inv_sqrt.(x)
	y_approx = first_try.(x)

	scatter(x, y_exact, label="Exact", linewidth=3)
	plot!(x, y_approx, label="First try", linewidth=3)
end

# ╔═╡ f7774fd4-05f5-4937-b005-0c7f0c8b0614
aside(md"""
!!! warning "Déjà vu"
	If you thought for a moment that you've just seen the same graph three times, there's a reason for that.
	First, look at the axes to convince yourself they're different, but then look carefully at the ranges chosen in $x$.
	The first graph has $x$ range from $2^{-4}$ to $2^0$, the second has $2^0$ to $2^4$, and the third has $2^4$ to $2^8$.
	They're all spanning four powers of $2$.
	What about our algorithm and what about the function we're approximating gives it this almost periodic looking behavior on that particular scale?
""")

# ╔═╡ df66cd9e-34a8-48ec-bd9e-e19a99be2e77
let
	x = 16.0f0:1.0f0:256.0f0
	y_exact = inv_sqrt.(x)
	y_approx = first_try.(x)

	scatter(x, y_exact, label="Exact", linewidth=3)
	plot!(x, y_approx, label="First try", linewidth=3)
end

# ╔═╡ 0b8b5dbf-8cb3-4b86-b1cb-bf7f9d09eb68
md"""
This is a good start, but throwing out the mantissa does mean that we can't be too accurate between powers of two.
"""

# ╔═╡ 311a15f6-f956-4116-9500-7a3cab3646ef
md"## Second try: Add a step of Newton's method"

# ╔═╡ bcdd7c50-6498-4419-830d-f3ce5ef3bfa5
md"""
Taking inspiration from the original Quake algorithm, let's add a step of Newton's method.

[Newton's method](https://en.wikipedia.org/wiki/Newton%27s_method) is an iterative root-finding algorithm based on linear approximation.
Given a guess for the root, it gives you a new, hopefully better, guess.
Repeating the process to get gradually better guesses often converges to the true root.

Calculating $x = \frac{1}{\sqrt{t}}$ is the same as finding a root of $f(x) = \frac{1}{x^2} - t$.
The line commented "1st iteration" in `Q_rsqrt` is a single iteration of Newton's method on this function.
Generally Newton's method takes many iterations, but it seems that whatever bit hacking is going on befor Newton's method gives a close enough estimate that only one step of Newton's method is required for convergence.
(You can even see where they used to have two steps, but found the second was unnecessary, so commented it out.)

Let's take a closer look at Newton's method before applying it.
"""

# ╔═╡ 015ada79-56de-4f1e-9758-6b6541f392fe
let url = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Newton_iteration.svg/2365px-Newton_iteration.svg.png"
	img = download(url)
	load(img)
end

# ╔═╡ 1990740b-33f9-4330-961d-dc33bf67d2a1
md"""
The graphic above is courtesy of Wikimedia Commons: Original:  Olegalexandrov Vector:  Pbroks13, Public domain.
"""

# ╔═╡ eddd244b-6df6-4d66-ad94-aeb694c0a6be
md"""
!!! danger "Activity 3: Derive Newton's Method"
	Write the equation for the red tangent line in the image above.
	Then, derive a formula for $x_{n+1}$, the point where tangent line intersects the $x$-axis.
"""

# ╔═╡ 39034cdc-800f-4a30-8845-84dd4b7307c4
answer_box(md"""
When we have an estimate $x_n$, the linear approximation is given by 

$$y = f'(x_n) (x - x_n) + f(x_n).$$
This line has its root at the $x_{n+1}$ that satisfies

$$0 = f'(x_n) (x_{n+1} - x_n) + f(x_n),$$
which means

$$x_{n+1} = x_n - \frac{f(x_n)}{f'(x_n)}.$$
""")

# ╔═╡ bae2fcf1-82a5-4e88-b9d1-a778b2e036ef
md"""
Now, back to the problem at hand.
In our case, $f'(x) = -\frac{2}{x^3}$, so

$$\begin{align}
	x_{n+1} &= x_n - \frac{\frac{1}{x_n^2} - t}{-\frac{2}{x_n^3}} \\
			&= x_n + \frac{x_n - t x_n^3}{2} \\
			&= x_n \left( 1.5 - 0.5 t x_n^2 \right)
\end{align}$$

That's exactly the assignment done in the following line from the original code, so we know we're on the right track.
```C
y  = y * ( threehalfs - ( x2 * y * y ) );  // 1st iteration
```

Our second try at approximating $\frac{1}{\sqrt{t}}$ just adds one iteration of this formula:
"""

# ╔═╡ 684ae767-6fba-4387-8d1a-df35219aae41
aside(md"""
!!! warning "Why that f(x)?"
	The choice of $f(x) = \frac{1}{x^2} - t$ was neither unique nor arbitrary.
	Other candidates include $f(x) = \frac{1}{x} - \sqrt{t}$, $f(x) = x^2 - \frac{1}{t}$, and $f(x) = 1 - t x^2$, among infinitely many other functions that have $\frac{1}{\sqrt{t}}$ as a root.

	However, the choice of $f(x) = \frac{1}{x^2} - t$ has led to an update rule with no floating point division, only multiplicaiton and subtraction.
	This provided a minor speed boost in a clearly highly optimized function, since floating point division is slower than floating point multiplication.
	
	Derive the update rule for each of the other candidates above and you'll see that they all include floating point division (or worse, square root).
""")

# ╔═╡ 194294d9-36fc-400e-90e0-817b8ccdb880
function second_try(number::Float32)
	y = first_try(number)
	y  = y * ( 1.5f0 - ( number * 0.5f0 * y * y) ) # Newton step
end

# ╔═╡ eb56506d-5262-41ac-a021-776a8db76ad4
let
	x = 0.063f0:0.001f0:1.0f0
	y_exact = inv_sqrt.(x)
	y_approx = second_try.(x)

	scatter(x, y_exact, label="Exact", linewidth=3)
	plot!(x, y_approx, label="First try + 1 Newton step", linewidth=3)
end

# ╔═╡ 2f7ce643-5f79-4c3b-9893-67cfb588b9ca
let
	x = 1.0f0:0.1f0:16.0f0
	y_exact = inv_sqrt.(x)
	y_approx = second_try.(x)

	scatter(x, y_exact, label="Exact", linewidth=3)
	plot!(x, y_approx, label="First try + 1 Newton step", linewidth=3)
end

# ╔═╡ 79b47c58-f95c-46f8-914e-acd029988c13
let
	x = 16.0f0:1.0f0:256.0f0
	y_exact = inv_sqrt.(x)
	y_approx = second_try.(x)

	scatter(x, y_exact, label="Exact", linewidth=3)
	plot!(x, y_approx, label="First try + 1 Newton step", linewidth=3)
end

# ╔═╡ 5f1bf8b3-7eb1-4ef3-85f1-67b9c5af2788
md"""
A single Newton step isn't enough to overcome throwing away the entire mantissa, so we're not there yet.

(You can try doing a few more Newton steps, but you'll find that you would need too many for it to actually be a speed up compared to `1/sqrt(x)`.)
"""

# ╔═╡ d2c79538-f143-410e-a4fe-b6de1b09d7f0
md"## Third try: Don't delete the mantissa"

# ╔═╡ e6ffb0c9-f190-486d-9cf1-e01507676323
md"""
We started our first try by specializing to powers of four, when $m = 0$.
In that case, we operated just on the exponent, by applying the offset, multiplying by $-\frac{1}{2}$, then re-applying the offset.

To extract the exponent, we shifted the exponent bits all the way over to the least siginficant bits, where the mantissa is usually stored, but we were assuming it was zero anyway.
We could, however, do the math on the exponent in-place.
Then, we at least won't throw away the mantissa and maybe we can find something to change it however it needs after we handle the exponent.

To do so, instead of shifting `i` to the right 23 places, let's shift the offset to the left 23 places.
"""

# ╔═╡ fdd5f2ae-56f4-4da1-8df7-40c08eb1c1da
function third_try(number::Float32)
	i = reinterpret(Int32, number)      # get the bits
	offset = Int32(127) << 23 			# shift the offset into the exponent places
	j = i - offset 						# remove the offset from the exponent
	new_j = -(j >> 1)     				# bitshift by one is the same as divide by two
	new_i = new_j + offset   			# re-offset
	return reinterpret(Float32, new_i) 
end

# ╔═╡ 17b0a791-6376-4fe0-abd2-02c72e6e3a3d
md"""
There are many subtle points and edge cases to what we just did.
Here are just a few:
* What happens when $e-127$ is negative?
  (We end up using the sign bit, but only for a moment, and by the end we're no longer using it.)
* When we shift and negate the whole number, don't we change mantissa?
  (Yes, and we'll carefully examine how soon.)
* We even shift the least significant bit of the exponent into the mantissa; surely that's counter-productive?

Before we think too deeply about these subtleties, let's see how we've done with this small change.

We'll start on powers of four, since we should still be exact on them.
"""

# ╔═╡ d2509072-1409-4576-8505-0791308bfb47
let
	x = Float32.(4.0 .^ (-3:3))
	y_exact = inv_sqrt.(x)
	y_approx = third_try.(x)

	scatter(x, y_exact, label="Exact")
	plot!(x, y_approx, label="Third try", linewidth=3)
end

# ╔═╡ 480e0bc3-8e25-4bd7-88a8-b5d3f5436dc6
md"""
As expected.
Now, let's look between them.
"""

# ╔═╡ 7aa572a6-8e44-4ef9-acdb-5e7d78965406
let
	x = 0.063f0:0.001f0:1.0f0
	y_exact = inv_sqrt.(x)
	y_approx = third_try.(x)

	scatter(x, y_exact, label="Exact")
	plot!(x, y_approx, label="Third try", linewidth=3)
end

# ╔═╡ 92ac5498-4872-42ad-a307-abb919c15ed9
let
	x = 1.0f0:0.1f0:16.0f0
	y_exact = inv_sqrt.(x)
	y_approx = third_try.(x)

	scatter(x, y_exact, label="Exact", linewidth=3)
	plot!(x, y_approx, label="Third try", linewidth=3)
end

# ╔═╡ 6709aeba-eb03-49e5-8e17-a2a2f10e581f
let
	x = 16.0f0:1.0f0:256.0f0
	y_exact = inv_sqrt.(x)
	y_approx = third_try.(x)

	scatter(x, y_exact, label="Exact", linewidth=3)
	plot!(x, y_approx, label="Third try", linewidth=3)
end

# ╔═╡ 9fad9c30-1155-422a-a6a3-f1869088fe6c
md"""
That's amazing improvement between the powers of four!
Far better than one step of Newton's method provided.

But, why?

Keeping the mantissa is a good start, but why did the same operation as the exponent do so well for the mantissa?
To answer that question, we're driven to our last resort: algebra.
"""

# ╔═╡ 5188fd89-36f0-437c-b793-f3e3316e4a3d
md"## Understanding the third try"

# ╔═╡ cc5af7ef-83d4-48fd-82cc-3f2e74c95933
md"""
We begin by further examining what we did in the line `i = reinterpret(Int32, number)`.
"""

# ╔═╡ 0f1c3e22-f9ba-45ad-8f09-2624c21fb7a3
let url = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Float_example.svg/2560px-Float_example.svg.png"
	img = download(url)
	load(img)
end

# ╔═╡ 596fe10e-a0eb-42ed-ac30-d840dfc32049
md"""
Letting the sign bit be $\sigma$, the exponent be $e$, and the fraction (also known as the mantissa) be $m$, the value stored in `number` is:

$$\chi_{float} = (-1)^\sigma \left(2^{e - 127}\right) \left(1 + \frac{m}{2^{23}}\right).$$

If we instead interpret it as an integer, we have

$$\chi_{int} = -2^{31} \sigma + 2^{23} e + m.$$
The $$2^{31}$$ comes from two's complement, but is irrelevant because we can't take the square root of a negative number, so we shouldn't get a negative input.
Let's therefore assume $\sigma = 0$:

$$\begin{gather}
	\chi_{float} = \left(2^{e - 127}\right) \left(1 + \frac{m}{2^{23}}\right), \\
	\chi_{int} = 2^{23}e + m.
\end{gather}$$

The main thing to notice here is that $e$ has moved out of the exponent.
Let's compare $\chi_{int}$ to $\log_2(\chi_{float})$:

$$\begin{gather}
	\log_2(\chi_{float}) = e - 127 + \log_2 \left(1 + \frac{m}{2^{23}}\right), \\
	\chi_{int} = 2^{23}e + m.
\end{gather}$$

Now we've moved the $m$ into a logarithm.
To move it out, we use a linear approximation of $\log_2(1+x)$.
Since $m \in [0, 2^{23}), x\in [0, 1)$.
Let's use the secant approximation from the endpoints of that interval.
Since $\log_2(1 + 0) = 0$ and $\log_2(1 + 1) = 1$ our secant approximation is $\log_2(1 + x) \approx x$.
As shown below, it's accurate at both endpoints (by definition), and decently close throughout the interval.
"""

# ╔═╡ 7081b5b0-2dcc-4ab5-a26f-33965137902f
let
	x = 0:0.001:1
	plot(x, x, label="y = x", linewidth=3)
	plot!(x, log.(2, 1 .+ x), label="y = log2(1+x)", legend=:bottomright, linewidth=3)
end

# ╔═╡ 51cd4bce-dbc0-416e-9d8a-e5553f947c20
md"""
With this linear approximation,

$$\begin{gather}
	\log_2(\chi_{float}) \approx e + \frac{m}{2^{23}} - 127, \\
	\chi_{int} = 2^{23}e + m,
\end{gather}$$

so, we have the following approximate relation between the logarithm of a floating point number and the integer that results from interpreting it as an integer:

$$\log_2(\chi_{float}) \approx 2^{-23}\chi_{int} - 127.$$
"""

# ╔═╡ dd096ed9-fa6c-43c1-88e2-6c1b4843a942
md"""
!!! tip "Take note!"
	The approximate formula we've just derived is essential to how `Q_rsqrt` works!
	
	That formula is saying that when you interpret the bits of the floating point number as an integer, you're approximately taking a scaled and shifted logarithm.
	
	Consider again the case where $\chi_{float}$ is a power of four ($1.0 \times 2^{2n}$).
	The base-two logarithm will just be the exponent, $2n$.
	That information is stored in the $e$ bits of $\chi_{int}$, which we can get by performing a 23-bit right shift (which multiplies by $2^{-23}$), and then applying the offset (subtracting $127$).

	This formula exactly represents the following lines from `first_try`:
	```julia
	i = reinterpret(Int32, number)      # get the bits
	e = i >> 23                         # get just the exponent bits
	exponent = e - Int32(127)           # offset to get the exponent
	```

	What the algebra has added for us, is a justification (through the approximation of $\log_2(1 + x)$ by $x$) for this formula applying even when $m \ne 0$.
	That's why we get decent results between powers of four.
"""

# ╔═╡ 098c0aa6-6566-4b35-a657-5fffb8f74188
md"""
To continue, we use the property of logarithms that $a \log_2(b) = \log_2(b^a)$. 
We then have

$$\begin{align}
	\log_2 \left( \chi_{float}^{-\frac{1}{2}} \right) &= -\frac{1}{2} \log_2(\chi_{float}) \\
		&\approx \frac{127}{2} - 2^{-24}\chi_{int} \\
		&= 2^{-23}\left(\frac{3}{2}(127)2^{23} -\frac{\chi_{int}}{2} \right) - 127
\end{align}$$

Using our relationship between the logarithm and the interpretation as an integer, we have shown that if you interpret $(381)2^{22} -\frac{\chi_{int}}{2}$ as a floating point number, you approximately have $\chi_{float}^{-\frac{1}{2}} = \frac{1}{\sqrt{\chi_{float}}}$.

It turns out that this is exactly what we did in `third_try`:

```julia
function third_try(number::Float32)
	i = reinterpret(Int32, number)      # get the bits
	offset = Int32(127) << 23 			# shift the offset into the exponent places
	j = i - offset 						# remove the offset from the exponent
	new_j = -(j >> 1)     				# bitshift by 1 is the same as divide by 2
	new_i = new_j + offset   			# re-offset
	return reinterpret(Float32, new_i) 
end
```

$\begin{align}
	\texttt{number} &= \chi_{float} \\
	\texttt{i} 		&= \chi_{int} \\
	\texttt{offset} &= (127) 2^{23} \\
	\texttt{j} 		&= \chi_{int} - (127) 2^{23} \\
	\texttt{new\_j} &= -\frac{1}{2} \left(\chi_{int} - (127) 2^{23} \right) \\
					&= \frac{1}{2}(127) 2^{23} - \frac{\chi_{int}}{2} \\
	\texttt{new\_i} &= \frac{3}{2}(127) 2^{23} - \frac{\chi_{int}}{2} \\
					&= (381) 2^{22} - \frac{\chi_{int}}{2} \\
\end{align}$
"""

# ╔═╡ 72f19468-68c5-4800-bb34-54731929856e
aside(md"""
!!! question "Check your understanding"
	See if you can figure out expressions for third roots or inverse fourth roots.
	Does the math still work when the root isn't a power of two (i.e., square root, fourth root, eight root) or when you aren't taking the reciprocal?
	Would you be able to write as efficient code if the root weren't a power of two?
	How about without the reciprocal?

	How about if we were to use `double` instead of `float`?
	They have a different offset and number of bits for the exponent and mantissa, but otherwise the same format.
""")

# ╔═╡ 6833d950-0c20-49f9-8e3a-ac4ba5e1a2aa
md"""
This careful examination shows us that our magic number $(381) 2^{22} = \frac{3}{2}(127)2^{23}$ comes from the offset in the exponent.
It has three components: $127$, which is the offset, $2^{23}$, which corresponds to the exponent being stored $23$ bits from the right, and $\frac{3}{2} = 1 - \left(-\frac{1}{2}\right)$, coming from the $-\frac{1}{2}$ power we used to take an inverse square root.
The same explains the $-\frac{1}{2}$ coefficient on $\chi_{int}$.

Looking back at our graphs, they were closer than we initially expected, but still not quite perfect.
Let's see if we can fix the last bit with a Newton step.
"""

# ╔═╡ 14965359-348f-43de-9ed1-7ad2b57709b3
md"## Fourth try: Newton again"

# ╔═╡ 69b68bfb-c07d-4cee-b81a-19ebfaf85ad1
function fourth_try(number::Float32)
	χ_int = reinterpret(Int32, number) 
    χ_int_new = Int32(381*2^22) - ( χ_int >> 1 ) 
    y = reinterpret(Float32, χ_int_new) 
	
	y = y * ( 1.5f0 - ( number * 0.5f0 * y * y ) ) # Newton step

	return y
end

# ╔═╡ 61f3f04f-27dd-42ad-86ca-9f2048dfd726
let
	x = 0.063f0:0.001f0:1.0f0
	y_exact = inv_sqrt.(x)
	y_approx = fourth_try.(x)

	scatter(x, y_exact, label="Exact")
	plot!(x, y_approx, label="Third try + 1 Newton step", linewidth=3)
end

# ╔═╡ a4389c3a-093b-4a81-ab58-5b2b11860663
let
	x = 1.0f0:0.1f0:16.0f0
	y_exact = inv_sqrt.(x)
	y_approx = fourth_try.(x)

	scatter(x, y_exact, label="Exact")
	plot!(x, y_approx, label="Third try + 1 Newton step", linewidth=3)
end

# ╔═╡ 5d081a0f-7631-4cea-a6a1-362f2176d335
let
	x = 16.0f0:1.0f0:256.0f0
	y_exact = inv_sqrt.(x)
	y_approx = fourth_try.(x)

	scatter(x, y_exact, label="Exact")
	plot!(x, y_approx, label="Third try + 1 Newton step", linewidth=3)
end

# ╔═╡ 86f751fe-6090-4e20-9dc5-c23f3af58d66
md"""
At least visually, it's a near perfect match.
"""

# ╔═╡ 74f2355f-c5fd-4d43-a166-d26ce891a451
md"# Comparing with Quake"

# ╔═╡ 2ddaaa10-c4d6-4ede-88e1-31aefbdf5cbd
md"""
It's time to see how our code compares with the Julia version of the original code from Quake.

```julia
function Q_rsqrt( number::Float32 )
    threehalfs = 1.5f0

    x2 = number * 0.5f0
    y = number

    i = reinterpret(Int32, y)                   # evil floating point bit level hack
    i  = 0x5f3759df - ( i >> 1 )                # what the ****?
    y = reinterpret(Float32, i) 

	y  = y * ( threehalfs - ( x2 * y * y ) );   # 1st iteration
#	y  = y * ( threehalfs - ( x2 * y * y ) );   # 2nd iteration, this can be removed

    return y
end

function fourth_try( number::Float32 )
	χ_int = reinterpret(Int32, number) 
    χ_int_new = Int32(381*2^22) - ( χ_int >> 1 ) 
    y = reinterpret(Float32, χ_int_new)

	y = y * ( 1.5f0 - ( number * 0.5f0 * y * y ) ) # Newton step
	
	return y
end
```

The original `Q_rsqrt` has more temporary variables (which doesn't impact performance, but would help if the second Newton iteration weren't commented out), but other than that it appears the only difference is the original had `0x5f3759df` as its magic number and we have `381*2^22`.
Let's see what that comes out to in hexadecimal, and if we got the exact same number:
"""

# ╔═╡ eb396f10-20fc-4a81-b592-631f8c5b05a7
"0x"*string(Int32(381*2^22), base=16)

# ╔═╡ a8e8a8f1-ab1f-49be-be73-557ac7e53192
md"""
We're so close, but we're off by:
"""

# ╔═╡ 14d7b1c3-55bf-4f0e-b060-43382e2eec64
381*2^22 - 0x5f3759df 

# ╔═╡ f1acd0e6-899c-4278-9bbf-19c6c87c1b04
md"""
This comes from Quake using a different linear approximation from us.
Let's go back to our algebra for a moment.
Just before our linear approximation, we had:

$$\begin{gather}
	\log_2(\chi_{float}) = e - 127 + \log_2 \left(1 + \frac{m}{2^{23}}\right), \\
	\chi_{int} = 2^{23}e + m.
\end{gather}$$

This time, let's solve for $e$ in the second equation,

$$e = 2^{-23}(\chi_{int} - m),$$

and plug it into the first:

$$\begin{align}
	\log_2(\chi_{float}) &= 2^{-23}(\chi_{int} - m) - 127 + \log_2 \left(1 + \frac{m}{2^{23}}\right) \\
		&= 2^{-23} \chi_{int} - 127 + \left( \log_2 \left(1 + \frac{m}{2^{23}}\right) - \frac{m}{2^{23}} \right).
\end{align}$$

This exact expression (not an approximation!) is the same as the approximate formula formula we had earlier relating the floating-point and integer interpretations of the same bits, except that it has this $\log_2 \left(1 + \frac{m}{2^{23}}\right) - \frac{m}{2^{23}}$ term that depends on the mantissa.
The linear approximation we did earlier, $\log_2(1+x) \approx x$, approximated this term as zero.

One nice thing about our earlier approximation was that it didn't just get rid of the logarithm, it actually got rid of the dependence of this formula on $m$ apart from $\chi_{int}$.
We didn't have to separate out the mantissa bits and handle them separately.

The only way to preserve that propery with a new approximation is for us to still approximate $\log_2 (1 + x) - x$ as a constant, but that constant doesn't have to be $0$.
Let's call that constant $\alpha$.
Then we have the following affine approximation

$$\log_2(1 + x) \approx x + \alpha$$
"""

# ╔═╡ 7e32af84-3fe6-4dab-b4e0-aefbb648c564
md"""
!!! danger "Activity 4: Optimization by eye"
	Play with the slider to estimate a better α.
"""

# ╔═╡ c0677178-9ef7-4090-ab44-db5cc4fc6db8
md"""
α: $(@bind α_slider Slider(0:0.001:0.1; show_value=true, default=0))
"""

# ╔═╡ 8c004611-99bf-46e1-9b63-e02404b97720
let
	x = 0:0.001:1
	plot(x, x .+ α_slider, label="y = x + α", linewidth=3)
	plot!(x, log.(2, 1 .+ x), label="y = log2(1+x)", legend=:bottomright, linewidth=3)
end

# ╔═╡ ab09f51c-945d-4316-8600-338ea6a26720
md"""
With this new approximation, we have a different approximate relation between the logarithm of a floating point number and the integer that results from interpreting it as an integer:

$$\log_2(\chi_{float}) \approx 2^{-23}\chi_{int} - 127 + \alpha.$$

This gives us a slightly different formula for the inverse square root:

$$\begin{align}
	\log_2 \left( \chi_{float}^{-\frac{1}{2}} \right) &= -\frac{1}{2} \log_2(\chi_{float}) \\
		&\approx \frac{127 - \alpha}{2} - 2^{-24}\chi_{int} \\
		&= 2^{-23}\left(\frac{3}{2}(127 - \alpha)2^{23} -\frac{\chi_{int}}{2} \right) - 127 + \alpha
\end{align}$$

To find the $\alpha$ used in Quake, we set $3(127 - \alpha)2^{22} = \texttt{0x5f3759df}$.
"""

# ╔═╡ 732e87ca-b274-44d7-8b56-c11619d781fd
α = 127 - 0x5f3759df/3.0*2.0^-22

# ╔═╡ 7f6d9993-b222-4bcb-9705-6c56607db7f2
let
	x = 0:0.001:1
	plot(x, x .+ α, label="y = x + α", linewidth=3)
	plot!(x, log.(2, 1 .+ x), label="y = log2(1+x)", legend=:bottomright, linewidth=3)
end

# ╔═╡ 367e7ed7-c96e-40d7-9fc1-ca46db168bbd
md"""
The Quake linear approximation does a better job on average than our linear approximation, which is why the Quake algorith more closely approximates $\frac{1}{\sqrt{x}}$ than our algorithm.
"""

# ╔═╡ dd066c53-8648-4a36-acef-62a1868dbab8
md"# Beating Quake"

# ╔═╡ 7d5e4a43-5937-4231-b073-bd85236f483e
md"""
We can do slightly better than the original Quake by using a more exact approximation than they did.
A natural value for $\alpha$ is the average value of $\log_2(1 + x) - x$ on $[0,1)$, since it minimizes our mean squared error (MSE).
For whatever reason, this isn't the value used in Quake, but it's what we'll use now. 
By doing so, we can achieve lower average error than they did.
There are other potential options, for example minimizing mean absolute error or maximum error, but we'll stick to minimizing MSE.
"""

# ╔═╡ b7a6ef9b-1f38-447e-8d9d-3b53451c105d
begin
	x = 0:0.001:1
	avg_diff = mean(log.(2, 1 .+ x) .- x)
	@show avg_diff
	@show α
end

# ╔═╡ a0812bc1-5ae7-488f-b761-ee2f58aa7b04
begin
	magic_number = Int32(round(3*(127 - avg_diff)*2^22))
	"0x"*string(magic_number, base=16)
end

# ╔═╡ f4e26bcc-3aaf-4f6e-8bbf-e3c29a76c9f0
function final_try( number::Float32 )
	χ_int = reinterpret(Int32, number) 
    χ_int_new = magic_number - ( χ_int >> 1 ) 
    y = reinterpret(Float32, χ_int_new)
	y = y * ( 1.5f0 - ( number * 0.5f0 * y * y ) ) # Newton step
end

# ╔═╡ b1b4042a-cca6-4f38-a5d2-154a6a92dcc5
let
	x = 0.063f0:0.001f0:1.0f0
		
	y_exact = inv_sqrt.(x)
	y_approx = final_try.(x)
	y_quake = Q_rsqrt.(x)

	err_ours = abs.(y_approx .- y_exact)
	err_quake = abs.(y_quake .- y_exact)
	
	@show mean(err_ours)
	@show(mean(err_quake))
	
	plot(x, err_quake, label="Error using Quake bias", linewidth=3)
	plot!(x, err_ours, label="Error using our bias", linewidth=3)
end

# ╔═╡ f5813664-ce3c-4f4e-9f2e-3148ca232ff1
let
	x = 1.0f0:0.1f0:16.0f0
	
	y_exact = inv_sqrt.(x)
	y_approx = final_try.(x)
	y_quake = Q_rsqrt.(x)

	err_ours = abs.(y_approx .- y_exact)
	err_quake = abs.(y_quake .- y_exact)
	
	@show mean(err_ours)
	@show(mean(err_quake))

	plot(x, err_quake, label="Error using Quake bias", linewidth=3)
	plot!(x, err_ours, label="Error using our bias", linewidth=3)
end

# ╔═╡ d9f4a3cf-2c66-4c81-a23c-97386009ad48
let
	x = 16.0f0:1.0f0:256.0f0
		
	y_exact = inv_sqrt.(x)
	y_approx = final_try.(x)
	y_quake = Q_rsqrt.(x)

	err_ours = abs.(y_approx .- y_exact)
	err_quake = abs.(y_quake .- y_exact)
	
	@show mean(err_ours)
	@show(mean(err_quake))

	plot(x, err_quake, label="Error using Quake bias", linewidth=3)
	plot!(x, err_ours, label="Error using our bias", linewidth=3)
end

# ╔═╡ 51f23d3f-f545-45e1-b593-95542d77ee40
md"""
!!! danger "Activity 5: Doing even better (Optional, Advanced)"
	We got a more accurate estimate by updating our linear approximation with a bias to match the average value with that of the function it was approximating.
	We limited ourselves to changing the offset because we wanted to replace $\log_2 \left( 1 + \frac{m}{2^{23}} \right) - \frac{m}{2^{23}}$ with a term that didn't depend on $m$ apart from $\chi_{int}$.
	We could potentially get a better fit if instead of replacing the expression with a constant, we replaced it with a simple expression in terms of $m$ and then extracted $m$ from $\chi_{int}$.

	We can extract $m$ from $\chi_{int}$ using the bitwise-and operation.
	That would be written as 
	`00000000011111111111111111111111 & chi_int`,
	or more concisely as
	`0x7FFFFF & chi_int`
	in either C or Julia.
	The zeros wipe away the sign bit and the exponent bits, while the ones maintain the mantissa bits.
	
	Try seeing if you can come up with a better approximation of $\log_2 ( 1 + x ) - x$; perhaps a parabola?
	Then, write some code that operates on $m$ to get the corrective term and add it in to `third_try`.
	See if your code is still faster than `1 / sqrt( number )`.
	Can you get both more accurate and faster than `Q_rsqrt`?
	Can you come up with an approximation that's close enough that you can remove the Newton step?
	Alternatively, it may be better to use this masking trick to separately handle the exponent and mantissa.
	
	Good luck!
"""

# ╔═╡ 12985fd3-213d-4275-b87f-e92f239baf87
md"# Utilities"

# ╔═╡ e252bfdd-7340-4c3a-8621-86402987fe85
function display_float(x::Float32, verbose=false)
	bits = bitstring(x)
	
	# Sign bit
	sgn_bit = bits[1]
	sgn = sgn_bit == '0' ? "+" : "-"
	
	# Exponent
	exp_bits = bits[2:9]
	e = parse(UInt8, exp_bits, base=2)
	exponent = e - 127
	
	# Mantissa
	m_bits = bits[10:end]
	m = parse(UInt32, m_bits, base=2)
	mantissa = 1 + m / 2^23
	
	println(x, " is ", sgn_bit, " ", exp_bits, " ", m_bits)
	println(x, " is represented as ", sgn, mantissa, " × 2^", exponent )
	
	if verbose
		println()
		println("Sign bit: ", bits[1], ", i.e., ", sgn)
		println()
		println("Exponent bits: ", exp_bits, ", i.e., ", e)
		println("Exponent: ", exponent)
		println()
		println("Mantissa bits: ", m_bits, ", i.e., ", m, " / 2^23")
		println("Mantissa: ", mantissa)
	end
end

# ╔═╡ f95adaf6-3263-43c2-b4e2-1c1fcfd166ea
display_float(Float32(2.0), true)

# ╔═╡ d3aa545f-009f-45fe-864d-bf425ec63234
display_float(Float32(-12.0), false)

# ╔═╡ fd9830cb-6816-4a5b-81f2-c304e9d00ed3
display_float(Float32(π), true)

# ╔═╡ f33ac63c-b2d3-46dd-8238-d0cde3b6466b
display_float(Float32(-3.0), true)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
ImageIO = "82e4d734-157c-48bb-816b-45c225c6df19"
ImageShow = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BenchmarkTools = "~1.3.2"
FileIO = "~1.16.1"
HypertextLiteral = "~0.9.4"
ImageIO = "~0.6.7"
ImageShow = "~0.3.8"
Plots = "~1.39.0"
PlutoTeachingTools = "~0.2.13"
PlutoUI = "~0.7.52"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "2d3ad58d4a9e7944364e03fe9b01a4bbaf7fa7c3"

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
git-tree-sha1 = "68c4c187a232e7abe00ac29e3b03e09af9d77317"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.7.0"

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

    [deps.Adapt.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

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

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

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

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "299dc33549f68299137e51e6d49a13b5b1da9673"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.1"

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
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "fc5d1d3443a124fde6e92d0260cd9e064eba69f8"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.1"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "bca20b2f5d00c4fbc192c3212da8fa79f4688009"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.7"

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
git-tree-sha1 = "3d09a9f60edf77f8a4d99f9e015e8fbf9989605d"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.7+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "ea8031dea4aff6bd41f1df8f2fdfb25b33626381"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IntervalSets]]
deps = ["Dates", "Random"]
git-tree-sha1 = "3d8866c029dd6b16e69e0d4a939c4dfcb98fac47"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.8"
weakdeps = ["Statistics"]

    [deps.IntervalSets.extensions]
    IntervalSetsStatisticsExt = "Statistics"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterTools]]
git-tree-sha1 = "4ced6667f9974fc5c5943fa5e2ef1ca43ea9e450"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.8.0"

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

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "d65930fa2bc96b07d7691c652d701dcbe7d9cf0b"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.4"

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

[[deps.MappedArrays]]
git-tree-sha1 = "2dab0221fe2b0f2cb6754eaa743cc266339f527e"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.2"

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

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "2ac17d29c523ce1cd38e27785a7d23024853a4bb"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.10"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "a4ca623df1ae99d09bc9868b008262d0c0ac1e4f"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.4+0"

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

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "5ded86ccaf0647349231ed6c0822c10886d4a1ee"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.1"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

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

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

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

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "00099623ffee15972c16111bcf84c58a0051257c"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.9.0"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

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

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

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
git-tree-sha1 = "a38e7d70267283888bc83911626961f0b8d5966f"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.9"

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

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "5165dfb9fd131cf0c6957a3a7605dede376e7b63"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.0"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

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

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "34cc045dd0aaa59b8bbe86c644679bc57f1d5bd0"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.8"

[[deps.TranscodingStreams]]
git-tree-sha1 = "49cbf7c74fafaed4c529d47d48c8f7da6a19eb75"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.10.1"
weakdeps = ["Random", "Test"]

    [deps.TranscodingStreams.extensions]
    TestExt = ["Test", "Random"]

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

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

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

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
# ╠═e0965f38-8d73-11ee-00ee-0f163204f5f6
# ╟─a184e2ba-1618-473a-8ed5-631be9c8ffec
# ╟─99cd93dd-ae07-46da-8bc2-9ae2fdca2475
# ╟─c94ff537-feb7-4555-acfc-5d82969a8c99
# ╟─6c433ba7-1456-49b7-a674-59056e36d805
# ╟─6fce0d3b-01db-4597-9bad-ce4a3df465ac
# ╟─3f65daf9-96f9-44a8-b396-2b785e779a45
# ╟─1fce9542-b0d7-43cd-872e-964265b48a06
# ╟─689c5e83-bea8-4c55-afb7-4de66390cad5
# ╠═9aef30cc-1661-48ce-b26c-b7e7a0fa81a4
# ╠═8a95044d-4e6a-4e59-bf5a-322b2f7274ab
# ╠═12f8bc93-8dfa-4e0c-b037-7d09093a63b8
# ╟─450feb25-55ee-49ee-935a-f8d215f7a8ad
# ╠═8ba712b7-85da-45e7-a361-5edc0432415e
# ╠═dffd72a2-a814-4c3d-9dd1-c0e1d58b1c51
# ╟─86eacaf7-67f0-40a3-a29c-4669229cd47b
# ╟─c5f88b35-a63a-4f0e-bd2f-0844d256795e
# ╟─c4e3008c-d544-4a87-8659-93026a381584
# ╟─8b923508-0369-42bf-8cc8-6d3166b1f307
# ╟─57e2aec8-8c1f-46c3-8d5d-f9bac77a20e0
# ╟─255a2d77-f890-4bbd-90a6-cb7fcf7b920d
# ╟─24ce88da-c4e6-4e84-92f7-49ba3b3491ac
# ╠═b655a525-f832-4c51-8980-cf8aeb4ef4d6
# ╟─c6c400af-9021-44a3-9039-7ef81c178caf
# ╟─62d19499-2346-4920-926d-72b899035598
# ╟─8fd356b9-eea8-40c2-8513-916344c63dc9
# ╟─ca6e2b22-d244-4925-ac25-065fc1178df9
# ╟─cb14ccc4-be9a-447f-860a-6b307de799fc
# ╠═f95adaf6-3263-43c2-b4e2-1c1fcfd166ea
# ╟─a31c585d-21ce-468e-a18f-0ed2cbbb03b7
# ╠═d3aa545f-009f-45fe-864d-bf425ec63234
# ╠═fd9830cb-6816-4a5b-81f2-c304e9d00ed3
# ╟─5008eef1-861e-4010-828c-2dacdbdeacff
# ╟─b4b8f416-18c8-40d5-89fc-39f99d732ec6
# ╟─2006d955-773f-47be-84c7-008e2a2734a2
# ╟─775be446-ea43-4c92-9508-34c6d1bd8d62
# ╟─83ce84ed-ea45-4df1-a8ca-2a20fe18d610
# ╠═f0ba969b-fa16-42e8-997b-654c4f71e7fd
# ╟─01d979b5-4dce-4ab2-98de-02424788a8ce
# ╠═3bde82cf-4995-4ae1-82ac-cd8e62c8576a
# ╟─b9b2f39b-b114-4ae8-8c15-e0482b68c55e
# ╟─3b651cb4-f2f2-430e-b670-5834421706c6
# ╟─c904916d-119e-4eb5-8ae3-4e837be97cef
# ╠═0448cc27-38a3-4b86-9506-2e072078b562
# ╟─f7774fd4-05f5-4937-b005-0c7f0c8b0614
# ╠═df66cd9e-34a8-48ec-bd9e-e19a99be2e77
# ╟─0b8b5dbf-8cb3-4b86-b1cb-bf7f9d09eb68
# ╟─311a15f6-f956-4116-9500-7a3cab3646ef
# ╟─bcdd7c50-6498-4419-830d-f3ce5ef3bfa5
# ╟─015ada79-56de-4f1e-9758-6b6541f392fe
# ╟─1990740b-33f9-4330-961d-dc33bf67d2a1
# ╟─eddd244b-6df6-4d66-ad94-aeb694c0a6be
# ╟─39034cdc-800f-4a30-8845-84dd4b7307c4
# ╟─bae2fcf1-82a5-4e88-b9d1-a778b2e036ef
# ╟─684ae767-6fba-4387-8d1a-df35219aae41
# ╠═194294d9-36fc-400e-90e0-817b8ccdb880
# ╠═eb56506d-5262-41ac-a021-776a8db76ad4
# ╠═2f7ce643-5f79-4c3b-9893-67cfb588b9ca
# ╠═79b47c58-f95c-46f8-914e-acd029988c13
# ╟─5f1bf8b3-7eb1-4ef3-85f1-67b9c5af2788
# ╟─d2c79538-f143-410e-a4fe-b6de1b09d7f0
# ╟─e6ffb0c9-f190-486d-9cf1-e01507676323
# ╠═fdd5f2ae-56f4-4da1-8df7-40c08eb1c1da
# ╟─17b0a791-6376-4fe0-abd2-02c72e6e3a3d
# ╟─d2509072-1409-4576-8505-0791308bfb47
# ╟─480e0bc3-8e25-4bd7-88a8-b5d3f5436dc6
# ╠═7aa572a6-8e44-4ef9-acdb-5e7d78965406
# ╠═92ac5498-4872-42ad-a307-abb919c15ed9
# ╠═6709aeba-eb03-49e5-8e17-a2a2f10e581f
# ╟─9fad9c30-1155-422a-a6a3-f1869088fe6c
# ╟─5188fd89-36f0-437c-b793-f3e3316e4a3d
# ╟─cc5af7ef-83d4-48fd-82cc-3f2e74c95933
# ╟─0f1c3e22-f9ba-45ad-8f09-2624c21fb7a3
# ╟─596fe10e-a0eb-42ed-ac30-d840dfc32049
# ╠═7081b5b0-2dcc-4ab5-a26f-33965137902f
# ╟─51cd4bce-dbc0-416e-9d8a-e5553f947c20
# ╟─dd096ed9-fa6c-43c1-88e2-6c1b4843a942
# ╟─098c0aa6-6566-4b35-a657-5fffb8f74188
# ╟─72f19468-68c5-4800-bb34-54731929856e
# ╟─6833d950-0c20-49f9-8e3a-ac4ba5e1a2aa
# ╟─14965359-348f-43de-9ed1-7ad2b57709b3
# ╠═69b68bfb-c07d-4cee-b81a-19ebfaf85ad1
# ╠═61f3f04f-27dd-42ad-86ca-9f2048dfd726
# ╠═a4389c3a-093b-4a81-ab58-5b2b11860663
# ╠═5d081a0f-7631-4cea-a6a1-362f2176d335
# ╟─86f751fe-6090-4e20-9dc5-c23f3af58d66
# ╟─74f2355f-c5fd-4d43-a166-d26ce891a451
# ╟─2ddaaa10-c4d6-4ede-88e1-31aefbdf5cbd
# ╠═eb396f10-20fc-4a81-b592-631f8c5b05a7
# ╟─a8e8a8f1-ab1f-49be-be73-557ac7e53192
# ╠═14d7b1c3-55bf-4f0e-b060-43382e2eec64
# ╟─f1acd0e6-899c-4278-9bbf-19c6c87c1b04
# ╟─7e32af84-3fe6-4dab-b4e0-aefbb648c564
# ╟─c0677178-9ef7-4090-ab44-db5cc4fc6db8
# ╟─8c004611-99bf-46e1-9b63-e02404b97720
# ╟─ab09f51c-945d-4316-8600-338ea6a26720
# ╠═732e87ca-b274-44d7-8b56-c11619d781fd
# ╟─7f6d9993-b222-4bcb-9705-6c56607db7f2
# ╟─367e7ed7-c96e-40d7-9fc1-ca46db168bbd
# ╟─dd066c53-8648-4a36-acef-62a1868dbab8
# ╟─7d5e4a43-5937-4231-b073-bd85236f483e
# ╠═b7a6ef9b-1f38-447e-8d9d-3b53451c105d
# ╠═a0812bc1-5ae7-488f-b761-ee2f58aa7b04
# ╠═f4e26bcc-3aaf-4f6e-8bbf-e3c29a76c9f0
# ╠═b1b4042a-cca6-4f38-a5d2-154a6a92dcc5
# ╠═f5813664-ce3c-4f4e-9f2e-3148ca232ff1
# ╠═d9f4a3cf-2c66-4c81-a23c-97386009ad48
# ╟─51f23d3f-f545-45e1-b593-95542d77ee40
# ╟─12985fd3-213d-4275-b87f-e92f239baf87
# ╟─e252bfdd-7340-4c3a-8621-86402987fe85
# ╟─f33ac63c-b2d3-46dd-8238-d0cde3b6466b
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
