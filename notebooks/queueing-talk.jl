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

# ╔═╡ eac0e680-c24f-5b56-ab9b-e71d55df97ce
using PlutoUI, Plots, Random, Statistics

# ╔═╡ 0fa45428-cdd4-5710-8796-cfb1772bb14c
begin
	default(size=(760, 380), linewidth=2.5, framestyle=:box, grid=:y, gridalpha=0.25,
		titlefontsize=12, guidefontsize=11, tickfontsize=10, legendfontsize=10,
		left_margin=4Plots.mm, bottom_margin=4Plots.mm)
	const BLUE = "#2563eb"
	const RED = "#dc2626"
	const GRAY = "#94a3b8"
	const GREEN = "#16a34a"
	const ORANGE = "#ea580c"
	const PURPLE = "#7c3aed"
end;

# ╔═╡ 7b7ac9c1-9958-514b-912e-501b8e24fecc
html"""<style>
pluto-output table td, pluto-output table th { font-family: inherit !important; }
</style>"""

# ╔═╡ 5ff52dbd-37c6-5bba-b62d-08ef81a1685b
md"""
# How many GPUs should I rent?
### A crash course in queueing theory

"""

# ╔═╡ 8d109aa3-cc57-5445-bc50-75bb08128299
md"""
## Imagine you're a tech bro 🦺

- You dropped out, bought the vest, and built **Scribbl**: snap a photo of your messy handwritten notes and AI hands back clean, typed notes.
- Every photo needs a **GPU** to read the handwriting. That takes about **15 seconds**, so one GPU can do **240 notes an hour**.
- Launch day. It goes viral. **220 notes an hour** come in.
- 220 < 240. One GPU is enough. Ship it. 🚀
"""

# ╔═╡ db2f45d3-454a-595d-8ef3-e8560e71d0d0
md"""
*→ Let's see how launch day goes.*
"""

# ╔═╡ 207fb2e0-99c7-5c80-bbdd-f51059c99709
md"""
## Launch day 📈

GPUs rented: $(@bind c_hook Slider(1:4, default=1, show_value=true)) $(html"&emsp;&emsp;") $(@bind replay_hook CounterButton("🎲 replay the day"))

Minutes since launch: $(@bind t_hook Slider(0:180, default=0, show_value=true))
"""

# ╔═╡ 372907b3-cb05-5e5b-abce-ebe3aa646e8f
md"""
- Each 🧍 = a note waiting. Red line = the minute you're looking at.
- The GPU is only **92% busy** (220 of 240 per hour), yet the line hits 20–30 notes.
"""

# ╔═╡ c5a7981c-dfcc-59f8-b47c-374770d190cc
md"""
*→ A GPU that keeps up on average still built a 30-note line. Why? And how many GPUs do we actually need? First, let's state the problem precisely.*
"""

# ╔═╡ efb6a82b-ca62-521e-8b9f-98658f804bd4
md"""
## The problem, formally

| symbol | meaning | launch day |
|:--|:--|:--|
| ``\lambda`` | **arrival rate**: notes per hour coming in | 220 |
| ``\mu`` | **service rate**: notes per hour **one** GPU can finish | 240 |
| ``c`` | number of GPUs, all pulling from **one shared line** | ? |
| ``W_q`` | average time a note **waits in line** before a GPU picks it up | ? |

**Goal:** the smallest ``c`` with ``W_q \le`` some target (say 10 seconds). Every GPU costs money; every second of waiting costs users.

This is the **M/M/c queue**: arrivals are **M**emoryless, processing times are **M**emoryless, ``c`` servers.
We will find out what "memoryless" means and why anyone would assume it.
"""

# ╔═╡ 35deae72-67fe-5620-8f00-adc13ab88917
md"""
*→ First question: if the GPU keeps up on average, where does the line even come from?*
"""

# ╔═╡ e8a2724f-a775-515b-8e4a-dc0f9cc5e541
md"""
## Why is there a line at all?

On average the GPU keeps up. Turn the two sources of randomness on and off, and watch the line.

Arrivals: $(@bind arr_mode Select(["evenly spaced", "random"], default="evenly spaced")) $(html"&emsp;&emsp;") 
Processing time: $(@bind svc_mode Select(["always 15 s", "random, 15 s on average"], default="always 15 s"))

How busy the GPU is (``\lambda/\mu``): $(@bind u_why Slider(0.5:0.01:0.99, default=0.92, show_value=true))
"""

# ╔═╡ 9c953c3f-07b8-54be-9f26-82e0b2e57ac3
md"""
- **Evenly spaced, always 15 s:** each note finishes before the next arrives. Nobody waits, even at 92% busy.
- **Random:** notes sometimes bunch up or run long. Idle time can't be saved for later, so a line forms.
- **Lines come from randomness, not from being over capacity.**
"""

# ╔═╡ 7987f2ba-3779-5ffc-befa-7f7c96f6fdb8
md"""
*→ So what does "random arrivals" mean, precisely?*
"""

# ╔═╡ 76783a62-4940-5ac5-aa1c-7edd0e8e4025
md"""
## Where "random" comes from: the Poisson distribution

Many users, each with a tiny, independent chance of uploading at any moment → the number of uploads per minute is **Poisson**:

```math
P(k) = \frac{e^{-\lambda}\lambda^{k}}{k!}
```

``P(k)`` = chance of exactly ``k`` uploads in a minute; ``\lambda`` = average per minute.

**Why:** split a minute into ``m`` slots, each with chance ``\lambda/m``. Finer slots → the count matches Poisson. Try it:

Arrivals per minute ``\lambda``: $(@bind λ_pois Slider(0.5:0.5:4, default=3, show_value=true)) $(html"&emsp;&emsp;")
Slots per minute ``m``: $(@bind n_slots Slider([4, 6, 10, 20, 60, 600, 3600], default=4, show_value=true)) $(html"&emsp;&emsp;")
$(@bind reroll_pois CounterButton("🎲"))
"""

# ╔═╡ a0a2b245-ea8a-572a-918d-804dd3c680c2
md"""
- **Top:** one minute in ``m`` slots (blue = an upload). **Bottom:** bars = slot model, dots = Poisson.
- Few slots: they disagree (4 slots can't give 5 uploads). More slots: bars land on the dots.
"""

# ╔═╡ 4aaedcea-bf5b-59c0-b5a2-78b478733e62
md"""
*→ Poisson tells us how many notes arrive per minute. Next: how long we wait *between* arrivals, and the property that makes the whole problem solvable.*
"""

# ╔═╡ fd8c6de1-f58d-5933-9b23-21126f2aa09f
md"""
## Exponential gaps and memorylessness

**Gap ``T`` between arrivals is exponential:** no arrival for ``t`` minutes = zero Poisson arrivals, so ``P(T > t) = e^{-\lambda t}``. Average gap ``1/\lambda``.

**Memoryless:** already waited ``s`` minutes? The chance of waiting ``t`` more is the same as from scratch. A gap longer than ``s+t`` is automatically longer than ``s``, so:

```math
P(T > s+t \mid T > s) = \frac{P(T > s+t)}{P(T > s)} = \frac{e^{-\lambda(s+t)}}{e^{-\lambda s}} = e^{-\lambda t} = P(T > t)
```

We assume **processing times** are exponential too (15 s average). A GPU has worked ``s`` seconds on a note: how much longer?

Compare with **Erlang-4**, a more realistic job: 4 random steps in a row, same 15 s average.

Processing time is: $(@bind dist_mem Select(["exponential", "realistic (Erlang-4)"], default="exponential")) $(html"&emsp;&emsp;")
Already worked ``s`` = $(@bind s_mem Slider(0:1:45, default=0, show_value=true)) seconds
"""

# ╔═╡ c2cee7d4-8ce4-5c9c-85f7-9cbda25fb840
let m = 15.0, s = s_mem
	if dist_mem == "exponential"
		r = 1 / m
		f = t -> r * exp(-r * t)
		S = t -> exp(-r * t)
	else
		k, r = 4, 4 / m
		f = t -> r^k * t^(k - 1) * exp(-r * t) / factorial(k - 1)
		S = t -> exp(-r * t) * sum((r * t)^j / factorial(j) for j in 0:k-1)
	end
	g = u -> f(s + u) / S(s)
	left = sum(S(s + u) for u in 0:0.05:400) * 0.05 / S(s)
	plot(f, 0, 60, color=GRAY, linewidth=5, label="total time for a brand-new note",
		xlabel="seconds", ylabel="probability density", ylims=(0, max(0.11, 1.1maximum(g, 0:0.5:60))),
		title="expected time left after $(s) s of work: $(round(left, digits=1)) s", size=(760, 330))
	plot!(g, 0, 60, color=RED, linestyle=:dash, linewidth=3, label="time left, given it already ran $(s) s")
end

# ╔═╡ c5266f89-4ad2-5bd0-a572-9e32d55b7eb4
md"""
- Exponential: the red curve never moves. Erlang-4: the longer it ran, the sooner it's done.
- Payoff: to predict the future we only need **``n`` = total notes in the system** (waiting + being processed).
"""

# ╔═╡ 01aa8d87-7f26-5287-abb5-62b06fdb1477
md"""
*→ Quick check before we use it.*
"""

# ╔═╡ 14ed8947-fb06-5a9e-9034-c51244e3abde
md"""
## ✋ Checkpoint 1: memorylessness

Uploads are Poisson, **3 per minute** (one every 20 s on average). Nobody has uploaded for **2 minutes**. Expected time until the next upload?

Vote **A, B, C or D**. $(html"&emsp;&emsp;") $(@bind cp1 CheckBox()) reveal the answer
"""

# ╔═╡ 2b542e50-0bd5-5191-99da-9e7c53ff3d71
if cp1
	md"""
	- **A: 20 seconds.** ``P(T > 2 + t \mid T > 2) = P(T > t)``: nothing is ever "overdue".
	- C is a good *real-world* instinct: maybe it's night and ``\lambda`` dropped. But then it's not Poisson with constant ``\lambda``. More at the end.
	"""
else
	md""
end

# ╔═╡ 207f41ef-3e21-55c3-9d7f-9a4ce1cc9e0c
cp1 ? md"""
*→ One more tool before we solve anything: a law that holds no matter how random things are.*
""" : md""

# ╔═╡ f8cb1979-1ee2-5281-8cbb-93f8be3bbc20
md"""
## Little's law: ``L = \lambda W``

- ``L`` = average number of notes in the system, ``\lambda`` = arrival rate, ``W`` = average time a note spends there.
- Holds for **any** randomness. Proof: count one area two ways.

Show the first $(@bind T_little Slider(2:1:20, default=6, show_value=true)) minutes of launch day (1 GPU)
"""

# ╔═╡ 6f7763da-fbcb-5bae-be69-f1c03dd8612b
md"""
- **Bar length** = one note's time in the system (minutes). All bars together = total **note-minutes**.
- ``N(t)`` = notes in the system at time ``t``; ``T`` = window length (minutes).
- A vertical slice at time ``t`` crosses ``N(t)`` bars, so **total bar length = area under ``N(t)``**:

```math
\underbrace{L \cdot T}_{\text{area, counted by time}} \;=\; \underbrace{(\lambda T)\cdot W}_{\text{area, counted by note}}
\quad\Longrightarrow\quad L = \lambda W
```

Also: ``\rho = \dfrac{\lambda}{c\mu}`` (**utilization**) = fraction of time each GPU works. If ``\rho \ge 1``, the line grows forever.
"""

# ╔═╡ 722b0fb3-0b47-5903-b8f4-f02935812fb1
md"""
*→ We now have both tools: memorylessness lets us track just ``n`` (the total number of notes in the system), and Little's law turns counts into times. Let's solve the one-GPU case.*
"""

# ╔═╡ 1ce703b6-c1a8-53fd-b1cb-da12be56e94e
md"""
## M/M/1: a random walk on one number

``n`` = total notes in the system (waiting + being processed). Arrivals push ``n`` up at rate ``\lambda``; the GPU pulls it down at rate ``\mu``.

Show the arrows as: $(@bind view_mm1 Select(["rates", "probabilities of the next move"]))
"""

# ╔═╡ 1d811f54-83bf-5e83-97ee-1a8c54e5f905
if view_mm1 == "rates"
	md"Each arrow is a **rate**: how often that move happens per minute. The balance argument uses rates."
else
	md"""
	- **Traditional Markov chain:** each arrow = chance it's the **next** move = its rate ÷ total rate out.
	- From ``n \ge 1``: up ``\frac{\lambda}{\lambda+\mu}``, down ``\frac{\mu}{\lambda+\mu}`` (launch day: 0.48 / 0.52). From 0: up, probability 1.
	"""
end

# ╔═╡ 959a3a7b-7987-5cb0-bfbd-ea95560b8a53
md"""
``p_n`` = fraction of time there are exactly ``n`` notes in the system (so ``p_0`` = fraction of time it's empty). ``\rho = \lambda/\mu``.

**Where ``p_n`` comes from.** In the long run the walk crosses each gap as often rightward as leftward:

```math
\underbrace{\lambda\,p_n}_{\text{rightward}} = \underbrace{\mu\,p_{n+1}}_{\text{leftward}}
\;\Rightarrow\; p_{n+1} = \rho\,p_n
\;\Rightarrow\; p_n = p_0\,\rho^{\,n},
\qquad \textstyle\sum_n p_n = 1 \;\Rightarrow\; p_0 = 1-\rho
```

How busy the GPU is, ``\rho``: $(@bind ρ_mm1 Slider(0.1:0.05:0.95, default=0.5, show_value=true))
"""

# ╔═╡ 412a6b56-ecfc-5334-bab4-c01ccdaca9ba
md"""
- Bars: ``p_n`` from the formula. Dots: a simulation. They match.
- As ``\rho`` grows the bars flatten: the GPU is rarely empty, and long lines become normal.
"""

# ╔═╡ 9f5305f5-d1c8-50d4-b22e-792175a42862
md"""
*→ Long lines become normal as ``\rho \to 1``. How fast does the **wait** grow?*
"""

# ╔═╡ b184ca0b-a580-5259-a958-02aa80b1a75a
md"""
## The hockey stick

- ``L`` = average notes in the system, ``W`` = average time in the system, ``W_q`` = average **wait in line**, ``1/\mu`` = processing time (15 s).
- ``\frac{\rho}{1-\rho}`` is the **average** of ``p_n`` from the last slide.

```math
\begin{aligned}
L &= \sum_n n\,p_n = \frac{\rho}{1-\rho} && \text{(the average of } p_n\text{)}\\
W &= \frac{L}{\lambda} = \frac{1}{\mu-\lambda} && \text{(Little)}\\
W_q &= W - \frac{1}{\mu} = \frac{1}{\mu}\cdot\frac{\rho}{1-\rho} && \text{(minus your own processing)}
\end{aligned}
```

How busy the GPU is, ``\rho``: $(@bind ρ_hockey Slider(0.05:0.01:0.99, default=0.5, show_value=true))
"""

# ╔═╡ 17710779-ef2e-5d73-9304-4ac69133b882
let ρ = ρ_hockey
	f = x -> x / (1 - x)
	plot(f, 0, 0.975, color=BLUE, label=false, xlims=(0, 1), ylims=(0, 40),
		xlabel="utilization ρ", ylabel="wait ÷ processing time",
		title="at $(round(Int, 100ρ))% busy a note waits $(round(f(ρ), digits=1))× its own processing time  (= $(round(15f(ρ), digits=0)) s)",
		size=(760, 330), xticks=0:0.1:1)
	scatter!([220 / 240], [f(220 / 240)], color=ORANGE, markersize=6, label="launch day (92%)")
	scatter!([ρ], [min(f(ρ), 40)], color=RED, markersize=9, label=false)
end

# ╔═╡ 510c27d9-3092-5be1-b6c0-68053deb5f04
md"""
*→ How sensitive is the wait to a little more traffic?*
"""

# ╔═╡ f9339ea6-21eb-5ff3-808a-e0694db85c71
md"""
## ✋ Checkpoint 2: the hockey stick

Traffic grows by the same **5 percentage points** in two situations. Which one makes the average wait grow more?

Vote **A, B, C or D**. $(html"&emsp;&emsp;") $(@bind cp2 CheckBox()) reveal the answer
"""

# ╔═╡ 082ebccc-f5dc-53d3-bf84-2864116bd91d
if cp2
	md"""
	- **B.** 50% → 55%: wait goes 1× → 1.2×. 90% → 95%: 9× → 19×.
	- The slope ``\dfrac{1}{(1-\rho)^2}`` is 4 at 50% busy, 100 at 90%. **The last 10% of utilization is the expensive 10%.**
	"""
else
	md""
end

# ╔═╡ f036ed59-e7b4-5edb-956c-e56844c43a3b
cp2 ? md"""
*→ On launch day we were on the steep part with one GPU. What happens with ``c`` GPUs?*
""" : md""

# ╔═╡ e5f6b838-1efc-584a-a614-bbf48ecc030e
md"""
## More GPUs: the M/M/c queue

With ``c`` GPUs the walk goes down at rate ``\min(n, c)\,\mu``, because only busy GPUs finish notes.

GPUs ``c``: $(@bind c_mmc Slider(1:6, default=2, show_value=true)) $(html"&emsp;&emsp;") Notes per hour ``\lambda``: $(@bind λ_mmc Slider(20:10:1400, default=220, show_value=true))

Show the arrows as: $(@bind view_mmc Select(["rates", "probabilities of the next move"]))
"""

# ╔═╡ a5f3be65-4476-5ce4-8a4a-9144586ae5ba
if view_mmc == "rates"
	md""
else
	md"""
	Each arrow = chance it's the **next** move. With ``k`` GPUs busy: up ``\frac{\lambda}{\lambda + k\mu}``, down ``\frac{k\mu}{\lambda + k\mu}``.
	"""
end

# ╔═╡ 43ec7b13-56f8-5325-832c-0bcd4b62adbc
md"""
**Where Erlang C comes from.** Same balance argument.

- ``a = \lambda/\mu`` = GPUs' worth of work arriving; ``\rho = a/c`` = fraction of time each GPU works.
- ``p_c`` = chance of exactly ``c`` notes; ``C(c,a)`` = chance a new note waits (all busy); ``L_q`` = average line.

```math
\lambda\,p_n = \min(n{+}1,\,c)\,\mu\,p_{n+1}
\;\Rightarrow\;
p_n = \begin{cases} p_0\,\dfrac{a^n}{n!} & n \le c \\[6pt] p_c\,\rho^{\,n-c} & n \ge c \;\;\text{(geometric again)}\end{cases}
```

```math
C(c,a) = P(\text{all } c \text{ busy}) = \sum_{n \ge c} p_n = \frac{p_c}{1-\rho},
\qquad
L_q = C(c,a)\,\frac{\rho}{1-\rho}
\;\xrightarrow{\;\text{Little}\;}\;
W_q = \frac{C(c,a)}{c\mu - \lambda}
```

- ``L_q`` = (chance all GPUs are busy) × (average line, given all busy).
- Once all are busy, the line is geometric again, like ``p_n`` in M/M/1, so its average is ``\frac{\rho}{1-\rho}``.
"""

# ╔═╡ 06fc262f-d17e-5d7a-81b3-98bd09dbb805
md"""
- One curve per number of GPUs (gray = fewer). Red dot = current setting.
- Each extra GPU adds another hockey stick, further right.
"""

# ╔═╡ 51f975d4-8967-5a70-b2b9-df1e89daf109
md"""
*→ Each extra GPU pushes the hockey stick further right. What does that mean for really big pools?*
"""

# ╔═╡ 0c47dc36-4e4e-5083-b859-270736b0643d
md"""
## Big pools can run hot

Every GPU **equally busy** (same ``\rho``); grow the pool from 1 to 30 GPUs. What happens to the wait?

- **Left:** average wait ÷ processing time.
- **Right:** at a random moment, % of GPUs busy, for 5 vs 50 GPUs (red = all busy, a new note waits).

How busy each GPU is: $(@bind u_pool Slider(0.5:0.01:0.98, default=0.8, show_value=true))
"""

# ╔═╡ 4a2c84e8-10fe-5754-bb57-a003258f518f
md"""
**Takeaway:** same utilization, bigger shared pool, far less waiting.
- A big pool can run its GPUs **hotter** (busier, cheaper per note) for the same wait.
- Twice the traffic does *not* need twice the GPUs: spare GPUs absorb random bursts, and bursts grow slower than traffic (1000 notes/hour: 6 GPUs; 2000: only 10).

**Why (right):** both pools are equally busy *on average*, but it fluctuates.
- Small pool: one extra note = 20% of capacity, so it often hits 100%.
- Big pool: bunched near its average, rarely hits 100%.
- On average ``a = \lambda/\mu`` GPUs are busy; fluctuations are about ``\sqrt a``, small *relative to the pool* when ``a`` is big.
- So spare capacity grows like ``\sqrt a``, not ``a``: **square-root staffing**, ``c \approx a + \beta\sqrt a`` (``\beta`` = safety factor, 1–3).
"""

# ╔═╡ 7c46256a-c93d-592d-a11b-e3eb3e7c9d65
md"""
*→ Quick check: does pooling help even when nothing else changes?*
"""

# ╔═╡ 55741125-9f43-578d-8ed8-fce176fb6b45
md"""
## ✋ Checkpoint 3: merging two pools

Two offices, each with **5 GPUs at 80% busy** and its own line. They merge into **one pool of 10 GPUs**: same traffic, still 80% busy. The average wait:

Vote **A, B, C or D**. $(html"&emsp;&emsp;") $(@bind cp3 CheckBox()) reveal the answer
"""

# ╔═╡ 67bfef08-1706-5c8b-b321-805738a100e7
cp3 ? md"""
*→ We now have everything we need to answer the investor.*
""" : md""

# ╔═╡ 4a725500-a83a-5b14-9f31-7f83b1b48d75
md"""
## Answering the investor 💸

Notes per hour: $(@bind λ_inv Slider(50:50:5000, default=1000, show_value=true)) $(html"&emsp;&emsp;") 
Seconds per note on one GPU: $(@bind sec_inv Slider(5:1:60, default=15, show_value=true))

Target average wait (seconds): $(@bind target_inv Slider(1:1:120, default=10, show_value=true)) $(html"&emsp;&emsp;") 
GPU price (dollars per hour): $(@bind price_inv Slider(0.5:0.25:5, default=2.0, show_value=true))

Budget (dollars per month): $(@bind budget_inv Slider(1000:500:60000, default=10000, show_value=true))
"""

# ╔═╡ f71e769f-ddc2-59ec-9381-910faeba7820
md"""
*→ Problem solved... until the product changes.*
"""

# ╔═╡ d63f94b6-074a-5745-8110-6f29bff71a9b
md"""
*→ Why is it so hard? Look at what we would have to keep track of.*
"""

# ╔═╡ 349f4eab-d29a-5097-8d52-25dfa63f8185
md"""
## Why it's hard: a random walk in ``k`` dimensions

- One GPU: the state was one number, ``n``.
- ``k`` branches: the state is **every branch's line length**: ``(n_1)``, ``(n_1, n_2)``, ``(n_1, n_2, n_3)``.
- The dot is the state; the line is its path.
- **The link to Scribbl v2:** for one GPU we got the wait from ``p_n``, the long-run chance of each state. Here we'd need the chance of every combination ``(n_1, n_2, n_3)``, the ``p_n`` of this walk, and that's what has no formula.

Branches ``k``: $(@bind k_walk Slider(1:3, default=1, show_value=true)) $(html"&emsp;&emsp;")
How busy each branch is: $(@bind ρ_walk Slider(0.5:0.05:0.9, default=0.8, show_value=true)) $(html"&emsp;&emsp;")
$(@bind reroll_walk CounterButton("🎲 new walk"))

Events so far (drag to watch it move): $(@bind step_walk Slider(0:5:600, default=150, show_value=true))
"""

# ╔═╡ d2a08a62-6acd-5a0f-99cb-0a615375053e
md"""
- New note: the dot moves **diagonally** (every line +1). Finished note: back along **one** axis.
- So the lines tend to rise and fall **together**. Remember that for later.

- **1 branch:** a walk on a line = M/M/1, solved: ``p_n = (1-\rho)\rho^n``.
- **2 branches:** a walk on a grid, solved in 1984 (Flatto & Hahn) with math that only works in 2-D.
- **3 branches:** a walk in 3-D, **no exact formula known**, but easy to simulate.
"""

# ╔═╡ 0022c931-6091-5e3c-ab6a-2ee6f0c6a9f6
md"""
*→ First question: what does the GPU stage pass on to the next stage?*
"""

# ╔═╡ 52591f69-e8ff-5873-9dbf-3c0a4775d84b
md"""
## ✋ Checkpoint 4: what leaves the GPU stage?

Notes arrive at **100 per hour** to a GPU stage that can handle up to **125 per hour**, so it keeps up (80% busy). In the long run, how many notes per hour **leave** it?

Vote **A, B, C or D**. $(html"&emsp;&emsp;") $(@bind cp4 CheckBox()) reveal the answer
"""

# ╔═╡ ffad597d-1e28-5a31-8413-1ac8f3505f0d
if cp4
	md"""
	GPUs: $(@bind c_burke Slider(1:4, default=1, show_value=true)) $(html"&emsp;&emsp;")
	How busy: $(@bind u_burke Slider(0.1:0.05:0.95, default=0.8, show_value=true)) $(html"&emsp;&emsp;")
	Processing time: $(@bind svc_burke Select(["random (exponential)", "always the same"]))
	"""
else
	md""
end

# ╔═╡ c739df48-4093-59c9-93a3-4e80d0a14232
if cp4
	md"""
	- **A: 100.** It keeps up, so what goes in comes out. (125/hour only while busy, 80% of the time: 0.8 × 125 = 100.)
	- **Surprise, Burke's theorem:** the gaps between departures are **exponential** too, like the arrivals (histogram).
	- *Why:* each step up is matched by a step down, so the walk looks the same played **backwards**, and backwards, departures are arrivals.
	- **So stages in a row are each their own M/M/c, and the times just add.** ("Always the same" breaks it: it needs memorylessness.)
	"""
else
	md""
end

# ╔═╡ 38882797-5fb6-5a13-8bb7-e12a8f64c8ec
cp4 ? md"""
*→ Stages **in a row** are fine. The fork is where things get hard.*
""" : md""

# ╔═╡ 404316e0-2955-53b4-bf65-cc10de17cb1b
md"""
## ✋ Checkpoint 5: waiting for the slowest

A note needs **all three** branches done. Each takes an exponential time, mean **1 minute**, independently. Average time until **all three** are done?

Vote **A, B, C or D**. $(html"&emsp;&emsp;") $(@bind cp5 CheckBox()) reveal the answer
"""

# ╔═╡ 56edf76d-5e33-5be9-aad7-80a6c86e8ca4
if cp5
	md"""Branches ``k``: $(@bind k_max Slider(1:10, default=3, show_value=true))"""
else
	md""
end

# ╔═╡ a06b4438-0ec9-51b3-9c60-33cf000b718f
if cp5
	md"""
	- **B: between 1 and 3.** More than 1 (you wait for the slowest); less than 3 (they run at the same time).
	- Exactly **1.83 min**: a race that memorylessness restarts after each finisher:

	```math
	E[\max] = \underbrace{\tfrac13}_{\text{first of 3 done}} + \underbrace{\tfrac12}_{\text{first of other 2}} + \underbrace{1}_{\text{last one}} = H_3 \approx 1.83
	```

	- In general ``H_k = 1 + \tfrac12 + \dots + \tfrac1k \approx \ln k + 0.58``: grows, but slowly.
	- *Refresher:* the first of ``k`` exponentials (rate 1) finishes at rate ``k``: ``P(\min > t) = e^{-kt}``.
	"""
else
	md""
end

# ╔═╡ bd7baa0d-0fb3-54d8-9084-3b1ef4571fc0
cp5 ? md"""
*→ That assumed the three branches are independent. Are they?*
""" : md""

# ╔═╡ 4cbe2db9-bb0b-5df7-a3de-e582626ad39e
md"""
## ✋ Checkpoint 6: the branches are not independent

- All branches see the **same** arrivals: a burst jams every branch at once.
- Each dot = one note: its time in branch 1 (x) vs branch 2 (y).

How busy each branch is: $(@bind u_corr Slider(0.05:0.05:0.95, default=0.8, show_value=true))
"""

# ╔═╡ 4cc8885f-b4fe-59e9-b57e-aef0625942a0
md"""
Branch times are **positively correlated**. If we compute the average slowest time **pretending they're independent** (the ``H_k`` trick), we get:

Vote **A, B, C or D**. $(html"&emsp;&emsp;") $(@bind cp6 CheckBox()) reveal the answer
"""

# ╔═╡ b2b064e4-e88c-54e3-9856-857262bd6703
if cp6
	md"""
	- **C: too high.** Compare the extremes:
	- Perfectly correlated: all finish together, so slowest = one branch, ``\frac{1}{\mu-\lambda}``.
	- Independent: ``\frac{H_k}{\mu-\lambda}``.
	- Positive correlation is in between, so **independence overestimates**. That gives us **two bounds for free**.
	"""
else
	md""
end

# ╔═╡ 2b0d4c11-0330-52f6-9b5e-370b9562bca5
cp6 ? md"""
*→ So "one branch alone" is too low and "independent branches" is too high. How good are those bounds, and can we do better?*
""" : md""

# ╔═╡ fdcd479d-108e-50d9-8adc-7964c4bd7f65
md"""
## So how do we model it?

Let's test the two bounds against a simulation of the real thing, plus a published approximation.

- ``k`` branches, one worker each, 1 time unit per note on average, same Poisson stream.
- ``\rho`` = how busy each branch is. ``H_k = 1 + \tfrac12 + \dots + \tfrac1k`` (Checkpoint 5).
- ``\frac{1}{\mu-\lambda}`` = average time in one branch (in M/M/1 it's exponential with rate ``\mu-\lambda``).

Branches ``k``: $(@bind k_models Slider(2:8, default=3, show_value=true))

Show: $(@bind shown_models MultiCheckBox(["ignore the join", "assume independent branches", "Nelson–Tantawi approximation", "simulation"]))
"""

# ╔═╡ c94149c5-35f3-5ff9-a2ab-2519948a984c
md"""
**How the simulation works (red dots):**
- 200,000 random notes (Poisson arrivals, exponential processing), each sent into all ``k`` branches.
- Each branch: one line, one worker, first come first served. A note is done when its **slowest** branch finishes.
- Average over all notes (skip the first 10% while lines fill up). No formula, just play it forward and measure.

| approach | formula | verdict |
|:--|:--|:--|
| ignore the join (perfect correlation) | ``\frac{1}{\mu-\lambda}`` | too optimistic: a **lower bound** |
| assume independent branches (Checkpoint 6) | ``\frac{H_k}{\mu-\lambda}`` | too pessimistic: an **upper bound** |
| Nelson–Tantawi | ``\Big[\tfrac{H_k}{H_2}+\tfrac{4}{11}\big(1-\tfrac{H_k}{H_2}\big)\rho\Big]\tfrac{12-\rho}{8}\cdot\tfrac{1}{\mu-\lambda}`` | exact-ish for ``k=2``, a fit to simulations beyond |
| simulate | no formula | always works, but gives no insight |

- The simulation always lands **between the two bounds**: two one-line formulas trap the answer.
- The gap widens with busier or more branches. Then use Nelson–Tantawi, or simulate.
"""

# ╔═╡ 5f48c35f-feb6-5be0-986c-3d340ea09f82
md"""
*→ Now let's put the GPU stage and the fork back together.*
"""

# ╔═╡ edb2c1d7-b83a-5e44-bd4a-4fc211e82762
md"""
## Putting it together: Scribbl v2, end to end

- By Burke (Checkpoint 4): total time = GPU stage + three branches. Just add them.
- GPU stage: M/M/c. Branches: our bounds. The question: **where does the time go?**

Notes per hour: $(@bind λ_e2e Slider(60:10:900, default=300, show_value=true)) $(html"&emsp;&emsp;")
GPUs: $(@bind c_e2e Slider(1:8, default=2, show_value=true)) $(html"&emsp;&emsp;")
GPU seconds per note: $(@bind gpu_e2e Slider(5:1:40, default=15, show_value=true))

Seconds per note in each branch. Summarize: $(@bind s1_e2e Slider(1:0.5:15, default=7, show_value=true)) $(html"&emsp;&emsp;")
Flashcards: $(@bind s2_e2e Slider(1:0.5:15, default=9, show_value=true)) $(html"&emsp;&emsp;")
Translate: $(@bind s3_e2e Slider(1:0.5:15, default=10, show_value=true))
"""

# ╔═╡ 51975da8-4e7a-5227-bdb1-4d711d3dff87
e2e = let λ = λ_e2e / 60, μg = 60 / gpu_e2e, c = c_e2e, μb = 60 ./ [s1_e2e, s2_e2e, s3_e2e]
	utils = vcat(λ / (c * μg), λ ./ μb)
	(; λ, μg, c, μb, utils, stable=maximum(utils) < 1)
end;

# ╔═╡ e6226ef6-3034-554c-b599-d1ee0e6e39f9
let names = ["GPU stage", "summarize", "flashcards", "translate"], u = e2e.utils, worst = argmax(e2e.utils)
	cells = join(["<td style='padding:4px 14px;border:1px solid #cbd5e1;$(i == worst ? "background:#fee2e2;font-weight:700" : "")'>$(names[i])<br>$(round(Int, 100u[i]))% busy</td>" for i in 1:4])
	warn = !e2e.stable ? "<p style='font-size:1.2em'>⚠️ <b>$(names[worst])</b> is over 100% busy: its line grows forever.</p>" :
		maximum(u) > 0.9 ? "<p style='color:#64748b'>Above 90% busy the simulation needs a very long run to settle, so it wobbles from run to run.</p>" : ""
	HTML("<table style='border-collapse:collapse'><tr>$cells</tr></table>$warn")
end

# ╔═╡ 3d03290b-56f5-5e27-96b2-d2c748024d2c
md"""
- Each bar: average time from upload to ready, in the order a note lives it: wait for a GPU, get read, then the three jobs (until all are done).
- Top two bars: our two bounds. Bottom bar: simulation. Red cell in the table: the **bottleneck** (busiest stage).

**A usable formula for the whole pipeline** (the "independent branches" bar, about 4% high at the defaults):

```math
\text{total} \;\approx\; \underbrace{W_q(\lambda, \mu_{\text{GPU}}, c) + \frac{1}{\mu_{\text{GPU}}}}_{\text{GPU stage: Erlang C, exact}} \;+\; \underbrace{E\big[\max(R_1, R_2, R_3)\big]}_{\text{3 jobs, as if independent}}, \qquad R_i \sim \text{Exp}(\mu_i - \lambda)
```

- ``R_i`` = time a note spends in job ``i`` (waiting + processing). It's exponential with rate ``\mu_i - \lambda`` (the job's spare capacity), so its average is ``\frac{1}{\mu_i - \lambda}``.

**How we got it:**
- Burke: the stages just add (Checkpoint 4).
- GPU stage: M/M/c, exact.
- Each job: an M/M/1, whose time is exponential with rate ``\mu_i - \lambda``.
- Pretend the jobs are independent: slightly too high (Checkpoint 6).

**What do we tell the investors about v2?**
- At 300 notes/hour, **2 GPUs are enough**: going to 4 only cuts the total from 1.6 to 1.5 min.
- Spend on **translation**, the bottleneck: 30% faster (10 s → 7 s) cuts the total to 1.1 min.
- "How many GPUs?" is the wrong question now. Ask: **which stage is the bottleneck?**
"""

# ╔═╡ 5446014a-af40-568b-979f-ee8722788d09
md"""
*→ This model still simplifies a lot.*
"""

# ╔═╡ 626ccda4-6993-57e2-a51a-3c51c052bf70
md"""
## What I left out (and what I'd try next)

- **Workers of different speeds.** Adding a slow laptop to a fast GPU can make the average *worse*. Fix: use it only when the line is long.
- **Bursty arrivals.** More uploads at 9 am than 3 am: ``\lambda`` changes during the day.
- **Non-exponential processing.** Pollaczek–Khinchine: ``W_q = \dfrac{1 + C_s^2}{2}\cdot W_q^{\text{M/M/1}}`` (``C_s`` = spread of processing time). Fixed times (``C_s = 0``) halve the wait.
- **Failures:** workers disconnect, notes time out and get retried.
"""

# ╔═╡ d075f692-473a-5d6c-ade6-0a8ed720b287
md"""
## Takeaways

1. Lines come from **randomness**, not from being over capacity.
2. The wait grows like ``\dfrac{\rho}{1-\rho}``: the last 10% of utilization is the expensive 10%.
3. A bigger shared pool can run hotter for the same wait.
4. Stages **in a row** add up (Burke). Parallel branches don't: you wait for the slowest, and they're correlated. So: bounds, approximations, simulation.

**Not just GPUs.** Anything with arrivals and servers works the same way:
- How many call-center agents, ER doctors, checkout lanes, or web servers? (M/M/c, Erlang C)
- One shared line beats separate lines: banks, airports, cloud pools.
- "Wait for all parts": a web page calling several services, a hospital waiting on multiple test results (fork-join).

**Question for you:** we assumed uploads are Poisson. When is that a bad assumption, and how would you check?
"""

# ╔═╡ 5daf03b1-b5e5-54b8-a080-4a3d4f0d4d89
md"""
# Thank you! Questions?
"""

# ╔═╡ 6f8f3b6c-2af9-5b0e-be3a-d56d0ef2888e
md"""
# Appendix: the code behind the slides
Everything is computed live. These are the only pieces.
"""

# ╔═╡ 6134dde2-fbaf-581e-9621-109c380552e9
"Arrival times of a Poisson process with rate λ on [0, T]: add up exponential gaps."
function poisson_arrivals(rng, λ, T)
	ts = Float64[]
	t = randexp(rng) / λ
	while t ≤ T
		push!(ts, t)
		t += randexp(rng) / λ
	end
	ts
end

# ╔═╡ fa722cc8-1703-5387-9524-9db7e75e3d92
"""
One shared line, `c` identical servers, first come first served.
`arrival` must be sorted. Each note goes to whichever server frees up first.
"""
function simulate_queue(arrival, service, c)
	n = length(arrival)
	free_at = zeros(c)
	start, depart = similar(arrival), similar(arrival)
	server = zeros(Int, n)
	for i in 1:n
		k = argmin(free_at)
		start[i] = max(arrival[i], free_at[k])
		depart[i] = start[i] + service[i]
		free_at[k] = depart[i]
		server[i] = k
	end
	(; arrival, start, depart, server, wait=start .- arrival, sojourn=depart .- arrival)
end

# ╔═╡ c8d8c9c2-2d49-55a3-a4ed-54f75f0b2776
sim_hook = let rng = Xoshiro(16 + replay_hook)
	λ, μ = 220 / 60, 240 / 60          # notes per minute
	arr = poisson_arrivals(rng, λ, 180.0)
	simulate_queue(arr, randexp(rng, length(arr)) ./ μ, c_hook)
end;

# ╔═╡ 8683bc88-0859-597a-94c4-fe1f40fe4f19
let s = sim_hook, t = t_hook
	idx = eachindex(s.arrival)
	waiting = count(i -> s.arrival[i] ≤ t < s.start[i], idx)
	busy = [any(i -> s.server[i] == k && s.start[i] ≤ t < s.depart[i], idx) for k in 1:c_hook]
	nxt = findfirst(>(t), s.arrival)
	wait_now = nxt === nothing ? 0.0 : s.wait[nxt]
	arrived = count(≤(t), s.arrival)
	angry = count(i -> s.arrival[i] ≤ t && min(s.start[i], t) - s.arrival[i] > 3, idx)
	people = waiting ≤ 50 ? "🧍"^waiting : "🧍"^50 * " <b>+$(waiting - 50)</b>"
	gpus = join(["<div style='display:inline-block;width:92px;margin:4px;padding:8px;border-radius:10px;text-align:center;background:$(b ? "#dbeafe" : "#f1f5f9");border:2px solid $(b ? BLUE : GRAY)'>GPU $k<br>$(b ? "📝 busy" : "💤 idle")</div>" for (k, b) in enumerate(busy)])
	stat(label, value) = "<div style='display:inline-block;margin-right:28px'><div style='font-size:0.85em;color:#64748b'>$label</div><div style='font-size:1.5em;font-weight:600'>$value</div></div>"
	HTML("""
	<div style='font-family:system-ui,sans-serif'>
	  <div>$gpus</div>
	  <div style='margin:8px 0 12px 0;min-height:32px;font-size:1.3em;line-height:1.1;word-break:break-all'>Line: $(waiting == 0 ? "<span style='color:#64748b;font-size:0.8em'>nobody waiting</span>" : people)</div>
	  $(stat("in line right now", waiting))
	  $(stat("upload now and you wait", "$(round(wait_now, digits=1)) min"))
	  $(stat("😡 users who waited over 3 min", "$angry of $arrived"))
	</div>""")
end

# ╔═╡ 9a20755d-9d74-5861-97ff-647a5e27164f
let T = T_little
	rng = Xoshiro(16)
	arr = poisson_arrivals(rng, 220 / 60, 40.0)
	s = simulate_queue(arr, randexp(rng, length(arr)) ./ 4.0, 1)
	idx = findall(<(T), s.arrival)
	n = length(idx)
	ends = min.(s.depart[idx], T)
	A = sum(ends .- s.arrival[idx])
	top = plot(xlims=(0, T), ylims=(0, n + 1), yflip=true, legend=false, ylabel="note #",
		title="one bar per note:  total length $(round(A, digits=1)) note-minutes")
	for (j, i) in enumerate(idx)
		plot!(top, [s.arrival[i], ends[j]], [j, j], color=BLUE, linewidth=4)
	end
	tg = range(0, T, length=1000)
	Ns = [count(j -> s.arrival[idx[j]] ≤ t < ends[j], 1:n) for t in tg]
	bot = plot(tg, Ns, seriestype=:steppost, fillrange=0, fillalpha=0.3, fillcolor=ORANGE,
		color=ORANGE, xlims=(0, T), legend=false, xlabel="minutes", ylabel="N(t)",
		title="N(t):  area $(round(A, digits=1)) note-minutes,  L = area/T = $(round(A / T, digits=2)) notes")
	plot(top, bot, layout=grid(2, 1, heights=[0.6, 0.4]), size=(760, 500))
end

# ╔═╡ f45695df-828e-5807-b66e-ebd808e1ebf4
if cp4
	let c = c_burke, λ = u_burke * c_burke, n = 60_000
		arr = cumsum(randexp(Xoshiro(41), n) ./ λ)
		svc = svc_burke == "always the same" ? ones(n) : randexp(Xoshiro(42), n)
		s = simulate_queue(arr, svc, c)
		gaps = diff(sort(s.depart))[n÷10:end]
		cv = std(gaps) / mean(gaps)
		gmax = 4 / λ
		histogram(gaps, normalize=:pdf, bins=range(0, gmax, length=40), color=BLUE, alpha=0.55,
			linewidth=0, label="gaps between notes leaving the GPU stage", xlims=(0, gmax),
			xlabel="gap", ylabel="density", size=(760, 280),
			title="spread of the gaps (std ÷ mean) = $(round(cv, digits=2))   (exponential = 1)")
		plot!(t -> λ * exp(-λ * t), 0, gmax, color=RED, label="exponential, same rate λ as the arrivals")
	end
else
	md""
end

# ╔═╡ 30c76f1e-19f3-5a74-a3a2-77aa8e610e8f
"Number of notes waiting in line, as a step function `(times, counts)`."
function line_length(s)
	w = s.wait .> 0
	ts = vcat(0.0, s.arrival[w], s.start[w])
	d = vcat(0, fill(1, count(w)), fill(-1, count(w)))
	p = sortperm(ts)
	ts[p], cumsum(d[p])
end

# ╔═╡ 3e4688b1-fc01-53ad-8fef-596e9220cf57
let (ts, q) = line_length(sim_hook)
	plot(ts, q, seriestype=:steppost, color=BLUE, label=false, xlims=(0, 180),
		ylims=(0, max(5, maximum(q) + 1)), xlabel="minutes since launch",
		ylabel="people in line", size=(760, 250))
	vline!([t_hook], color=RED, label=false, linewidth=2)
end

# ╔═╡ f8382513-b2c9-5fe3-b98f-6c6432df8871
let μ = 4.0, λ = u_why * μ, T = 180.0
	arr = arr_mode == "random" ? poisson_arrivals(Xoshiro(3), λ, T) : collect(1/λ:1/λ:T)
	svc = svc_mode == "always 15 s" ? fill(1 / μ, length(arr)) : randexp(Xoshiro(4), length(arr)) ./ μ
	s = simulate_queue(arr, svc, 1)
	ts, q = line_length(s)
	plot(ts, q, seriestype=:steppost, color=BLUE, label=false, xlims=(0, T),
		ylims=(0, max(5, maximum(q) + 1)), xlabel="minutes", ylabel="people in line",
		title="one GPU, $(round(Int, 100u_why))% busy:  average wait $(round(Int, 60mean(s.wait))) s,  longest line $(maximum(q))",
		size=(760, 300))
end

# ╔═╡ 7829298d-2335-5600-afaa-92be8adf787d
"Fraction of time with exactly n = 0..nmax notes in the system."
function time_in_state(s, nmax)
	ts = vcat(s.arrival, s.depart)
	d = vcat(fill(1, length(s.arrival)), fill(-1, length(s.depart)))
	p = sortperm(ts)
	frac = zeros(nmax + 1)
	N, tprev = 0, 0.0
	for j in p
		N ≤ nmax && (frac[N+1] += ts[j] - tprev)
		N += d[j]
		tprev = ts[j]
	end
	frac ./ tprev
end

# ╔═╡ a72c7db8-5ce7-5691-a960-dd4ef3aa54e9
let ρ = ρ_mm1, N = 15
	arr = cumsum(randexp(Xoshiro(21), 200_000) ./ ρ)
	s = simulate_queue(arr, randexp(Xoshiro(22), length(arr)), 1)
	frac = time_in_state(s, N)
	ns = 0:N
	bar(ns, (1 - ρ) .* ρ .^ ns, color=BLUE, alpha=0.55, linewidth=0, label="theory  (1−ρ)ρⁿ",
		xlabel="notes in the system, n", ylabel="fraction of time", xticks=ns, ylims=(0, 0.92),
		title="average notes in system:  theory ρ/(1−ρ) = $(round(ρ/(1-ρ), digits=2)),  simulation $(round(sum(s.sojourn)/s.depart[end], digits=2))",
		size=(760, 320))
	scatter!(ns, frac, color=RED, markersize=6, label="simulation (200,000 notes)")
end

# ╔═╡ 9ad53e52-4d84-52c8-9b96-13023b517eb5
"Binomial(n, p) probabilities for k = 0..K, by the ratio P(k+1)/P(k) (no huge factorials)."
function binom_pmf(n, p, K)
	p == 1 && return [k == n ? 1.0 : 0.0 for k in 0:K]
	out = zeros(K + 1)
	P = (1 - p)^n
	for k in 0:K
		out[k+1] = k ≤ n ? P : 0.0
		P *= (n - k) / (k + 1) * p / (1 - p)
	end
	out
end

# ╔═╡ d10587e6-fd4f-5242-aca3-f94f95f4467d
"Poisson(λ) probabilities for k = 0..K."
function pois_pmf(λ, K)
	out = zeros(K + 1)
	P = exp(-λ)
	for k in 0:K
		out[k+1] = P
		P *= λ / (k + 1)
	end
	out
end

# ╔═╡ f61decbf-3652-53df-a760-35b65783f278
let n = n_slots, λ = λ_pois, p = λ / n
	hits = rand(Xoshiro(11 + reroll_pois), n) .< p
	strip = plot(xlims=(0, 1), ylims=(0, 1), yticks=false, xticks=false, legend=false,
		grid=false, title="one simulated minute: $(count(hits)) arrivals")
	if n ≤ 60
		for i in 1:n
			plot!(strip, Shape([(i-1)/n, i/n, i/n, (i-1)/n] .+ [0.1, -0.1, -0.1, 0.1] ./ n, [0.15, 0.15, 0.85, 0.85]),
				fillcolor=hits[i] ? BLUE : :white, linecolor=GRAY, linewidth=1)
		end
	else
		vline!(strip, (findall(hits) .- 0.5) ./ n, color=BLUE, linewidth=2)
	end
	ks = 0:10
	bp, pp = binom_pmf(n, p, 10), pois_pmf(λ, 10)
	pm = bar(ks, bp, color=BLUE, alpha=0.55, linewidth=0, ylims=(0, 1.15max(maximum(bp), maximum(pp))),
		label="slot model: $n slots, chance $(round(p, digits=4)) each",
		xlabel="arrivals in one minute (k)", ylabel="probability", xticks=ks)
	scatter!(pm, ks, pp, color=RED, markersize=7, label="Poisson formula")
	plot(strip, pm, layout=grid(2, 1, heights=[0.22, 0.78]), size=(760, 430))
end

# ╔═╡ 57d1bf91-2cc8-523f-942a-42df50029224
"""
Erlang B by its recursion, which avoids computing aⁿ and n! separately (they overflow
for big pools). `a = λ/μ` is the offered load.
"""
function erlang_b(c::Int, a::Real)
	b = 1.0
	for n in 1:c
		b = a * b / (n + a * b)
	end
	b
end

# ╔═╡ 97ecf5b5-d7f3-5fb6-9c76-7fb0de2d3789
"Erlang C: probability that a new arrival finds all c servers busy and has to wait."
function erlang_c(c::Int, a::Real)
	b = erlang_b(c, a)
	b / (1 - (a / c) * (1 - b))
end

# ╔═╡ 21aa852f-26f5-5571-90ed-21ba01018d94
"Average wait in line for M/M/c (same time unit as 1/μ). Inf when over capacity."
mmc_wait(λ, μ, c) = λ < c * μ ? erlang_c(c, λ / μ) / (c * μ - λ) : Inf

# ╔═╡ f7e589e5-fba9-5bd4-aa58-5204b3865806
let μ = 240.0, λ = λ_mmc, c = c_mmc
	p = plot(xlabel="notes per hour λ", ylabel="average wait in line (seconds)", ylims=(0, 120),
		xlims=(0, 1450), size=(760, 300), legend=:topright)
	for k in 1:c
		λs = range(1, 0.995k * μ, length=300)
		plot!(p, λs, [3600mmc_wait(x, μ, k) for x in λs], color=k == c ? BLUE : GRAY,
			linewidth=k == c ? 3.5 : 1.5, label=k == c ? "$k GPU$(k == 1 ? "" : "s")" : false)
		k < c && annotate!(p, 0.97k * μ, 112, text("$k", 9, :gray))
	end
	w = 3600mmc_wait(λ, μ, c)
	scatter!(p, [λ], [min(w, 118)], color=RED, markersize=8, label=false)
	title!(p, isfinite(w) ? "$c GPU$(c == 1 ? "" : "s") at λ = $λ/h:  $(round(Int, 100λ / (c * μ)))% busy,  $(round(Int, 100erlang_c(c, λ / μ)))% of notes wait,  average wait $(round(w, digits=1)) s" :
		"$c GPU$(c == 1 ? "" : "s") at λ = $λ/h:  over capacity, the line grows forever")
end

# ╔═╡ a3c7bebe-e05c-55ee-ae15-875d404d31b1
if cp3
	let w5 = 15mmc_wait(4.0, 1.0, 5), w10 = 15mmc_wait(8.0, 1.0, 10)
		md"""
		- **C: shorter.** Same utilization, bigger pool: **$(round(w5, digits=1)) s → $(round(w10, digits=1)) s** (15 s per note).
		- Separate lines: one office can have a line while the other has an idle GPU. A shared line never wastes a free GPU.
		"""
	end
else
	md""
end

# ╔═╡ c057e2df-a0f7-5cb9-a713-453d64168022
if cp3
	let w = [15mmc_wait(4.0, 1.0, 5), 15mmc_wait(8.0, 1.0, 10)]
		bar(["2 offices × 5 GPUs\n(separate lines)", "1 pool × 10 GPUs\n(one shared line)"], w,
			color=[GRAY, BLUE], linewidth=0, label=false, ylabel="average wait (seconds)",
			title="same traffic, same 80% busy", size=(560, 280), ylims=(0, 1.2maximum(w)))
	end
else
	md""
end

# ╔═╡ 7d97f7ae-56b7-53fb-ada4-22bfdb717db7
let λ = λ_inv, μ = 3600 / sec_inv, load = λ_inv / (3600 / sec_inv)
	cost(c) = c * price_inv * 24 * 30
	wait(c) = 3600mmc_wait(λ, μ, c)                       # seconds; Inf if c can't keep up
	cmax = floor(Int, budget_inv / (price_inv * 24 * 30))  # most GPUs the budget pays for
	need = floor(Int, load) + 1                             # fewest GPUs that meet the target
	while wait(need) > target_inv
		need += 1
	end
	ok = need ≤ cmax
	rec = ok ? need : cmax                                  # what we can actually rent
	lo, hi = max(1, min(need, cmax) - 2), ok ? need + 2 : need
	row(c) = let w = wait(c), over = c > cmax
		style = over ? "color:#94a3b8" : c == rec ? (ok ? "background:#dcfce7;font-weight:600" : "background:#ffedd5;font-weight:600") : ""
		pw = c > load ? round(Int, 100erlang_c(c, load)) : 100
		"<tr style='$style'><td>$c</td><td>$(c > load ? string(round(Int, 100load / c), "%") : "over 100%")</td><td>$pw%</td><td>$(isfinite(w) ? string(round(w, digits=1), " s") : "∞")</td><td>\$$(round(Int, cost(c)))$(over ? " (over budget)" : "")</td></tr>"
	end
	verdict = if rec < 1
		"⚠️ The budget doesn't cover even <b>one</b> GPU."
	elseif ok
		"✅ Rent <b>$rec GPUs</b> for \$$(round(Int, cost(rec))) a month: average wait $(round(wait(rec), digits=1)) s, within the $(target_inv) s target."
	elseif rec ≤ load
		"⚠️ The budget pays for only <b>$rec GPU$(rec == 1 ? "" : "s")</b>, which can't keep up with the traffic: <b>the line grows forever</b>. Meeting the target needs $need GPUs (\$$(round(Int, cost(need))) a month)."
	else
		"⚠️ The budget pays for <b>$rec GPUs</b>: average wait $(round(wait(rec), digits=1)) s, which misses the $(target_inv) s target. Meeting it needs $need GPUs (\$$(round(Int, cost(need))) a month)."
	end
	check = if rec ≥ 1 && rec > load
		n = 1_000_000
		arr = cumsum(randexp(Xoshiro(31), n) ./ λ)
		simw = 3600mean(simulate_queue(arr, randexp(Xoshiro(32), n) ./ μ, rec).wait[n÷10:end])
		"<p>A simulation of 1,000,000 notes with $rec GPUs measures an average wait of <b>$(round(simw, digits=1)) s</b> (formula: $(round(wait(rec), digits=1)) s).</p>"
	else
		""
	end
	HTML("""
	<table style='font-size:1.05em;min-width:560px'>
	<tr><th>GPUs</th><th>busy</th><th>notes that wait</th><th>average wait</th><th>cost / month</th></tr>
	$(join(row.(lo:hi)))
	</table>
	<p style='font-size:1.15em'>$verdict</p>
	$check
	""")
end

# ╔═╡ 3bc328b2-c9eb-5cb3-bc96-7c052830f679
harmonic(k) = sum(1 / i for i in 1:k)

# ╔═╡ 30f229f6-402b-5c03-b3b3-b1250e3cbcbd
if cp5
	let k = k_max, n = 40_000, rng = Xoshiro(51)
		draws = randexp(rng, n, k)
		single = draws[:, 1]
		mx = vec(maximum(draws, dims=2))
		histogram(single, normalize=:pdf, bins=range(0, 8, length=50), color=GRAY, alpha=0.5,
			linewidth=0, label="one branch (mean 1)", xlims=(0, 8), xlabel="minutes",
			ylabel="density", size=(760, 280),
			title="slowest of $k: simulated mean $(round(mean(mx), digits=2)) min    formula 1 + 1/2 + … + 1/$k = $(round(harmonic(k), digits=2))")
		histogram!(mx, normalize=:pdf, bins=range(0, 8, length=50), color=RED, alpha=0.5,
			linewidth=0, label="slowest of $k branches")
		vline!([1, harmonic(k)], color=[GRAY RED], linestyle=:dash, label=false)
	end
else
	md""
end

# ╔═╡ 7281444f-5545-52ac-abf5-5ce74a6813a6
"Nelson & Tantawi (1988): approximate mean response time of a k-way fork-join of M/M/1 branches."
function nelson_tantawi(k, λ, μ)
	ρ = λ / μ
	r = harmonic(k) / harmonic(2)
	(r + 4 / 11 * (1 - r) * ρ) * (12 - ρ) / 8 / (μ - λ)
end

# ╔═╡ cd4ad572-f656-5ee0-b5f4-c6303a293d50
"E[max] of independent exponentials with rates `r`, by inclusion–exclusion over subsets."
function indep_max_mean(r)
	k = length(r)
	sum((-1)^(count_ones(m) + 1) / sum(r[i] for i in 1:k if (m >> (i - 1)) & 1 == 1) for m in 1:(2^k-1))
end

# ╔═╡ 616f6820-ba53-5cda-89ea-62578a02e6ef
"k branches (one server each, rates μs) all fed the same Poisson(λ) stream; a job is done when all are."
function fork_join(rng, λ, μs, n)
	arr = cumsum(randexp(rng, n) ./ λ)
	branch = [simulate_queue(arr, randexp(rng, n) ./ μ, 1).sojourn for μ in μs]
	(; arrival=arr, branch, R=reduce((a, b) -> max.(a, b), branch))
end

# ╔═╡ c13b4287-d177-5336-a101-4800a8aec07b
let λ = u_corr, n = 40_000
	fj = fork_join(Xoshiro(61), λ, [1.0, 1.0], n)
	a, b = fj.branch[1][n÷10:end], fj.branch[2][n÷10:end]
	pick = 1:10:length(a)
	lim = quantile(vcat(a, b), 0.995)
	scatter(a[pick], b[pick], markersize=2.5, markerstrokewidth=0, color=BLUE, alpha=0.5,
		label=false, xlims=(0, lim), ylims=(0, lim), aspect_ratio=:equal,
		xlabel="time in branch 1", ylabel="time in branch 2", size=(480, 320),
		title="correlation between the branches = $(round(cor(a, b), digits=2))")
end

# ╔═╡ 348babc2-8d6f-5b8a-a47a-7a2ed5c9223e
sims_models = let k = k_models, ρs = 0.1:0.1:0.9
	[mean(fork_join(Xoshiro(70 + i), ρ, ones(k), 200_000).R[20_001:end]) for (i, ρ) in enumerate(ρs)]
end;

# ╔═╡ dc8fad03-1597-59a3-9d2a-f09ed586476c
let k = k_models, ρs = 0.01:0.01:0.92
	p = plot(xlabel="utilization ρ of each branch", ylabel="average time until all $k are done",
		xlims=(0, 0.95), ylims=(0, harmonic(k) / (1 - 0.92)), size=(760, 330), legend=:topleft)
	"ignore the join" in shown_models &&
		plot!(p, ρs, 1 ./ (1 .- ρs), color=GRAY, label="ignore the join: 1/(μ−λ)")
	"assume independent branches" in shown_models &&
		plot!(p, ρs, harmonic(k) ./ (1 .- ρs), color=ORANGE, label="independent: H_k/(μ−λ)")
	"Nelson–Tantawi approximation" in shown_models &&
		plot!(p, ρs, [nelson_tantawi(k, ρ, 1.0) for ρ in ρs], color=PURPLE, linestyle=:dash,
			label="Nelson–Tantawi (1988)")
	"simulation" in shown_models &&
		scatter!(p, 0.1:0.1:0.9, sims_models, color=RED, markersize=7, label="simulation")
	p
end

# ╔═╡ 413f9ff8-8f80-5f17-bbc9-8ae6e7bf1b16
"GPU stage (c servers) followed by a fork into one-server branches with rates μb."
function pipeline(rng, λ, μg, c, μb, n)
	arr = cumsum(randexp(rng, n) ./ λ)
	g = simulate_queue(arr, randexp(rng, n) ./ μg, c)
	order = sortperm(g.depart)              # branches see notes in the order they leave the GPUs
	fork_t = g.depart[order]
	done = reduce((a, b) -> max.(a, b),
		[simulate_queue(fork_t, randexp(rng, n) ./ μ, 1).depart for μ in μb])
	(; gpu_wait=g.wait[order], gpu_work=(g.depart.-g.start)[order], branches=done .- fork_t)
end

# ╔═╡ f2403469-956a-5052-917c-088da67e2b48
if e2e.stable
	let (; λ, μg, c, μb) = e2e
		wq = mmc_wait(λ, μg, c)
		s = pipeline(Xoshiro(81), λ, μg, c, μb, 400_000)
		keep = 40_001:400_000
		rows = [("ignore the join", [wq, 1 / μg, maximum(1 ./ (μb .- λ))]),
			("independent branches", [wq, 1 / μg, indep_max_mean(μb .- λ)]),
			("simulation", [mean(s.gpu_wait[keep]), mean(s.gpu_work[keep]), mean(s.branches[keep])])]
		cols = [ORANGE, BLUE, GREEN]
		labels = ["1. wait for GPU", "2. GPU reads it", "3. three jobs"]
		p = plot(yticks=(1:3, first.(rows)), xlabel="minutes from upload to ready", legend=:outertop,
			legendcolumns=3, size=(760, 330), bottom_margin=6Plots.mm, ylims=(0.4, 3.6), grid=:x, yflip=true)
		for (r, (_, segs)) in enumerate(rows)
			x0 = 0.0
			for (j, d) in enumerate(segs)
				plot!(p, Shape([x0, x0 + d, x0 + d, x0], [r - 0.32, r - 0.32, r + 0.32, r + 0.32]),
					color=cols[j], linewidth=0, label=r == 1 ? labels[j] : false)
				x0 += d
			end
			annotate!(p, x0, r, text("  $(round(x0, digits=2)) min", 10, :left))
		end
		xlims!(p, 0, 1.3 * sum(rows[2][2]))
	end
else
	md""
end

# ╔═╡ 0f936c76-33e8-51a3-884a-c5f9ae7c3ebe
"Birth–death chain for M/M/c as SVG: up at rate λ, down at rate min(n, c)μ. With `probs=true`, each arrow shows the chance it is the next move (its rate ÷ total rate out of the state)."
function chain_svg(c::Int; nstates=6, probs=false)
	r, gap, x0, y = 24, 112, 50, 72
	m(k) = k == 1 ? "μ" : "$(k)μ"
	fs = probs ? 13 : 16
	xs = [x0 + i * gap for i in 0:nstates-1]
	el = String["""<defs><marker id="ah" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="#334155"/></marker></defs>"""]
	for (i, x) in enumerate(xs)
		n = i - 1
		fill = n ≥ c ? "#fee2e2" : "#dbeafe"
		push!(el, """<circle cx="$x" cy="$y" r="$r" fill="$fill" stroke="#334155" stroke-width="2"/><text x="$x" y="$(y+6)" font-size="18" text-anchor="middle" fill="#0f172a">$n</text>""")
		i == nstates && break
		x2, mid = xs[i+1], (x + xs[i+1]) / 2
		push!(el, """<path d="M$(x+17),$(y-17) Q$mid,$(y-62) $(x2-17),$(y-17)" fill="none" stroke="#334155" stroke-width="1.8" marker-end="url(#ah)"/><text x="$mid" y="$(y-44)" font-size="$fs" text-anchor="middle" fill="$BLUE">$(!probs ? "λ" : n == 0 ? "1" : "λ/(λ+$(m(min(n, c))))")</text>""")
		k = min(n + 1, c)
		push!(el, """<path d="M$(x2-17),$(y+17) Q$mid,$(y+62) $(x+17),$(y+17)" fill="none" stroke="#334155" stroke-width="1.8" marker-end="url(#ah)"/><text x="$mid" y="$(y+57)" font-size="$fs" text-anchor="middle" fill="$RED">$(probs ? "$(m(k))/(λ+$(m(k)))" : m(k))</text>""")
	end
	push!(el, """<text x="$(xs[end]+50)" y="$(y+6)" font-size="22" fill="#334155">…</text>""")
	push!(el, """<rect x="$(x0+560)" y="134" width="14" height="14" fill="#fee2e2" stroke="#334155"/><text x="$(x0+580)" y="146" font-size="13" fill="#334155">all GPUs busy</text>""")
	"""<svg viewBox="0 0 760 152" width="100%" style="max-width:760px">$(join(el))</svg>"""
end

# ╔═╡ 3be90aaf-4d63-5f9b-8eab-25a22cfe5a31
HTML(chain_svg(1; probs=view_mm1 != "rates"))

# ╔═╡ 7f4c463e-4781-5a90-b238-daeb778fc1df
HTML(chain_svg(c_mmc; probs=view_mmc != "rates"))

# ╔═╡ 997287ab-891b-50f1-8e61-3969f9f4b44c
"The Scribbl v2 pipeline diagram."
function pipeline_svg()
	box(x, y, w, label; fill="#f1f5f9") = """<rect x="$x" y="$y" width="$w" height="40" rx="8" fill="$fill" stroke="#334155" stroke-width="1.5"/><text x="$(x + w/2)" y="$(y+25)" font-size="14" text-anchor="middle" fill="#0f172a">$label</text>"""
	arrow(x1, y1, x2, y2) = """<line x1="$x1" y1="$y1" x2="$x2" y2="$y2" stroke="#334155" stroke-width="1.8" marker-end="url(#pa)"/>"""
	ys = [20, 80, 140]
	names = ["📝 summarize", "🃏 flashcards", "🌍 translate"]
	parts = String["""<defs><marker id="pa" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="#334155"/></marker></defs>"""]
	push!(parts, box(5, 80, 90, "📷 upload"), arrow(95, 100, 125, 100))
	push!(parts, box(127, 80, 150, "GPU line, c GPUs"; fill="#dbeafe"), arrow(277, 100, 318, 100))
	push!(parts, """<circle cx="328" cy="100" r="10" fill="#334155"/><text x="328" y="135" font-size="12" text-anchor="middle" fill="#334155">fork</text>""")
	for (y, nm) in zip(ys, names)
		push!(parts, arrow(338, 100, 395, y + 20), box(397, y, 150, nm; fill="#fef3c7"), arrow(547, y + 20, 602, 100))
	end
	push!(parts, """<circle cx="612" cy="100" r="10" fill="#334155"/><text x="612" y="135" font-size="12" text-anchor="middle" fill="#334155">join</text>""")
	push!(parts, arrow(622, 100, 650, 100), box(652, 80, 100, "✅ ready"))
	"""<svg viewBox="0 0 760 190" width="100%" style="max-width:760px">$(join(parts))</svg>"""
end

# ╔═╡ b0a743ab-7da0-5bb0-93a7-672083132ce8
md"""
## Plot twist: Scribbl v2

Investors want features. After the GPU, **three jobs run at the same time**; a note is ready when **all three** are done.

$(HTML(pipeline_svg()))

Each branch has its own worker and line. How long from upload to ready?

**The catch: no exact formula** for "wait until all three are done" (only for two).
- The three lines are fed by the same notes, so the answer depends on all three line lengths **at once**: too tangled to solve by hand.
- **Plan:** trap the answer between a **lower bound** and an **upper bound**, then check with a simulation.

To build the bounds we need:
1. what the GPU stage passes on to the branches (Checkpoint 4),
2. how long the **slowest** of several branches takes (Checkpoint 5),
3. whether the branches are independent (Checkpoint 6).
"""

# ╔═╡ b85adf8d-85ef-56e3-a754-c24b64c8d2ae
"Multiple-choice checkpoint: option cards; once revealed, the right one turns green."
function checkpoint(options, correct, revealed)
	cards = map(enumerate(options)) do (i, opt)
		ok = revealed && i == correct
		style = !revealed ? "border:2px solid #cbd5e1;background:#f8fafc" :
			ok ? "border:2px solid $GREEN;background:#dcfce7" : "border:2px solid #e2e8f0;opacity:0.4"
		"<div style='$style;border-radius:10px;padding:10px 16px;margin:8px 0;font-size:1.15em'><b>$('A' + i - 1).</b> $opt$(ok ? " ✅" : "")</div>"
	end
	HTML("<div style='max-width:760px'>" * join(cards) * "</div>")
end

# ╔═╡ 485de944-e45a-5358-a9aa-c7ea0072b14c
checkpoint([
	"20 seconds",
	"Less than 20 seconds: one is overdue",
	"More than 20 seconds: it must be a slow period",
	"0 seconds: one is certainly about to arrive"
], 1, cp1)

# ╔═╡ b1bb5375-c0ca-57d2-ba7a-9ce0fd3f60ae
checkpoint([
	"Going from 50% to 55% busy",
	"Going from 90% to 95% busy",
	"Same: both are +5%",
	"Neither: the wait only depends on the GPU’s speed"
], 2, cp2)

# ╔═╡ 6c5d7e1f-ae91-5773-b0fa-92508dba80b1
checkpoint([
	"Gets longer",
	"Stays the same: the load didn’t change",
	"Gets shorter",
	"Can’t tell"
], 3, cp3)

# ╔═╡ afd5dc2a-5f35-55c0-8ae7-e6ba09b579d9
checkpoint([
	"100",
	"125",
	"80",
	"225"
], 1, cp4)

# ╔═╡ fed100f8-32d1-582a-b58a-b42ce1525f84
checkpoint([
	"Exactly 1 minute",
	"Between 1 and 3 minutes",
	"Exactly 3 minutes",
	"More than 3 minutes"
], 2, cp5)

# ╔═╡ b5a2bf70-66c9-5725-8234-47006ca2d043
checkpoint([
	"Too low",
	"Exactly right",
	"Too high",
	"Could go either way"
], 3, cp6)

# ╔═╡ 866e8e2d-c4d1-5647-b3a9-904f6fb8d47a
"""
M/M/c: probability that exactly k = 0..c GPUs are busy at a random moment.
Below c it is p_k; the last entry (all busy) is the whole tail, i.e. Erlang C.
"""
function busy_dist(c::Int, a::Real)
	w = [a^k / factorial(big(k)) for k in 0:c]   # relative weights p_k / p_0
	tail = w[end] / (1 - a / c)                    # all busy: p_c + p_(c+1) + …
	P = Float64.(vcat(w[1:end-1], tail) ./ (sum(w[1:end-1]) + tail))
	P
end

# ╔═╡ 789048ac-804b-5c10-a004-e77cddf5a346
let u = u_pool, cs = 1:30
	wq = [erlang_c(c, u * c) / (c - u * c) for c in cs]   # in units of processing time
	p1 = bar(cs, wq, color=BLUE, alpha=0.7, linewidth=0, label=false, xlabel="GPUs in the pool",
		ylabel="wait ÷ processing time",
		title="avg wait:  1 GPU $(round(wq[1], digits=2))×,  30 GPUs $(round(wq[end], digits=3))×")
	dist(c) = let P = busy_dist(c, u * c), ks = 0:c
		allbusy = 100P[end]
		bar(100 .* ks ./ c, P, bar_width=100 / c * 0.8, linewidth=0, label=false,
			color=[k == c ? RED : GRAY for k in ks], xlims=(-3, 104), xticks=0:20:100,
			ylabel="fraction of time", guidefontsize=9,
			title="$c GPUs: all busy $(round(Int, allbusy))% of the time", titlefontsize=10)
	end
	d5, d50 = dist(5), dist(50)
	xlabel!(d50, "% of GPUs busy at a random moment")
	plot(p1, plot(d5, d50, layout=(2, 1)), layout=(1, 2), size=(760, 360))
end

# ╔═╡ 121cf8b8-fedc-5e4b-8871-331cd8802577
"Fork-join line lengths, event by event: an arrival adds 1 to every branch, a finished note removes 1 from one busy branch. Returns a (steps+1) × k matrix."
function forkjoin_walk(rng, k, ρ, steps)
	n = zeros(Int, k)
	path = [copy(n)]
	for _ in 1:steps
		rates = vcat(ρ, [n[i] > 0 ? 1.0 : 0.0 for i in 1:k])    # arrivals at ρ, each busy worker at 1
		j = findfirst(≥(rand(rng) * sum(rates)), cumsum(rates))
		j == 1 ? (n .+= 1) : (n[j-1] -= 1)
		push!(path, copy(n))
	end
	permutedims(reduce(hcat, path))
end

# ╔═╡ 083c9c53-78b1-57f8-a87c-bbbb0712b316
let k = k_walk, P = forkjoin_walk(Xoshiro(90 + reroll_walk), k_walk, ρ_walk, 600), m = step_walk
	Q = P[1:m+1, :]
	lim = maximum(P) + 1
	if k == 1
		plot(0:m, Q[:, 1], seriestype=:steppost, color=BLUE, label=false, xlims=(0, 600), ylims=(0, lim),
			xlabel="event #", ylabel="n₁ (line length)", title="1 branch: a walk on a line (over time)", size=(640, 360))
		scatter!([m], [Q[end, 1]], color=RED, markersize=7, label=false)
	elseif k == 2
		plot(Q[:, 1], Q[:, 2], color=BLUE, alpha=0.5, label=false, xlims=(0, lim), ylims=(0, lim),
			aspect_ratio=:equal, xlabel="n₁ (line 1)", ylabel="n₂ (line 2)", title="2 branches: a walk on a grid", size=(560, 440))
		plot!([0, lim], [0, lim], color=GRAY, linestyle=:dash, label="diagonal: n₁ = n₂")
		scatter!([Q[end, 1]], [Q[end, 2]], color=RED, markersize=7, label="now")
	else
		plot(Q[:, 1], Q[:, 2], Q[:, 3], color=BLUE, alpha=0.6, label=false, xlims=(0, lim), ylims=(0, lim),
			zlims=(0, lim), xlabel="n₁", ylabel="n₂", zlabel="n₃", title="3 branches: a walk in 3-D", camera=(45, 30),
			size=(600, 460))
		plot!([0, lim], [0, lim], [0, lim], color=GRAY, linestyle=:dash, label="diagonal")
		scatter!([Q[end, 1]], [Q[end, 2]], [Q[end, 3]], color=RED, markersize=6, label="now")
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
Plots = "~1.41.7"
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.13.0"
manifest_format = "2.1"
project_hash = "afca714ef5af0e0c526669188984c47815c4c678"

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

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Reexport"]
git-tree-sha1 = "291665b547f137df070e4dd83e432b5fee8cc4a0"
registries = "General"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.2"

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
git-tree-sha1 = "bba2d9aa057d8f126415de240573e86a8f39d2a1"
registries = "General"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "1.0.1"

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
git-tree-sha1 = "ef17c47d22224aaecc76e597ab21a072e025cf7b"
registries = "General"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.14.1+0"

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
# ╟─eac0e680-c24f-5b56-ab9b-e71d55df97ce
# ╟─0fa45428-cdd4-5710-8796-cfb1772bb14c
# ╟─7b7ac9c1-9958-514b-912e-501b8e24fecc
# ╟─5ff52dbd-37c6-5bba-b62d-08ef81a1685b
# ╟─8d109aa3-cc57-5445-bc50-75bb08128299
# ╟─db2f45d3-454a-595d-8ef3-e8560e71d0d0
# ╟─207fb2e0-99c7-5c80-bbdd-f51059c99709
# ╟─c8d8c9c2-2d49-55a3-a4ed-54f75f0b2776
# ╟─8683bc88-0859-597a-94c4-fe1f40fe4f19
# ╟─3e4688b1-fc01-53ad-8fef-596e9220cf57
# ╟─372907b3-cb05-5e5b-abce-ebe3aa646e8f
# ╟─c5a7981c-dfcc-59f8-b47c-374770d190cc
# ╟─efb6a82b-ca62-521e-8b9f-98658f804bd4
# ╟─35deae72-67fe-5620-8f00-adc13ab88917
# ╟─e8a2724f-a775-515b-8e4a-dc0f9cc5e541
# ╟─f8382513-b2c9-5fe3-b98f-6c6432df8871
# ╟─9c953c3f-07b8-54be-9f26-82e0b2e57ac3
# ╟─7987f2ba-3779-5ffc-befa-7f7c96f6fdb8
# ╟─76783a62-4940-5ac5-aa1c-7edd0e8e4025
# ╟─f61decbf-3652-53df-a760-35b65783f278
# ╟─a0a2b245-ea8a-572a-918d-804dd3c680c2
# ╟─4aaedcea-bf5b-59c0-b5a2-78b478733e62
# ╟─fd8c6de1-f58d-5933-9b23-21126f2aa09f
# ╟─c2cee7d4-8ce4-5c9c-85f7-9cbda25fb840
# ╟─c5266f89-4ad2-5bd0-a572-9e32d55b7eb4
# ╟─01aa8d87-7f26-5287-abb5-62b06fdb1477
# ╟─14ed8947-fb06-5a9e-9034-c51244e3abde
# ╟─485de944-e45a-5358-a9aa-c7ea0072b14c
# ╟─2b542e50-0bd5-5191-99da-9e7c53ff3d71
# ╟─207f41ef-3e21-55c3-9d7f-9a4ce1cc9e0c
# ╟─f8cb1979-1ee2-5281-8cbb-93f8be3bbc20
# ╟─9a20755d-9d74-5861-97ff-647a5e27164f
# ╟─6f7763da-fbcb-5bae-be69-f1c03dd8612b
# ╟─722b0fb3-0b47-5903-b8f4-f02935812fb1
# ╟─1ce703b6-c1a8-53fd-b1cb-da12be56e94e
# ╟─3be90aaf-4d63-5f9b-8eab-25a22cfe5a31
# ╟─1d811f54-83bf-5e83-97ee-1a8c54e5f905
# ╟─959a3a7b-7987-5cb0-bfbd-ea95560b8a53
# ╟─a72c7db8-5ce7-5691-a960-dd4ef3aa54e9
# ╟─412a6b56-ecfc-5334-bab4-c01ccdaca9ba
# ╟─9f5305f5-d1c8-50d4-b22e-792175a42862
# ╟─b184ca0b-a580-5259-a958-02aa80b1a75a
# ╟─17710779-ef2e-5d73-9304-4ac69133b882
# ╟─510c27d9-3092-5be1-b6c0-68053deb5f04
# ╟─f9339ea6-21eb-5ff3-808a-e0694db85c71
# ╟─b1bb5375-c0ca-57d2-ba7a-9ce0fd3f60ae
# ╟─082ebccc-f5dc-53d3-bf84-2864116bd91d
# ╟─f036ed59-e7b4-5edb-956c-e56844c43a3b
# ╟─e5f6b838-1efc-584a-a614-bbf48ecc030e
# ╟─7f4c463e-4781-5a90-b238-daeb778fc1df
# ╟─a5f3be65-4476-5ce4-8a4a-9144586ae5ba
# ╟─43ec7b13-56f8-5325-832c-0bcd4b62adbc
# ╟─f7e589e5-fba9-5bd4-aa58-5204b3865806
# ╟─06fc262f-d17e-5d7a-81b3-98bd09dbb805
# ╟─51f975d4-8967-5a70-b2b9-df1e89daf109
# ╟─0c47dc36-4e4e-5083-b859-270736b0643d
# ╟─789048ac-804b-5c10-a004-e77cddf5a346
# ╟─4a2c84e8-10fe-5754-bb57-a003258f518f
# ╟─7c46256a-c93d-592d-a11b-e3eb3e7c9d65
# ╟─55741125-9f43-578d-8ed8-fce176fb6b45
# ╟─6c5d7e1f-ae91-5773-b0fa-92508dba80b1
# ╟─a3c7bebe-e05c-55ee-ae15-875d404d31b1
# ╟─c057e2df-a0f7-5cb9-a713-453d64168022
# ╟─67bfef08-1706-5c8b-b321-805738a100e7
# ╟─4a725500-a83a-5b14-9f31-7f83b1b48d75
# ╟─7d97f7ae-56b7-53fb-ada4-22bfdb717db7
# ╟─f71e769f-ddc2-59ec-9381-910faeba7820
# ╟─b0a743ab-7da0-5bb0-93a7-672083132ce8
# ╟─d63f94b6-074a-5745-8110-6f29bff71a9b
# ╟─349f4eab-d29a-5097-8d52-25dfa63f8185
# ╟─083c9c53-78b1-57f8-a87c-bbbb0712b316
# ╟─d2a08a62-6acd-5a0f-99cb-0a615375053e
# ╟─0022c931-6091-5e3c-ab6a-2ee6f0c6a9f6
# ╟─52591f69-e8ff-5873-9dbf-3c0a4775d84b
# ╟─afd5dc2a-5f35-55c0-8ae7-e6ba09b579d9
# ╟─ffad597d-1e28-5a31-8413-1ac8f3505f0d
# ╟─f45695df-828e-5807-b66e-ebd808e1ebf4
# ╟─c739df48-4093-59c9-93a3-4e80d0a14232
# ╟─38882797-5fb6-5a13-8bb7-e12a8f64c8ec
# ╟─404316e0-2955-53b4-bf65-cc10de17cb1b
# ╟─fed100f8-32d1-582a-b58a-b42ce1525f84
# ╟─56edf76d-5e33-5be9-aad7-80a6c86e8ca4
# ╟─30f229f6-402b-5c03-b3b3-b1250e3cbcbd
# ╟─a06b4438-0ec9-51b3-9c60-33cf000b718f
# ╟─bd7baa0d-0fb3-54d8-9084-3b1ef4571fc0
# ╟─4cbe2db9-bb0b-5df7-a3de-e582626ad39e
# ╟─c13b4287-d177-5336-a101-4800a8aec07b
# ╟─4cc8885f-b4fe-59e9-b57e-aef0625942a0
# ╟─b5a2bf70-66c9-5725-8234-47006ca2d043
# ╟─b2b064e4-e88c-54e3-9856-857262bd6703
# ╟─2b0d4c11-0330-52f6-9b5e-370b9562bca5
# ╟─fdcd479d-108e-50d9-8adc-7964c4bd7f65
# ╟─348babc2-8d6f-5b8a-a47a-7a2ed5c9223e
# ╟─dc8fad03-1597-59a3-9d2a-f09ed586476c
# ╟─c94149c5-35f3-5ff9-a2ab-2519948a984c
# ╟─5f48c35f-feb6-5be0-986c-3d340ea09f82
# ╟─edb2c1d7-b83a-5e44-bd4a-4fc211e82762
# ╟─51975da8-4e7a-5227-bdb1-4d711d3dff87
# ╟─e6226ef6-3034-554c-b599-d1ee0e6e39f9
# ╟─f2403469-956a-5052-917c-088da67e2b48
# ╟─3d03290b-56f5-5e27-96b2-d2c748024d2c
# ╟─5446014a-af40-568b-979f-ee8722788d09
# ╟─626ccda4-6993-57e2-a51a-3c51c052bf70
# ╟─d075f692-473a-5d6c-ade6-0a8ed720b287
# ╟─5daf03b1-b5e5-54b8-a080-4a3d4f0d4d89
# ╟─6f8f3b6c-2af9-5b0e-be3a-d56d0ef2888e
# ╠═6134dde2-fbaf-581e-9621-109c380552e9
# ╠═fa722cc8-1703-5387-9524-9db7e75e3d92
# ╠═30c76f1e-19f3-5a74-a3a2-77aa8e610e8f
# ╠═7829298d-2335-5600-afaa-92be8adf787d
# ╠═9ad53e52-4d84-52c8-9b96-13023b517eb5
# ╠═d10587e6-fd4f-5242-aca3-f94f95f4467d
# ╠═57d1bf91-2cc8-523f-942a-42df50029224
# ╠═97ecf5b5-d7f3-5fb6-9c76-7fb0de2d3789
# ╠═21aa852f-26f5-5571-90ed-21ba01018d94
# ╠═3bc328b2-c9eb-5cb3-bc96-7c052830f679
# ╠═7281444f-5545-52ac-abf5-5ce74a6813a6
# ╠═cd4ad572-f656-5ee0-b5f4-c6303a293d50
# ╠═616f6820-ba53-5cda-89ea-62578a02e6ef
# ╠═413f9ff8-8f80-5f17-bbc9-8ae6e7bf1b16
# ╠═0f936c76-33e8-51a3-884a-c5f9ae7c3ebe
# ╠═997287ab-891b-50f1-8e61-3969f9f4b44c
# ╠═b85adf8d-85ef-56e3-a754-c24b64c8d2ae
# ╠═866e8e2d-c4d1-5647-b3a9-904f6fb8d47a
# ╠═121cf8b8-fedc-5e4b-8871-331cd8802577
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
