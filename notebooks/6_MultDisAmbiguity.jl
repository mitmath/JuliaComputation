### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ 208180e6-9686-4105-985d-fa9232ff8a7e
md"""
# Multiple Dispatch Ambiguity
"""

# ╔═╡ f01c27c9-e246-4a11-a856-5e1103b541db
f(a::Number, b::Integer) = "(ℝ , ℤ)"

# ╔═╡ 83a1215f-93fe-4844-8cd8-2243cd4f2925
f(a::Integer, b:: Number) = "(ℤ , ℝ)"

# ╔═╡ e5d21d57-856e-4c15-87fc-82471afceb35
f(a::Number, b:: Number) = "(ℝ , ℝ)"

# ╔═╡ a9fcb40a-549d-445d-892e-3e0c8e33237f
f(1.0,1)

# ╔═╡ f45c6ce8-6f93-4c5f-8f7e-198a5203a039
f(1,1.0)

# ╔═╡ 7d98b956-7445-4ec1-8fff-db27ff7ab3dd
f(1.0,1.0)

# ╔═╡ acdc9c3f-d302-4bc4-b920-f227f3004f38
f(1,1)

# ╔═╡ Cell order:
# ╟─208180e6-9686-4105-985d-fa9232ff8a7e
# ╠═f01c27c9-e246-4a11-a856-5e1103b541db
# ╠═83a1215f-93fe-4844-8cd8-2243cd4f2925
# ╠═e5d21d57-856e-4c15-87fc-82471afceb35
# ╠═a9fcb40a-549d-445d-892e-3e0c8e33237f
# ╠═f45c6ce8-6f93-4c5f-8f7e-198a5203a039
# ╠═7d98b956-7445-4ec1-8fff-db27ff7ab3dd
# ╠═acdc9c3f-d302-4bc4-b920-f227f3004f38
