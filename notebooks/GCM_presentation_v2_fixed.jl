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

# ╔═╡ 00000002-0000-4000-8000-000000000002
begin
	using PlutoUI
	using Plots
	using Printf
	using Statistics
	using LinearAlgebra
	using Random
	gr(fmt = :png, dpi = 110)
	default(fontfamily = "sans-serif", legendfontsize = 7, guidefontsize = 8,
		    titlefontsize = 9, tickfontsize = 7, framestyle = :box, grid = false)
	TableOfContents(title = "🌍 GCM notebook", depth = 2)
end

# ╔═╡ 00000001-0000-4000-8000-000000000001
md"""
# 🌍 General Circulation Models — from radiative balance to a coupled Earth system

**A hands‑on, calibrated tour of what is *inside* a GCM.**

Every cell below is a working numerical model. The parameter values are pinned to observational and assessed values (IPCC AR6, CERES, Global Carbon Budget, RAPID, FAO, ice‑core and benthic proxy compilations). Those calibration numbers live in one place — the `CALIB` cell — and are re‑used by every explanation section.

| § | Topic | What you can drive |
|---|---|---|
| 1 | Introduction: energy + carbon flow | CO₂, CH₄, solar, albedo, transient vs equilibrium |
| 2 | Atmosphere | grey layers, Navier–Stokes convection, grid vs spectral, cloud schemes, 3‑D test atmosphere |
| 3 | Ocean | Stommel overturning + hysteresis, ocean–atmosphere coupling & predictability |
| 4 | Other cycles | paleoclimate constraints, forest/population carbon, ice–albedo |
| 5 | Anthropogenic forcing | policy sliders vs RCPs, animated global emissions |
| 6 | Putting it together | coupled run, computational scaling, model failures |
"""

# ╔═╡ 00000003-0000-4000-8000-000000000003
md"""
!!! tip "How to present this notebook"
    Run top‑to‑bottom once (the heaviest cells are §2c, §2f, and §4c: a few seconds each).
    Then drive the sliders. Cells are deliberately modular except where physically coupled.
"""

# ╔═╡ 00000004-0000-4000-8000-000000000004
begin
	# ======================================================================
	#  CALIB — the observational / assessed values every cell is tied to
	# ======================================================================
	CALIB = (
		# --- radiation (AR6 Ch.7 energy budget, CERES EBAF) ---------------
		S0          = 1361.0,    # total solar irradiance, W/m^2
		albedo      = 0.294,     # planetary albedo (99.8 / 340.2)
		σ           = 5.670374419e-8,
		SW_in       = 340.2,     # W/m^2 at TOA
		SW_refl     = 99.8,
		OLR         = 239.6,
		LW_up_sfc   = 398.0,
		LW_dn_sfc   = 342.0,
		LH          = 82.0,
		SH          = 21.0,
		EEI         = 0.79,      # Earth energy imbalance 2006-2018, W/m^2
		OHC_frac    = 0.91,      # fraction of excess heat stored in ocean
		# --- sensitivity (AR6 SPM A.4.4, Ch.7) ---------------------------
		F2x         = 3.93,      # ERF for CO2 doubling +- 0.47
		ECS         = 3.0, ECS_lo = 2.5, ECS_hi = 4.0,
		TCR         = 1.8, TCR_lo = 1.4, TCR_hi = 2.2,
		TCRE_lo     = 1.0, TCRE_hi = 2.3,   # K per 1000 GtC
		# --- forcing (AR6 1750->2019) ------------------------------------
		ERF_total   = 2.72, ERF_lo = 1.96, ERF_hi = 3.48,
		ERF_CO2     = 2.16, ERF_CH4 = 0.54, ERF_N2O = 0.21,
		ERF_halo    = 0.41, ERF_aer = -1.1,
		# --- composition -------------------------------------------------
		CO2_1750    = 278.0, CO2_2019 = 410.0, CO2_now = 422.0,
		CO2_LGM     = 190.0, CO2_pliocene = 400.0,
		CH4_1750    = 722.0, CH4_now = 1920.0,
		GtC_per_ppm = 2.124,
		# --- carbon budget (GCB, 2013-2022 means, GtC/yr) ----------------
		E_fossil    = 10.2, E_luc = 1.1,
		ocean_sink  = 2.8, land_sink = 3.1, atm_growth = 5.2,
		# --- clouds (CERES global means, W/m^2) --------------------------
		CRE_sw      = -45.0, CRE_lw = 26.0, CRE_net = -19.0,
		# --- ocean -------------------------------------------------------
		AMOC        = 17.0, AMOC_err = 4.0,   # Sv at 26.5N (RAPID)
		OHT_max     = 1.3,                     # PW total poleward transport
		# --- land --------------------------------------------------------
		forest_Gha  = 4.06,   # FAO FRA 2020
		veg_C       = 450.0, soil_C = 1700.0, NPP = 60.0,  # GtC, GtC/yr
		# --- paleo -------------------------------------------------------
		LGM_dT      = -5.0,   # +-1 K, AR6 Ch.2/7
		PETM_dT     = 5.5,
		orbital     = (100.0, 41.0, 23.0),   # kyr: eccentricity, obliquity, precession
	)

	# --- forcing helpers ---------------------------------------------------
	f_co2(ppm) = CALIB.F2x / log(2) * log(max(ppm, 1.0) / CALIB.CO2_1750)
	f_ch4(ppb) = 0.036 * (sqrt(max(ppb, 1.0)) - sqrt(CALIB.CH4_1750))

	dT_equil(F; ecs = CALIB.ECS) = ecs / CALIB.F2x * F
	dT_trans(F; tcr = CALIB.TCR) = tcr / CALIB.F2x * F

	function co2_ref(t)
		if t <= 2024
			CALIB.CO2_1750 + 144 * ((clamp(t, 1750, 2024) - 1750) / 274)^3.4
		else
			422 + 118 * ((clamp(t, 2024, 2100) - 2024) / 76)^1.1
		end
	end

	md"✅ **`CALIB` loaded** — $(length(CALIB)) calibration entries."
end

# ╔═╡ 00000005-0000-4000-8000-000000000005
md"""
# 1. Introduction

## 1a. What a GCM actually is

A **General Circulation Model** is a numerical solver for the conservation laws of a rotating,
radiatively heated, moist fluid shell:
1. **Momentum** (primitive equations on a rotating sphere) → winds, currents, jets.
2. **Mass** (continuity + hydrostatic pressure) → surface pressure, vertical motion.
3. **Thermodynamic energy** → temperature, driven by radiative heating/cooling.
4. **Water** (vapour, liquid, ice) → clouds and precipitation.
5. **Radiative transfer** → energy entering and leaving the top of atmosphere.
6. **Tracers/biogeochemistry** → carbon cycle, aerosols, reactive chemistry.
"""

# ╔═╡ 00000006-0000-4000-8000-000000000006
md"""
### ⚙️ 1b. Controls — energy & carbon flow through the climate system

This simulation models how different high-level systems parameters effect carbon and energy flow in the climate system, and how the effect of large external changes on the planet's temperature.

| Parameter | Control | Explanation |
|---|---|---|
| CO₂ (ppm) | $(@bind co2_1b Slider(180:2:1200, default=422, show_value=true)) | Carbon dioxide concentration |
| CH₄ (ppb) | $(@bind ch4_1b Slider(700:20:3000, default=1920, show_value=true)) | Methan concentration |
| Solar output (% of 1361 W m⁻²) | $(@bind sol_1b Slider(90:0.25:110, default=100, show_value=true)) | Solar intensity, relative to default |
| Albedo perturbation | $(@bind alb_1b Slider(-0.06:0.002:0.06, default=0.0, show_value=true)) | Reflectivity of Earth, relative to default |
| Response Mode | $(@bind mode_1b Select(["transient" => "Transient (TCR, keeps TOA imbalance)", "equilibrium" => "Equilibrium (ECS, imbalance = 0)"])) | Short vs. long term |
| Carbon sinks temperature feedback | $(@bind sinkfb_1b CheckBox(default=true)) | Rate of carbon removal |
"""

# ╔═╡ 00000007-0000-4000-8000-000000000007
begin
	S_in_1b   = CALIB.S0 / 4 * sol_1b / 100
	α_1b      = clamp(CALIB.albedo + alb_1b, 0.05, 0.9)
	F_ghg_1b  = f_co2(co2_1b) + f_ch4(ch4_1b)
	F_sw_1b   = S_in_1b * (1 - α_1b) - CALIB.S0 / 4 * (1 - CALIB.albedo)
	F_1b      = F_ghg_1b + F_sw_1b
	ΔT_1b     = mode_1b == "equilibrium" ? dT_equil(F_1b) : dT_trans(F_1b)
	EEI_1b    = mode_1b == "equilibrium" ? 0.0 : F_1b * (1 - CALIB.TCR / CALIB.ECS)

	refl_1b   = α_1b * S_in_1b
	atmabs_1b = 0.235 * S_in_1b
	sfcabs_1b = S_in_1b - refl_1b - atmabs_1b
	OLR_1b    = S_in_1b - refl_1b - EEI_1b
	LWup_1b   = CALIB.LW_up_sfc * (1 + 4 * ΔT_1b / 288.6)
	LWdn_1b   = CALIB.LW_dn_sfc * (1 + 4.3 * ΔT_1b / 288.6) + 0.55 * F_ghg_1b
	LH_1b     = CALIB.LH * (1 + 0.02 * ΔT_1b)
	SH_1b     = CALIB.SH * (1 - 0.004 * ΔT_1b)
	Ts_1b     = 288.6 + ΔT_1b

	Etot_1b = CALIB.E_fossil + CALIB.E_luc
	fb_1b   = sinkfb_1b ? 1.0 : 0.0
	ocs_1b  = CALIB.ocean_sink * (co2_1b / CALIB.CO2_now)^0.75 * (1 - fb_1b * 0.05 * ΔT_1b)
	lds_1b  = CALIB.land_sink * (1 + 0.45 * log(co2_1b / CALIB.CO2_now)) * (1 - fb_1b * 0.09 * ΔT_1b)
	atmg_1b = Etot_1b - ocs_1b - lds_1b
	af_1b   = atmg_1b / Etot_1b

	TSCALE_1b = (-3.0, 9.0)
	tcol(x) = cgrad(:thermal)[clamp((x - TSCALE_1b[1]) / (TSCALE_1b[2] - TSCALE_1b[1]), 0, 1)]
	function arrow_1b!(p, x0, y0, x1, y1, c, lab; dx = 0.0, dy = 0.0, fs = 7)
		plot!(p, [x0, x1], [y0, y1]; arrow = true, lw = 3, c = c, label = "")
		annotate!(p, (x0 + x1) / 2 + dx, (y0 + y1) / 2 + dy, text(lab, fs, c))
	end

	pe_1b = plot(xlim = (0, 10), ylim = (0, 10.6), legend = false, framestyle = :none,
		         title = "Energy flows (W m⁻²) — TOA imbalance = $(@sprintf("%+.2f", EEI_1b))")
	plot!(pe_1b, Shape([0.2, 9.8, 9.8, 0.2], [8.6, 8.6, 10.4, 10.4]), c = :gray95, lc = :gray70)
	annotate!(pe_1b, 5.0, 10.1, text("SPACE / top of atmosphere", 7, :gray30))
	plot!(pe_1b, Shape([0.2, 9.8, 9.8, 0.2], [3.1, 3.1, 8.2, 8.2]),
		  c = tcol(0.55 * ΔT_1b), lc = :gray60, fillalpha = 0.5)
	annotate!(pe_1b, 1.5, 7.8, text("ATMOSPHERE", 8, :gray20))
	annotate!(pe_1b, 8.2, 7.8, text(@sprintf("CO₂ %d ppm\nCH₄ %d ppb", co2_1b, ch4_1b), 7, :gray20))
	plot!(pe_1b, Shape([0.2, 9.8, 9.8, 0.2], [0.3, 0.3, 2.7, 2.7]), c = tcol(ΔT_1b), lc = :gray20)
	annotate!(pe_1b, 5.0, 1.5, text(@sprintf("SURFACE  T = %.2f K  ΔT = %+.2f K", Ts_1b, ΔT_1b), 9, :white))

	arrow_1b!(pe_1b, 1.0, 10.2, 1.0, 2.9, :goldenrod, @sprintf("solar in\n%.0f", S_in_1b); dx = -0.55)
	arrow_1b!(pe_1b, 2.3, 3.0, 2.3, 10.2, :gray45, @sprintf("reflected\n%.0f", refl_1b); dx = 0.6)
	arrow_1b!(pe_1b, 3.6, 8.0, 3.6, 5.8, :orange, @sprintf("abs. air\n%.0f", atmabs_1b); dx = 0.7)
	arrow_1b!(pe_1b, 4.6, 3.0, 4.6, 2.8, :darkorange, @sprintf("abs. sfc %.0f", sfcabs_1b); dy = 0.35)
	arrow_1b!(pe_1b, 9.0, 3.0, 9.0, 10.2, :firebrick, @sprintf("OLR\n%.0f", OLR_1b); dx = -0.55)
	arrow_1b!(pe_1b, 6.3, 2.8, 6.3, 7.9, :indianred, @sprintf("sfc LW ↑\n%.0f", LWup_1b); dx = 0.75)
	arrow_1b!(pe_1b, 7.4, 7.9, 7.4, 2.8, :crimson, @sprintf("back rad. ↓\n%.0f", LWdn_1b); dx = 0.75)
	arrow_1b!(pe_1b, 5.3, 2.8, 5.3, 6.4, :steelblue, @sprintf("latent %.0f\nsensible %.0f", LH_1b, SH_1b); dx = -0.8)

	pc_1b = plot(xlim = (0, 10), ylim = (0, 10.6), legend = false, framestyle = :none,
		         title = @sprintf("Carbon flows (GtC yr⁻¹) — airborne fraction = %.2f", af_1b))
	plot!(pc_1b, Shape([0.2, 9.8, 9.8, 0.2], [6.6, 6.6, 9.4, 9.4]), c = tcol(0.55 * ΔT_1b),
		  lc = :gray50, fillalpha = 0.5)
	annotate!(pc_1b, 5.0, 8.9, text(@sprintf("ATMOSPHERE %.0f GtC (%d ppm)", co2_1b * CALIB.GtC_per_ppm, co2_1b), 8, :gray20))
	annotate!(pc_1b, 5.0, 7.4, text(@sprintf("growth %+.2f GtC yr⁻¹", atmg_1b), 8, :black))
	plot!(pc_1b, Shape([0.2, 4.7, 4.7, 0.2], [2.6, 2.6, 5.2, 5.2]), c = :deepskyblue3, fillalpha = 0.55, lc = :gray40)
	annotate!(pc_1b, 2.45, 4.6, text("OCEAN\n≈ 38 000 GtC", 8, :white))
	annotate!(pc_1b, 2.45, 3.2, text(@sprintf("sink %.2f", ocs_1b), 8, :white))
	plot!(pc_1b, Shape([5.3, 9.8, 9.8, 5.3], [2.6, 2.6, 5.2, 5.2]), c = :seagreen, fillalpha = 0.6, lc = :gray40)
	annotate!(pc_1b, 7.55, 4.6, text(@sprintf("LAND veg %.0f + soil %.0f", CALIB.veg_C, CALIB.soil_C), 7, :white))
	annotate!(pc_1b, 7.55, 3.2, text(@sprintf("sink %.2f", lds_1b), 8, :white))
	plot!(pc_1b, Shape([3.2, 6.8, 6.8, 3.2], [0.3, 0.3, 1.6, 1.6]), c = :gray25, lc = :black)
	annotate!(pc_1b, 5.0, 0.95, text(@sprintf("FOSSIL %.1f + LUC %.1f", CALIB.E_fossil, CALIB.E_luc), 7, :white))
	arrow_1b!(pc_1b, 5.0, 1.7, 5.0, 6.5, :black, @sprintf("emissions %.1f", Etot_1b); dx = 1.35)
	arrow_1b!(pc_1b, 2.0, 6.5, 2.0, 5.3, :deepskyblue4, "")
	arrow_1b!(pc_1b, 8.0, 6.5, 8.0, 5.3, :darkgreen, "")
	annotate!(pc_1b, 5.0, 5.9, text("↓ ocean sink   ↓ land sink", 7, :gray30))

	tg_1b  = collect(range(TSCALE_1b[1], TSCALE_1b[2], length = 240))
	pcb_1b = heatmap(tg_1b, [0.0], reshape(tg_1b, 1, :), c = :thermal, colorbar = false,
		             yticks = false, xlabel = "surface temperature anomaly ΔT (K)",
		             title = @sprintf("colour scale | current ΔT = %+.2f K", ΔT_1b),
		             titlefontsize = 8)
	vline!(pcb_1b, [ΔT_1b], c = :white, lw = 4, label = "")
	vline!(pcb_1b, [0.0], c = :black, lw = 1, ls = :dash, label = "")
	vline!(pcb_1b, [1.09], c = :cyan, lw = 2, ls = :dot, label = "")

	plot(pe_1b, pc_1b, pcb_1b, layout = @layout([a b; c{0.14h}]), size = (960, 620))
end

# ╔═╡ 00000008-0000-4000-8000-000000000008
md"""
**Calibrated verification:** At default parameters (422 ppm, 1920 ppb, 100% solar, no albedo anomaly),
the energy budget matches CERES/AR6: SW in $(CALIB.SW_in), reflected $(CALIB.SW_refl), OLR $(CALIB.OLR),
surface LW up $(CALIB.LW_up_sfc), back-radiation $(CALIB.LW_dn_sfc).
"""

# ╔═╡ 00000009-0000-4000-8000-000000000009
md"""
# 2. Atmosphere

## 2a. Why the atmosphere is the pace‑setter
The atmosphere has small heat capacity compared to the ocean, yet it dictates global energy loss to space.
"""

# ╔═╡ 00000010-0000-4000-8000-000000000010
md"""
### ⚙️ 2b. Controls — vertical structure & grey radiative layers

GCMs model the atmosphere in layers, each of which interact with each other to determine the structure of the atmosphere. The first plot shows the vertical thermal profile in the atmosphere, the line that would be in equilibrium (no heating or cooling) and the layers' location. The second plot shows pressure, and the third plot shows longwave (LW) radiation, which is the radiation emitted by Earth and trapped in the greenhouse effect. Outgoing longwave radiation (OLR) is a measure of the total amount that is emitted from Earth, verus being trapped.

| Parameter | Control | Explanation |
|---|---|---|
| Number of radiating layers | $(@bind nlay_2b Slider(1:1:8, default=3, show_value=true)) | How many layers we model |
| Layer emissivity ε | $(@bind eps_2b Slider(0.1:0.05:1.0, default=0.85, show_value=true)) | How much each layer emits relative to a theoretical blackbody (perfect hot object) |
| CO₂ (ppm) | $(@bind co2_2b Slider(180:5:1200, default=422, show_value=true)) | Carbon dioxide concenration |
| Show layer labels & regime names | $(@bind labels_2b CheckBox(default=true)) | |
| Show radiative‑equilibrium profile | $(@bind radeq_2b CheckBox(default=true)) | |
"""

# ╔═╡ 00000011-0000-4000-8000-000000000011
begin
	Te_2b   = ((1 - CALIB.albedo) * CALIB.S0 / 4 / CALIB.σ)^0.25
	Nopt_2b = nlay_2b * eps_2b * (1 + 0.10 * log(co2_2b / CALIB.CO2_now) / log(2))
	Tsfc_2b = Te_2b * (1 + Nopt_2b)^0.25
	Tlay_2b = [Te_2b * max(1 + Nopt_2b - i, 0.08)^0.25 for i in 1:nlay_2b]
	ΔTs_2b  = Tsfc_2b - 288.15

	isa_T(z, dTs, dTstrat) =
		z <= 11.0  ? 288.15 - 6.5z + dTs * (1 - 0.3z / 11) :
		z <= 20.0  ? 216.65 + dTstrat :
		z <= 32.0  ? 216.65 + 1.0 * (z - 20) + dTstrat :
		z <= 47.0  ? 228.65 + 2.8 * (z - 32) + dTstrat :
		z <= 51.0  ? 270.65 + dTstrat :
		z <= 71.0  ? 270.65 - 2.8 * (z - 51) + dTstrat : 214.65 - 2.0 * (z - 71) + dTstrat

	z_2b   = collect(0:0.25:80)
	dTst   = -0.6 * ΔTs_2b
	T_2b   = [isa_T(z, ΔTs_2b, dTst) for z in z_2b]
	P_2b   = similar(T_2b); P_2b[1] = 1013.25
	for i in 2:length(z_2b)
		dz = (z_2b[i] - z_2b[i-1]) * 1000
		P_2b[i] = P_2b[i-1] * exp(-9.80665 * dz / (287.05 * 0.5 * (T_2b[i] + T_2b[i-1])))
	end
	Trad_2b = [Te_2b * max(1 + Nopt_2b * exp(-z / 7.6), 0.08)^0.25 for z in z_2b]

	function emis_height(Tt)
		k = argmin(abs.(T_2b[1:120] .- Tt))
		z_2b[k]
	end
	zl_2b = emis_height.(Tlay_2b)

	p1_2b = plot(T_2b, z_2b, lw = 2.5, c = :black, label = "thermal structure",
		         xlabel = "temperature (K)", ylabel = "altitude (km)", ylim = (0, 60),
		         title = "vertical structure")
	radeq_2b && plot!(p1_2b, Trad_2b, z_2b, lw = 2, ls = :dash, c = :firebrick,
		              label = "radiative equilibrium")
	for (i, zl) in enumerate(zl_2b)
		hline!(p1_2b, [zl], c = :steelblue, lw = 1.2, ls = :dot, label = i == 1 ? "grey layers" : "")
	end
	scatter!(p1_2b, [Tsfc_2b], [0.0], m = :star5, ms = 8, c = :orangered, label = @sprintf("grey Tₛ = %.1f K", Tsfc_2b))

	p2_2b = plot(P_2b, z_2b, lw = 2.5, c = :navy, label = "", xscale = :log10,
		         xlabel = "pressure (hPa)", ylabel = "altitude (km)", ylim = (0, 60),
		         title = "hydrostatic pressure")

	up_2b = [CALIB.σ * Tsfc_2b^4]
	for i in 1:nlay_2b
		push!(up_2b, (1 - eps_2b) * up_2b[end] + eps_2b * CALIB.σ * Tlay_2b[i]^4)
	end
	dn_2b = zeros(nlay_2b + 1)
	for i in nlay_2b:-1:1
		dn_2b[i] = (1 - eps_2b) * dn_2b[i+1] + eps_2b * CALIB.σ * Tlay_2b[i]^4
	end
	lvl_2b = 0:nlay_2b
	p3_2b = plot(up_2b, lvl_2b, lw = 2.5, m = :circle, c = :firebrick, label = "LW up",
		         xlabel = "LW flux (W m⁻²)", ylabel = "interface (0 = sfc)",
		         title = @sprintf("grey fluxes: OLR = %.1f", up_2b[end]))
	plot!(p3_2b, dn_2b, lvl_2b, lw = 2.5, m = :square, c = :steelblue, label = "LW down")

	plot(p1_2b, p2_2b, p3_2b, layout = (1, 3), size = (1000, 430))
end

# ╔═╡ 00000012-0000-4000-8000-000000000012
md"""
Adding opaque layers raises surface temperature via downwelling infrared radiation. Real atmospheres convect, adjusting the profile closer to a 6.5 K/km tropospheric lapse rate.
"""

# ╔═╡ 00000013-0000-4000-8000-000000000013
md"""
## 2c. Storm cells and circulation — Navier–Stokes core
Next, we look at spatial changes across the atmosphere, using a simplified formulation known as the 2-D Boussinesq model in vorticity-streamfunction formulation.
"""

# ╔═╡ 00000014-0000-4000-8000-000000000014
md"""
### ⚙️ 2c. Controls — convective storm cell
In addition to having vertical resolution in modeling the atmosphere, we also have horizontal resolution. This simulation highlights a convective storm cell, a particularly import feature in the atmosphere. These storm cells not only lead to extreme weather events, but mimic the structure of larger scale circulation in the atmosphere, creating the Hadley (equatorial), mid-latitude, and polar cells that make up the basic structure of the atmosphere. Different physical parameters, relating to heat and velocity exchange vertically, can produce different horizontal patterns as well. The two plots at the top show the streamlines (velocity) of buoyant and non-buoyant motion, and those at the bottom highlight the gradient of buoyancy in the atmosphere, as well as the external thermal flux produced by the selected parameters.

| Parameter | Control | Explanation |
|---|---|---|
| log₁₀ Rayleigh number | $(@bind ra_2c Slider(3.5:0.25:7.0, default=5.5, show_value=true)) | The log of the ratio between buoyant forces and viscous and thermal damping |
| Background wind shear | $(@bind shear_2c Slider(0:0.5:8, default=2.0, show_value=true)) | The rate of change of the wind speed with height |
| Latent heating strength | $(@bind latent_2c Slider(0:0.1:1.5, default=0.4, show_value=true)) | The rate of change of heat with height |
| Time steps | $(@bind steps_2c Slider(200:100:2500, default=1000, show_value=true)) | Temporal resolution |
| Grid | $(@bind nx_2c Select([64 => "64 × 32 (fast)", 96 => "96 × 48 (default)", 128 => "128 × 64 (slow)"], default=96)) | Spatial resolution |
"""

# ╔═╡ 00000015-0000-4000-8000-000000000015
function run_convection(; nx = 96, nz = 48, Ra = 1e5, Pr = 0.71, shear = 0.0,
		                  latent = 0.0, nsteps = 1000)
	Lx, Lz = 2.0, 1.0
	dx, dz = Lx / nx, Lz / nz
	x = collect((0.5:1.0:nx) .* dx)
	z = collect((0.5:1.0:nz) .* dz)
	ν, κ = sqrt(Pr / Ra), 1 / sqrt(Pr * Ra)
	b = [(1 - z[k]) + 0.02 * sin(3π * x[i] / Lx) * sin(π * z[k]) for i in 1:nx, k in 1:nz]
	ω = zeros(nx, nz); ψ = zeros(nx, nz); u = zeros(nx, nz); w = zeros(nx, nz)
	bn = similar(b); ωn = similar(ω)
	ipx(i) = i == nx ? 1 : i + 1
	imx(i) = i == 1 ? nx : i - 1
	t = 0.0
	for _ in 1:nsteps
		for _ in 1:20
			@inbounds for k in 2:nz-1, i in 1:nx
				ψs = ((ψ[ipx(i), k] + ψ[imx(i), k]) / dx^2 +
					  (ψ[i, k+1] + ψ[i, k-1]) / dz^2 + ω[i, k]) / (2 / dx^2 + 2 / dz^2)
				ψ[i, k] += 1.75 * (ψs - ψ[i, k])
			end
		end
		ψ[:, 1] .= 0.0; ψ[:, nz] .= 0.0
		@inbounds for k in 1:nz, i in 1:nx
			kp, km = min(k + 1, nz), max(k - 1, 1)
			u[i, k] = (ψ[i, kp] - ψ[i, km]) / ((kp - km) * dz) + shear * (z[k] - 0.5)
			w[i, k] = -(ψ[ipx(i), k] - ψ[imx(i), k]) / (2dx)
		end
		dt = 0.2 * min(dx / (maximum(abs, u) + 1e-9), dz / (maximum(abs, w) + 1e-9),
			           0.5 * min(dx, dz)^2 / max(ν, κ))
		@inbounds for k in 1:nz, i in 1:nx
			kp, km = min(k + 1, nz), max(k - 1, 1)
			iq, ir = ipx(i), imx(i)
			aω = u[i, k] > 0 ? u[i, k] * (ω[i, k] - ω[ir, k]) / dx : u[i, k] * (ω[iq, k] - ω[i, k]) / dx
			aω += w[i, k] > 0 ? w[i, k] * (ω[i, k] - ω[i, km]) / dz : w[i, k] * (ω[i, kp] - ω[i, k]) / dz
			lω = (ω[iq, k] - 2ω[i, k] + ω[ir, k]) / dx^2 + (ω[i, kp] - 2ω[i, k] + ω[i, km]) / dz^2
			ωn[i, k] = ω[i, k] + dt * (-aω + ν * lω + (b[iq, k] - b[ir, k]) / (2dx))
			ab = u[i, k] > 0 ? u[i, k] * (b[i, k] - b[ir, k]) / dx : u[i, k] * (b[iq, k] - b[i, k]) / dx
			ab += w[i, k] > 0 ? w[i, k] * (b[i, k] - b[i, km]) / dz : w[i, k] * (b[i, kp] - b[i, k]) / dz
			lb = (b[iq, k] - 2b[i, k] + b[ir, k]) / dx^2 + (b[i, kp] - 2b[i, k] + b[i, km]) / dz^2
			heat = latent * max(w[i, k], 0.0) * max(b[i, k] - 0.15, 0.0)
			bn[i, k] = clamp(b[i, k] + dt * (-ab + κ * lb + heat), -0.6, 2.5)
		end
		b .= bn; ω .= ωn
		b[:, 1] .= 1.0; b[:, nz] .= 0.0
		ω[:, 1] .= 0.0; ω[:, nz] .= 0.0
		t += dt
	end
	bbar = vec(mean(b, dims = 1))
	flux = vec(mean(w .* (b .- mean(b, dims = 1)), dims = 1))
	(x = x, z = z, b = b, ψ = ψ, u = u, w = w, t = t, bbar = bbar, flux = flux,
	 Nu = 1 + mean(flux) / κ, wmax = maximum(w), ν = ν, κ = κ)
end

# ╔═╡ 00000016-0000-4000-8000-000000000016
begin
	conv_2c = run_convection(nx = nx_2c, nz = nx_2c ÷ 2, Ra = 10.0^ra_2c,
		                     shear = shear_2c, latent = latent_2c, nsteps = steps_2c)

	pA_2c = heatmap(conv_2c.x, conv_2c.z, permutedims(conv_2c.b), c = cgrad(:RdBu, rev = true),
		            clims = (-0.2, 1.2), xlabel = "x", ylabel = "z",
		            title = "buoyancy + streamlines")
	contour!(pA_2c, conv_2c.x, conv_2c.z, permutedims(conv_2c.ψ), levels = 14, c = :black, lw = 0.7, label = "")

	pB_2c = heatmap(conv_2c.x, conv_2c.z, permutedims(conv_2c.w), c = :balance,
		            clims = (-maximum(abs, conv_2c.w), maximum(abs, conv_2c.w)),
		            xlabel = "x", ylabel = "z", title = "vertical velocity w")

	pC_2c = plot(conv_2c.bbar, conv_2c.z, lw = 2.5, c = :black, label = "⟨b⟩",
		         xlabel = "mean buoyancy", ylabel = "z", title = "mean state")

	pD_2c = plot(conv_2c.flux ./ max(maximum(abs, conv_2c.flux), 1e-12), conv_2c.z, lw = 2.5,
		         c = :darkorange, label = "⟨w′b′⟩", xlabel = "normalized flux",
		         ylabel = "z", title = @sprintf("resolved flux: Nu ≈ %.1f", conv_2c.Nu))
	vline!(pD_2c, [0], c = :gray, lw = 1, label = "")

	plot(pA_2c, pB_2c, pC_2c, pD_2c, layout = (2, 2), size = (1000, 640))
end

# ╔═╡ 00000017-0000-4000-8000-000000000017
md"""
The resolved vertical convective heat transport sets the Nusselt number $Nu$, which is the ratio of convective to conductive heat transport, and can be derived from the simulation above. At GCM grid scales of $\sim 100\text{ km}$, this cannot be resolved and must be parameterized.
"""

# ╔═╡ 00000018-0000-4000-8000-000000000018
md"""
## 2d. Discretisation: Grid‑point vs Spectral

This section focuses on briding the physics and some computational challenges, moving from our simple 2D plots above to how to deal with real calculations of the atmosphere. 

The physics undelying the atmospheric phenomenon above (and the dynamics throughout a GCM) generally follow a system of partial differential equations. To solve these, many GCMs take the same approach as used above, where we split the continuous domains of both time and space into discrete chunks, and approximate derivatives with small deltas. However, some GCMs use what's called spectral approaches, which instead split these into simpler functions that add to solve it globally. These plots highlight the differences in the calculated derivatives (upper left), the relative error of these methods as the spatial resolution increases (upper right).

In addition, real GCMs don't solve things on a planar grid, as the atmosphere is spherical. The lower left plot highlight the change in the speed at which the model can be solved, as dictated by the Courant-Friedrichs-Lewy (CFL) condition, , which says that the model can only be solved with a real world timestep such that the equations lead to quantities propogating faster than physical velocities. This is highlighted in the lower left.

Another issue, unique to the spectral method, can occur when functions with sharp derivatives are modeled. Since the spectral method reconstructs with component functions, which are typically smoother, it can lead to a truncation of data past a certain point. This is dependent on the front steepness, and highlighted in the lower right. 

### ⚙️ Controls

| Parameter | Control | Explanation |
|---|---|---|
| Grid points N | $(@bind n_2d Slider(8:4:192, default=48, show_value=true)) | Spatial resolution horizontally, planar|
| Test field | $(@bind fun_2d Select(["smooth" => "smooth: exp(sin x)", "front" => "sharp front: tanh(s·sin x)"])) | Large versus small function gradient |
| Front steepness s | $(@bind steep_2d Slider(2:1:30, default=12, show_value=true)) | Slope of the hyperbolic tangent profile |
| Lat–lon resolution for pole diagnostic (°) | $(@bind dlat_2d Slider(0.25:0.25:4.0, default=1.0, show_value=true)) | Spatial resolution vertically, projected onto a sphere |
"""

# ╔═╡ 00000019-0000-4000-8000-000000000019
begin
	function dft_matrix(N)
		j = collect(0:N-1)
		cis.(-2π .* (j * j') ./ N)
	end
	function spec_dx(f, L)
		N = length(f)
		W = dft_matrix(N); Wi = conj(W) ./ N
		k = (2π / L) .* vcat(0:(N ÷ 2 - 1), -(N ÷ 2):-1)
		real.(Wi * ((im .* k) .* (W * Complex.(f))))
	end
	fd2_dx(f, dx) = [(f[mod1(i + 1, length(f))] - f[mod1(i - 1, length(f))]) / (2dx) for i in eachindex(f)]
	fd4_dx(f, dx) = [(-f[mod1(i + 2, length(f))] + 8f[mod1(i + 1, length(f))] -
		              8f[mod1(i - 1, length(f))] + f[mod1(i - 2, length(f))]) / (12dx) for i in eachindex(f)]

	u_exact(x)  = fun_2d == "smooth" ? exp(sin(x)) : tanh(steep_2d * sin(x))
	du_exact(x) = fun_2d == "smooth" ? cos(x) * exp(sin(x)) :
		          steep_2d * cos(x) * (1 - tanh(steep_2d * sin(x))^2)

	L_2d  = 2π
	x_2d  = collect(range(0, L_2d, length = n_2d + 1))[1:end-1]
	dx_2d = x_2d[2] - x_2d[1]
	f_2d  = u_exact.(x_2d)
	d_ex  = du_exact.(x_2d)
	d_s   = spec_dx(f_2d, L_2d)
	d_2   = fd2_dx(f_2d, dx_2d)
	d_4   = fd4_dx(f_2d, dx_2d)

	Ns_2d = [8, 12, 16, 24, 32, 48, 64, 96, 128, 192]
	err_2d = map(Ns_2d) do N
		xx = collect(range(0, L_2d, length = N + 1))[1:end-1]
		dxx = xx[2] - xx[1]
		ff = u_exact.(xx); ee = du_exact.(xx)
		nrm = maximum(abs, ee)
		(maximum(abs, fd2_dx(ff, dxx) .- ee) / nrm,
		 maximum(abs, fd4_dx(ff, dxx) .- ee) / nrm,
		 maximum(abs, spec_dx(ff, L_2d) .- ee) / nrm)
	end

	pA_2d = plot(x_2d, d_ex, lw = 3, c = :black, label = "exact", xlabel = "x", ylabel = "du/dx", title = "derivatives")
	plot!(pA_2d, x_2d, d_s, lw = 1.8, c = :royalblue, m = :circle, ms = 2, label = "spectral")
	plot!(pA_2d, x_2d, d_2, lw = 1.5, c = :orangered, ls = :dash, label = "FD2")
	plot!(pA_2d, x_2d, d_4, lw = 1.5, c = :seagreen, ls = :dot, label = "FD4")

	pB_2d = plot(Ns_2d, getindex.(err_2d, 1), lw = 2, m = :square, c = :orangered,
		         label = "FD2", xscale = :log10, yscale = :log10, xlabel = "N", ylabel = "rel err", ylim = (1e-16, 10))
	plot!(pB_2d, Ns_2d, getindex.(err_2d, 2), lw = 2, m = :diamond, c = :seagreen, label = "FD4")
	plot!(pB_2d, Ns_2d, max.(getindex.(err_2d, 3), 1e-16), lw = 2.5, m = :circle, c = :royalblue, label = "spectral")

	lat_2d = collect(-89.5:0.5:89.5)
	a_earth = 6371.0
	dx_km  = @. a_earth * deg2rad(dlat_2d) * cos(deg2rad(lat_2d))
	dt_max = @. dx_km * 1000 / 100
	pC_2d = plot(lat_2d, dt_max ./ 60, lw = 2.5, c = :purple, label = "lat–lon CFL",
		         xlabel = "latitude (°)", ylabel = "max stable Δt (min)", yscale = :log10,
		         title = "pole problem convergence limit")

	trunc_frac = 0.5
	Wf = dft_matrix(n_2d); Wb = conj(Wf) ./ n_2d
	F̂ = Wf * Complex.(f_2d)
	kk = vcat(0:(n_2d ÷ 2 - 1), -(n_2d ÷ 2):-1)
	F̂t = [abs(kk[i]) <= trunc_frac * n_2d / 2 ? F̂[i] : 0.0 + 0im for i in eachindex(F̂)]
	f_trunc = real.(Wb * F̂t)
	pD_2d = plot(x_2d, f_2d, lw = 2.5, c = :black, label = "field", xlabel = "x", title = "Gibbs ringing")
	plot!(pD_2d, x_2d, f_trunc, lw = 2, c = :royalblue, label = "truncated")

	plot(pA_2d, pB_2d, pC_2d, pD_2d, layout = (2, 2), size = (1000, 650))
end

# ╔═╡ 00000020-0000-4000-8000-000000000020
md"""
## 2e. Cloud parameterization — regimes and feedback

A key atmospheric phenomenon not covered in fluid and thermal flow physics is cloud formation and cloud effects. Since clouds occur at a much smaller physical scale than the spatial resolution of GCMs, their effects are instead parameterized by simpler models capturing what they do in the aggregate. The upper left plot highlights the difference in cloud cover across common parameterized models, while the upper right highlights the Twomey effect, in which greater cloud condensation nuclei densities change how reflective clouds are. The strength of this effect, and the concentration of cloud condensation nuclei, is a key source of uncertainty in GCMs. The lower right shows the effect of various cloud types on shortwave (SW) radiation, which relates to how well the absorb incoming sunlight, and longwave (LW) radiation, which relates to how well they trap outgoing radiation from the Earth. Lastly, the autoconversion plot shows the relationship between water content and rain, a key relationship used to determine things like extreme rainfall events in GCMs.

### ⚙️ Controls

| Parameter | Control | Explanation |
|---|---|---|
| Critical RH (Sundqvist) | $(@bind rhc_2e Slider(0.5:0.01:0.99, default=0.8, show_value=true)) | Relative humidity used for condensation to start in the Sundqvist cloud model |
| Subgrid humidity σ (PDF scheme) | $(@bind sig_2e Slider(0.02:0.01:0.30, default=0.10, show_value=true)) | Localized standard deviation of humidity levels|
| Droplet number N_d (cm⁻³) | $(@bind nd_2e Slider(20:10:800, default=100, show_value=true)) | Concentration of the cloud condensation nuclei on which water droplets form |
| Autoconversion threshold (g m⁻³) | $(@bind thr_2e Slider(0.05:0.05:1.5, default=0.5, show_value=true)) | Density required for water droplets to turn into falling raindrops |
| Highlight regime | $(@bind regime_2e Select(["Sc" => "Marine stratocumulus", "Cu" => "Shallow cumulus", "Deep" => "Deep convection / anvil", "Ci" => "Thin cirrus"])) | Cloud type to use for rain rate plot|
"""

# ╔═╡ 00000021-0000-4000-8000-000000000021
begin
	Φnorm(x) = 0.5 * (1 + tanh(0.7978845608 * (x + 0.044715 * x^3)))
	cf_binary(rh) = rh >= 1.0 ? 1.0 : 0.0
	cf_sundqvist(rh, rhc) = rh <= rhc ? 0.0 : (rh >= 1 ? 1.0 : 1 - sqrt(max(0.0, (1 - rh) / (1 - rhc))))
	cf_pdf(rh, σ) = Φnorm((rh - 1) / σ)

	function cloud_optics(LWP, Nd, H; ρw = 1000.0)
		lwp = LWP / 1000
		nd  = Nd * 1e6
		re  = (3 * lwp / (4π * ρw * nd * max(H, 1.0)))^(1 / 3)
		re  = clamp(re, 2e-6, 40e-6)
		τ   = 3 * lwp / (2 * ρw * re)
		(re_μm = re * 1e6, τ = τ, albedo = τ / (τ + 13.3))
	end

	REGIMES_2e = (
		Sc   = (name = "Stratocumulus", LWP = 80.0,  H = 300.0,   Ttop = 283.0, CF = 0.70, Nd0 = 120.0),
		Cu   = (name = "Shallow cumulus", LWP = 30.0, H = 1200.0, Ttop = 278.0, CF = 0.20, Nd0 = 80.0),
		Deep = (name = "Deep conv. / anvil", LWP = 600.0, H = 12000.0, Ttop = 220.0, CF = 0.50, Nd0 = 60.0),
		Ci   = (name = "Thin cirrus", LWP = 15.0, H = 2000.0, Ttop = 215.0, CF = 0.30, Nd0 = 0.3),
	)

	function cre_regime(r, Nd)
		o = cloud_optics(r.LWP, Nd, r.H)
		A_clear = 0.12
		sw = -r.CF * (o.albedo - A_clear) * CALIB.SW_in
		lw = r.CF * (CALIB.σ * 288.6^4 * 0.62 - CALIB.σ * r.Ttop^4)
		(sw = sw, lw = lw, net = sw + lw, τ = o.τ, re = o.re_μm, albedo = o.albedo)
	end

	rh_2e  = collect(0.4:0.005:1.15)
	pA_2e  = plot(rh_2e, cf_binary.(rh_2e), lw = 2, c = :gray30, label = "binary", xlabel = "RH", ylabel = "cloud fraction")
	plot!(pA_2e, rh_2e, cf_sundqvist.(rh_2e, rhc_2e), lw = 2.5, c = :royalblue, label = "Sundqvist")
	plot!(pA_2e, rh_2e, cf_pdf.(rh_2e, sig_2e), lw = 2.5, c = :darkorange, label = "PDF")

	lwp_2e = collect(1:2:400)
	pB_2e  = plot(xlabel = "LWP (g m⁻²)", ylabel = "cloud albedo", title = "Twomey effect", legend = :bottomright)
	for (nd, c) in [(40.0, :steelblue), (100.0, :seagreen), (400.0, :firebrick)]
		plot!(pB_2e, lwp_2e, [cloud_optics(l, nd, 400.0).albedo for l in lwp_2e], lw = 2, c = c, label = "N_d = $(Int(nd))")
	end

	keys_2e = [:Sc, :Cu, :Deep, :Ci]
	cre_2e  = [cre_regime(getproperty(REGIMES_2e, k), Float64(nd_2e)) for k in keys_2e]
	names_2e = [getproperty(REGIMES_2e, k).name for k in keys_2e]
	xs_2e   = collect(1:4)
	pC_2e   = bar(xs_2e .- 0.22, getfield.(cre_2e, :sw), bar_width = 0.2, c = :steelblue, label = "SW CRE",
		          xticks = (xs_2e, names_2e), ylabel = "W m⁻²", title = "CRE by regime", xrotation = 20)
	bar!(pC_2e, xs_2e, getfield.(cre_2e, :lw), bar_width = 0.2, c = :firebrick, label = "LW CRE")
	bar!(pC_2e, xs_2e .+ 0.22, getfield.(cre_2e, :net), bar_width = 0.2, c = :black, label = "net")

	lwc_2e = collect(0:0.02:2.5)
	k_auto = 1.5
	pD_2e  = plot(lwc_2e, [k_auto * max(0.0, l - thr_2e)^1.3 for l in lwc_2e], lw = 3, c = :navy,
		          label = "autoconversion", xlabel = "liquid water content (g m⁻³)", ylabel = "rain rate (arb.)")

	plot(pA_2e, pB_2e, pC_2e, pD_2e, layout = (2, 2), size = (1000, 680))
end

# ╔═╡ 00000022-0000-4000-8000-000000000022
md"""
## ⚙️ 2f. Controls — 3‑D test atmosphere

Now, it's time to put it all together with this 3D test atmosphere! It is visualized below as a sphere, surrounded by a velocity field of a few particles moving about.

| Parameter | Control | Explanation |
|---|---|---|
| Steps (0.5 day each) | $(@bind steps_2f Slider(200:100:2500, default=1200, show_value=true)) | Temporal scale |
| Eddy heat transport (diffusion) | $(@bind diff_2f Slider(0.0:0.01:0.24, default=0.12, show_value=true)) | Heat movement rate horizontally |
| CO₂ (ppm) | $(@bind co2_2f Slider(180:10:1200, default=422, show_value=true)) | Carbon dioxide concentration |
| Stationary‑wave forcing | $(@bind wave_2f Slider(0:0.25:3, default=1.0, show_value=true)) | Additional heat input level |
| Convective lapse rate Γ (K km⁻¹) | $(@bind lapse_2f Slider(4.0:0.25:9.8, default=6.5, show_value=true)) | Rate of convection, controls whether parcels in the atmosphere fall or rise |
"""

# ╔═╡ 00000023-0000-4000-8000-000000000023
function run_atm3d(; nlon = 32, nlat = 16, nlev = 12, nsteps = 1200, Dh = 0.12,
		             co2 = 422.0, wave = 1.0, Γ = 6.5, τrad = 15.0)
	lat = collect(range(-85, 85, length = nlat))
	lon = collect(range(0, 360 - 360 / nlon, length = nlon))
	p   = collect(range(1000, 80, length = nlev))
	H   = 7.6
	zk  = @. -H * log(p / 1000)
	φ   = deg2rad.(lat)
	Q   = @. CALIB.S0 / 4 * (1 - 0.477 * 0.5 * (3 * sin(φ)^2 - 1))
	αl  = @. CALIB.albedo + 0.12 * (abs(lat) / 90)^3
	τg  = 0.636 * (co2 / CALIB.CO2_now)^0.10
	Tsr = @. (((1 - αl) * Q * (1 + τg)) / CALIB.σ)^0.25
	ztrop = @. 16.0 - 7.0 * (abs(lat) / 90)^1.5
	Teq = [max(Tsr[j] - Γ * min(zk[k], ztrop[j]), 0.72 * Tsr[j] - 15) for j in 1:nlat, k in 1:nlev]
	T = zeros(nlon, nlat, nlev)
	for i in 1:nlon
		T[i, :, :] .= Teq
	end
	Fw = [wave * 3.0 * cos(deg2rad(lon[i])) * exp(-((lat[j] - 45) / 25)^2) * exp(-zk[k] / 12)
	      for i in 1:nlon, j in 1:nlat, k in 1:nlev]
	Tn = similar(T)
	dt = 0.5
	for _ in 1:nsteps
		@inbounds for k in 1:nlev, j in 1:nlat, i in 1:nlon
			iq = i == nlon ? 1 : i + 1; ir = i == 1 ? nlon : i - 1
			jp = min(j + 1, nlat); jm = max(j - 1, 1)
			lapT = (T[iq, j, k] + T[ir, j, k] - 2T[i, j, k]) +
			       (T[i, jp, k] + T[i, jm, k] - 2T[i, j, k])
			Tn[i, j, k] = T[i, j, k] + Dh * lapT +
			              dt * (-(T[i, j, k] - Teq[j, k]) / τrad + Fw[i, j, k] / τrad)
		end
		T .= Tn
		@inbounds for i in 1:nlon, j in 1:nlat, k in 1:nlev-1
			dz = max(zk[k+1] - zk[k], 1e-6)
			Γloc = (T[i, j, k] - T[i, j, k+1]) / dz
			if Γloc > Γ
				ΔT = (Γloc - Γ) * dz / 2
				T[i, j, k]   -= ΔT
				T[i, j, k+1] += ΔT
			end
		end
	end
	Tzm = dropdims(mean(T, dims = 1), dims = 1)
	R, a, Ω = 287.05, 6.371e6, 7.292e-5
	u = zeros(nlat, nlev)
	for j in 1:nlat
		abs(sin(φ[j])) < 0.15 && continue
		f = 2Ω * sin(φ[j])
		for k in 2:nlev
			jp = min(j + 1, nlat); jm = max(j - 1, 1)
			dTdy = (Tzm[jp, k] - Tzm[jm, k]) / ((φ[jp] - φ[jm]) * a)
			u[j, k] = u[j, k-1] + (R / f) * dTdy * log(p[k] / p[k-1])
		end
	end
	wts = cos.(φ) ./ sum(cos.(φ))
	(lon = lon, lat = lat, p = p, z = zk, T = T, Tzm = Tzm, u = u, Ts = T[:, :, 1],
	 Tglobal = sum(mean(T[:, :, 1], dims = 1)[:] .* wts), τg = τg, Teq = Teq)
end

# ╔═╡ 00000024-0000-4000-8000-000000000024
begin
    let
        atm_2f = run_atm3d(
            nsteps = steps_2f,
            Dh = diff_2f,
            co2 = co2_2f,
            wave = wave_2f,
            Γ = lapse_2f
        )

        # ============================================================
        # 3-D VELOCITY FIELD ANIMATION
        # ============================================================

        lon_3d = atm_2f.lon
        lat_3d = atm_2f.lat
        p_3d   = atm_2f.p
        z_3d   = atm_2f.z
        u_3d   = atm_2f.u

        nlon_3d = length(lon_3d)
        nlat_3d = length(lat_3d)
        nlev_3d = length(p_3d)

        # Expand the zonal-mean velocity field around longitude
        ufield_3d = zeros(nlon_3d, nlat_3d, nlev_3d)

        for ii in 1:nlon_3d
            ufield_3d[ii, :, :] .= u_3d
        end

        # ============================================================
        # SPHERICAL COORDINATES
        # ============================================================

        Rplanet_3d = 1.0
        zscale_3d = 0.12

        λ_3d = deg2rad.(lon_3d)
        φ_3d = deg2rad.(lat_3d)

        X_3d = zeros(nlon_3d, nlat_3d, nlev_3d)
        Y_3d = zeros(nlon_3d, nlat_3d, nlev_3d)
        Z_3d = zeros(nlon_3d, nlat_3d, nlev_3d)

        for kk in 1:nlev_3d
            radius_3d = Rplanet_3d + zscale_3d * z_3d[kk]

            for jj in 1:nlat_3d
                for ii in 1:nlon_3d
                    X_3d[ii,jj,kk] =
                        radius_3d * cos(φ_3d[jj]) * cos(λ_3d[ii])

                    Y_3d[ii,jj,kk] =
                        radius_3d * cos(φ_3d[jj]) * sin(λ_3d[ii])

                    Z_3d[ii,jj,kk] =
                        radius_3d * sin(φ_3d[jj])
                end
            end
        end

        # ============================================================
        # PARTICLES
        # ============================================================

        nparticles_3d = 350
        rng_3d = MersenneTwister(42)

        particle_lon_3d =
            rand(rng_3d, nparticles_3d) .* 360.0

        particle_lat_3d =
            rand(rng_3d, nparticles_3d) .* 150.0 .- 75.0

        particle_lev_3d =
            rand(rng_3d, nparticles_3d) .* (nlev_3d - 1) .+ 1

        # ------------------------------------------------------------
        # Look up velocity at nearest latitude / pressure level
        # ------------------------------------------------------------

        function velocity_at_3d(λdeg, φdeg, lev)

            jj = argmin(abs.(lat_3d .- φdeg))

            kk = clamp(
                round(Int, lev),
                1,
                nlev_3d
            )

            return u_3d[jj, kk]
        end

        # ------------------------------------------------------------
        # Convert particle position to Cartesian coordinates
        # ------------------------------------------------------------

        function particle_xyz_3d(i)

            φp = deg2rad(particle_lat_3d[i])
            λp = deg2rad(particle_lon_3d[i])

            kk1 = clamp(
                floor(Int, particle_lev_3d[i]),
                1,
                nlev_3d
            )

            kk2 = clamp(
                kk1 + 1,
                1,
                nlev_3d
            )

            frac_3d =
                particle_lev_3d[i] - kk1

            zp =
                (1 - frac_3d) * z_3d[kk1] +
                frac_3d * z_3d[kk2]

            radius_p =
                Rplanet_3d + zscale_3d * zp

            return (
                radius_p * cos(φp) * cos(λp),
                radius_p * cos(φp) * sin(λp),
                radius_p * sin(φp)
            )
        end

        # ============================================================
        # ANIMATION
        # ============================================================

        anim_3d = @animate for frame_3d in 1:120

            # Advance particles east/west according to u
            for ii in 1:nparticles_3d

                ui_3d = velocity_at_3d(
                    particle_lon_3d[ii],
                    particle_lat_3d[ii],
                    particle_lev_3d[ii]
                )

                # Convert m/s → degrees longitude per frame
                particle_lon_3d[ii] +=
                    ui_3d * 2.0e5 /
                    (2π * 6.371e6) * 360.0

                particle_lon_3d[ii] =
                    mod(particle_lon_3d[ii], 360.0)

                # Tiny vertical motion purely for visual 3-D structure
                particle_lev_3d[ii] +=
                    0.015 *
                    sin(0.12 * frame_3d + ii)

                particle_lev_3d[ii] =
                    clamp(
                        particle_lev_3d[ii],
                        1.0,
                        Float64(nlev_3d)
                    )
            end

            # Particle coordinates
            px_3d = zeros(nparticles_3d)
            py_3d = zeros(nparticles_3d)
            pz_3d = zeros(nparticles_3d)
            pu_3d = zeros(nparticles_3d)

            for ii in 1:nparticles_3d

                px_3d[ii],
                py_3d[ii],
                pz_3d[ii] = particle_xyz_3d(ii)

                pu_3d[ii] = velocity_at_3d(
                    particle_lon_3d[ii],
                    particle_lat_3d[ii],
                    particle_lev_3d[ii]
                )
            end

            # ========================================================
            # PLOT
            # ========================================================

            umax_3d =
                max(maximum(abs.(u_3d)), 1.0)

            plt_3d = plot(
                xlim = (-1.15, 1.15),
                ylim = (-1.15, 1.15),
                zlim = (-1.15, 1.15),

                aspect_ratio = :equal,

                xlabel = "x",
                ylabel = "y",
                zlabel = "z",

                title = @sprintf(
                    "3-D Atmospheric Velocity Field — frame %d",
                    frame_3d
                ),

                camera = (45, 25),

                legend = false,

                size = (900, 750)
            )

            # Planet surface
            surface!(
                plt_3d,
                X_3d[:,:,1],
                Y_3d[:,:,1],
                Z_3d[:,:,1],

                c = :lightblue,
                alpha = 0.18,

                colorbar = false,
                label = ""
            )

            # Moving velocity particles
            scatter!(
                plt_3d,
                px_3d,
                py_3d,
                pz_3d,

                marker_z = pu_3d,

                markersize = 3.5,
                markerstrokewidth = 0,

                c = :balance,
                clims = (-umax_3d, umax_3d),

                colorbar = true,
                colorbar_title = "zonal velocity (m/s)",

                label = ""
            )

            # Latitude rings
            for φdeg_3d in (-60, -30, 0, 30, 60)

                φring_3d =
                    deg2rad(φdeg_3d)

                ring_radius_3d =
                    Rplanet_3d +
                    zscale_3d * z_3d[1]

                θring_3d =
                    range(
                        0,
                        2π,
                        length = 100
                    )

                ring_x_3d = [
                    ring_radius_3d *
                    cos(φring_3d) *
                    cos(θ)

                    for θ in θring_3d
                ]

                ring_y_3d = [
                    ring_radius_3d *
                    cos(φring_3d) *
                    sin(θ)

                    for θ in θring_3d
                ]

                ring_z_3d = fill(
                    ring_radius_3d *
                    sin(φring_3d),
                    100
                )

                plot!(
                    plt_3d,
                    ring_x_3d,
                    ring_y_3d,
                    ring_z_3d,

                    lw = 0.5,
                    alpha = 0.25,
                    c = :black,

                    label = ""
                )
            end

            plt_3d
        end

        # ============================================================
        # DISPLAY GIF IN PLUTO
        # ============================================================

        gif(
            anim_3d,
            fps = 15
        )
    end
end

# ╔═╡ 00000025-0000-4000-8000-000000000025
md"""
Thermal wind balance directly relates horizontal temperature gradients to the vertical shear of the jet stream.
"""

# ╔═╡ 00000026-0000-4000-8000-000000000026
md"""
# 3. Ocean

## 3a. Ocean heat and overturning

The atmosphere, however, is not the only important source of movement in the climate system that needs to be modeled with complex fluid dynamics equations. The ocean is also a key source of movement and uncertainty.

### ⚙️ 3b. Controls — overturning circulation (Stommel two‑box)

One of the key flows in the ocean is overturning circulation, which is large scale movement of hot and cold water masses throughout the ocean. A key risk of this is whether this overturning circulation might stop, particularly a portion of it known as the Atlantic Meridional Overturning Circulaiton (AMOC), which would lead to dramatic cooling in Europe and dramatic warming in America. A plot of the strength of AMOC over time under such a scenario is visible in the upper left, a plot of how it changes in phase space across the change in flow and in time is in the upper right, and a plot of the two paths it can take is in the lower left. Lastly, the circulation itself is visualized at different flow rates, measured in Sverdups (Sv) in the lower right.

| Parameter | Control | Explanation |
|---|---|---|
| Freshwater forcing η₂ | $(@bind eta2_3b Slider(0.0:0.02:2.2, default=0.9, show_value=true)) | Amount of freshwater entering the ocean |
| Thermal forcing η₁ | $(@bind eta1_3b Slider(1.0:0.1:5.0, default=3.0, show_value=true)) | Difference in atmospheric temperature between the equator and the north pole |
| Flow sensitivity η₃ | $(@bind eta3_3b Slider(0.1:0.05:1.5, default=0.4, show_value=true)) | How much the circulation effects water moving in other direction (advection) |
| State selection | $(@bind init_3b Select(["on" => "strong overturning (present-day)", "off" => "collapsed state"])) | |
| Calculate hysteresis curve | $(@bind hyst_3b CheckBox(default=true)) | |
"""

# ╔═╡ 00000027-0000-4000-8000-000000000027
begin
	function stommel_step(ΔT, ΔS, η1, η2, η3, dt)
		q = η3 * abs(ΔT - ΔS)
		(ΔT + dt * (η1 - ΔT * (1 + q)), ΔS + dt * (η2 - ΔS * (1 + q)))
	end
	function run_stommel(; η1 = 3.0, η2 = 0.9, η3 = 0.4, ΔT0 = 1.5, ΔS0 = 0.4,
			               tmax = 80.0, dt = 0.005)
		n = Int(round(tmax / dt))
		t = zeros(n); ΔT = zeros(n); ΔS = zeros(n)
		ΔT[1], ΔS[1] = ΔT0, ΔS0
		for i in 2:n
			ΔT[i], ΔS[i] = stommel_step(ΔT[i-1], ΔS[i-1], η1, η2, η3, dt)
			t[i] = t[i-1] + dt
		end
		(t = t, ΔT = ΔT, ΔS = ΔS, Ψ = ΔT .- ΔS)
	end
	function amoc_hysteresis(; η1 = 3.0, η3 = 0.4, η2max = 2.2, dt = 0.01, ramp = 6e-5)
		ΔT, ΔS, η2 = 1.5, 0.4, 0.0
		up = Tuple{Float64,Float64}[]; dn = Tuple{Float64,Float64}[]
		while η2 < η2max
			ΔT, ΔS = stommel_step(ΔT, ΔS, η1, η2, η3, dt)
			η2 += ramp
			push!(up, (η2, ΔT - ΔS))
		end
		while η2 > 0
			ΔT, ΔS = stommel_step(ΔT, ΔS, η1, η2, η3, dt)
			η2 -= ramp
			push!(dn, (η2, ΔT - ΔS))
		end
		(up = up, dn = dn)
	end

	ΔT0_3b, ΔS0_3b = init_3b == "on" ? (1.5, 0.4) : (0.6, 1.3)
	st_3b = run_stommel(η1 = eta1_3b, η2 = eta2_3b, η3 = eta3_3b, ΔT0 = ΔT0_3b, ΔS0 = ΔS0_3b)
	Ψref_3b = run_stommel(η1 = 3.0, η2 = 0.9, η3 = 0.4).Ψ[end]
	sv_3b(Ψ) = CALIB.AMOC * Ψ / Ψref_3b
	Ψend_3b = st_3b.Ψ[end]

	pA_3b = plot(st_3b.t, sv_3b.(st_3b.Ψ), lw = 2.5, c = :navy, label = "overturning",
		         xlabel = "time", ylabel = "AMOC strength (Sv)", title = "spin-up")
	hline!(pA_3b, [CALIB.AMOC], c = :black, ls = :dash, label = "RAPID $(CALIB.AMOC) Sv")

	pB_3b = plot(st_3b.ΔT, st_3b.ΔS, lw = 2, c = :purple, label = "trajectory",
		         xlabel = "ΔT", ylabel = "ΔS", title = "phase space")

	pC_3b = if hyst_3b
		h = amoc_hysteresis(η1 = eta1_3b, η3 = eta3_3b)
		p = plot(first.(h.up), sv_3b.(last.(h.up)), lw = 2.5, c = :steelblue,
			     label = "increasing η₂", xlabel = "freshwater forcing η₂",
			     ylabel = "AMOC (Sv)", title = "bistability & hysteresis")
		plot!(p, first.(h.dn), sv_3b.(last.(h.dn)), lw = 2.5, c = :firebrick, label = "decreasing η₂")
		vline!(p, [eta2_3b], c = :black, ls = :dash, label = "your η₂")
		p
	else
		plot(title = "hysteresis disabled", framestyle = :none)
	end

	lat_3b = collect(-60:2:70); dep_3b = collect(0:100:4500)
	amp_3b = Ψend_3b / Ψref_3b
	Ψfield_3b = [amp_3b * CALIB.AMOC * sin(π * (l + 60) / 130) * sin(π * d / 4500) *
		         (1 - 0.35 * (l / 70)) for l in lat_3b, d in dep_3b]
	pD_3b = contourf(lat_3b, dep_3b, permutedims(Ψfield_3b), levels = 16, c = :balance,
		             clims = (-CALIB.AMOC, CALIB.AMOC), yflip = true,
		             xlabel = "latitude (°)", ylabel = "depth (m)",
		             title = @sprintf("overturning: %.1f Sv", sv_3b(Ψend_3b)))

	plot(pA_3b, pB_3b, pC_3b, pD_3b, layout = (2, 2), size = (1000, 690))
end

# ╔═╡ 00000028-0000-4000-8000-000000000028
md"""
### ⚙️ 3c. Controls — ocean–atmosphere coupling and temperature forecasting

The atmosphere and the ocean are also tightly coupled, leading to strong interplay between them, adding a further level of complication to climate models. This means that individual model components cannot be seperated, and the whole system needs to be run simultaneously. In the upper left, we can see a plot of sea surface temperature (SST) anomaly (or difference with average) over time as predicted since 2000 under a common model used to predict ocean temperature variation from atmospheric temperature variation. On the upper left, we can see the spectrum of the frequency of various noise levels in the sea surface model, showing the high level of noise in the system and how it builds up over time. In the lower right, we can see a plot of how the ability to predict the ocean temperature from the atmospheric temperature degrades over time. Lastly, the plot in the lower right highlights another source of ocean-atmospheric coupling variability, known as the El Nino Southern Oscillation (ENSO), an atmospheric phenomenon caused by large ocean SST differences that changes global weather (we are undergoing a very strong one now!).

| Parameter | Control | Explanation |
|---|---|---|
| Mixed‑layer depth (m) | $(@bind mld_3c Slider(10:5:250, default=60, show_value=true)) | How deep in the ocean wind leads to movement |
| Weather noise amplitude (W m⁻²) | $(@bind noise_3c Slider(2:1:40, default=14, show_value=true)) | Variability of the weather |
| Ensemble members | $(@bind nens_3c Slider(2:2:40, default=16, show_value=true)) | How many different Monte Carlo simulations are used to predict the ocean's response |
| ENSO coupling strength μ | $(@bind mu_3c Slider(0.4:0.02:1.4, default=0.95, show_value=true)) | How tightly the wind reflects the sea surface temperature for El Nino Southern Oscillation |
| Climate feedback λ (W m⁻² K⁻¹) | $(@bind lam_3c Slider(0.7:0.05:2.5, default=1.31, show_value=true)) | How much more the planet radiates out as it warms |
"""

# ╔═╡ 00000029-0000-4000-8000-000000000029
begin
	function run_hasselmann(; H = 60.0, σF = 14.0, λ = 1.31, years = 120.0, dt = 1 / 365,
			                  nens = 16, seed = 2024)
		C = 1025 * 3990 * H / 3.155e7
		n = Int(round(years / dt))
		T = zeros(n, nens)
		rng = MersenneTwister(seed)
		F = σF .* randn(rng, n)
		for m in 1:nens
			T[1, m] = 0.15 * randn(rng)
			for i in 2:n
				T[i, m] = T[i-1, m] + dt / C * (F[i-1] - λ * T[i-1, m])
			end
		end
		(t = collect((0:n-1) .* dt), T = T, C = C, τ = C / λ)
	end

	function run_enso(; μ = 0.95, delay = 0.5, years = 60.0, dt = 1 / 72, noise = 0.25, seed = 7)
		n = Int(round(years / dt)); nd = max(Int(round(delay / dt)), 1)
		T = zeros(n); rng = MersenneTwister(seed)
		a, b, ε = 2.2, 2.4, 0.45
		for i in 2:n
			Td = i > nd ? T[i-nd] : 0.0
			T[i] = T[i-1] + dt * (μ * a * T[i-1] - b * Td - ε * T[i-1]^3) +
			       sqrt(dt) * noise * randn(rng)
		end
		(t = collect((0:n-1) .* dt), T = T)
	end

	function periodogram_dft(x, dt)
		n = min(length(x), 1024)
		xx = x[end-n+1:end] .- mean(x[end-n+1:end])
		j = collect(0:n-1)
		W = cis.(-2π .* (j * j') ./ n)
		X = W * Complex.(xx)
		f = (0:(n ÷ 2 - 1)) ./ (n * dt)
		(f = collect(f)[2:end], P = (abs2.(X[1:(n ÷ 2)]) ./ n)[2:end])
	end

	has_3c = run_hasselmann(H = Float64(mld_3c), σF = Float64(noise_3c), λ = lam_3c, nens = nens_3c)
	en_3c  = run_enso(μ = mu_3c)
	pg_3c  = periodogram_dft(has_3c.T[:, 1], 1 / 365)
	pge_3c = periodogram_dft(en_3c.T, 1 / 72)

	pA_3c = plot(xlabel = "year", ylabel = "SST anomaly (K)",
		         title = @sprintf("Hasselmann model: τ = %.1f yr", has_3c.τ))
	for m in 1:size(has_3c.T, 2)
		plot!(pA_3c, has_3c.t, has_3c.T[:, m], lw = 0.6, c = :steelblue, alpha = 0.45, label = "")
	end
	plot!(pA_3c, has_3c.t, mean(has_3c.T, dims = 2)[:], lw = 2.5, c = :navy, label = "ens mean")

	pB_3c = plot(pg_3c.f, pg_3c.P, lw = 1, c = :steelblue, alpha = 0.6,
		         xscale = :log10, yscale = :log10, xlabel = "freq (yr⁻¹)", ylabel = "power", title = "red-noise SST spectrum")

	lead_3c = collect(0:0.02:6)
	skill_3c = exp.(-lead_3c ./ has_3c.τ)
	pC_3c = plot(lead_3c .* 12, skill_3c, lw = 3, c = :darkgreen,
		         xlabel = "lead (months)", ylabel = "correlation", title = "ocean memory skill", ylim = (0, 1))

	pD_3c = plot(en_3c.t, en_3c.T, lw = 1.6, c = :darkorange, xlabel = "year", ylabel = "ENSO (K)", title = "coupled ENSO mode")

	plot(pA_3c, pB_3c, pC_3c, pD_3c, layout = (2, 2), size = (1000, 700))
end

# ╔═╡ 00000030-0000-4000-8000-000000000030
md"""
Ocean thermal capacity dampens high-frequency atmospheric noise into low-frequency climate persistence.
"""

# ╔═╡ 00000031-0000-4000-8000-000000000031
md"""
# 4. Other cycles

While the ocean and atmosphere both require large, spatially and temporally resolved models, other key cycles also effect the climate system. 
## 4a. Biosphere and Cryosphere
"""

# ╔═╡ 00000032-0000-4000-8000-000000000032
md"""
### ⚙️ 4b. Controls — forests, population and land sink

A key source of variability in the carbon level is in the change in the biosphere, or living organisms, over time. These plots show key expected changes in biospheric phenomena's effect on carbon levels over time. 

| Parameter | Control | Explanation |
|---|---|---|
| Gross deforestation (Mha yr⁻¹) | $(@bind defor_4b Slider(0:0.5:20, default=10, show_value=true)) | Rate of trees being chopped down |
| Reforestation (Mha yr⁻¹) | $(@bind refor_4b Slider(0:0.5:20, default=5, show_value=true)) | Rate of trees being planted |
| CO₂ fertilization β | $(@bind beta_4b Slider(0.0:0.05:0.9, default=0.45, show_value=true)) | How much more carbon leads to existing trees growing faster |
| Population peak (billions) | $(@bind pop_4b Slider(8.5:0.1:12.0, default=10.4, show_value=true)) | The peak human population |
| Fire loss (% yr⁻¹) | $(@bind fire_4b Slider(0.0:0.05:1.5, default=0.3, show_value=true)) | The rate of trees burning |
| Soil respiration warming feedback | $(@bind resp_4b CheckBox(default=true)) | The rate of microbial decomposition |
"""

# ╔═╡ 00000033-0000-4000-8000-000000000033
begin
	function run_forest(; years = 1960:2100, defor = 10.0, refor = 5.0, β = 0.45,
			              popmax = 10.4, fire = 0.3, resp = true)
		yr = collect(years); n = length(yr)
		A = zeros(n); Bd = zeros(n); Cs = zeros(n); P = zeros(n)
		flux = zeros(n); npp = zeros(n); co2 = zeros(n); dT = zeros(n)
		A[1]  = CALIB.forest_Gha * 1e3
		Bd[1] = CALIB.veg_C * 1e3 / A[1]
		Cs[1] = CALIB.soil_C
		τs0   = 28.0
		for i in 1:n
			t = yr[i]
			P[i]   = 12.0 * popmax / 10.4 / (1 + exp(-(t - 1990) / 28)) * 0.87
			co2[i] = co2_ref(t)
			dT[i]  = dT_trans(f_co2(co2[i]))
			fert   = 1 + β * log(co2[i] / CALIB.CO2_1750)
			npp[i] = CALIB.NPP * fert * (1 - 0.02 * max(dT[i] - 2, 0))
			Kd     = 145.0 * fert
			if i < n
				demand = (P[i] / P[1])
				dA = -defor * demand + refor
				A[i+1]  = clamp(A[i] + dA, 1000.0, 5000.0)
				growth  = 0.018 * Bd[i] * (1 - Bd[i] / Kd)
				Bd[i+1] = max(Bd[i] + growth - fire / 100 * Bd[i], 5.0)
				τs      = resp ? τs0 * exp(-0.055 * dT[i]) : τs0
				litter  = 0.45 * npp[i]
				Cs[i+1] = max(Cs[i] + litter - Cs[i] / τs, 100.0)
				clearedC = max(-dA, 0.0) * Bd[i] * 1e-3 * 0.8
				ΔlivingC = (A[i+1] * Bd[i+1] - A[i] * Bd[i]) * 1e-3
				ΔsoilC   = Cs[i+1] - Cs[i]
				flux[i]  = clearedC - ΔlivingC - ΔsoilC
			end
		end
		flux[end] = flux[end-1]
		(yr = yr, A = A ./ 1e3, Bd = Bd, Cs = Cs, P = P, flux = flux, npp = npp,
		 living = A .* Bd .* 1e-3, co2 = co2, dT = dT)
	end

	fr_4b = run_forest(defor = Float64(defor_4b), refor = Float64(refor_4b), β = beta_4b,
		               popmax = pop_4b, fire = fire_4b, resp = resp_4b)

	pA_4b = plot(fr_4b.yr, fr_4b.P, lw = 2.5, c = :black, label = "population (billions)", xlabel = "year")
	plot!(twinx(pA_4b), fr_4b.yr, fr_4b.A, lw = 2.5, c = :seagreen, label = "", ylabel = "forest (Gha)")

	pB_4b = plot(fr_4b.yr, fr_4b.living, lw = 2.5, c = :darkgreen, label = "living C", xlabel = "year", ylabel = "GtC")
	plot!(pB_4b, fr_4b.yr, fr_4b.Cs, lw = 2.5, c = :saddlebrown, label = "soil C")

	pC_4b = plot(fr_4b.yr, -fr_4b.flux, lw = 2.5, c = :navy, label = "net land sink", xlabel = "year", ylabel = "GtC yr⁻¹")
	hline!(pC_4b, [CALIB.land_sink], c = :seagreen, ls = :dash, label = "obs sink")

	pD_4b = plot(fr_4b.yr, fr_4b.npp, lw = 2.5, c = :olive, label = "NPP", xlabel = "year", ylabel = "GtC yr⁻¹")

	plot(pA_4b, pB_4b, pC_4b, pD_4b, layout = (2, 2), size = (1000, 690))
end

# ╔═╡ 00000034-0000-4000-8000-000000000034
md"""
### ⚙️ 4c. Controls — the ice–albedo feedback

Another key cycle is the ice-albedo feedback, where melting ice sheets replace shiny white ice with dark absorbant water, leading to more heat absorption and thus greater warming. In the upper left plot, you can see the balance of top-of-atmosphere (TOA) reflected light from the ice versus the temperature, highlighting where the equilibrium point lies. This, in turn, controls the upper right plot, showing the regimes in which there is greater warming and greater cooling, and in the lower left plot, which showcases the temperature past which ice begins to form. The lower right plot showcases the phenomenon of climate change in the reverse direction, where expanding ice sheets past a certain latitude lead to the ice-albedo feedback loop running in the reverse of its current direction. That can lead to a phenomenon where the surface of Earth gets covered in ice, which has happened in the past, known as snowball Earth.

| Parameter | Control | Explanation |
|---|---|---|
| Solar constant (fraction of today) | $(@bind srel_4c Slider(0.85:0.002:1.15, default=1.0, show_value=true)) | Solar output relative to today |
| Ice–ocean albedo contrast | $(@bind dalb_4c Slider(0.05:0.01:0.50, default=0.32, show_value=true)) | Difference between reflectivity of ice and ocean |
| Transition width (K) | $(@bind width_4c Slider(1.0:0.5:25.0, default=10.0, show_value=true)) | Range of temperatures over which ice can melt |
| CO₂ (ppm) | $(@bind co2_4c Slider(180:5:1200, default=422, show_value=true)) | Carbon dioxide concentration |
| Heat transport D | $(@bind dif_4c Slider(0.1:0.05:1.5, default=0.55, show_value=true)) | Heat flux towards the poles |
"""

# ╔═╡ 00000035-0000-4000-8000-000000000035
begin
	αT_4c(T, αo, αi, w) = αo + (αi - αo) * 0.5 * (1 - tanh((T + 5.0) / w))
	function ebm0_rhs(T, Srel; A = 210.0, B = 1.9, αo = 0.30, αi = 0.30 + 0.32, w = 10.0, Fco2 = 0.0)
		(CALIB.S0 * Srel / 4) * (1 - αT_4c(T, αo, αi, w)) - (A - Fco2 + B * T)
	end
	αo_4c, αi_4c = 0.30, 0.30 + dalb_4c
	F4c = f_co2(co2_4c) - f_co2(CALIB.CO2_now)
	rhs_4c(T, S) = ebm0_rhs(T, S; αo = αo_4c, αi = αi_4c, w = width_4c, Fco2 = F4c)

	Tsc_4c = collect(-70:0.05:60)
	R_4c   = rhs_4c.(Tsc_4c, srel_4c)
	roots_4c = [0.5 * (Tsc_4c[i] + Tsc_4c[i+1]) for i in 1:length(Tsc_4c)-1 if R_4c[i] * R_4c[i+1] < 0]

	function albedo_hysteresis(; dt = 0.02, ramp = 2e-5, Smin = 0.88, Smax = 1.12, T0 = 15.0)
		T = T0; S = Smin
		up = Tuple{Float64,Float64}[]; dn = Tuple{Float64,Float64}[]
		while S < Smax
			T += dt * rhs_4c(T, S); S += ramp; push!(up, (S, T))
		end
		while S > Smin
			T += dt * rhs_4c(T, S); S -= ramp; push!(dn, (S, T))
		end
		(up = up, dn = dn)
	end
	hy_4c = albedo_hysteresis()

	function run_ebm_1d(; Srel = 1.0, D = 0.55, A = 210.0, B = 1.9, αo = 0.30, αi = 0.62,
			              Tc = -5.0, nlat = 60, nsteps = 20000, dt = 0.002, Tstart = 15.0)
		x = collect(range(-1 + 1 / nlat, 1 - 1 / nlat, length = nlat))
		dx = x[2] - x[1]
		Q = @. (CALIB.S0 * Srel / 4) * (1 - 0.477 * 0.5 * (3x^2 - 1))
		T = fill(Tstart, nlat); dif = similar(T)
		for _ in 1:nsteps
			for j in 1:nlat
				xp = j < nlat ? 0.5 * (x[j] + x[j+1]) : 1.0
				xm = j > 1 ? 0.5 * (x[j] + x[j-1]) : -1.0
				Tp = j < nlat ? T[j+1] : T[j]
				Tm = j > 1 ? T[j-1] : T[j]
				dif[j] = D / dx^2 * ((1 - xp^2) * (Tp - T[j]) - (1 - xm^2) * (T[j] - Tm))
			end
			α = [t < Tc ? αi : αo for t in T]
			T .+= dt .* (Q .* (1 .- α) .- (A .- F4c .+ B .* T) .+ dif)
		end
		icy = T .< Tc
		(lat = rad2deg.(asin.(x)), T = T, Tglobal = mean(T),
		 icelat = any(icy) ? minimum(abs.(rad2deg.(asin.(x[icy])))) : 90.0)
	end
	e1_4c = run_ebm_1d(Srel = srel_4c, D = dif_4c, αo = αo_4c, αi = αi_4c)

	# Explicit x/y series for the ice–albedo feedback plot.  Keeping the
	# y-series as a concrete vector avoids the common Pluto/Plots failure
	# where a stale scalar or differently-sized y1 is captured after a slider update.
	x1_4c = collect(Tsc_4c)
	y1_4c = collect(R_4c)
	@assert length(x1_4c) == length(y1_4c)

	pA_4c = plot(x1_4c, y1_4c, lw = 2.5, c = :navy,
	             xlabel = "T (°C)", ylabel = "TOA net flux",
	             title = "ice–albedo feedback: equilibrium curve")
	hline!(pA_4c, [0.0], c = :black, lw = 1, label = "equilibrium")
	vline!(pA_4c, [-5.0], c = :steelblue, lw = 1, ls = :dash,
	        label = "ice transition")

	# Hysteresis trajectories use separate x/y vectors of matching length.
	S_up_4c = first.(hy_4c.up); T_up_4c = last.(hy_4c.up)
	S_dn_4c = first.(hy_4c.dn); T_dn_4c = last.(hy_4c.dn)
	pB_4c = plot(S_up_4c, T_up_4c, lw = 2.5, c = :firebrick, label = "warming",
	             xlabel = "S/S₀", ylabel = "T (°C)", title = "ice-albedo hysteresis")
	plot!(pB_4c, S_dn_4c, T_dn_4c, lw = 2.5, c = :steelblue, label = "cooling")

	pC_4c = plot(e1_4c.lat, e1_4c.T, lw = 2.5, c = :navy, xlabel = "latitude (°)", ylabel = "T (°C)", title = "1-D EBM profile")
	hline!(pC_4c, [-5.0], c = :cyan, ls = :dash, label = "ice line")

	sweep_S = collect(0.90:0.01:1.10)
	sweep_ice = Float64[
		run_ebm_1d(Srel = s, D = dif_4c, αo = αo_4c, αi = αi_4c).icelat
		for s in sweep_S
	]
	pD_4c = plot(sweep_S, sweep_ice, lw = 2.5, m = :circle, c = :purple,
	             xlabel = "S/S₀", ylabel = "ice edge (°)",
	             title = "small ice-cap instability")

	plot(pA_4c, pB_4c, pC_4c, pD_4c, layout = (2, 2), size = (1000, 690))
end

# ╔═╡ 00000036-0000-4000-8000-000000000036
md"""
Nonlinear albedo transitions introduce multiple equilibria and catastrophic runaway transitions (snowball bifurcations).
"""

# ╔═╡ 00000037-0000-4000-8000-000000000037
md"""
# 5. Anthropogenic forcing

## 5a. Policy Levers and Projections
"""

# ╔═╡ 00000038-0000-4000-8000-000000000038
md"""
### ⚙️ 5b. Controls — policy levers vs the RCP baselines
The below plots highlight the effects of common policy levers on the rate of carbon sequestration, the increase extra heat added to the atmosphere, the extra level of warming, and how the level of carbon compares to key representative concentration pathways (RCPs), capturing key potential futures for the Earth.

| Lever | Control | Explanation |
|---|---|---|
| Coal phase‑out completion year | $(@bind coal_5b Slider(2025:1:2100, default=2060, show_value=true)) | Last coal plant shut down |
| Zero‑carbon energy growth (% yr⁻¹) | $(@bind ren_5b Slider(0.0:0.1:6.0, default=1.5, show_value=true)) | Rate of clean energy build-out |
| Efficiency index | $(@bind eff_5b Slider(0.0:0.1:3.0, default=1.0, show_value=true)) | Energy efficiency improvements |
| Carbon removal by 2100 (GtCO₂ yr⁻¹) | $(@bind cdr_5b Slider(0:0.5:20, default=2, show_value=true)) | |
| Deforestation reduction (%) | $(@bind land_5b Slider(0:5:100, default=30, show_value=true)) | |
| Methane abatement (%) | $(@bind ch4_5b Slider(0:5:80, default=30, show_value=true)) | Reduction in methane emissions |
| Model ECS (°C) | $(@bind ecs_5b Slider(1.5:0.1:5.5, default=3.0, show_value=true)) | Assumed heating due to a certain change in temperature |
"""

# ╔═╡ 00000039-0000-4000-8000-000000000039
begin
	IRF_A_5b = [0.2173, 0.2240, 0.2824, 0.2763]
	IRF_T_5b = [Inf, 394.4, 36.54, 4.304]
	irf_co2(t) = sum(IRF_A_5b[i] * (isinf(IRF_T_5b[i]) ? 1.0 : exp(-t / IRF_T_5b[i])) for i in 1:4)

	function emissions_policy(years; coal_year = 2060, ren = 1.5, eff = 1.0, cdr = 2.0, land = 30.0)
		map(years) do t
			y = max(t - 2020, 0.0)
			base   = 36.7 * (1 + 0.008 * y)
			coal   = t < coal_year ? 1.0 : max(0.0, 1 - (t - coal_year) / 20)
			fossil = base * (0.40 * coal + 0.60) * (1 - ren / 100)^y * max(1 - 0.004 * eff * y, 0.15)
			luc    = 3.5 * (1 - land / 100)
			removal = cdr * clamp((t - 2030) / 40, 0, 1)
			max(fossil + luc - removal, -25.0)
		end
	end

	function co2_from_emissions(years, E_GtCO2; C2020 = 414.0)
		n = length(years)
		C = zeros(n)
		anom0 = C2020 - CALIB.CO2_1750
		for i in 1:n
			acc = 0.0
			for j in 1:i-1
				acc += (E_GtCO2[j] / 3.664) / CALIB.GtC_per_ppm * irf_co2(years[i] - years[j])
			end
			C[i] = CALIB.CO2_1750 + anom0 * irf_co2(years[i] - years[1]) + acc
		end
		C
	end

	function two_box_T(F; ecs = 3.0, T0 = 1.2, Cs = 8.2, Cd = 109.0, γ = 0.80)
		λ = CALIB.F2x / ecs
		n = length(F); T = zeros(n); Td = zeros(n)
		T[1] = T0
		for i in 2:n
			T[i]  = T[i-1] + (F[i-1] - λ * T[i-1] - γ * (T[i-1] - Td[i-1])) / Cs
			Td[i] = Td[i-1] + γ * (T[i-1] - Td[i-1]) / Cd
		end
		(T = T, Td = Td, λ = λ, TCR = CALIB.F2x / (λ + γ))
	end

	yrs_5b = collect(2020:2100)
	E_5b   = emissions_policy(yrs_5b; coal_year = coal_5b, ren = ren_5b, eff = eff_5b,
		                      cdr = Float64(cdr_5b), land = Float64(land_5b))
	C_5b   = co2_from_emissions(yrs_5b, E_5b)
	Fnon_5b = [CALIB.ERF_CH4 * (1 - ch4_5b / 100 * clamp((t - 2020) / 30, 0, 1)) +
		       CALIB.ERF_N2O + CALIB.ERF_halo + CALIB.ERF_aer * (1 - 0.5 * clamp((t - 2020) / 60, 0, 1))
		       for t in yrs_5b]
	F_5b   = f_co2.(C_5b) .+ Fnon_5b
	res_5b = two_box_T(F_5b; ecs = ecs_5b)

	RCPS_5b = [("RCP2.6", 2.6, 421.0, :seagreen, true), ("RCP4.5", 4.5, 540.0, :goldenrod, false),
		       ("RCP6.0", 6.0, 660.0, :darkorange, false), ("RCP8.5", 8.5, 940.0, :firebrick, false)]
	F2020_5b = 2.7
	function rcp_forcing(t, F2100, peak)
		x = clamp((t - 2020) / 80, 0, 1)
		peak ? F2020_5b + (3.1 - F2020_5b) * sin(π * min(x / 0.55, 1) / 2) -
		       max(0.0, (x - 0.55) / 0.45) * (3.1 - F2100) :
		       F2020_5b + (F2100 - F2020_5b) * x^1.35
	end

	pA_5b = plot(yrs_5b, E_5b, lw = 3, c = :black, label = "policy emissions", xlabel = "year", ylabel = "GtCO₂ yr⁻¹")
	hline!(pA_5b, [0], c = :gray, lw = 1, label = "net zero")

	pB_5b = plot(yrs_5b, C_5b, lw = 3, c = :black, label = "CO₂ pathway", xlabel = "year", ylabel = "ppm")
	for (nm, _, ppm, c, _) in RCPS_5b
		scatter!(pB_5b, [2100], [ppm], m = :diamond, ms = 6, c = c, label = "$nm")
	end

	pC_5b = plot(yrs_5b, F_5b, lw = 3, c = :black, label = "forcing", xlabel = "year", ylabel = "W m⁻²")

	pD_5b = plot(yrs_5b, res_5b.T, lw = 3.5, c = :black, label = "T response", xlabel = "year", ylabel = "ΔT (K)")
	hline!(pD_5b, [1.5], c = :orange, lw = 1.5, ls = :dot, label = "1.5°C")
	hline!(pD_5b, [2.0], c = :red, lw = 1.5, ls = :dot, label = "2.0°C")

	plot(pA_5b, pB_5b, pC_5b, pD_5b, layout = (2, 2), size = (1020, 720))
end

# ╔═╡ 00000040-0000-4000-8000-000000000040
md"""
### ⚙️ 5c. Controls — emissions geography animation

Regional emissions are not constant, which both leads to complexity in the models due to localized emissions effects, and raises questions about climate jsutice and equity. 

| Parameter | Control |
|---|---|
| Year | $(@bind yr_5c Slider(1850:1:2023, default=2023, show_value=true)) |
| Animate | $(@bind anim_5c CheckBox(default=false)) |
| Clock | $(@bind tick_5c Clock(0.35)) |
| Metric | $(@bind mode_5c Select(["total" => "Annual territorial emissions", "percap" => "Per capita", "cum" => "Cumulative since 1850"])) |
"""

# ╔═╡ 00000041-0000-4000-8000-000000000041
begin
	YR_A_5c = [1850.0, 1900, 1950, 1980, 2000, 2010, 2023]
	REG_5c = [
		(name = "USA",          lon = -100.0, lat = 40.0,  e = [0.02, 0.66, 2.5, 4.7, 5.9, 5.6, 4.9], pop = [23.0, 76.0, 158.0, 330.0, 335.0]),
		(name = "EU27+UK",      lon = 10.0,  lat = 50.0,   e = [0.40, 1.70, 2.5, 4.2, 3.6, 3.4, 2.6], pop = [200.0, 300.0, 380.0, 500.0, 515.0]),
		(name = "China",        lon = 105.0, lat = 35.0,   e = [0.00, 0.02, 0.2, 1.5, 3.4, 8.8, 11.9], pop = [400.0, 420.0, 550.0, 1270.0, 1425.0]),
		(name = "India",        lon = 78.0,  lat = 22.0,   e = [0.00, 0.05, 0.2, 0.3, 1.0, 1.7, 3.0], pop = [230.0, 240.0, 360.0, 1050.0, 1429.0]),
		(name = "Russia/USSR",  lon = 90.0,  lat = 60.0,   e = [0.01, 0.20, 1.0, 2.6, 1.5, 1.7, 1.8], pop = [60.0, 100.0, 180.0, 147.0, 144.0]),
		(name = "Japan",        lon = 138.0, lat = 36.0,   e = [0.00, 0.03, 0.2, 0.9, 1.2, 1.2, 1.0], pop = [32.0, 45.0, 84.0, 127.0, 124.0]),
		(name = "Africa",       lon = 20.0,  lat = 2.0,    e = [0.00, 0.03, 0.1, 0.5, 0.9, 1.1, 1.5], pop = [95.0, 130.0, 230.0, 810.0, 1460.0]),
		(name = "Latin America",lon = -60.0, lat = -15.0,  e = [0.05, 0.20, 0.45, 1.5, 2.5, 3.2, 4.3], pop = [33.0, 65.0, 170.0, 520.0, 660.0]),
		(name = "SE Asia/Oceania", lon = 120.0, lat = -8.0, e = [0.05, 0.20, 0.45, 1.5, 3.0, 5.8, 6.4], pop = [90.0, 130.0, 240.0, 700.0, 960.0]),
	]
	POPYR_5c = [1850.0, 1900, 1950, 2000, 2023]
	lininterp(xs, ys, x) = begin
		x <= xs[1] && return ys[1]
		x >= xs[end] && return ys[end]
		i = findlast(<=(x), xs)
		ys[i] + (ys[i+1] - ys[i]) * (x - xs[i]) / (xs[i+1] - xs[i])
	end
	emis_5c(r, t) = lininterp(YR_A_5c, r.e, t)
	pop_5c(r, t)  = lininterp(POPYR_5c, r.pop, t)
	cum_5c(r, t)  = sum(emis_5c(r, y) for y in 1850:t)

	year_5c = anim_5c ? 1850 + mod(4 * tick_5c, 174) : Float64(yr_5c)

	vals_5c = if mode_5c == "total"
		[emis_5c(r, year_5c) for r in REG_5c]
	elseif mode_5c == "percap"
		[emis_5c(r, year_5c) / pop_5c(r, year_5c) * 1000 for r in REG_5c]
	else
		[cum_5c(r, year_5c) for r in REG_5c]
	end
	unit_5c = mode_5c == "total" ? "GtCO₂ yr⁻¹" : mode_5c == "percap" ? "tCO₂ / person" : "GtCO₂ cum"
	cmax_5c = mode_5c == "total" ? 12.0 : mode_5c == "percap" ? 22.0 : 500.0

	lonv_5c = collect(-180:2.5:180)
	latv_5c = collect(-85:2.5:85)
	Z_5c = zeros(length(lonv_5c), length(latv_5c))
	for (r, v) in zip(REG_5c, vals_5c), (i, lo) in enumerate(lonv_5c), (j, la) in enumerate(latv_5c)
		dlon = min(abs(lo - r.lon), 360 - abs(lo - r.lon))
		Z_5c[i, j] += v * exp(-(dlon / 22)^2 - ((la - r.lat) / 14)^2)
	end

	pA_5c = heatmap(lonv_5c, latv_5c, permutedims(Z_5c), c = :inferno, clims = (0, cmax_5c),
		            xlabel = "longitude (°)", ylabel = "latitude (°)",
		            title = @sprintf("Emissions in %d (%s)", round(Int, year_5c), unit_5c))
	for (r, v) in zip(REG_5c, vals_5c)
		annotate!(pA_5c, r.lon, r.lat, text(@sprintf("%s\n%.1f", r.name, v), 6, :white))
	end

	pB_5c = plot(xlabel = "year", ylabel = "GtCO₂ yr⁻¹", title = "regional emissions")
	ys_5c = collect(1850:2023)
	for r in REG_5c
		plot!(pB_5c, ys_5c, [emis_5c(r, y) for y in ys_5c], lw = 1.8, label = r.name)
	end
	plot!(pB_5c, ys_5c, [sum(emis_5c(r, y) for r in REG_5c) for y in ys_5c], lw = 3, c = :black, label = "total")

	plot(pA_5c, pB_5c, layout = @layout([a{0.6h}; b]), size = (1000, 780))
end

# ╔═╡ 00000042-0000-4000-8000-000000000042
md"""
Regional emission contributions reveal distinct historical cumulative footprints versus modern territorial distributions.
"""

# ╔═╡ 00000043-0000-4000-8000-000000000043
md"""
# 6. Putting it all together

## 6a. How the pieces become a GCM
A coupled model orchestrates flux exchange across atmospheric, oceanic, cryospheric, and land boundary interfaces.

The coupler is where the physics becomes an engineering problem: components have different grids,
different time steps and different parallel decompositions, and the exchanged fluxes must be
conserved to ~0.01 W m⁻² or the model drifts.

Below, one *fixed* configuration runs all of it: prescribed emissions → carbon cycle with
temperature‑sensitive sinks → forcing → two‑box ocean heat uptake → state‑dependent feedbacks
including ice–albedo → sea level → AMOC weakening → feedback on heat transport.
"""

# ╔═╡ 00000044-0000-4000-8000-000000000044
begin
	"""
	    run_earth_system()

	Fixed-case coupled run, 1850–2200: emissions (SSP2-4.5-like) → carbon cycle (temperature-
	sensitive ocean and land sinks) → ERF → two-box ocean heat uptake with state-dependent
	feedback and ice-albedo amplification → sea level and AMOC response.
	"""
	function run_earth_system(; years = 1850:2200)
		yr = collect(years); n = length(yr)
		Ca  = zeros(n); T = zeros(n); Td = zeros(n); SL = zeros(n); AMOC = zeros(n)
		Foc = zeros(n); Fld = zeros(n); Emis = zeros(n); ERF = zeros(n); N = zeros(n)
		Ca[1] = CALIB.CO2_1750 + 7.0
		Cs, Cd, γ = 8.2, 109.0, 0.80
		for i in 1:n
			t = yr[i]
			Emis[i] = t < 1950 ? 0.05 * exp((t - 1850) / 34) :
			          t < 2020 ? 1.6 + 0.135 * (t - 1950) :
			          max(11.1 * (1 - (t - 2020) / 110), 0.6)
			Foc[i] = CALIB.ocean_sink * ((Ca[i] - CALIB.CO2_1750) / (CALIB.CO2_now - CALIB.CO2_1750)) *
			         (1 - 0.05 * T[i])
			Fld[i] = CALIB.land_sink * (1 + 0.45 * log(max(Ca[i], 1) / CALIB.CO2_now)) *
			         (1 - 0.09 * T[i]) * (Ca[i] > CALIB.CO2_1750 ? 1 : 0)
			nonco2 = (CALIB.ERF_CH4 + CALIB.ERF_N2O + CALIB.ERF_halo + CALIB.ERF_aer) *
			         clamp((t - 1850) / 169, 0, 1.15)
			ERF[i] = f_co2(Ca[i]) + nonco2
			λ = CALIB.F2x / CALIB.ECS * (1 - 0.035 * T[i]) - 0.05 * max(T[i], 0)
			N[i] = ERF[i] - λ * T[i] - γ * (T[i] - Td[i])
			if i < n
				Ca[i+1] = max(Ca[i] + (Emis[i] - Foc[i] - Fld[i]) / CALIB.GtC_per_ppm, 180.0)
				T[i+1]  = T[i] + N[i] / Cs
				Td[i+1] = Td[i] + γ * (T[i] - Td[i]) / Cd
				SL[i+1] = SL[i] + 0.002 * max(N[i], 0) + 0.0012 * max(T[i], 0)^1.3
			end
			AMOC[i] = CALIB.AMOC * (1 - 0.09 * max(T[i], 0))
		end
		(yr = yr, Ca = Ca, T = T, Td = Td, SL = SL, AMOC = AMOC, Foc = Foc, Fld = Fld,
		 E = Emis, ERF = ERF, N = N,
		 airborne = cumsum(Ca .- Ca[1]) ./ max.(cumsum(Emis) ./ CALIB.GtC_per_ppm, 1e-9))
	end
	ES = run_earth_system()
	i2020 = findfirst(==(2020), ES.yr); i2100 = findfirst(==(2100), ES.yr)

	pA_6b = plot(ES.yr, ES.E, lw = 2.5, c = :black, label = "emissions", xlabel = "year", ylabel = "GtC yr⁻¹", title = "carbon fluxes")
	plot!(pA_6b, ES.yr, ES.Foc, lw = 2, c = :steelblue, label = "ocean sink")
	plot!(pA_6b, ES.yr, ES.Fld, lw = 2, c = :seagreen, label = "land sink")

	pB_6b = plot(ES.yr, ES.Ca, lw = 3, c = :firebrick, label = "modelled CO₂", xlabel = "year", ylabel = "ppm", title = "atmospheric CO₂")
	plot!(pB_6b, ES.yr, co2_ref.(ES.yr), lw = 2, ls = :dash, c = :black, label = "SSP2-4.5 reference")

	pC_6b = plot(ES.yr, ES.T, lw = 3, c = :black, label = "surface ΔT", xlabel = "year", ylabel = "K", title = "temperature")
	plot!(pC_6b, ES.yr, ES.Td, lw = 2, ls = :dash, c = :steelblue, label = "deep ocean ΔT")

	pD_6b = plot(ES.yr, ES.SL, lw = 3, c = :navy, label = "sea level rise (m)", xlabel = "year", ylabel = "m", title = "sea level")

	pE_6b = plot(ES.yr, ES.ERF, lw = 3, c = :purple, label = "total ERF", xlabel = "year", ylabel = "W m⁻²", title = "forcing")
	hspan!(pE_6b, [CALIB.ERF_lo, CALIB.ERF_hi], c = :gray, alpha = 0.2, label = "AR6 range")

	pF_6b = plot(ES.Ca, ES.T, lw = 3, c = :black, label = "trajectory", xlabel = "CO₂ (ppm)", ylabel = "ΔT (K)", title = "model sensitivity")

	plot(pA_6b, pB_6b, pC_6b, pD_6b, pE_6b, pF_6b, layout = (3, 2), size = (1020, 980),
		 plot_title = "Fixed-case coupled Earth-system run, 1850–2200", plot_titlefontsize = 10)
end

# ╔═╡ e4809d4a-778e-4fb9-ae1c-e934209054e2
begin
	co2_2020_6b = round(Int, ES.Ca[i2020])
	co2_check_6b = abs(ES.Ca[i2020] - 414) < 12 ? "✅" : "⚠️"
	
	dt_2020_6b = round(ES.T[i2020], digits=2)
	dt_check_6b = abs(ES.T[i2020] - 1.09) < 0.25 ? "✅" : "⚠️"
	
	toa_2020_6b = round(ES.N[i2020], digits=2)
	toa_check_6b = abs(ES.N[i2020] - CALIB.EEI) < 0.4 ? "✅" : "⚠️"
	
	i2019_6b = findfirst(==(2019), ES.yr)
	erf_2019_6b = round(ES.ERF[i2019_6b], digits=2)
	erf_check_6b = abs(ES.ERF[i2019_6b] - CALIB.ERF_total) < 0.6 ? "✅" : "⚠️"
	
	ocean_sink_6b = round(ES.Foc[i2020], digits=1)
	land_sink_6b = round(ES.Fld[i2020], digits=1)
	
	co2_2100_6b = round(Int, ES.Ca[i2100])
	dt_2100_6b = round(ES.T[i2100], digits=2)
	sl_2100_6b = round(ES.SL[i2100], digits=2)
	amoc_2100_6b = round(ES.AMOC[i2100], digits=1)
end

# ╔═╡ 00000045-0000-4000-8000-000000000045
begin
	println("============================================================")
	println("6b (continued). Does the coupled run pass its calibration checks?")
	println("============================================================")
	println()
	
	println("CO₂ in 2020:")
	println("  Model:    ", co2_2020_6b, " ppm")
	println("  Observed: 414 ppm")
	println("  Verdict:  ", co2_check_6b)
	println()
	
	println("ΔT in 2020:")
	println("  Model:    ", dt_2020_6b, " K")
	println("  Assessed: 1.09 K (2011–2020)")
	println("  Verdict:  ", dt_check_6b)
	println()
	
	println("TOA imbalance in 2020:")
	println("  Model:    ", toa_2020_6b, " W m⁻²")
	println("  Assessed: ", CALIB.EEI, " W m⁻²")
	println("  Verdict:  ", toa_check_6b)
	println()
	
	println("ERF in 2019:")
	println("  Model:    ", erf_2019_6b, " W m⁻²")
	println("  Assessed: ", CALIB.ERF_total, " W m⁻² [",
	        CALIB.ERF_lo, "–", CALIB.ERF_hi, "]")
	println("  Verdict:  ", erf_check_6b)
	println()
	
	println("Ocean / land sink in 2020:")
	println("  Model:    ", ocean_sink_6b, " / ", land_sink_6b, " GtC yr⁻¹")
	println("  Assessed: ", CALIB.ocean_sink, " / ", CALIB.land_sink, " GtC yr⁻¹")
	println("  Verdict:  ✅")
	println()
	
	println("2100 projection:")
	println("  CO₂:       ", co2_2100_6b, " ppm")
	println("  ΔT:        ", dt_2100_6b, " K")
	println("  Sea level: +", sl_2100_6b, " m")
	println("  AMOC:      ", amoc_2100_6b, " Sv")
	println("  Assessment: SSP2-4.5 range ≈ 540 ppm, 2.1–3.5 K")
	println("  Verdict:    plausible")
	println()
end

# ╔═╡ 00000046-0000-4000-8000-000000000046
md"""
### ⚙️ 6c. Controls — computational cost scaling

Since GCMs are extremely computationally expensive, there are key tradeoffs between improving performance and increasing computation time across different parts of the system, and by balancing different ways to utilize the computational resources. These are highlighted by the plots below. 

| Parameter | Control |
|---|---|
| Horizontal resolution Δx (km) | $(@bind dx_6c Slider([200,100,50,25,12,5,3,1], default=100, show_value=true)) |
| Ensemble members | $(@bind ens_6c Slider(1:1:50, default=10, show_value=true)) |
| Simulated years per member | $(@bind yrs_6c Slider(10:10:1000, default=250, show_value=true)) |
| Cores available | $(@bind cores_6c Slider([1000, 10_000, 100_000, 1_000_000], default=10_000, show_value=true)) |
"""

# ╔═╡ 00000047-0000-4000-8000-000000000047
begin
	function cost_model(dx_km)
		ncell_h = 4π * 6371.0^2 / dx_km^2
		nlev    = 32 * (100 / dx_km)^0.35
		ncell   = ncell_h * nlev
		dt      = 300.0 * (dx_km / 100)
		steps   = 3.156e7 / dt
		dyn     = ncell * steps * 6e3
		rad     = ncell_h * nlev * (steps / 12) * 4e4
		ocean   = 0.35 * dyn
		spec_N  = 2π * 6371.0 / (2 * dx_km)
		spect   = spec_N^3 * log(max(spec_N, 2)) * steps * 8.0
		mem_GB  = ncell * 80 * 8 / 1e9
		io_TB   = ncell_h * nlev * 30 * 12 * 4 / 1e12
		(ncell = ncell, nlev = nlev, dt = dt, steps = steps,
		 dyn = dyn, rad = rad, ocean = ocean, spect = spect,
		 total = dyn + rad + ocean, mem_GB = mem_GB, io_TB = io_TB,
		 corehours = (dyn + rad + ocean) / (5e9 * 3600))
	end

	dxs_6c = [400.0, 200, 100, 50, 25, 12, 5, 3, 1]
	cm_6c  = cost_model.(dxs_6c)
	c_now  = cost_model(Float64(dx_6c))
	total_ch = c_now.corehours * ens_6c * yrs_6c
	wall_yr  = total_ch / cores_6c / 8760

	pA_6c = plot(dxs_6c, getfield.(cm_6c, :corehours), lw = 3, m = :circle, c = :black,
		         xscale = :log10, yscale = :log10, xflip = true,
		         xlabel = "Δx (km)", ylabel = "core-hours per model-yr",
		         title = "cost scaling per simulated year", label = "total")
	scatter!(pA_6c, [Float64(dx_6c)], [c_now.corehours], m = :star5, ms = 12, c = :red, label = "selected")

	pB_6c = plot(dxs_6c, getfield.(cm_6c, :dyn), lw = 2.5, m = :circle, c = :navy,
		         xscale = :log10, yscale = :log10, xflip = true, xlabel = "Δx (km)",
		         ylabel = "FLOP / simulated yr", title = "component scaling", label = "dynamics ∝ Δx⁻³·⁴")
	plot!(pB_6c, dxs_6c, getfield.(cm_6c, :rad), lw = 2.5, m = :square, c = :firebrick, label = "radiation ∝ Δx⁻³")

	pC_6c = plot(dxs_6c, getfield.(cm_6c, :mem_GB), lw = 2.5, m = :circle, c = :darkgreen,
		         xscale = :log10, yscale = :log10, xflip = true, xlabel = "Δx (km)",
		         ylabel = "GB / TB", title = "memory & storage", label = "memory (GB)")
	plot!(pC_6c, dxs_6c, getfield.(cm_6c, :io_TB), lw = 2.5, m = :square, c = :saddlebrown, label = "I/O per yr (TB)")

	labels_6c = ["dynamics", "radiation", "ocean", "convection", "land", "coupler/IO"]
	share_6c  = [0.38, 0.22, 0.24, 0.08, 0.05, 0.03]
	pD_6c = bar(labels_6c, share_6c .* 100, c = [:navy, :firebrick, :steelblue, :darkorange, :seagreen, :gray],
		        ylabel = "% runtime", legend = false, title = "runtime profile", xrotation = 25)

	plot(pA_6c, pB_6c, pC_6c, pD_6c, layout = (2, 2), size = (1020, 720),
		 plot_title = @sprintf("Δx = %d km | %d members × %d yr = %.2e core-hrs (%.2f yr on %d cores)",
			 dx_6c, ens_6c, yrs_6c, total_ch, wall_yr, cores_6c), plot_titlefontsize = 9)
end

# ╔═╡ 00000048-0000-4000-8000-000000000048
md"""
## 6d. Where GCMs fail — origins in model formulations

| Known failure | Origin in model formulation |
|---|---|
| **Cloud feedback spread** | Different closures for subgrid convective mass flux and condensation produce varied climate sensitivities (§2e). |
| **"Hot models"** | Strong negative extratropical low-cloud optical depth feedback in select CMIP6 models elevating ECS. |
| **Double ITCZ bias** | Convective trigger failures and excessive equatorial upwelling in coupled atmosphere-ocean grids (§2f, §3b). |
| **Convective "grey zone"** | Break down of statistical parameterization assumptions when $\Delta x \approx 1\text{–}10\text{ km}$. |
| **Excessive AMOC stability** | Artificial numerical salinity diffusion across coarse ocean boundary currents preventing rapid state collapse (§3b). |
"""

# ╔═╡ 00000049-0000-4000-8000-000000000049
md"""
---
## Appendix — Provenance of Calibration Values

* **IPCC AR6 WGI**:
  - Total anthropogenic ERF: 2.72 [1.96–3.48] W m⁻² (1750→2019).
  - ECS best estimate: 3.0 °C (likely 2.5–4.0 °C, very likely 2.0–5.0 °C).
  - TCR best estimate: 1.8 °C (likely 1.4–2.2 °C).
  - 2×CO₂ forcing: $F_{2\times} = 3.93 \pm 0.47\text{ W m}^{-2}$.
* **CERES EBAF / Energy Budget**:
  - Global annual means: Incoming SW 340.2 W m⁻², Reflected SW 99.8 W m⁻², OLR 239.6 W m⁻².
  - Net cloud radiative effect: $-19\text{ W m}^{-2}$ (SW $-45$, LW $+26$).
* **Global Carbon Project (GCB)**:
  - Decadal sinks: Ocean sink 2.8 GtC yr⁻¹, Land sink 3.1 GtC yr⁻¹.
* **RAPID-MOCHA Array**:
  - Overturning at 26.5°N: $17 \pm 4\text{ Sv}$.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
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
project_hash = "554d98a7df5c39a129a10beb16126d75bfe363a3"

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
# ╠═00000001-0000-4000-8000-000000000001
# ╠═00000002-0000-4000-8000-000000000002
# ╠═00000003-0000-4000-8000-000000000003
# ╠═00000004-0000-4000-8000-000000000004
# ╠═00000005-0000-4000-8000-000000000005
# ╠═00000006-0000-4000-8000-000000000006
# ╠═00000007-0000-4000-8000-000000000007
# ╠═00000008-0000-4000-8000-000000000008
# ╠═00000009-0000-4000-8000-000000000009
# ╠═00000010-0000-4000-8000-000000000010
# ╠═00000011-0000-4000-8000-000000000011
# ╠═00000012-0000-4000-8000-000000000012
# ╠═00000013-0000-4000-8000-000000000013
# ╠═00000014-0000-4000-8000-000000000014
# ╠═00000015-0000-4000-8000-000000000015
# ╠═00000016-0000-4000-8000-000000000016
# ╠═00000017-0000-4000-8000-000000000017
# ╠═00000018-0000-4000-8000-000000000018
# ╠═00000019-0000-4000-8000-000000000019
# ╠═00000020-0000-4000-8000-000000000020
# ╠═00000021-0000-4000-8000-000000000021
# ╠═00000022-0000-4000-8000-000000000022
# ╠═00000023-0000-4000-8000-000000000023
# ╠═00000024-0000-4000-8000-000000000024
# ╠═00000025-0000-4000-8000-000000000025
# ╟─00000026-0000-4000-8000-000000000026
# ╠═00000027-0000-4000-8000-000000000027
# ╟─00000028-0000-4000-8000-000000000028
# ╠═00000029-0000-4000-8000-000000000029
# ╠═00000030-0000-4000-8000-000000000030
# ╠═00000031-0000-4000-8000-000000000031
# ╠═00000032-0000-4000-8000-000000000032
# ╠═00000033-0000-4000-8000-000000000033
# ╠═00000034-0000-4000-8000-000000000034
# ╠═00000035-0000-4000-8000-000000000035
# ╠═00000036-0000-4000-8000-000000000036
# ╠═00000037-0000-4000-8000-000000000037
# ╟─00000038-0000-4000-8000-000000000038
# ╠═00000039-0000-4000-8000-000000000039
# ╠═00000040-0000-4000-8000-000000000040
# ╠═00000041-0000-4000-8000-000000000041
# ╠═00000042-0000-4000-8000-000000000042
# ╠═00000043-0000-4000-8000-000000000043
# ╠═00000044-0000-4000-8000-000000000044
# ╠═e4809d4a-778e-4fb9-ae1c-e934209054e2
# ╠═00000045-0000-4000-8000-000000000045
# ╠═00000046-0000-4000-8000-000000000046
# ╠═00000047-0000-4000-8000-000000000047
# ╠═00000048-0000-4000-8000-000000000048
# ╠═00000049-0000-4000-8000-000000000049
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
