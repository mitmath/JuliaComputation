### A Pluto.jl notebook ###
# v0.19.11

using Markdown
using InteractiveUtils

# ╔═╡ 095fe061-b141-4329-a598-89987e69ddb9


# ╔═╡ 41f2ea0a-34ea-11ed-0bad-b90a0169251a
T(c::Number) = x -> c * x

# ╔═╡ 8054ab1a-e6ef-41db-951d-faa101364986
T(w::Vector) = x::Vector -> w'x  # could write w ⋅ x "cdot" with linalg

# ╔═╡ 3267a067-0613-42fc-9304-d4370c01fff9
T(A::Matrix) = x::Vector -> A*x

# ╔═╡ 2837c741-ca74-436e-9065-6b86f4e3fd9b
T(10)(1)

# ╔═╡ bfbe6a47-61d9-436c-8c42-323ff7966c3b
T(10)([1,2,3,4])

# ╔═╡ 3a501d1b-4a19-40c4-925d-0e20bd892904
T(10)([1 2;3 4])

# ╔═╡ b25fe8e8-dff6-4c38-9e23-e3b7ff00f42b
T([1,2,3,4])([5,6,7,8])

# ╔═╡ dde18f54-b212-4792-bf08-83b6c82b1ed6


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.0-rc4"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╠═095fe061-b141-4329-a598-89987e69ddb9
# ╠═41f2ea0a-34ea-11ed-0bad-b90a0169251a
# ╠═2837c741-ca74-436e-9065-6b86f4e3fd9b
# ╠═bfbe6a47-61d9-436c-8c42-323ff7966c3b
# ╠═3a501d1b-4a19-40c4-925d-0e20bd892904
# ╠═8054ab1a-e6ef-41db-951d-faa101364986
# ╠═b25fe8e8-dff6-4c38-9e23-e3b7ff00f42b
# ╠═3267a067-0613-42fc-9304-d4370c01fff9
# ╠═dde18f54-b212-4792-bf08-83b6c82b1ed6
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
