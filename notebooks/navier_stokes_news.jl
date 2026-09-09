### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto,
# the following mock version gives bound variables a default value.
macro bind(def, element)
    quote
        local iv = try
            Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value
        catch
            b -> missing
        end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0001
begin
    using PlutoUI
    using Plots
    using Statistics
end

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0002
md"""
# Navier–Stokes in the news: can a flow blow up?

Today we will learn enough about fluid equations to understand the question behind the
recent news. We will use a simple interactive experiment to see how a flow can steepen,
spread, and lose energy.

This notebook is a lesson, not a proof of a Millennium Prize problem. The reported result
is new and requires careful checking by mathematicians. Our goal is to understand the
equations and to ask better questions about the claim.
"""

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0003
md"""
## Start with the question

The incompressible Navier–Stokes equations describe the velocity field **u** and pressure
`p` of a fluid with viscosity `ν`:

$$\partial_t \mathbf{u} + (\mathbf{u}\cdot\nabla)\mathbf{u}
= -\nabla p + \nu\Delta\mathbf{u} + \mathbf{f},$$

$$\nabla\cdot\mathbf{u}=0.$$

The first equation is Newton’s law for a tiny piece of fluid. The nonlinear term transports
the velocity by the flow itself; the Laplacian spreads out sharp features; pressure keeps
the flow incompressible. In three dimensions, the central open question is whether smooth
initial data can develop an infinite velocity or derivative in finite time.

In one dimension, incompressibility makes the problem too simple. But if we keep the
transport and viscosity terms, we get the **viscous Burgers equation**:

$$\partial_t u + u\,\partial_x u = \nu\,\partial_{xx}u.$$

It is a small model with the same tug-of-war: nonlinear steepening versus diffusive
smoothing. It is perfect for an experiment we can understand from calculus.
"""

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0004
md"""
## A few links for the news discussion

- [Nature's report on the claimed result](https://www.nature.com/articles/d41586-026-02842-5)
- [The Guardian's report and context](https://www.theguardian.com/science/2026/sep/08/openai-claims-to-have-solved-elusive-maths-problem)
- [Steven Strogatz's post on X](https://x.com/stevenstrogatz/status/2097390631303663840?s=46&t=FGZ6qOY7zA1xiXb4dlU5ZA)
- [The Clay Mathematics Institute problem statement](https://www.claymath.org/millennium-problems/navier-stokes-equation/)

As you read, separate three claims: a numerical experiment, a convincing mathematical
argument, and a proof that meets the Clay problem's exact requirements.
"""

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0005
md"""
## Experiment: make a wave move and smooth

We put a sinusoidal flow on a periodic interval. The sliders change the initial amplitude,
the viscosity, and the time at which we look. The solver uses a conservative finite-difference
scheme, so every displayed curve is computed from the equation rather than drawn by hand.

Initial amplitude `A`: $(@bind A Slider(0.2:0.05:1.5; default=0.8, show_value=true))

Viscosity `ν`: $(@bind ν Slider(0.005:0.005:0.3; default=0.08, show_value=true))

Time `t`: $(@bind t_view Slider(0.0:0.02:2.0; default=0.6, show_value=true))
"""

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0006
function burgers_run(ν, A, t_view; N=160)
    x = collect(range(0, 2π; length=N + 1))[1:N]
    u0 = A .* sin.(x)
    if t_view == 0
        return x, u0, u0, [0.0], [mean(u0 .^ 2) / 2]
    end

    dx = 2π / N
    dt_adv = 0.35 * dx / max(abs(A), 1e-8)
    dt_diff = 0.20 * dx^2 / max(ν, 1e-8)
    nsteps = max(1, ceil(Int, t_view / min(dt_adv, dt_diff)))
    dt = t_view / nsteps
    u = copy(u0)
    energies = [mean(u .^ 2) / 2]
    times = [0.0]

    for k in 1:nsteps
        up = circshift(u, -1)
        um = circshift(u, 1)
        flux = 0.5 .* u .^ 2
        flux_p = 0.5 .* up .^ 2
        flux_m = 0.5 .* um .^ 2
        speed_p = max.(abs.(u), abs.(up))
        speed_m = max.(abs.(um), abs.(u))
        numerical_flux_p = 0.5 .* (flux .+ flux_p) .- 0.5 .* speed_p .* (up .- u)
        numerical_flux_m = 0.5 .* (flux_m .+ flux) .- 0.5 .* speed_m .* (u .- um)
        advection = (numerical_flux_p .- numerical_flux_m) ./ dx
        diffusion = ν .* (up .- 2 .* u .+ um) ./ dx^2
        u = u .+ dt .* (-advection .+ diffusion)
        push!(energies, mean(u .^ 2) / 2)
        push!(times, k * dt)
    end
    return x, u0, u, times, energies
end

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0007
begin
    x, u_initial, u_final, times, energies = burgers_run(ν, A, t_view)
    flow_plot = plot(x, u_initial; label="initial flow", lw=2, alpha=0.65,
        xlabel="position x", ylabel="velocity u", ylim=(-1.7, 1.7),
        title="Viscous Burgers flow at t = $(round(t_view, digits=2))")
    plot!(flow_plot, x, u_final; label="flow at selected time", lw=3)

    energy_plot = plot(times, energies; label="kinetic energy", lw=3, color=:darkorange,
        xlabel="time", ylabel="mean(u²)/2", title="Energy dissipates when ν = $ν",
        legend=:topright)
    plot(flow_plot, energy_plot; layout=(2, 1), size=(760, 680))
end

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0008
md"""
## What did we learn?

For small `ν`, the wave's high-slope regions become visibly sharper before viscosity
smooths them. For larger `ν`, diffusion acts quickly and the flow loses energy more rapidly.
The calculation remains finite and well behaved because this one-dimensional model is much
less difficult than three-dimensional Navier–Stokes.

That distinction is the point. A simulation can suggest mechanisms and reveal behavior,
but it cannot by itself prove that every smooth three-dimensional solution stays smooth,
or that one particular solution becomes singular.
"""

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0010
md"""
## The ODE hiding inside the recent blow-up construction

The new work by Alpöge and Buckmaster studies several fluid equations, including forced
inviscid Boussinesq and three-dimensional Euler. In a carefully chosen oscillatory-wave
ansatz, the wave amplitudes obey an exact two-variable ODE. In a simplified frozen setting,
the equations are

$$\dot{\Theta}=\frac{A\sin\phi}{\lambda r}\,\Omega,\qquad
\dot{\Omega}=\lambda r\sin\phi\,\Theta.$$

When $0<\phi<\pi$, the matrix has eigenvalues
$\pm\sqrt{A\sin\phi}$. Along the growing eigenline, the amplitudes grow like
$e^{\sqrt{A\sin\phi}\,t}$. This is the instability that one can see directly in an ODE;
the difficult PDE proof arranges many increasingly fine waves and fits infinitely many
stages into finite time.

This is not itself a proof of Navier–Stokes blow-up. It is a window into the mechanism.
See [Tao's explanation](https://terrytao.wordpress.com/2026/09/07/finite-time-blowup/)
and the [Boussinesq preprint](https://cims.nyu.edu/~tristanb/boussinesq.pdf).

Wave amplitude `A`: $(@bind A_wave Slider(0.1:0.1:4.0; default=1.0, show_value=true))

Wave angle `φ`: $(@bind phi Slider(0.1:0.1:3.0; default=1.6, show_value=true))

Frequency scale `λr`: $(@bind lambda_r Slider(0.5:0.5:4.0; default=1.0, show_value=true))

Time window: $(@bind t_wave Slider(0.1:0.05:3.0; default=1.5, show_value=true))
"""

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0011
function wave_amplitudes(A_wave, phi, lambda_r, t_wave)
    growth_rate = sqrt(max(A_wave * sin(phi), 0.0))
    times = collect(range(0, t_wave; length=300))
    theta0 = -1.0
    omega0 = (lambda_r / sqrt(A_wave)) * theta0
    theta = theta0 .* exp.(growth_rate .* times)
    omega = omega0 .* exp.(growth_rate .* times)
    return times, theta, omega, growth_rate
end

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0012
begin
    wave_times, theta, omega, growth_rate = wave_amplitudes(A_wave, phi, lambda_r, t_wave)
    plot(wave_times, abs.(theta); label="|Θ(t)|", lw=3,
        xlabel="time", ylabel="amplitude", title="ODE growth rate = $(round(growth_rate, digits=3))")
    plot!(wave_times, abs.(omega); label="|Ω(t)|", lw=3)
end

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0013
md"""
## A one-line comparison that really blows up

The simplest calculus model for self-amplification is

$$\dot{Y}=cY^2,\qquad Y(0)=Y_0.$$

Separating variables gives

$$Y(t)=\frac{Y_0}{1-cY_0t},\qquad T_* = \frac{1}{cY_0}.$$

The graph becomes infinite at the finite time $T_*$. This is an exact ODE calculation,
not a discretization artifact. But it is only a comparison model: replacing a PDE by this
ODE loses spatial transport, pressure, incompressibility, viscosity, and the geometry of
vortex stretching. The mathematical challenge is proving that the full PDE can organize
those effects so that a mechanism like this survives.

Initial value `Y₀`: $(@bind Y0_blow Slider(0.2:0.1:2.0; default=1.0, show_value=true))

Amplification `c`: $(@bind c_blow Slider(0.2:0.1:2.0; default=1.0, show_value=true))

Requested time: $(@bind t_blow Slider(0.0:0.01:3.0; default=0.8, show_value=true))
"""

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0014
begin
    blowup_time = 1 / (c_blow * Y0_blow)
    safe_time = min(t_blow, 0.98 * blowup_time)
    blowup_times = collect(range(0, max(safe_time, 0.001); length=300))
    blowup_values = Y0_blow ./ (1 .- c_blow .* Y0_blow .* blowup_times)
    plot(blowup_times, blowup_values; label="Y(t)", lw=3, color=:crimson,
        xlabel="time", ylabel="Y", xlims=(0, 1.02 * blowup_time),
        title="Exact ODE blow-up at T⋆ = $(round(blowup_time, digits=3))")
    vline!([blowup_time]; label="T⋆", ls=:dash, color=:black)
end

# ╔═╡ 0b31c0d4-8d68-4e06-b3ef-6e7c5cda0009
md"""
## Questions for class

1. Which term moves the wave, and which term smooths it?
2. What changes when you increase `A` while keeping `ν` fixed?
3. Why must the time step become smaller when the grid is finer or the viscosity is larger?
4. What evidence would you want before believing a claimed three-dimensional blow-up proof?
5. Ask an LLM to explain one part of the notebook, then try to find a mistake or missing
   assumption in its explanation.

The useful habit is not to ask whether an LLM sounds confident. It is to ask what would
let us check the answer.
"""

# ╔═╡ Cell order:
# ╟─0b31c0d4-8d68-4e06-b3ef-6e7c5cda0001
# ╟─0b31c0d4-8d68-4e06-b3ef-6e7c5cda0002
# ╟─0b31c0d4-8d68-4e06-b3ef-6e7c5cda0003
# ╟─0b31c0d4-8d68-4e06-b3ef-6e7c5cda0004
# ╟─0b31c0d4-8d68-4e06-b3ef-6e7c5cda0005
# ╠═0b31c0d4-8d68-4e06-b3ef-6e7c5cda0006
# ╠═0b31c0d4-8d68-4e06-b3ef-6e7c5cda0007
# ╟─0b31c0d4-8d68-4e06-b3ef-6e7c5cda0008
# ╟─0b31c0d4-8d68-4e06-b3ef-6e7c5cda0010
# ╠═0b31c0d4-8d68-4e06-b3ef-6e7c5cda0011
# ╠═0b31c0d4-8d68-4e06-b3ef-6e7c5cda0012
# ╟─0b31c0d4-8d68-4e06-b3ef-6e7c5cda0013
# ╠═0b31c0d4-8d68-4e06-b3ef-6e7c5cda0014
# ╟─0b31c0d4-8d68-4e06-b3ef-6e7c5cda0009
