### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ ee32f9cc-c276-11f1-3f2b-6d02acc278ee
md"""
# Homework 3: Automatic Differentiation

**Due Monday, October 19, 2026 at 11:59 PM EDT.**

Automatic differentiation (AD) differentiates a program by applying the chain
rule to its elementary operations. In this homework you will build small,
transparent versions of forward mode and reverse mode, then use forward mode
to compute a Jacobian.

Work in this notebook and replace each `TODO` with your own code. You may use
an LLM to discuss ideas, but you should be able to explain every line you
submit.
"""

# ╔═╡ ee331470-c276-11f1-0639-eb08186537cd
student = (name = "Your name", kerberos_id = "your_kerberos")

# ╔═╡ ee331fce-c276-11f1-1425-bbac96792761
md"""
## 1. Forward mode: dual numbers

A dual number stores a value and its derivative:

\$a + b\varepsilon, \qquad \varepsilon^2 = 0.\$

For example,
\$(a + b\varepsilon)(c + d\varepsilon) = ac + (ad + bc)\varepsilon\$.
The `value` field is the ordinary computation and `tangent` field carries its
derivative forward.
"""

# ╔═╡ ee3322da-c276-11f1-39e8-770a31e6854c
struct Dual{T}
    value::T
    tangent::T
end

# ╔═╡ ee3325b4-c276-11f1-115e-036045fa36ed
md"""
### Problem 1a — elementary operations

Implement `+`, `-`, `*`, `/`, `sin`, and `exp` for `Dual` numbers. Your methods
should also allow a `Dual` number to interact naturally with an ordinary real
number. Use the chain rule rather than numerical finite differences.
"""

# ╔═╡ ee332848-c276-11f1-373b-bb0864def4b5
Base.:+(a::Dual, b::Dual) = Dual(a.value + b.value, a.tangent + b.tangent)
Base.:-(a::Dual, b::Dual) = Dual(a.value - b.value, a.tangent - b.tangent)
Base.:-(a::Dual) = Dual(-a.value, -a.tangent)

# Replace the following definitions and add the missing scalar methods.
Base.:*(a::Dual, b::Dual) = error("TODO: implement multiplication for Dual")
Base.:/(a::Dual, b::Dual) = error("TODO: implement division for Dual")
Base.sin(a::Dual) = error("TODO: implement sin for Dual")
Base.exp(a::Dual) = error("TODO: implement exp for Dual")

# ╔═╡ ee332b0e-c276-11f1-0f9c-9bb295acdb87
md"""
### Problem 1b — one derivative

Complete `forward_derivative`. If you evaluate `f(Dual(x, 1))`, the tangent of
the result is \$f'(x)\$. Verify your answer on
\$f(x) = x\sin(x) + e^x\$ at `x = 0.7`, and compare it to the analytic
derivative.
"""

# ╔═╡ ee332c80-c276-11f1-2bf0-eba013561d94
function forward_derivative(f, x)
    # TODO
end

# ╔═╡ ee332cda-c276-11f1-2bf1-a96334c3b527
f_scalar(x) = x * sin(x) + exp(x)
analytic_fprime(x) = sin(x) + x * cos(x) + exp(x)

# ╔═╡ ee332d72-c276-11f1-0f29-a377e289df04
md"""
### Problem 1c — a directional derivative

For \$g : \mathbb{R}^n \to \mathbb{R}\$, seed every input coordinate with a
direction \$v\$. Complete `directional_derivative(g, x, v)` so it returns
\$\nabla g(x)^\top v\$.

Use your function for \$g(x) = x_1^2x_2 + \sin(x_2)\$, at
`x = [2.0, 0.3]` in the direction `v = [1.0, -2.0]`.
"""

# ╔═╡ ee332f50-c276-11f1-0451-65af098e2013
g(x) = x[1]^2 * x[2] + sin(x[2])

# ╔═╡ ee3330ea-c276-11f1-063c-23135a49a59d
function directional_derivative(g, x, v)
    # Hint: construct Dual.(x, v), evaluate g, and return its tangent.
    # TODO
end

# ╔═╡ ee3332ac-c276-11f1-1d59-97870e2eb437
md"""
## 2. Reverse mode: work backward once

Forward mode carries one input direction forward. Reverse mode instead starts
with one output sensitivity and propagates sensitivities backward. This is why
reverse mode is especially effective for a scalar loss function with many
parameters.

Consider the program

```julia
a = x * y
b = sin(x)
L = a + b
```

The reverse pass begins with `∂L/∂L = 1`. Follow the arrows backward and apply
the chain rule to obtain `∂L/∂x` and `∂L/∂y`.
"""

# ╔═╡ ee3334be-c276-11f1-38e1-6d88a9688109
loss(x, y) = x * y + sin(x)

# ╔═╡ ee33350c-c276-11f1-2eea-c97dd3fef559
md"""
### Problem 2 — hand-coded reverse pass

Implement `reverse_gradient(x, y)` without calling any AD package. Return a
named tuple `(dx = ..., dy = ...)`. Include brief comments identifying the
adjoint of `a`, the adjoint of `b`, and the contributions to `x`.

Check your result at `x = 0.4`, `y = -1.2` against the derivatives you compute
on paper.
"""

# ╔═╡ ee3338ce-c276-11f1-17ed-39e0259781ff
function reverse_gradient(x, y)
    # TODO
end

# ╔═╡ ee333dee-c276-11f1-3336-83d738acd6a7
md"""
## 3. Jacobians from repeated forward passes

For a vector-valued function \$F : \mathbb{R}^n \to \mathbb{R}^m\$, the
Jacobian is the \$m \times n\$ matrix whose `j`th column is the directional
derivative in the coordinate direction \$e_j\$.

Let
\[
F(x_1,x_2) = \begin{bmatrix}
x_1x_2 \\
\sin(x_1) + x_2^2
\end{bmatrix}.
\]
"""

# ╔═╡ ee333f36-c276-11f1-32fe-651067f1e8a0
F(x) = [x[1] * x[2], sin(x[1]) + x[2]^2]

# ╔═╡ ee33408c-c276-11f1-2fcf-dfb1e3f8b5de
md"""
### Problem 3 — build a Jacobian

Complete `jacobian_forward(F, x)` using the `Dual` type from Part 1. Do not use
finite differences or an AD package. It should work for any vector-valued
function that accepts a vector of dual numbers.

Evaluate it at `x = [1.0, 2.0]`, then write the analytic Jacobian by hand and
confirm the two agree.
"""

# ╔═╡ ee334238-c276-11f1-1cfc-53b41f0b5b47
function jacobian_forward(F, x)
    # Hint: make one seed vector for each coordinate direction e_j.
    # TODO
end

# ╔═╡ ee3342e2-c276-11f1-2e53-e789fbc1143d
md"""
## 4. Reflection

In 4–8 sentences, answer both questions:

1. Why does forward mode need one pass per input direction to build a full
   Jacobian?
2. Why is reverse mode attractive for a scalar loss depending on millions of
   parameters, as in machine learning?

Finally, name one operation or Julia program pattern for which you would be
cautious before assuming that an AD system will work automatically.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.9"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╠═ee32f9cc-c276-11f1-3f2b-6d02acc278ee
# ╠═ee331470-c276-11f1-0639-eb08186537cd
# ╠═ee331fce-c276-11f1-1425-bbac96792761
# ╠═ee3322da-c276-11f1-39e8-770a31e6854c
# ╠═ee3325b4-c276-11f1-115e-036045fa36ed
# ╠═ee332848-c276-11f1-373b-bb0864def4b5
# ╠═ee332b0e-c276-11f1-0f9c-9bb295acdb87
# ╠═ee332c80-c276-11f1-2bf0-eba013561d94
# ╠═ee332cda-c276-11f1-2bf1-a96334c3b527
# ╠═ee332d72-c276-11f1-0f29-a377e289df04
# ╠═ee332f50-c276-11f1-0451-65af098e2013
# ╠═ee3330ea-c276-11f1-063c-23135a49a59d
# ╠═ee3332ac-c276-11f1-1d59-97870e2eb437
# ╠═ee3334be-c276-11f1-38e1-6d88a9688109
# ╠═ee33350c-c276-11f1-2eea-c97dd3fef559
# ╠═ee3338ce-c276-11f1-17ed-39e0259781ff
# ╠═ee333dee-c276-11f1-3336-83d738acd6a7
# ╠═ee333f36-c276-11f1-32fe-651067f1e8a0
# ╠═ee33408c-c276-11f1-2fcf-dfb1e3f8b5de
# ╠═ee334238-c276-11f1-1cfc-53b41f0b5b47
# ╠═ee3342e2-c276-11f1-2e53-e789fbc1143d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
