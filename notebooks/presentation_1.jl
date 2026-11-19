### A Pluto.jl notebook ###
# v1.0.3

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

# ╔═╡ a78d2311-d0d5-4c85-993c-e8b1c3a9aa46
begin
    using PlutoUI, Plots, StaticArrays, ForwardDiff, LinearAlgebra, Printf, LaTeXStrings, Random
    gr()
    default(lw = 2, framestyle = :box, size = (760, 400), legendfontsize = 8,
            guidefontsize = 11, tickfontsize = 9, titlefontsize = 11)
end

# ╔═╡ bdd640fb-0667-4ad1-9c80-317fa3b1799d
md"""
# The Hodgkin–Huxley Model

*Maxwell (Yuquan) Zhou · 2026/10/13*

**Overview** 
1. Background 
2. The Hodgkin–Huxley model
3. Predictions of the model
4. The FitzHugh–Nagumo simplification 
5. The nerve-axon equations 
"""

# ╔═╡ 153c50a5-b9e8-4417-ae13-7a366defb1d9
default(margin = 5Plots.mm)

# ╔═╡ ae12ac31-971f-43fe-a7dc-d3c04ea2cbac
md"""
# 1 · The biology of a neuron

A neuron is a cell built to send a signal in one direction. **Dendrites** collect inputs from other cells, the **soma** (cell body) adds them up, and the **axon** carries the output, sometimes for more than a metre, to **synapses**, where the signal is handed to the next cell chemically. The human brain has about 86 billion of them.

Inside a neuron the signal is electrical. The cell membrane separates two salt solutions of different composition: potassium is concentrated inside, sodium outside. At rest the inside sits about 65–70 mV below the outside. When the inputs push it past a **threshold**, the cell fires an **action potential**: a pulse of roughly 100 mV that lasts about a millisecond and then travels down the axon *without shrinking*. It is **all-or-none**: a stronger stimulus produces more spikes, never a bigger one.

Everything in this talk is about two facts in that paragraph: there is a **threshold**, and the pulse travels **without shrinking**.
"""

# ╔═╡ 7306d631-270d-48ac-90ba-18eb313eaab9
LocalResource("neuron_cell.png")

# ╔═╡ 25fb2e51-29ac-5024-93ac-ef35efa73d2e
md"""
### A century of experiments

| year | who | what it showed |
|:---|:---|:---|
| 1791 | Luigi Galvani | Nerve and muscle are electrical: a frog's leg twitches when its nerve is stimulated. |
| 1840s | Emil du Bois-Reymond | A travelling electrical disturbance, the "negative variation", accompanies the nerve impulse. |
| 1850 | Hermann von Helmholtz | The impulse is *slow*, a few tens of metres per second in frog nerve, nothing like current in a wire. |
| 1890s | Santiago Ramón y Cajal | The nervous system is made of separate cells (the neuron doctrine). Sherrington names their contacts *synapses* in 1897. |
| 1902 | Julius Bernstein | The resting potential comes from a membrane permeable mainly to K⁺. He guessed that during the impulse the membrane becomes permeable to everything, so the voltage simply falls to zero. |
| 1936 | J. Z. Young | The squid has a **giant axon**, about half a millimetre across, wide enough to slide a wire inside. |
| 1939 | Kenneth Cole and Howard Curtis | During the impulse the membrane's conductance rises sharply. |
| 1939 | Alan Hodgkin and Andrew Huxley | A wire inside the squid axon shows the voltage **overshoots** zero and reverses sign, so Bernstein's "breakdown" picture cannot be right. |
| 1949 | Hodgkin and Bernard Katz | The overshoot depends on external Na⁺: the upstroke is carried by sodium. |
| 1952 | Hodgkin and Huxley | A series of five voltage-clamp papers (the first with Katz), ending in the equations this talk is about. |
| 1963 | | Nobel Prize to Hodgkin, Huxley and John Eccles. |

#### What came later

Hodgkin and Huxley did not know what an ion channel was; they wrote of charged "particles" moving within the membrane. The next fifty years kept confirming their picture:

* **1973:** Clay Armstrong and Francisco Bezanilla measured *gating currents*, the tiny movement of charge inside the membrane that the gating "particles" implied.
* **1976:** Erwin Neher and Bert Sakmann's patch clamp recorded the current through a **single** channel, a protein flicking between open and closed. The smooth gating variables are averages over thousands of these random switches (Nobel Prize 1991).
* **1998:** Roderick MacKinnon's group solved the structure of a potassium channel: **four identical subunits** around a central pore, matching the $n^4$ that had been chosen in 1952 to fit a curve (Nobel Prize 2003).

The model is still an approximation. The gates are not truly independent (sodium inactivation is coupled to activation), real neurons carry dozens of channel types, and the ion gradients the model takes for granted are maintained by pumps it leaves out. Most axons in our bodies are also myelinated rather than giant and bare. Even so, every modern "conductance-based" neuron model is written in Hodgkin and Huxley's form.
"""

# ╔═╡ 1f0f6e6c-4891-48ad-8e38-24a752e8652a
md"""
**The Key Question:**
1. What are the underlying mechanisms behind the formation and transmission of neural signals?
2. Can we create models that help predict neural phenomena?
"""

# ╔═╡ edd58c7a-ddbc-4601-a7a0-84cd02339a4a
md"""
# 2. The Hodgkin–Huxley model

A living cell is enormously complicated, so the first modelling decision is what to keep track of. Hodgkin and Huxley's answer is the **membrane voltage** $V$, plus a few variables describing the ion channels.

Picture a neuron as a tiny bag of salt water floating in more salt water. The dissolved particles are **ions**, which carry positive or negative charge, and the mixture on the two sides of the membrane is different: the inside holds a slight excess of negative charge. Separated charge stores energy, like water held behind a dam, and the **voltage** across the membrane measures that stored energy per unit charge. Give the ions a path and they will flow.

The derivation has five steps: 
1. The membrane is a capacitor 
2. Ions are driven by diffusion and electricity 
3. Channels open and close 
4. Potassium and sodium channels gate differently 
5. TThe construction of coupled differential equations
"""

# ╔═╡ f373bdd1-2283-4dba-9a2d-5c0d7059660a
md"""
## Step 1 · The membrane is a capacitor

The lipid membrane is a thin insulator between two conducting solutions, so it stores charge like a capacitor:

```math
Q = C\,V \quad\Longrightarrow\quad C\,\frac{dV}{dt} = \frac{dQ}{dt}.
```

The membrane is not a perfect insulator, though. Embedded proteins called **ion channels** let specific ions through, and each type acts like a resistor wired in parallel with the capacitor. Since current is the rate of change of charge,

```math
C\,\frac{dV}{dt} \;=\; -\sum_{\text{ion types}} I_{\text{ion}} \;+\; I_{\text{inj}} .
```

**This is the first equation of the model:** the voltage changes only because current flows. Everything that follows is about what those currents are.

Below, a 10 ms current pulse is injected into a patch of membrane. With no open channels the capacitor charges linearly. Add a constant **leak** conductance $g$ and the voltage instead levels off, approaching its new value with time constant $\tau = C/g$.
"""

# ╔═╡ 40d6444f-123c-456b-894c-df7367b3ffe9
md"""
i.e. Blue = no ion channel; Red = has ion channel
"""

# ╔═╡ 1ca8cb2b-c8d1-4fd7-a9fc-901d5d72ec2c
md"""
Injected current (µA/cm²): $(@bind I_inj Slider(0.0:0.25:5.0; default = 2.0, show_value = true))   leak conductance (mS/cm²): $(@bind g_leak_demo Slider(0.1:0.1:2.0; default = 0.3, show_value = true))
"""

# ╔═╡ 63028ef0-8e30-40ef-9aa7-b36675bd3778
let
    C = 1.0                                   # µF/cm²
    t = 0:0.05:40                             # ms; current on from 5 to 15 ms
    # capacitor only:  C dV/dt = I            →  V rises linearly while the current is on
    V_cap = [I_inj / C * clamp(ti - 5, 0, 10) for ti in t]
    # capacitor + leak: C dV/dt = I − g V     →  exponential approach to I/g with time constant C/g
    τ = C / g_leak_demo
    V_rc = map(t) do ti
        ti < 5  ? 0.0 :
        ti < 15 ? I_inj / g_leak_demo * (1 - exp(-(ti - 5) / τ)) :
                  I_inj / g_leak_demo * (1 - exp(-10 / τ)) * exp(-(ti - 15) / τ)
    end
    plot(t, V_cap; label = "capacitor only", xlabel = "time (ms)", ylabel = "V - V_rest (mV)",
         title = "Charging a patch of membrane", legend = :topright)
    plot!(t, V_rc; label = @sprintf("capacitor + leak (tau = C/g = %.1f ms)", τ))
    vspan!([5, 15]; color = :gray, alpha = 0.15, label = "current on")
end

# ╔═╡ 7a7ce7c1-cba3-4b5b-8530-c192db9a1488
md"""
## Step 2 · Why ions move: diffusion against electricity

The current through open channels depends on two things: **how many channels are open** and **how hard the ions are pushed**. Two forces do the pushing, and they usually pull in opposite directions.

* **Diffusion.** Ions move randomly, so if there are more of them on one side, more of them happen to wander through channels from that side. Potassium is about 30 times more concentrated inside a neuron than outside, so diffusion pushes K⁺ **out**.
* **Electricity.** The inside is negative, so positive ions such as K⁺ are pulled **in**.

Which force wins depends on the voltage. At one special value, the **equilibrium (reversal) potential**, the two balance exactly: ions still cross in both directions, but there is no net flow.

**Deriving it.** At equilibrium the ions follow Boltzmann statistics: the concentration at electric potential $\phi$ is proportional to $e^{-zq\phi/k_BT}$ for an ion of charge $zq$. Comparing the two sides of the membrane, $V = \phi_{\text{in}} - \phi_{\text{out}}$,

```math
\frac{[\text{ion}]_{\text{in}}}{[\text{ion}]_{\text{out}}} = e^{-zFV/RT}
\quad\Longrightarrow\quad
E_{\text{ion}} = \frac{RT}{zF}\,\ln\frac{[\text{ion}]_{\text{out}}}{[\text{ion}]_{\text{in}}} ,
```

the **Nernst equation** (per mole: $F = N_A q$ and $R = N_A k_B$). For potassium with a 30-fold ratio at body temperature it gives about −90 mV; for sodium, concentrated outside, it is positive, about +50 mV.
"""

# ╔═╡ 6adfd41f-67f3-4a91-a442-8f260a4eb5d6
LocalResource("equilibrium_potential.jpg")

# ╔═╡ d03205ad-a3cd-4b4d-9f16-ebd0e5ce87ba
md"""
When the voltage differs from $E_{\text{ion}}$, ions flow in whichever direction moves $V$ back toward $E_{\text{ion}}$, and the current is proportional to the difference. This is **Ohm's law**, with the **conductance** $g$ (the inverse of resistance) measuring how many channels are open and how easily ions get through:

```math
I_{\text{ion}} = g_{\text{ion}}\,\big(V - E_{\text{ion}}\big).
```

The difference $V - E_{\text{ion}}$ is called the **driving force**. Below, a membrane whose only open channels are potassium channels starts from several different voltages. Wherever it starts, the potassium current drives $V$ to $E_K$.
"""

# ╔═╡ e48698a5-c0a4-48ff-a111-da203916630f
md"""
## Step 3 · Channels open and close: gating variables

So far the conductance has been constant, as if the channels were permanent holes. The crucial fact about real neurons is that many channels are **voltage-gated**: they open or close depending on $V$ itself. Write the conductance as a maximum times a fraction:

```math
g(V, t) = \bar g \cdot p(V, t), \qquad 0 \le p \le 1 .
```

Here $\bar g$ is the conductance if every channel were open, set by how many channels the membrane has, and $p$ is the fraction open at the moment. Equivalently, $p$ is the **probability** that any one channel is open.

Zoom in on one channel. It is a protein with charged parts, call them **gates**, that shift in the electric field across the membrane. Each gate is either *permissive* or *non-permissive*, and ions pass only when **every** gate is permissive, like the pins of a lock that must all line up.

Let $n$ be the probability that a given gate is permissive. Non-permissive gates, a fraction $1-n$, open at rate $\alpha(V)$; permissive gates, a fraction $n$, close at rate $\beta(V)$:

```math
\frac{dn}{dt} = \alpha_n(V)\,(1-n) - \beta_n(V)\,n \;=\; \frac{n_\infty(V) - n}{\tau_n(V)},
\qquad n_\infty = \frac{\alpha_n}{\alpha_n+\beta_n},\quad \tau_n = \frac{1}{\alpha_n+\beta_n}.
```

At a fixed voltage, $n$ relaxes exponentially to $n_\infty(V)$ with time constant $\tau_n(V)$. There is no first-principles formula for $\alpha$ and $\beta$: Hodgkin and Huxley chose combinations of exponentials that fitted their measurements.
"""

# ╔═╡ bf43b662-f8d0-4bbb-9df5-09cd522dacd8
begin
    # Hodgkin & Huxley's empirical rate functions (1/ms), V in mV, squid axon at 6.3 °C.
    # Modern sign convention: the resting potential is about −65 mV.
    vtrap(x) = abs(x) < 1e-6 ? 1 + x / 2 : x / (1 - exp(-x))    # x / (1 − e⁻ˣ), safe at x = 0

    αₙ(V) = 0.1 * vtrap((V + 55) / 10)
    βₙ(V) = 0.125 * exp(-(V + 65) / 80)
    αₘ(V) = vtrap((V + 40) / 10)
    βₘ(V) = 4.0 * exp(-(V + 65) / 18)
    αₕ(V) = 0.07 * exp(-(V + 65) / 20)
    βₕ(V) = 1 / (1 + exp(-(V + 35) / 10))

    n_inf(V) = αₙ(V) / (αₙ(V) + βₙ(V));   τₙ(V) = 1 / (αₙ(V) + βₙ(V))
    m_inf(V) = αₘ(V) / (αₘ(V) + βₘ(V));   τₘ(V) = 1 / (αₘ(V) + βₘ(V))
    h_inf(V) = αₕ(V) / (αₕ(V) + βₕ(V));   τₕ(V) = 1 / (αₕ(V) + βₕ(V))
end

# ╔═╡ e5a7bc65-ca3e-4724-aeee-2ae8389e9124
let
    V = -100:0.5:40
    p1 = plot(V, [αₙ.(V) βₙ.(V)]; label = [L"\alpha_n(V)" L"\beta_n(V)"], xlabel = "V (mV)",
              ylabel = "rate (1/ms)", title = "Potassium gate: opening vs closing rate", legend = :topleft)
    p2 = plot(V, n_inf.(V); label = L"n_\infty(V)", xlabel = "V (mV)", ylabel = "steady-state value",
              title = "Depolarization opens it", legend = :topleft)
    p3 = plot(V, τₙ.(V); label = L"\tau_n(V)", xlabel = "V (mV)", ylabel = "time constant (ms)",
              title = "...over a few milliseconds")
    plot(p1, p2, p3; layout = (1, 3), size = (1000, 320))
end

# ╔═╡ 558464f8-efff-47ab-afe8-d3c8897a6bb5
md"""
!!! tip "Observations about Julia:"
    The functions above are called `αₙ`, `βₘ` and `τₕ`, can be typed as `\alpha` Tab `\_n` Tab. Julia identifiers can use Unicode, so the code reads like the actual equations. A dot after a function name *broadcasts* it over an array: `n_inf.(V)` evaluates the steady state at every voltage in `V`, and an expression such as `αₙ.(V) .+ βₙ.(V)` is fused into a single loop with no temporary arrays.
"""

# ╔═╡ 227ffb97-a614-4a0c-9dbe-1fefaa004cdf
md"""
## Step 4 · Gates in detail: potassium vs sodium

### Potassium: four gates make a delay

A potassium channel needs **four** gates in the permissive position at once. If the gates act independently, probability theory gives

```math
p_K = n^4, \qquad g_K = \bar g_K\, n^4 .
```

Hodgkin and Huxley did not get this from molecular biology; they got it from curve fitting. When they stepped the voltage up, the potassium conductance did not rise straight away, as one exponentially relaxing gate would. It started slowly, with an S-shaped delay, and a fourth power fitted the shape. Decades later, X-ray crystallography showed that the potassium channel is built from **four identical subunits** around its pore (2003 Nobel Prize in Chemistry)

Choose a voltage step and compare one gate, $n$, with whole channels needing 2, 3 or 4 gates:
"""

# ╔═╡ 53c0a169-ecdf-4f2c-853d-0d231f8ba6b5
md"""
Voltage step from −65 mV to (mV): $(@bind V_step Slider(-50.0:5.0:50.0; default = 0.0, show_value = true))
"""

# ╔═╡ 5ee9df75-549b-4889-9caa-a118b622ef23
let
    V0, t = -65.0, 0:0.02:12
    n = n_inf(V_step) .+ (n_inf(V0) - n_inf(V_step)) .* exp.(-t ./ τₙ(V_step))
    plt = plot(; xlabel = "time after the step (ms)", ylabel = "normalized rise", legend = :bottomright,
               title = "Step from -65 mV to $(Int(V_step)) mV: more gates, longer delay")
    for k in 1:4
        y = n .^ k
        plot!(plt, t, (y .- y[1]) ./ (y[end] - y[1]); lw = k == 4 ? 3 : 1.5,
              label = k == 1 ? "n  (a single gate)" : "n^$k  ($k gates must open)")
    end
    plt
end

# ╔═╡ be62e866-dd8c-4af4-8fcb-45d5fac7a582
md"""
### Probabilities made visible: simulating single channels

Because $n$ is a probability, a single channel should flicker randomly between open and closed, and only the **average** over many channels should follow the smooth curve. Below, every simulated potassium channel has four independent gates. In each time step $\Delta t$, a closed gate opens with probability $\alpha_n \Delta t$ and an open gate closes with probability $\beta_n \Delta t$. The membrane is held at −65 mV and stepped, at $t = 2$ ms, to the voltage chosen above.
"""

# ╔═╡ caf05331-0709-4338-9999-f50b55c26833
"""
    stochastic_K_channels(N, V_hold, V_step; T, t_step, dt, seed)

Simulate `N` potassium channels, each with four independent gates. The membrane is held at
`V_hold` and stepped to `V_step` at time `t_step`. Returns the times and the fraction of open channels.
"""
function stochastic_K_channels(N, V_hold, V_step; T = 12.0, t_step = 2.0, dt = 0.01, seed = 2026)
    rng = Random.Xoshiro(seed)
    open_gate = rand(rng, 4, N) .< n_inf(V_hold)          # start every gate at its equilibrium
    ts = collect(0:dt:T)
    frac_open = zeros(length(ts))
    for (k, t) in enumerate(ts)
        frac_open[k] = count(j -> all(@view open_gate[:, j]), 1:N) / N
        V = t < t_step ? V_hold : V_step
        p_open, p_close = αₙ(V) * dt, βₙ(V) * dt            # transition probabilities for one step
        for j in 1:N, g in 1:4
            open_gate[g, j] = open_gate[g, j] ? (rand(rng) > p_close) : (rand(rng) < p_open)
        end
    end
    return ts, frac_open
end

# ╔═╡ 5e32515c-71db-447b-aced-7b4d10007441
md"""
Number of channels: $(@bind N_channels Select([1, 10, 100, 1000, 5000]; default = 10))
"""

# ╔═╡ 16655f36-147b-4f43-8848-7af0762b8ae6
let
    ts, frac = stochastic_K_channels(N_channels, -65.0, V_step)
    n_det = [t < 2.0 ? n_inf(-65.0) : n_inf(V_step) + (n_inf(-65.0) - n_inf(V_step)) * exp(-(t - 2.0) / τₙ(V_step))
             for t in ts]
    plot(ts, frac; seriestype = :steppost, color = :gray, label = "$(N_channels) simulated channel(s)",
         xlabel = "time (ms)", ylabel = "fraction of channels open", ylims = (-0.02, 1.02),
         title = "Random single channels average out to n^4", legend = :topleft)
    plot!(ts, n_det .^ 4; color = :crimson, lw = 3, label = "Hodgkin-Huxley prediction: n(t)^4")
    vline!([2.0]; ls = :dot, color = :black, label = "voltage step")
end

# ╔═╡ 26fe5e45-f6ac-449f-bb28-1a02bec740dc
md"""
With one channel you see what the patch clamp finally recorded in 1976: an all-or-nothing current that switches at random moments. With thousands, the randomness averages out and the fraction open follows $n^4$. The smooth gating variables of the model are **averages** over many random molecular switches.
"""

# ╔═╡ 735a293f-bcb0-571f-9796-b9e95a427f63
md"""
### Sodium: three activation gates and one inactivation gate

The sodium channel follows the same recipe with a twist: it has **two kinds** of gate.

* Three **activation gates** $m$ open on depolarization, like $n$ but roughly ten times faster.
* One **inactivation gate** $h$ does the opposite: it *closes* when the membrane stays depolarized.

```math
g_{Na} = \bar g_{Na}\, m^3 h, \qquad
\frac{dm}{dt} = \alpha_m(1-m) - \beta_m m, \qquad
\frac{dh}{dt} = \alpha_h(1-h) - \beta_h h .
```

|  | K⁺ channel | Na⁺ channel |
|:---|:---|:---|
| activation gates | four $n$ gates, slow (ms) | three $m$ gates, fast (0.1 ms) |
| inactivation gate | none | one $h$ gate, slow, closes when depolarized |
| conductance | $\bar g_K\,n^4$ | $\bar g_{Na}\,m^3h$ |
| reversal potential | $E_K \approx -77$ mV: current flows **out** | $E_{Na} \approx +50$ mV: current flows **in** |
| role in a spike | recovery | excitation |
"""

# ╔═╡ 57e5eb70-f702-4818-a320-8f028ac09788
let
    V = -100:0.5:40
    p1 = plot(V, [m_inf.(V) h_inf.(V) n_inf.(V)]; label = [L"m_\infty" L"h_\infty" L"n_\infty"],
              xlabel = "V (mV)", ylabel = "steady-state value", title = "Where each gate settles", legend = :right)
    p2 = plot(V, [τₘ.(V) τₕ.(V) τₙ.(V)]; label = [L"\tau_m" L"\tau_h" L"\tau_n"],
              xlabel = "V (mV)", ylabel = "time constant (ms)", title = "How fast it gets there")
    plot(p1, p2; layout = (1, 2), size = (920, 340))
end

# ╔═╡ 1a2a73ed-562b-4f79-8374-59eef50bea63
md"""
**The whole mechanism is in this picture.** $m$ is about ten times faster than $h$ and $n$. A small depolarization opens $m$, Na⁺ rushes in, the membrane depolarizes further and opens still more $m$ gates: **runaway positive feedback**. About a millisecond later the slow gates catch up: $h$ shuts sodium off and $n$ lets potassium out. Fast excitation followed by slow recovery is the core of every model in this talk; the FitzHugh–Nagumo model of Section 5 keeps exactly this and nothing else.
"""

# ╔═╡ 4fceac85-93a3-4db1-a7c6-2b30cfdf3089
md"""
### The experiment behind the rate functions: voltage clamp

Hodgkin and Huxley measured $\alpha$ and $\beta$ with the **voltage clamp**, a feedback amplifier that holds the membrane at a chosen voltage $V_c$.

#### Step 1 · Clamp the voltage

Hold the membrane at rest, then step it suddenly to $V_c$ and keep it there.

#### Step 2 · Record the current

With the voltage fixed, $C\,dV/dt = 0$, so the current the amplifier supplies equals the total ionic current:

```math
I_{\text{clamp}}(t) = I_{Na}(t) + I_K(t) + I_L(t).
```

#### Step 3 · Isolate potassium

Replace the external sodium with an ion that cannot pass through the channel (choline). The sodium current disappears, and the small leak current is subtracted. What remains is the potassium current alone.

#### Step 4 · Convert current to conductance

By Ohm's law, with $E_K$ the potassium equilibrium potential:

```math
g_K(t) = \frac{I_K(t)}{V_c - E_K}.
```

#### Step 5 · Convert conductance to the gate

Since $g_K = \bar g_K\, n^4$,

```math
n(t) = \left(\frac{g_K(t)}{\bar g_K}\right)^{1/4}.
```

The maximal conductance $\bar g_K$ is estimated from the largest conductance reached at strong depolarizations, where almost all the gates are open.

#### Step 6 · Read off n∞ and τₙ

At fixed voltage each gate relaxes exponentially (as a solution to the DE):

```math
x(t) = x_\infty(V_c) + \big(x(0) - x_\infty(V_c)\big)\,e^{-t/\tau_x(V_c)}, \qquad x \in \{m, h, n\}.
```

For a step to 0 mV:

* the starting value is $n_0 = (0.37/36)^{1/4} \approx 0.32$;
* the final value is $n_\infty = (24.6/36)^{1/4} \approx 0.91$;
* the time constant $\tau_n$ is the time to cover 63% of the way from start to finish. A cleaner way to get it is to plot $\ln(n_\infty - n(t))$ against $t$, which gives a straight line with slope $-1/\tau_n$. Here $\tau_n \approx 1.65$ ms.

#### Step 7 · Convert to α and β

Invert $n_\infty = \alpha/(\alpha+\beta)$ and $\tau_n = 1/(\alpha+\beta)$:

```math
\alpha_n = \frac{n_\infty}{\tau_n}, \qquad \beta_n = \frac{1 - n_\infty}{\tau_n}.
```

At 0 mV this gives $\alpha_n \approx 0.55$ and $\beta_n \approx 0.055$ per ms. These are the values of `αₙ(0)` and `βₙ(0)` in the code above.

#### Step 8 · Repeat and fit

Do Steps 1–7 at many clamp voltages to build a table of $\alpha_n$ and $\beta_n$. At negative voltages, where the gates close, step *down* from a depolarized level and fit the closing exponential in the same way. Finally, choose smooth formulas that pass through the points. These are the rate functions in the notebook's code.

Sodium follows the same recipe, with one complication. Its conductance $\bar g_{Na} m^3 h$ rises and then falls, so each trace is fitted with two exponentials: a fast one for $m$ and a slow one for $h$.

#### The model run backwards

Below, the model is put through the same experiment. The membrane is held at rest and stepped to $V_c$ at $t = 0$; the gray curves are steps to −40, −20, 0, +20 and +40 mV. The recorded current is first **inward** (sodium) and then **outward** (potassium), which is exactly why Step 3 is needed to pull the two apart.
"""

# ╔═╡ 954212bb-1797-453e-aa28-06c53cc2e376
md"""
Clamp voltage (mV): $(@bind V_clamp Slider(-60.0:5.0:60.0; default = 0.0, show_value = true))
"""

# ╔═╡ 4d1b316c-15f7-4ba7-a8fe-94c29f79a79b
md"""
Two features stand out, and both are what the gating picture predicts:

* **Sodium switches itself off.** Even with the voltage held high, $g_{Na}$ peaks within a millisecond and then decays, because the slow $h$ gate closes. The bigger the step, the faster this happens.
* **Potassium is delayed but persistent.** $g_K$ starts with an S-shaped lag (the $n^4$ again) and then stays on for as long as the clamp holds (i.e. as long the voltage is kept high)

Hodgkin and Huxley fitted $\alpha$ and $\beta$ to curves like these, voltage by voltage. The real test came next, because none of this fitting involved an action potential.
"""

# ╔═╡ 2d13a99d-fc87-44dc-aab4-4ec2f33bb949
md"""
## Step 5 · Putting it together

Add a small **leak** current with constant conductance to account for everything else, and the model is complete: four coupled differential equations.

```math
\begin{aligned}
C\,\frac{dV}{dt} &= I_{\text{inj}} - \bar g_{Na}\,m^3 h\,(V-E_{Na}) - \bar g_K\,n^4\,(V-E_K) - g_L\,(V-E_L),\\[2pt]
\frac{dx}{dt} &= \alpha_x(V)\,(1-x) - \beta_x(V)\,x, \qquad x \in \{m, h, n\}.
\end{aligned}
```

| parameter | value | meaning |
|:---|:---|:---|
| $C$ | 1 µF/cm² | membrane capacitance |
| $\bar g_{Na}$, $\bar g_K$, $g_L$ | 120, 36, 0.3 mS/cm² | maximal conductances |
| $E_{Na}$, $E_K$, $E_L$ | 50, −77, −54.4 mV | reversal potentials |

These are the squid-axon values in the modern sign convention. The −90 mV for $E_K$ in Step 2 is typical of mammalian neurons; the squid's is less negative.
"""

# ╔═╡ 3fa8ac97-8068-464b-8b1d-65c271457593
begin
    const C_m  = 1.0                                    # µF/cm²
    const ḡ_Na = 120.0;  const E_Na = 50.0              # mS/cm², mV
    const ḡ_K  = 36.0;   const E_K  = -77.0
    const g_L  = 0.3;    const E_L  = -54.387

    I_Na(V, m, h) = ḡ_Na * m^3 * h * (V - E_Na)
    I_K(V, n)     = ḡ_K * n^4 * (V - E_K)
    I_L(V)        = g_L * (V - E_L)

    # The whole model. State u = (V, m, h, n); I_inj(t) is the injected current.
    function hh_rhs(u, I_inj, t)
        V, m, h, n = u
        dV = (I_inj(t) - I_Na(V, m, h) - I_K(V, n) - I_L(V)) / C_m
        dm = αₘ(V) * (1 - m) - βₘ(V) * m
        dh = αₕ(V) * (1 - h) - βₕ(V) * h
        dn = αₙ(V) * (1 - n) - βₙ(V) * n
        return (dV, dm, dh, dn)
    end
end

# ╔═╡ 9c6ca05c-0893-4d17-8ebd-d946e2f0d6ad
begin
    """
        simulate(f, u0, (t0, t1); p, dt = 0.01)

    Classic fourth-order Runge–Kutta with a fixed step, for `du/dt = f(u, p, t)`.
    The state `u` can be any tuple or static vector of numbers.
    """
    function simulate(f, u0, tspan; p = nothing, dt = 0.01)
        t0, t1 = tspan
        nsteps = round(Int, (t1 - t0) / dt)
        h = (t1 - t0) / nsteps
        ts = [t0 + k * h for k in 0:nsteps]
        us = Vector{typeof(u0)}(undef, nsteps + 1)
        u = us[1] = u0
        for k in 1:nsteps
            t = ts[k]
            k1 = f(u, p, t)
            k2 = f(u .+ (h / 2) .* k1, p, t + h / 2)
            k3 = f(u .+ (h / 2) .* k2, p, t + h / 2)
            k4 = f(u .+ h .* k3, p, t + h)
            u = u .+ (h / 6) .* (k1 .+ 2 .* k2 .+ 2 .* k3 .+ k4)
            us[k + 1] = u
        end
        return ts, us
    end

    "Root of `f` between `a` and `b` (where `f` changes sign), by bisection."
    function bisect(f, a, b; iters = 60)
        fa = f(a)
        for _ in 1:iters
            c = (a + b) / 2
            fc = f(c)
            if sign(fc) == sign(fa)
                a, fa = c, fc
            else
                b = c
            end
        end
        return (a + b) / 2
    end
end

# ╔═╡ 64cdb86b-bd84-47b5-a547-9e3279697539
begin
    # Resting state for a constant current I: every gate at its steady state,
    # and the ionic currents balance I. Found by bisection on V.
    function rest_at(I)
        V = bisect(v -> I_Na(v, m_inf(v), h_inf(v)) + I_K(v, n_inf(v)) + I_L(v) - I, -90.0, 0.0)
        return (V, m_inf(V), h_inf(V), n_inf(V))
    end
    const u_rest = rest_at(0.0)
    const V_rest = u_rest[1]
end

# ╔═╡ 960ba1db-823b-4e81-9b15-3882ff5e4331
function voltage_clamp(Vc; V_hold = V_rest, T = 12.0, dt = 0.02)
    t = 0:dt:T
    relax(x0, x_end, τ) = x_end .+ (x0 - x_end) .* exp.(-t ./ τ)      # exponential approach at fixed V
    m = relax(m_inf(V_hold), m_inf(Vc), τₘ(Vc))
    h = relax(h_inf(V_hold), h_inf(Vc), τₕ(Vc))
    n = relax(n_inf(V_hold), n_inf(Vc), τₙ(Vc))
    gNa = ḡ_Na .* m .^ 3 .* h
    gK  = ḡ_K .* n .^ 4
    I   = gNa .* (Vc - E_Na) .+ gK .* (Vc - E_K) .+ g_L * (Vc - E_L)   # what the amplifier supplies
    return (; t, gNa, gK, I)
end

# ╔═╡ b8703d9d-f7d0-4ee9-a591-f747cd0c5b89
let
    p1 = plot(; ylabel = "current (uA/cm2)", title = "What the amplifier records (inward < 0)")
    p2 = plot(; ylabel = "g_Na (mS/cm2)", title = "Sodium: fast on, then off by itself")
    p3 = plot(; ylabel = "g_K (mS/cm2)", xlabel = "time after the step (ms)", title = "Potassium: delayed, then stays on")
    for Vc in -40.0:20.0:40.0
        r = voltage_clamp(Vc)
        for (pl, y) in ((p1, r.I), (p2, r.gNa), (p3, r.gK))
            plot!(pl, r.t, y; color = :gray, alpha = 0.4, lw = 1, label = "")
        end
    end
    r = voltage_clamp(V_clamp)
    plot!(p1, r.t, r.I; color = :black, lw = 3, label = "step to $(Int(V_clamp)) mV")
    plot!(p2, r.t, r.gNa; color = :crimson, lw = 3, label = "")
    plot!(p3, r.t, r.gK; color = :steelblue, lw = 3, label = "")
    hline!(p1, [0]; color = :gray, ls = :dot, label = "")
    plot(p1, p2, p3; layout = (3, 1), size = (760, 720), link = :x)
end

# ╔═╡ 7cbd5946-42c3-5cf1-a286-8ceb19c324a0
md"""
**Try it.** A current pulse is injected at t = 5 ms.

Pulse amplitude (µA/cm²): $(@bind I_amp Slider(-10.0:0.1:20.0; default = 10.0, show_value = true))   duration (ms): $(@bind I_dur Slider(0.5:0.5:40.0; default = 1.0, show_value = true))
"""

# ╔═╡ 5f603049-ab8e-41cd-86b1-1e9d3288d6bf
let
    stim(t) = 5.0 <= t < 5.0 + I_dur ? I_amp : 0.0
    ts, us = simulate(hh_rhs, u_rest, (0.0, 50.0); p = stim)
    V, m, h, n = (getindex.(us, i) for i in 1:4)
    p1 = plot(ts, V; color = :black, label = "", ylabel = "V (mV)", ylims = (-100, 60), title = "Membrane voltage")
    plot!(p1, ts, 2 .* stim.(ts) .- 95; color = :gray, lw = 1, label = "injected current (scaled)")
    p2 = plot(ts, [m h n]; label = ["m (Na activation)" "h (Na inactivation)" "n (K activation)"],
              ylabel = "gate value", ylims = (0, 1), title = "Gating variables", legend = :right)
    p3 = plot(ts, [I_Na.(V, m, h) I_K.(V, n)]; label = ["Na+ current (inward < 0)" "K+ current (outward > 0)"],
              ylabel = "uA/cm2", xlabel = "time (ms)", title = "Ionic currents", legend = :right)
    plot(p1, p2, p3; layout = (3, 1), size = (760, 760), link = :x)
end

# ╔═╡ e9db9796-88e7-4bb6-bfdb-5744f1fadbab
md"""
**Things to try**

* With a 1 ms pulse, find the threshold. Below about 6.9 µA/cm² the voltage barely moves; just above it you get a full spike, and nothing in between. The spike is **all-or-none**.
* Read the three panels together. First $m$ shoots up, so sodium floods in and the voltage rockets up; then, over a few milliseconds, $h$ falls and $n$ rises, so sodium shuts off and potassium drags $V$ down. This is the sequence from the sketch at the start of the section, now produced by the equations.
* Hold 10 µA/cm² for 40 ms: the neuron fires **repeatedly**.
* Inject a *negative* current, −5 µA/cm² for 20 ms. When it is switched off, the neuron fires anyway. The hyperpolarization re-opened the $h$ gates and closed the $n$ gates, so releasing it leaves the membrane briefly more excitable than at rest ("anode break excitation").
"""

# ╔═╡ 93ec16ec-928e-4afd-b703-8be67f276324
md"""
## Recap of the derivation

* The membrane is a **leaky capacitor**: $C\,dV/dt$ equals minus the sum of the ionic currents.
* Each ionic current obeys **Ohm's law** with driving force $V - E_{\text{ion}}$, where the Nernst potential $E_{\text{ion}}$ balances diffusion against the electric force.
* The conductances are **voltage-gated**, $g_K = \bar g_K n^4$ and $g_{Na} = \bar g_{Na} m^3 h$. Each gating variable is the probability that one gate is permissive and obeys $dx/dt = \alpha(1-x) - \beta x$.
* Fast activation ($m$) against slower inactivation and recovery ($h$ and $n$) produces the action potential, with nothing in charge.
"""

# ╔═╡ ebeebd1c-2f63-4a13-abb5-20e03eda4ea2
md"""
## Physical Intuition...
"""

# ╔═╡ f2cee6ea-dd33-4747-b896-ba9039a9b2b3
LocalResource("activation_potential.png")

# ╔═╡ 5fcce651-5d89-4f4c-86d7-a1f7850745b1
md"""
# 3. Predictions of the model

So far the input was a brief pulse. Now hold the injected current $I$ **constant** and ask what the neuron does in the long run. The slider below sets $I$ for the whole section; the current is switched on at t = 10 ms.

The right panel shows the same run in the plane of voltage $V$ and potassium activation $n$. Rest is a **point** in this plane; continuous firing is a **closed loop** that the state travels around once per spike, called a *limit cycle*. The three parts of this section explain when each one appears: the bifurcation diagram (4.1), the firing frequency and amplitude (4.2), and the resulting regimes of behaviour (4.3).
"""

# ╔═╡ 44addaf1-6ad6-4d2b-887d-f4849421c72a
begin
    # Times at which V crosses `level` upward, interpolated between samples
    function spike_times(ts, V; level = 0.0)
        [ts[k] + (level - V[k]) / (V[k+1] - V[k]) * (ts[k+1] - ts[k])
         for k in 1:length(V)-1 if V[k] < level <= V[k+1]]
    end

    # Eigenvalues of the 4×4 Jacobian at the resting state for current I (exact derivatives from ForwardDiff)
    rest_eigvals(I) = eigvals(ForwardDiff.jacobian(u -> collect(hh_rhs(u, t -> I, 0.0)), collect(rest_at(I))))

    # Long-run behaviour at constant current I, starting from state u0:
    # firing rate (Hz) and the voltage range over the last `window` ms
    function steady_firing(I, u0; T = 300.0, window = 100.0, dt = 0.02)
        ts, us = simulate(hh_rhs, u0, (0.0, T); p = t -> I, dt = dt)
        sel = ts .>= T - window
        tw, Vw = ts[sel], first.(us)[sel]
        lo, hi = extrema(Vw)
        hi - lo < 2 && return (rate = 0.0, Vmax = hi, Vmin = lo)       # no oscillation left
        sp = spike_times(tw, Vw; level = (hi + lo) / 2)
        rate = length(sp) >= 2 ? 1000 * (length(sp) - 1) / (sp[end] - sp[1]) : 0.0
        return (rate = rate, Vmax = hi, Vmin = lo)
    end
end

# ╔═╡ 0d695c02-e30c-4914-b32f-1ef7203a842d
md"""
Constant current I (µA/cm²): $(@bind I_dc Slider(vcat(0.0:0.25:15.0, 16.0:1.0:200.0); default = 10.0, show_value = true))
"""

# ╔═╡ 560bf4e6-3345-4b3c-973c-a440264eeae8
let
    on(t) = t >= 10.0 ? I_dc : 0.0
    ts, us = simulate(hh_rhs, u_rest, (0.0, 200.0); p = on)
    V, n = first.(us), last.(us)
    late = ts .>= 100.0                                     # judge the long-run behaviour from the last 100 ms
    lo, hi = extrema(V[late])
    sp = hi - lo > 2 ? spike_times(ts[late], V[late]; level = (hi + lo) / 2) : Float64[]
    rate = length(sp) >= 2 ? 1000 * (length(sp) - 1) / (sp[end] - sp[1]) : 0.0
    status = rate > 0 ? @sprintf("fires continuously at %.0f Hz", rate) : "silent in the long run"
    p1 = plot(ts, V; color = :black, label = "", xlabel = "time (ms)", ylabel = "V (mV)", ylims = (-90, 60),
              title = @sprintf("I = %.2f uA/cm2: %s", I_dc, status))
    vspan!(p1, [10, 200]; color = :orange, alpha = 0.08, label = "current on")
    p2 = plot(V, n; color = :gray, alpha = 0.5, label = "whole run", xlabel = "V (mV)", ylabel = "n (K activation)",
              xlims = (-90, 60), ylims = (0.2, 0.9), title = "Rest is a point, firing is a loop", legend = :topleft)
    plot!(p2, V[late], n[late]; color = :crimson, lw = 2.5, label = "last 100 ms")
    plot(p1, p2; layout = grid(1, 2; widths = [0.62, 0.38]), size = (980, 380))
end

# ╔═╡ c143bd7c-d9a4-4320-81d0-13517acd5f42
md"""
## 3.1 · The bifurcation diagram

A **bifurcation** is a qualitative change in behaviour when a parameter crosses a critical value; here the parameter is the current $I$. For every $I$ the model has exactly one resting state, where all four derivatives vanish. Whether it survives small disturbances is decided by the four eigenvalues of the Jacobian there, computed exactly with ForwardDiff: if every eigenvalue has a negative real part, disturbances die out.

* As $I$ rises, a **complex pair** of eigenvalues crosses into the right half-plane. Rest becomes unstable and the neuron has to fire. This is an **Andronov–Hopf bifurcation**.
* But a large firing loop already exists *before* that point. In between, rest and continuous firing **coexist**: the neuron is **bistable**, and what it does depends on its history. Because the loop appears at full size, firing starts at a finite rate. This is a *subcritical* Hopf bifurcation.
* At very large $I$ the pair crosses back, rest becomes stable again, and the oscillation disappears: **depolarization block**.

The diagram below collects the long-run behaviour for many currents; it takes a few seconds to compute.
"""

# ╔═╡ 6d6498af-e4fc-4d3c-97fe-4da49c9a6cbf
hopf_I = let
    growth(I) = maximum(real, rest_eigvals(I))       # largest real part of the eigenvalues at rest
    (lower = bisect(growth, 5.0, 15.0; iters = 40), upper = bisect(growth, 100.0, 200.0; iters = 40))
end

# ╔═╡ e13cd2dd-bb07-413e-ac11-c4b1c4045c7c
bif_branch = let
    Is = vcat(0.0:0.25:15.0, 16.0:1.0:200.0)
    Vrest = [rest_at(I)[1] for I in Is]
    stable = [maximum(real, rest_eigvals(I)) < 0 for I in Is]
    (; Is, Vrest, stable)
end

# ╔═╡ 76b71cc4-df12-4a44-8a8b-cb29dba6c7a4
# Long-run firing for many constant currents, each switched on from rest
fI_table = let Is = vcat(0.0:0.25:15.0, 16.0:2.0:200.0)
    (; Is, runs = [steady_firing(I, u_rest) for I in Is])
end

# ╔═╡ 0966b687-cfd7-4e9b-a782-36caab91ca1c
let b = bif_branch, r = fI_table
    Vs = copy(b.Vrest); Vs[.!b.stable] .= NaN          # stable part of the rest branch
    Vu = copy(b.Vrest); Vu[b.stable] .= NaN             # unstable part
    firing = [x.rate > 0 for x in r.runs]
    I_on = r.Is[findfirst(firing)]
    function panel(xmax, ttl, leg)
        plt = plot(b.Is, Vs; color = :black, lw = 2.5, label = "rest: stable", xlims = (0, xmax), ylims = (-90, 50),
                   xlabel = "constant current I (uA/cm2)", ylabel = "V (mV)", title = ttl, legend = leg)
        plot!(plt, b.Is, Vu; color = :black, ls = :dash, label = "rest: unstable")
        scatter!(plt, r.Is[firing], [x.Vmax for x in r.runs[firing]]; color = :crimson, ms = 2.5,
                 label = "firing: top and bottom of each spike")
        scatter!(plt, r.Is[firing], [x.Vmin for x in r.runs[firing]]; color = :crimson, ms = 2.5, label = "")
        vspan!(plt, [I_on, hopf_I.lower]; color = :orange, alpha = 0.2, label = "bistable")
        vline!(plt, [I_dc]; color = :gray, ls = :dot, label = "slider")
        return plt
    end
    plot(panel(200.0, "Bifurcation diagram", :topright), panel(15.0, "Zoom on the onset", false);
         layout = (1, 2), size = (980, 400))
end

# ╔═╡ 972a6e00-57ab-4fa0-b9b7-1614480b89c5
let r = fI_table
    firing = [x.rate > 0 for x in r.runs]
    k_on = findfirst(firing)
    f_max = maximum(x.rate for x in r.runs)
md"""
**In numbers** (squid axon at 6.3 °C, computed above):

* continuous firing appears at I ≈ $(r.Is[k_on]) µA/cm², already at about $(round(Int, r.runs[k_on].rate)) Hz;
* the resting state loses stability at the Hopf point I ≈ $(round(hopf_I.lower; digits = 2)) µA/cm², so the neuron is bistable between these two currents;
* the fastest firing is about $(round(Int, f_max)) Hz, and above I ≈ $(round(hopf_I.upper; digits = 1)) µA/cm² rest is stable again (depolarization block).

The bistability is not just a feature of the equations: Guttman, Lewis and Rinzel (1980) found it in real squid axons, where a brief, well-timed pulse can switch ongoing repetitive firing off.
"""
end

# ╔═╡ 9f34d948-39c5-445f-9996-b2e279485546
md"""
**See the bistability.** Set the current between about 6.3 and 9.8 µA/cm² with the slider above. The neuron starts exactly at rest and gets a 1 ms kick at t = 50 ms. A small kick dies away; a big enough one switches the neuron into continuous firing, which never stops, although the current is the same as before.

Kick size (µA/cm² for 1 ms): $(@bind kick_dc Slider(0.0:1.0:40.0; default = 10.0, show_value = true))
"""

# ╔═╡ 14d2c851-d48f-477e-a8ea-ecb5b236cd3a
let
    stim(t) = I_dc + (50.0 <= t < 51.0 ? kick_dc : 0.0)
    ts, us = simulate(hh_rhs, rest_at(I_dc), (0.0, 250.0); p = stim)
    grow = maximum(real, rest_eigvals(I_dc))
    plot(ts, first.(us); color = :black, label = "", xlabel = "time (ms)", ylabel = "V (mV)", ylims = (-90, 60),
         title = @sprintf("I = %.2f uA/cm2: rest is %s (largest Re of eigenvalues %.3f /ms)",
                          I_dc, grow < 0 ? "stable" : "unstable", grow), size = (900, 380))
    vline!([50.0]; color = :orange, ls = :dash, label = "kick")
end

# ╔═╡ af260316-0cec-4d25-88cd-3322c3f9ee94
md"""
**Hysteresis.** Now sweep the current slowly from 0 up to 15 µA/cm² and back down over two seconds. On the way up, firing starts near the Hopf point; on the way down, it continues until the firing loop disappears near 6.3. The neuron "remembers" which way the current was moving.
[i.e. The state of the firing depends not only on the present state but also the history. This is the consequence of the bistability regime]
"""

# ╔═╡ b62b7808-40ba-45b3-9b6f-63de07ffda4c
md"""
## 3.2 · Firing frequency and spike amplitude

The same runs give two more curves.

* **Frequency against current (the f–I curve).** The rate jumps from 0 to about 50 Hz: the squid axon cannot fire slowly, because the firing loop is born at full size (the subcritical Hopf bifurcation above). Hodgkin (1948) called this *class 2* excitability; neurons that can fire arbitrarily slowly are *class 1*. A thirty-fold range of current then only takes the rate from about 50 to 170 Hz.
* **Amplitude against frequency.** The faster the neuron fires, the smaller its spikes. Each new spike starts before the sodium inactivation ($h$) and potassium activation ($n$) have recovered from the last one, so less sodium current is available and more potassium current opposes it. At the top of the range the loop shrinks to nothing at the upper Hopf point.

The orange marker follows the slider.
"""

# ╔═╡ 907f3e1b-87c7-405e-bfc2-f92dba5e45f3
let r = fI_table
    rate = [x.rate for x in r.runs]
    amp  = [x.Vmax - x.Vmin for x in r.runs]
    on   = rate .> 0
    now  = steady_firing(I_dc, u_rest)
    p1 = plot(r.Is, rate; marker = :circle, ms = 2, label = "", xlabel = "constant current I (uA/cm2)",
              ylabel = "firing rate (Hz)", title = "f-I curve: a jump, then saturation")
    scatter!(p1, [I_dc], [now.rate]; color = :orange, ms = 8, label = @sprintf("slider: %.0f Hz", now.rate))
    p2 = scatter(rate[on], amp[on]; marker_z = r.Is[on], ms = 3, label = "", colorbar_title = "I (uA/cm2)",
                 xlabel = "firing rate (Hz)", ylabel = "spike amplitude, peak to trough (mV)",
                 title = "Faster firing, smaller spikes")
    now.rate > 0 && scatter!(p2, [now.rate], [now.Vmax - now.Vmin]; color = :orange, ms = 8, label = "slider")
    plot(p1, p2; layout = (1, 2), size = (980, 380))
end

# ╔═╡ 67edde1e-34b9-59fe-bd2a-742bbf620ae9
md"""
## 3.3 · Three regimes

Reading the bifurcation diagram at a fixed current predicts how the neuron answers a step of current from rest:

| current $I$ (µA/cm²) | response | why |
|:---|:---|:---|
| below about 2.5 | **no firing**: the voltage shifts slightly and settles | rest is stable and the step is too small to reach threshold |
| about 2.5 to 6.2 | **one spike** (sometimes two or three), then rest | the *switch-on* kicks the neuron over threshold, but rest is the only long-run state |
| about 6.3 to 155 | **continuous firing** for as long as the current lasts | the firing loop exists and the switch-on lands in it; above the Hopf point it is the only option |
| above about 155 | a brief transient, then **depolarization block** | rest is stable again, at a depolarized voltage |

The middle row says that a neuron responds to *changes* in its input as well as to its level. The slider at the top of the section moves through all four rows; the three typical cases are shown here.
"""

# ╔═╡ 59110ad4-a782-51b6-b2c8-e2b76ee52539
let
    cases = [(1.5, "no firing"), (4.0, "one spike, then rest"), (10.0, "continuous firing")]
    plts = map(cases) do (Iapp, name)
        ts, us = simulate(hh_rhs, u_rest, (0.0, 100.0); p = t -> t >= 10 ? Iapp : 0.0)
        plot(ts, first.(us); color = :black, label = "", ylims = (-90, 60), xlabel = "time (ms)",
             ylabel = "V (mV)", title = "I = $Iapp: $name")
    end
    plot(plts...; layout = (1, 3), size = (1000, 300))
end

# ╔═╡ 220eb743-7e86-4ba8-9a1d-f8af94d6d536
md"""
### Brief pulses instead of steps

Real inputs are often brief. Below, a pulse of amplitude $A$ and duration $d$ starts at t = 5 ms, and the colour counts the spikes that follow. The same regimes reappear:

* **No spike** in the middle band. A short pulse needs a larger amplitude, because a fixed amount of charge, roughly $A \times d \approx 7$ nC/cm², must be put on the capacitor before the sodium runaway starts.
* **One spike** for most pulses above threshold: the all-or-none response.
* **Several spikes** only for long, strong pulses (roughly $A \gtrsim 6$ µA/cm², lasting tens of milliseconds): a slice of continuous firing.
* **Anode break** at the bottom: a strong enough *negative* pulse also fires one spike, when it ends.

The white cross marks the pulse chosen with the sliders in Step 5. The map takes a few seconds to compute.
"""

# ╔═╡ 5dbf02e1-e3e4-5778-88de-d6e2d9a88c6e
# Spike count after a pulse of amplitude A (µA/cm²) and duration d (ms)
pulse_map = let amps = -10.0:0.5:20.0, durs = exp.(range(log(0.2), log(50.0); length = 25))
    function n_spikes(A, d)
        ts, us = simulate(hh_rhs, u_rest, (0.0, d + 30.0); p = t -> (5.0 <= t < 5.0 + d ? A : 0.0), dt = 0.02)
        return length(spike_times(ts, first.(us)))
    end
    (; amps, durs, N = [n_spikes(A, d) for A in amps, d in durs])
end

# ╔═╡ 4ccc3503-6402-5e7d-8521-49ce4f5d7a50
let r = pulse_map
    ticks = [0.2, 0.5, 1, 2, 5, 10, 20, 50]
    heatmap(log10.(r.durs), r.amps, r.N; c = cgrad(:viridis, 5; categorical = true), clims = (-0.5, 4.5),
            xticks = (log10.(ticks), ["0.2", "0.5", "1", "2", "5", "10", "20", "50"]),
            xlabel = "pulse duration d (ms, log scale)", ylabel = "pulse amplitude A (uA/cm2)",
            colorbar_title = "number of spikes", title = "Response to a single current pulse", size = (760, 460))
    scatter!([log10(I_dur)], [I_amp]; marker = :xcross, ms = 8, color = :white, label = "")
    annotate!(log10(1.0), 1.0, text("no spike", 10, :white))
    annotate!(log10(3.0), 12.0, text("one spike", 10, :white))
    annotate!(log10(30.0), 17.0, text("several spikes", 10, :black))
    annotate!(log10(15.0), -7.0, text("anode break: one spike", 10, :white))
end

# ╔═╡ 5557e5f6-a1da-4413-8a3d-715239e86aea
md"""
### Aside - The 2026 Nobel Prize: Optogenetics
"""

# ╔═╡ 3cfd5af2-ec2b-4645-a3a9-03a698d31693
md"""
On 5 October 2026 the Nobel Prize in Physiology or Medicine went to **Peter Hegemann**, **Georg Nagel** and **Karl Deisseroth** "for their discoveries concerning light-gated ion channels and optogenetics". Hegemann and Nagel found **channelrhodopsin** in a single-celled alga; Deisseroth put it into neurons as a light switch.

Optogenetics insert a gene into neurons so that it makes a light-sensitive membrane protein (opsin). Shining light on the neuron switch the protein on. There are two kinds of opsins:
1. Light-gated channels (e.g. ChR2 - in the original 2005 paper) → light opens a pore, ions flow through it down the driving force like Na/K channel
2. Light-driven pumps (e.g. NpHR) → light powers protein to move ions across membrane


To the Hodgkin–Huxley model an opsin is just one more conductance in the current balance, gated by light instead of voltage:

```math
C\,\frac{dV}{dt} = I_{\text{bias}} - I_{Na} - I_K - I_L - I_{op}, \qquad
I_{op} = \begin{cases} x\,\bar g\,O\,(V - E_{op}) & \text{light-gated channel} \\ x\,\bar I\,O & \text{light-driven pump} \end{cases}
```

The opsin cycles closed → open → desensitized → closed, and only the first step needs light:

```math
\dot C = G_r D - k_a\,\phi(t)\,C, \qquad \dot O = k_a\,\phi(t)\,C - G_d\,O, \qquad \dot D = G_d\,O - G_r D .
```

These have the same form as the gating equations for ``m``, ``h`` and ``n``, with the light intensity ``\phi(t)`` in place of the voltage. ``x`` is the expression level (how many opsins the cell makes).
"""

# ╔═╡ d942e80c-6e77-4e60-8c9e-170f7737b976
md"""
**What each symbol means**

| symbol | meaning | units |
|:---|:---|:---|
| $C$ | fraction of opsins **closed** and ready to respond to light (not the capacitance $C$ in the voltage equation) | between 0 and 1 |
| $O$ | fraction **open** (conducting or pumping) | between 0 and 1 |
| $D$ | fraction **desensitized**: closed and not yet able to respond | between 0 and 1 |
| $\dot C, \dot O, \dot D$ | rate of change with time, e.g. $\dot C = dC/dt$ | 1/ms |
| $\phi(t)$ | light intensity at time $t$: zero in the dark, positive when the light is on (unrelated to the temperature factor φ of Section 6) | e.g. mW/mm², or normalized |
| $k_a$ | activation constant: how efficiently light opens a closed opsin. The opening rate is $k_a\phi$, so brighter light opens opsins faster | 1/(ms × intensity unit) |
| $k_a\,\phi(t)\,C$ | flow from closed to open: rate × fraction available | 1/ms |
| $G_d$ | desensitization rate: how fast open opsins fall into $D$. The open state lasts roughly $1/G_d$ | 1/ms |
| $G_d\,O$ | flow from open to desensitized | 1/ms |
| $G_r$ | recovery rate: how fast desensitized opsins become ready again. Slow for ChR2, with full recovery taking seconds | 1/ms |
| $G_r\,D$ | flow from desensitized back to closed | 1/ms |

The three fractions always add up to one, $C + O + D = 1$: every flow out of one state is a flow into another.
"""

# ╔═╡ b25eddd9-73e4-41db-9d29-26c1e4d21c47
# g: maximal conductance (mS/cm²), or maximal pump current (µA/cm²) for NpHR. Rates in 1/ms.
opsins = (
    ChR2    = (E = 0.0,   g = 2.0,  ka = 0.5, Gd = 0.10, Gr = 0.02, pump = false, color = :dodgerblue),
    Chronos = (E = 0.0,   g = 2.0,  ka = 1.2, Gd = 0.28, Gr = 0.04, pump = false, color = :dodgerblue),
    GtACR   = (E = -70.0, g = 3.0,  ka = 0.8, Gd = 0.02, Gr = 0.05, pump = false, color = :dodgerblue),
    NpHR    = (E = NaN,   g = 30.0, ka = 0.4, Gd = 0.25, Gr = 0.10, pump = true,  color = :orange),
)

# ╔═╡ 934f2b1a-df02-4a9b-86a0-96b223dda2cc
begin
    I_op(V, O, op, x) = op.pump ? x * op.g * O : x * op.g * O * (V - op.E)

    # State u = (V, m, h, n, C, O, D). The HH part is your hh_rhs; the opsin current enters as injected current.
    function opto_rhs(u, p, t)
        V, m, h, n, C, O, D = u
        dV, dm, dh, dn = hh_rhs((V, m, h, n), _ -> p.Ib - I_op(V, O, p.op, p.x), t)
        ka = p.op.ka * p.light(t)
        return (dV, dm, dh, dn, p.op.Gr * D - ka * C, ka * C - p.op.Gd * O, p.op.Gd * O - p.op.Gr * D)
    end

    # Light on from 50 to 450 ms: pulses of width w at frequency f (w = Inf gives continuous light)
    pulse_train(f, w; I = 1.0, on = 50.0, off = 450.0) = t -> (on <= t < off && mod(t - on, 1000 / f) < w) ? I : 0.0

    run_opto(op; light, x = 1.0, Ib = 0.0, T = 500.0) =
        simulate(opto_rhs, (u_rest..., 1.0, 0.0, 0.0), (0.0, T); p = (; op, light, x, Ib))

    light_spikes(ts, us) = count(t -> 50 <= t < 460, spike_times(ts, first.(us)))
end

# ╔═╡ 77c8e90e-b089-41ef-9c85-f60740a86716
md"""
Opsin: $(@bind opsin_name Select([k => string(k) for k in keys(opsins)]; default = :ChR2))   light intensity: $(@bind light_I Slider(0.0:0.05:1.0; default = 0.6, show_value = true))   continuous light: $(@bind light_cont CheckBox(default = false))

Pulse frequency (Hz): $(@bind light_f Slider(1:150; default = 40, show_value = true))   pulse width (ms): $(@bind light_w Slider(0.5:0.5:20.0; default = 3.0, show_value = true))

Opsin expression (×): $(@bind opsin_x Slider(0.25:0.25:5.0; default = 1.0, show_value = true))   bias current (µA/cm²): $(@bind opto_bias Slider(0.0:0.5:20.0; default = 0.0, show_value = true))
"""

# ╔═╡ 96ac727c-a40f-4415-a2e3-d1a251e81b80
let op = opsins[opsin_name]
    light = pulse_train(light_f, light_cont ? Inf : light_w; I = light_I)
    ts, us = run_opto(op; light, x = opsin_x, Ib = opto_bias)
    V, h, O = getindex.(us, 1), getindex.(us, 3), getindex.(us, 6)
    Iop = [I_op(u[1], u[6], op, opsin_x) for u in us]
    n_sp = light_spikes(ts, us)
    ttl = light_cont ? @sprintf("%s, continuous light: %d spikes", opsin_name, n_sp) :
                       @sprintf("%s at %d Hz: %d spikes for %d light pulses", opsin_name, light_f, n_sp, ceil(Int, 0.4 * light_f))
    p1 = plot(ts, light.(ts); fillrange = 0, lw = 0, color = op.color, ylabel = "light", yticks = false, label = "", title = ttl)
    p2 = plot(ts, V; color = :black, ylabel = "V (mV)", ylims = (-90, 60), label = "")
    p3 = plot(ts, Iop; color = :orangered, ylabel = "I_op (uA/cm2)", label = "")
    hline!(p3, [0]; color = :gray, ls = :dot, label = "")
    p4 = plot(ts, [h O]; label = ["h (Na inactivation)" "O (opsin open)"], ylabel = "gating",
              ylims = (0, 1), xlabel = "time (ms)", legend = :right)
    plot(p1, p2, p3, p4; layout = grid(4, 1; heights = [0.08, 0.42, 0.25, 0.25]), size = (760, 720), link = :x)
end

# ╔═╡ b483a29a-d8c7-434d-9f2d-2dad68a5665b
md"""
**Things to try**

* **ChR2 at 40 Hz:** one spike per flash. This is how the Tsai lab drove gamma rhythms in mice.
* **ChR2 at 100 Hz:** pulses are missed. ChR2 closes slowly (about 10 ms) and desensitizes, so the photocurrent cannot reset between flashes; watch ``O`` pile up. Switch to **Chronos**, which closes three times faster, and every flash fires again.
* **ChR2, continuous light, intensity 1, expression 3:** one spike, then silence. ``h`` collapses and never recovers. This is the **depolarization block** from the bifurcation diagram, now caused by light instead of an electrode.
* **Bias 10, continuous light, GtACR vs NpHR:** both silence a firing neuron, differently. GtACR opens a chloride conductance that clamps ``V`` near −70 mV (shunting), so its current stays small. NpHR pumps a fixed current and has to fight the bias head-on.
"""

# ╔═╡ 30718f9a-8962-4999-ab1e-0a77cf3fcbb8
md"""
# 5 · The FitzHugh–Nagumo simplification

Four coupled variables are too many to picture. In 1961 Richard FitzHugh asked which parts of the Hodgkin–Huxley model really matter and found a two-variable caricature that keeps the essential geometry; a year later Jin-ichi Nagumo built it as an electronic circuit. The derivation takes three steps, each checked against the full model below.

**1. Sodium activation is instantaneous.** $\tau_m$ is about ten times smaller than $\tau_h$ and $\tau_n$, so $m$ tracks its steady state: replace $m$ by $m_\infty(V)$.

**2. $h$ and $n$ move in lockstep.** During a spike, sodium inactivation closes ($h$ falls) while potassium activation opens ($n$ rises), at nearly the same rate. Along the trajectory $h$ is almost a linear function of $n$ (Rinzel, 1985), $h \approx h_0 + h_1 n$, and a least-squares fit gives the two numbers.

**3. Two variables remain**, a fast voltage $V$ and a slow recovery variable $n$:

```math
C\,\frac{dV}{dt} = I - \bar g_{Na}\, m_\infty(V)^3\,(h_0 + h_1 n)\,(V - E_{Na}) - \bar g_K\, n^4\,(V - E_K) - g_L\,(V - E_L),
\qquad \frac{dn}{dt} = \alpha_n(V)(1-n) - \beta_n(V)\,n .
```

Below, the full model fires continuously at $I = 10$ µA/cm², and each step is tested against it. [Note: This is an actual approximation of the 4 variable ODEs to 2 variables.]
"""

# ╔═╡ 76cffe32-dd29-5c54-95e3-295e3359f5f9
rinzel = let
    ts, us = simulate(hh_rhs, u_rest, (0.0, 100.0); p = t -> 10.0)
    V, m, h, n = (getindex.(us, i) for i in 1:4)
    late = ts .> 20                                           # skip the first spike
    h₀, h₁ = [ones(count(late)) n[late]] \ h[late]            # least-squares line h ≈ h₀ + h₁ n
    (; ts, V, m, h, n, late, h₀, h₁)
end

# ╔═╡ dfd49aff-f165-5de6-9878-a5003af6af50
let r = rinzel, Iapp = 10.0
    h_of(n) = clamp(r.h₀ + r.h₁ * n, 0.0, 1.0)
    dV(V, n) = (Iapp - I_Na(V, m_inf(V), h_of(n)) - I_K(V, n) - I_L(V)) / C_m
    reduced(u, _, t) = (dV(u[1], u[2]), αₙ(u[1]) * (1 - u[2]) - βₙ(u[1]) * u[2])
    ts2, us2 = simulate(reduced, (V_rest, n_inf(V_rest)), (0.0, 100.0))
    late2 = ts2 .> 20
    # the voltage nullcline: for each V, the n at which dV/dt = 0 (dV is monotone in n)
    nV(V) = dV(V, 0.0) * dV(V, 1.0) < 0 ? bisect(n -> dV(V, n), 0.0, 1.0) : NaN
    Vg = range(-75, 45; length = 300)

    p1 = plot(r.ts, [r.m m_inf.(r.V)]; label = ["m(t)" "m_inf(V(t))"], ls = [:solid :dash], xlims = (20, 50),
              xlabel = "time (ms)", ylabel = "Na activation", title = "1. m follows m_inf(V)", legend = :topright)
    p2 = scatter(r.n[r.late], r.h[r.late]; ms = 1.5, alpha = 0.4, label = "full model", xlabel = "n", ylabel = "h",
                 title = @sprintf("2. h ≈ %.2f %+.2f n", r.h₀, r.h₁))
    plot!(p2, [0.3, 0.8], r.h₀ .+ r.h₁ .* [0.3, 0.8]; color = :crimson, label = "fit")
    p3 = plot(Vg, nV.(Vg); color = :steelblue, lw = 2.5, label = "dV/dt = 0", xlabel = "V (mV)", ylabel = "n",
              ylims = (0.25, 0.85), title = "3. Two variables keep the loop", legend = :bottomright)
    plot!(p3, Vg, n_inf.(Vg); color = :darkorange, lw = 2.5, label = "dn/dt = 0")
    plot!(p3, r.V[r.late], r.n[r.late]; color = :gray, alpha = 0.7, label = "full model (4 variables)")
    plot!(p3, first.(us2)[late2], last.(us2)[late2]; color = :black, ls = :dash, label = "reduced (2 variables)")
    plot(p1, p2, p3; layout = (1, 3), size = (1100, 360))
end

# ╔═╡ dc8cd131-f38d-5fd3-b8b7-4aa349603d25
md"""
### Keep the shapes, drop the details

Everything in the two-variable model is organised by its **nullclines**, the curves where one variable stops changing:

| nullcline | shape | what it means |
|:---|:---|:---|
| $dV/dt = 0$ | three branches | left: **rest** · middle: **threshold** · right: **excited** |
| $dn/dt = 0$ | monotone | slow **recovery** |

FitzHugh kept these two shapes and threw away the details: the three-branched curve becomes a **cubic**, the recovery curve a **straight line**. This gives the **FitzHugh–Nagumo model**, in the form used for the rest of the talk:

```math
\frac{dv}{dt} = f(v) - w + I, \qquad\qquad \frac{dw}{dt} = \varepsilon\,(v - \gamma w), \qquad\qquad f(v) = v\,(1 - v)\,(v - a).
```

| symbol | role | value |
|:---|:---|:---|
| $v$ | dimensionless voltage: rest at 0, excited near 1 | |
| $w$ | **recovery** (fatigue): $h$ closing and $n$ opening rolled into one | |
| $f(v)$ | the sodium runaway: below $a$ it pulls $v$ back to 0, above $a$ it pushes $v$ up to 1 | |
| $a$ | threshold | 0.25 |
| $\varepsilon$ | slowness of recovery, $\varepsilon \ll 1$ | 0.001 |
| $\gamma$ | how strongly $w$ decays back | 1 |
| $I$ | applied current | slider below |

Note: This is does not have an analytical derivation - it is only a caricature used to describe the geometrical characteristics of the 2-variable reduced model. 

**A spike is a four-stroke loop around the cubic:**

1. **Jump right** *(fast)*: $v$ leaps from the rest branch to the excited branch.
2. **Climb** *(slow)*: $v$ stays high while $w$ builds up.
3. **Fall off the upper knee** *(fast)*: $v$ drops back to the left branch.
4. **Slide down** *(slow)*: $w$ drains away and the state returns to rest.
"""

# ╔═╡ fc14f3f5-c6a2-5f02-984e-ee479a37ba61
begin
    const FHN = (a = 0.25, γ = 1.0, ε = 0.001, dx = 0.5, dt = 0.05)  # dimensionless; dx, dt are for the cable (Section 6)
    cubic(v, a = FHN.a)  = v * (1 - v) * (v - a)
    dcubic(v, a = FHN.a) = -3v^2 + 2(1 + a) * v - a                 # f′(v)
    fhn_rhs(u, I, t) = (cubic(u[1]) - u[2] + I, FHN.ε * (u[1] - FHN.γ * u[2]))
    fhn_rest(I) = bisect(v -> cubic(v) - v / FHN.γ + I, -1.0, 2.0)   # where the two nullclines cross
end

# ╔═╡ 818c087c-db6d-5321-8679-8abf0c546cb4
md"""
Constant current I: $(@bind I_fhn Slider(0.0:0.01:0.7; default = 0.0, show_value = true))   kick v away from rest by: $(@bind kick_fhn Slider(0.0:0.02:0.6; default = 0.3, show_value = true))
"""

# ╔═╡ 9770ec50-2a97-5ce9-a17a-9e5f7a6a23be
let
    v₀ = fhn_rest(I_fhn)
    ts, us = simulate(fhn_rhs, (v₀ + kick_fhn, v₀ / FHN.γ), (0.0, 3000.0); p = I_fhn, dt = 0.2)
    vg = range(-0.4, 1.2; length = 300)
    status = dcubic(v₀) < FHN.ε * FHN.γ ? "rest is stable" : "rest is unstable: the neuron must fire"
    p1 = plot(vg, cubic.(vg) .+ I_fhn; color = :steelblue, lw = 2.5, label = "dv/dt = 0 (cubic)", xlabel = "v",
              ylabel = "w", xlims = (-0.4, 1.2), ylims = (I_fhn - 0.06, I_fhn + 0.16), title = "Phase plane",
              legend = :topleft)
    plot!(p1, vg, vg ./ FHN.γ; color = :darkorange, lw = 2.5, label = "dw/dt = 0 (line)")
    plot!(p1, first.(us), last.(us); color = :crimson, label = "trajectory")
    scatter!(p1, [v₀ + kick_fhn], [v₀ / FHN.γ]; color = :crimson, label = "start")
    p2 = plot(ts, first.(us); color = :black, label = "", xlabel = "time", ylabel = "v", ylims = (-0.4, 1.2),
              title = @sprintf("I = %.2f: %s", I_fhn, status))
    plot(p1, p2; layout = (1, 2), size = (980, 380))
end

# ╔═╡ d21a406c-b94c-528d-8bbe-e79fbc5845ad
md"""
**Things to try** with the sliders above

| current $I$ | kick | what you see | why |
|:---|:---|:---|:---|
| 0 | 0.2 | the kick dies away | $v$ stays below the middle branch of the cubic (near $v = a$) and falls back to rest |
| 0 | 0.3 | one full spike, then rest | $v$ crosses the middle branch: the threshold |
| 0.2 | any | **fires forever** (relaxation oscillation) | the line crosses the *middle* branch, so rest is unstable |
| 0.7 | any | **no spikes**, $v$ stays high | rest sits on the right branch: depolarization block |
"""

# ╔═╡ eb65e831-0ec4-5d52-abd6-e4beb56b5d1a
md"""
### The bifurcation diagram of FitzHugh–Nagumo

**Resting state.** Both derivatives must vanish:

```math
\frac{dw}{dt} = 0 \;\Rightarrow\; w = \frac{v}{\gamma}, \qquad
\frac{dv}{dt} = 0 \;\Rightarrow\; f(v) - w + I = 0
\qquad\Longrightarrow\qquad f(v) - \frac{v}{\gamma} + I = 0 .
```

The left-hand side of the last equation has derivative $f'(v) - 1/\gamma < 0$, because $f'(v) \le 0.27 < 1/\gamma$. It is strictly decreasing, so for every current there is **exactly one** resting state $(\bar v, \bar v/\gamma)$, where the cubic and the line cross.

**Stability.** Linearizing about the resting state gives

```math
J = \begin{pmatrix} f'(\bar v) & -1 \\ \varepsilon & -\varepsilon\gamma \end{pmatrix}, \qquad
\det J = \varepsilon\,\big(1 - \gamma f'(\bar v)\big), \qquad \operatorname{tr} J = f'(\bar v) - \varepsilon\gamma .
```

Both eigenvalues of a 2×2 Jacobian have negative real parts exactly when $\det J > 0$ and $\operatorname{tr} J < 0$.

* The determinant is always positive (the same bound on $f'$), so no eigenvalue can pass through 0: the resting state never disappears or splits in two.
* Stability is therefore decided by the trace alone: rest is **stable** where $f'(\bar v) < \varepsilon\gamma$ (the left and right branches of the cubic) and **unstable** where $f'(\bar v) > \varepsilon\gamma$ (the middle branch).

**Hopf points.** Where $\operatorname{tr} J = 0$ the eigenvalues are $\pm i\sqrt{\det J}$, purely imaginary because the determinant is positive: a **Hopf bifurcation**. Solving the quadratic $f'(v_H) = \varepsilon\gamma$ and then the resting-state equation for the current:

```math
v_H = \frac{(1+a) \pm \sqrt{(1+a)^2 - 3\,(a + \varepsilon\gamma)}}{3}, \qquad I_H = \frac{v_H}{\gamma} - f(v_H) .
```

With $a = 0.25$, $\gamma = 1$ and $\varepsilon = 0.001$: $v_H \approx 0.117$ and $0.717$, so $I_H \approx 0.130$ and $0.622$. Both lie just inside the two knees of the cubic (where $f' = 0$), on the middle branch. As $I$ changes, the trace crosses zero with nonzero speed, which a genuine Hopf bifurcation requires; whether the new loop is born stable or unstable takes a further calculation, and the simulation below shows it is stable. In Section 4.1 this took ForwardDiff and bisection; here it is pencil and paper.
"""

# ╔═╡ 78e70996-4bfa-58e6-9c6d-4a254ce6b623
fhn_bif = let Is = 0.0:0.005:0.75
    vrest = fhn_rest.(Is)
    cyc = map(Is) do I                                      # long-run range of v, starting near rest
        ts, us = simulate(fhn_rhs, (fhn_rest(I) + 0.01, fhn_rest(I) / FHN.γ), (0.0, 6000.0); p = I, dt = 0.2)
        extrema(first.(us)[ts .> 4000])
    end
    (a, γ, ε) = (FHN.a, FHN.γ, FHN.ε)
    vH = [(1 + a) + s * sqrt((1 + a)^2 - 3 * (a + ε * γ)) for s in (-1, 1)] ./ 3   # roots of f′(v) = εγ
    (; Is, vrest, stable = dcubic.(vrest) .< ε * γ, vmin = first.(cyc), vmax = last.(cyc), IH = vH ./ γ .- cubic.(vH))
end

# ╔═╡ 6b210354-6cf5-5518-acb1-eafe8ad5f08c
let b = fhn_bif
    Vs = copy(b.vrest); Vs[.!b.stable] .= NaN
    Vu = copy(b.vrest); Vu[b.stable] .= NaN
    firing = b.vmax .- b.vmin .> 0.05
    plot(b.Is, Vs; color = :black, lw = 2.5, label = "rest: stable", xlabel = "constant current I", ylabel = "v",
         ylims = (-0.4, 1.2), legend = :topleft, size = (760, 400),
         title = @sprintf("Hopf points from the formula: I = %.3f and %.3f", b.IH[1], b.IH[2]))
    plot!(b.Is, Vu; color = :black, ls = :dash, label = "rest: unstable")
    scatter!(b.Is[firing], b.vmax[firing]; color = :crimson, ms = 3, label = "firing: top and bottom of each spike")
    scatter!(b.Is[firing], b.vmin[firing]; color = :crimson, ms = 3, label = "")
    vline!(b.IH; color = :orange, ls = :dot, lw = 2, label = "Hopf points")
    vline!([I_fhn]; color = :gray, ls = :dot, label = "slider")
end

# ╔═╡ a00506c4-5b86-5656-8f59-4b092b4d1790
md"""
**Same skeleton, simpler details.** As in the Hodgkin–Huxley diagram of Section 4.1, rest is stable at low current, loses stability at a Hopf point, the neuron fires in between, and rest returns at high current (depolarization block). One difference is worth knowing: there is **no bistable window**. In Hodgkin–Huxley a large firing loop exists before rest becomes unstable (a *subcritical* Hopf bifurcation). In FitzHugh–Nagumo the loop is born at the Hopf point itself and grows from zero to a full spike within a current range far too narrow to see on this grid (a *canard explosion*).

That is the trade: FitzHugh–Nagumo gives up quantitative detail for geometry we can reason about, and almost everything about it can be computed by hand. It is the model on which the theory of travelling nerve pulses, and of their stability, was first built.
"""

# ╔═╡ 99165e72-3720-41db-a142-6ab2793265d9
md"""
# 5 · The nerve-axon equations
"""

# ╔═╡ 26cc65ee-c2fd-4155-abe8-84c03ccc615b
md"""
## Step 1 · From a point to a cable

So far the voltage was the same everywhere in the cell. A real axon is a long thin tube, and current also flows **along** it through the salty axoplasm (specialized cytoplasm inside the axon), from patches at high voltage to their neighbours.

Cut the axon (radius $r$, axoplasm resistivity $R_i$) into thin slices. Ohm's law gives the current along the axis, $I_a = -\frac{\pi r^2}{R_i}\frac{\partial V}{\partial x}$, and charge conservation on each slice adds one term to the point-neuron equation:

```math
C\,\frac{\partial V}{\partial t} \;=\; \underbrace{\frac{r}{2R_i}\,\frac{\partial^2 V}{\partial x^2}}_{\text{current from the neighbours}} \;-\; I_{Na} - I_K - I_L,
\qquad \frac{\partial m}{\partial t} = \alpha_m(V)(1-m) - \beta_m(V)\,m \quad (\text{same for } h, n).
```

These are the **nerve-axon equations**. Two things to notice:

* Only $V$ spreads along the axon. The gates $m, h, n$ belong to the membrane and stay put.
* The new term is a **diffusion** term: voltage spreads like heat. On its own that only smears a signal out, so the channels have to regenerate it at every point.

Below is Hodgkin and Huxley's squid axon ($r = 238$ µm, $R_i = 35.4$ Ω·cm) at 18.5 °C, where every gate runs $3^{(18.5-6.3)/10} \approx 3.8$ times faster than at 6.3 °C. It is kicked at the left end.
"""

# ╔═╡ 7eab8533-078f-46bb-983e-051e845cd3e5
begin
    """
        hh_cable(; radius, active, kick, L, dx, T, temp, save_dt)

    The Hodgkin–Huxley axon as a chain of membrane patches of length `dx` (cm), coupled
    through the axoplasm. Each patch uses the point-neuron currents and gates from Section 3.
    `kick = :left` excites the left end; `kick = :both` excites both ends.
    """
    function hh_cable(; radius = 238e-4, Rᵢ = 35.4, active = true, kick = :left, L = 12.0,
                        dx = 0.025, T = 4.0, temp = 18.5, save_dt = 0.05)
        D  = radius / (2Rᵢ) * 1e3 / C_m           # how fast voltage spreads, cm²/ms
        dt = 0.4 * dx^2 / D                        # small enough for explicit Euler
        φ  = 3.0^((temp - 6.3) / 10)               # gates run 3× faster per 10 °C
        x  = 0:dx:L
        N  = length(x)
        V, m, h, n = (fill(Float64(u), N) for u in u_rest)
        V[x .< 0.3] .+= 40                         # kick the left end
        kick == :both && (V[x .> L - 0.3] .+= 40)  # ... and the right end
        Vxx = similar(V)
        ts = Float64[]
        Vs, ms, hs, ns = (Vector{Float64}[] for _ in 1:4)
        save_every = round(Int, save_dt / dt)
        for k in 0:round(Int, T / dt)
            if k % save_every == 0
                push!(ts, k * dt)
                push!(Vs, copy(V)); push!(ms, copy(m)); push!(hs, copy(h)); push!(ns, copy(n))
            end
            for i in 1:N                           # current from the neighbours (sealed ends)
                l = i == 1 ? V[2] : V[i-1]
                r = i == N ? V[N-1] : V[i+1]
                Vxx[i] = (l - 2V[i] + r) / dx^2
            end
            for i in 1:N                           # the point neuron, patch by patch
                v = V[i]
                Iion = active ? I_Na(v, m[i], h[i]) + I_K(v, n[i]) + I_L(v) : I_L(v)
                m[i] += dt * φ * (αₘ(v) * (1 - m[i]) - βₘ(v) * m[i])
                h[i] += dt * φ * (αₕ(v) * (1 - h[i]) - βₕ(v) * h[i])
                n[i] += dt * φ * (αₙ(v) * (1 - n[i]) - βₙ(v) * n[i])
                V[i] += dt * (D * Vxx[i] - Iion / C_m)
            end
        end
        return (; x, ts, Vs, ms, hs, ns)
    end

    # speed of the rightmost point above `level`: least-squares slope over a time window
    function front_speed(x, ts, profiles; level, window)
        sel = findall(t -> window[1] ≤ t ≤ window[2], ts)
        pos = [(i = findlast(>(level), profiles[k]); isnothing(i) ? NaN : x[i]) for k in sel]
        return ([one.(ts[sel]) ts[sel]] \ pos)[2]
    end
end

# ╔═╡ 13cb4b7f-9285-4e7c-b82f-dea8337a96a2
md"""
Axon radius (µm): $(@bind axon_radius Slider([59.5, 119.0, 238.0, 476.0]; default = 238.0, show_value = true))   ion channels on: $(@bind axon_active CheckBox(default = true))
"""

# ╔═╡ 64b1fc44-74df-4398-b56f-0db27d38b0a4
let r = hh_cable(; radius = axon_radius * 1e-4, active = axon_active)
    c = 10 * front_speed(r.x, r.ts, r.Vs; level = -20.0, window = (1.0, 3.5))   # cm/ms → m/s
    ttl = isnan(c) ? "Passive cable: the kick leaks away" :
          @sprintf("Speed %.1f m/s  (Huxley 1952 by hand: 18.8, measured: 21.2)", c)
    p1 = heatmap(r.x, r.ts, permutedims(reduce(hcat, r.Vs)); clims = (-80, 50),
                 xlabel = "position along the axon (cm)", ylabel = "time (ms)",
                 colorbar_title = "V (mV)", title = ttl)
    p2 = plot(; xlabel = "position along the axon (cm)", ylabel = "V (mV)", ylims = (-90, 50),
              title = "Snapshots: same shape, shifted", legend = :topright)
    for tk in (1.0, 2.0, 3.0)
        k = argmin(abs.(r.ts .- tk))
        plot!(p2, r.x, r.Vs[k]; label = "t = $(tk) ms")
    end
    plot(p1, p2; layout = (2, 1), size = (760, 640))
end

# ╔═╡ e9683caf-1b39-49f3-b874-6f6222147c36
md"""
**What to see**

* **Untick the ion channels.** The cable is passive and the kick leaks away within a few millimetres. Diffusion alone cannot carry a signal.
* **With channels on**, every patch pushed past threshold fires and pushes its neighbour past threshold: a fuse that relights itself. The pulse keeps a fixed shape and a constant speed, a straight stripe in the space–time plot.
* **The speed** comes out at about 18.7 m/s, matching Huxley's hand-calculated 18.8 m/s.
* **Double the radius** and the speed grows by $\sqrt2$, not 2. Rescaling the cable equation gives $c \propto \sqrt{r}$, which is why the squid needed a giant axon, and why vertebrates insulate their axons with myelin instead.
"""

# ╔═╡ 0058ab16-e90d-44ac-923f-40c5d5af35e7
md"""
### Watch the impulse travel

$(@bind axon_tick Clock(0.1))   $(@bind axon_kick Select([:left => "kick the left end", :both => "kick both ends"]))

Press **start**. Top: the axon, coloured by its voltage. Middle: the voltage along it. Bottom: the three gates along it.
"""

# ╔═╡ fdfed7c9-1c02-4309-b9e7-4f4b4194d228
axon_movie = hh_cable(; kick = axon_kick, T = 5.0)

# ╔═╡ 70417ff4-ff62-45dc-84e2-d6f84704036c
let r = axon_movie, k = mod1(axon_tick, length(axon_movie.ts))
    p1 = heatmap(r.x, 0:1, [r.Vs[k]'; r.Vs[k]']; clims = (-80, 50), c = :inferno,
                 yticks = false, colorbar = false, title = @sprintf("t = %.2f ms", r.ts[k]))
    p2 = plot(r.x, r.Vs[k]; color = :black, label = "", ylims = (-90, 50), ylabel = "V (mV)")
    hline!(p2, [V_rest]; ls = :dot, color = :gray, label = "rest")
    p3 = plot(r.x, [r.ms[k] r.hs[k] r.ns[k]];
              label = ["m (Na activation)" "h (Na inactivation)" "n (K activation)"],
              ylims = (0, 1), ylabel = "gate", xlabel = "position along the axon (cm)", legend = :right)
    plot(p1, p2, p3; layout = grid(3, 1; heights = [0.12, 0.48, 0.40]), size = (860, 560), link = :x)
end

# ╔═╡ d180a8f2-2969-478f-ab85-6608a77836f4
md"""
**What to notice**

* **The front is the moving switch.** Where the voltage starts to rise, $m$ jumps up and sodium rushes in, which pushes the next patch past threshold.
* **The wake is refractory.** Behind the peak, $h$ is low (sodium channels inactivated) and $n$ is high (potassium channels open) for several milliseconds. The membrane there cannot fire again, so the impulse can only move forward.
* **Kick both ends.** Two impulses run toward each other, meet and **annihilate**. Unlike water waves or solitons, they cannot pass through each other: each one runs into the other's refractory wake.
"""

# ╔═╡ f9739681-b8e2-4636-bef2-a5b0da02f354
md"""
## Step 2 · Ride along with the wave: the travelling-wave equation

**The idea.** In the simulation above, the pulse moves at a constant speed without changing shape. Imagine riding a bicycle beside it at exactly that speed $c$: from the bicycle, the pulse looks **frozen**. So measure position relative to the rider,

```math
\xi = x - ct ,
```

and look for a pulse whose voltage depends only on $\xi$: $V(x, t) = \Phi(\xi)$. Here $\xi = 0$ is a fixed point on the pulse, $\xi < 0$ is behind it and $\xi > 0$ is ahead of it.

**From a PDE to an ODE.** By the chain rule, both derivatives become derivatives in $\xi$ (written with a prime):

```math
\frac{\partial V}{\partial x} = V', \qquad \frac{\partial V}{\partial t} = -c\,V' .
```

The minus sign says that a fixed observer sees the profile slide past from front to back. Substituting into the nerve-axon equations, with $D = r/2R_iC$, leaves only one variable, $\xi$:

```math
\begin{aligned}
D\,V'' + c\,V' &= \frac{I_{\text{ion}}(V, m, h, n)}{C},\\[4pt]
-c\,m' &= \alpha_m(V)(1-m) - \beta_m(V)\,m \qquad (\text{same for } h, n).
\end{aligned}
```

Solving this ODE gives the **shape** of the pulse.

**The pulse is a homoclinic orbit.** To step this ODE forward you need the five numbers $(V, V', m, h, n)$, so it lives in five dimensions. Far ahead of the pulse the axon is at rest; far behind, it has recovered and is at rest again. The pulse is therefore a path that leaves the resting state ($\xi \to -\infty$), makes one big excursion (the spike) and returns to the *same* resting state ($\xi \to +\infty$): a **homoclinic orbit**.

**The speed is selected, not chosen.** For almost every value of $c$, a path that leaves rest misses it on the way back and runs off to $+\infty$ or $-\infty$. Only special values of $c$ bring it home. Physically, the front must charge the patch ahead of it to threshold before it can advance:

| if the pulse moved... | then... |
|:---|:---|
| faster than the selected $c$ | it reaches patches before they are charged to threshold, so it falls back |
| slower than the selected $c$ | current spreading ahead fires patches before it arrives, so it jumps forward |

So **the axon sets the speed**, through $r$, $R_i$, $C$, the channel densities and the temperature. A stronger stimulus launches the same pulse at the same speed, like dominoes that fall at the same rate however hard you push the first one.

**Shooting.** This is how Huxley computed the speed by hand in 1952:

1. Guess $c$.
2. Start just off the resting state and integrate the ODE forward in $\xi$.
3. See which way the solution fails: one direction means $c$ was too small, the other too large.
4. Bisect between a "too slow" and a "too fast" guess until they agree.

### The same idea for FitzHugh–Nagumo

Five dimensions cannot be drawn, so we apply the same substitution to the FitzHugh–Nagumo model of Section 5 with diffusion added, the **FitzHugh–Nagumo cable** (space and time rescaled so that $D = 1$):

```math
\begin{aligned}
\text{cable:}\quad & v_t = v_{xx} + f(v) - w, & w_t &= \varepsilon\,(v - \gamma w),\\[4pt]
\text{riding along:}\quad & v'' + c\,v' + f(v) - w = 0, & c\,w' + \varepsilon\,(v - \gamma w) &= 0 .
\end{aligned}
```

### The front: shooting for the speed

The front of the pulse, where $v$ jumps from 0 to 1, is steep and narrow. Recovery is slow ($\varepsilon = 0.001$), so across it $w$ hardly moves from 0. Setting $w = 0$ leaves one second-order ODE for the **front**, the switch from excitation behind ($v = 1$) to rest ahead ($v = 0$):

```math
v'' + c\,v' + f(v) = 0, \qquad v(-\infty) = 1, \quad v(+\infty) = 0 .
```

**A ball rolling on hills.** Read $\xi$ as time and $v$ as the position of a ball. The equation is then Newton's law, acceleration = force − friction:

```math
\underbrace{v''}_{\text{acceleration}} = \underbrace{-f(v)}_{\text{slope of the landscape}} \;\underbrace{-\;c\,v'}_{\text{friction}}, \qquad F(v) = \int_0^v f(s)\,ds .
```

The landscape $F(v)$ has two hilltops, at $v = 0$ and $v = 1$, with a valley at $v = a$ between them; the hilltop at $v = 1$ is **higher** when $a < \tfrac12$. The front is a ball released from the high hilltop that must come to rest **exactly** on top of the low one. Friction has to remove exactly the difference in height:

| friction $c$ | what the ball does | in the plot below |
|:---|:---|:---|
| too small | arrives with energy to spare and rolls over the low hilltop | the curve crosses $v = 0$: "too slow" |
| too large | runs out of energy, stops short and rolls back | the curve turns back before $v = 0$: "too fast" |
| just right | creeps up and stops on the top | the front |

The bigger the difference in height, the faster the front. At $a = \tfrac12$ the hilltops are equally high and the front does not move at all.

**An exact answer.** For this cubic the front can be found in closed form. Guess that its slope is $v' = -k\,v(1 - v)$, the shape of a smooth step. Substituting, every term becomes a polynomial in $v$, and setting each power of $v$ to zero fixes both unknowns:

```math
k = \frac{1}{\sqrt2}, \qquad c_0 = \sqrt2\left(\tfrac12 - a\right) \approx 0.354, \qquad v(\xi) = \frac{1}{1 + e^{\xi/\sqrt2}} .
```

**Try it.** Set a trial speed and watch the ball's path in the plane of position $v$ and velocity $v'$, starting from the high hilltop at $(1, 0)$. Below 0.354 it overshoots; above, it turns back. The dashed curve is the speed found by shooting, which matches the formula.

Speed to try: $(@bind c_try Slider(0.05:0.01:0.7; default = 0.2, show_value = true))
"""

# ╔═╡ 301cbfd7-94fa-5596-b9bb-c0a5ca0d4246
begin
    # Shoot the front v'' + c v' + f(v) = 0 from v = 1. Returns the orbit and its fate:
    # -1 = too slow (overshoots rest), +1 = too fast (turns back), 0 = still undecided at ξ = L
    function shoot_front(c; L = 60.0)
        μ = (-c + sqrt(c^2 + 4 * (1 - FHN.a))) / 2              # leave v = 1 along its unstable direction
        rhs(y, c, ξ) = SVector(y[2], -c * y[2] - cubic(y[1]))
        _, ys = simulate(rhs, SVector(1 - 1e-4, -1e-4 * μ), (0.0, L); p = c, dt = 0.01)
        k = findfirst(y -> y[1] < -0.1 || y[2] > 0, ys)
        fate = isnothing(k) ? 0 : (ys[k][1] < -0.1 ? -1 : +1)
        return ys[1:something(k, length(ys))], fate
    end
    c_front = bisect(c -> shoot_front(c)[2], 0.1, 0.6; iters = 30)
end

# ╔═╡ f40ecfb6-b437-51c8-9d85-04d75ec94ab7
let
    ys, fate = shoot_front(c_try)
    verdict = fate < 0 ? "too slow: overshoots rest" : fate > 0 ? "too fast: turns back" : "reaches rest"
    plt = plot(; xlabel = "v", ylabel = "v' = dv/dξ", xlims = (-0.15, 1.05), ylims = (-0.35, 0.05), legend = :bottomleft,
               title = @sprintf("Shooting gives c* = %.4f; the formula gives %.4f", c_front, √2 * (0.5 - FHN.a)))
    plot!(plt, first.(ys), last.(ys); color = :crimson, lw = 2.5, label = "c = $(c_try): $verdict")
    front, _ = shoot_front(c_front)
    plot!(plt, first.(front), last.(front); color = :black, ls = :dash, label = "c = c*: the front")
    scatter!(plt, [0, 1], [0, 0]; color = :black, label = "rest (v = 0) and excited (v = 1)")
end

# ╔═╡ e671347b-3dc8-4c70-b1cd-1d7eb541f31c
md"""
### The whole pulse

Now switch recovery back on and simulate the FitzHugh–Nagumo cable, kicked at its left end. The right panel plots the same snapshot in the $(v, w)$ plane: read along $x$, the pulse is a closed orbit around the cubic, the four-stroke loop of Section 5.

Recovery rate ε: $(@bind ε_axon Slider([0.0005, 0.001, 0.002, 0.003, 0.004]; default = 0.001, show_value = true))
"""

# ╔═╡ 8de3b968-2cf1-4323-8f05-82bc9aea7374
begin
    function fhn_step!(v, w, vxx, P)              # one explicit-Euler step of the cable, sealed ends
        (; a, γ, ε, dx, dt) = P
        N = length(v)
        for i in 1:N
            l = i == 1 ? v[2] : v[i-1]
            r = i == N ? v[N-1] : v[i+1]
            vxx[i] = (l - 2v[i] + r) / dx^2
        end
        @. vxx += cubic(v, a) - w                 # vxx now holds dv/dt
        @. w += dt * ε * (v - γ * w)
        @. v += dt * vxx
        return nothing
    end

    # The FitzHugh–Nagumo cable kicked at its left end; σ > 0 adds random current to every patch.
    function fhn_cable(P; σ = 0.0, seed = 1, L = 250.0, T = 600.0)
        x = 0:P.dx:L
        v = Float64.(x .< 5);  w = zero(v);  s = similar(v)
        rng = Random.Xoshiro(seed)
        ts, vs, ws = Float64[], Vector{Float64}[], Vector{Float64}[]
        for k in 0:round(Int, T / P.dt)
            k % round(Int, 2 / P.dt) == 0 && (push!(ts, k * P.dt); push!(vs, copy(v)); push!(ws, copy(w)))
            fhn_step!(v, w, s, P)
            σ > 0 && (v .+= σ * sqrt(P.dt) .* randn(rng, length(v)))
        end
        return (; x, ts, vs, ws)
    end
end

# ╔═╡ 942e2fd8-2ea2-47af-8f64-8b3e854332f6
let P = merge(FHN, (ε = ε_axon,)), r = fhn_cable(P)
    a = P.a
    c      = front_speed(r.x, r.ts, r.vs; level = 0.5, window = (150.0, 550.0))
    c₀     = √2 * (1/2 - a)                      # speed of a single front (ε → 0)
    w_star = cubic((2 - a) / 3, a)               # fatigue at the downstroke (ε → 0)
    v, w = r.vs[end], r.ws[end]
    ttl = isnan(c) ? @sprintf("ε = %.4f: recovery too fast, no pulse survives", P.ε) :
                     @sprintf("ε = %.4f: speed %.3f (theory as ε → 0: %.3f)", P.ε, c, c₀)
    p1 = plot(r.x, [v w]; label = ["voltage v" "recovery w"], xlabel = "position x",
              ylims = (-0.3, 1.1), title = ttl, legend = :topleft)
    vgrid = range(-0.35, 1.1; length = 300)
    p2 = plot(vgrid, cubic.(vgrid, a); ls = :dash, color = :gray, label = "w = f(v): where v can rest",
              xlabel = "v", ylabel = "w", ylims = (-0.05, 0.15), legend = :topleft,
              title = @sprintf("The pulse as an orbit: max w = %.3f (theory w* = %.3f)", maximum(w), w_star))
    plot!(p2, v, w; color = :crimson, label = "the pulse, read along x")
    hline!(p2, [w_star]; ls = :dot, color = :black, label = "")
    plot(p1, p2; layout = (1, 2), size = (980, 380))
end

# ╔═╡ 129b2c3e-21e4-4b2c-ae8f-6d8c5748043a
md"""
**Reading the loop.** Follow the red curve starting from the front of the pulse:

1. **Upstroke** (fast): at $w \approx 0$, $v$ jumps from rest to the excited branch. This is the front we just shot for, with speed $c_0 = \sqrt2\,(\tfrac12 - a)$.
2. **Plateau** (slow): $v$ stays high while the fatigue $w$ builds up.
3. **Downstroke** (fast): at $w^* = f\big(\tfrac{2-a}{3}\big)$, the level where the switch-off edge runs exactly as fast as the switch-on edge.
4. **Recovery** (slow): $v$ sits slightly below rest while $w$ drains away.

The jumps are horizontal because $\varepsilon \ll 1$: the voltage moves long before the fatigue can. Lower ε and the simulation approaches both predictions while the plateau stretches like $1/\varepsilon$. Raise it and propagation fails altogether.
"""

# ╔═╡ eb8c1bfd-4184-4c16-9b98-ca0354729df1
md"""
**The question for Section 7.** Both cable simulations started from a crude kick, not from a pulse, yet settled onto the same travelling shape. Real axons are noisy too. Why does the pulse survive disturbances, and can we prove it?
"""

# ╔═╡ f7c7b8db-cc25-4a60-a319-a640a7b787f0
md"""
## Aside: Stability

The cable in this section was perfect. A real axon is not:

* channels open and close **at random** (the single-channel flicker of Section 3);
* neighbouring axons and synapses inject stray currents;
* diameter, temperature and channel density vary along the way.

A signal that only works under perfect conditions would be useless. The impulse has to be **self-correcting**: after a disturbance it must return to the same shape and speed. The one thing a disturbance may change for good is **when** the impulse arrives, called timing jitter. In very thin axons, channel noise is large enough to cause measurable jitter, and can even block spikes or create spurious ones (Faisal & Laughlin, 2007).

**Experiment.** Run the FitzHugh–Nagumo cable of Section 6 again, but add random current to every patch at every time step.

Noise strength σ: $(@bind noise_σ Slider([0.0, 0.025, 0.05, 0.075, 0.1, 0.15]; default = 0.05, show_value = true))
"""

# ╔═╡ e6fa0489-5e7f-4100-85f8-e1ad3a96bae6
let clean = fhn_cable(FHN), noisy = fhn_cable(FHN; σ = noise_σ, seed = 2)
	i = findfirst(>=(150), clean.x)                           # an "electrode" at x = 150
	arrival(r) = (k = findfirst(v -> v[i] > 0.5, r.vs); isnothing(k) ? NaN : r.ts[k])
	ttl = @sprintf("σ = %.3f: arrives at x = 150 at t = %.0f (noise-free: t = %.0f)",
	               noise_σ, arrival(noisy), arrival(clean))
	p1 = heatmap(noisy.x, noisy.ts, permutedims(reduce(hcat, noisy.vs)); clims = (-0.3, 1),
	             xlabel = "position x", ylabel = "time t", colorbar_title = "v", title = ttl)
	vline!(p1, [150]; color = :white, ls = :dash, label = "electrode")
	p2 = plot(clean.x, [clean.vs[end] noisy.vs[end]]; label = ["noise-free" "noisy"],
	          xlabel = "position x", ylabel = "v", ylims = (-0.4, 1.2),
	          title = "Final snapshot: same shape, slightly shifted")
	plot(p1, p2; layout = (2, 1), size = (760, 640))
end

# ╔═╡ 345c8f73-78d4-478a-b8ff-daf46209e0c8
md"""
**What to see.** Up to σ ≈ 0.1 the pulse arrives with the same shape and speed. Only its arrival time shifts, by a few percent. At σ = 0.15 the noise is strong enough to fire spikes by itself, and the signal is lost in them. **

"""


# ╔═╡ 22fe56cd-8a89-4229-8683-28879d555c63
md"""
## A pulse that fails: remove the recovery

**Why this example.** Before testing the nerve pulse, it is worth seeing that stability is **not automatic**: a pulse can exist and still fall apart at the slightest touch. The cleanest way to see this is to delete the recovery variable $w$.

**The model.** Keep one excitable variable $u$ on a cable:

```math
u_t = \underbrace{u_{xx}}_{\text{spreading}} \;\underbrace{-\;u}_{\text{leak back to rest}} \;+\; \underbrace{u^3}_{\text{self-excitation}} .
```

This is the FitzHugh–Nagumo voltage equation with $w$ removed, with a simpler cubic chosen so that everything below can be computed exactly.

**The pulse.** A pulse that stands still ($c = 0$) satisfies $u_t = 0$, that is $\Phi'' - \Phi + \Phi^3 = 0$, and one solution is

```math
\Phi(\xi) = \sqrt2\,\operatorname{sech}\xi .
```

It is a perfect balance: at its centre, self-excitation exactly cancels the leak and the spreading.

**The test.** Disturb it, $u = \Phi + p$, and keep first-order terms. Since $(\Phi + p)^3 \approx \Phi^3 + 3\Phi^2 p$, the disturbance obeys $p_t = \mathcal L\,p$ with

```math
\mathcal L = \partial_\xi^2 - 1 + 3\Phi^2 = \partial_\xi^2 - 1 + 6\operatorname{sech}^2\xi .
```

This is the same recipe as above, simpler: no drift term (the pulse stands still) and no second row (there is no $w$).

**What to expect.** Make the pulse slightly **taller**. Self-excitation grows like $u^3$ but the leak only like $u$, so the excitation wins and the pulse keeps growing. Make it slightly **shorter**, and the leak wins and the pulse dies away. Nothing in the equation can stop either runaway. So there should be a disturbance, "taller or shorter", that grows: a **positive eigenvalue**. Indeed, a direct calculation gives

```math
\mathcal L\,\operatorname{sech}^2\xi = 3\,\operatorname{sech}^2\xi \qquad\Longrightarrow\qquad \lambda = +3 .
```

**Checking it numerically.** This $\mathcal L$ is symmetric, so its eigenvalues are real, and with finite differences it becomes a symmetric tridiagonal matrix that Julia diagonalizes directly. The next cell prints the four largest eigenvalues. Expect **3** (taller or shorter: unstable), **0** (sliding) and values near **−1** (the far field).
"""

# ╔═╡ 6a0a9d42-0c87-41a0-83c4-50e4faa8d1d1
let dx = 0.05, ξ = -15:dx:15
    Φ = √2 .* sech.(ξ)
    d = @. -2 / dx^2 - 1 + 3Φ^2
    ℒ = SymTridiagonal(d, fill(1 / dx^2, length(ξ) - 1))
    eigvals(ℒ)[end-3:end]                  # the four largest
end

# ╔═╡ f90bf465-2082-4569-924b-edfa7e54f3a9
let
    function peak_height(scale; dx = 0.05, dt = 1e-3, T = 3.0)
        u = scale .* √2 .* sech.(-15:dx:15);  uxx = similar(u);  peak = Float64[]
        for k in 1:round(Int, T / dt)
            for i in eachindex(u)
                l = i == 1 ? u[2] : u[i-1];  r = i == length(u) ? u[end-1] : u[i+1]
                uxx[i] = (l - 2u[i] + r) / dx^2
            end
            @. u += dt * (uxx - u + u^3)
            k % 50 == 0 && push!(peak, maximum(u))
            maximum(u) > 4 && break
        end
        return peak
    end
    plot(; xlabel = "time", ylabel = "peak height", ylims = (0, 4),
         title = "Without recovery, a pulse is a knife edge")
    for (s, lab) in ((1.01, "1% taller"), (1.0, "exact pulse"), (0.99, "1% shorter"))
        h = peak_height(s)
        plot!(0.05 .* eachindex(h), h; label = lab)
    end
    current()
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[compat]
ForwardDiff = "~1.4.6"
LaTeXStrings = "~1.4.1"
Plots = "~1.41.7"
PlutoUI = "~0.7.83"
StaticArrays = "~1.9.22"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.13.0"
manifest_format = "2.1"
project_hash = "2eadc3b77a9ec8e0c3596ef8440cd678c40755bc"

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
git-tree-sha1 = "1fa950ebc3e37eccd51c6a8fe1f92f7d86263522"
registries = "General"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.7+0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b0fd3f56fa442f81e0a47815c92245acfaaa4e34"
registries = "General"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.31.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "61761f58648aa7217445f24f841839b78c712232"
registries = "General"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.3"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
registries = "General"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Reexport"]
git-tree-sha1 = "291665b547f137df070e4dd83e432b5fee8cc4a0"
registries = "General"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.2"

[[deps.CommonSubexpressions]]
deps = ["MacroTools"]
git-tree-sha1 = "cda2cfaebb4be89c9084adaca7dd7333369715c5"
registries = "General"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.1"

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

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
registries = "General"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "79a2aca180a85c690c58a020d47b426954b590f8"
registries = "General"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.16.0"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
registries = "General"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

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
git-tree-sha1 = "2bfb1e047e2ad0a5ca94365340bde8005d637568"
registries = "General"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.8.4+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "95ecf07c2eea562b5adbd0696af6db62c0f52560"
registries = "General"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.5"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libva_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "7a58e45171b63ed4782f2d36fdee8713a469e6e0"
registries = "General"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "8.1.2+0"

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
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
registries = "General"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
registries = "General"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "3b0f72e2ffef1a139ac450725c9ecd01c0a3c050"
registries = "General"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "1.4.6"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "70329abc09b886fd2c5d94ad2d9527639c421e3e"
registries = "General"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.14.3+1"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
registries = "General"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

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
git-tree-sha1 = "090526e65de8f69648ac156daae153de8b56df62"
registries = "General"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.88.3+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "69ffb934a5c5b7e086a0b4fee3427db2556fba6e"
registries = "General"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.16+0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "9d9531a9cb63a9edc33836414e82a07e81710de2"
registries = "General"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "100.14004.0+0"

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
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
registries = "General"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

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
git-tree-sha1 = "633b5a34494e711f694ccbc88a6e00102f10238c"
registries = "General"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.9.0"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "037babc10853eeb8e585418922246cb97b8e5b74"
registries = "General"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.2.0+1"

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
git-tree-sha1 = "39bca05343661c347aae0bca57a5994a0bf4f08d"
registries = "General"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.2.0+0"

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
git-tree-sha1 = "cc3ad4faf30015a3e8094c9b5b7f19e85bdf2386"
registries = "General"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.42.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "aebd334d06cee9f24cea70bd19a39749daf73881"
registries = "General"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.3+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d620582b1f0cbe2c72dd1d5bd195a9ce73370ab1"
registries = "General"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.42.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.13.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "b85e2797b2409570e84c4de46238c0ed5f6476ae"
registries = "General"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "1.0.2"

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
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
registries = "General"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2026.8.13"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "dbd2e8cd2c1c27f0b584f6661b4309609c5a685e"
registries = "General"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.4"

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

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
registries = "General"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e2bb57a313a74b8104064b7efd01406c0a50d2ff"
registries = "General"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.6.1+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05f45c2e0de6259db764adbfd2f1dc6d3f8de13c"
registries = "General"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "2.0.1"

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
git-tree-sha1 = "663e8b48b789916221e0765393b289ca6c88f24e"
registries = "General"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "3.0.0"

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
git-tree-sha1 = "f20e945b895d2009c6c28d8bbf40a5cd846f7c2f"
registries = "General"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.5.0"

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
git-tree-sha1 = "e189d0623e7ce9c37389bac17e80aac3b0302e75"
registries = "General"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.83"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "edbeefc7a4889f528644251bdb5fc9ab5348bc2c"
registries = "General"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "5005266de4bfe50e53ff44a5cb5c540b6e47a254"
registries = "General"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.6.0"

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
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
registries = "General"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

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

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "429071b23f4c9a13fb6582f807cc2ef454082408"
registries = "General"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.9.0"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "39e70e0ab5d7f89833a62ab7c79df15d4fc417c1"
registries = "General"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.22"

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

    [deps.StaticArrays.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6ab403037779dae8c514bad259f32a447262455a"
registries = "General"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.4"

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
git-tree-sha1 = "b814d5005d6a529d740ffe06f8a86396f6501138"
registries = "General"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.9.2"

    [deps.StructUtils.extensions]
    StructUtilsLazilyInitializedFieldsExt = ["LazilyInitializedFields"]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
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
git-tree-sha1 = "908fec9df6c5de98548ead82a468c95ccf6cd263"
registries = "General"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.7.0"

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
git-tree-sha1 = "808090ede1d41644447dd5cbafced4731c56bd2f"
registries = "General"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.13+0"

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
git-tree-sha1 = "dcb316b3ce0941f195537dda56bea4517fcd3ff5"
registries = "General"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.4+0"

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
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
registries = "General"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

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
git-tree-sha1 = "801a858fc9fb90c11ffddee1801bb06a738bda9b"
registries = "General"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.7+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "2e59214e017a55cb87474a00fa76035c82ac0e17"
registries = "General"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.47.0+2"

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
git-tree-sha1 = "1210ba774d3427387d307bf1f416d699b7c39417"
registries = "General"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.15.1+0"

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
git-tree-sha1 = "e51150d5ab85cee6fc36726850f0e627ad2e4aba"
registries = "General"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.58+0"

[[deps.libva_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "libdrm_jll"]
git-tree-sha1 = "7dbf96baae3310fe2fa0df0ccbb3c6288d5816c9"
registries = "General"
uuid = "9a156e7d-b971-5f62-b2c9-67348b8fb97c"
version = "2.23.0+0"

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
# ╟─bdd640fb-0667-4ad1-9c80-317fa3b1799d
# ╠═a78d2311-d0d5-4c85-993c-e8b1c3a9aa46
# ╠═153c50a5-b9e8-4417-ae13-7a366defb1d9
# ╟─ae12ac31-971f-43fe-a7dc-d3c04ea2cbac
# ╟─7306d631-270d-48ac-90ba-18eb313eaab9
# ╟─25fb2e51-29ac-5024-93ac-ef35efa73d2e
# ╟─1f0f6e6c-4891-48ad-8e38-24a752e8652a
# ╟─edd58c7a-ddbc-4601-a7a0-84cd02339a4a
# ╟─f373bdd1-2283-4dba-9a2d-5c0d7059660a
# ╟─40d6444f-123c-456b-894c-df7367b3ffe9
# ╟─1ca8cb2b-c8d1-4fd7-a9fc-901d5d72ec2c
# ╠═63028ef0-8e30-40ef-9aa7-b36675bd3778
# ╟─7a7ce7c1-cba3-4b5b-8530-c192db9a1488
# ╟─6adfd41f-67f3-4a91-a442-8f260a4eb5d6
# ╟─d03205ad-a3cd-4b4d-9f16-ebd0e5ce87ba
# ╟─e48698a5-c0a4-48ff-a111-da203916630f
# ╠═bf43b662-f8d0-4bbb-9df5-09cd522dacd8
# ╠═e5a7bc65-ca3e-4724-aeee-2ae8389e9124
# ╟─558464f8-efff-47ab-afe8-d3c8897a6bb5
# ╟─227ffb97-a614-4a0c-9dbe-1fefaa004cdf
# ╟─53c0a169-ecdf-4f2c-853d-0d231f8ba6b5
# ╠═5ee9df75-549b-4889-9caa-a118b622ef23
# ╟─be62e866-dd8c-4af4-8fcb-45d5fac7a582
# ╠═caf05331-0709-4338-9999-f50b55c26833
# ╟─5e32515c-71db-447b-aced-7b4d10007441
# ╠═16655f36-147b-4f43-8848-7af0762b8ae6
# ╟─26fe5e45-f6ac-449f-bb28-1a02bec740dc
# ╟─735a293f-bcb0-571f-9796-b9e95a427f63
# ╠═57e5eb70-f702-4818-a320-8f028ac09788
# ╟─1a2a73ed-562b-4f79-8374-59eef50bea63
# ╟─4fceac85-93a3-4db1-a7c6-2b30cfdf3089
# ╟─954212bb-1797-453e-aa28-06c53cc2e376
# ╠═960ba1db-823b-4e81-9b15-3882ff5e4331
# ╠═b8703d9d-f7d0-4ee9-a591-f747cd0c5b89
# ╟─4d1b316c-15f7-4ba7-a8fe-94c29f79a79b
# ╟─2d13a99d-fc87-44dc-aab4-4ec2f33bb949
# ╠═3fa8ac97-8068-464b-8b1d-65c271457593
# ╠═9c6ca05c-0893-4d17-8ebd-d946e2f0d6ad
# ╠═64cdb86b-bd84-47b5-a547-9e3279697539
# ╟─7cbd5946-42c3-5cf1-a286-8ceb19c324a0
# ╠═5f603049-ab8e-41cd-86b1-1e9d3288d6bf
# ╟─e9db9796-88e7-4bb6-bfdb-5744f1fadbab
# ╟─93ec16ec-928e-4afd-b703-8be67f276324
# ╟─ebeebd1c-2f63-4a13-abb5-20e03eda4ea2
# ╟─f2cee6ea-dd33-4747-b896-ba9039a9b2b3
# ╟─5fcce651-5d89-4f4c-86d7-a1f7850745b1
# ╠═44addaf1-6ad6-4d2b-887d-f4849421c72a
# ╟─0d695c02-e30c-4914-b32f-1ef7203a842d
# ╠═560bf4e6-3345-4b3c-973c-a440264eeae8
# ╟─c143bd7c-d9a4-4320-81d0-13517acd5f42
# ╠═6d6498af-e4fc-4d3c-97fe-4da49c9a6cbf
# ╠═e13cd2dd-bb07-413e-ac11-c4b1c4045c7c
# ╠═76b71cc4-df12-4a44-8a8b-cb29dba6c7a4
# ╠═0966b687-cfd7-4e9b-a782-36caab91ca1c
# ╟─972a6e00-57ab-4fa0-b9b7-1614480b89c5
# ╟─9f34d948-39c5-445f-9996-b2e279485546
# ╠═14d2c851-d48f-477e-a8ea-ecb5b236cd3a
# ╟─af260316-0cec-4d25-88cd-3322c3f9ee94
# ╟─b62b7808-40ba-45b3-9b6f-63de07ffda4c
# ╠═907f3e1b-87c7-405e-bfc2-f92dba5e45f3
# ╟─67edde1e-34b9-59fe-bd2a-742bbf620ae9
# ╠═59110ad4-a782-51b6-b2c8-e2b76ee52539
# ╟─220eb743-7e86-4ba8-9a1d-f8af94d6d536
# ╠═5dbf02e1-e3e4-5778-88de-d6e2d9a88c6e
# ╠═4ccc3503-6402-5e7d-8521-49ce4f5d7a50
# ╟─5557e5f6-a1da-4413-8a3d-715239e86aea
# ╟─3cfd5af2-ec2b-4645-a3a9-03a698d31693
# ╟─d942e80c-6e77-4e60-8c9e-170f7737b976
# ╠═b25eddd9-73e4-41db-9d29-26c1e4d21c47
# ╠═934f2b1a-df02-4a9b-86a0-96b223dda2cc
# ╟─77c8e90e-b089-41ef-9c85-f60740a86716
# ╠═96ac727c-a40f-4415-a2e3-d1a251e81b80
# ╟─b483a29a-d8c7-434d-9f2d-2dad68a5665b
# ╟─30718f9a-8962-4999-ab1e-0a77cf3fcbb8
# ╠═76cffe32-dd29-5c54-95e3-295e3359f5f9
# ╠═dfd49aff-f165-5de6-9878-a5003af6af50
# ╟─dc8cd131-f38d-5fd3-b8b7-4aa349603d25
# ╠═fc14f3f5-c6a2-5f02-984e-ee479a37ba61
# ╠═818c087c-db6d-5321-8679-8abf0c546cb4
# ╠═9770ec50-2a97-5ce9-a17a-9e5f7a6a23be
# ╟─d21a406c-b94c-528d-8bbe-e79fbc5845ad
# ╟─eb65e831-0ec4-5d52-abd6-e4beb56b5d1a
# ╠═78e70996-4bfa-58e6-9c6d-4a254ce6b623
# ╠═6b210354-6cf5-5518-acb1-eafe8ad5f08c
# ╟─a00506c4-5b86-5656-8f59-4b092b4d1790
# ╟─99165e72-3720-41db-a142-6ab2793265d9
# ╟─26cc65ee-c2fd-4155-abe8-84c03ccc615b
# ╠═7eab8533-078f-46bb-983e-051e845cd3e5
# ╟─13cb4b7f-9285-4e7c-b82f-dea8337a96a2
# ╠═64b1fc44-74df-4398-b56f-0db27d38b0a4
# ╟─e9683caf-1b39-49f3-b874-6f6222147c36
# ╟─0058ab16-e90d-44ac-923f-40c5d5af35e7
# ╠═fdfed7c9-1c02-4309-b9e7-4f4b4194d228
# ╠═70417ff4-ff62-45dc-84e2-d6f84704036c
# ╟─d180a8f2-2969-478f-ab85-6608a77836f4
# ╟─f9739681-b8e2-4636-bef2-a5b0da02f354
# ╠═301cbfd7-94fa-5596-b9bb-c0a5ca0d4246
# ╠═f40ecfb6-b437-51c8-9d85-04d75ec94ab7
# ╟─e671347b-3dc8-4c70-b1cd-1d7eb541f31c
# ╠═8de3b968-2cf1-4323-8f05-82bc9aea7374
# ╠═942e2fd8-2ea2-47af-8f64-8b3e854332f6
# ╟─129b2c3e-21e4-4b2c-ae8f-6d8c5748043a
# ╟─eb8c1bfd-4184-4c16-9b98-ca0354729df1
# ╟─f7c7b8db-cc25-4a60-a319-a640a7b787f0
# ╠═e6fa0489-5e7f-4100-85f8-e1ad3a96bae6
# ╟─345c8f73-78d4-478a-b8ff-daf46209e0c8
# ╟─22fe56cd-8a89-4229-8683-28879d555c63
# ╠═6a0a9d42-0c87-41a0-83c4-50e4faa8d1d1
# ╠═f90bf465-2082-4569-924b-edfa7e54f3a9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
