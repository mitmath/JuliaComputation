### A Pluto.jl notebook ###
# v0.19.11

#> [frontmatter]
#> title = "HW1b - Matrix calculus"
#> date = "2022-09-16"

using Markdown
using InteractiveUtils

# ╔═╡ f6cdf6d4-35cd-11ed-1c5c-db3e4aec3adb
md"""
Homework 1b of the MIT Course [_Julia: solving real-world problems with computation_](https://github.com/mitmath/JuliaComputation)

Release date: Friday, Sep 16, 2022 (version 1)

**Due date: Thursday, Sep 22, 2022 (11:59pm EST)**

Submission by: Jazzy Doe (jazz@mit.edu)
"""

# ╔═╡ 6cc8e719-fb27-478c-a362-a51e65c152a9
student = (name = "Jazzy Doe", kerberos_id = "jazz")

# ╔═╡ d411f114-76e5-45b3-b257-8936227c45bc
md"""
# Matrix calculus
"""

# ╔═╡ 14ac9e7e-206e-4472-af05-b3d1ccf0010f
md"""
For each function $f(x)$, work out the linear transformation $f'(x)$ such that $df = f'(x) dx$.
Check your answers numerically using Julia by computing $f(x+e)-f(x)$ for some random $x$ and (small) $e$, and comparing with $f'(x)e$.
We use lowercase $x$ for vectors and uppercase $X$ for matrices.
"""

# ╔═╡ 5aed70bc-d518-4c0a-b650-cd6ff60f2db0
md"""
!!! warning "Instructions"
	Please write the mathematical part of each answer inside a Markdown cell, and the experimental part inside one or several code cells.
"""

# ╔═╡ 12e51959-e16d-424d-a663-e316adb78e0e
md"""
!!! info "Tips"
	To write math in a Markdown cell, just surround it with dollars and use basic LaTeX syntax, like this:
	
	$\sum_{n=1}^{\infty} \frac{1}{n^2} = \frac{\pi^2}{6}$
"""

# ╔═╡ 245f4f38-9aed-4d7b-b1e1-4294ac6c477f
md"""
## Question 1

 $f \colon x \in \mathbb{R}^n \longmapsto (x^\top x)^2$. Hint: use the chain rule $df(g)=f'(g)dg$
"""

# ╔═╡ f07be691-99c3-47ce-b963-c7452338f0fa
md"""
Your answer (with justification) goes here
"""

# ╔═╡ cd1d0fbe-5760-4100-ad49-7b94e368df3d
# Your code goes here

# ╔═╡ a36c286b-d6d6-4f9f-ad86-b4046a77663d
md"""
## Question 2

 $f \colon x \in \mathbb{R}^n \longmapsto \log.(x)$, meaning the elementwise application of the $\log$ function to each entry of the vector $x$, whose result is another vector of $\mathbb{R}^n$.
"""

# ╔═╡ 86a96dbb-c018-45b2-b6dd-35bd47051f7f
md"""
Your answer (with justification) goes here
"""

# ╔═╡ ed3beb6f-42ac-4787-b4f1-78169e53678b
# Your code goes here

# ╔═╡ 4fcc5b25-0df2-4125-9e5a-9357e56f8e13
# and here

# ╔═╡ 9be9d847-36ce-4461-aa85-5da3e82cc1ec
# and maybe here too

# ╔═╡ 87c518d1-632d-4b27-9b4d-69bc2300b569
md"""
## Question 3

 $f \colon X \in \mathbb{R}^{n \times m} \longmapsto \theta^\top X$, where $\theta \in R^n$ is a vector
"""

# ╔═╡ a2e57067-52c6-4a5c-95fd-ae655418fa48
md"""
Your answer (with justification) goes here
"""

# ╔═╡ 1ef4387c-59f0-443d-8d8c-26aa8d1c1e0f
# Your code goes here

# ╔═╡ 39d7205b-4de0-4e60-9def-39c3cdc09f52
md"""
## Question 4

 $f \colon X \in \mathbb{R}^{n \times n} \longmapsto X^{-2}$, where $X$ is non-singular. Hint: use the chain rule and remember $d(X^{-1}) = -X^{-1} (dX) X^{-1}$ and $d(X^2)=X (dX) + (dX) X.$
"""

# ╔═╡ fa193ad5-e527-4d48-8c39-e428252c1ccd
md"""
Your answer (with justification) goes here
"""

# ╔═╡ 3e80bec0-b8dc-406e-bc6b-b1a7d1df5f60
# Your code goes here

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.1"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╟─f6cdf6d4-35cd-11ed-1c5c-db3e4aec3adb
# ╠═6cc8e719-fb27-478c-a362-a51e65c152a9
# ╟─d411f114-76e5-45b3-b257-8936227c45bc
# ╟─14ac9e7e-206e-4472-af05-b3d1ccf0010f
# ╟─5aed70bc-d518-4c0a-b650-cd6ff60f2db0
# ╠═12e51959-e16d-424d-a663-e316adb78e0e
# ╟─245f4f38-9aed-4d7b-b1e1-4294ac6c477f
# ╠═f07be691-99c3-47ce-b963-c7452338f0fa
# ╠═cd1d0fbe-5760-4100-ad49-7b94e368df3d
# ╟─a36c286b-d6d6-4f9f-ad86-b4046a77663d
# ╠═86a96dbb-c018-45b2-b6dd-35bd47051f7f
# ╠═ed3beb6f-42ac-4787-b4f1-78169e53678b
# ╠═4fcc5b25-0df2-4125-9e5a-9357e56f8e13
# ╠═9be9d847-36ce-4461-aa85-5da3e82cc1ec
# ╟─87c518d1-632d-4b27-9b4d-69bc2300b569
# ╠═a2e57067-52c6-4a5c-95fd-ae655418fa48
# ╠═1ef4387c-59f0-443d-8d8c-26aa8d1c1e0f
# ╟─39d7205b-4de0-4e60-9def-39c3cdc09f52
# ╠═fa193ad5-e527-4d48-8c39-e428252c1ccd
# ╠═3e80bec0-b8dc-406e-bc6b-b1a7d1df5f60
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
