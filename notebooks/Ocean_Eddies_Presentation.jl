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

# ╔═╡ 747de03c-f4c4-47aa-b66d-542cf974dd72
begin
    using PlutoUI
    using Plots
    using Statistics
    using FFTW
    default(fontfamily="sans-serif", size=(940,380), linewidth=3,
        background_color=:white, foreground_color=:darkslategray,
        legendfontsize=10, guidefontsize=11, titlefontsize=13,
        left_margin=8 * Plots.mm, bottom_margin=8 * Plots.mm,
        right_margin=5 * Plots.mm, top_margin=5 * Plots.mm)
end

# ╔═╡ 0778c545-fb72-44e0-9d86-df34d735f7da
function presentation_details(title::AbstractString, content)
    escaped_title = replace(title, "&" => "&amp;", "<" => "&lt;", ">" => "&gt;", '"' => "&quot;")
    body = repr(MIME"text/html"(), content)
    return Base.HTML("<details><summary>" * escaped_title * "</summary><div>" * body * "</div></details>")
end

# ╔═╡ 5f6215c4-5656-4942-b88e-b28ca23a1733
HTML("""
<style>
main {max-width:1050px; padding-left:36px; padding-right:36px;}
pluto-output {font-size:17px; line-height:1.55;}
h1,h2,h3 {color:#123d52; letter-spacing:-0.025em;}
h1 {font-size:2.5em;} h2 {border-top:3px solid #40a9a1; padding-top:20px; margin-top:25px;}
blockquote {border-left:5px solid #e5a24c; background:#fff8ec; padding:12px 18px;}
details {background:#f2f7fa; border:1px solid #dce7ec; border-radius:8px; padding:10px 15px; margin:8px 0;}
summary {cursor:pointer; color:#245b70; font-weight:600;}
table {font-size:0.92em;}
</style>
""")

# ╔═╡ b38696a8-e07e-45fa-ae5e-42e06435f934
md"""
# How a balanced ocean makes eddies
### From hydrostatic balance to the Eady model to global circulation

**A 30-minute classroom story · 28 minutes + 2 minutes for questions**

> How can an ocean that is nearly balanced develop swirling eddies—and how can a computer represent those motions?

**Follow the story:** vertical balance → rotating currents → stored energy → growing disturbances → eddies → global models.

Move one control at a time. The main path is for presenting; blue expandable boxes hold derivations and extra context. All visuals are generated locally; no data downloads are required after packages install.
"""

# ╔═╡ 116cd075-e925-4ece-be24-6f4c665ace1a
TableOfContents(depth=2)

# ╔═╡ f7fa3664-2ed3-4f0b-9236-5b8640b1bcba
begin
    periodic_gaussian(x, center, width, L) = exp(-0.5*((mod(x-center+L/2,L)-L/2)/width)^2)
    function eady_factor(mu)
        mu <= 1e-7 && return 0.0
        a=mu/2
        sqrt(max(0.0,(a/tanh(a)-1)*(1-a*tanh(a))))
    end
    eady_rate(f,N,dU,H,ratio) = abs(f*dU)/(N*H)*eady_factor(2pi/ratio)
    function transport2d(n, speed, elapsed_days; L=200e3, snapshots=41)
        dx = L / n
        xy = collect((0:n-1) .* dx .+ dx/2)
        k = 2pi/L
        u = [speed * sin(k*(i*dx)) * cos(k*xy[j]) for j in 1:n, i in 1:n]
        v = [-speed * cos(k*xy[i]) * sin(k*(j*dx)) for j in 1:n, i in 1:n]
        q0 = [periodic_gaussian(xy[i],0.34L,0.065L,L) *
              periodic_gaussian(xy[j],0.30L,0.065L,L) for j in 1:n, i in 1:n]
        q = copy(q0)
        frames = [copy(q)]
        targets = collect(range(0, elapsed_days*86400; length=snapshots))
        # The sum of directional Courant numbers is <= 0.8.
        dtlimit = speed == 0 ? Inf : 0.40dx/abs(speed)
        steps = 0
        for frame in 2:snapshots
            interval = targets[frame]-targets[frame-1]
            count = interval == 0 || speed == 0 ? 0 : ceil(Int, interval/dtlimit)
            if count > 0
                dt = interval/count
                for step in 1:count
                    qright = circshift(q,(0,-1))
                    qup = circshift(q,(-1,0))
                    fx = max.(u,0) .* q .+ min.(u,0) .* qright
                    fy = max.(v,0) .* q .+ min.(v,0) .* qup
                    q = q .- (dt/dx) .* (fx .- circshift(fx,(0,1)) .+ fy .- circshift(fy,(1,0)))
                end
            end
            steps += count
            push!(frames,copy(q))
        end
        return (; xy, q0, frames, steps, dx,
            mass_error=abs(sum(q)-sum(q0))/sum(q0))
    end
end

# ╔═╡ 0ad0a43d-3576-43dc-b57d-9a89670b3e97
md"""
## 1 · Meet the moving ocean

A **current** is an organized flow of water. A **meander** is a bend in that flow. An **eddy** is a rotating feature that can transport water and its properties.

Large currents are not perfectly smooth. Their bends and eddies help redistribute heat, salt, and other substances. We will investigate one way these disturbances can grow: **baroclinic instability**.
"""

# ╔═╡ bc1e0bc1-e358-44e4-9d30-83084f832227
let
    x=range(0,600;length=500)
    y=95 .+ 23sin.(2pi .* x ./ 340) .+ 10sin.(2pi .* x ./ 170)
    p=plot(x,y;ribbon=8,color=:teal,fillalpha=0.18,label="Meandering current",
        xlabel="Along-current distance (illustrative km)",ylabel="Across-current distance (illustrative km)",
        xlims=(0,600),ylims=(0,200),title="An idealized view from above · schematic, not observations")
    t=range(0,2pi;length=150)
    plot!(p,200 .+ 28cos.(t),42 .+ 24sin.(t);color=:coral,label="Eddy")
    plot!(p,435 .+ 35cos.(t),155 .+ 27sin.(t);color=:coral,label=false)
    quiver!(p,[70.,305.,530.],[y[59],y[255],y[442]];quiver=([22.,22.,22.],[0.,0.,0.]),color=:teal,label=false)
    annotate!(p,435,155,text("rotating
water",10,:darkslategray))
    p
end

# ╔═╡ 1ec2f0b6-ac0d-484b-945f-8ca318073dd9
md"""
> **Today's question:** where does a growing disturbance get its energy?

To answer it, first ask what keeps the ocean close to balance.
"""

# ╔═╡ 679b8ba7-089b-4529-81d3-e88c5096b27d
md"""
## 2 · Why doesn't the ocean simply overturn?
**Vertical balance and stable layering**

Deeper water supports the water above it, so pressure increases downward. In **hydrostatic balance**, the vertical pressure-gradient force balances gravity:
```math
\frac{\partial p}{\partial z}=-\rho g.
```
Here **z** increases upward, **p** is pressure, **ρ** is density, and **g** is gravitational acceleration.

**Stratification** means density varies with depth. If lighter water lies above denser water, a parcel pushed upward finds itself denser than its new surroundings and is pulled back down.

**Predict:** will stronger layering make that return faster or slower?

Layering: $(@bind strat_choice Select(["Weak", "Strong"]; default="Weak"))
"""

# ╔═╡ 09f86ae9-8fa0-4eff-a6fe-0d197b948ca0
let
    N=strat_choice=="Weak" ? 0.005 : 0.010
    z=range(-100,0;length=150)
    p1=plot(1025*9.81 .* (-z) ./ 1e6,z;color=:royalblue,label=false,
        xlabel="Pressure above surface value (MPa)",ylabel="Height z (m)",
        title="Pressure supports the water above")
    ts=range(0,30;length=500)
    p2=plot(ts,15cos.(N .* ts .* 60);color=:teal,label=false,
        xlabel="Time after release (minutes)",ylabel="Parcel displacement (m)",
        title="$(strat_choice) layering · period $(round(2pi/N/60;digits=1)) min",ylims=(-18,18))
    hline!(p2,[0];color=:gray,linestyle=:dash,label=false)
    plot(p1,p2;layout=(1,2),size=(960,360))
end

# ╔═╡ 70eae89e-a832-483c-b105-12854db5b93a
md"""
> **Takeaway:** hydrostatic balance describes vertical forces; stable stratification describes the restoring response to displacement. They are related ideas, but they answer different questions.

The oscillator is an idealized parcel released from rest. Its small vertical acceleration is a departure from the resting background's hydrostatic balance. Next, turn from vertical forces to horizontal forces.
"""

# ╔═╡ 0e8fa6bd-002b-4fa0-bc86-b5d26fe57804
presentation_details("The mathematics · from pressure to a parcel oscillator", md"""
A submerged object has buoyancy force ``F_B = \rho_w g V`` and weight ``W = \rho_p g V``. Newton's law gives
```math
a_z=g\frac{\rho_w-\rho_p}{\rho_p}.
```
For a parcel displaced by a small distance ξ from its original level z₀, approximate the ambient density by
```math
\rho(z_0+\xi)\approx\rho(z_0)+\rho_z\xi.
```
The parcel keeps its original density in this incompressible cartoon. Replacing the denominator by a reference density ρ₀ gives
```math
\ddot\xi=\frac{g}{\rho_0}\rho_z\xi=-N^2\xi,
\qquad N^2=-\frac{g}{\rho_0}\rho_z.
```
Stable layering has ρz < 0, so N² > 0. With initial displacement ξ₀ and zero initial velocity,
```math
\xi(t)=\xi_0\cos(Nt),\qquad T=\frac{2\pi}{N}.
```
N is an angular frequency, measured in s⁻¹. At equilibrium the force is zero but the parcel can be moving fastest. The simple oscillator neglects drag, mixing, and the detailed motion of surrounding water. Real seawater stability calculations account for compressibility and the density change of a parcel moved adiabatically.
""")

# ╔═╡ d47f77ed-c3d1-475b-bd18-dc5818539e14
md"""
## 3 · Why can a rotating current maintain tilted layers?
**Geostrophic balance and vertical shear**

Horizontal pressure differences push water sideways. On a rotating Earth, moving water also experiences the **Coriolis effect**. For many large, slowly evolving currents away from the equator, these effects nearly balance: **geostrophic balance**.

```math
fu=-\frac{1}{\rho_0}\frac{\partial p}{\partial y}.
```
**u** is along-current velocity; **y** is across-current distance; **f** measures the local rotational effect. Water can keep flowing while the pressure difference persists.

When density differs across a current, the pressure difference changes with depth. The balanced current velocity must therefore change with depth too. This is **thermal-wind balance**; the velocity change is **vertical shear**.


"""

# ╔═╡ 6168311e-2e1b-4e51-b588-16357416727f
let
    p=plot(;xlims=(-1,1),ylims=(-1,1),axis=false,grid=false,legend=false,
        title="View from above · Northern Hemisphere")
    quiver!(p,[0.],[0.];quiver=([0.75],[0.]),color=:teal)
    quiver!(p,[0.],[0.];quiver=([0.],[0.65]),color=:coral)
    quiver!(p,[0.],[0.];quiver=([0.],[-0.65]),color=:royalblue)
    annotate!(p,0.57,-0.16,text("current u",12,:teal))
    annotate!(p,0.,0.84,text("pressure-gradient force",12,:coral))
    annotate!(p,0.,-0.84,text("Coriolis force",12,:royalblue))
    p
end

# ╔═╡ f2e8c323-7d7d-4565-bbb6-7948b5836383
md"""
Top-minus-bottom velocity difference ΔU (m/s): $(@bind front_shear Slider(0:0.05:0.4;default=0.2,show_value=true))
"""

# ╔═╡ 73a8ba60-4897-4177-804c-65968d9e8dae
let
    H=500.; N=0.01; f=1e-4; slope=f*front_shear/(N^2*H)
    y=range(-50e3,50e3;length=150); z=range(-H,0;length=100)
    p1=plot(;xlabel="Across-current distance (km)",ylabel="Height (m)",
        xlims=(-50,50),ylims=(-H,0),legend=false,title="Side view · surfaces of equal density")
    for level in -600:75:100
        plot!(p1,y ./ 1000,level .+ slope .* y;color=:teal)
    end
    p2=plot(front_shear .* (z ./ H .+ 0.5),z;color=:coral,label=false,
        xlabel="Along-current velocity (m/s)",ylabel="Height (m)",xlims=(-0.23,0.23),
        title="More shear ↔ steeper density surfaces")
    vline!(p2,[0.];color=:gray,linestyle=:dash,label=false)
    plot(p1,p2;layout=(1,2),size=(960,360))
end

# ╔═╡ cb7fa45d-e2ab-47c9-bdbb-00e48f208092
md"""
> **Takeaway:** tilted density layers and vertical shear are connected parts of a balanced rotating current.

Rotation organizes the motion; it supplies no energy directly. But does being balanced mean this current will resist a small bend?
"""

# ╔═╡ eb2f6a0b-369d-4240-acdf-43855adf051c
presentation_details("The mathematics · thermal wind follows from two balances", md"""
Differentiate geostrophic balance vertically, then use hydrostatic balance:
```math
f u_z=-\frac{1}{\rho_0}\partial_y(p_z)
=\frac{g}{\rho_0}\rho_y=-b_y,
\qquad b=-g\frac{\rho-\rho_0}{\rho_0}.
```
For uniform stratification and a constant density-surface slope s, choose
```math
b=N^2(z-sy),\quad u_z=\frac{\Delta U}{H}.
```
Then (b_y=-N^2s), giving
```math
s=\frac{f\Delta U}{N^2H}.
```
Here f = 10⁻⁴ s⁻¹, N = 0.010 s⁻¹, and H = 500 m are fixed. The velocity profile is (u(z)=\Delta U(z/H+1/2)), with zero depth mean. Thermal wind determines shear, not the arbitrary depth-independent velocity that could be added.

The Coriolis parameter is (f=2\Omega\sin\phi), where Ω is Earth's rotation rate and φ is latitude. Geostrophic approximations require small enough accelerations relative to Coriolis effects and fail near the equator in this form. Coriolis acceleration is perpendicular to velocity, so it does no direct work.
""")

# ╔═╡ 08ada2c7-14c1-4458-8860-9ec207c492ed
md"""
## 4 · Balanced does not mean stable
**9–12 minutes · Find the energy source**

**Balance** asks whether the main forces approximately cancel. **Stability** asks whether a small disturbance grows.

Light water can remain above dense water everywhere while the interface between them tilts. Flattening that arrangement lowers gravitational potential energy. A coordinated disturbance can draw on this **available potential energy**.

Fraction of tilt removed: $(@bind flattening Slider(0:0.1:1;default=0,show_value=true))
"""

# ╔═╡ ace2a491-b7a9-484f-8bf0-37626e1e3f3b
let
    W=100e3; H=1000.; rise=200.; drho=2.; g=9.81
    y=range(-W/2,W/2;length=200)
    initial=-H/2 .+ rise/W .* y
    current=-H/2 .+ (1-flattening)*rise/W .* y
    E=drho*g*(rise/W)^2*W^3/24
    p1=plot(y ./ 1000,current;fillrange=-H,fillalpha=0.24,color=:royalblue,label="Dense water",
        xlabel="Across-basin distance (km)",ylabel="Height (m)",ylims=(-H,0),title="Stable columns; energy in the tilt")
    plot!(p1,y ./ 1000,current;fillrange=0,fillalpha=0.13,color=:teal,label="Light water")
    plot!(p1,y ./ 1000,initial;color=:coral,linestyle=:dash,label="Initial interface")
    p2=bar(["Remaining","Released"],[100(1-flattening)^2,100(1-(1-flattening)^2)];
        color=[:teal,:coral],legend=false,ylims=(0,105),ylabel="Percent of initial available energy",
        title="Removing half the tilt releases 75%")
    plot(p1,p2;layout=(1,2),size=(960,360))
end

# ╔═╡ 3010a462-4065-4172-a26b-53d41da35555
md"""
> **Takeaway:** a current can be vertically stable and approximately balanced, yet contain energy that a growing disturbance can extract.

This slider prescribes a rearrangement and calculates its energy change. It does not prove that the fluid will make that rearrangement. **The Eady model tests whether suitable disturbances can actually grow.**
"""

# ╔═╡ 40c78695-a23d-429b-a9d1-22d07de1536f
presentation_details("The mathematics · why the energy depends on tilt squared", md"""
Let η(y) be interface displacement relative to a flat reference with the same layer volumes. Relative to that reference, lifting dense water into a region formerly occupied by light water adds
```math
\Delta E=\int_0^\eta\Delta\rho gz\,dz=\frac12\Delta\rho g\eta^2
```
per unit horizontal area. With η = sy, integrate across width W:
```math
E_A=\frac{\Delta\rho g}{2}\int_{-W/2}^{W/2}s^2y^2\,dy
=\frac{\Delta\rho gs^2W^3}{24}.
```
This is energy per meter of basin length. Here W = 100 km, H = 1000 m, Δρ = 2 kg/m³, and the initial interface rise is 200 m; initial available energy is 3.27 × 10⁹ J/m.

If a fraction r of the slope is removed, remaining energy is ((1-r)^2E_A). For r = 0.5, 25% remains and 75% is released. Reversing the slope leaves the energy unchanged.

The reference-state calculation is a two-layer cartoon, distinct from the continuously stratified Eady model. Not all released potential energy becomes a single eddy's kinetic energy.
""")

# ╔═╡ ee9fdb64-3060-49e1-ae03-e8268fa60803
md"""
## 5 · The ideal Eady experiment
**Which disturbances grow?**

We simplify the current to isolate one mechanism: a rotating fluid layer with stable stratification and a velocity that changes uniformly with depth. Add a tiny disturbance and ask whether it grows.

**Linear theory** follows disturbances while they are small enough that their interactions with each other can be neglected. It predicts the early stage of instability.
"""

# ╔═╡ add6faf6-a0cd-478e-b0f7-83ceb4f7d9c3
let
    p=plot(;xlims=(0,1),ylims=(-500,0),xlabel="Across-current position (schematic)",
        ylabel="Height (m)",legend=false,title="Eady setup · a sheared, stratified layer")
    for zz in -425:75:-75
        plot!(p,[0.08,0.92],[zz-20,zz+20];color=:teal,alpha=0.65)
    end
    hline!(p,[-500.,0.];color=:darkslategray,linewidth=4)
    annotate!(p,0.33,-65,text("u = +ΔU/2",10,:coral))
    annotate!(p,0.33,-250,text("u = 0",10,:coral))
    annotate!(p,0.33,-435,text("u = −ΔU/2",10,:coral))
    annotate!(p,0.73,-250,text("current flows\nperpendicular to\nthis cross-section",10,:coral))
    annotate!(p,0.75,-70,text("f, N constant",11,:darkslategray))
    annotate!(p,0.75,-425,text("depth H = 500 m",11,:darkslategray))
    p
end

# ╔═╡ 03d8e7bf-0f3d-4e83-8ef8-c8acf49344b7
presentation_details("Assumptions · what makes this model idealized", md"""
| Assumption | Meaning |
|:--|:--|
| Constant nonzero f | Ignore latitude variation within the local region |
| Constant N | Uniform strength of stratification |
| Constant vertical shear | Background velocity is linear in depth |
| Hydrostatic | Vertical pressure gradients approximately balance gravity |
| Quasigeostrophic | Motion stays close to geostrophic balance |
| Rigid horizontal top and bottom | No flow through either boundary |
| No friction | Omit damping and mixing |
| Small perturbations | Keep terms linear in disturbance amplitude |

There are no sidewalls in the along-current wave calculation used here. The plotted setup illustrates the background; it is not a solved perturbation field. The experiment uses f = 10⁻⁴ s⁻¹, N = 0.010 s⁻¹, and H = 500 m throughout.
""")

# ╔═╡ 7860ab27-8e60-4e8f-bd7e-1eff7029f8b0
md"""
### Prediction 1 · A growing disturbance amplifies itself
```math
A(t)=A_0e^{\sigma t},\qquad t_2=\frac{\ln 2}{\sigma}.
```
**A₀** is initial amplitude, **A(t)** is later amplitude, **σ** is growth rate, and **t₂** is doubling time. If the rate of growth is proportional to the amplitude already present, the result is exponential growth.

### Prediction 2 · More shear gives faster maximum growth
```math
\sigma_{\max}\approx0.31\frac{|f|}{N}\frac{|\Delta U|}{H}.
```
At fixed f, N, and H, doubling ΔU doubles the maximum growth rate. The factor 0.31 comes from solving and maximizing the ideal model's growth relation.

Eady velocity difference ΔU (m/s): $(@bind eady_shear Slider(0:0.05:0.4;default=0.2,show_value=true))

### Prediction 3 · Wavelength matters
Compare a short wave, a wave near the fastest-growing scale, and a longer wave.

Disturbance: $(@bind wave_choice Select(["Short · 75 km", "Near fastest · 195 km", "Long · 500 km"];default="Near fastest · 195 km"))

Time since the small disturbance began (days): $(@bind growth_day Slider(0:0.5:15;default=6.5,show_value=true))
"""

# ╔═╡ 8e59cfed-839e-4292-b2fc-555b2dde1f6a
begin
    wave_ratio=wave_choice=="Short · 75 km" ? 1.5 : wave_choice=="Near fastest · 195 km" ? 3.9 : 10.0
    growth_sigma=eady_rate(1e-4,0.01,eady_shear,500.,wave_ratio)
    growth_double=growth_sigma==0 ? Inf : log(2)/growth_sigma/86400
    growth_multiplier=exp(growth_sigma*growth_day*86400)
end

# ╔═╡ a57502b8-c0c8-4e97-91f8-cbe60c110881
let
    ratios=range(1,12;length=400)
    rates=[eady_rate(1e-4,0.01,eady_shear,500.,r)*86400 for r in ratios]
    p1=plot(ratios .* 50,rates;color=:teal,label="Growth rate",xlabel="Wavelength (km)",
        ylabel="Growth rate (day⁻¹)",title="Which wavelengths grow?",ylims=(0,0.23),legend=:topright)
    vline!(p1,[2pi/2.399*50];color=:gray,linestyle=:dash,label="Short-wave cutoff")
    scatter!(p1,[wave_ratio*50],[growth_sigma*86400];color=:coral,markersize=7,label="Selected wave")
    ts=range(0,15;length=200)
    p2=plot(ts,growth_sigma .* ts .* 86400 ./ log(2);color=:teal,label=false,
        xlabel="Time (days)",ylabel="Number of amplitude doublings",title="Early linear growth",ylims=(0,5))
    scatter!(p2,[growth_day],[log2(growth_multiplier)];color=:coral,markersize=7,label=false)
    plot(p1,p2;layout=(1,2),size=(980,370))
end

# ╔═╡ bf39123a-b70f-4c83-9c35-37c19c2ad4bd
md"""
**Selected wave:** $(round(wave_ratio*50;digits=0)) km · **Growth rate:** $(round(growth_sigma*86400;digits=3)) day⁻¹ · **Doubling time:** $(isfinite(growth_double) ? string(round(growth_double;digits=2)," days") : "no exponential growth").

After $(growth_day) days, the linear prediction is **$(round(growth_multiplier;digits=2))× the initial amplitude**. A neutral wave has zero exponential growth; it is not necessarily motionless or damped.
"""

# ╔═╡ efa06055-c2e5-4ac5-9958-1ddd11089abf
let
    x=range(0,2;length=400)
    p=plot(x,0.005sin.(2pi .* x);color=:gray,linestyle=:dash,label="Initial",
        xlabel="Along-current distance / wavelength",ylabel="Normalized sideways displacement",
        title="A growing bend · prescribed illustration, not an eddy simulation",ylims=(-0.14,0.14))
    plot!(p,x,0.005growth_multiplier .* sin.(2pi .* x);color=:teal,label="Selected time")
    p
end

# ╔═╡ c62e9e26-d245-470b-a9cf-7222989318a4
md"""
> **Takeaway:** Eady theory predicts the early growth rate and preferred scale of disturbances. It does not calculate the mature eddies that emerge after the current changes substantially.

The bend above is a sine wave with prescribed amplitude. $(0.005growth_multiplier>0.1 ? "Its normalized amplitude has passed the illustrative 0.1 guide: continued growth should be treated as a linear extrapolation." : "Its amplitude is still small in this drawing; actual linear validity depends on the full physical state.")

**Next question:** how can a growing bend develop into a rotating eddy, and what describes that circulation?
"""

# ╔═╡ d01bc0bf-110a-4e09-a2a1-e7bab6ab7d29
presentation_details("The mathematics · where the Eady relation comes from", md"""
Write a small wave disturbance as a vertical structure multiplied by a traveling wave:
```math
\psi'=\operatorname{Re}\{\Phi(z)e^{ik(x-ct)}\},\qquad k=2\pi/\lambda.
```
If c = cᵣ + icᵢ, the exponential contains a growth factor exp(kcᵢt), so σ = kcᵢ. In this along-current Eady problem, the unstable interior solution obeys
```math
\Phi''-(Nk/f)^2\Phi=0.
```
Its solutions are combinations of cosh and sinh. With mean velocity U(z) of constant shear, the rigid-boundary buoyancy conditions imply
```math
(U-c)\Phi'-U_z\Phi=0
```
at the top and bottom. Requiring a nonzero solution satisfying both boundaries determines the wave speed c and yields the dispersion relation.

Define the dimensionless wavenumber μ and the horizontal scale L*:
```math
L_* = NH/|f|,\qquad \mu=kL_* = 2\pi L_*/\lambda.
```
The growing branch is
```math
\sigma=\frac{|f\Delta U|}{NH}
\sqrt{\max\{0,[a\coth(a)-1][1-a\tanh(a)]\}},\qquad a=\mu/2.
```
Maximizing its dimensionless factor gives about 0.31 at μ ≈ 1.61. Thus λmax ≈ 3.9 L*. The short-wave cutoff is μ ≈ 2.399, or λ ≈ 2.62 L*. Longer waves grow, increasingly slowly as wavelength tends to infinity; this ideal problem has no finite long-wave cutoff.

Here L* = 50 km, λmax ≈ 195 km, and the cutoff is about 131 km. At ΔU = 0.20 m/s, the approximate maximum growth is 1.24 × 10⁻⁶ s⁻¹ and the doubling time is 6.47 days. The full relation gives a slightly different value because 0.31 is rounded.

Source: [Cambridge Fluid Dynamics of Climate notes, §8.4](https://www.damtp.cam.ac.uk/user/phh1/atmosocean/notes2019.pdf).
""")

# ╔═╡ a1bcbe71-ddea-4bdb-99da-52d467ddcd41
md"""
## 6 · How does a meander become an eddy?
** From growing waves to rotating structures**

An **eddy** is a rotating flow feature. A meander can grow without becoming a detached eddy; a detached **ring** is one possible outcome, not the definition of every eddy.

### Step 1 · The disturbance starts changing the current

In the Eady calculation, the disturbance is small and the background current stays fixed. Once the disturbance becomes large, it transports and rearranges the velocity and density patterns that govern its own motion. This feedback is **nonlinear**.

The bend can curl, stretch water into filaments, and develop recirculating regions. In some currents a loop separates into a ring, carrying water with different properties from its surroundings. The original current already has motion and shear; rotation and pressure help organize the resulting circulation.

Story stage: $(@bind eddy_stage Select(["1 · Small meander", "2 · Large looping meander", "3 · Separated ring"];default="1 · Small meander"))
"""

# ╔═╡ 8c432ac9-f468-4ad3-b5a7-ee29e0a34bb3
let
    p=plot(;xlims=(0,300),ylims=(-5,145),xlabel="Along-current position (schematic)",
        ylabel="Across-current position (schematic)",legend=false,size=(940,350),
        title="One possible route to a ring · drawn stages, not a dynamical simulation")
    x=range(0,300;length=300)
    if startswith(eddy_stage,"1")
        y=25 .+ 12 .* exp.(-((x .- 150) ./ 55).^2)
        plot!(p,x,y;color=:teal,linewidth=5)
        annotate!(p,150,90,text("A small bend grows by extracting\nenergy from the background",12,:darkslategray))
    elseif startswith(eddy_stage,"2")
        t=range(-pi/2-0.20,-pi/2-2pi+0.20;length=300)
        xx=vcat([0.,100.],150 .+ 45 .* cos.(t),[200.,300.])
        yy=vcat([20.,20.],70 .+ 45 .* sin.(t),[20.,20.])
        plot!(p,xx,yy;color=:teal,linewidth=5)
        annotate!(p,52,90,text("The flow now\nchanges its own\nbackground",11,:darkslategray))
        annotate!(p,250,65,text("Narrow neck;\nlarge deformation",11,:darkslategray))
    else
        plot!(p,x,20 .+ 3 .* sin.(2pi .* x ./ 300);color=:teal,linewidth=5)
        t=range(0,2pi;length=200)
        plot!(p,150 .+ 35 .* cos.(t),90 .+ 35 .* sin.(t);color=:coral,linewidth=5)
        quiver!(p,[185.],[90.];quiver=([0.],[-13.]),color=:coral)
        annotate!(p,150,90,text("rotating\ncore",11,:darkslategray))
        annotate!(p,55,100,text("A ring can carry\na water-mass\nanomaly",11,:darkslategray))
    end
    p
end

# ╔═╡ 20a0ba0f-02f2-4e9d-ba37-e011369ca7b1
md"""
### Step 2 · What keeps water circulating around the eddy?

An eddy can have a pressure anomaly at its center. For a broad, slowly rotating surface eddy, pressure-gradient and Coriolis effects nearly balance around that center, just as they did across the earlier straight current.

With nearly uniform atmospheric pressure, the surface pressure-gradient signal is related to sea-surface height η. In the geostrophic approximation,
```math
v_\theta(r)\approx\frac{g}{f}\frac{d\eta}{dr}.
```
**r** is distance from the eddy center; **vθ** is signed tangential speed, positive counterclockwise; **η** is sea-surface height anomaly. We use **f > 0**, the Northern Hemisphere.

- A central **sea-surface low** has height increasing outward: counterclockwise circulation.
- A central **sea-surface high** has height decreasing outward: clockwise circulation.

Eddy center: $(@bind eddy_polarity Select(["Sea-surface low", "Sea-surface high"];default="Sea-surface low"))

This example uses a smooth 10 cm anomaly with a 50 km radial scale. It calculates a balanced eddy's circulation; it does not calculate that eddy's formation.
"""

# ╔═╡ f4acf4db-8c9e-4e81-8076-3c769ba036dc
begin
    eddy_height=eddy_polarity=="Sea-surface low" ? -0.10 : 0.10
    eddy_radius=50e3
    eddy_speed_at_radius=-9.81*eddy_height/(1e-4*eddy_radius)*exp(-0.5)
    eddy_turnover=2pi*eddy_radius/abs(eddy_speed_at_radius)/86400
end

# ╔═╡ 95e1bfa9-07cc-4cfb-b783-8bb2bdbed66d
let
    f=1e-4;g=9.81;R=eddy_radius;h0=eddy_height
    xy=collect(range(-125.,125.;length=150))
    eta=[100h0*exp(-((1000x)^2+(1000y)^2)/(2R^2)) for y in xy,x in xy]
    p1=heatmap(xy,xy,eta;clims=(-10,10),color=:balance,aspect_ratio=:equal,
        xlabel="x (km)",ylabel="y (km)",colorbar_title="Height anomaly (cm)",
        title="$(eddy_polarity) · view from above")
    xs=Float64[];ys=Float64[];us=Float64[];vs=Float64[]
    for y in -90.:30.:90., x in -90.:30.:90.
        rr=(1000x)^2+(1000y)^2
        amp=g*h0/(f*R^2)*exp(-rr/(2R^2))
        push!(xs,x);push!(ys,y)
        push!(us,90amp*1000y);push!(vs,-90amp*1000x)
    end
    quiver!(p1,xs,ys;quiver=(us,vs),color=:black,linewidth=1.3,label=false)
    r=range(0,150e3;length=250)
    vel=-g*h0/(f*R^2) .* r .* exp.(-r.^2 ./ (2R^2))
    p2=plot(r ./ 1000,vel;color=:teal,label=false,ylims=(-0.14,0.14),
        xlabel="Distance from center (km)",ylabel="Signed tangential speed (m/s)",
        title="Speed follows the radial height slope")
    hline!(p2,[0.];color=:gray,linestyle=:dash,label=false)
    scatter!(p2,[R/1000],[eddy_speed_at_radius];color=:coral,label=false)
    plot(p1,p2;layout=(1,2),size=(1020,410))
end

# ╔═╡ cf9758cb-5120-4e01-9a90-aafae52bccff
md"""
At a radius of 50 km, the idealized speed is **$(round(abs(eddy_speed_at_radius);digits=3)) m/s** and a parcel takes about **$(round(eddy_turnover;digits=1)) days** to go around once in this steady circular flow. This turnover time is different from the Eady **amplitude doubling time**.

### Step 3 · Why exponential growth eventually stops

The growing disturbance changes the density slopes and current that supply its energy. Eddies can exchange energy with the current and one another, stretch filaments, merge, and lose energy through mixing and friction. There is no universal rule that a wave doubles until it becomes one ring.

> **Takeaway:** linear Eady theory predicts early growth; nonlinear dynamics determine the later rearrangement. An eddy's rotating structure can remain close to geostrophic balance even though its formation involved nonlinear evolution.

**Now the modeling question is specific:** how can we evolve the flow that transports and changes its own density and rotation, rather than prescribe the next shape?

Background: [WHOI on currents and eddies](https://www.whoi.edu/ocean-learning-hub/ocean-topics/how-the-ocean-works/ocean-circulation/currents-gyres-eddies/) and [Cambridge notes on rotating stratified dynamics](https://www.damtp.cam.ac.uk/user/phh1/atmosocean/notes2019.pdf).
"""

# ╔═╡ a3bf7946-a3c2-414e-850f-e2b9b707d2de
presentation_details("The mathematics · what linear theory leaves out", md"""
Fluid acceleration includes transport of velocity by the velocity itself: **u · ∇u**. For a background U and a disturbance u′,
```math
(\mathbf U+\mathbf u')\cdot\nabla(\mathbf U+\mathbf u')
=\mathbf U\cdot\nabla\mathbf U
+\mathbf U\cdot\nabla\mathbf u'
+\mathbf u'\cdot\nabla\mathbf U
+\underbrace{\mathbf u'\cdot\nabla\mathbf u'}_{\text{quadratic disturbance term}}.
```
The two middle terms contain one disturbance factor and are kept in linear theory. The last contains two; doubling the disturbance makes this term four times as large. It becomes important as disturbances grow and can reshape the flow. Density transport contains corresponding nonlinear terms.

Nonlinear does not mean random. It means the evolving disturbances interact and alter the background, so a fixed growth rate and one prescribed sine wave cannot determine the later flow.

The final eddy diameter is not automatically equal to the Eady fastest-growing wavelength. That wavelength characterizes a linear disturbance of the original current. Later deformation and interactions select the resulting structures.
""")

# ╔═╡ fe2c1e09-1787-4762-ac87-bba0a3e612dd
presentation_details("The mathematics · deriving the rotating eddy example", md"""
Assume an axisymmetric steady eddy, with negligible radial velocity. Let r increase outward and vθ be positive counterclockwise. A parcel moving around a circle has inward acceleration −vθ²/r. The radial momentum equation gives
```math
-\frac{v_\theta^2}{r}-fv_\theta=-\frac{1}{\rho_0}\frac{\partial p}{\partial r},
\qquad
fv_\theta+\frac{v_\theta^2}{r}=\frac{1}{\rho_0}\frac{\partial p}{\partial r}.
```
This is **gradient-wind balance**. It includes the centripetal acceleration needed for the curved path. When |vθ|/(|f|r) is small, the curvature term is small relative to the Coriolis term. Near the surface, with uniform atmospheric pressure and the hydrostatic free-surface relation, pr/ρ₀ ≈ gηr. Therefore
```math
v_\theta\approx\frac{g}{f}\eta_r.
```
Choose an idealized height anomaly
```math
\eta(r)=\eta_0\exp[-r^2/(2R^2)].
```
Differentiating produces the plotted velocity:
```math
v_\theta(r)=-\frac{g\eta_0}{fR^2}r\exp[-r^2/(2R^2)].
```
The magnitude peaks at r = R. For |η₀| = 0.10 m, R = 50 km, and f = 10⁻⁴ s⁻¹, |vθ(R)| ≈ 0.119 m/s. The local curvature-to-Coriolis ratio there is about 0.024; its limiting central value is about 0.039. This supports the geostrophic approximation for this chosen illustration. It is not an exact gradient-wind solution.

The rotation is quantified by vertical relative vorticity:
```math
\zeta=\frac{\partial v}{\partial x}-\frac{\partial u}{\partial y}
=\frac1r\frac{d(rv_\theta)}{dr}
=-\frac{g\eta_0}{fR^2}\left(2-\frac{r^2}{R^2}\right)e^{-r^2/(2R^2)}.
```
At the center use its finite limit. Positive ζ means local counterclockwise spin. This smooth vortex has an oppositely signed vorticity skirt beyond √2 R, even though its tangential velocity keeps the same sign. Vorticity measures local spin and shear; it is not simply the direction of a drawn streamline.

The orbital time at radius r is 2πr/|vθ(r)|. It describes circulation in the already specified steady eddy, not its lifetime, formation time, or Eady growth time. The surface-height example does not specify a complete vertical temperature or salinity structure.
""")

# ╔═╡ 1f5e5721-86be-4d89-8717-53cc301d959b
presentation_details("Going further · the equation that lets eddies reshape their flow", md"""
A common next step beyond linear theory is a nonlinear **quasigeostrophic potential-vorticity model**. Here Q denotes potential vorticity, distinct from the passive tracer q used later.

Using the convention u = −ψy and v = ψx for this derivation,
```math
Q=\nabla_h^2\psi+\frac{\partial}{\partial z}
\left(\frac{f_0^2}{N^2}\frac{\partial\psi}{\partial z}\right)+\beta y,
\qquad
\frac{\partial Q}{\partial t}+uQ_x+vQ_y=0.
```
The terms in Q represent relative vorticity, the effect of vertical stretching and stratification, and the change of planetary rotation with latitude. β = df/dy; it is set to zero in the ideal Eady problem. Q is a dynamical quantity with units s⁻¹ here, not a concentration.

The physical idea is that moving water carries its potential vorticity in this inviscid, adiabatic approximation. Rearranging Q changes the velocity field implied by Q. That new velocity then rearranges Q again. Unlike passive dye, the transported quantity is dynamically active.

The transport term can also be written J(ψ,Q) = ψx Qy − ψy Qx. It is nonlinear because Q and ψ are linked. Obtaining ψ from Q requires solving a spatial boundary-value problem, often called PV inversion.

**For an Eady-type problem, the top and bottom buoyancy fields and their evolution are essential.** An interior Q equation alone does not complete that model. Boundary conditions, initial perturbations, and any forcing or dissipation must also be specified. The next demonstration solves a different, two-layer QG idealization with evolving perturbations; it does not solve this continuously stratified Eady boundary-value problem.

The later tracer demonstration uses the opposite streamfunction sign convention, u = ψy and v = −ψx. Both conventions are valid when used consistently; the derivation here uses the common QG convention to match the cited lecture notes.

Source: [Cambridge Fluid Dynamics of Climate, rotating stratified and quasigeostrophic equations](https://www.damtp.cam.ac.uk/user/phh1/atmosocean/notes2019.pdf).
""")

# ╔═╡ ac1b885e-bac8-4edf-ade4-e72f6f6ecfde
md"""
### 6A · Let the disturbance change the flow

**These are computed snapshots, not a wave with a prescribed growing amplitude.** Two equal-depth layers move in opposite directions. A small disturbance draws energy from this vertical shear. The nonlinear run lets the disturbance transport and reshape itself; the linear run omits that interaction.

Move from **0 → 20 → 35 → 45 model-time units**. Early patterns nearly agree. Later, the nonlinear field develops curved filaments and interacting vortical structures. The linear calculation continues amplifying its wave pattern.

Colors show the upper layer's **potential-vorticity anomaly**: a combination of local rotation and layer stretching, not temperature. Arrows show the **disturbance velocity**, excluding the imposed uniform current. Each panel is normalized to its own maximum to compare shapes; the graph below compares actual disturbance energy.

This is a **two-layer quasigeostrophic model**, not a nonlinear solution of the continuously stratified Eady problem. It demonstrates baroclinic eddy development in a periodic domain, not the detachment of a ring from a specific ocean jet.
"""

# ╔═╡ 1f26689a-76c5-4dea-9b46-c8632e07bf04
function eddy_qg_run(; nonlinear=true, n=64, dt=0.02, tend=45.0, amplitude=0.01)
    # Nondimensional equal-layer QG; Ld=1, velocity difference=1.
    # Coordinates: rows=y, columns=x. u'=-psi_y, v'=psi_x.
    L=20.0; F=0.5; U=(0.5,-0.5); B=(0.5,-0.5)
    x=collect(0:n-1).*L/n
    k=(2pi/L).*vcat(0:n÷2-1,-n÷2:-1)
    kx=reshape(k,1,n); ky=reshape(k,n,1)
    K=kx.^2 .+ ky.^2; safe=copy(K); safe[1,1]=1.0
    cutoff=2pi/L*n/3
    mask=(abs.(kx).<cutoff).&(abs.(ky).<cutoff)
    damping=1.0.*(K./cutoff^2).^4
    p1=amplitude.*[cos(4pi*xx/L)*cos(2pi*yy/L)+
        0.7sin(2pi*xx/L+0.3)*cos(4pi*yy/L)+
        0.4cos(6pi*xx/L+1)*sin(2pi*yy/L) for yy in x, xx in x]
    h1=fft(p1);h2=-0.5h1
    q=cat(-K.*h1.+F.*(h2.-h1),-K.*h2.+F.*(h1.-h2);dims=3)
    function invert(qh)
        bt=-(qh[:,:,1].+qh[:,:,2])./(2 .*safe);bt[1,1]=0
        bc=-(qh[:,:,1].-qh[:,:,2])./(2 .*(K.+2F))
        cat(bt.+bc,bt.-bc;dims=3)
    end
    function rhs(qh)
        ph=invert(qh); result=similar(qh)
        for j in 1:2
            pq=ph[:,:,j];qq=qh[:,:,j]
            jac=zeros(ComplexF64,n,n)
            if nonlinear
                px=real.(ifft(im.*kx.*pq));py=real.(ifft(im.*ky.*pq))
                qx=real.(ifft(im.*kx.*qq));qy=real.(ifft(im.*ky.*qq))
                jac=fft(px.*qy.-py.*qx)
            end
            result[:,:,j]=(-jac.-im.*kx.*(U[j].*qq.+B[j].*pq).-damping.*qq).*mask
        end
        result
    end
    times=Float64[]; energy=Float64[]; snapshots=Matrix{Float64}[]
    velocities=Tuple{Matrix{Float64},Matrix{Float64}}[]
    cflmax=0.0;meanmax=0.0
    steps=round(Int,tend/dt);stride=round(Int,1/dt)
    for step in 0:steps
        if step%stride==0 || step==steps
            ph=invert(q); qreal=real.(ifft(q[:,:,1]))
            uu=-real.(ifft(im.*ky.*ph[:,:,1]));vv=real.(ifft(im.*kx.*ph[:,:,1]))
            u2=-real.(ifft(im.*ky.*ph[:,:,2]));v2=real.(ifft(im.*kx.*ph[:,:,2]))
            dp=real.(ifft(ph[:,:,1].-ph[:,:,2]))
            push!(times,step*dt);push!(snapshots,qreal);push!(velocities,(uu,vv))
            push!(energy,mean(uu.^2 .+vv.^2 .+u2.^2 .+v2.^2 .+F.*dp.^2)/2)
            cflmax=max(cflmax,dt/(L/n)*maximum(abs.(uu.+U[1]).+abs.(vv)),
                dt/(L/n)*maximum(abs.(u2.+U[2]).+abs.(v2)))
            meanmax=max(meanmax,abs(mean(qreal)),abs(real(q[1,1,2])/n^2))
        end
        step==steps && break
        a=rhs(q);b=rhs(q.+(dt/2).*a);c=rhs(q.+(dt/2).*b);d=rhs(q.+dt.*c)
        q=(q.+(dt/6).*(a.+2 .*b.+2 .*c.+d)).*reshape(mask,n,n,1)
        all(isfinite,q) || error("Non-finite QG state: reduce dt or shorten the run")
    end
    (;x,times,energy,snapshots,velocities,cflmax,meanmax,n,dt)
end

# ╔═╡ 2bd661c5-4c2a-4076-a10e-2ea27eb40996
begin
    # Computed once. Moving the time slider does not rerun the solver.
    eddy_qg_nonlinear=eddy_qg_run()
    eddy_qg_linear=eddy_qg_run(nonlinear=false)
end

# ╔═╡ 0d463de2-a151-4c60-82ad-ec3d7a9a97d1
md"""
**Time through the computed experiment:** $(@bind eddy_qg_frame Slider(1:length(eddy_qg_nonlinear.times);default=1,show_value=false))

**t = $(round(eddy_qg_nonlinear.times[eddy_qg_frame];digits=1)) model-time units**
"""

# ╔═╡ b4d30806-706b-4204-ad3b-f776f7b09b43
let
    frame=eddy_qg_frame
    panels=Plots.Plot[]
    for (run,label) in ((eddy_qg_linear,"Linear · no self-advection"),(eddy_qg_nonlinear,"Nonlinear · evolving interactions"))
        field=run.snapshots[frame]; scale=max(maximum(abs,field),1e-12)
        p=heatmap(run.x,run.x,field./scale;color=:balance,clims=(-1,1),
            xlabel="x / Ld",ylabel="y / Ld",title=label,aspect_ratio=:equal,
            colorbar_title="PV / panel max",xlims=(0,20),ylims=(0,20))
        uu,vv=run.velocities[frame];speed=max(maximum(sqrt.(uu.^2 .+vv.^2)),1e-12)
        ids=3:6:length(run.x)
        xs=[run.x[j] for i in ids for j in ids];ys=[run.x[i] for i in ids for j in ids]
        us=[0.9uu[i,j]/speed for i in ids for j in ids];vs=[0.9vv[i,j]/speed for i in ids for j in ids]
        quiver!(p,xs,ys;quiver=(us,vs),color=:black,linewidth=1,label=false)
        push!(panels,p)
    end
    plot(panels...;layout=(1,2),size=(1000,430),titlefontsize=11)
end

# ╔═╡ ade8b254-b862-4911-a187-e20d21e7821a
let
    a=eddy_qg_linear;b=eddy_qg_nonlinear
    p=plot(a.times,a.energy./a.energy[1];label="Linear",color=:coral,yscale=:log10,
        xlabel="Model time = t ΔU / Ld",ylabel="Energy / initial energy",
        title="Same initial disturbance · compare actual growth",legend=:topleft,size=(950,300))
    plot!(p,b.times,b.energy./b.energy[1];label="Nonlinear",color=:teal)
    vline!(p,[b.times[eddy_qg_frame]];label="Selected snapshot",color=:gray,linestyle=:dash)
    p
end

# ╔═╡ d729a8a3-5c65-442b-af28-65c61ff39cc2
md"""
> **What changed?** The nonlinear simulation computes a new velocity from the changing potential vorticity at every step. That velocity transports the potential vorticity again. This feedback allows shape changes and interactions that an exponentially enlarged sine wave cannot represent.

The imposed, domain-mean vertical shear is maintained in this idealization: it remains an energy source. Local perturbations and their zonal averages can evolve. Do not interpret the energy graph as depletion of a finite ocean energy reservoir or as a prediction of an eddy's lifetime.

**Bridge to global models:** we have now coupled transport to the flow that causes it. A global model must also represent coasts, topography, surface forcing, temperature, salinity, and unresolved mixing.
"""

# ╔═╡ f91b2fa7-d786-45a1-9f3f-cbf27433ee38
presentation_details("The mathematics · what this simulation actually solves", md"""
In layer ``i``, the perturbation potential vorticity ``q_i`` obeys
```math
\frac{\partial q_i}{\partial t}+U_i\frac{\partial q_i}{\partial x}
+B_i\frac{\partial\psi_i}{\partial x}
+J(\psi_i,q_i)=-\nu_8(-\nabla^2)^4q_i,
```
```math
q_1=\nabla^2\psi_1+F(\psi_2-\psi_1),\qquad
q_2=\nabla^2\psi_2+F(\psi_1-\psi_2).
```
``\psi_i`` is the disturbance streamfunction: ``u'_i=-\partial_y\psi_i`` and ``v'_i=\partial_x\psi_i``. Inverting the two elliptic equations recovers the flow from potential vorticity at each step.

- ``U_1=+0.5``, ``U_2=-0.5`` are imposed uniform layer velocities.
- ``F=0.5`` couples the layers; the deformation radius is ``L_d=1/\sqrt{2F}=1``.
- With constant Coriolis parameter (``\beta=0``), the background PV gradients are ``B_1=F(U_1-U_2)=0.5`` and ``B_2=-0.5``. These encode the background interface tilt.
- ``J(\psi,q)=\psi_xq_y-\psi_yq_x`` is the **nonlinear self-advection** term. Only this term is removed in the linear comparison. Both runs use the same initial fields and small-scale damping.
- The displayed energy is ``E'=\langle |\nabla\psi_1|^2+|\nabla\psi_2|^2+F(\psi_1-\psi_2)^2\rangle/2``. It includes perturbation kinetic and available potential energy, with a common normalization.

**Numerics:** 64 × 64 periodic grid; Fourier inversion and derivatives; two-thirds spectral truncation to remove aliasing; fourth-order Runge–Kutta; time step 0.02; eighth-order damping with rate 1 at the spectral cutoff. Thin filaments near the grid scale are damped, not fully resolved. This is a qualitative teaching calculation, not a converged ocean forecast.

**Units:** distance is in deformation radii and time in ``L_d/\Delta U``. For an illustrative ``L_d=25`` km and ``\Delta U=0.10`` m/s, one time unit is 2.89 days and the box spans 500 km. These are separate parameters from the Eady slider; changing that slider does not change this simulation.

**Limit:** the domain is periodic in both directions, with a prescribed uniform background shear and no coasts. It can illustrate unstable waves developing nonlinear vortical structures; it does not demonstrate a Gulf Stream ring pinching off. The earlier loop-to-ring drawing remains a schematic.

Equations: [pyqg two-layer QG model documentation](https://pyqg.readthedocs.io/en/latest/equations/notation_twolayer_model.html). The Julia solver here is a small independent implementation of that equation framework, with equal layers, no beta, and no bottom drag.
""")

# ╔═╡ 1fd5bed5-58b5-4cce-addb-c2b05d64283a
md"""
## 7 · From a moving patch to the global ocean
**What must the computer calculate?**

A computer represents the ocean with a finite set of cells and advances its state through time. First see one building block: **advection**, the transport of a property by moving water.

The patch below behaves like dye. Its velocity field is prescribed, so the patch cannot change the flow. Moving through the frames shows transport through four recirculating cells.

Time through the transport experiment: $(@bind transport_frame Slider(1:41;default=1,show_value=true))
"""

# ╔═╡ b5f868b5-0092-4b48-a7b6-3abdea062379
tracer_run=transport2d(64,0.2,8.0)

# ╔═╡ ce0a10d6-d0a5-42cb-98c1-99f6eca5ff3c
let
    r=tracer_run
    p=heatmap(r.xy ./ 1000,r.xy ./ 1000,r.frames[transport_frame];color=:thermal,clims=(0,1),
        xlabel="x (km)",ylabel="y (km)",aspect_ratio=:equal,colorbar_title="Tracer",
        title="Day $(round((transport_frame-1)/5;digits=1)) · prescribed flow",xlims=(0,200),ylims=(0,200),size=(770,450))
    a=collect(12.0:22.0:188.0); xs=Float64[];ys=Float64[];us=Float64[];vs=Float64[]
    for yy in a, xx in a
        push!(xs,xx);push!(ys,yy)
        push!(us,8sin(2pi*xx/200)*cos(2pi*yy/200))
        push!(vs,-8cos(2pi*xx/200)*sin(2pi*yy/200))
    end
    quiver!(p,xs,ys;quiver=(us,vs),color=:white,linewidth=1.3,label=false)
    p
end

# ╔═╡ e7f7d47b-be52-431c-87ec-f9e42f5b9fe1
md"""
The tracer moves and stretches; the numerical scheme also smears it. **Conserving the total tracer does not guarantee that its shape is accurate.** Relative total-tracer error: $(round(tracer_run.mass_error;sigdigits=3)).

### An active ocean model closes the feedback loop

**Currents transport temperature and salinity → those properties affect density → density and pressure affect currents.**

The computer must evolve these connected quantities together. It uses momentum equations, conservation laws, an equation of state, and appropriate pressure constraints. This feedback allows a model to generate disturbances rather than having us prescribe their shapes.

### What changes when the domain becomes global?

Reveal the ingredients: $(@bind global_stage Slider(1:1:4;default=1,show_value=true))
"""

# ╔═╡ 394b189f-ef5b-49ba-b923-729b7e30bdfb
let
    p=plot(;xlims=(-2,2),ylims=(-1.25,1.3),aspect_ratio=:equal,axis=false,grid=false,
        legend=false,title="Building a global model · conceptual diagram",size=(940,430))
    t=range(0,2pi;length=200)
    plot!(p,cos.(t),sin.(t);color=:royalblue,linewidth=3)
    for a in [-0.75,-0.4,0.4,0.75]
        plot!(p,a .* cos.(t),sin.(t);color=:lightsteelblue,linewidth=1)
        width=sqrt(1-a*a)
        plot!(p,[-width,width],[a,a];color=:lightsteelblue,linewidth=1)
    end
    annotate!(p,0,0,text("GRID
velocity · T · S",12,:darkslategray))
    if global_stage>=2
        annotate!(p,-1.48,0.62,text("BOUNDARIES
coasts
seafloor",11,:teal))
        annotate!(p,1.48,0.62,text("ROTATION
changes with
latitude",11,:teal))
    end
    if global_stage>=3
        annotate!(p,0,1.15,text("SURFACE FORCING: wind · heat · freshwater",11,:coral))
    end
    if global_stage>=4
        annotate!(p,-1.48,-0.55,text("STARTING STATE
initial currents
temperature · salt",10,:darkslategray))
        annotate!(p,1.48,-0.55,text("UNRESOLVED
PROCESSES
mixing · eddies",10,:darkslategray))
    end
    p
end

# ╔═╡ 35eb0d97-0abd-4aab-bfcd-e5b5e40aec3b
md"""
| Ingredient | What it contributes |
|:--|:--|
| Continents and seafloor | Boundaries that redirect and constrain water |
| Latitude-dependent rotation | Different rotational effects across the globe |
| Wind, heat, and freshwater exchange | Momentum input and changes to buoyancy |
| Mixing, friction, and unresolved eddy effects | Exchanges that the grid cannot explicitly capture |
| Initial conditions | A starting state for the evolving calculation |

### Resolution determines what we can represent

A feature needs many cells across it to be represented well. A finer grid can capture smaller structures, but it requires more cells and often shorter time steps. Coarse models use **parameterizations** to estimate unresolved effects.

Compare grid sampling: $(@bind sample_cells Select([16,32,64];default=16))
"""

# ╔═╡ cd2362cc-4de3-4421-8b8a-fe36638307f0
let
    field(x,y)=exp(-((x-0.42)^2+(y-0.55)^2)/0.008)-0.7exp(-((x-0.65)^2+(y-0.4)^2)/0.012)
    fine=range(0,1;length=240)
    coarse=((0:sample_cells-1) .+ 0.5) ./ sample_cells
    p1=heatmap(fine,fine,[field(x,y) for y in fine,x in fine];clims=(-1,1),color=:balance,
        xlabel="x",ylabel="y",title="Idealized reference field",aspect_ratio=:equal,colorbar=false)
    p2=heatmap(coarse,coarse,[field(x,y) for y in coarse,x in coarse];clims=(-1,1),color=:balance,
        xlabel="x",ylabel="y",title="$(sample_cells) × $(sample_cells) samples",aspect_ratio=:equal,colorbar=false)
    plot(p1,p2;layout=(1,2),size=(900,360))
end

# ╔═╡ ea2b4d35-6d56-41ff-94f2-8ac734b2fcfe
md"""
This last comparison samples the same artificial field on different grids; it is not a convergence test or a circulation simulation.

> **Takeaway:** global circulation models combine interacting physical equations, forcing, boundaries, and numerical approximations. Their realism must be tested against observations and physical budgets.
"""

# ╔═╡ 52c82281-cbb0-42c5-acc1-c893da09fcec
presentation_details("The mathematics · a minimum set of coupled equations", md"""
For a Boussinesq rotating fluid, a schematic momentum equation is
```math
\frac{D\mathbf u}{Dt}+f\hat{\mathbf z}\times\mathbf u
=-\frac{1}{\rho_0}\nabla p'+b\hat{\mathbf z}+\mathbf F.
```
Here p′ is pressure relative to the reference hydrostatic state and F collects additional forces. Hydrostatic models replace the vertical acceleration equation with vertical pressure balance.

The material derivative follows a moving parcel:
```math
\frac{D}{Dt}=\frac{\partial}{\partial t}+u\frac{\partial}{\partial x}
+v\frac{\partial}{\partial y}+w\frac{\partial}{\partial z}.
```
Volume conservation, property budgets, and density complete the schematic system:
```math
\nabla\cdot\mathbf u=0,\qquad
\frac{DT}{Dt}=\text{heating and mixing},\qquad
\frac{DS}{Dt}=\text{salt sources and mixing},\qquad
\rho=\rho(T,S,p).
```
At each step the solver calculates tendencies and fluxes, enforces its constraints, and updates the state. The ordering depends on the numerical method. Pressure is constrained by mass conservation and model approximations; it is not always advanced as an independent local variable.

Halving horizontal grid spacing gives roughly four times as many horizontal cells. If the time step must also halve, work can increase roughly eightfold for the same simulated duration before other costs are included.
""")

# ╔═╡ 8352a5c8-2320-4ebc-87ef-dfe033800390
presentation_details("The mathematics · what the tracer solver actually computes", md"""
The conservative tracer equation is
```math
q_t+\partial_x(uq)+\partial_y(vq)=0.
```
Its prescribed streamfunction is
```math
\psi=\frac{U}{k}\sin(kx)\sin(ky),\quad
u=\psi_y,\quad v=-\psi_x,\quad k=2\pi/L.
```
Mixed derivatives cancel, so ux + vy = 0. With divergence-free velocity, the transport equation becomes Dq/Dt = 0: a parcel retains its tracer in the ideal continuous solution.

The code stores a tracer value in each cell, estimates upwind fluxes on cell faces, and updates each cell using inflow minus outflow. Shared face fluxes cancel in the total budget. Boundaries are periodic: tracer leaving one edge returns on the opposite edge.

In one dimension with constant positive velocity, the same idea gives
```math
q_i^{n+1}=(1-C)q_i^n+Cq_{i-1}^n,\qquad C=u\Delta t/\Delta x.
```
For 0 ≤ C ≤ 1 this is a weighted average. Repeated averaging smooths the patch: numerical diffusion. For the 2D scheme the sum of directional Courant numbers must remain ≤ 1; the code uses a conservative time-step limit. At a fixed Courant number, finer cells reduce leading upwind diffusion.

This run uses 64 × 64 cells over a 200 km square, U = 0.20 m/s, and eight days. Velocity is imposed, not generated by Eady instability; tracer has no buoyancy feedback. Molecular diffusion is not included, but the numerical scheme introduces smearing.
""")

# ╔═╡ fda4b9fc-9429-4f12-8518-5ea208a4d7dd
md"""
## 8 · Return to the opening question
**What explains the moving ocean?**

The ocean is often close to **hydrostatic balance vertically** and **geostrophic balance horizontally**. A balanced current can nevertheless contain **available potential energy** in its density arrangement.

The **Eady model** shows how suitable small disturbances can draw on that energy and grow. **Nonlinear evolution** can organize the disturbed flow into eddies; their circulation can remain approximately balanced. **Active numerical ocean models** extend the picture by evolving the interacting currents, density fields, forcing, and boundaries.

| Step in the story | What we learned |
|:--|:--|
| Vertical balance | Pressure supports weight; stratification restores displaced parcels |
| Rotating current | Horizontal pressure gradients coexist with currents and density tilt |
| Available energy | Balance and local vertical stability do not guarantee stability of a current |
| Eady instability | Growth depends on shear, stratification, rotation, and wavelength |
| Eddy development | Nonlinear feedback reshapes the current; pressure gradients support circulating flow |
| Global modeling | The feedbacks must be solved with boundaries, forcing, and finite resolution |

> **Discussion · 2 minutes:** When we see eddies in a model, what evidence would convince us that it represents their physics well?
"""

# ╔═╡ d2ba7633-bea8-4570-aec3-8c34ba499e07
md"""
## Appendix · sources and checks
The main presentation ends above. Use this material for preparation or questions.
"""

# ╔═╡ ff6b5c68-8f59-4049-8ee8-6ef6bd08de9a
presentation_details("Sources · follow the story in the literature", md"""
1. **Haynes & Taylor (2019), University of Cambridge, Fluid Dynamics of Climate.** Rotating stratified equations, the Boussinesq approximation, and Eady theory in §8.4. [Lecture notes](https://www.damtp.cam.ac.uk/user/phh1/atmosocean/notes2019.pdf).
2. **MIT OpenCourseWare, 12.803, Lecture 19.** Baroclinic instability and the Eady model. [Lecture page and PDF](https://ocw.mit.edu/courses/12-803-quasi-balanced-circulations-in-oceans-and-atmospheres-fall-2009/resources/mit12_803f09_lec19/).
3. **Griffies (2019), AMSI Summer School.** Ocean circulation as a problem in mathematical and computational physics. Background reading for buoyancy, rotation, available potential energy, and ocean modeling. [Lecture PDF](https://amsi.org.au/media/Griffies_AMSI_2019.pdf).
4. **Ketcheson, LeVeque & del Razo, Riemann Problems and Jupyter Solutions.** Conservation and exact advection. [Advection chapter](https://www.clawpack.org/riemann_book/html/Advection.html).
5. **MITgcm documentation.** Finite-volume algorithms and advection schemes. [Algorithms](https://mitgcm.readthedocs.io/en/latest/algorithm/algorithm.html) · [Advection schemes](https://mitgcm.readthedocs.io/en/latest/algorithm/adv-schemes.html).
6. **Tulloch, Marshall, Hill & Smith (2011).** Scales, Growth Rates, and Spectral Fluxes of Baroclinic Instability in the Ocean. Journal of Physical Oceanography, 41, 1057–1076. [DOI](https://doi.org/10.1175/2011JPO4404.1).

7. **Woods Hole Oceanographic Institution.** Currents, gyres, and eddies; an accessible account of meanders and ring formation. [Ocean learning hub](https://www.whoi.edu/ocean-learning-hub/ocean-topics/how-the-ocean-works/ocean-circulation/currents-gyres-eddies/).

All plots are locally generated teaching illustrations or calculations. No plot is an observational image or output from a global circulation model. ChatGPT assisted with the notebook's structure, explanations, and code.
""")

# ╔═╡ b34f3545-385a-43fc-90a3-cef3ca988d83
let
    base=eady_rate(1e-4,0.01,0.2,500.,3.9)
    checks=[
        "Near-fastest wave doubles in about 6.5 days" => isapprox(log(2)/base/86400,6.5;atol=0.1),
        "Doubling shear doubles growth" => isapprox(eady_rate(1e-4,0.01,0.4,500.,3.9),2base),
        "Short wave has no exponential growth" => iszero(eady_rate(1e-4,0.01,0.2,500.,1.5)),
        "Zero shear has no Eady growth" => iszero(eady_rate(1e-4,0.01,0.,500.,3.9)),
        "Tracer total is conserved" => tracer_run.mass_error<1e-10,
        "Tracer remains nonnegative to roundoff" => minimum(minimum(q) for q in tracer_run.frames)>-1e-12,
        "Half the tilt leaves one quarter of the energy" => (1-0.5)^2==0.25
    ]
    presentation_details("Verification checks · not validation of an ocean prediction",
        Markdown.parse(join(["- "*(ok ? "✓ " : "✗ ")*label for (label,ok) in checks],"\n")))
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
FFTW = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
FFTW = "~1.10.0"
Plots = "~1.41.7"
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.13.0"
manifest_format = "2.1"
project_hash = "1499516ce9c6032e4e61e2cb96fa2f34c5d28176"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
registries = "General"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

    [deps.AbstractFFTs.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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
git-tree-sha1 = "7b841680738c19948120f6e4cf8d0200518bd564"
registries = "General"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.8+0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b0fd3f56fa442f81e0a47815c92245acfaaa4e34"
registries = "General"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.31.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "a7cf827a79b378a381e31e5c7feca853ec19cb94"
registries = "General"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.4"
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
git-tree-sha1 = "a633156e74096f90b3b5e833529292b651b5671a"
registries = "General"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.3"

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
git-tree-sha1 = "8eeb56c16e74c6592afc69d2bb9e6082ba6aa850"
registries = "General"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.10.0"

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

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "Libdl", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "97f08406df914023af55ade2f843c39e99c5d969"
registries = "General"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.10.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6866aec60ef98e3164cd8d6855225684207e9dff"
registries = "General"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.12+0"

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

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "ec1debd61c300961f98064cfb21287613ad7f303"
registries = "General"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2025.2.0+0"

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
git-tree-sha1 = "9939eb6f799a963b3392ac4a1d49d3fc0646eb80"
registries = "General"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.11.0"

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

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"
version = "1.11.0"

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

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "oneTBB_jll"]
git-tree-sha1 = "282cadc186e7b2ae0eeadbd7a4dffed4196ae2aa"
registries = "General"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2025.2.0+0"

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
git-tree-sha1 = "ad435e30854ed0f50f4b7f67edd71664afecc5d8"
registries = "General"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.10.0"

    [deps.StructUtils.extensions]
    StructUtilsDataFramesExt = ["DataFrames"]
    StructUtilsLazilyInitializedFieldsExt = ["LazilyInitializedFields"]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
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
git-tree-sha1 = "0392e5e3c5327b90a487b0ff3e818c4aecd3660b"
registries = "General"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.7.1"

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
git-tree-sha1 = "1fcd6cf05d23adab0b5ffc496d020537215751dc"
registries = "General"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.59+1"

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

[[deps.oneTBB_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "ed2d8d4ad96c03d3abe3382cdbbdea9489b63636"
registries = "General"
uuid = "1317d2d5-d96f-522e-a858-c73665f53c3e"
version = "2023.1.0+0"

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
# ╟─0778c545-fb72-44e0-9d86-df34d735f7da
# ╟─747de03c-f4c4-47aa-b66d-542cf974dd72
# ╟─5f6215c4-5656-4942-b88e-b28ca23a1733
# ╟─b38696a8-e07e-45fa-ae5e-42e06435f934
# ╟─116cd075-e925-4ece-be24-6f4c665ace1a
# ╟─f7fa3664-2ed3-4f0b-9236-5b8640b1bcba
# ╟─0ad0a43d-3576-43dc-b57d-9a89670b3e97
# ╟─bc1e0bc1-e358-44e4-9d30-83084f832227
# ╟─1ec2f0b6-ac0d-484b-945f-8ca318073dd9
# ╟─679b8ba7-089b-4529-81d3-e88c5096b27d
# ╟─09f86ae9-8fa0-4eff-a6fe-0d197b948ca0
# ╟─70eae89e-a832-483c-b105-12854db5b93a
# ╟─0e8fa6bd-002b-4fa0-bc86-b5d26fe57804
# ╟─d47f77ed-c3d1-475b-bd18-dc5818539e14
# ╟─6168311e-2e1b-4e51-b588-16357416727f
# ╟─f2e8c323-7d7d-4565-bbb6-7948b5836383
# ╟─73a8ba60-4897-4177-804c-65968d9e8dae
# ╟─cb7fa45d-e2ab-47c9-bdbb-00e48f208092
# ╟─eb2f6a0b-369d-4240-acdf-43855adf051c
# ╟─08ada2c7-14c1-4458-8860-9ec207c492ed
# ╟─ace2a491-b7a9-484f-8bf0-37626e1e3f3b
# ╟─3010a462-4065-4172-a26b-53d41da35555
# ╟─40c78695-a23d-429b-a9d1-22d07de1536f
# ╟─ee9fdb64-3060-49e1-ae03-e8268fa60803
# ╟─add6faf6-a0cd-478e-b0f7-83ceb4f7d9c3
# ╟─03d8e7bf-0f3d-4e83-8ef8-c8acf49344b7
# ╟─7860ab27-8e60-4e8f-bd7e-1eff7029f8b0
# ╟─8e59cfed-839e-4292-b2fc-555b2dde1f6a
# ╟─a57502b8-c0c8-4e97-91f8-cbe60c110881
# ╟─bf39123a-b70f-4c83-9c35-37c19c2ad4bd
# ╟─efa06055-c2e5-4ac5-9958-1ddd11089abf
# ╟─c62e9e26-d245-470b-a9cf-7222989318a4
# ╟─d01bc0bf-110a-4e09-a2a1-e7bab6ab7d29
# ╟─a1bcbe71-ddea-4bdb-99da-52d467ddcd41
# ╟─8c432ac9-f468-4ad3-b5a7-ee29e0a34bb3
# ╟─20a0ba0f-02f2-4e9d-ba37-e011369ca7b1
# ╟─f4acf4db-8c9e-4e81-8076-3c769ba036dc
# ╟─95e1bfa9-07cc-4cfb-b783-8bb2bdbed66d
# ╟─cf9758cb-5120-4e01-9a90-aafae52bccff
# ╟─a3bf7946-a3c2-414e-850f-e2b9b707d2de
# ╟─fe2c1e09-1787-4762-ac87-bba0a3e612dd
# ╟─1f5e5721-86be-4d89-8717-53cc301d959b
# ╟─ac1b885e-bac8-4edf-ade4-e72f6f6ecfde
# ╟─1f26689a-76c5-4dea-9b46-c8632e07bf04
# ╟─2bd661c5-4c2a-4076-a10e-2ea27eb40996
# ╟─0d463de2-a151-4c60-82ad-ec3d7a9a97d1
# ╟─b4d30806-706b-4204-ad3b-f776f7b09b43
# ╟─ade8b254-b862-4911-a187-e20d21e7821a
# ╟─d729a8a3-5c65-442b-af28-65c61ff39cc2
# ╟─f91b2fa7-d786-45a1-9f3f-cbf27433ee38
# ╟─1fd5bed5-58b5-4cce-addb-c2b05d64283a
# ╠═b5f868b5-0092-4b48-a7b6-3abdea062379
# ╟─ce0a10d6-d0a5-42cb-98c1-99f6eca5ff3c
# ╟─e7f7d47b-be52-431c-87ec-f9e42f5b9fe1
# ╟─394b189f-ef5b-49ba-b923-729b7e30bdfb
# ╟─35eb0d97-0abd-4aab-bfcd-e5b5e40aec3b
# ╟─cd2362cc-4de3-4421-8b8a-fe36638307f0
# ╟─ea2b4d35-6d56-41ff-94f2-8ac734b2fcfe
# ╟─52c82281-cbb0-42c5-acc1-c893da09fcec
# ╟─8352a5c8-2320-4ebc-87ef-dfe033800390
# ╟─fda4b9fc-9429-4f12-8518-5ea208a4d7dd
# ╟─d2ba7633-bea8-4570-aec3-8c34ba499e07
# ╟─ff6b5c68-8f59-4049-8ee8-6ef6bd08de9a
# ╟─b34f3545-385a-43fc-90a3-cef3ca988d83
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
