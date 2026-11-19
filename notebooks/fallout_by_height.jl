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

# ╔═╡ c94af885-4f8b-48d1-a6cd-850afe703757
begin
    using Base64
    img64(path) = "data:image/jpeg;base64," * base64encode(read(path))
    hiro  = img64(joinpath(@__DIR__, "hiroshima.jpg"))
    bravo = img64(joinpath(@__DIR__, "bravo_map.jpg"))
    HTML("""
    <div style="display: flex; gap: 18px; margin: 14px 0;">
      <figure style="flex: 1; margin: 0; background: #111; border-radius: 12px; overflow: hidden;">
        <img src="$hiro" style="width: 100%; height: 320px; object-fit: cover;">
        <figcaption style="color: #eee; padding: 12px 14px; font-size: 15px;">
          <b style="color: #5aa0ff;">AIR BURST</b> · Hiroshima, Aug 6, 1945 · about 600 m up
        </figcaption>
      </figure>
      <figure style="flex: 1; margin: 0; background: #111; border-radius: 12px; overflow: hidden;">
        <div style="background: white; height: 320px;">
          <img src="$bravo" style="width: 100%; height: 100%; object-fit: contain;">
        </div>
        <figcaption style="color: #eee; padding: 12px 14px; font-size: 15px;">
          <b style="color: #ff7a45;">SURFACE BURST</b> · Castle Bravo fallout, 48 hrs later · RAND RM-1855
        </figcaption>
      </figure>
    </div>
    """)
end

# ╔═╡ 6c30c54d-c0e1-49e7-8a35-6002fb1f846e
begin
    using PlutoUI, Plots, Random, Statistics
    TableOfContents(title="Fallout by Height")
end

# ╔═╡ 9806bac6-cbd0-11f1-8b2c-1b40a5094502
html"""
<div style="background: linear-gradient(135deg, #1a0f2e 0%, #5c1a1a 55%, #d9772b 100%);
            border-radius: 14px; padding: 36px 32px; color: white;">
  <div style="font-size: 13px; letter-spacing: 3px; opacity: 0.8;">18.C25 · FALL 2026 · THOMAS SHOALES</div>
  <div style="font-size: 44px; font-weight: 800; margin: 8px 0;">☢️ Fallout by Height</div>
  <div style="font-size: 20px; opacity: 0.9;">How burst altitude controls radioactive deposition</div>
</div>
"""

# ╔═╡ 4a82494b-8bf9-40a6-af83-cd1547c3a2e6
html"""
<h2>3. Roadmap</h2>
<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-top: 10px;">

  <div style="border-left: 6px solid #d9772b; background: #fdf3ec; border-radius: 10px; padding: 14px 16px;">
    <div style="font-size: 12px; letter-spacing: 2px; color: #a5531c; font-weight: 700;">PART 4</div>
    <div style="font-size: 18px; font-weight: 700; margin: 4px 0;">🌋 The story</div>
    <div style="font-size: 14px; color: #444;">Why touching the ground changes everything</div>
  </div>

  <div style="border-left: 6px solid #c0392b; background: #fbeeec; border-radius: 10px; padding: 14px 16px;">
    <div style="font-size: 12px; letter-spacing: 2px; color: #922b21; font-weight: 700;">PART 5</div>
    <div style="font-size: 18px; font-weight: 700; margin: 4px 0;">🪨 One particle</div>
    <div style="font-size: 14px; color: #444;">How fast it falls, and how fast its radioactivity fades</div>
  </div>

  <div style="border-left: 6px solid #7d3c98; background: #f4eef8; border-radius: 10px; padding: 14px 16px;">
    <div style="font-size: 12px; letter-spacing: 2px; color: #5b2c6f; font-weight: 700;">PART 6</div>
    <div style="font-size: 18px; font-weight: 700; margin: 4px 0;">☢️ The isotopes</div>
    <div style="font-size: 14px; color: #444;">Where radiation comes from, which isotopes survive the fall, and a decay-chain twist</div>
  </div>

  <div style="border-left: 6px solid #3f7fd1; background: #edf3fb; border-radius: 10px; padding: 14px 16px;">
    <div style="font-size: 12px; letter-spacing: 2px; color: #2a5a99; font-weight: 700;">PART 7</div>
    <div style="font-size: 18px; font-weight: 700; margin: 4px 0;">🎲 Thousands of particles</div>
    <div style="font-size: 14px; color: #444;">A random-walk simulation that builds a fallout map</div>
  </div>

</div>
<p style="margin-top: 14px; color: #666; font-size: 14px;"><b>Thread running through it all:</b> the race between how fast a particle falls and how fast its radioactivity fades.</p>
"""

# ╔═╡ 0a68612d-bb50-4d8e-acb7-45b50d61a25f
begin
    const g_ = 9.81        # m/s², gravity
    const μ_air = 1.8e-5   # Pa·s, air viscosity
    const ρ_p = 2600.0     # kg/m³, soil/glass particle density
    stokes_v(r) = (2/9) * ρ_p * g_ * r^2 / μ_air   # fall speed in m/s, r in meters
end

# ╔═╡ 799dc855-74be-4b21-a64b-b6a1a501fd26
begin
    Random.seed!(7)
    N_story = 60
    U_wind = 20.0                       # km/h, wind speed
    λ_story = log(2) / 12.0             # illustrative 12-hour half-life

    r_ground = 100e-6 .+ 200e-6 .* rand(N_story)   # 100 to 300 microns (sand)
    r_air    = 2e-6   .+ 8e-6   .* rand(N_story)   # 2 to 10 microns (dust)

    z0_ground = 8.0 .+ 1.2 .* randn(N_story)       # km, starting heights in the cloud
    z0_air    = 8.0 .+ 1.2 .* randn(N_story)
    x0_ground = 1.5 .* randn(N_story)              # km, cloud width
    x0_air    = 1.5 .* randn(N_story)

    function story_state(r, z0, x0, t)
        v = stokes_v.(r) .* 3.6                    # m/s to km/h
        t_land = z0 ./ v
        t_eff = min.(t, t_land)                    # landed particles stop moving
        z = z0 .- v .* t_eff
        x = x0 .+ U_wind .* t_eff
        activity = exp.(-λ_story .* t_eff)         # frozen at landing
        return x, z, activity
    end
end

# ╔═╡ 1600f6cb-0ae6-411a-b7df-6760290721af
md"""
**Particle radius (microns):** $(@bind r_one Slider([1, 2, 5, 10, 20, 50, 100, 200, 300, 500], default=10, show_value=true))

**Starting height (km):** $(@bind h_one Slider(1.0:0.5:15.0, default=8.0, show_value=true))

!!! tip "Predict first"
    Start at 10 microns. Before moving the slider to 200, guess: how much faster will it fall, and how much radioactivity will be left when it lands?
"""

# ╔═╡ c0b3acdd-699b-4659-a72c-aaaf99725920
begin
    fmt_time(h) = h < 1 ? "$(round(Int, 60h)) minutes" :
                  h < 48 ? "$(round(h, digits=1)) hours" : "$(round(h/24, digits=1)) days"

    ρ_air = 1.2
    r_m = r_one * 1e-6
    v_one = stokes_v(r_m)                          # m/s
    t_fall_one = h_one * 1000 / v_one / 3600       # hours
    left_one = exp(-λ_story * t_fall_one)          # fraction remaining
    Re_one = ρ_air * v_one * 2r_m / μ_air          # Reynolds number (Stokes valid if ≲ 1)
end

# ╔═╡ 77ba7813-58ef-480a-95e0-6ab586cce1aa
begin
    using Markdown
    stokes_note = Re_one > 1 ?
        "⚠️ *At this size the particle falls fast enough that Stokes' law is being stretched (Reynolds number ≈ $(round(Re_one, digits=1))). Real fall speeds would be somewhat slower.*" :
        "✅ *Stokes' law is a good approximation at this size.*"
    Markdown.parse("""
A **$(r_one)-micron** particle falls at **$(round(v_one, sigdigits=2)) m/s**, takes **$(fmt_time(t_fall_one))** to land from **$(h_one) km**, and arrives with **$(round(Int, 100left_one))%** of its radioactivity.

$stokes_note
""")
end

# ╔═╡ 2d2c1932-5cf4-4ef9-be67-529a04d3ba30
md"""
## 1. Why I care: my fallout simulator

In my UROP I helped to build a web-based nuclear fallout simulator that draws contamination plumes on a real map. It shows *where* fallout lands, but the physics underneath was a more difficult to understand. 

This project opens that box: **what actually decides where radioactive material lands, and how dangerous it still is when it gets there?**
"""

# ╔═╡ c1ac5103-0b3e-456e-abc1-715811584787
md"""
## 2. Two bombs, two very different aftermaths

**Hiroshima, August 6, 1945.** The bomb detonated roughly 600 meters *above* the city. The blast and fire were devastating, but the fireball never touched the ground, and local radioactive fallout was relatively limited.

**Castle Bravo, March 1, 1954.** A test at Bikini Atoll detonated *at the surface*. Within hours, a powdery white ash fell on inhabited islands and on a Japanese fishing boat, the *Lucky Dragon No. 5*, far outside the danger zone. People who had never seen the explosion got radiation sickness.

> **The question for today:** why does exploding on the ground make fallout so much more dangerous downwind?
"""

# ╔═╡ f853a342-5e80-41cd-9b2d-339cddb48f1f
md"""
## 4. The story: dirt changes everything

When a fireball **touches the ground**, it scoops up thousands of tons of soil. Radioactive vapor condenses onto those grains, making **big, heavy particles**, like sand.

When it explodes **high in the air**, there is no dirt to grab. The vapor condenses into **tiny particles**, like dust or smoke.

Both start in the same mushroom cloud. Then a **race** begins: does a particle reach the ground *before* its radioactivity fades?

!!! tip "Predict first"
    Big grains and fine dust are released from the same cloud. Which lands closer? Which is more radioactive when it lands?
"""

# ╔═╡ a61d7d98-99df-4a5c-8bb9-7aeafb39b582
md"""
▶️ **Start the race:** $(@bind race_step Clock(0.12, true, false, 150, false))
"""

# ╔═╡ e5ec2066-722e-4103-b9f4-3d5b4b165796
md"""
### What to notice
- 🟡 **Bright = still very radioactive.** ⚫ Dark = mostly decayed.
- **Ground burst:** the sand-sized grains land within an hour, close to ground zero, *still glowing*.
- **Air burst:** the dust is still floating days later, hundreds of kilometers away. By the time it lands, most of its radioactivity is gone.
- Look at the x-axes: the ground burst lands within **40 km**, while the air burst spreads over **thousands**.

*Simplifications: both clouds start at the same height (the real difference is particle size), one illustrative 12-hour half-life, steady wind, no random gusts yet. Gusts come in Section 7.*
"""

# ╔═╡ b15054fd-b609-442e-aada-01c0fde19b24
md"""
## 5. One particle: how fast does it fall?

Drop a grain of sand and a speck of dust from the same height. Gravity pulls both down, air pushes back up, and each settles at a steady **terminal speed**. For small particles, that speed is given by **Stokes' law**:

```math
v = \frac{2}{9}\,\frac{\rho_p\, g\, r^2}{\mu}
```

- ``v``: how fast the particle falls (meters per second)
- ``\rho_p``: how dense the particle is. Heavier stuff falls faster.
- ``g``: gravity, the pull downward
- ``\mu``: air's "stickiness" (viscosity), the drag pushing back
- ``r``: the particle's radius, and it's **squared**

**One simple case:** double the radius and the particle falls **4 times faster**. A grain 100 times wider falls **10,000 times faster**. That ``r^2`` is the whole reason sand and dust end up in such different places.
"""

# ╔═╡ 86351899-4375-47d3-858f-5d4717905e0c
md"""
### ...and how fast does it fade?

A radioactive sample loses atoms the way hot coffee loses heat: **the more you have, the faster you lose it.**

```math
\frac{dN}{dt} = -\lambda N
```

**What is changing?** ``N``, the number of radioactive atoms still riding on the particle. As atoms decay into stable ones, ``N`` goes down.

**What controls the rate?** Two things multiplied together:
- ``N`` itself: more radioactive atoms means more decays per second.
- ``\lambda``, the decay rate: each isotope's built-in chance of decaying per hour. Big ``\lambda`` fades fast (iodine-132), tiny ``\lambda`` fades slowly (cesium-137).

**Why?** Every atom decays on its own, with the same fixed chance each moment, like each atom flipping its own weighted coin. Atoms don't age or affect each other. So total decays per second = (chance per atom) × (number of atoms) = ``\lambda N``. The **minus sign** is there because each decay removes an atom.

**One simple case:** start with 1,000 atoms and ``\lambda`` = 10% per hour. About 100 decay in the first hour, leaving 900. The next hour only about 90 decay, since there are fewer atoms flipping coins. The decay slows as the pile shrinks.

**What it predicts:** ``N(t) = N_0 e^{-\lambda t}``. Every **half-life**, half of what's left disappears: 50%, then 25%, then 12.5%. It never quite reaches zero.

**The race:** fall time comes from Stokes' law, and this decay clock runs the whole time the particle is in the air. Whatever is left at landing is what reaches people.
"""

# ╔═╡ 45ca3509-3d8d-4964-8a0d-f233176e8e30
md"""
## 6. Where does the radiation come from?

The bomb's fuel is uranium-235. When a neutron hits a uranium atom, it splits into **two smaller atoms** plus a couple of spare neutrons. Those fragments are the **fission products**, and they are what's radioactive in fallout.

Which two fragments you get is **random**. Split billions of atoms and you get hundreds of different isotopes.

!!! tip "Predict first"
    When a uranium atom splits, does it usually break into two equal halves?
"""

# ╔═╡ 631c0b9b-da98-486e-aac7-1479274cc23e
md"**Number of atoms split:** $(@bind n_split Slider([10, 100, 1_000, 10_000, 100_000], default=100, show_value=true))"

# ╔═╡ 69e7778e-d976-4710-827c-35fc445f8c16
md"""
- **Almost never equal halves.** Atoms prefer to split into one heavier piece (around mass 135 to 140) and one lighter piece (around 90 to 100). Nobody predicts *which* split a given atom takes, but thousands of atoms always build the same double hump. Drag the slider from 10 to 100,000 to watch it emerge.
- **Iodine and cesium sit right on the heavy hump**, which is why they're so common in fallout. Strontium-90, another long-lived hazard, sits on the light hump.
- This is the first of three kinds of randomness in this talk: **random splits** here, **random decays** (each atom's chance per second), and **random gusts** in Section 7.

*Illustrative model: two bell-shaped humps approximating the real uranium-235 fission yield curve, not exact nuclear data.*
"""

# ╔═╡ 9e185f65-6967-4602-aef7-b2229bd2adb8
md"""
### Who survives the fall?

Fallout isn't one substance. It's hundreds of radioactive isotopes, each with its own half-life. Three that matter:

| Isotope | Half-life | Why it matters |
|:--|:--|:--|
| **Iodine-132** | 2.3 hours | Intense, but gone within a day |
| **Iodine-131** | 8 days | Absorbed by the thyroid, especially in children |
| **Cesium-137** | 30 years | Contaminates land for decades |

Let's send each one down on a **sand grain** (ground burst, 150 microns) and on a **dust speck** (air burst, 5 microns), both starting 8 km up.
"""

# ╔═╡ 22712db3-7de6-47b2-9e20-e857876291c5
begin
    isotopes = [
        (name="Iodine-132", half_life=2.3,          color=RGB(0.98, 0.75, 0.10)),
        (name="Iodine-131", half_life=8.02 * 24,    color=RGB(0.90, 0.35, 0.10)),
        (name="Cesium-137", half_life=30.1 * 8766,  color=RGB(0.45, 0.10, 0.45)),
    ]                                   # half-lives in hours

    fall_hours(r_microns; h_km=8.0) = h_km * 1000 / stokes_v(r_microns * 1e-6) / 3600
    t_ground = fall_hours(150)
    t_air    = fall_hours(5)
    surviving(iso, t) = 0.5^(t / iso.half_life)
end

# ╔═╡ bb79e7cc-a455-4c26-9343-e5401f550bd7
md"""
!!! tip "Predict first"
    Cesium-137 lasts 30 years. Will burst height make any difference to how much of it reaches the ground?
"""

# ╔═╡ 70808e44-d720-44a5-90fc-fd0c3272bbdb
md"""
### The takeaway
Sand lands in **$(fmt_time(t_ground))**. Dust takes **$(fmt_time(t_air))**.

- **Iodine-132:** $(round(Int, 100surviving(isotopes[1], t_ground)))% survives on sand, $(round(Int, 100surviving(isotopes[1], t_air)))% on dust.
- **Iodine-131:** $(round(Int, 100surviving(isotopes[2], t_ground)))% on sand, $(round(Int, 100surviving(isotopes[2], t_air)))% on dust.
- **Cesium-137:** essentially 100% either way.

**Burst height controls the short-term danger, not the long-term contamination.** Long-lived isotopes like cesium outlast any fall time, so they arrive no matter what. An air burst doesn't remove them, it just spreads them thinly over a huge area.
"""

# ╔═╡ 564f444e-303e-4a8b-82b6-14c99b147ac6
md"""
## 7. Thousands of particles: a random-walk fallout map

So far each particle fell straight down a fixed path. Real air is gusty: every moment, a particle gets shoved a little left or right at random.

**Warm-up: flip a coin.** Heads, step right. Tails, step left. Where do you end up after many flips?

!!! tip "Predict first"
    After 100 flips, how far from the start do you expect to be? 100 steps? 50? Zero?
"""

# ╔═╡ f67d1fac-4fad-4218-872f-841f6c2655a5
md"**Number of flips:** $(@bind n_flips Slider(1:200, default=100, show_value=true))"

# ╔═╡ 1fbf1e05-c68c-456a-bd60-92b9a770af60
md"""
**The key idea:** random steps mostly cancel out, so after ``n`` steps you are typically only about ``\sqrt{n}`` away. Four times the time gives only **twice** the spread. And the pile of endpoints forms a bell curve (the orange line), no matter how jagged each walk looks.

Now give every fallout particle that same treatment. Every small time step ``\Delta t``, update its position:

```math
\begin{aligned}
x_{\text{next}} &= x + U\,\Delta t + \sigma\sqrt{\Delta t}\;\xi_1 \\
y_{\text{next}} &= y + \sigma\sqrt{\Delta t}\;\xi_2 \\
z_{\text{next}} &= z - v(r)\,\Delta t
\end{aligned}
```

| Symbol | What it is | Units | In my simulation |
|:--|:--|:--|:--|
| ``x`` | distance **downwind** from ground zero | km | starts near 0 |
| ``y`` | distance **sideways** (crosswind) | km | starts near 0 |
| ``z`` | **altitude** | km | starts around 8 km |
| ``\Delta t`` | length of one time step | hours | 0.05 h (3 minutes) |
| ``U`` | steady **wind speed**, the same push for every particle | km/h | slider, default 30 |
| ``\sigma`` | **gustiness**: how hard random gusts shove particles | km/√h | slider, default 6 |
| ``\xi_1, \xi_2`` | random numbers ("xi"), drawn fresh each step from a bell curve centered at 0 | none | usually between −2 and 2 |
| ``v(r)`` | **fall speed** from Stokes' law, set by particle radius ``r`` | km/h | about 11 km/h for 100-micron sand |

**How to read each line:**
- **Downwind:** new position = old position + steady wind push + random gust.
- **Sideways:** there's no steady crosswind, so it's only random gusts. That's why the plume spreads to both sides.
- **Altitude:** the particle drops at its Stokes speed. Nothing random here.

The gust uses ``\sqrt{\Delta t}`` instead of ``\Delta t`` because of the ``\sqrt{n}`` rule above: random kicks add up like a square root.

**One step, with real numbers** (100-micron sand grain, wind 30 km/h, gustiness 6, ``\Delta t`` = 3 minutes):
- Wind: 30 × 0.05 = **1.5 km** downwind
- Typical gust: 6 × √0.05 ≈ **1.3 km**, in a random direction
- Fall: 11 × 0.05 ≈ **0.56 km** lower

From 8 km up, that grain lands after about 14 steps (about 45 minutes). A 5-micron dust speck would need thousands of steps, which is why it drifts so much farther.

Repeat for thousands of particles until each one lands. Where they land, colored by how radioactive they still are, **is** the fallout map.
"""

# ╔═╡ 9865d9ba-c80f-4c87-83f8-a30f52b0bcb2
begin
    # illustrative mix: mostly short-lived activity, a little long-lived
    activity_mix(t) = 0.60 * 0.5^(t / 2.3) + 0.35 * 0.5^(t / 192.5) + 0.05 * 0.5^(t / 263_870)

    function run_fallout(; burst_h, U, σ, N=3000, dt=0.05, Tmax=72.0, seed=1)
        rng = MersenneTwister(seed)
        fireball_R = 300.0                                  # m, illustrative fireball radius
        f_sand = clamp(1 - burst_h / fireball_R, 0.0, 1.0)  # share of particles that grab dirt

        r = [rand(rng) < f_sand ? exp(log(100.0) + 0.6randn(rng)) :   # sand, ~100 microns
                                  exp(log(5.0)   + 0.5randn(rng)) for _ in 1:N]  # dust, ~5 microns
        v = stokes_v.(r .* 1e-6) .* 3.6                     # km/h
        x = 1.5 .* randn(rng, N)
        y = 1.5 .* randn(rng, N)
        z = max.(8.0 .+ 1.2 .* randn(rng, N), 2.0)          # km
        landed = falses(N)
        t_land = fill(NaN, N)

        t = 0.0
        while t < Tmax && !all(landed)
            for i in 1:N
                landed[i] && continue
                x[i] += U * dt + σ * sqrt(dt) * randn(rng)
                y[i] += σ * sqrt(dt) * randn(rng)
                z[i] -= v[i] * dt
                if z[i] <= 0
                    landed[i] = true
                    t_land[i] = t + dt
                end
            end
            t += dt
        end
        return (; x, y, landed, t_land, f_sand, N)
    end
end

# ╔═╡ 933288a8-5959-4cbb-9587-69582ddbbf93
md"""
**Burst height (m):** $(@bind burst_h Slider(0:25:600, default=0, show_value=true)) *0 = surface burst*

**Wind speed (km/h):** $(@bind U7 Slider(5:5:60, default=30, show_value=true))

**Gustiness σ (km/√h):** $(@bind σ7 Slider(0:1:15, default=6, show_value=true))

!!! tip "Predict first"
    Slide the burst height from 0 to 600 m. What happens to the hot zone near ground zero? Where does the radioactivity go?
"""

# ╔═╡ e043652a-f3b5-43ab-a8ab-765633df9156
sim = run_fallout(burst_h=burst_h, U=U7, σ=σ7);

# ╔═╡ a9de1897-47a5-45e5-a488-90f43bfae5f1
begin
    landed_act = activity_mix.(sim.t_land[sim.landed])
    avg_act = isempty(landed_act) ? 0.0 : mean(landed_act)
    md"""
    With a burst at **$(burst_h) m**, about **$(round(Int, 100sim.f_sand))%** of particles grab dirt and become sand-sized.

    - **$(round(Int, 100count(sim.landed) / sim.N))%** of particles land within 72 hours. The rest are still drifting, spread over a far larger area.
    - Particles that land carry on average **$(round(Int, 100avg_act))%** of their starting radioactivity.

    Compare the contamination map with the real Castle Bravo map from Section 1: a hot spot near ground zero stretching into a long plume downwind.

    *Simplifications: one steady wind direction at all heights, an illustrative fireball size and isotope mix, Stokes' law even where it stretches, and no rain.*
    """
end

# ╔═╡ c165ef20-8df9-4b0b-b250-4cf6a93e8166
md"""
### 7b. How do I know the simulation is right?

Each particle just flips coins. But a **crowd** of thousands of coin-flipping particles obeys an exact equation, the **advection-diffusion equation**. If my simulation is correct, it should match this equation's exact answer.

```math
\underbrace{\frac{\partial c}{\partial t}}_{\text{change over time}}
+ \underbrace{U\,\frac{\partial c}{\partial x}}_{\text{wind carries it}}
= \underbrace{K\left(\frac{\partial^2 c}{\partial x^2} + \frac{\partial^2 c}{\partial y^2}\right)}_{\text{gusts spread it}},
\qquad K = \frac{\sigma^2}{2}
```

| Symbol | What it is | Units |
|:--|:--|:--|
| ``c(x, y, t)`` | **concentration**: how crowded the particles are at map position ``(x, y)`` at time ``t`` | share of particles per km² |
| ``x, y`` | position downwind and sideways | km |
| ``t`` | time since release | hours |
| ``U`` | steady wind speed (same as Section 7) | km/h |
| ``\sigma`` | gustiness (same as Section 7) | km/√h |
| ``K`` | **diffusion coefficient**: how fast the cloud spreads, set by gustiness | km²/h |
| ``\partial`` | "partial" derivative: how ``c`` changes in one direction while holding the others fixed | |

**Why "partial"?** In Section 5, ``N`` only depended on time, so we had an ordinary derivative ``dN/dt``. Here ``c`` depends on position **and** time, so we take derivatives one variable at a time. That makes this a **partial differential equation (PDE)**.

**Reading each term:**
- ``\partial c/\partial t``: how fast the crowd at one spot is growing or shrinking.
- ``U\,\partial c/\partial x``: the **wind** slides the whole cloud downwind. It moves the cloud but doesn't change its shape.
- ``K\,\nabla^2 c``: **spreading**. The second derivative measures whether a spot is more crowded than its neighbors. Crowded peaks lose particles to the emptier areas around them, so the cloud flattens out.
- ``K = \sigma^2/2``: gustier air spreads the cloud faster.

**Why does crowding drain away?** Gusts kick particles in random directions. A crowded spot has more particles to kick *out* than its empty neighbors have to kick *in*, so on average particles flow from crowded to empty.

**Simple case:** drop dye into a river. The current carries it downstream (the ``U`` term) while it spreads into a wider, fainter blob (the ``K`` term).

**What it predicts:** if everything starts at one point, the exact solution is a bell curve that drifts with the wind and widens over time:

```math
c(x, y, t) = \frac{1}{4\pi K t}\exp\!\left(-\frac{(x - Ut)^2 + y^2}{4Kt}\right)
\quad\Longrightarrow\quad \text{plume width} = \sigma\sqrt{t}
```

- The center sits at ``x = Ut``: it drifts with the wind.
- The width grows like ``\sqrt{t}``: the coin-flip rule again, now coming out of a PDE.
- The peak height shrinks like ``1/t``: the same particles spread over more area.

**The test:** release 5,000 particles from one point, let them random-walk, and compare their spread to this formula. If they match, the simulation is doing the physics correctly.

!!! tip "Predict first"
    If the particles drift for 4 times as long, how much wider does the plume get?
"""

# ╔═╡ d588926a-8684-4478-a296-65a97df50ef4
begin
    σc = max(σ7, 0.5)    # reuses the gustiness slider from Section 7 (avoid σ = 0)

    function walk_spread(; σ, N=5000, dt=0.05, Tmax=48, seed=5)
        rng = MersenneTwister(seed)
        y = zeros(N)
        steps_per_hour = round(Int, 1 / dt)
        times, widths = Float64[], Float64[]
        snaps = Dict{Int, Vector{Float64}}()
        for k in 1:(Tmax * steps_per_hour)
            y .+= σ * sqrt(dt) .* randn(rng, N)          # the same gust rule as Section 7
            if k % steps_per_hour == 0
                h = k ÷ steps_per_hour
                push!(times, h); push!(widths, std(y))
                snaps[h] = copy(y)
            end
        end
        return (; times, widths, snaps)
    end

    spread = walk_spread(σ=σc)
    nothing
end

# ╔═╡ e3162ccb-108e-4884-86cd-c213bea5a7c6
md"**Hours of drifting:** $(@bind t_check Slider(1:48, default=4, show_value=true))"

# ╔═╡ b7917336-fbff-4730-b7a5-17b6c043010a
md"""
## 8. The race, in one picture

Back to the blackboard: **big falls fast, radioactivity fades, and it's a race.**

- 🌋 **Ground burst:** the fireball grabs dirt, makes sand-sized particles, they land in minutes, still hot. Intense, concentrated fallout downwind.
- ☁️ **Air burst:** no dirt, dust-sized particles drift for days, and the short-lived danger decays before landing.
- ☢️ **But long-lived isotopes like cesium-137 survive either way.** Burst height decides the *short-term* danger, not the long-term contamination.

> **Question for you:** same bomb, same yield. Why is the ground burst worse for someone 50 miles downwind, even though the air burst does more blast damage?
"""

# ╔═╡ 26cafac4-1423-458a-a204-ce8ccb40cb1f
begin
    default(fontfamily="Helvetica", titlefontsize=15, guidefontsize=13,
            tickfontsize=11, legendfontsize=11, size=(850, 480),
            framestyle=:box, grid=false, lw=2.5, dpi=110)
    const HOT  = cgrad(:inferno)
    const SKY  = RGB(0.93, 0.95, 0.99)
    const DIRT = RGB(0.55, 0.42, 0.30)
    const GROUND_COLOR = RGB(0.85, 0.30, 0.15)
    const AIR_COLOR    = RGB(0.25, 0.55, 0.90)
    nothing
end

# ╔═╡ d16640a0-11a2-41ef-a7fd-29555e9f8333
begin
    t_now = 0.02 * 1.06^race_step       # clock speeds up: minutes at first, days by the end

    function race_panel(x, z, a, xmax, ttl, col; cbar=false)
        p = plot(xlims=(-5, xmax), ylims=(-0.6, 11.5), legend=false,
                 title=ttl, titlefontcolor=col,
                 xlabel="distance downwind (km)", ylabel="altitude (km)",
                 background_color_inside=SKY)
        hspan!(p, [-0.6, 0], color=DIRT, alpha=0.9)
        scatter!(p, x, max.(z, 0.08), zcolor=a, color=HOT, clims=(0, 1),
                 ms=7, msw=0.4, msc=:black, colorbar=cbar,
                 colorbar_title=" radioactivity left")
        return p
    end

    xg, zg, ag = story_state(r_ground, z0_ground, x0_ground, t_now)
    xa, za, aa = story_state(r_air,    z0_air,    x0_air,    t_now)

    p_g = race_panel(xg, zg, ag, 40,   "Ground burst: sand-sized", GROUND_COLOR)
    p_a = race_panel(xa, za, aa, 2600, "Air burst: dust-sized",    AIR_COLOR; cbar=true)

    hrs = t_now < 1 ? "$(round(Int, 60t_now)) minutes" : "$(round(t_now, digits=1)) hours"
    plot(p_g, p_a, layout=(1, 2), size=(1050, 460),
         plot_title="Time since detonation: $hrs", plot_titlefontsize=16,
         left_margin=4Plots.mm, bottom_margin=6Plots.mm)
end

# ╔═╡ 83de3062-f9ce-4ec9-b546-444f644b3e4b
begin
    rr = 10 .^ range(0, log10(500), length=200)
    p_speed = plot(rr, stokes_v.(rr .* 1e-6), xscale=:log10, yscale=:log10,
                   color=:gray30, label="Stokes' law",
                   xlabel="particle radius (microns)", ylabel="fall speed (m/s)",
                   title="Bigger falls much faster")
    scatter!(p_speed, [r_one], [v_one], ms=11, zcolor=[left_one], color=HOT,
             clims=(0, 1), colorbar=false, label="your particle")

    tt = range(0, max(2t_fall_one, 24), length=400)
    p_decay = plot(tt, exp.(-λ_story .* tt), color=:gray30, label="radioactivity left",
                   xlabel="time (hours)", ylabel="fraction remaining", ylims=(0, 1.05),
                   title="Lands after $(fmt_time(t_fall_one))")
    vline!(p_decay, [t_fall_one], color=GROUND_COLOR, ls=:dash, label="lands")
    scatter!(p_decay, [t_fall_one], [left_one], ms=11, zcolor=[left_one], color=HOT,
             clims=(0, 1), colorbar=false, label="")

    plot(p_speed, p_decay, layout=(1, 2), size=(1050, 430),
         left_margin=5Plots.mm, bottom_margin=6Plots.mm)
end

# ╔═╡ df8ca5ae-0b71-4e1c-b82a-96bd2d4918c3
begin
    rng_f = MersenneTwister(11)
    A_heavy = round.(Int, 139 .+ 5.5 .* randn(rng_f, n_split))   # heavy fragment mass
    A_light = 234 .- A_heavy                                     # 236 total, minus ~2 spare neutrons
    masses = vcat(A_heavy, A_light)

    p_fis = histogram(masses, bins=70:1:165, normalize=:probability,
                      color=GROUND_COLOR, alpha=0.85, linecolor=GROUND_COLOR,
                      label="fragments", legend=:top, xlims=(70, 165),
                      xlabel="fragment mass (protons + neutrons)",
                      ylabel="share of fragments",
                      title="$(n_split) uranium atoms split at random (fission yield curve)",
                      size=(950, 420), left_margin=5Plots.mm, bottom_margin=5Plots.mm)
    for (m, nm, c) in [(90,  "strontium-90", AIR_COLOR),
                       (131, "iodine-131",   RGB(0.90, 0.35, 0.10)),
                       (137, "cesium-137",   RGB(0.45, 0.10, 0.45))]
        vline!(p_fis, [m], color=c, lw=2.5, ls=:dash, label=nm)
    end
    p_fis
end

# ╔═╡ 2bf3ffc1-36a3-448c-a761-5ac4863201bd
begin
    tt6 = 10 .^ range(log10(0.05), log10(8766), length=500)
    tick_h = [0.1, 1, 24, 168, 720, 8766]
    tick_l = ["6 min", "1 hour", "1 day", "1 week", "1 month", "1 year"]

    p_curve = plot(xscale=:log10, xticks=(tick_h, tick_l), xlims=(0.05, 8766),
                   ylims=(0, 1.18), legend=:bottomleft,
                   xlabel="time in the air", ylabel="fraction remaining",
                   title="Each isotope's decay clock")
    for iso in isotopes
        plot!(p_curve, tt6, surviving.(Ref(iso), tt6), color=iso.color, lw=3.5, label=iso.name)
    end
    vline!(p_curve, [t_ground], color=GROUND_COLOR, ls=:dash, lw=2, label="")
    vline!(p_curve, [t_air],    color=AIR_COLOR,    ls=:dash, lw=2, label="")
    annotate!(p_curve, t_ground, 1.1, text("sand lands\n$(fmt_time(t_ground))", 9, GROUND_COLOR))
    annotate!(p_curve, t_air,    1.1, text("dust lands\n$(fmt_time(t_air))",    9, AIR_COLOR))

    xs = 1:length(isotopes)
    g_vals = [surviving(i, t_ground) for i in isotopes]
    a_vals = [surviving(i, t_air)    for i in isotopes]
    p_bars = bar(xs .- 0.2, g_vals, bar_width=0.38, color=GROUND_COLOR, label="ground burst")
    bar!(p_bars, xs .+ 0.2, a_vals, bar_width=0.38, color=AIR_COLOR, label="air burst")
    for (i, (g, a)) in enumerate(zip(g_vals, a_vals))
        annotate!(p_bars, i - 0.2, g + 0.06, text("$(round(Int, 100g))%", 10))
        annotate!(p_bars, i + 0.2, a + 0.06, text("$(round(Int, 100a))%", 10))
    end
    plot!(p_bars, xticks=(xs, [i.name for i in isotopes]), ylims=(0, 1.18),
          ylabel="fraction left at landing", title="What reaches the ground",
          legend=:outertopright)

    plot(p_curve, p_bars, layout=(1, 2), size=(1100, 450),
         left_margin=5Plots.mm, bottom_margin=6Plots.mm)
end

# ╔═╡ 7dec6fa6-cad9-433c-ab68-c9ad3235ba34
begin
    rng_c = MersenneTwister(3)
    walks = cumsum(rand(rng_c, [-1, 1], 200, 2000), dims=1)   # 2000 walkers, 200 flips each

    p_walk = plot(0:n_flips, vcat(zeros(1, 40), walks[1:n_flips, 1:40]), color=:gray60,
                  alpha=0.5, lw=1, legend=false, xlabel="flip number", ylabel="position",
                  title="40 random walkers", ylims=(-45, 45))
    plot!(p_walk, 0:n_flips, sqrt.(0:n_flips), color=GROUND_COLOR, lw=3.5)
    plot!(p_walk, 0:n_flips, -sqrt.(0:n_flips), color=GROUND_COLOR, lw=3.5)

    finals = walks[n_flips, :]
    p_hist = histogram(finals, bins=-45:2:45, normalize=:pdf, color=AIR_COLOR,
                       alpha=0.75, legend=false, xlims=(-45, 45),
                       xlabel="final position", ylabel="share of walkers",
                       title="Typical distance ≈ √$(n_flips) ≈ $(round(sqrt(n_flips), digits=1))")
    xg7 = range(-45, 45, length=300)
    plot!(p_hist, xg7, exp.(-xg7.^2 ./ (2n_flips)) ./ sqrt(2π * n_flips),
          color=GROUND_COLOR, lw=3.5)

    plot(p_walk, p_hist, layout=(1, 2), size=(1050, 420),
         left_margin=5Plots.mm, bottom_margin=6Plots.mm)
end

# ╔═╡ 4f8c0536-8e86-4da7-95b5-85e0e3bdcaa0
begin
    L = sim.landed
    act = activity_mix.(sim.t_land[L])
    NIGHT = RGB(0.06, 0.06, 0.10)

    p_pts = scatter(sim.x[L], sim.y[L], zcolor=act, color=HOT, clims=(0, 1),
                    ms=3, msw=0, alpha=0.8, label="",
                    xlims=(-20, 400), ylims=(-100, 100),
                    background_color_inside=NIGHT,
                    colorbar_title=" radioactivity at landing",
                    xlabel="km downwind", ylabel="km crosswind",
                    title="Where particles land (first 72 hours)")
    scatter!(p_pts, [0], [0], marker=:xcross, ms=8, msw=2, color=:white, label="")
    annotate!(p_pts, 6, 14, text("ground zero", :white, 10, :left))

    xe, ye = -20:5:400, -100:5:100
    M = zeros(length(ye) - 1, length(xe) - 1)
    for (xi, yi, a) in zip(sim.x[L], sim.y[L], act)
        ix = searchsortedlast(xe, xi); iy = searchsortedlast(ye, yi)
        (1 <= ix < length(xe) && 1 <= iy < length(ye)) && (M[iy, ix] += a)
    end
    M ./= sim.N
    Mplot = [m > 0 ? log10(m) : NaN for m in M]
    p_map = heatmap(xe[1:end-1] .+ 2.5, ye[1:end-1] .+ 2.5, Mplot, color=HOT,
                    clims=(-4, -1), background_color_inside=NIGHT,
                    colorbar_title=" log₁₀ contamination",
                    xlabel="km downwind", ylabel="km crosswind",
                    title="Contamination map")
    scatter!(p_map, [0], [0], marker=:xcross, ms=8, msw=2, color=:white, label="")
    annotate!(p_map, 6, 14, text("ground zero", :white, 10, :left))

    plot(p_pts, p_map, layout=(2, 1), size=(1000, 820),
         left_margin=6Plots.mm, bottom_margin=5Plots.mm)
end

# ╔═╡ 2f9f1410-bd59-4a41-ab4c-6c165af9a781
begin
    yy = spread.snaps[t_check]
    s_exact = σc * sqrt(t_check)
    lim = 4σc * sqrt(48)

    p_h = histogram(yy, bins=range(-lim, lim, length=120), normalize=:pdf,
                    color=AIR_COLOR, alpha=0.75, linecolor=AIR_COLOR,
                    label="5,000 simulated particles", xlims=(-lim, lim),
                    ylims=(0, 1.15 / (sqrt(2π) * σc)),
                    xlabel="km crosswind", ylabel="concentration",
                    title="After $(t_check) hours", legend=:topright)
    yg = range(-lim, lim, length=400)
    plot!(p_h, yg, exp.(-yg.^2 ./ (2s_exact^2)) ./ (sqrt(2π) * s_exact),
          color=GROUND_COLOR, lw=3.5, label="exact PDE solution")

    th = 0:0.1:48
    p_w = scatter(spread.times, spread.widths, color=AIR_COLOR, ms=4, msw=0,
                  label="simulated width", xlabel="hours drifting",
                  ylabel="plume width (km)", title="Width grows like √t",
                  legend=:topleft)
    plot!(p_w, th, σc .* sqrt.(th), color=GROUND_COLOR, lw=3.5, label="exact: σ√t")
    vline!(p_w, [t_check], color=:gray50, ls=:dash, label="")

    plot(p_h, p_w, layout=(1, 2), size=(1100, 430),
         left_margin=5Plots.mm, bottom_margin=6Plots.mm)
end

# ╔═╡ b3c74c4c-6def-4201-8dfb-4d5cdd4ddd75
begin
    sim_w = spread.widths[t_check]
    err_pct = 100abs(sim_w - s_exact) / s_exact
    Markdown.parse("""
After **$(t_check) hours**, the simulated plume is **$(round(sim_w, digits=2)) km** wide. The PDE predicts **$(round(s_exact, digits=2)) km**, a difference of **$(round(err_pct, digits=1))%**.

Two completely different methods, one flipping coins for 5,000 particles and one solving a PDE with calculus, give the same answer. That's the evidence the simulation is doing the physics correctly. The small leftover difference is Monte Carlo noise, which shrinks as you add more particles.
""")
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Base64 = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
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
project_hash = "b7589167b448c7b094ed7ec8996039eb4cffd88e"

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
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
registries = "General"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
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
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "37ea44092930b1811e666c3bc38065d7d87fcc74"
registries = "General"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.1"

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
git-tree-sha1 = "88352712893ec50bee3680605891eaf0e9ed6368"
registries = "General"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.8.0"

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
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "26ca162858917496748aad52bb5d3be4d26a228a"
registries = "General"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.4"

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

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "4f96c596b8c8258cc7d3b19797854d368f243ddc"
registries = "General"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.4"

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
git-tree-sha1 = "2d0fc55c61321ba245c47be599570d11bac50303"
registries = "General"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.8.5"

    [deps.StructUtils.extensions]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
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
# ╟─9806bac6-cbd0-11f1-8b2c-1b40a5094502
# ╟─2d2c1932-5cf4-4ef9-be67-529a04d3ba30
# ╟─c1ac5103-0b3e-456e-abc1-715811584787
# ╟─c94af885-4f8b-48d1-a6cd-850afe703757
# ╟─4a82494b-8bf9-40a6-af83-cd1547c3a2e6
# ╟─f853a342-5e80-41cd-9b2d-339cddb48f1f
# ╟─0a68612d-bb50-4d8e-acb7-45b50d61a25f
# ╟─799dc855-74be-4b21-a64b-b6a1a501fd26
# ╟─a61d7d98-99df-4a5c-8bb9-7aeafb39b582
# ╟─d16640a0-11a2-41ef-a7fd-29555e9f8333
# ╟─e5ec2066-722e-4103-b9f4-3d5b4b165796
# ╟─b15054fd-b609-442e-aada-01c0fde19b24
# ╟─86351899-4375-47d3-858f-5d4717905e0c
# ╟─1600f6cb-0ae6-411a-b7df-6760290721af
# ╟─c0b3acdd-699b-4659-a72c-aaaf99725920
# ╟─83de3062-f9ce-4ec9-b546-444f644b3e4b
# ╟─77ba7813-58ef-480a-95e0-6ab586cce1aa
# ╟─45ca3509-3d8d-4964-8a0d-f233176e8e30
# ╟─631c0b9b-da98-486e-aac7-1479274cc23e
# ╟─df8ca5ae-0b71-4e1c-b82a-96bd2d4918c3
# ╟─69e7778e-d976-4710-827c-35fc445f8c16
# ╟─9e185f65-6967-4602-aef7-b2229bd2adb8
# ╟─22712db3-7de6-47b2-9e20-e857876291c5
# ╟─bb79e7cc-a455-4c26-9343-e5401f550bd7
# ╟─2bf3ffc1-36a3-448c-a761-5ac4863201bd
# ╟─70808e44-d720-44a5-90fc-fd0c3272bbdb
# ╟─564f444e-303e-4a8b-82b6-14c99b147ac6
# ╟─f67d1fac-4fad-4218-872f-841f6c2655a5
# ╟─7dec6fa6-cad9-433c-ab68-c9ad3235ba34
# ╟─1fbf1e05-c68c-456a-bd60-92b9a770af60
# ╟─9865d9ba-c80f-4c87-83f8-a30f52b0bcb2
# ╟─933288a8-5959-4cbb-9587-69582ddbbf93
# ╟─e043652a-f3b5-43ab-a8ab-765633df9156
# ╟─4f8c0536-8e86-4da7-95b5-85e0e3bdcaa0
# ╟─a9de1897-47a5-45e5-a488-90f43bfae5f1
# ╟─c165ef20-8df9-4b0b-b250-4cf6a93e8166
# ╟─d588926a-8684-4478-a296-65a97df50ef4
# ╟─e3162ccb-108e-4884-86cd-c213bea5a7c6
# ╟─2f9f1410-bd59-4a41-ab4c-6c165af9a781
# ╟─b3c74c4c-6def-4201-8dfb-4d5cdd4ddd75
# ╟─b7917336-fbff-4730-b7a5-17b6c043010a
# ╟─6c30c54d-c0e1-49e7-8a35-6002fb1f846e
# ╟─26cafac4-1423-458a-a204-ce8ccb40cb1f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
