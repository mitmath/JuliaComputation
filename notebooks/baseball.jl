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

# ╔═╡ 43cf8e7b-0f80-40eb-b8d3-cdeb57f996a8
using PlutoUI

# ╔═╡ efcb2bff-1471-458d-a3e6-309a79b22cf9
html"<button onclick='present()'>Start Presentation</button>"

# ╔═╡ 7d5bca93-0ddb-45e8-baec-3034a39f41a4
md"""
## Ball Trajectories in baseball
"""

# ╔═╡ 2a057a6c-bfd5-4b44-8d1a-714c9620e21a
let video = joinpath(@__DIR__, "baseball_demo.mp4")
    isfile(video) ? LocalResource(video) : md"*The introductory demo video was not included with this notebook. The simulations below are available.*"
end

# ╔═╡ 9053158a-872a-4e3c-b524-ee7ef24d15bd


# ╔═╡ 20f8fd5b-f792-47ae-8e18-ebabad3946d3
md"""
## Live demo
"""

# ╔═╡ 6b16e580-08f5-484e-b143-4dd5f6d71a3b
md"""
## Magnus Force
"""

# ╔═╡ 1b475654-c032-421b-a2b3-b0e92c6083d4
begin
# ---------- geometry (ball radius = 1, ball at origin, y up) ----------
dir(φ) = [cosd(φ), sind(φ)]
hermite(p0, m0, p1, m1; n=300) =
	[(2t^3 - 3t^2 + 1) .* p0 .+ (t^3 - 2t^2 + t) .* m0 .+
	 (-2t^3 + 3t^2) .* p1 .+ (t^3 - t^2) .* m1  for t in range(0, 1; length=n)]
arc(r, θ1, θ2; n=200) = [r .* dir(θ) for θ in range(θ1, θ2; length=n)]

# illustrative stream passing OVER the ball; a = +1 surface moves with the air, -1 against it
function stream_over(a)
	blend(against, none, with) = a ≥ 0 ? none + a * (with - none) : none - a * (against - none)
	h0, r, θin = 0.45, blend(1.28, 1.20, 1.15), 150.0
	θout = blend(125.0, 90.0, 10.0)
	yend = blend(1.55, h0, -0.90)
	φend = blend(8.0, 0.0, -10.0)
	along(θ) = dir(θ - 90)
	A, A2, B = [-6.6, h0], [-2.6, h0], r .* dir(θin)
	C, D = r .* dir(θout), [6.6, yend]
	[hermite(A, A2 .- A, A2, A2 .- A; n=50);
	 hermite(A2, 1.6 .* dir(0), B, 0.8 .* along(θin))[2:end];
	 arc(r, θin, θout)[2:end];
	 hermite(C, 2.5 .* along(θout), D, 5.0 .* dir(φend))[2:end]]
end
stream_under(a) = [[x, -y] for (x, y) in stream_over(a)]

# illustrative speed: faster where surface helps the air, much slower where it opposes
function speed(p, a)
	near = a ≥ 0 ? 1.15 + 0.30a : 1.15 + 1.03a
	w = exp(-((hypot(p...) - 1) / 0.55)^2)
	1 + (near - 1) * w
end

# move a parcel of air along the path at the local speed; sample every dt seconds
function time_sample(path, a; U=1.5, dt=1/60)
	t = [0.0]
	for i in 2:length(path)
		ds = hypot((path[i] .- path[i-1])...)
		push!(t, t[end] + ds / (U * speed((path[i] .+ path[i-1]) ./ 2, a)))
	end
	pts = map(0:dt:t[end]) do τ
		i = clamp(searchsortedlast(t, τ), 1, length(t) - 1)
		f = (τ - t[i]) / (t[i+1] - t[i])
		(1 - f) .* path[i] .+ f .* path[i+1]
	end
	x, y = first.(pts), last.(pts)
	tx = [x[min(i+1, end)] - x[max(i-1, 1)] for i in eachindex(x)]
	ty = [y[min(i+1, end)] - y[max(i-1, 1)] for i in eachindex(y)]
	len = hypot.(tx, ty)
	r4(v) = round.(v; digits=4)
	(x=r4(x), y=r4(y), nx=r4(-ty ./ len), ny=r4(tx ./ len), T=t[end])
end

# Newton's 3rd law: downward turn of the air (3 radii behind ball) => upward push on ball
function heading(path, x0)
	i = findfirst(p -> p[1] ≥ x0, path)
	d = path[i] .- path[i-1]
	atan(d[2], d[1])
end
downwash(spin) = -(sin(heading(stream_over(spin), 3.0)) + sin(heading(stream_under(-spin), 3.0)))

airflow(spin) = (
	streams = [time_sample(stream_over(spin), spin), time_sample(stream_under(-spin), -spin)],
	omega   = 2.0 * spin,
	lift    = downwash(spin) / downwash(1.0),
)

flows = [airflow(s) for s in (-1.0, 0.0, 1.0)]   # topspin, no spin, backspin

# Julia data -> JavaScript text
js(x::Number) = string(x)
js(v::AbstractVector) = "[" * join(js.(v), ",") * "]"
js(t::NamedTuple) = "{" * join(["$k:" * js(v) for (k, v) in pairs(t)], ",") * "}"

HTML("<script>\nconst flows = " * js(flows) * "\n" * raw"""
const W = 960, H = 540, S = 80, cx = W / 2, cy = H / 2
const toX = x => cx + S * x, toY = y => cy - S * y
const HALF = 0.15, TRAIL = 6, TRAIL_DT = 0.035, PULSE = 0.9
const pulse = t => 0.45 + 0.55 * Math.max(0, Math.cos(2 * Math.PI * t / PULSE)) ** 3

const wrap = document.createElement("div")
const canvas = document.createElement("canvas")
canvas.width = 2 * W; canvas.height = 2 * H
canvas.style.cssText = "width:100%; display:block; border-radius:12px; background:#0a0d13"
const ctx = canvas.getContext("2d")

const puff = document.createElement("canvas")
puff.width = puff.height = 64
const pg = puff.getContext("2d"), grad = pg.createRadialGradient(32, 32, 0, 32, 32, 32)
grad.addColorStop(0, "rgba(255,255,255,1)")
grad.addColorStop(0.3, "rgba(255,255,255,0.55)")
grad.addColorStop(1, "rgba(255,255,255,0)")
pg.fillStyle = grad; pg.fillRect(0, 0, 64, 64)

const makeParticles = T => Array.from({length: 240}, () => {
  const s = Math.random()
  return { s, b: pulse(-s * T), side: (Math.random() + Math.random() + Math.random() - 1.5) / 1.5,
           size: 0.7 + 0.6 * Math.random() }
})
const st = { k: 2, show: false, clock: 0, angle: 0, shown: 0, lift: flows[2].lift,
             particles: flows[2].streams.map(p => makeParticles(p.T)) }

const bar = document.createElement("div")
bar.style.cssText = "display:flex; gap:8px; align-items:center; margin-top:10px; font-family:system-ui,sans-serif; font-size:15px"
const btns = ["↺ topspin", "no spin", "↻ backspin"].map((t, k) => {
  const b = document.createElement("button")
  b.textContent = t
  b.style.cssText = "padding:6px 14px; border-radius:8px; border:1px solid #888; cursor:pointer"
  b.onclick = () => { st.k = k; paint() }
  bar.appendChild(b); return b
})
const paint = () => btns.forEach((b, k) => {
  b.style.background = k === st.k ? "#d9ee3a" : "white"; b.style.fontWeight = k === st.k ? "700" : "400" })
paint()
const lab = document.createElement("label"), cb = document.createElement("input")
cb.type = "checkbox"; cb.onchange = () => { st.show = cb.checked }
lab.style.marginLeft = "16px"; lab.append(cb, " show forces"); bar.appendChild(lab)
wrap.append(canvas, bar)

function at(path, s, side) {
  const n = path.x.length, f = s * (n - 1), i = Math.floor(f), j = Math.min(i + 1, n - 1), w = f - i
  const L = a => a[i] + w * (a[j] - a[i])
  return [toX(L(path.x) + side * HALF * L(path.nx)), toY(L(path.y) + side * HALF * L(path.ny))]
}

function drawBall() {
  ctx.save(); ctx.translate(cx, cy)
  const body = ctx.createRadialGradient(-0.35 * S, -0.4 * S, 0.05 * S, 0, 0, S)
  body.addColorStop(0, "#f7ffa8"); body.addColorStop(0.6, "#d9ee3a"); body.addColorStop(1, "#97ac17")
  ctx.fillStyle = body
  ctx.beginPath(); ctx.arc(0, 0, S, 0, 2 * Math.PI); ctx.fill()
  ctx.clip(); ctx.rotate(st.angle)
  ctx.strokeStyle = "rgba(255,255,255,0.92)"; ctx.lineWidth = 6
  ctx.beginPath(); ctx.arc(-1.45 * S, 0, 1.05 * S, -1, 1); ctx.stroke()
  ctx.beginPath(); ctx.arc(1.45 * S, 0, 1.05 * S, Math.PI - 1, Math.PI + 1); ctx.stroke()
  ctx.restore()
}

function arrow(x0, y0, x1, y1, color, width) {
  const ang = Math.atan2(y1 - y0, x1 - x0), head = 4 * width
  ctx.strokeStyle = ctx.fillStyle = color; ctx.lineWidth = width; ctx.lineCap = "round"
  ctx.beginPath(); ctx.moveTo(x0, y0)
  ctx.lineTo(x1 - 0.8 * head * Math.cos(ang), y1 - 0.8 * head * Math.sin(ang)); ctx.stroke()
  ctx.beginPath(); ctx.moveTo(x1, y1)
  ctx.lineTo(x1 - head * Math.cos(ang - 0.45), y1 - head * Math.sin(ang - 0.45))
  ctx.lineTo(x1 - head * Math.cos(ang + 0.45), y1 - head * Math.sin(ang + 0.45))
  ctx.closePath(); ctx.fill()
}

function drawLabels(flow) {
  ctx.font = "17px system-ui, sans-serif"
  ctx.textAlign = "left"; ctx.fillStyle = "rgba(255,255,255,0.75)"
  ctx.fillText(flow.omega > 0.05 ? "backspin  ↻  clockwise" :
               flow.omega < -0.05 ? "topspin  ↺  counter-clockwise" : "no spin", 20, 34)
  ctx.fillText("air  →", toX(-5.7), toY(0.45) - 20)
  ctx.font = "13px system-ui, sans-serif"; ctx.fillStyle = "rgba(255,255,255,0.4)"
  ctx.fillText("ball's view: the ball flies ←, so the air flows →", 20, H - 18)
  ctx.textAlign = "right"
  ctx.fillText("illustrative airflow, not a CFD solution", W - 20, H - 18)
}

function drawForces() {
  ctx.globalAlpha = st.shown
  ctx.font = "600 18px system-ui, sans-serif"
  const L = st.lift
  if (Math.abs(L) < 0.04) {
    ctx.textAlign = "center"; ctx.fillStyle = "#ffffff"
    ctx.fillText("symmetric flow → no net push on the air → no Magnus force", cx, 70)
    return
  }
  const up = Math.sign(L)
  const tipY = cy - up * (1.05 + 1.15 * Math.abs(L)) * S
  arrow(cx, cy, cx, tipY, "#ff5c5c", 6)
  ctx.textAlign = "left"; ctx.fillStyle = "#ff8080"
  ctx.fillText("force on ball", cx + 16, tipY + (up > 0 ? 16 : -4))
  const ax = toX(3.3), y0 = toY(up * 0.9), y1 = y0 + up * 1.1 * Math.abs(L) * S
  arrow(ax, y0, ax, y1, "#5cc8ff", 5)
  ctx.fillStyle = "#8ad8ff"
  ctx.fillText(up > 0 ? "air pushed down" : "air pushed up", ax + 14, (y0 + y1) / 2 + 6)
}

let last = performance.now(), raf
function frame(now) {
  const dt = Math.min(0.05, (now - last) / 1000); last = now
  const flow = flows[st.k]
  st.clock += dt
  st.angle += flow.omega * dt
  st.shown += ((st.show ? 1 : 0) - st.shown) * Math.min(1, 5 * dt)
  st.lift += (flow.lift - st.lift) * Math.min(1, 5 * dt)

  ctx.setTransform(2, 0, 0, 2, 0, 0)
  ctx.globalCompositeOperation = "source-over"; ctx.globalAlpha = 1
  ctx.fillStyle = "#0a0d13"; ctx.fillRect(0, 0, W, H)

  ctx.globalCompositeOperation = "lighter"
  flow.streams.forEach((path, k) => {
    for (const q of st.particles[k]) {
      q.s += dt / path.T
      if (q.s >= 1) { q.s -= 1; q.b = pulse(st.clock) }
      for (let n = 0; n < TRAIL; n++) {
        const s = q.s - n * TRAIL_DT / path.T
        if (s < 0) break
        const [X, Y] = at(path, s, q.side), r = 13 * q.size
        ctx.globalAlpha = 0.16 * q.b * (1 - n / TRAIL) * Math.min(1, s / 0.03, (1 - s) / 0.03)
        ctx.drawImage(puff, X - r, Y - r, 2 * r, 2 * r)
      }
    }
  })

  ctx.globalCompositeOperation = "source-over"; ctx.globalAlpha = 1
  drawBall()
  drawLabels(flow)
  if (st.shown > 0.01) drawForces()
  ctx.globalAlpha = 1
  raf = requestAnimationFrame(frame)
}
raf = requestAnimationFrame(frame)
invalidation.then(() => cancelAnimationFrame(raf))
return wrap
</script>
""")
end

# ╔═╡ 3efd26d8-f29d-4ead-8079-23acd13b5dd9
md"""
### Direction!

The Magnus force acts **perpendicular to both the ball's velocity and its spin axis**.

Determined by the cross product $\vec{\omega} \times \vec{v}$.

Mental cheat sheet:
- Topspin → downward force
- Backspin → upward force
- Sidespin → sideways force


### Magnitude!


$F_M = \frac{1}{2}\rho C_L A v^2$

- **ρ:** Air density — denser air produces more force.
- **C_L:** Lift coefficient — captures how spin and airflow affect the force.
- **A:** Cross-sectional area — a larger ball generally experiences more force.
- **v:** Ball speed — faster motion produces more force (for fixed $C_L$).

**Direction:** 
**Key intuition:** Spinning deflects the surrounding airflow. By Newton's third law, the air pushes the ball in the opposite direction.
"""

# ╔═╡ 120860e2-1e87-4bee-a46e-cfe97ea369d1
md"""
## Why does the paper cylinder curve backward, but the tennis ball doesn't?
"""

# ╔═╡ 84417d7a-4817-401f-be10-056796b37ba8
md"""

## Newton's second law: F=ma

Even if both objects experience the same Magnus force:

- 🎾 **Tennis ball:** Large mass → Small acceleration
- 📄 **Paper cylinder:** Small mass → Large acceleration

**Key intuition:** It's not just the force that matters, but how much it accelerates the object.

The paper cylinder's smaller mass makes it much more sensitive to aerodynamic forces.
"""

# ╔═╡ cc633591-cde8-4cd7-9912-753c4effe5b6

begin
    ρ = 1.2
    v = 2.0
    g = 9.81

    # Tennis ball
    m_t = 0.057
    A_t = π * (0.067 / 2)^2
    CL_t = 0.3

    # Paper cylinder
    m_p = 0.001
    A_p = 0.08 * 0.20
    CL_p = 0.3

    # Magnus forces
    F_t = 0.5 * ρ * CL_t * A_t * v^2
    F_p = 0.5 * ρ * CL_p * A_p * v^2

    # Accelerations
    a_t = F_t / m_t
    a_p = F_p / m_p

    md"""
    ## 🎾 Tennis Ball vs. 📄 Paper Cylinder

    ### The Magnus Force Equation

    ```math
    F_M = \frac{1}{2}\rho C_L A v^2
    ```

    The resulting acceleration is:

    ```math
    a_M = \frac{F_M}{m}
    ```

    ### 1. Compare the Objects

    Assume both travel at **2 m/s** with the same lift coefficient.

    | Parameter | 🎾 Tennis Ball | 📄 Paper Cylinder |
    |---|---:|---:|
    | Mass | 57 g | 1 g |
    | Projected Area | $(round(A_t, digits=4)) m² | $(round(A_p, digits=4)) m² |
    | Lift Coefficient | $CL_t | $CL_p |
    | **Magnus Force** | **$(round(F_t, digits=4)) N** | **$(round(F_p, digits=4)) N** |
    | **Magnus Acceleration** | **$(round(a_t, digits=3)) m/s²** | **$(round(a_p, digits=2)) m/s²** |

    ### 2. Why Such a Big Difference?

    - **Area:** Paper presents $(round(A_p/A_t, digits=1))× more projected area.
    - **Mass:** Tennis ball is $(round(m_t/m_p))× heavier.
    - **Lift coefficient:** Identical for both in this simplified comparison.

    ### 3. The Result

    The paper experiences:

    - **$(round(F_p/F_t, digits=1))× greater Magnus force**
    - **$(round(a_p/a_t))× greater Magnus acceleration!**

    ### 4. Compare with Gravity

    ```math
    a_g = 9.81\\ \mathrm{m/s^2}
    ```

    The paper's estimated Magnus acceleration is approximately **$(round(a_p/g, digits=2))× gravitational acceleration**.

    **Key intuition:** Even with identical lift coefficients, the paper's larger projected area and dramatically smaller mass make aerodynamic forces much more influential.

    *These are illustrative estimates. Real lift coefficients depend on shape, spin, speed, and airflow. The Magnus force also changes direction as the cylinder falls.*
    """
end


# ╔═╡ e75aacc1-73d8-4b33-b414-2f169e348322
md"""
## The other forces on a pitch

```math
m\vec a = \vec F_g + \vec F_b + \vec F_d + \vec F_M + \vec F_s
```

### 🌍 Gravity: ``\vec F_g = m\vec g``
- **Direction:** straight down
- **Magnitude:** depends only on the ball's mass: ``0.145\text{ kg} \times 9.81\text{ m/s}^2 \approx 1.4\text{ N}``
- **Key intuition:** the same force on every pitch, whatever its speed or spin

### 🎈 Buoyancy: ``\vec F_b = \rho_{\text{air}} V g\,\hat z``
- **Direction:** straight up
- **Magnitude:** the weight of the air the ball pushes aside
- **Key intuition:** air is about 1000× less dense than water, so buoyancy is tiny for a baseball

### 🪂 Drag: ``\vec F_d = -\tfrac12 C_D \rho A v\,\vec v``
- **Direction:** opposite the ball's velocity
- **Magnitude:** grows with speed **squared**, so doubling the speed means 4× the drag
- **Key intuition:** the ball has to shove air out of its way, and that slows it down

### ⚾ Seam-shifted wake: ``\vec F_s``
- **Direction:** mostly sideways
- **Magnitude:** depends on where the seams sit as the ball spins
- **Key intuition:** the seams can make the air peel off the ball unevenly, giving extra movement that spin alone doesn't explain. It's hard to model, so we leave it out.

> 🤔 **Predict:** for a 95 mph fastball, rank these forces from biggest to smallest.
"""

# ╔═╡ e1c53560-0d58-4fb0-a711-bba6bee3a6b2
md"""
## Why we leave out the seam force
Unlike gravity, drag and Magnus, the seam force has no simple formula. 

The seam force is still an active area of research. Predicting it accurately takes 3D turbulence simulations, which is far beyond the compute power that my notebook can produce for a reasonably good simulation. So I leave it out and treat it as the remaining few inches of movement my model can’t explain.

It's also smaller, usually a few inches of movement compared with about 20 inches from Magnus, and it mostly cancels on a 4-seam fastball. So our model covers most of a pitch's movement.
"""

# ╔═╡ e3982fb0-0fee-4dc7-92a5-94a116bd9f35
md"""
## Effect of Magnus Force on pitch location
"""

# ╔═╡ 142ce579-36d6-49e4-9583-fafd58f3f4d9
@bind pitch_params HTML("""
<span style="display:block; font-family:system-ui,sans-serif; font-size:15px; line-height:2">
  <div><b>Preset:</b>
    <button data-p="95,2300,215" style="padding:3px 12px; margin-left:6px; cursor:pointer">4-seam fastball</button>
    <button data-p="86,2450,85" style="padding:3px 12px; margin-left:6px; cursor:pointer">Slider</button>
    <button data-p="80,2550,25" style="padding:3px 12px; margin-left:6px; cursor:pointer">Curveball</button>
  </div>
  <div><b>Pitch speed</b> <input type="range" name="v" min="60" max="105" step="1" value="92"> <output></output> mph</div>
  <div><b>Spin rate</b> <input type="range" name="rpm" min="0" max="3500" step="50" value="2300"> <output></output> rpm</div>
  <div><b>Spin axis</b> <input type="range" name="dir" min="0" max="355" step="5" value="180"> <output></output>°
    <span style="opacity:0.65"> (Statcast style: 180 = backspin, 0 = topspin, 90 / 270 = sidespin)</span></div>
  <div><b>Forces:</b>
    <label><input type="checkbox" name="g"> gravity</label>
    <label style="margin-left:10px"><input type="checkbox" name="buoy"> buoyancy</label>
    <label style="margin-left:10px"><input type="checkbox" name="drag"> drag</label>
    <label style="margin-left:10px"><input type="checkbox" name="magnus"> Magnus</label></div>
<script>
const root = currentScript.parentElement
const el = n => root.querySelector("[name=" + n + "]")
function update() {
  for (const n of ["v", "rpm", "dir"]) el(n).nextElementSibling.textContent = el(n).value
  root.value = { v: +el("v").value, rpm: +el("rpm").value, dir: +el("dir").value,
                 g: el("g").checked, buoy: el("buoy").checked, drag: el("drag").checked, magnus: el("magnus").checked }
}
function send() { update(); root.dispatchEvent(new CustomEvent("input")) }
root.querySelectorAll("input").forEach(i => i.addEventListener("input", e => { e.stopPropagation(); send() }))
root.querySelectorAll("button").forEach(b => b.addEventListener("click", () => {
  const [v, rpm, dir] = b.dataset.p.split(",")
  el("v").value = v; el("rpm").value = rpm; el("dir").value = dir
  send()
}))
update()
</script>
</span>
""")

# ╔═╡ 2aa1c3ec-9f50-4b43-b965-89556ca2a980
md"""
### 🤔 Drag is the biggest force on a fastball, so it must change where the pitch lands the most… right?
"""

# ╔═╡ 13223efd-8209-43a6-9848-ef2cbbc8fcd5
begin
	# units: SI inside, feet for the picture. Catcher's view: x → right, y → toward pitcher, z ↑ up
	ft, mph = 0.3048, 0.44704
	m_ball, r_ball, ρ_air, C_D = 0.145, 0.0366, 1.2, 0.35   # kg, m, kg/m³, drag coefficient
	K = ρ_air * π * r_ball^2 / (2m_ball)
	a_buoy = ρ_air * (4/3) * π * r_ball^3 * 9.81 / m_ball   # buoyancy acceleration (m/s², up)
	release = [-1.8, 54.0, 6.0] .* ft      # fixed release point (right-handed pitcher)
	plate_y = 17 / 12 * ft                  # front edge of home plate

	cross3(a, b) = [a[2]b[3] - a[3]b[2], a[3]b[1] - a[1]b[3], a[1]b[2] - a[2]b[1]]

	# spin axis at angle θ (Statcast style), catcher's view, measured from +x toward +z:
	# 180 = backspin, 0 = topspin, 90 / 270 = sidespin. Magnus push = ω × v (right-hand rule)
	spin_axis(θ) = [cosd(θ), 0.0, sind(θ)]

	# fly the ball from the release point to the front of home plate
	# m a = gravity + buoyancy + drag + Magnus
	function fly(v0, rpm, φ, aim; g=true, buoy=true, drag=true, magnus=true, dt=2e-4)
		ω, ω̂ = rpm * 2π / 60, spin_axis(φ)
		p, v, t = copy(release), v0 .* aim, 0.0
		while p[2] > plate_y && p[3] > 0 && t < 3
			s = hypot(v...)
			S = r_ball * ω / s                       # spin factor
			C_L = S / (0.4 + 2.32S)                  # lift coefficient (A. Nathan's fit)
			a = g * [0, 0, -9.81] .+                              # gravity
			    buoy * [0, 0, a_buoy] .-                          # buoyancy
			    drag * K * C_D * s .* v .+                        # drag (opposes motion)
			    magnus * K * C_L * s^2 .* cross3(ω̂, v ./ s)      # Magnus (⟂ to spin axis and velocity)
			v = v .+ a .* dt
			p = p .+ v .* dt
			t += dt
		end
		(x=p[1] / ft, z=p[3] / ft, t=t)
	end

	# fixed throwing direction (a real pitcher's aim): with ALL forces on, the default
	# pitch (92 mph, 2300 rpm backspin) lands mid-zone. With NO forces it flies straight.
	AIM = let target = [0.0, 2.5], pt = [0.0, 2.5], d = [0.0, -1.0, 0.0]
		for _ in 1:25
			dvec = [pt[1] * ft, plate_y, pt[2] * ft] .- release
			d = dvec ./ hypot(dvec...)
			r = fly(92mph, 2300, 180, d)
			pt .+= target .- [r.x, r.z]
		end
		d
	end

	# ---- picture (catcher's view) ----
	function pitch_view(v_mph, rpm, spin_dir, use_g=true, use_drag=true, use_magnus=true, use_buoy=true)
		hit  = fly(v_mph * mph, rpm, spin_dir, AIM; g=use_g, buoy=use_buoy, drag=use_drag, magnus=use_magnus)
		none = fly(v_mph * mph, rpm, spin_dir, AIM; g=use_g, buoy=use_buoy, drag=use_drag, magnus=false)
		nob  = fly(v_mph * mph, rpm, spin_dir, AIM; g=use_g, buoy=false, drag=use_drag, magnus=use_magnus)
		λ = (plate_y - release[2]) / AIM[2]                     # straight line: where it was aimed
		ax, az = (release[1] + λ * AIM[1]) / ft, (release[3] + λ * AIM[3]) / ft
		X(x) = 260 + 100x;  Y(z) = 590 - 100z                   # 100 px per foot
		forces = join([n for (n, on) in (("gravity", use_g), ("buoyancy", use_buoy), ("drag", use_drag), ("Magnus", use_magnus)) if on], " + ")
		show_ghost = use_magnus && rpm > 0
		hw, zlo, zhi, rb = 17 / 24, 1.6, 3.5, r_ball / ft      # half plate width, zone, ball radius (ft)
		strike = abs(hit.x) ≤ hw + rb && zlo - rb ≤ hit.z ≤ zhi + rb && hit.z > 0
		h = mod((spin_dir - 180) / 30, 12); hh = floor(Int, h); mm = round(Int, (h - hh) * 60)
		clock = string(hh == 0 ? 12 : hh, ":", lpad(mm, 2, '0'))
		dx, dz = (hit.x - none.x) * 12, (hit.z - none.z) * 12   # inches moved by spin
		grid = join(["<line x1='$(X(-hw + 2hw*i/3))' y1='$(Y(zhi))' x2='$(X(-hw + 2hw*i/3))' y2='$(Y(zlo))'/>" *
		             "<line x1='$(X(-hw))' y1='$(Y(zlo + (zhi-zlo)*i/3))' x2='$(X(hw))' y2='$(Y(zlo + (zhi-zlo)*i/3))'/>" for i in 1:2])
		ghost = show_ghost ? string(
			"<circle cx='$(X(none.x))' cy='$(Y(none.z))' r='$(100rb)' fill='none' stroke='#8b95a3' stroke-width='1.5' stroke-dasharray='4 3'/>",
			"<text x='$(X(none.x) + 18)' y='$(Y(none.z) + 5)' fill='#8b95a3' font-size='12'>without Magnus</text>",
			"<line x1='$(X(none.x))' y1='$(Y(none.z))' x2='$(X(hit.x))' y2='$(Y(hit.z))' stroke='#5cc8ff' stroke-width='2' stroke-dasharray='2 3'/>") : ""
		verdict = hit.z ≤ 0 ? "BOUNCED" : strike ? "STRIKE" : "BALL"
		moved = show_ghost ? "Magnus moved it $(round(dz, digits=1) + 0.0) in up, $(round(dx, digits=1) + 0.0) in right" : ""
		HTML(string(
			"<svg viewBox='0 0 520 650' style='width:100%;max-width:520px;background:#0f141b;border-radius:12px;font-family:system-ui,sans-serif'>",
			"<text x='16' y='28' fill='#cfd6df' font-size='16'>Catcher's view</text>",
			"<text x='16' y='50' fill='#8b95a3' font-size='13'>forces on: $(isempty(forces) ? "none" : forces)</text>",
			use_buoy ? "<text x='16' y='70' fill='#7ee081' font-size='13'>buoyancy moved it $(round((hit.z - nob.z) * 12, digits=3)) in up</text>" : "",
			"<g stroke='#f5c542' stroke-width='2'><line x1='$(X(ax)-9)' y1='$(Y(az))' x2='$(X(ax)+9)' y2='$(Y(az))'/><line x1='$(X(ax))' y1='$(Y(az)-9)' x2='$(X(ax))' y2='$(Y(az)+9)'/></g>",
			"<text x='$(X(ax) - 14)' y='$(Y(az) + 4)' fill='#f5c542' font-size='12' text-anchor='end'>aimed here</text>",
			"<polygon points='$(X(-hw)),$(Y(0.30)) $(X(hw)),$(Y(0.30)) $(X(hw)),$(Y(0.18)) $(X(0)),$(Y(0.05)) $(X(-hw)),$(Y(0.18))' fill='#e8e8e8'/>",
			"<rect x='$(X(-hw))' y='$(Y(zhi))' width='$(200hw)' height='$(100(zhi-zlo))' fill='rgba(255,255,255,0.04)' stroke='#e8e8e8' stroke-width='2.5'/>",
			"<g stroke='rgba(255,255,255,0.25)' stroke-width='1'>$grid</g>",
			ghost,
			"<circle cx='$(X(hit.x))' cy='$(Y(hit.z))' r='$(100rb)' fill='#fbfbf5' stroke='#d33' stroke-width='2'/>",
			"<text x='16' y='622' fill='$(strike ? "#7ee081" : "#ff7b7b")' font-size='20' font-weight='700'>$verdict</text>",
			"<text x='504' y='598' fill='#cfd6df' font-size='13' text-anchor='end'>spin axis $(spin_dir)° (tilt $(clock)) · flight $(round(hit.t, digits=3)) s</text>",
			"<text x='504' y='620' fill='#5cc8ff' font-size='13' text-anchor='end'>$moved</text>",
			"</svg>"))
	end
end

# ╔═╡ e2adbf51-ebf6-47a8-9f5e-a89040edabf1
let
	# a 95 mph, 2300 rpm four-seam fastball at the release point (same constants as the pitch simulation)
	v, ω = 95 * mph, 2300 * 2π / 60
	A, V = π * r_ball^2, (4/3) * π * r_ball^3      # cross-sectional area, volume
	S = r_ball * ω / v                              # spin factor
	C_L = S / (0.4 + 2.32S)                         # lift coefficient
	W = m_ball * 9.81                               # weight
	forces = [
		("Drag",     0.5 * C_D * ρ_air * A * v^2, "opposite the velocity"),
		("Gravity",  W,                            "down"),
		("Magnus",   0.5 * C_L * ρ_air * A * v^2, "perpendicular to spin axis and velocity"),
		("Buoyancy", ρ_air * V * 9.81,             "up"),
	]
	rows = ["| **$n** | $(round(F, digits=4)) N | $(round(F / W, sigdigits=2)) × weight | $d |" for (n, F, d) in forces]
	Markdown.parse(join([
		"## Answer: drag is the biggest force on a fastball!",
		"Forces on a 95 mph, 2300 rpm four-seam fastball at the release point:",
		"",
		"| Force | Size | Compared with weight | Direction |",
		"|:--|--:|--:|:--|",
		rows...,
		"",
		"Drag is slightly *bigger* than gravity, Magnus is about 3/4 of the weight, and buoyancy is about 600× smaller than the weight.",
	], "\n"))
end

# ╔═╡ 59e9e83d-77cc-4f83-9740-3dcb0db0daec
let
	# ---- forces on a 95 mph, 2300 rpm fastball (spin axis 215°) at the release point ----
	# axes (same as the pitch simulation): x → catcher's right, y → toward the pitcher, z → up
	v0, rpm, θ_axis = 95 * mph, 2300, 215
	v̂ = AIM                                                  # direction of travel (toward home plate)
	ω̂ = [cosd(θ_axis), 0.0, sind(θ_axis)]                    # spin axis
	cr(a, b) = [a[2]b[3] - a[3]b[2], a[3]b[1] - a[1]b[3], a[1]b[2] - a[2]b[1]]
	A, V = π * r_ball^2, (4/3) * π * r_ball^3
	S = r_ball * (rpm * 2π / 60) / v0
	C_L = S / (0.4 + 2.32S)
	F_g = [0, 0, -m_ball * 9.81]                              # gravity: down
	F_b = [0, 0, ρ_air * V * 9.81]                            # buoyancy: up
	F_d = -0.5 * C_D * ρ_air * A * v0^2 .* v̂                  # drag: opposite the velocity
	F_M = 0.5 * C_L * ρ_air * A * v0^2 .* cr(ω̂, v̂)           # Magnus: ω̂ × v̂ (right-hand rule)

	vec(v) = "[" * join(round.(v; digits=5), ",") * "]"
	arrows = join([
		"{name:'Gravity',  F:$(vec(F_g)), color:'#f5c542'}",
		"{name:'Drag',     F:$(vec(F_d)), color:'#ff7b7b'}",
		"{name:'Magnus',   F:$(vec(F_M)), color:'#5cc8ff'}",
		"{name:'Buoyancy', F:$(vec(F_b)), color:'#7ee081'}"], ",")

	HTML("<script>\nconst arrows = [" * arrows * "]\nconst vhat = " * vec(v̂) * "\nconst what = " * vec(ω̂) * "\n" * raw"""
const W = 900, H = 560, cx = W / 2, cy = H / 2 + 30, K = 120   // K = pixels per drawing unit
const Fmax = Math.max(...arrows.map(a => Math.hypot(...a.F)))
const canvas = document.createElement("canvas")
canvas.width = 2 * W; canvas.height = 2 * H
canvas.style.cssText = "width:100%; display:block; border-radius:12px; background:#0f141b; cursor:grab; touch-action:none"
const ctx = canvas.getContext("2d")
let yaw = -0.6, pitch = 0.35, auto = true, dragging = null

canvas.addEventListener("pointerdown", e => { dragging = [e.clientX, e.clientY, yaw, pitch]; auto = false; canvas.setPointerCapture(e.pointerId) })
canvas.addEventListener("pointermove", e => {
  if (!dragging) return
  yaw = dragging[2] + (e.clientX - dragging[0]) * 0.01
  pitch = Math.max(-1.4, Math.min(1.4, dragging[3] + (e.clientY - dragging[1]) * 0.01))
})
canvas.addEventListener("pointerup", () => { dragging = null })

// 3D → 2D (simple orthographic camera that you can rotate)
function proj([x, y, z]) {
  const x1 = x * Math.cos(yaw) - y * Math.sin(yaw), y1 = x * Math.sin(yaw) + y * Math.cos(yaw)
  return [cx + K * x1, cy - K * (z * Math.cos(pitch) - y1 * Math.sin(pitch))]
}
function line3(a, b, color, width, dash) {
  const [x0, y0] = proj(a), [x1, y1] = proj(b)
  ctx.setLineDash(dash || []); ctx.strokeStyle = color; ctx.lineWidth = width
  ctx.beginPath(); ctx.moveTo(x0, y0); ctx.lineTo(x1, y1); ctx.stroke(); ctx.setLineDash([])
}
function arrow3(a, b, color, width) {
  const [x0, y0] = proj(a), [x1, y1] = proj(b), ang = Math.atan2(y1 - y0, x1 - x0), head = 4.5 * width
  if (Math.hypot(x1 - x0, y1 - y0) < 2) return
  ctx.strokeStyle = ctx.fillStyle = color; ctx.lineWidth = width; ctx.lineCap = "round"
  ctx.beginPath(); ctx.moveTo(x0, y0); ctx.lineTo(x1 - 0.8 * head * Math.cos(ang), y1 - 0.8 * head * Math.sin(ang)); ctx.stroke()
  ctx.beginPath(); ctx.moveTo(x1, y1)
  ctx.lineTo(x1 - head * Math.cos(ang - 0.45), y1 - head * Math.sin(ang - 0.45))
  ctx.lineTo(x1 - head * Math.cos(ang + 0.45), y1 - head * Math.sin(ang + 0.45))
  ctx.closePath(); ctx.fill()
}
function text3(p, s, color, dx = 8, dy = -8) {
  const [x, y] = proj(p); ctx.fillStyle = color; ctx.fillText(s, x + dx, y + dy)
}

let raf
function frame() {
  if (auto) yaw += 0.004
  ctx.setTransform(2, 0, 0, 2, 0, 0)
  ctx.fillStyle = "#0f141b"; ctx.fillRect(0, 0, W, H)
  ctx.font = "14px system-ui, sans-serif"; ctx.textAlign = "left"

  // axes
  const L = 2.05
  for (const [d, lab] of [[[1,0,0], "x (catcher's right)"], [[0,1,0], "y (toward pitcher)"], [[0,0,1], "z (up)"]]) {
    line3(d.map(c => -L * c), d.map(c => L * c), "rgba(255,255,255,0.18)", 1)
    text3(d.map(c => L * c), lab, "rgba(255,255,255,0.45)", 4, -4)
  }
  // velocity and spin axis (dashed, for reference)
  line3([0,0,0], vhat.map(c => 2.0 * c), "rgba(255,255,255,0.7)", 2, [6, 5])
  text3(vhat.map(c => 2.0 * c), "velocity", "rgba(255,255,255,0.8)")
  line3(what.map(c => -1.1 * c), what.map(c => 1.1 * c), "rgba(200,160,255,0.8)", 2, [3, 4])
  text3(what.map(c => 1.1 * c), "spin axis", "rgba(200,160,255,0.9)")

  // the ball
  const [bx, by] = proj([0, 0, 0]), br = 0.28 * K
  const g = ctx.createRadialGradient(bx - 0.35 * br, by - 0.4 * br, 0.1 * br, bx, by, br)
  g.addColorStop(0, "#ffffff"); g.addColorStop(1, "#a9a79d")
  ctx.fillStyle = g; ctx.beginPath(); ctx.arc(bx, by, br, 0, 2 * Math.PI); ctx.fill()

  // force arrows, length proportional to size, starting at the ball's centre
  ctx.font = "600 15px system-ui, sans-serif"
  for (const a of arrows) {
    const n = Math.hypot(...a.F), tip = a.F.map(c => 2.0 * c / Fmax)
    arrow3([0, 0, 0], tip, a.color, 5)
    const label = a.name + "  " + n.toFixed(n < 0.01 ? 4 : 2) + " N" + (n / Fmax < 0.05 ? "  (too small to see!)" : "")
    text3(n / Fmax < 0.05 ? [0, 0, 0.35] : tip, label, a.color, 10, n / Fmax < 0.05 ? -14 : -6)
  }
  ctx.font = "16px system-ui, sans-serif"; ctx.fillStyle = "#cfd6df"
  ctx.fillText("Free-body diagram: 95 mph, 2300 rpm fastball at release", 16, 30)
  ctx.font = "13px system-ui, sans-serif"; ctx.fillStyle = "rgba(255,255,255,0.45)"
  ctx.fillText("drag to rotate · arrow length ∝ force", 16, 52)
  raf = requestAnimationFrame(frame)
}
raf = requestAnimationFrame(frame)
invalidation.then(() => cancelAnimationFrame(raf))
return canvas
</script>
""")
end

# ╔═╡ 448ca182-c74b-4977-b2d5-2ed7ed15a91a
let p = ismissing(pitch_params) ? Dict("v"=>92, "rpm"=>2300, "dir"=>180, "g"=>false, "buoy"=>false, "drag"=>false, "magnus"=>false) : pitch_params
	pitch_view(p["v"], p["rpm"], p["dir"], p["g"], p["drag"], p["magnus"], p["buoy"])
end

# ╔═╡ e17d5895-ecf8-4a1b-8108-bd9ea21884b2
let
	# same pitch as the simulation: 92 mph, thrown along the fixed aim line
	v0 = 92 * mph
	L  = (release[2] - plate_y) / abs(AIM[2])          # distance travelled to the plate (m)
	k  = K * C_D                                        # drag constant: dv/dt = -k v²   (1/m)
	t0 = L / v0                                         # flight time without drag
	t1 = (exp(k * L) - 1) / (k * v0)                    # flight time with drag
	v1 = v0 / (1 + k * v0 * t1)                         # speed at the plate with drag
	d0, d1 = 0.5 * 9.81 * t0^2, 0.5 * 9.81 * t1^2       # gravity drop (m)
	sim0 = fly(v0, 0, 180, AIM; buoy=false, drag=false, magnus=false).z   # full simulation, for comparison (ft)
	sim1 = fly(v0, 0, 180, AIM; buoy=false, drag=true,  magnus=false).z
	# Magnus lift (2300 rpm backspin) from the full simulation: landing height with Magnus minus without it
	zM(drag) = fly(v0, 2300, 180, AIM; buoy=false, g=false, drag=drag).z - fly(v0, 2300, 180, AIM; buoy=false, g=false, drag=drag, magnus=false).z
	M0, M1 = zM(false) * 12, zM(true) * 12            # inches
	# Magnus by hand: a_M = K C_L v², and v(t) = v₀/(1 + b t) with b = k v₀ (holding C_L fixed)
	b  = k * v0
	S  = r_ball * (2300 * 2π / 60) / v0
	aM = K * (S / (0.4 + 2.32S)) * v0^2                # Magnus acceleration at release (m/s²)
	Mnaive = 0.5 * aM * t1^2                           # wrong: pretend the force stays constant
	Mhand  = aM * (t1 / b - log(1 + b * t1) / b^2)     # right: the force weakens as the ball slows
	r(x, n=3) = round(x, digits=n)
	inch(m) = r(m / 0.0254, 1)
	md"""
	## Answer: drag only matters because it changes the flight time

	**1. Drag slows the ball down.** Along the path, Newton's 2nd law with drag alone is
	```math
	\frac{dv}{dt} = -k v^2, \qquad k = \frac{\rho\, C_D A}{2m}
	```
	Separate and integrate:
	```math
	\int_{v_0}^{v} \frac{dv'}{v'^2} = -k\int_0^t dt' \;\;\Longrightarrow\;\; v(t) = \frac{v_0}{1 + k v_0 t}
	```
	Integrate once more for the distance travelled, then solve for the time to cover the distance ``L`` to the plate:
	```math
	s(t) = \frac{1}{k}\ln\!\left(1 + k v_0 t\right) \;\;\Longrightarrow\;\; t_{\text{drag}} = \frac{e^{kL} - 1}{k\, v_0}
	```

	**2. Gravity and Magnus both get more time.** Gravity is *constant*, so its drop grows with the square of the time:
	```math
	\Delta z_g = \tfrac12 g t^2
	```
	Magnus is *not* constant. It scales with ``v^2``, so it weakens as drag slows the ball. With ``b = k v_0``:
	```math
	a_M(t) = \frac{a_{M,0}}{(1 + b t)^2} \;\;\Longrightarrow\;\; \Delta z_M = \int_0^t\!\!\int_0^{t'} a_M\, dt''\, dt' = a_{M,0}\left[\frac{t}{b} - \frac{\ln(1 + b t)}{b^2}\right]
	```
	Using ``\tfrac12 a t^2`` for Magnus would predict $(inch(Mnaive)) in, too much. The integral gives $(inch(Mhand)) in, close to the simulation's $(r(M1, 1)) in.

	**3. The numbers** (92 mph, 2300 rpm backspin, ``L`` = $(r(L, 2)) m, ``k`` = $(r(k, 5)) m⁻¹):

	| | Flight time | Speed at plate | Gravity drop | Magnus rise |
	|:--|--:|--:|--:|--:|
	| no drag | $(r(t0, 4)) s | $(r(v0 / mph, 1)) mph | $(inch(d0)) in | $(r(M0, 1)) in |
	| with drag | $(r(t1, 4)) s | $(r(v1 / mph, 1)) mph | $(inch(d1)) in | $(r(M1, 1)) in |
	| **difference** | **+$(r(t1 - t0, 4)) s** ($(r(100(t1/t0 - 1), 1))%) | | **+$(inch(d1 - d0)) in** ($(r(100((t1/t0)^2 - 1), 1))%) | **+$(r(M1 - M0, 1)) in** ($(r(100(M1/M0 - 1), 1))%) |

	- **Gravity:** full simulation says drag adds **$(r((sim0 - sim1) * 12, 1)) in** of drop, about 1 in less than our estimate. Drag also slightly slows the ball's *falling* motion; that's only ~3% of the total drop, but a third of the small difference.
	- **Magnus** (from the simulation): the extra time *helps*, but the slower ball feels a weaker Magnus force (``F_M \propto v^2``). The two nearly cancel.

	> **Key intuition:** drag is parallel to the velocity, so it can't turn the ball; it only slows it. A force has to be *perpendicular* to the velocity to change where the pitch goes. Drag's only effect on location is giving gravity (and Magnus) more time to act.
	"""
end

# ╔═╡ a14f48a4-3241-4f3b-a577-f07ef806f442
md"""
## 🤔 Why do curveballs curve less in Denver?
"""

# ╔═╡ 1d15e7d4-7b6e-444d-96fe-d9591f3fd765
let
	# same pitch physics as the simulation, but with the air density as an input
	function flight(ρ, v_mph, rpm, θ; magnus=true, dt=2e-4)
		Kρ = ρ * π * r_ball^2 / (2m_ball)
		ω, ω̂ = rpm * 2π / 60, spin_axis(θ)
		p, v, t = copy(release), v_mph * mph .* AIM, 0.0
		while p[2] > plate_y
			s = hypot(v...)
			S = r_ball * ω / s
			a = [0, 0, -9.81] .- Kρ * C_D * s .* v .+ magnus * Kρ * (S / (0.4 + 2.32S)) * s^2 .* cross3(ω̂, v ./ s)
			v = v .+ a .* dt;  p = p .+ v .* dt;  t += dt
		end
		(p = p ./ 0.0254, v = hypot(v...) / mph, t = t)   # position (in), speed at plate (mph), time (s)
	end
	landing(args...; kw...) = flight(args...; kw...).p
	# how far spin moves the pitch (straight-line distance at the plate, with vs without Magnus)
	moved(ρ, args...) = hypot((landing(ρ, args...) .- landing(ρ, args...; magnus=false))...)
	ρ_sea, ρ_den = ρ_air, 0.85 * ρ_air                # Coors Field (5,200 ft): air about 15% thinner
	pitches = [("4-seam fastball", 95, 2300, 215), ("Curveball", 80, 2550, 25)]
	curve_loss = moved(ρ_sea, 80, 2550, 25) - moved(ρ_den, 80, 2550, 25)
	rows = map(pitches) do (name, v, rpm, θ)
		a, b = moved(ρ_sea, v, rpm, θ), moved(ρ_den, v, rpm, θ)
		"| $name | $(round(a, digits=1)) in | $(round(b, digits=1)) in | **$(round(b - a, digits=1)) in** ($(round(Int, 100(b/a - 1)))%) |"
	end
	# drag: thinner air -> less drag -> faster at the plate -> less time for gravity
	drag_rows = map(pitches) do (name, v, rpm, θ)
		a, b = flight(ρ_sea, v, 0, 180), flight(ρ_den, v, 0, 180)
		"| $name | $(round(a.v, digits=1)) → $(round(b.v, digits=1)) mph | $(round(a.t, digits=3)) → $(round(b.t, digits=3)) s | **$(round(b.p[3] - a.p[3], digits=1)) in higher** |"
	end
	Markdown.parse(join([
		"## 🏔️ Why do curveballs curve less in Denver?",
		"",
		"> 🤔 **Predict:** Coors Field is a mile above sea level, where the air is about 15% thinner. Will a curveball break *more* or *less* there? By how much?",
		"",
		"Both drag and Magnus are proportional to the air density ``\\rho``:  ``F_M = \\tfrac12 C_L \\rho A v^2``. Thinner air means a weaker Magnus force, so the same spin moves the ball less.",
		"",
		"| Pitch | Movement from spin, sea level | Movement from spin, Denver | Change |",
		"|:--|--:|--:|--:|",
		rows...,
		"",
		"**Drag drops by 15% too**, so the ball arrives faster and spends less time falling:",
		"",
		"| Pitch | Speed at plate (sea level → Denver) | Flight time | Effect on location |",
		"|:--|--:|--:|--:|",
		drag_rows...,
		"",
		"Even a 15% change in the *biggest* force moves the pitch less than half an inch, while the same change in Magnus moves it about 4 inches. Drag changes speed, not direction.",
		"",
		"**Conclusion:** the same curveball breaks about **$(round(Int, curve_loss)) inches less** in Denver. That's about 15% less, matching the 15% thinner air, and it's why breaking balls look flatter at Coors Field.",
	], "\n"))
end

# ╔═╡ 013402ff-35e2-4b8d-bc53-01f52cf9d1ab

md"""
## ⚾ Does Thinner Air Make Pitches Easier to Hit?

**Our prediction:** Less air density → Less Magnus force → Less pitch movement → Potentially fewer swings and misses.

### What Does the MLB Data Show?

At Coors Field in Denver (2021–2023):

- **Fastball whiff rate: 16.5%** — Lowest among MLB stadiums.
- **Off-speed whiff rate: 27.5%** — Second-lowest among MLB stadiums.

Additionally, Statcast's 2024–2026 strikeout park factor for Coors Field is **90**, which can be interpreted as approximately **10% fewer strikeouts** than a neutral park.

### 💡 Takeaway

Our physics model predicts weaker pitch movement in thinner air, and real-world data shows Denver is a relatively difficult environment for generating swings and misses.

**Important:** This is consistent with our hypothesis, but doesn't prove causation. Pitcher quality, hitter quality, and other park conditions also affect these statistics.

*Sources: [Pitcher List (2024)](https://pitcherlist.com/which-parks-generate-the-most-whiffs/) · [MLB Statcast Park Factors](https://baseballsavant.mlb.com/leaderboard/statcast-park-factors)*
"""


# ╔═╡ dae5b3f0-b7df-4ddd-bc36-62cf4206e646
md"""
## ⏱️ Why does the ball "break late"?

> 🤔 **Predict:** halfway to the plate, how much of its total break has a fastball already done?

A pitch leaves the hand moving in a straight line. Gravity and Magnus give it a roughly constant sideways acceleration, so its sideways *speed* grows like ``t`` and its *deviation* from that straight line grows like ``t^2``:

```math
\Delta(t) \approx \tfrac12 a t^2 \quad\Longrightarrow\quad \frac{\Delta(T/2)}{\Delta(T)} = \left(\tfrac12\right)^2 = \tfrac14
```

So only **¼ of the break happens in the first half** of the flight, and **¾ in the second half**.

**Tunneling:** the difference between two pitches *also* grows like ``t^2``. A hitter has to commit to a swing about 0.2 s before the ball arrives, when it's roughly 25 ft away. So a pitcher can make a fastball and a curveball look **identical at the commit point**, and they only split apart after the hitter has decided.
"""

# ╔═╡ 64ce53ef-78eb-4a16-8ee1-84f311ffeb78
let
	# ---- fly a pitch with all forces, recording its path (same physics as the simulation) ----
	function path(v_mph, rpm, θ, aim; dt=2e-4)
		ω, ω̂ = rpm * 2π / 60, spin_axis(θ)
		p, v, t = copy(release), v_mph * mph .* aim, 0.0
		P, T = [copy(p)], [0.0]
		while p[2] > plate_y
			s = hypot(v...);  S = r_ball * ω / s
			a = [0, 0, -9.81 + a_buoy] .- K * C_D * s .* v .+ K * (S / (0.4 + 2.32S)) * s^2 .* cross3(ω̂, v ./ s)
			v = v .+ a .* dt;  p = p .+ v .* dt;  t += dt
			push!(P, copy(p));  push!(T, t)
		end
		P, T
	end
	# aim a pitch so it passes through `target` (x, z in ft) when it reaches distance y from home
	function aim_through(v_mph, rpm, θ, y, target)
		pt, d = copy(target), [0.0, -1.0, 0.0]
		for _ in 1:30
			dv = [pt[1] * ft, y, pt[2] * ft] .- release;  d = dv ./ hypot(dv...)
			P, _ = path(v_mph, rpm, θ, d)
			q = P[findfirst(p -> p[2] ≤ y, P)]
			pt .+= target .- [q[1], q[3]] ./ ft
		end
		d
	end
	y_commit = plate_y + 25ft                     # the hitter must commit ≈ 25 ft out (≈ 0.2 s left)
	aim_fb = aim_through(95, 2300, 215, plate_y, [0.0, 3.0])       # fastball: top of the zone
	Pf, Tf = path(95, 2300, 215, aim_fb)
	q = Pf[findfirst(p -> p[2] ≤ y_commit, Pf)]
	# tunnel: the curveball is aimed to be in the SAME spot as the fastball at the commit point
	aim_cb = aim_through(80, 2550, 25, y_commit, [q[1], q[3]] ./ ft)
	Pc, Tc = path(80, 2550, 25, aim_cb)

	at(P, y) = P[findfirst(p -> p[2] ≤ y, P)]
	sep(y) = hypot((at(Pf, y) .- at(Pc, y))...) / 0.0254        # distance between the pitches (in)
	s_commit, s_plate = sep(y_commit), hypot((Pf[end] .- Pc[end])...) / 0.0254

	# ---- drawing ----
	dist(p) = (release[2] - p[2]) / ft                           # feet from release
	L = dist(Pf[end])
	X(d) = 40 + 470 * d / L;  Y(z) = 330 - 42 * z / ft           # side view
	pts(P) = join(["$(round(X(dist(p)), digits=1)),$(round(Y(p[3]), digits=1))" for p in P[1:20:end]], " ")
	xc = X(dist([0, y_commit, 0]))
	r1(x) = round(x, digits=1)
	HTML(string(
		"<svg viewBox='0 0 620 400' style='width:100%;max-width:720px;background:#0f141b;border-radius:12px;font-family:system-ui,sans-serif'>",
		"<text x='40' y='30' fill='#cfd6df' font-size='16'>Side view: a fastball and a curveball that tunnel</text>",
		"<line x1='$(X(0))' y1='$(Y(0))' x2='$(X(L))' y2='$(Y(0))' stroke='#3a4350'/>",
		"<rect x='$(X(L) - 4)' y='$(Y(3.5ft))' width='8' height='$(Y(1.6ft) - Y(3.5ft))' fill='rgba(255,255,255,0.15)' stroke='#e8e8e8'/>",
		"<text x='$(X(L))' y='$(Y(0) + 18)' fill='#8b95a3' font-size='12' text-anchor='middle'>plate</text>",
		"<text x='$(X(0))' y='$(Y(0) + 18)' fill='#8b95a3' font-size='12'>release</text>",
		"<rect x='$xc' y='45' width='$(X(L) - xc)' height='$(Y(0) - 45)' fill='rgba(255,92,92,0.08)'/>",
		"<line x1='$xc' y1='45' x2='$xc' y2='$(Y(0))' stroke='#ff7b7b' stroke-dasharray='5 4'/>",
		"<text x='$(xc - 6)' y='60' fill='#ff9b9b' font-size='12' text-anchor='end'>hitter must commit</text>",
		"<text x='$(xc - 6)' y='75' fill='#ff9b9b' font-size='12' text-anchor='end'>(≈ 0.2 s left)</text>",
		"<polyline points='$(pts(Pf))' fill='none' stroke='#5cc8ff' stroke-width='3'/>",
		"<polyline points='$(pts(Pc))' fill='none' stroke='#f5a742' stroke-width='3'/>",
		"<text x='$(X(L) - 14)' y='$(Y(Pf[end][3]) - 12)' fill='#5cc8ff' font-size='13' text-anchor='end'>fastball</text>",
		"<text x='$(X(L) - 10)' y='$(Y(Pc[end][3]) + 20)' fill='#f5a742' font-size='13' text-anchor='end'>curveball</text>",
		"<circle cx='$xc' cy='$(Y(at(Pf, y_commit)[3]))' r='5' fill='#ffffff'/><text x='$(xc + 8)' y='$(Y(at(Pf, y_commit)[3]) - 12)' fill='#ffffff' font-size='13'>same spot ($(r1(s_commit)) in apart)</text>",
		"<text x='$(X(L) + 12)' y='$(Y((Pf[end][3] + Pc[end][3]) / 2))' fill='#ffffff' font-size='13'>$(round(Int, s_plate)) in apart</text>",
		"<text x='40' y='385' fill='#8b95a3' font-size='11'>height exaggerated about 5× · all forces on</text>",
		"</svg>"))
end

# ╔═╡ 0912a4a7-5e3c-4c7a-894c-d823e9e4dc2f
md"""
## 🌀 Spin efficiency: not all spin is useful spin

> 🤔 **Predict:** two sliders spin at the *same* 2450 rpm. Can one move much more than the other?

The Magnus force comes from a cross product:
```math
\vec F_M \propto \vec\omega \times \vec v, \qquad |\vec\omega \times \vec v| = \omega\, v \sin\alpha
```
where ``\alpha`` is the angle between the spin axis and the direction of travel. Split the spin into two parts:
- **``\omega_\perp = \omega\sin\alpha``** (perpendicular to the velocity) bends the airflow and **makes the Magnus force**.
- **``\omega_\parallel = \omega\cos\alpha``** ("gyro" spin, along the velocity) spins the ball and **does nothing**.

```math
\text{spin efficiency} = \frac{\omega_\perp}{\omega} = \sin\alpha
```

So the spin rate on a broadcast doesn't tell you how much a pitch will move. You need the spin rate **and** the direction of the spin axis.
"""

# ╔═╡ 0e5cf87a-18cf-4fce-9ea8-15c6100b9884
HTML(raw"""
<div>
<canvas></canvas>
<div style="display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin-top:10px; font-family:system-ui,sans-serif; font-size:15px">
  <b>Angle between spin axis and velocity, α:</b>
  <input type="range" min="0" max="90" step="1" value="35" style="width:220px"> <span class="val"></span>
  <span style="margin-left:10px">Presets:</span>
    <button data-a="17" style="margin-left:10px">typical slider (≈30%)</button>
</div>
<script>
const root = currentScript.parentElement
const canvas = root.querySelector("canvas"), slider = root.querySelector("input"), val = root.querySelector(".val")
root.querySelectorAll("button").forEach(b => {
  b.style.cssText = "padding:4px 10px; border-radius:6px; border:1px solid #888; cursor:pointer"
  b.onclick = () => { slider.value = b.dataset.a; show() }
})
const W = 900, H = 520, cx = 430, cy = 300, K = 100
canvas.width = 2 * W; canvas.height = 2 * H
canvas.style.cssText = "width:100%; display:block; border-radius:12px; background:#0f141b; cursor:grab; touch-action:none"
const ctx = canvas.getContext("2d")

// world axes: x = direction of travel, y = sideways, z = up
let yaw = -0.75, pitch = 0.32, drag = null, phase = 0
canvas.addEventListener("pointerdown", e => { drag = [e.clientX, e.clientY, yaw, pitch]; canvas.setPointerCapture(e.pointerId) })
canvas.addEventListener("pointermove", e => { if (!drag) return
  yaw = drag[2] + (e.clientX - drag[0]) * 0.01
  pitch = Math.max(-1.3, Math.min(1.3, drag[3] + (e.clientY - drag[1]) * 0.01)) })
canvas.addEventListener("pointerup", () => { drag = null })

const proj = ([x, y, z]) => {
  const x1 = x * Math.cos(yaw) - y * Math.sin(yaw), y1 = x * Math.sin(yaw) + y * Math.cos(yaw)
  return [cx + K * x1, cy - K * (z * Math.cos(pitch) - y1 * Math.sin(pitch)), y1 * Math.cos(pitch) + z * Math.sin(pitch)]  // [sx, sy, depth (+ = away)]
}
const add = (a, b) => a.map((c, i) => c + b[i]), mul = (a, s) => a.map(c => c * s)
const dot = (a, b) => a[0]*b[0] + a[1]*b[1] + a[2]*b[2]
const cross = (a, b) => [a[1]*b[2] - a[2]*b[1], a[2]*b[0] - a[0]*b[2], a[0]*b[1] - a[1]*b[0]]
// rotate point p about unit axis k by angle t (Rodrigues)
const rot = (p, k, t) => add(add(mul(p, Math.cos(t)), mul(cross(k, p), Math.sin(t))), mul(k, dot(k, p) * (1 - Math.cos(t))))
const hidden = p => { const [sx, sy, d] = proj(p); return Math.hypot(...p) < 0.999 || (d > 0 && Math.hypot(sx - cx, sy - cy) < K) }

// a baseball-like seam on the unit sphere
const a = 0.7, b = 0.3
const seam = Array.from({length: 400}, (_, i) => { const t = 2 * Math.PI * i / 400
  return [a * Math.cos(t) + b * Math.cos(3 * t), a * Math.sin(t) - b * Math.sin(3 * t), 2 * Math.sqrt(a * b) * Math.sin(2 * t)] })

function arrow(p0, p1, color, width, dash) {
  const [x0, y0] = proj(p0), [x1, y1] = proj(p1), ang = Math.atan2(y1 - y0, x1 - x0), h = 4 * width
  if (Math.hypot(x1 - x0, y1 - y0) < 3) return
  ctx.setLineDash(dash || []); ctx.strokeStyle = ctx.fillStyle = color; ctx.lineWidth = width; ctx.lineCap = "round"
  ctx.beginPath(); ctx.moveTo(x0, y0); ctx.lineTo(x1 - 0.8 * h * Math.cos(ang), y1 - 0.8 * h * Math.sin(ang)); ctx.stroke()
  ctx.setLineDash([]); ctx.beginPath(); ctx.moveTo(x1, y1)
  ctx.lineTo(x1 - h * Math.cos(ang - 0.45), y1 - h * Math.sin(ang - 0.45)); ctx.lineTo(x1 - h * Math.cos(ang + 0.45), y1 - h * Math.sin(ang + 0.45))
  ctx.closePath(); ctx.fill()
}
function label(p, s, color, dx = 8, dy = -6) { const [x, y] = proj(p); ctx.fillStyle = color; ctx.fillText(s, x + dx, y + dy) }

function show() { val.textContent = slider.value + "°  →  spin efficiency = sin α = " + Math.round(100 * Math.sin(slider.value * Math.PI / 180)) + "%" }
show()
slider.addEventListener("input", show)

let last = performance.now(), raf
function frame(now) {
  const dt = Math.min(0.05, (now - last) / 1000); last = now
  phase += 2 * Math.PI * 0.6 * dt                         // the ball spins at 0.6 rev/s (slowed way down)
  const al = slider.value * Math.PI / 180, eff = Math.sin(al)
  const v = [1, 0, 0]                                       // direction of travel
  const w = [Math.cos(al), 0, Math.sin(al)]                 // spin axis: tilted α away from the velocity
  const Fm = cross(w, v)                                    // Magnus direction (length = sin α)

  ctx.setTransform(2, 0, 0, 2, 0, 0)
  ctx.fillStyle = "#0f141b"; ctx.fillRect(0, 0, W, H)
  ctx.font = "14px system-ui, sans-serif"; ctx.textAlign = "left"

  // seam points behind the ball (faint), then the ball, then the visible seam
  const pts = seam.map(p => rot(p, w, phase))
  ctx.fillStyle = "rgba(201,48,44,0.25)"
  for (const p of pts) if (hidden(p)) { const [x, y] = proj(p); ctx.fillRect(x - 1, y - 1, 2, 2) }
  const g = ctx.createRadialGradient(cx - 0.35 * K, cy - 0.4 * K, 0.1 * K, cx, cy, K)
  g.addColorStop(0, "rgba(255,255,255,0.97)"); g.addColorStop(1, "rgba(170,168,158,0.97)")
  ctx.fillStyle = g; ctx.beginPath(); ctx.arc(cx, cy, K, 0, 2 * Math.PI); ctx.fill()
  ctx.strokeStyle = "#c9302c"; ctx.lineWidth = 3; ctx.beginPath()
  pts.forEach((p, i) => { const q = pts[(i + 1) % pts.length]
    if (!hidden(p) && !hidden(q)) { const [x0, y0] = proj(p), [x1, y1] = proj(q); ctx.moveTo(x0, y0); ctx.lineTo(x1, y1) } })
  ctx.stroke()

  // the spin axis: a rod through the ball, plus a ring showing the direction of spin
  ctx.strokeStyle = "#c8a0ff"; ctx.lineWidth = 4; ctx.beginPath()
  for (let s = -1.9; s < 1.9; s += 0.02) { const p = mul(w, s), q = mul(w, s + 0.02)
    if (!hidden(p) && !hidden(q)) { const [x0, y0] = proj(p), [x1, y1] = proj(q); ctx.moveTo(x0, y0); ctx.lineTo(x1, y1) } }
  ctx.stroke()
  const e1 = Math.abs(w[2]) < 0.9 ? [0, 0, 1] : [0, 1, 0], u1 = cross(w, e1), un = Math.hypot(...u1)
  const uu = mul(u1, 1 / un), vv = cross(w, uu)
  ctx.strokeStyle = "rgba(200,160,255,0.9)"; ctx.lineWidth = 2; ctx.beginPath()
  for (let t = 0; t < 1.6 * Math.PI; t += 0.05) {
    const p = add(mul(w, 1.55), add(mul(uu, 0.35 * Math.cos(t + phase)), mul(vv, 0.35 * Math.sin(t + phase))))
    const [x, y] = proj(p); t === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y) }
  ctx.stroke()
  label(mul(w, -1.95), "spin axis ω", "#c8a0ff", 8, 16)

  // velocity, the two parts of the spin, and the Magnus force
  arrow([0, 0, 0], [2.3, 0, 0], "#ffffff", 3)
  label([2.3, 0, 0], "velocity v", "#ffffff")
  arrow([0, 0, 0], [0, 0, 1.6 * eff], "#5cc8ff", 3, [7, 5])
  if (eff > 0.05) label([0, 0, 1.6 * eff], "ω⊥ = " + Math.round(100 * eff) + "%: makes Magnus", "#5cc8ff", 10, 4)
  arrow([0, 0, 0], [1.6 * Math.cos(al), 0, 0], "#8b95a3", 3, [7, 5])
  ctx.font = "600 15px system-ui, sans-serif"
  arrow([0, 0, 0], mul(Fm, 2.0), "#ff7b7b", 6)
  if (eff > 0.05) label(mul(Fm, 2.0), "Magnus force", "#ff7b7b", 10, 18)
  else { ctx.textAlign = "center"; ctx.fillStyle = "#ff7b7b"; ctx.fillText("all gyro spin → no Magnus force!", cx, cy + K + 40); ctx.textAlign = "left" }

  ctx.font = "16px system-ui, sans-serif"; ctx.fillStyle = "#cfd6df"
  ctx.fillText("What the spin axis means", 16, 30)
  ctx.font = "13px system-ui, sans-serif"; ctx.fillStyle = "rgba(255,255,255,0.55)"
  ctx.fillText("The ball spins around the purple rod. Gray dashed = gyro part ω∥ (does nothing).", 16, 52)
  ctx.fillText("Drag to rotate the view. Spin slowed way down so you can see it.", 16, 70)
  raf = requestAnimationFrame(frame)
}
raf = requestAnimationFrame(frame)
invalidation.then(() => cancelAnimationFrame(raf))
</script>
</div>
""")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.13.1"
manifest_format = "2.1"
project_hash = "40c9f1cac973d64f8ca3ef3a09f769ff947e80f3"

[[deps.AbstractPlutoDingetjes]]
git-tree-sha1 = "e71ee7b4aa06b045259a7d6101e1cb45ad140bce"
registries = "General"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
registries = "General"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.5.5+2"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
registries = "General"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

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

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "1.0.0"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "Zstd_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.18.0+1"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl", "OpenSSL_jll", "Zlib_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.104+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.13.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
registries = "General"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2026.8.13"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.30+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.6+0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e189d0623e7ce9c37389bac17e80aac3b0302e75"
registries = "General"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.83"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
registries = "General"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "1.0.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
registries = "General"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

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

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["CompilerSupportLibraries_jll", "Libdl"]
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.67.1+0"

[registries.General]
url = "https://github.com/JuliaRegistries/General.git"
uuid = "23338594-aafe-5451-b93e-139f81909106"
"""

# ╔═╡ Cell order:
# ╟─efcb2bff-1471-458d-a3e6-309a79b22cf9
# ╟─7d5bca93-0ddb-45e8-baec-3034a39f41a4
# ╟─43cf8e7b-0f80-40eb-b8d3-cdeb57f996a8
# ╟─2a057a6c-bfd5-4b44-8d1a-714c9620e21a
# ╠═9053158a-872a-4e3c-b524-ee7ef24d15bd
# ╟─20f8fd5b-f792-47ae-8e18-ebabad3946d3
# ╟─6b16e580-08f5-484e-b143-4dd5f6d71a3b
# ╟─1b475654-c032-421b-a2b3-b0e92c6083d4
# ╟─3efd26d8-f29d-4ead-8079-23acd13b5dd9
# ╟─120860e2-1e87-4bee-a46e-cfe97ea369d1
# ╟─84417d7a-4817-401f-be10-056796b37ba8
# ╟─cc633591-cde8-4cd7-9912-753c4effe5b6
# ╟─e75aacc1-73d8-4b33-b414-2f169e348322
# ╟─e2adbf51-ebf6-47a8-9f5e-a89040edabf1
# ╟─59e9e83d-77cc-4f83-9740-3dcb0db0daec
# ╟─e1c53560-0d58-4fb0-a711-bba6bee3a6b2
# ╟─e3982fb0-0fee-4dc7-92a5-94a116bd9f35
# ╟─142ce579-36d6-49e4-9583-fafd58f3f4d9
# ╟─448ca182-c74b-4977-b2d5-2ed7ed15a91a
# ╟─2aa1c3ec-9f50-4b43-b965-89556ca2a980
# ╟─13223efd-8209-43a6-9848-ef2cbbc8fcd5
# ╟─e17d5895-ecf8-4a1b-8108-bd9ea21884b2
# ╠═a14f48a4-3241-4f3b-a577-f07ef806f442
# ╟─1d15e7d4-7b6e-444d-96fe-d9591f3fd765
# ╟─013402ff-35e2-4b8d-bc53-01f52cf9d1ab
# ╟─dae5b3f0-b7df-4ddd-bc36-62cf4206e646
# ╟─64ce53ef-78eb-4a16-8ee1-84f311ffeb78
# ╟─0912a4a7-5e3c-4c7a-894c-d823e9e4dc2f
# ╟─0e5cf87a-18cf-4fce-9ea8-15c6100b9884
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
