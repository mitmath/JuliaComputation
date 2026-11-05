### A Pluto.jl notebook ###
# v1.1.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 7494c497-d0e9-5544-afc1-0a2cd4052729
begin
    using PlutoUI
    using Plots
    using LinearAlgebra
    using Random
    using Statistics
    using Printf
    gr()
    default(size=(850, 400), linewidth=2.6, legendfontsize=10,
        guidefontsize=11, tickfontsize=9, titlefontsize=13,
        gridalpha=0.16, background_color=:white, foreground_color=:black)
    TableOfContents(title="Lesson map", depth=2, aside=true)
end

# ╔═╡ f3e1211f-66c8-4367-a2d5-eae99d4fdc65
using SparseArrays

# ╔═╡ a2610797-a873-5a49-bed0-ff1302024aa0
md"""
# Echo State Networks
### How can a mostly untrained neural network remember the past?

*Start with an impulse. Watch it echo. Then learn to read the echo.*

"""

# ╔═╡ affcad7e-fa50-4300-80fd-4d08cc47d804

md"""
## Intro · Echo State Networks: History and Origins

**Echo State Networks (ESNs) were introduced in 2001 by Herbert Jaeger**, a researcher working on recurrent neural networks and dynamical systems.

At the time, traditional RNNs were difficult to train because backpropagation through time was computationally expensive and susceptible to vanishing or exploding gradients.

Jaeger proposed a surprisingly simple alternative: **instead of training the recurrent connections, randomly initialize them, keep them fixed, and train only the output layer.**

Around the same time, **Wolfgang Maass and collaborators** independently developed a closely related approach called *Liquid State Machines* (2002), inspired by biological neural networks.

These approaches helped establish the broader field of **Reservoir Computing**.

### Important milestones

- **2001:** Herbert Jaeger introduces Echo State Networks.
- **2002:** Maass and collaborators introduce Liquid State Machines.
- **2004:** Jaeger and Harald Haas demonstrate impressive results in chaotic time-series prediction and wireless communication.
- **2010s–2020s:** Research expands into physical reservoirs, robotics, nonlinear system modeling, and efficient hardware implementations.

> **The original motivation:** Make recurrent neural networks easier and faster to train without sacrificing their ability to process temporal information.
"""


# ╔═╡ a3228763-0dae-4e13-8346-08d48d9d5b86

md"""
## Intro · How Are ESNs Used Today?

ESNs remain an active research area, especially for applications involving **sequential data, nonlinear dynamics, and efficient training**.

### Common applications

**1. Time-Series Forecasting**
- Predicting signals, sensor measurements, and other temporal data.
- Modeling nonlinear systems whose future depends on previous observations.

**2. Chaotic Dynamical Systems**
- Predicting short-term trajectories of chaotic systems.
- Reconstructing long-term attractor behavior, as demonstrated in our Lorenz experiment.

**3. Robotics and Control**
- Processing sequences of sensor observations.
- Learning dynamic behavior and generating control signals.

**4. Signal Processing**
- Speech and temporal pattern recognition.
- Processing communication signals and nonlinear channel equalization.

**5. Physical and Neuromorphic Computing**
- Implementing reservoir dynamics using physical systems, optical devices, or specialized hardware.
- Exploring alternatives to conventional neural-network computation.

### Why are ESNs still interesting?

Unlike many conventional RNNs, ESNs usually avoid backpropagation through time by keeping the reservoir fixed.

This can make training significantly cheaper, particularly when the readout is fitted using linear or ridge regression.

However, ESNs are not universally better than LSTMs, GRUs, or Transformers. Their usefulness depends heavily on the task, reservoir design, and required memory horizon.
"""


# ╔═╡ 131c19e2-3a11-420e-9f6f-77c0e95c03d4

md"""
## Intro · When Are Echo State Networks Most Useful?

ESNs are particularly well suited for problems with three characteristics:

**1. Temporal dependencies**

The current output depends on a history of previous inputs, rather than only the current observation.

**2. Nonlinear dynamics**

The relationship between past inputs and future outputs is complex, but can be represented using nonlinear reservoir states.

**3. Limited training resources**

Training a large recurrent network using backpropagation would be expensive or unnecessary.

### Strengths

- Fast and relatively simple readout training.
- Useful representations of recent input history.
- Natural compatibility with dynamical systems and continuous signals.
- Ability to experiment with reservoir memory and stability.

### Limitations

- Reservoir size, spectral radius, and input scaling often require tuning.
- Fixed random features may not be ideal for every task.
- Very long-term dependencies can be difficult to preserve.
- Autonomous predictions can become unstable or inaccurate.

### Connecting Back to Our Experiments

Our notebook demonstrates several of these strengths:

- **Memory capacity:** How much historical information the reservoir retains.
- **Bouncing ball:** How temporal memory helps predict motion.
- **Lorenz attractor:** How an ESN can approximate complex nonlinear dynamics.

> **The central idea:** ESNs trade the flexibility of training every recurrent weight for a simpler learning procedure that exploits the natural dynamics of a fixed reservoir.
"""


# ╔═╡ 0a58d8c8-3110-4a3f-9f21-14f29702a301

md"""
### Traditional Recurrent Neural Network (RNN)

A traditional RNN updates its hidden state using the current input and previous hidden state:

```math
h_t = \tanh(W_{\text{in}}u_t + W_h h_{t-1} + b)
```

The output is computed as:

```math
y_t = W_{\text{out}}h_t + b_{\text{out}}
```

**Unlike an ESN, a traditional RNN trains its input, recurrent, and output weights using backpropagation through time (BPTT).** This allows the network to learn its recurrent dynamics rather than relying on a fixed, randomly initialized reservoir.
"""


# ╔═╡ b9cae793-3951-5b2a-bb95-373504fd2909
md"""
## 1 · The strange idea

An **Echo State Network (ESN)** usually does something surprising: it **freezes a randomly constructed recurrent network** and trains only a simple output layer.

> **Don't train the dynamics. Train how to read the dynamics.**

The random reservoir does *not* already know the answer. It creates an expressive set of features from recent input history. A trained readout combines those features for the task at hand.
"""

# ╔═╡ 9ba4e057-4056-5c1b-a2c2-df782cbb41c1
md"""
## 2 · Intuition

Imagine yelling into a cave. After the initial sound, echoes remain. A second shout creates new sounds and echoes **on top of the old ones**. A reservoir behaves similarly: each input perturbs a state that already carries traces of previous inputs.

This is **fading memory**: recent inputs can still affect today's state, but their influence often becomes harder to recover as time passes.
"""

# ╔═╡ 8d77036e-a085-4ede-9aee-9a7f9d73d450

md"""
![Echoes in a Cave](https://commons.wikimedia.org/wiki/Special:FilePath/Echo_Caves.jpg)
"""


# ╔═╡ f946eb98-ac1d-5daf-a827-c05ccd48d227
md"""
## 3 · The Formula

A **state** is a vector of numbers describing the reservoir's current activity. **Recurrence** means the next state depends on the previous state *and* the new input.

```math
x_t = \tanh\left(W_{\mathrm{in}}u_t + Wx_{t-1}\right)
```

- ``u_t``: input at step ``t``.
- ``W_{\mathrm{in}}``: weights turning the input into a vector.
- ``x_{t-1}``: reservoir's previous state.
- ``W``: recurrent weights mixing the previous neuron activities.
- ``\tanh``: elementwise nonlinearity keeping each component between −1 and 1.

```text
 current input uₜ ─▶ Win ──┐
                            ├──▶ add ──▶ tanh ──▶ new state xₜ
 previous state xₜ₋₁ ─▶ W ─┘                  │
         ▲                                    │
         └────────── next time step ─────────┘
```

**TLDR**; the reservoir combines **what just happened** with **what it remembers**, then applies a nonlinear transformation. The term ``Wx_{t-1}`` is how the reservoir carries forward its earlier state.
"""

# ╔═╡ 9c8eb871-01f6-58ac-8b43-13827d79fecd

md"""
## 4 · Visualizing Forgetfulness

Imagine giving two identical neural networks different input histories.

Both networks eventually receive the exact same current input: **zero**.

**Will their internal states still be different?**

In an Echo State Network (ESN), information from previous inputs can persist through recurrent connections.

Use the sliders below to explore how the network remembers — and eventually forgets — an earlier event.
"""


# ╔═╡ a4031068-b259-5567-8cc0-0403fd872612

md"""
#### 4.1 · Design two input histories

**When should Sequence B receive an additional pulse?**

$(@bind intro_second_pulse Slider(4:12, default=7, show_value=true))

**How strong should that additional pulse be?**

$(@bind intro_pulse_strength Slider(0.0:0.1:2.0, default=1.0, show_value=true))

**Which time step should we observe?**

$(@bind intro_observe_time Slider(1:24, default=12, show_value=true))
"""


# ╔═╡ e9960987-cbcb-5803-b9d9-dfcc2149cac0

begin
    intro_Win = [1.0, -0.6]

    intro_W = [
         0.7   0.2
        -0.15  0.65
    ]

    function intro_simulate(inputs, Win, W)
        states = zeros(2, length(inputs) + 1)

        for t in 1:length(inputs)
            states[:, t+1] = tanh.(
                Win .* inputs[t] + W * states[:, t]
            )
        end

        return states
    end
end


# ╔═╡ c0f90186-6d8b-4ddc-8c67-c0093b854423
begin
    intro_T = 24

    intro_A = zeros(intro_T)
    intro_B = zeros(intro_T)

    # Both histories start with the same pulse.
    intro_A[3] = 1.0
    intro_B[3] = 1.0

    # Only Sequence B receives an extra pulse.
    intro_B[intro_second_pulse] += intro_pulse_strength

    intro_states_A = intro_simulate(
        intro_A, intro_Win, intro_W
    )

    intro_states_B = intro_simulate(
        intro_B, intro_Win, intro_W
    )
end

# ╔═╡ f5fbcfa3-e372-4b22-9e4a-8d73c01ab2a3

begin
    intro_steps = 1:intro_T

    intro_input_plot = plot(
        intro_steps, intro_A,
        label="Sequence A",
        color=:royalblue,
        linewidth=2.5,
        marker=:circle,
        markersize=3,
        xlabel="Time step",
        ylabel="Input value",
        title="1. Two Different Input Histories",
        xlims=(1, intro_T),
        ylims=(-0.15, 2.3),
        size=(850, 290),
        legend=:topright,
        gridalpha=0.15
    )

    plot!(
        intro_input_plot,
        intro_steps, intro_B,
        label="Sequence B",
        color=:darkorange,
        linewidth=2.5,
        marker=:diamond,
        markersize=4,
        linestyle=:dash
    )

    vline!(
        intro_input_plot,
        [intro_observe_time],
        color=:black,
        linestyle=:dot,
        linewidth=2,
        label="Observed time"
    )

    intro_input_plot
end


# ╔═╡ f623e7b8-a764-475e-b2cb-ee86b61b2493

begin
    intro_idx = intro_observe_time + 1

    intro_state_A = intro_states_A[:, intro_idx]
    intro_state_B = intro_states_B[:, intro_idx]

    intro_trajectory_plot = plot(
        intro_states_A[1, 1:intro_idx],
        intro_states_A[2, 1:intro_idx],
        label="Sequence A trajectory",
        color=:royalblue,
        linewidth=3,
        marker=:circle,
        markersize=2,
        xlabel="Neuron 1 activation",
        ylabel="Neuron 2 activation",
        title="2. Where Does Each History Take the Reservoir?",
        xlims=(-1.1, 1.1),
        ylims=(-1.1, 1.1),
        aspect_ratio=:equal,
        size=(700, 510),
        legend=:topright,
        gridalpha=0.15
    )

    plot!(
        intro_trajectory_plot,
        intro_states_B[1, 1:intro_idx],
        intro_states_B[2, 1:intro_idx],
        label="Sequence B trajectory",
        color=:darkorange,
        linewidth=3,
        marker=:circle,
        markersize=2
    )

    scatter!(
        intro_trajectory_plot,
        [intro_state_A[1]], [intro_state_A[2]],
        color=:royalblue,
        markersize=11,
        markerstrokewidth=2,
        label="A at t=$(intro_observe_time)"
    )

    scatter!(
        intro_trajectory_plot,
        [intro_state_B[1]], [intro_state_B[2]],
        color=:darkorange,
        markersize=11,
        markerstrokewidth=2,
        label="B at t=$(intro_observe_time)"
    )

    intro_trajectory_plot
end


# ╔═╡ 01c51696-7c48-47c4-9e19-a59f2f4b7022

begin
    intro_times = 0:intro_T

    intro_distances = [
        norm(intro_states_A[:, t] - intro_states_B[:, t])
        for t in 1:(intro_T + 1)
    ]

    intro_distance_plot = plot(
        intro_times,
        intro_distances,
        label="Distance between states",
        color=:purple,
        linewidth=3,
        fillrange=0,
        fillalpha=0.12,
        xlabel="Time step",
        ylabel="Euclidean distance",
        title="3. How Long Does the Reservoir Remember?",
        xlims=(0, intro_T),
        ylims=(0, max(0.1, maximum(intro_distances) * 1.2)),
        size=(850, 300),
        gridalpha=0.15
    )

    scatter!(
        intro_distance_plot,
        [intro_observe_time],
        [intro_distances[intro_observe_time + 1]],
        color=:red,
        markersize=8,
        label="Current observation"
    )

    vline!(
        intro_distance_plot,
        [intro_second_pulse],
        color=:gray,
        linestyle=:dash,
        label="Extra input"
    )

    intro_distance_plot
end


# ╔═╡ 4c40a600-cbcb-5653-89a0-cdc3a46900e2
md"""
## 5 · Interpreting Reservoir Size

A useful reservoir may contain dozens or hundreds of neurons connected with **fixed random weights**. Different neurons see different combinations of the same recent input history, so they may respond in remarkably different ways.

```text
                           frozen recurrent connections
                        ↗─────────↘   ↗─────────↘
 input uₜ ───▶  [ ●  ●  ●  ●  ●  ●  ●  ●  ● ] ───▶ state xₜ
                         ↖─────↗    ↖─────↗            │
                                                      ▼
                                                trained readout
                                                      │
                                                      ▼
                                                desired output
```

This resembles a **random feature expansion** (e.g., extra nonlinear features before linear regression), but unlike ordinary static random features, the ESN features can depend on *past inputs* through recurrence.
"""

# ╔═╡ 7c741da4-866c-4f26-99c6-515760c8d7e7

md"""
## 6 · The implementation underneath our experiments
```math
x_t = \tanh\left(g W_{\mathrm{in}}u_t + s W x_{t-1}\right)
```

where:

- ``g`` is the **input gain** (`features_gain`).
- ``s`` is the **recurrent strength**.
- ``W_{\mathrm{in}}u_t`` represents the current input.
- ``Wx_{t-1}`` represents the previous reservoir state's influence.
"""


# ╔═╡ cb084983-8ca9-5eb2-ad99-698b5f471e78
begin
    # Small, reusable ESN helpers; one Julia function per distinct operation.
    function scale_spectral_radius(W, target_radius)
        radius = maximum(abs.(eigvals(Matrix(W))))
        radius > 1e-12 || error("Cannot scale a zero-spectral-radius matrix")
        Matrix(W) .* (target_radius / radius)
    end

    function make_reservoir(n; spectral_radius=0.9, sparsity=0.85, seed=41)
        rng = MersenneTwister(seed)
        A = randn(rng, n, n) ./ sqrt(n)
        mask = rand(rng, n, n) .>= sparsity
        A .*= mask
        scale_spectral_radius(A, spectral_radius)
    end

    function run_reservoir(u, Win, W; x0=zeros(size(W, 1)), leak=1.0)
        n = size(W, 1)
        @assert length(Win) == n && size(W, 2) == n
        X = Matrix{Float64}(undef, n, length(u)+1)
        X[:,1] = x0
        x = copy(Float64.(x0))
        for t in eachindex(u)
            candidate = tanh.(Win .* u[t] + W*x)
            x = (1-leak).*x .+ leak.*candidate
            X[:, t+1] = x
        end
        X
    end

    # Samples are in columns; append a bias feature so the intercept is trained too.
    function train_readout(X, y; ridge=1e-5)
        Z = vcat(X, ones(1, size(X,2)))
        targets = ndims(y) == 1 ? reshape(y, 1, :) : y
        G = Z*Z' + ridge*I
        # Solve instead of forming an explicit matrix inverse.
        Matrix((G \ (Z*targets'))')
    end

    function predict_readout(Wout, X)
        Wout * vcat(X, ones(1, size(X,2)))
    end

    function safe_corr2(a, b)
        std(a) < 1e-10 || std(b) < 1e-10 ? 0.0 : clamp(cor(a,b)^2, 0.0, 1.0)
    end

    function memory_curve(u, X; max_delay=30, washout=100, train_fraction=0.65, ridge=1e-4)
        # X[:, t+1] is the state immediately AFTER reading u[t].
        # For delay k, the target aligned with X[:, t+1] is u[t-k].
        start_t = max(washout+1, max_delay+1)
        stop_t = length(u)
        ts = collect(start_t:stop_t)
        states = X[:,ts .+ 1]
        targets = reduce(vcat, (reshape(u[ts .- k], 1, :) for k in 1:max_delay))
        split = floor(Int, train_fraction*length(ts))
        @assert split > 5 && length(ts)-split > 5
        Wout = train_readout(states[:,1:split], targets[:,1:split]; ridge=ridge)
        predictions = predict_readout(Wout, states[:,split+1:end])
        scores = [safe_corr2(vec(predictions[k,:]), vec(targets[k,split+1:end])) for k in 1:max_delay]
        scores
    end
    nothing
end

# ╔═╡ 578c95d2-4a0b-5f94-a39b-cc2552314c84
md"""
## 7 · Random neurons create different features

Here the same synthetic signal enters a fixed random reservoir. We only plot the first eight neurons, but each responds to a different combination of input and recurrent activity.

**Try:** change the input gain. A stronger input can make the state move more sharply, but may also saturate ``\tanh``.
"""

# ╔═╡ e89222fc-61c9-5e34-8d43-2a3f0d24b7fe
@bind features_gain Slider(0.1:0.1:2.0, default=0.8, show_value=true)

# ╔═╡ 3397283f-aca0-5d82-8cf4-de010887dc64
begin
    feature_t = 1:130
    feature_u = [0.65*sin(0.17*t) + 0.35*cos(0.047*t) +
                 (t in (25, 65, 98) ? 0.9 : 0.0) for t in feature_t]
    feature_W = make_reservoir(40; seed=22, sparsity=0.80)
    feature_Win = randn(MersenneTwister(23), 40)
    feature_X = run_reservoir(feature_u, features_gain .* feature_Win, feature_W)
end

# ╔═╡ 718c21a6-06fa-539d-927b-a84390cc78f6
let
    p = plot(feature_t, feature_u; color=:black, label="shared input",
        xlabel="Time step", ylabel="Input / neuron activation",
        title="Eight different responses to one input history", linewidth=3.0, alpha=0.75)
    for j in 1:8
        plot!(p, feature_t, feature_X[j,2:end]; label="neuron $j", linewidth=1.8, alpha=0.8)
    end
    p
end

# ╔═╡ cfefa664-9801-59d8-a14c-464c6292b3ea
md"""
**Interpretation:** the readout does not need the reservoir neurons to individually predict the target. It needs their **combined state vector** to contain helpful information that a linear model can extract.
"""

# ╔═╡ 4f0f06c5-2510-54a9-b6dd-8c90332da706
md"""
## 8 · What actually gets trained?

| Standard RNN | Echo State Network |
|:--|:--|
| Usually update input, recurrent, and output weights | Freeze input and recurrent weights |
| Learn state dynamics using backpropagation through time | Generate state dynamics using the fixed reservoir |
| Train a task output head too | Train a linear readout (often ridge regression) |

Collect the states as **columns** of a matrix ``X`` and desired outputs as columns of ``Y``:

```math
X=\begin{bmatrix}\vert&\vert&&\vert\\x_1&x_2&\cdots&x_T\\\vert&\vert&&\vert\end{bmatrix},\qquad
Y\approx W_{\mathrm{out}}X
```

The readout chooses the combination of reservoir features that best fits the labels. **Ridge regression** is least squares with a penalty on large weights:

```math
W_{\mathrm{out}}=YX^{\mathsf T}(XX^{\mathsf T}+\lambda I)^{-1}
```

The code uses a numerically more stable **linear solve**, and includes an intercept by adding a row of ones to ``X``. Training is fast compared with retraining a full recurrent network.
"""

# ╔═╡ c2c16da8-13f8-44c2-9b83-dc284ce18d93

md"""
## 9 · Can the ESN actually recover the past

Recall our ESN update equation:

```math
x_t = \tanh\left(g W_{\mathrm{in}}u_t + s W x_{t-1}\right)
```

The memory experiment introduces three parameters:

- **`memory_n` — Reservoir size (N):** The number of neurons in the reservoir, corresponding to the dimension of ``x_t``. Increasing ``N`` gives the network more neurons to represent information about previous inputs.

- **`memory_radius` — Spectral radius (ρ):** Controls the scale of the recurrent matrix ``W``, similar to our earlier recurrent strength ``s``. Specifically, ``W`` is rescaled so its largest absolute eigenvalue equals ``\rho``. Larger values generally allow previous states to influence the network for longer, but do not guarantee better memory.

- **`memory_maxdelay` — Maximum delay (K):** The maximum number of past time steps we attempt to reconstruct. It does **not** change the ESN equation or its weights. Instead, it determines how far into the past we test the reservoir's memory.

For each delay ``k = 1,\ldots,K``, we train a linear readout to predict an earlier input:

```math
\hat{u}_{t-k} = W_{\mathrm{out}}^{(k)}x_t
```

We measure how accurately the reservoir remembers that input using:

```math
MC_k = \operatorname{corr}^2(\hat{u}_{t-k},u_{t-k})
```

**Key distinction:** ``N`` and ``\rho`` affect the reservoir itself, while ``K`` only determines how far back we evaluate its memory.
"""


# ╔═╡ 0ce89ae1-255d-524c-85db-2b95daf17464
@bind memory_n Slider(20:20:100, default=60, show_value=true)

# ╔═╡ a59b952b-e516-57fd-aa32-a6bbfe8da722
@bind memory_radius Slider(0.1:0.1:1.4, default=0.9, show_value=true)

# ╔═╡ b6c5d343-adbd-5dea-af04-e47574b6b037
@bind memory_maxdelay Slider(10:5:40, default=30, show_value=true)

# ╔═╡ 08c2661e-4205-5d5f-a9f2-df7f79c8d17e
begin
    memory_u = randn(MersenneTwister(445), 1450)
    memory_Win_master = randn(MersenneTwister(446), 100) .* 0.35
    # The upper-left submatrix changes with n, but is deterministic for that size.
    memory_base_W = make_reservoir(memory_n; spectral_radius=1.0, sparsity=0.85, seed=447)
    memory_W = memory_radius .* memory_base_W
    memory_Win = memory_Win_master[1:memory_n]
    memory_X = run_reservoir(memory_u, memory_Win, memory_W)
    memory_scores = memory_curve(memory_u, memory_X; max_delay=memory_maxdelay,
        washout=100, train_fraction=0.65, ridge=1e-3)
    memory_total = sum(memory_scores)
end

# ╔═╡ efd55a4d-10bf-5bd5-8ebe-2ae0716a4e25
let
    p = bar(1:memory_maxdelay, memory_scores; bar_width=0.84,
        color=:steelblue, label="held-out MCₖ", xlabel="Delay k (steps into the past)",
        ylabel="Squared correlation", title="How quickly does the reservoir forget?",
        ylim=(0,1.05), xlims=(0.3,memory_maxdelay+0.7), legend=:topright)
    hline!(p, [0.5]; color=:gray, linestyle=:dash, label="0.5 reference")
    p
end

# ╔═╡ 4e1857cd-ae83-53b7-a239-b455012fe7ce
md"""
**Measured result:** with **$(memory_n)** neurons and spectral radius **$(round(memory_radius; digits=2))**, the held-out sum over **$(memory_maxdelay)** delays is **$(round(memory_total; digits=2))**. This is a *finite, experimental sum*, not a universal memory-capacity guarantee. Compare the shape of the bars, not just the total. A larger radius or larger reservoir can help, but neither guarantees better test performance.
"""

# ╔═╡ 009ffbed-3fbd-583b-8189-eb62478a170d
md"""
## 10 · Spectral radius: how strongly do echoes circulate?

A matrix can have directions of activity that grow or shrink when repeatedly multiplied. An **eigenvalue** measures the scaling of such a direction. The **spectral radius** is the size of the largest eigenvalue magnitude:

```math
\rho(W)=\max_i |\lambda_i(W)|
```

This is a useful guide to recurrent persistence, especially near small activities where ``\tanh(z)\approx z``. It is **not a complete or universally necessary condition** for the echo state property; nonlinearities, input strengths, and matrix structure also matter.

**Compare identical impulses using the same underlying weights** at spectral radii 0.2, 0.8, 1.1, and your chosen radius.
"""

# ╔═╡ 27adc9d7-5a45-5a32-924b-116bc829fce2
md"""
**How to read it:** very small ``\rho`` tends to forget quickly. Moderate recurrence can preserve an echo longer. Above one, activity may become persistent, sensitive, or saturated depending on the nonlinear system; the curve need not diverge because ``\tanh`` is bounded. This is an **impulse-response comparison**, not a proof of the echo state property.
"""

# ╔═╡ f3eef579-414e-5089-a791-aa60cdb18e1b
md"""
## 12 · Turn memory into a prediction

Let's solve a simple supervised sequence problem: predict a nonlinear signal from the **current and recent input values**. The input sequence is random; the target depends on inputs from the past:

```math
y_t=0.65u_{t-2}+0.25u_{t-5}+0.10\sin(2u_{t-1})
```

The reservoir gets only ``u_t`` sequentially. It is **not given the delayed inputs** directly. We will train a linear readout of its states on the first 65% of usable time steps and evaluate on the later 35%.

To test whether dynamics matter, we'll also fit a linear readout on a **memoryless input feature**, using only ``u_t``. Both models are evaluated on the same held-out segment.

The prediction experiment introduces three parameters:

- **`prediction_radius` — Spectral radius (ρ):** Controls the scale of the recurrent matrix ``W``, determining how strongly previous states influence the current state. Larger values can preserve information longer, but do not necessarily improve prediction accuracy.

- **`prediction_ridge` — Regularization strength (λ):** Controls how strongly we penalize large weights in the trained output matrix ``W_{\mathrm{out}}``. Larger ``\lambda`` encourages smaller readout weights, potentially reducing overfitting.

- **`prediction_window` — Visualization window:** Controls which portion of the prediction results is displayed. It does **not** change the reservoir, training process, or predictions.

"""

# ╔═╡ a43c95aa-cd02-5c44-9a0b-0070c7946dc2
@bind prediction_radius Slider(0.2:0.1:1.3, default=0.9, show_value=true)

# ╔═╡ 808abf72-5819-5c4e-a5aa-0e9e73f15b8b
@bind prediction_ridge Slider([1e-5, 1e-4, 1e-3, 1e-2, 1e-1], default=1e-3, show_value=true)

# ╔═╡ d72f8d3d-0290-5367-96b7-7e4ed3ad6c80
begin
    predict_u = randn(MersenneTwister(809), 1600) .* 0.75
    predict_Win = randn(MersenneTwister(810), 80) .* 0.45
    predict_baseW = make_reservoir(80; spectral_radius=1.0, seed=811, sparsity=0.85)
    predict_X = run_reservoir(predict_u, predict_Win, prediction_radius .* predict_baseW)
    predict_t = collect(105:length(predict_u))
    predict_y = [0.65*predict_u[t-2] + 0.25*predict_u[t-5] +
                  0.10*sin(2*predict_u[t-1]) for t in predict_t]
    predict_states = predict_X[:, predict_t .+ 1]
    predict_split = floor(Int, 0.65*length(predict_t))
    fitted_out = train_readout(predict_states[:,1:predict_split],
        predict_y[1:predict_split]; ridge=prediction_ridge)
    predict_yhat = vec(predict_readout(fitted_out, predict_states[:,predict_split+1:end]))
    baseline_states = reshape(predict_u[predict_t], 1, :)
    baseline_out = train_readout(baseline_states[:,1:predict_split],
        predict_y[1:predict_split]; ridge=prediction_ridge)
    baseline_yhat = vec(predict_readout(baseline_out, baseline_states[:,predict_split+1:end]))
    predict_true = predict_y[predict_split+1:end]
    predict_rmse = sqrt(mean((predict_yhat .- predict_true).^2))
    baseline_rmse = sqrt(mean((baseline_yhat .- predict_true).^2))
end

# ╔═╡ 7cdc9368-fd49-5c4c-8e40-536063733741
@bind prediction_window Slider(1:10:401, default=1, show_value=true)

# ╔═╡ 2e4e4c66-ca3e-506b-bce7-d4b8ef5a1a50
let
    lo = prediction_window
    hi = min(lo+95, length(predict_true))
    segment = lo:hi
    p = plot(segment, predict_true[segment]; color=:black, label="true target",
        xlabel="Held-out sample index", ylabel="Target / prediction",
        title="Can fixed reservoir features support useful predictions?", linewidth=3)
    plot!(p, segment, predict_yhat[segment]; color=:royalblue,
        label="ESN readout", alpha=0.9)
    plot!(p, segment, baseline_yhat[segment]; color=:darkorange,
        label="memoryless baseline", linestyle=:dash, linewidth=2)
    p
end

# ╔═╡ 8cbd2738-6aba-4922-a729-6a4604c1f179

md"""
## 13 · Can an Echo State Network Predict Motion?

Imagine watching a ball bounce around a rectangular screen.

If the ball suddenly disappears behind a wall, could you still predict where it is?

You probably could, because you remember:

- Where the ball was previously.
- Which direction it was moving.
- Approximately how fast it was moving.

An ESN can use its recurrent state to learn similar information.

**Our goal:** Train a reservoir to predict future ball positions from a sequence of observations, including when the ball is temporarily hidden.

We will train only the readout weights. The recurrent reservoir remains randomly initialized and frozen.
"""


# ╔═╡ cab67fbe-0b60-47d6-aed7-2d356b4119ef

begin
    # Reflect a coordinate off the boundaries [0, 1].
    function ball_reflect(z)
        q = mod(z, 2.0)
        return q <= 1.0 ? q : 2.0 - q
    end

    # Generate one bouncing-ball trajectory.
    function ball_generate(rng, T)
        x0 = rand(rng) * 0.6 + 0.2
        y0 = rand(rng) * 0.6 + 0.2

        vx = (rand(rng, Bool) ? 1 : -1) *
             (0.015 + 0.025 * rand(rng))

        vy = (rand(rng, Bool) ? 1 : -1) *
             (0.012 + 0.025 * rand(rng))

        positions = zeros(2, T)

        for t in 1:T
            positions[1,t] = ball_reflect(x0 + vx*(t-1))
            positions[2,t] = ball_reflect(y0 + vy*(t-1))
        end

        return positions
    end

    # Convert positions into partial observations.
    # The ball becomes invisible behind the central wall.
    function ball_observations(positions; occlusion=true)
        T = size(positions, 2)
        observations = zeros(3, T)

        for t in 1:T
            x, y = positions[:,t]

            visible = !occlusion || !(0.42 <= x <= 0.58)

            if visible
                observations[1,t] = 2x - 1
                observations[2,t] = 2y - 1
                observations[3,t] = 1.0
            end
        end

        return observations
    end

    # Build a random recurrent matrix with a chosen radius.
    function ball_make_esn(n, radius)
        rng = MersenneTwister(2026)

        W = randn(rng, n, n)

        mask = rand(rng, n, n) .< 0.12
        W .*= mask

        actual_radius = maximum(abs.(eigvals(W)))
        W .*= radius / actual_radius

        Win = 0.65 .* randn(rng, n, 3)

        return Win, W
    end

    # Run observations through the frozen reservoir.
    function ball_run_esn(observations, Win, W)
        n = size(W, 1)
        T = size(observations, 2)

        states = zeros(n+1, T)
        h = zeros(n)

        for t in 1:T
            h = tanh.(Win * observations[:,t] + W*h)

            states[1:n,t] = h
            states[n+1,t] = 1.0  # Bias feature
        end

        return states
    end

    # Ridge regression readout.
    function ball_fit_readout(X, Y; ridge=1e-2)
        A = X*X' + ridge*I
        return transpose(A \ (X*Y'))
    end
end


# ╔═╡ 983856da-55b7-4455-a049-11ff616eed94

begin
    ball_rng = MersenneTwister(12345)

    ball_H = 12
    ball_train_T = 90

    ball_training_paths = [
        ball_generate(ball_rng, ball_train_T + ball_H)
        for i in 1:100
    ]

    # Independent test trajectory
    ball_test_path = ball_generate(
        MersenneTwister(98765),
        120
    )
end


# ╔═╡ 3c52a532-91b8-4801-82b6-04244a0c39af

md"""
### Configure the ESN

**Number of reservoir neurons (N)**

$(@bind ball_n Slider(40:20:100, default=60, show_value=true))

**Spectral radius (ρ)**

$(@bind ball_radius Slider(0.2:0.1:1.2, default=0.9, show_value=true))

Increasing reservoir size gives the readout more features to work with.

Changing the spectral radius adjusts the recurrent dynamics and can affect how much useful information the reservoir retains about earlier ball positions.
"""


# ╔═╡ bd4fff1f-c594-4aca-bf81-3d90af830b31

begin
    ball_Win, ball_W = ball_make_esn(ball_n, ball_radius)

    ball_feature_batches = Matrix{Float64}[]
    ball_target_batches = Matrix{Float64}[]

    for path in ball_training_paths
        observations = ball_observations(path)
        states = ball_run_esn(observations, ball_Win, ball_W)

        # Leave room for future targets.
        time_indices = 13:ball_train_T

        Xpart = states[:, time_indices]

        Ypart = zeros(
            2*(ball_H+1),
            length(time_indices)
        )

        for (j,t) in enumerate(time_indices)
            for k in 0:ball_H
                Ypart[2k+1:2k+2,j] = path[:,t+k]
            end
        end

        push!(ball_feature_batches, Xpart)
        push!(ball_target_batches, Ypart)
    end

    ball_X = hcat(ball_feature_batches...)
    ball_Y = hcat(ball_target_batches...)

    ball_Wout = ball_fit_readout(
        ball_X,
        ball_Y,
        ridge=1e-2
    )

    # Evaluate on a separate test sequence.
    ball_test_obs = ball_observations(ball_test_path)

    ball_test_states = ball_run_esn(
        ball_test_obs,
        ball_Win,
        ball_W
    )

    ball_test_preds = ball_Wout * ball_test_states

    md"""
    **Model trained**

    - Reservoir neurons: $(ball_n)
    - Spectral radius: $(round(ball_radius, digits=2))
    - Training samples: $(size(ball_X,2))
    - Readout outputs: $(size(ball_Wout,1))

    Only ``W_{\mathrm{out}}`` was fitted using ridge regression.
    """
end


# ╔═╡ b0762005-714e-4d0f-a5d5-eb4b089bfc16

md"""
### Explore the Ball's Motion

**Current observation frame**

$(@bind ball_frame Slider(15:90, default=35, show_value=true))

**How far into the future should the ESN predict?**

$(@bind ball_horizon Slider(0:12, default=6, show_value=true))

**Reveal the true future position?**

$(@bind ball_reveal CheckBox(default=true))

The observation slider changes how much of the trajectory the model has already seen.

The prediction-horizon slider changes which of the trained future predictions we inspect.

A horizon of **0** asks the ESN to estimate the ball's current location, even if it is hidden. Larger horizons ask it to forecast future positions.
"""


# ╔═╡ e1ec1c8f-cdb1-41a6-aa52-5af0a87da5ec

begin
    # Prediction vector from the current reservoir state.
    ball_prediction_vector = ball_test_preds[:, ball_frame]

    ball_predicted_positions = reshape(
        ball_prediction_vector,
        2,
        ball_H + 1
    )

    ball_target_frame = ball_frame + ball_horizon

    ball_true_current = ball_test_path[:,ball_frame]
    ball_true_future = ball_test_path[:,ball_target_frame]

    ball_pred_future = ball_predicted_positions[
        :,ball_horizon+1
    ]

    ball_is_visible = ball_test_obs[3,ball_frame] > 0.5

    ball_plot = plot(
        xlims=(0,1),
        ylims=(0,1),
        aspect_ratio=:equal,
        xlabel="Horizontal position",
        ylabel="Vertical position",
        title="ESN Bouncing-Ball Prediction",
        size=(800,550),
        legend=:outertopright,
        gridalpha=0.12
    )

    # Occluding wall.
    plot!(
        ball_plot,
        Shape(
            [0.42,0.58,0.58,0.42],
            [0.0,0.0,1.0,1.0]
        ),
        color=:gray,
        fillalpha=0.22,
        linealpha=0,
        label="Occluding wall"
    )

    # Observed history: only visible positions.
    visible_indices = [
        t for t in 1:ball_frame
        if ball_test_obs[3,t] > 0.5
    ]

    scatter!(
        ball_plot,
        ball_test_path[1,visible_indices],
        ball_test_path[2,visible_indices],
        color=:royalblue,
        alpha=0.35,
        markersize=3,
        label="Visible history"
    )

    # ESN's predicted trajectory over the selected horizon.
    plot!(
        ball_plot,
        ball_predicted_positions[1,1:ball_horizon+1],
        ball_predicted_positions[2,1:ball_horizon+1],
        color=:darkorange,
        linewidth=3,
        linestyle=:dash,
        marker=:circle,
        markersize=3,
        label="ESN forecast"
    )

    # Current position only if observed.
    if ball_is_visible
        scatter!(
            ball_plot,
            [ball_true_current[1]],
            [ball_true_current[2]],
            color=:royalblue,
            markersize=10,
            label="Current visible ball"
        )
    end

    # Predicted final position.
    scatter!(
        ball_plot,
        [ball_pred_future[1]],
        [ball_pred_future[2]],
        color=:darkorange,
        markersize=11,
        marker=:star5,
        label="Predicted target"
    )

    # Ground truth is optional.
    if ball_reveal
        scatter!(
            ball_plot,
            [ball_true_future[1]],
            [ball_true_future[2]],
            color=:green,
            markersize=9,
            marker=:diamond,
            label="True target"
        )
    end

    ball_plot
end


# ╔═╡ 04f768c6-74c4-4b76-a1cc-0c48e8712913

begin
    ball_errors = Float64[]

    # Only evaluate times with valid future targets.
    for k in 0:ball_H
        errors_k = Float64[]

        for t in 13:(size(ball_test_path,2)-ball_H)
            predicted = ball_test_preds[2k+1:2k+2,t]
            actual = ball_test_path[:,t+k]

            push!(errors_k, sum((predicted-actual).^2))
        end

        push!(ball_errors, sqrt(mean(errors_k)))
    end

    ball_error_plot = plot(
        0:ball_H,
        ball_errors,
        linewidth=3,
        marker=:circle,
        color=:purple,
        xlabel="Prediction horizon (frames)",
        ylabel="Position RMSE",
        title="How Does Prediction Error Change Over Time?",
        label="ESN error",
        size=(850,350),
        gridalpha=0.15
    )

    vline!(
        ball_error_plot,
        [ball_horizon],
        color=:red,
        linestyle=:dash,
        label="Selected horizon"
    )

    ball_error_plot
end


# ╔═╡ 6409fd02-22e8-4deb-9264-9a2f4bc85032

md"""
### What Do the Parameters Mean?

Recall our ESN update equation:

```math
h_t = \tanh(gW_{\mathrm{in}}u_t + Wh_{t-1})
```

The bouncing-ball experiment introduces the following parameters:

- **`ball_n` — Reservoir size (N):** The dimension of ``h_t``, representing the number of recurrent neurons. Increasing it gives the reservoir more features with which to represent motion history.

- **`ball_radius` — Spectral radius (ρ):** Determines the scale of the recurrent matrix ``W``. This affects how previous states influence future states. It is closely related to the recurrent-strength parameter ``s`` in our earlier example.

- **`ball_frame` — Current time (t):** Determines how much of the observed trajectory the model has processed before producing its forecast.

- **`ball_horizon` — Prediction delay (k):** Determines how many frames into the future we want to predict. Unlike the spectral radius, this does not change the reservoir's weights.

- **`ball_reveal`:** Determines whether we display the true future position. This only affects visualization.

The readout predicts future positions:

```math
\hat{p}_{t+k} = W_{\mathrm{out}}^{(k)}h_t+b^{(k)}
```

where ``p_t=[x_t,y_t]^\top`` represents the ball's position.

### What should we observe?

1. **Short-term prediction:** The ESN may predict nearby future positions more accurately than distant ones.
2. **Occlusion:** Even when the ball is invisible, the reservoir continues evolving from its previous state.
3. **Spectral radius:** Changing ``\rho`` changes how the reservoir processes and retains motion history.
4. **Long-horizon uncertainty:** The model may struggle when predicting collisions or motion many frames ahead.

**Key takeaway:** The reservoir provides a representation of recent observations that a trained readout can use to estimate hidden states and forecast future motion.
"""


# ╔═╡ 9fa9d099-1cc2-4b31-928d-f583091c868c

md"""
## 14 · Can an ESN Learn Chaos?

The Lorenz system is a classic example of **deterministic chaos**.

Although its equations are completely deterministic, tiny differences in initial conditions can produce dramatically different future trajectories.

Our experiment asks:

**Can an ESN reproduce the dynamics of the Lorenz system without knowing its equations?**

We will:

1. Generate observations from the Lorenz system.
2. Train only the ESN's linear readout.
3. Remove the true input and let the ESN generate its own future.
4. Compare short-term prediction accuracy with long-term attractor behavior.

The reservoir weights will remain frozen throughout training.
"""


# ╔═╡ 853ae50c-837f-45e1-881b-a6114ace3489

md"""
### The Lorenz Attractor

![Lorenz Attractor](https://upload.wikimedia.org/wikipedia/commons/5/5b/Lorenz_attractor_yb.svg)

The Lorenz attractor illustrates how a deterministic system can exhibit chaotic behavior, where small differences in initial conditions lead to dramatically different trajectories.

### The Lorenz System

The Lorenz system consists of three coupled nonlinear differential equations:

```math
\begin{aligned}
\frac{dx}{dt} &= \sigma(y-x) \\
\frac{dy}{dt} &= x(\rho_L-z)-y \\
\frac{dz}{dt} &= xy-\beta z
\end{aligned}
```

Using the classical parameter values:

```math
\sigma=10,\qquad \rho_L=28,\qquad \beta=\frac{8}{3}
```

- ``x,y,z`` represent the system's three state variables.
- ``\sigma`` controls the coupling between ``x`` and ``y``.
- ``\rho_L`` controls the system's driving parameter.
- ``\beta`` controls the damping of ``z``.

**Key takeaway:** Although these equations are deterministic, small differences in initial conditions can produce dramatically different trajectories, a defining characteristic of chaos.

"""


# ╔═╡ 0891c743-ab8a-4c9b-84a3-3a0849f89b30

begin
    function lorenz_derivative(s)
        x, y, z = s

        sigma = 10.0
        rho_L = 28.0
        beta = 8.0 / 3.0

        return [
            sigma * (y - x),
            x * (rho_L - z) - y,
            x*y - beta*z
        ]
    end

    function lorenz_rk4(s, dt)
        k1 = lorenz_derivative(s)
        k2 = lorenz_derivative(s + dt/2 * k1)
        k3 = lorenz_derivative(s + dt/2 * k2)
        k4 = lorenz_derivative(s + dt * k3)

        return s + dt/6 * (k1 + 2k2 + 2k3 + k4)
    end

    function lorenz_generate(T)
        trajectory = zeros(3, T)
        state = [1.0, 1.0, 1.0]

        # Discard the initial transient.
        for i in 1:1000
            state = lorenz_rk4(state, 0.01)
        end

        for t in 1:T
            state = lorenz_rk4(state, 0.01)
            state = lorenz_rk4(state, 0.01)

            trajectory[:,t] = state
        end

        return trajectory
    end

    lorenz_data = lorenz_generate(6000)
end


# ╔═╡ e9cf25d8-7196-4753-9777-71ed901c6335

begin
    lorenz_original_plot = plot(
        lorenz_data[1,1:4000],
        lorenz_data[2,1:4000],
        lorenz_data[3,1:4000],
        seriestype=:path3d,
        color=:royalblue,
        linewidth=1.5,
        label="True Lorenz system",
        xlabel="x",
        ylabel="y",
        zlabel="z",
        title="The Lorenz Attractor",
        size=(850,550),
        camera=(45,25),
        legend=:topright
    )

    lorenz_original_plot
end


# ╔═╡ e9ecbb3a-58f3-4386-a356-7fc8da81be27

begin
    function lorenz_make_reservoir(n, radius, input_gain)
        rng = MersenneTwister(2026)

        W_dense = randn(rng, n, n)

        # Roughly 6 recurrent connections per neuron.
        density = min(1.0, 6.0/n)
        W_dense .*= (rand(rng, n, n) .< density)

        actual_radius = maximum(abs.(eigvals(W_dense)))

        W_dense .*= radius / actual_radius
        W = sparse(W_dense)

        Win = input_gain .* randn(rng, n, 3)
        bias = 0.15 .* randn(rng, n)

        return Win, W, bias
    end

    function lorenz_update(h, u, Win, W, bias)
        return tanh.(Win*u + W*h + bias)
    end

    function lorenz_features(h)
        return vcat(1.0, h, h.^2)
    end

    function lorenz_fit(X, Y, ridge)
        # Do not regularize the intercept.
        A = X*X'
        for i in 2:size(A,1)
            A[i,i] += ridge
        end

        return transpose(A \ (X*Y'))
    end

    # Fixed normalization based on the typical Lorenz scale.
    lorenz_center = [0.0, 0.0, 25.0]
    lorenz_scale = [20.0, 30.0, 25.0]

    function lorenz_normalize(p, center, scale)
        return (p .- center) ./ scale
    end

    function lorenz_denormalize(p, center, scale)
        return p .* scale .+ center
    end
end


# ╔═╡ 18152571-6aae-4e80-93c6-288dadd10610

md"""
### Configure the Reservoir

**Reservoir size (N)** — Number of recurrent neurons

$(@bind lorenz_n Slider(60:30:180, default=120, show_value=true))

**Spectral radius (ρ)** — Strength of recurrent dynamics

$(@bind lorenz_radius Slider(0.3:0.1:1.3, default=0.9, show_value=true))

**Input gain (g)** — How strongly observations affect the reservoir

$(@bind lorenz_input_gain Slider(0.1:0.1:1.0, default=0.4, show_value=true))

**Ridge regularization (λ)** — Penalty on readout weights

$(@bind lorenz_ridge Select([
    1e-6 => "0.000001",
    1e-5 => "0.00001",
    1e-4 => "0.0001",
    1e-3 => "0.001",
    1e-2 => "0.01"
], default=1e-4))
"""


# ╔═╡ 03db0f35-76d5-4b56-9663-0b926e61f72c

begin
    lorenz_Win, lorenz_W, lorenz_bias =
        lorenz_make_reservoir(
            lorenz_n,
            lorenz_radius,
            lorenz_input_gain
        )

    lorenz_U = (
        lorenz_data .- lorenz_center
    ) ./ lorenz_scale

    lorenz_train_start = 300
    lorenz_train_end = 3900

    lorenz_feature_count = 2*lorenz_n + 1
    lorenz_train_count =
        lorenz_train_end - lorenz_train_start + 1

    lorenz_X = zeros(
        lorenz_feature_count,
        lorenz_train_count
    )

    lorenz_Y = zeros(3, lorenz_train_count)

    # Local reservoir state avoids the soft-scope warning.
    local h = zeros(lorenz_n)

    # Wash in using the preceding training observations.
    for t in 1:(lorenz_train_start-1)
        h = lorenz_update(
            h, lorenz_U[:,t],
            lorenz_Win, lorenz_W, lorenz_bias
        )
    end

    # Collect reservoir states and next-step targets.
    for (j,t) in enumerate(
        lorenz_train_start:lorenz_train_end
    )
        h = lorenz_update(
            h, lorenz_U[:,t],
            lorenz_Win, lorenz_W, lorenz_bias
        )

        lorenz_X[:,j] = lorenz_features(h)
        lorenz_Y[:,j] = lorenz_U[:,t+1]
    end

    # Train only the readout weights.
    lorenz_Wout = lorenz_fit(
        lorenz_X,
        lorenz_Y,
        lorenz_ridge
    )

    lorenz_train_prediction = lorenz_Wout * lorenz_X

    lorenz_training_rmse = sqrt(
        mean((lorenz_train_prediction - lorenz_Y).^2)
    )

    md"""
    ### Training complete

    - **Reservoir neurons:** $(lorenz_n)
    - **Spectral radius:** $(lorenz_radius)
    - **Input gain:** $(lorenz_input_gain)
    - **Readout features:** $(lorenz_feature_count)
    - **Training transitions:** $(lorenz_train_count)
    - **Training RMSE (normalized):** $(round(lorenz_training_rmse, digits=5))

    The matrices ``W`` and ``W_{\mathrm{in}}`` remain fixed.

    Only ``W_{\mathrm{out}}`` is learned through ridge regression.
    """
end


# ╔═╡ eb258318-19a1-40c4-afa9-69f729563297

begin
    lorenz_test_start = 4100
    lorenz_test_length = 1000

    # Synchronize the reservoir with real observations.
    local lorenz_h0 = zeros(lorenz_n)

    for t in 4001:lorenz_test_start
        lorenz_h0 = lorenz_update(
            lorenz_h0,
            lorenz_U[:,t],
            lorenz_Win,
            lorenz_W,
            lorenz_bias
        )
    end

    # Store the predictions.
    lorenz_autonomous = zeros(3, lorenz_test_length)
    lorenz_teacher = zeros(3, lorenz_test_length)

    # Local variables prevent soft-scope ambiguity.
    local h_auto = copy(lorenz_h0)
    local h_teacher = copy(lorenz_h0)

    for j in 1:lorenz_test_length

        # Autonomous mode:
        # Predict using the current reservoir state.
        pred_auto = lorenz_Wout * lorenz_features(h_auto)

        lorenz_autonomous[:,j] = pred_auto

        # Feed the predicted state back into the ESN.
        h_auto = lorenz_update(
            h_auto,
            pred_auto,
            lorenz_Win,
            lorenz_W,
            lorenz_bias
        )

        # Teacher-forced mode:
        # Predict one step from the current state.
        pred_teacher = lorenz_Wout * lorenz_features(h_teacher)

        lorenz_teacher[:,j] = pred_teacher

        # Update using the TRUE next observation.
        h_teacher = lorenz_update(
            h_teacher,
            lorenz_U[:,lorenz_test_start+j],
            lorenz_Win,
            lorenz_W,
            lorenz_bias
        )
    end

    # Ground-truth test trajectory.
    lorenz_true_test = lorenz_data[
        :,
        (lorenz_test_start+1):
        (lorenz_test_start+lorenz_test_length)
    ]

    # Convert normalized predictions back to Lorenz coordinates.
    lorenz_pred_test = (
        lorenz_autonomous .* lorenz_scale
    ) .+ lorenz_center

    lorenz_teacher_test = (
        lorenz_teacher .* lorenz_scale
    ) .+ lorenz_center

    # Compute prediction errors.
    lorenz_auto_error = [
        norm(
            lorenz_pred_test[:,j] -
            lorenz_true_test[:,j]
        )
        for j in 1:lorenz_test_length
    ]

    lorenz_teacher_error = [
        norm(
            lorenz_teacher_test[:,j] -
            lorenz_true_test[:,j]
        )
        for j in 1:lorenz_test_length
    ]

    md"""
    ### Autonomous Generation Complete

    The ESN generated **$(lorenz_test_length) time steps**
    without receiving true Lorenz observations.

    **Mean teacher-forced one-step error:**
    $(round(mean(lorenz_teacher_error), digits=3))

    **Mean autonomous trajectory error:**
    $(round(mean(lorenz_auto_error), digits=3))

    The autonomous model feeds its own predictions back into
    the reservoir, allowing errors to accumulate over time.
    """
end


# ╔═╡ e225a082-5946-4e9e-a2be-f3b324711ea8

md"""
### Explore the Learned Attractor

**Current frame** — How far through the autonomous trajectory we are viewing.

$(@bind lorenz_frame Slider(
    50:10:1000,
    default=250,
    show_value=true
))

**Trajectory window** — Number of recent time steps shown in detail.

$(@bind lorenz_window Slider(
    40:20:300,
    default=160,
    show_value=true
))

**3D viewing angle** — Rotate the attractor visualization.

$(@bind lorenz_camera Slider(
    0:10:350,
    default=45,
    show_value=true
))
"""


# ╔═╡ 720acf7e-f558-46b4-9b78-42f1c906656c

begin
    lorenz_lo = max(
        1,
        lorenz_frame - lorenz_window + 1
    )

    lorenz_idx = lorenz_lo:lorenz_frame

    lorenz_common = (
        xlims=(-30,30),
        ylims=(-35,35),
        zlims=(0,60),
        xlabel="x",
        ylabel="y",
        zlabel="z",
        camera=(lorenz_camera,25),
        legend=false,
        gridalpha=0.12
    )

    # True Lorenz trajectory.
    lorenz_plot_true = plot(
        lorenz_true_test[1,lorenz_idx],
        lorenz_true_test[2,lorenz_idx],
        lorenz_true_test[3,lorenz_idx];
        seriestype=:path3d,
        color=:royalblue,
        linewidth=2,
        title="True Lorenz System",
        lorenz_common...
    )

    scatter!(
        lorenz_plot_true,
        [lorenz_true_test[1,lorenz_frame]],
        [lorenz_true_test[2,lorenz_frame]],
        [lorenz_true_test[3,lorenz_frame]];
        color=:royalblue,
        markersize=5,
        label=false
    )

    # Autonomous ESN trajectory.
    lorenz_plot_esn = plot(
        lorenz_pred_test[1,lorenz_idx],
        lorenz_pred_test[2,lorenz_idx],
        lorenz_pred_test[3,lorenz_idx];
        seriestype=:path3d,
        color=:darkorange,
        linewidth=2,
        title="Autonomous ESN",
        lorenz_common...
    )

    scatter!(
        lorenz_plot_esn,
        [lorenz_pred_test[1,lorenz_frame]],
        [lorenz_pred_test[2,lorenz_frame]],
        [lorenz_pred_test[3,lorenz_frame]];
        color=:darkorange,
        markersize=5,
        label=false
    )

    plot(
        lorenz_plot_true,
        lorenz_plot_esn,
        layout=(1,2),
        size=(1100,490),
        bottom_margin=5Plots.mm
    )
end


# ╔═╡ 3a92e6c6-8c6c-4325-a018-b377f8baf8e9

begin
    lorenz_times = (1:lorenz_frame) .* 0.02

    lorenz_x_plot = plot(
        lorenz_times,
        lorenz_true_test[1,1:lorenz_frame],
        label="True x(t)",
        color=:royalblue,
        linewidth=2.5,
        xlabel="Time after autonomous start",
        ylabel="x-coordinate",
        title="Can the ESN Track the True Trajectory?",
        size=(950,380),
        gridalpha=0.15
    )

    plot!(
        lorenz_x_plot,
        lorenz_times,
        lorenz_pred_test[1,1:lorenz_frame],
        label="Autonomous ESN",
        color=:darkorange,
        linewidth=2
    )

    plot!(
        lorenz_x_plot,
        lorenz_times,
        lorenz_teacher_test[1,1:lorenz_frame],
        label="Teacher-forced one-step",
        color=:green,
        linewidth=1.5,
        linestyle=:dash,
        alpha=0.75
    )

    lorenz_x_plot
end


# ╔═╡ a583a69f-bd4c-4852-80cc-0e458b8149f6

begin
    lorenz_error_times = (
        1:lorenz_frame
    ) .* 0.02

    lorenz_error_plot = plot(
        lorenz_error_times,
        max.(
            lorenz_auto_error[1:lorenz_frame],
            1e-6
        ),
        color=:darkorange,
        linewidth=2.5,
        label="Autonomous prediction",
        xlabel="Time after autonomous start",
        ylabel="3D position error",
        yscale=:log10,
        title="How Quickly Does the ESN Lose the Exact Trajectory?",
        size=(950,380),
        gridalpha=0.2
    )

    plot!(
        lorenz_error_plot,
        lorenz_error_times,
        max.(
            lorenz_teacher_error[1:lorenz_frame],
            1e-6
        ),
        color=:green,
        linewidth=2,
        linestyle=:dash,
        label="Teacher-forced one-step prediction"
    )

    lorenz_error_plot
end


# ╔═╡ 2f5506ec-cd6b-4cd4-a507-dc8b63a73312

begin
    lorenz_full_true = plot(
        lorenz_true_test[1,:],
        lorenz_true_test[2,:],
        lorenz_true_test[3,:],
        seriestype=:path3d,
        color=:royalblue,
        linewidth=1.2,
        xlims=(-30,30),
        ylims=(-35,35),
        zlims=(0,60),
        camera=(lorenz_camera,25),
        xlabel="x",
        ylabel="y",
        zlabel="z",
        title="True Attractor",
        legend=false
    )

    lorenz_full_esn = plot(
        lorenz_pred_test[1,:],
        lorenz_pred_test[2,:],
        lorenz_pred_test[3,:],
        seriestype=:path3d,
        color=:darkorange,
        linewidth=1.2,
        xlims=(-30,30),
        ylims=(-35,35),
        zlims=(0,60),
        camera=(lorenz_camera,25),
        xlabel="x",
        ylabel="y",
        zlabel="z",
        title="ESN-Generated Attractor",
        legend=false
    )

    plot(
        lorenz_full_true,
        lorenz_full_esn,
        layout=(1,2),
        size=(1100,490)
    )
end


# ╔═╡ 2b571237-9790-43bc-905b-3184f2372943

md"""
### Understanding the Lorenz ESN Parameters

Recall our reservoir equation:

```math id="h7qz2r"
h_t = \tanh(gW_{\mathrm{in}}u_t + Wh_{t-1} + b)
```

Our trained readout is:

```math id="k3p9af"
\hat{u}_{t+1} = W_{\mathrm{out}}\phi(h_t)
```

where ``\phi(h_t)=[1;h_t;h_t^2]`` provides additional nonlinear features for the readout.

#### Model parameters

- **`lorenz_n` — Reservoir size (N):** The number of recurrent neurons, corresponding to the dimension of ``h_t``. Larger reservoirs provide more features for representing the Lorenz dynamics.

- **`lorenz_radius` — Spectral radius (ρ):** Controls the spectral radius of the recurrent matrix ``W``. This affects how strongly previous states influence the current reservoir state.

- **`lorenz_input_gain` — Input gain (g):** Scales ``W_{\mathrm{in}}``. Larger values increase the influence of the current Lorenz observation and can push reservoir neurons toward saturation.

- **`lorenz_ridge` — Regularization (λ):** Controls the penalty on the trained readout weights. It affects ``W_{\mathrm{out}}``, not the frozen reservoir.

#### Visualization parameters

- **`lorenz_frame` — Current time step:** Determines how far through the generated trajectory we observe.

- **`lorenz_window` — History length:** Determines how many recent trajectory points appear in the detailed 3D comparison.

- **`lorenz_camera` — Viewing angle:** Rotates the visualization without changing the model.

### Autonomous Generation

During ordinary one-step prediction, the reservoir receives the true Lorenz observations.

During autonomous generation, the ESN instead receives its own previous predictions:

```math id="v4td8n"
\hat{u}_{t+1}=W_{\mathrm{out}}\phi(h_t)
```

```math id="a6m2xb"
h_{t+1}=\tanh(W_{\mathrm{in}}\hat{u}_{t+1}+Wh_t+b)
```

**Key takeaway:** Even when exact long-term predictions diverge because of chaos, an ESN may still learn to reproduce the broader geometric and statistical properties of the dynamical system.
"""


# ╔═╡ 7190c5a1-a24c-50e5-9573-c45118725a68
md"""
## 15 · The math you need (and what can wait)

| Idea | Minimum understanding |
|:--|:--|
| Vector | A list of neuron activities, e.g. ``x_t`` |
| Matrix-vector multiplication | Each neuron receives a weighted combination of inputs or previous activities |
| Nonlinearity | ``\tanh`` changes that combination componentwise |
| Recurrence | The next state uses the previous state: ``x_t=f(x_{t-1},u_t)`` |
| Linear regression | A readout learns coefficients combining state features |
| Spectral radius (later concept) | Largest eigenvalue magnitude; one useful heuristic for recurrent behavior |

You don't need to derive eigenvalues or backpropagation through time to run this notebook. What matters is understanding why **the same current input may lead to different states when the earlier input history differs**.
"""

# ╔═╡ 10174019-d0b2-5d3e-a128-13bcc634b451
md"""
## 16 · Main takeaways

1. **An ESN uses a fixed recurrent network to transform input history into a high-dimensional state.**
2. **Recurrence gives its states a fading influence from previous inputs.**
3. **Random neurons provide different nonlinear views of recent history.**
4. **The readout is trained; the reservoir usually is not.**
5. **Reservoir settings control the tradeoff between fast forgetting and overly persistent or saturated dynamics.**

> **Don't train the dynamics. Train how to read the dynamics.**

**Optional exploration:** Try to find two radius settings that give visibly different impulse decays but similar measured memory curves. What might that teach us about the difference between *visible activity* and *decodable information*?

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
Plots = "~1.41.7"
PlutoUI = "~0.7.84"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.13.0"
manifest_format = "2.1"
project_hash = "081d3ab64d7d32c84f29b261f5d086a09018cefe"

[[deps.AbstractPlutoDingetjes]]
git-tree-sha1 = "e71ee7b4aa06b045259a7d6101e1cb45ad140bce"
registries = "General"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.1"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
registries = "General"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
registries = "General"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "0cfb779e24fdced77a05df1dbe99200821a9f563"
registries = "General"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.8+1"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "060adaf7a5c2e14bca025edf0eea0206ffdebd87"
registries = "General"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.32.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "af523e59de94de05b9b367a2ca4d63233aacd222"
registries = "General"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.5"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "96fce5c80e0834e96ab6d24fb384fd945c9cb2d4"
registries = "General"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.2"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Reexport"]
git-tree-sha1 = "0737a3e59f9d94957f5b177fa2ca40901636b85b"
registries = "General"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.5.5+2"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
registries = "General"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
registries = "General"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "b0bc6d2cad1fed8b7fd59a1551a991cb3d2809e6"
registries = "General"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.6"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "473e9afc9cf30814eb67ffa5f2db7df82c3ad9fd"
registries = "General"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.16.2+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
registries = "General"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
git-tree-sha1 = "38ef52f18cbdfa783ec6c25acc23fb1e8525ec16"
registries = "General"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.10.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
registries = "General"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f2659a735f9360fedfa29925812380f322679e93"
registries = "General"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.10.0+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "7bd13840b4148949e290748071bbe6826b3eabcd"
registries = "General"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.6"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libva_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d9d3cd382f2c999f684e6bfa4039fcc16c153b6f"
registries = "General"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "9.0.2+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
registries = "General"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "e1e9ba3a8f5d71e6ae698f138a1362aeabb42e9f"
registries = "General"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.18.3+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
registries = "General"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d95a7a3a7e0f2fffc6291bd33035830aab01310b"
registries = "General"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.15.0+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e894be022a2eba58463939f1bf1f7f7006f27f52"
registries = "General"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.19+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "64bbbb7d1499297751b536dd39c58b20750ab1db"
registries = "General"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.5.1+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "4d777f73c46b46b8b5276206059cf8a195499314"
registries = "General"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.27"

    [deps.GR.extensions]
    IJuliaExt = "IJulia"

    [deps.GR.weakdeps]
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f8eb8f7ba13ea75083531647fc8faeda8d541f07"
registries = "General"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.27+0"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
registries = "General"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
registries = "General"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "ea9f1fb37ff10597353b56f3ba0ebd525acef6e0"
registries = "General"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.90.1+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "69ffb934a5c5b7e086a0b4fee3427db2556fba6e"
registries = "General"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.16+0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "f700c32c1e9e11b576592043f270e6b33868a56f"
registries = "General"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "100.15000.0+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
registries = "General"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
registries = "General"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
registries = "General"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "d22e8bdb3f03c300a103ff23c0dd5a654c6701de"
registries = "General"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.7"

[[deps.JLFzf]]
deps = ["REPL", "Random", "fzf_jll"]
git-tree-sha1 = "82f7acdc599b65e0f8ccd270ffa1467c21cb647b"
registries = "General"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.11"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7204148362dafe5fe6a273f855b8ccbe4df8173e"
registries = "General"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.8.0"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "06d90f699285d055e34f0b014636a75a17ff2252"
registries = "General"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.13.4"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]
    JSONSerializationExt = ["Serialization"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Serialization = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e06b451acfb1c6fa5ea753b5042207226271f455"
registries = "General"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.2.1+0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
registries = "General"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6d7c65411dda4bfa0beb7490476122b4f805cf31"
registries = "General"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.3.0+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e5b100780d4d30d63b4618d7930d48af409c1772"
registries = "General"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "23.1.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f88f3ccef05a6a72a0cf0ed417c8fd68530f4ab2"
registries = "General"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.1"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "df7566479bd64f20bd16b09960145e70160ffb3b"
registries = "General"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.12"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "1.0.0"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "Zstd_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.18.0+1"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "PCRE2_jll", "Zlib_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.1+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl", "OpenSSL_jll", "Zlib_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.103+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
registries = "General"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
registries = "General"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
registries = "General"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b8a91037379e1fd661e9b5ff3d7a770424b1f9f2"
registries = "General"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.42.4+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "aebd334d06cee9f24cea70bd19a39749daf73881"
registries = "General"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.3+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "9e887184f306b28dbfcff88cefbb0ec80f1aa9e0"
registries = "General"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.42.4+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.13.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "28d620bcdb37a3fb02de9f521928ee453690f414"
registries = "General"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "1.0.3"

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
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
registries = "General"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
registries = "General"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.Measures]]
git-tree-sha1 = "b513cedd20d9c914783d8ad83d08120702bf2c77"
registries = "General"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.3"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "d9d20d6eb2a3290ba5c70a1c013b45305cc39c9e"
registries = "General"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2026.8.13"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "676c0f1c1c34224d6869675047a54b42fdc7b8c5"
registries = "General"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.5"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
registries = "General"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.30+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e2bb57a313a74b8104064b7efd01406c0a50d2ff"
registries = "General"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.6.1+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "b079a6affebde167dad8ffe0d670b53917fbcb68"
registries = "General"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "2.0.3"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.46.0+0"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1912a9f1b9ca55005b03ba075f8e19993583e237"
registries = "General"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.58.2+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools"]
git-tree-sha1 = "91503bbab255aec9374145accd1b09c7e108cd54"
registries = "General"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "3.0.5"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "e4a6721aa89e62e5d4217c0b21bd714263779dda"
registries = "General"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.46.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "Zstd_jll", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.13.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
registries = "General"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Reexport", "Statistics"]
git-tree-sha1 = "ddcc36fd83fb4cd459a53c891981697bde0d3de6"
registries = "General"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.5.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "83bd514e8ff16b5858ac54c53fa0bcf6002a3b00"
registries = "General"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.41.7"

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

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "9869376035f47756b8b8e711fd0d06a06d51da6f"
registries = "General"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.84"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "edbeefc7a4889f528644251bdb5fc9ab5348bc2c"
registries = "General"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "aef1987d90dcc2e2cbd919ad10b2d25bcce4f418"
registries = "General"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.6.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
registries = "General"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "144895f6166994730ee7ff8113b981fc360638f1"
registries = "General"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.10.2+2"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll", "Qt6Svg_jll"]
git-tree-sha1 = "159d253ab126d5b29230cf53521899bea4ef4648"
registries = "General"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.10.2+2"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "4d85eedf69d875982c46643f6b4f66919d7e157b"
registries = "General"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.10.2+1"

[[deps.Qt6Svg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "81587ff5ff25a4e1115ce191e36285ede0334c9d"
registries = "General"
uuid = "6de9746b-f93d-5813-b365-ba18ad4a9cf3"
version = "6.10.2+0"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "672c938b4b4e3e0169a07a5f227029d4905456f2"
registries = "General"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.10.2+1"

[[deps.REPL]]
deps = ["Base64", "Dates", "FileWatching", "InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "0c0dcffc464cda2ff33fc8ffc1dd1bdd53cd98be"
registries = "General"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.4.0"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
registries = "General"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
registries = "General"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
registries = "General"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
registries = "General"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "1.0.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
registries = "General"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates"]
git-tree-sha1 = "8238217340ad0aaabe11afe39c1098b5bc9f4c8e"
registries = "General"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.1.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "13cd91cc9be159e3f4d95b857fa2aa383b53772a"
registries = "General"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.3"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.13.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
registries = "General"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
registries = "General"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "adb9da019510162e67a4493fc235c23203d8b09e"
registries = "General"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.13"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "b04bfab37484defe300b2f9ed64469abab2431ff"
registries = "General"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.12.0"

    [deps.StructUtils.extensions]
    StructUtilsDBInterfaceExt = ["DBInterface", "Tables"]
    StructUtilsDataFramesExt = ["DataFrames"]
    StructUtilsLazilyInitializedFieldsExt = ["LazilyInitializedFields"]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    DBInterface = "a10d1c49-ce27-4219-8d33-6db1a4562965"
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    LazilyInitializedFields = "0e77f7df-68c5-4e49-93ce-4cd80f5598bf"
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.10.1+0"

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
registries = "General"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
registries = "General"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
deps = ["Serialization"]
git-tree-sha1 = "eb3b85ca904a1d1647b15acc091b113b8874b648"
registries = "General"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.7.3"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
registries = "General"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
registries = "General"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
registries = "General"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "96478df35bbc2f3e1e791bc7a3d0eeee559e60e9"
registries = "General"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.24.0+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e52eca002a11c30a858185efdfb15311e1c7a6bf"
registries = "General"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.4+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3ea76ee3f4facd7a64684f9af25310825ee3668"
registries = "General"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.2+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "9c7ad99c629a44f81e7799eb05ec2746abb5d588"
registries = "General"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.6+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "ce91b54a5f90c4f27df6950706234b34e49cf79e"
registries = "General"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.14+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
registries = "General"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c74ca84bbabc18c4547014765d194ff0b4dc9da"
registries = "General"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.4+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
registries = "General"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "1a4a26870bf1e5d26cd585e38038d399d7e65706"
registries = "General"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.8+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "75e00946e43621e09d431d9b95818ee751e6b2ef"
registries = "General"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.2+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "704274ca960c42049fd9bda089fc4be32af5cdca"
registries = "General"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.5+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "0ba01bc7396896a4ace8aab67db31403c71628f4"
registries = "General"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.7+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c174ef70c96c76f4c3f4d3cfbe09d018bcd1b53"
registries = "General"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.6+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a54cf54677c9f6eac0d97e9d757c233b56bc21b9"
registries = "General"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.13+0"

[[deps.Xorg_libpciaccess_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "58972370b81423fc546c56a60ed1a009450177c3"
registries = "General"
uuid = "a65dc6b1-eb27-53a1-bb3e-dea574b5389e"
version = "0.19.0+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
registries = "General"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "ed756a03e95fff88d8f738ebc2849431bdd4fd1a"
registries = "General"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.2.0+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "9750dc53819eba4e9a20be42349a6d3b86c7cdf8"
registries = "General"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.6+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f4fc02e384b74418679983a97385644b67e1263b"
registries = "General"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll"]
git-tree-sha1 = "68da27247e7d8d8dafd1fcf0c3654ad6506f5f97"
registries = "General"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "44ec54b0e2acd408b0fb361e1e9244c60c9c3dd4"
registries = "General"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "5b0263b6d080716a02544c55fdff2c8d7f9a16a0"
registries = "General"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.10+0"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f233c83cad1fa0e70b7771e0e21b061a116f2763"
registries = "General"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.2+0"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "9a5e6e8f1a7c40941465c04840145e527f0d6b4b"
registries = "General"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.5.0+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "df77b22eb77051b3d0ef30aab979684f7482c66f"
registries = "General"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.48.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
registries = "General"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["CompilerSupportLibraries_jll", "Libdl"]
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c3b0e6196d50eab0c5ed34021aaa0bb463489510"
registries = "General"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.14+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6a34e0e0960190ac2a4363a1bd003504772d631"
registries = "General"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.61.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "21e05cef1411bfe6b22a1ca8cbdc64a297d4b447"
registries = "General"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.15.3+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "cb007192783c56d8249db4cf0e3495001edfe414"
registries = "General"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.5+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
registries = "General"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libdrm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libpciaccess_jll"]
git-tree-sha1 = "28e57478e8a160d346a19c28b3fffb9273bcc9c2"
registries = "General"
uuid = "8e53e030-5e6c-5a89-a30b-be5b7263a166"
version = "2.4.134+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "56d643b57b188d30cccc25e331d416d3d358e557"
registries = "General"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.13.4+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
registries = "General"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "91d05d7f4a9f67205bd6cf395e488009fe85b499"
registries = "General"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.28.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "1fcd6cf05d23adab0b5ffc496d020537215751dc"
registries = "General"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.59+1"

[[deps.libva_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "libdrm_jll"]
git-tree-sha1 = "21cbc8fc2ac0bb182ed461e556d9c062ae6a3164"
registries = "General"
uuid = "9a156e7d-b971-5f62-b2c9-67348b8fb97c"
version = "2.24.1+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
registries = "General"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b4d631fd51f2e9cdd93724ae25b2efc198b059b1"
registries = "General"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.7+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.67.1+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.8.2+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
registries = "General"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
registries = "General"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "a1fc6507a40bf504527d0d4067d718f8e179b2b8"
registries = "General"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.13.0+0"

[registries.General]
url = "https://github.com/JuliaRegistries/General.git"
uuid = "23338594-aafe-5451-b93e-139f81909106"
"""

# ╔═╡ Cell order:
# ╟─a2610797-a873-5a49-bed0-ff1302024aa0
# ╟─affcad7e-fa50-4300-80fd-4d08cc47d804
# ╟─a3228763-0dae-4e13-8346-08d48d9d5b86
# ╟─131c19e2-3a11-420e-9f6f-77c0e95c03d4
# ╟─0a58d8c8-3110-4a3f-9f21-14f29702a301
# ╟─b9cae793-3951-5b2a-bb95-373504fd2909
# ╟─7494c497-d0e9-5544-afc1-0a2cd4052729
# ╟─9ba4e057-4056-5c1b-a2c2-df782cbb41c1
# ╟─8d77036e-a085-4ede-9aee-9a7f9d73d450
# ╟─f946eb98-ac1d-5daf-a827-c05ccd48d227
# ╟─9c8eb871-01f6-58ac-8b43-13827d79fecd
# ╟─a4031068-b259-5567-8cc0-0403fd872612
# ╟─e9960987-cbcb-5803-b9d9-dfcc2149cac0
# ╟─c0f90186-6d8b-4ddc-8c67-c0093b854423
# ╟─f5fbcfa3-e372-4b22-9e4a-8d73c01ab2a3
# ╟─f623e7b8-a764-475e-b2cb-ee86b61b2493
# ╟─01c51696-7c48-47c4-9e19-a59f2f4b7022
# ╟─4c40a600-cbcb-5653-89a0-cdc3a46900e2
# ╟─7c741da4-866c-4f26-99c6-515760c8d7e7
# ╟─cb084983-8ca9-5eb2-ad99-698b5f471e78
# ╟─578c95d2-4a0b-5f94-a39b-cc2552314c84
# ╟─e89222fc-61c9-5e34-8d43-2a3f0d24b7fe
# ╟─3397283f-aca0-5d82-8cf4-de010887dc64
# ╟─718c21a6-06fa-539d-927b-a84390cc78f6
# ╟─cfefa664-9801-59d8-a14c-464c6292b3ea
# ╟─4f0f06c5-2510-54a9-b6dd-8c90332da706
# ╟─c2c16da8-13f8-44c2-9b83-dc284ce18d93
# ╠═0ce89ae1-255d-524c-85db-2b95daf17464
# ╠═a59b952b-e516-57fd-aa32-a6bbfe8da722
# ╠═b6c5d343-adbd-5dea-af04-e47574b6b037
# ╟─08c2661e-4205-5d5f-a9f2-df7f79c8d17e
# ╠═efd55a4d-10bf-5bd5-8ebe-2ae0716a4e25
# ╟─4e1857cd-ae83-53b7-a239-b455012fe7ce
# ╟─009ffbed-3fbd-583b-8189-eb62478a170d
# ╟─27adc9d7-5a45-5a32-924b-116bc829fce2
# ╟─f3eef579-414e-5089-a791-aa60cdb18e1b
# ╠═a43c95aa-cd02-5c44-9a0b-0070c7946dc2
# ╠═808abf72-5819-5c4e-a5aa-0e9e73f15b8b
# ╟─d72f8d3d-0290-5367-96b7-7e4ed3ad6c80
# ╠═7cdc9368-fd49-5c4c-8e40-536063733741
# ╠═2e4e4c66-ca3e-506b-bce7-d4b8ef5a1a50
# ╟─8cbd2738-6aba-4922-a729-6a4604c1f179
# ╟─cab67fbe-0b60-47d6-aed7-2d356b4119ef
# ╟─983856da-55b7-4455-a049-11ff616eed94
# ╟─3c52a532-91b8-4801-82b6-04244a0c39af
# ╟─bd4fff1f-c594-4aca-bf81-3d90af830b31
# ╟─b0762005-714e-4d0f-a5d5-eb4b089bfc16
# ╟─e1ec1c8f-cdb1-41a6-aa52-5af0a87da5ec
# ╟─04f768c6-74c4-4b76-a1cc-0c48e8712913
# ╟─6409fd02-22e8-4deb-9264-9a2f4bc85032
# ╟─9fa9d099-1cc2-4b31-928d-f583091c868c
# ╟─853ae50c-837f-45e1-881b-a6114ace3489
# ╠═0891c743-ab8a-4c9b-84a3-3a0849f89b30
# ╟─e9cf25d8-7196-4753-9777-71ed901c6335
# ╟─e9ecbb3a-58f3-4386-a356-7fc8da81be27
# ╠═f3e1211f-66c8-4367-a2d5-eae99d4fdc65
# ╟─18152571-6aae-4e80-93c6-288dadd10610
# ╟─03db0f35-76d5-4b56-9663-0b926e61f72c
# ╟─eb258318-19a1-40c4-afa9-69f729563297
# ╟─e225a082-5946-4e9e-a2be-f3b324711ea8
# ╟─720acf7e-f558-46b4-9b78-42f1c906656c
# ╟─3a92e6c6-8c6c-4325-a018-b377f8baf8e9
# ╟─a583a69f-bd4c-4852-80cc-0e458b8149f6
# ╟─2f5506ec-cd6b-4cd4-a507-dc8b63a73312
# ╟─2b571237-9790-43bc-905b-3184f2372943
# ╟─7190c5a1-a24c-50e5-9573-c45118725a68
# ╟─10174019-d0b2-5d3e-a128-13bcc634b451
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
