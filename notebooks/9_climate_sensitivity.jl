### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 3e60b013-98cf-4057-9c96-b627662c85a4
begin
    using DifferentialEquations, Plots, PlutoUI, LinearAlgebra, CSV, DataFrames, Images
end

# ╔═╡ 42085492-ac8c-11eb-0620-adcb307077f1
html"""
<div style="
position: absolute;
width: calc(100% - 30px);
border: 50vw solid #282936;
border-top: 200px solid #282936;
border-bottom: none;
box-sizing: content-box;
left: calc(-50vw + 15px);
top: -200px;
height: 200px;
pointer-events: none;
"></div>

<div style="
height: 200px;
width: 100%;
background: #282936;
color: #fff;
padding-top: 68px;
">
<span style="
font-family: Vollkorn, serif;
font-weight: 700;
font-feature-settings: 'lnum', 'pnum';
"> <p style="
font-size: 1.5rem;
opacity: .8;
"><em>Section 2.2</em></p>
<p style="text-align: center; font-size: 2rem;">
<em> Climate models: climate sensitivity </em>
</p>

<style>
body {
overflow-x: hidden;
}
</style>"""


# ╔═╡ 14195fc4-40e1-4576-973a-69d649fddc02
TableOfContents(title="📚 Table of Contents", indent=true, depth=4, aside=true)

# ╔═╡ dd6ba348-d0d7-46b7-a77f-351c00dc9c36
html"""
<iframe width="700" height="394" src="https://www.youtube-nocookie.com/embed/E7kMr2OYKSU" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
"""

# ╔═╡ 2ab34e6f-9059-4f33-8abd-df15b0c00b6b
md"""
## Climate sensitivity

"""

# ╔═╡ a24c2177-5fee-4930-ab78-524085f65ed9
md"""
### Greenhouse gases
---
---

The energy budget of the atmopshere is quite remarkable in that most of the radiation received at the surface (mostly oceans) comes from the amtophere as thermal energy, not from the Sun as shortwave energy. This brings to the fore the importance of greenhouse gases that regulate the radiation emitted from the atmosphere.

"""

# ╔═╡ b9eca29e-9028-4fd7-8c62-718a2dcf87d1
html"""<img src="https://static.cambridge.org/binary/version/id/urn:cambridge.org:id:binary:20220228071607931-0310:9781108979030:83886fig3_1.png" width=625>"""

# ╔═╡ 231e4c3b-6998-4f3d-9cc3-14fa17941f7d
md"""
#### Energy levels and absorption of energy
---
Here we revisit our discussion of why greehouse gases like water vapor and carbon dioxide play a key role in regulating the thermal radiation of the atmosphere, even though they make up for a paltry amount of the atmosphere by mass. The permanent gases that compose the atmosphere are : nitrogen (78%), oxygen (21%) and argon (0.9%). Carbon dioxide makes up barely 0.4%. Water vapor concentration varies from 0-4% of the atmosphere depending on where you are and what time of the day it is. Why are we concerned about small increases in carbon dioxide concentrations then?

Let us beging by reviewing how gases absorb radiation. This requires a review of quantum theory, a field that may not be the forte of some climate skeptics. Any given molecule of a gas can be at different energy levels, depdening on the levels occupied by its electrons, but also on the vibration and rotation modes of the meolecular bonds. Radiation arrives to a molecule in the form of a photon of energy $h/\lambda$ where $h$ is  Planck's constant and $\lambda$ the photon wavelength. The photon can be absorbed by the molecule only if its energy (and hence its wavelength) matches the amount of energy needed to cause the molecule to trasnition between its energy level and a higher one. Moving electrons to higher orbitals typically requires very energetic photons in the ultraviolet range (shortwaves). Exciting vibrations and rotations requires photons with weaker energies. In particular vibrations where the dipole moment of the moelcule changes are excited by photons in the thermal energy range (longwaves) and hence play a crucial role in the Earth's greenhouse effect.

"""

# ╔═╡ 482dd428-74f0-4c7c-afc9-db547777e79f
md"""

##### Vibration modes of $H_2O$ molecule
"""

# ╔═╡ f8868c0a-d0ec-45dc-844f-c053981277d9
html"""<img src="https://3.bp.blogspot.com/-iYcX-0kkxZo/WJV3HDK6OjI/AAAAAAAAMeY/MHM0bs-o_B8hBMc_1KU4sU-H2YGL3jPtwCLcB/s320/water-asymm2.gif" width=425>"""

# ╔═╡ 2ecbad61-0f94-4e0a-9b35-0a5a60d4405c
md"""

##### Vibration modes of $CO_2$ molecule
"""

# ╔═╡ 2b7eeede-83ef-45ca-929b-19a3c369b105
html"""<img src="http://www.dynamicscience.com.au/tester/solutions1/chemistry/greenhouse/co2vib.gif" width=425>"""

# ╔═╡ a8b9d935-d951-493f-9e91-45743a471249
md"""

##### Absorption of radiation by the amtosphere
"""

# ╔═╡ 87c272a7-66bb-4c91-a8ee-30c74ce60461
html"""<img 
	src="https://www.climate-policy-watcher.org/climate-dynamics/images/3258_16_24-absorption-spectra-goody-1989.jpg" width=625>"""

# ╔═╡ 82e4f960-da7e-41ca-ab16-4d49636041a2
md"""

Figure: (a) The normalized blackbody emission spectra, T-4XBX, for the Sun (T = 6000 K) and Earth (T = 255 K) as a function of ln X (top), where Bx is the blackbody function (see Eq. A-2) and X is the wavelength (see Appendix A.1.1 for further discussion). (b) The fraction of radiation absorbed while passing from the ground to the top of the atmosphere as a function of wavelength. (c) The fraction of radiation absorbed from the tropopause (typically at a height of 11km) to the top of the atmosphere as a function of wavelength. The atmospheric molecules contributing the important absorption features at each frequency are also indicated. After Goody and Yung (1989).

"""

# ╔═╡ 54d73952-c016-48f5-9fb5-83aaea4363de
md"""

##### Emission of radiation by the atmosphere


You may often read that energy is absorbed and re-emitted by greenhouse gas molecules. This is not correct. Molecules absorb according to incident intensity,
collide to distribute the energy, and emit according to their temperature. EAPS Prof. Tim Cronin has sketched a nice schematic of the two descriptions and why they are fundamentally different.

"""

# ╔═╡ 05c9f594-1005-4662-ab1d-49f218012add
	md"""
	![WrongPicture_TC.png]
	(https://raw.githubusercontent.com/mitmath/JuliaComputation/main/notebooks/WrongPicture_TC.png)
	"""

# ╔═╡ 1147a6ad-e528-4b41-bca6-63caa02f3a68

	md"""
	![RightPicture_TC.png]
	(https://raw.githubusercontent.com/mitmath/JuliaComputation/main/notebooks/RightPicture_TC.png)
	"""
	
	

# ╔═╡ 37535223-1fce-402f-ab24-53d9609b2b9c
md"""

The emission spectrum in the thermal infrared range can therefore be used to infer the temperature at which radiation is emitted. The colder the emission temperature, the more efficient is the atmopshere to absorb and emit energy at that wavelength.

"""

# ╔═╡ 487c6447-7d47-457f-8d0e-8ad25240a4d2
	md"""
	![Emission_TS.png]
	(https://raw.githubusercontent.com/mitmath/JuliaComputation/main/notebooks/Emission_TS.png)
	"""

# ╔═╡ c665a43c-5020-4cc9-8209-1a786e4c98ab
md"""

Figure: Terrestrial spectral radiative energy flux emanating from the top of Earth’s atmosphere. The spectrum is calculated with a radiative transfer model for the U.S. standard atmosphere, which is representative of midlatitudes. Effects of clouds are ignored in this spectrum, so it represents clear-sky conditions. Absorption bands of a few atmospheric trace constituents are identified: water vapor (H2O), methane (CH4), ozone (O3), and carbon dioxide (CO2). The emission temperature of the spectrum shown is 260 K, which is close to Earth’s emission temperature of 255 K. The blue lines show blackbody spectra for temperatures of 255 K (Earth’s emission temperature) and 288 K (Earth’s global-mean surface temperature).  From Tapio Schneider online textbook "Physics of Earth's Climate".


"""

# ╔═╡ ab4039d5-c564-4fcc-84b7-58fba714d735
md"""
#### Collisional broadening
---

The atmopshere is saturated with respect to CO$_2$ absorption--that is, longwave photons emitted from the surface at the wavelengths of the CO$_2$ individual absortption lines are already fully absorbed by the atmosphere at preindustiral CO$_2$ concentrations. Why do we worry baout increasing CO$_2$ concentrations then?

It turns out that molecules can absorb photons with energy on a broader range around the precise energies corresponding to transitions between pairs of molecule energy levels (specifically the vibration modes for CO$_2$ in the infrared range). This is due to one major effect: collisional broadening of the absorption lines. If the arriving photon has slightly more energy than needed for energy level transition, the excess energy can be transferred to the colliding molecule, allowing to absorb photons that are not exactly at the right wavelength/energy. 

As the concentration of CO$_2$ increases so does the number of collisions and the broadening of the absorption lines. And voila', the absorptivity/emissivity of the amtopshere increses in the CO$_2$ absorption wavelengths range.
"""

# ╔═╡ bb36eda4-91a2-4fd0-bce3-12891b610fb7
	md"""
	![Broadening.svg]
	(https://raw.githubusercontent.com/mitmath/JuliaComputation/main/notebooks/Broadening.svg)
	"""

# ╔═╡ 44515eae-805e-445a-ac35-f5d9c40df83e
md"""
Figure from slides accopanying "Global Warming Science" by Eli Tziperman.
"""

# ╔═╡ 37b5cafd-1147-4677-94d1-1a265736f794
md"""
#### Radiative forcing and logarithmic dependence on $CO_2$
---
The width of the abosrption bands for each individual vibrational mode increases as a function of wavelengths due to the increased collisions. This increase results in a logarithmic deepndence of the emissivity on the CO$_2$ concentration well described by the formula:

$\epsilon(CO_2) = ϵ₀ + ϵ₁ \,\,\log_2 \left(\frac{[CO_2]}{[CO_2]_{PI}}\right)$

with $CO_2$ measured in ppmv and $[CO_2]_{PI}$ is the Pre-Industrial CO$_2$ concentration of 280 ppmv.

"""

# ╔═╡ e372b079-53fc-4f6e-9365-e43ad8281f3c
md"""
#### Radiative forcing and water vapor feedback
---

Although water vapor accounts for more than half of the Earth’s greenhouse warming effect, it does not control the Earth’s temperature. Instead, the amount of water vapor is controlled by the temperature. This is because the temperature of the atmosphere limits the maximum amount of water vapor the atmosphere can hold. If the temperature decreases any water vapor in excess of its saturation value will condense to form liquid water. This is why clouds form as warm air containing water vapor rises and cools at higher altitudes where the water condenses to the tiny droplets that make up clouds. According to Clausius-Clapeyron's relation the saturation specific humidity $q^*$--the mass (in kg) of moisture in 1 kg of mosit air at saturation--increases nearly exponentially with temperature $T$ in Kelvin:

$$q^*(T) \simeq 1.58 \times 10^6 \,e^{-5415/T} \quad\text{ kg of moisture per kg of mosit air}$$

Model calculations and physical arguments further show that the relative humidity--the ratio of the specific humidity and the saturation specific humidit--remains roughly unchanged as climate warms, implying that the water vapor in the amtosphere follows the Clausius-Clapeyron quasi-exponential relation. An increase in temperature due, for example, by an increase in another greenhouses gas CO$_2$ is therefore amplified by water vapor as illustrated in the loop below. In climate jargon we refer to water vapor as a positive feedback.

We can finally capture the combined effects of CO$_2$ and water vapor on the emissivity and write:

```math
\begin{align}
ϵ(CO_2, T) &= ϵ₀ + ϵ₁\,\,\log_2\left(\frac{[CO₂]}{[CO₂]_{PI}}\right) + \hat ϵ₂\,\, \log_2\left(\frac{q^*(T)}{q^*(T_{PI})}\right)\\
&= ϵ₀ + ϵ₁\,\,\log_2\left(\frac{[CO₂]}{[CO₂]_{PI}}\right) + ϵ₂\,\, (T-T_{PI})
\end{align}
```


"""

# ╔═╡ 75a31c18-37c0-41db-afba-5d92f818be73
md"""
![WaterVapor.svg]
(https://raw.githubusercontent.com/mitmath/JuliaComputation/main/notebooks/WaterVapor.svg)
"""

# ╔═╡ 91441230-1b1c-4702-b3a7-2f9adf2ddaaa
begin
	CO₂_PI = 280.; # preindustrial CO2 concentration [parts per million; ppm];
	ϵ₀ = 0.75 # Pre Industrial emissivity
	ϵ₁ = 0.02 # Parameter setting emissivity dependence on CO_2
	ϵ₂ = 0.01 # Parameter setting emissivity dependence on water vapor [1/K]
	ϵ(CO₂,δT) = ϵ₀ + ϵ₁*log(CO₂/CO₂_PreIndust)/log(2) + ϵ₂*δT
end

# ╔═╡ 576a94c7-64e7-41a8-b8cc-dc1b2e2380e2
md"""
### Climate sensitivity and the role of the ocean
---
---

The $\text{\color{red}{climate sensitivity}}$ is defined as the increase in surface temperature in response to a change in radiative forcing, for example due to an icrease in greenhouse gases, once the climate has ajsuted to the new radiative forcing. It has uints of K dvided by W/m^2. This is more properly called the equilibrium climate sensitivity. In this section we discuss how the ocean affects the evolution of Earth's climate towards equilibrium and introduce the concepts of $\text{\color{red}{equilibrium climate sensitivity}}$ and $\text{\color{red}{transient climate sensitivity}}$.
"""

# ╔═╡ 353e3341-5957-40e7-b2b9-800ba7a80063
begin
	σ = 5.670374419*10^(−8) # Stefan-Boltzman constant [W/m^2/K^4]
	α = 0.3 # Earth's mean albedo, or planetary reflectivity [unitless]
	S = 1366 # solar insolation [W/m^2]  (energy per unit time per unit area)
end

# ╔═╡ 4c9e7ec6-64e9-4146-8558-f78f865df195
md"""
#### Equilibrium climate sensitivity
---

The concept of climate sensitivity is introduced to quantify the response of the Earth's climate to pertubations inn greenhouse gas concentrations. We start with the evolution of a temperature pertubations of the ocean temperature, $\delta T_o$, that evolves accoring to the model we derived in the last lecture, assuming that the emissivity is the only parameter that can changes (we do not consider changes in solar forcing and albedo but is is a straightfoward extension). Substituting $T_o = T_{PI}+\delta T_o$, where $T_{PI}$ is the equilibrium temperature before the change in radiative forcing, we get:

```math
\begin{align}
&C_o \frac{d \delta T_o}{dt} = \frac{(1-\alpha)S_0}{4} - \frac{2-\epsilon_0 - \delta\epsilon}{2}\sigma \,\left( T_{PI}^4 + 4 T_{PI}^3 \,\,\delta T_0 +O(\delta T_o^2) \right) 
\end{align}
```
where $\delta \epsilon$ is the change in emissivity due to changes in Co$_2$, water vapor, etcetera. 

Remembering that $(1-\alpha)S_0/4 =(2-\epsilon_0)\sigma T_{PI}^4/2$, and dropping terms quadratic in preturbations ($\delta T_o^2, \,\,\delta T_o \delta \epsilon$), we have,

$$C_o \frac{d \delta T_o}{\delta t} = \delta F - \lambda \,\, \delta T_o.$$

where $\delta F$ is the radiative forcing in W/m$^2$:

$$\delta F = \frac{1}{2} \sigma T_{PI}^4 \epsilon_1 \log_2\left(\frac{[CO₂]}{[CO₂]_{PI}}\right)$$

and $\lambda$ is the equilibrium climate feedback paprameter which encapsulates how the temperature changes in response to the radiative perturbation:

$$\lambda = \underbrace{4 \frac{2-\epsilon_0}{2} T_{PI}^3}_{\text{Plank feedback}} \quad - \underbrace{\frac{1}{2} T_{PI}^4 \epsilon_2}_{\text{water vapor feedback}}$$

"""

# ╔═╡ 2e91945b-6239-41df-83d1-cfed67081cf7
md"""
Using our parameters we can compute the radiative forcing parameter:
"""

# ╔═╡ 69fa38d3-2411-496c-bf0a-af4e3531b2ae
begin
	T_PI = ( 2/(2-ϵ₀) * S*(1-α)/4/σ )^(1/4) # Equilibrium Pre Industrial temperature [K]]
	δF(CO₂) = 1/2 * σ *T_PI^4 * ϵ₁ * log(CO₂/CO₂_PI)/log(2) # Radiative forcing [W/m^2]
end

# ╔═╡ 212d6995-d04b-4c8c-b0ed-b8b591c683e5
md"""
which for a doubling of C0$_2$ above Pre Industrial values implies a radiative forcing of:
"""

# ╔═╡ 3a443524-834c-44fc-a3dd-c72839adba1f
δF₂ₓ = δF(560)

# ╔═╡ b96b4e7c-1350-4c1a-a716-3623dae87574
md"""
and a climate feedack parameter of:
"""

# ╔═╡ 7f232e27-e2bb-4474-aadf-bebcd2e61e45
λ = 2 * (2-ϵ₀)  * σ * T_PI^3 - 1/2 * σ * T_PI^4 * ϵ₂

# ╔═╡ 6c2998d7-ec51-446a-a5f9-7dcef8f97454
md"""
The $\text{\color{red}{equilibrium climate sensitivity}}$  is defined as the temperature change for a doubling of CO$_2$ once the climate reaches a new equilibrium. According to our model it is thus predicted to be:
"""

# ╔═╡ a71e2174-0a01-4b77-a1c8-bce3663f5485
ΔT₂ₓ = δF₂ₓ / λ

# ╔═╡ 660aad5a-4fc3-4e0f-8d40-5884c7dde2fd
md"""
This value is twice as large as that predicted without water vapor feedback:
"""

# ╔═╡ 553084e1-863d-4d01-9670-a0909732278b
ΔT₂ₓʷⁱᵗʰᵒᵘᵗ = δF₂ₓ / (2 * (2-ϵ₀)  * σ * T_PI^3)

# ╔═╡ 3fbc0b72-8228-4d2a-ae8e-9ca73393664b
md"""
but still on the very low end of estmiates from comprehensive climate models which include the full vertical structure of the atmosphere and ocean and the motions of air and water. These aspects will be introduced in the next two lecture and add numerous additional feedbacks which affect the climate feedback parameter.
"""

# ╔═╡ cd69218a-b7fb-4e70-8b17-3dadd0838d62
md"""
#### Transient climate sensitivity
---
In the last lecture we assumed that the whole ocean warms in response to incoming solar radiation, but this is not the case. The ocean is a stratified fluid with warmer waters at the top. Once solar radiation hits its surface, warming affects only the surface mixed layer, the ocean upper layer where strong turbulence, driven by winds and heat loss, mixes heat in the vertical and keeps the vertical temperature profile constant. This upper layer has a depth of approximately h=100 m on average. Heat then diffuses in the deeper layers of the ocean at a much slower pace. A simple extension of the model for perturbations of the ocean temperature $\delta T_o$ in respnse to radiative forcing $\delta F$ is one in which the ocean is divided into an upper and a deep layer:

```math
\begin{align}
&{C_u \frac{d δT_u}{dt}} = \delta F - \lambda \delta T_u - \mu (\delta T_u -\delta T_d) \\
&{C_d \frac{d δT_d}{dt}} = \mu (\delta T_u -\delta T_d)
\end{align}
```

where $\delta T_u$ and $\delta T_o$ are the temperature perturbations of the upper and deep layers with the associated heat capacities.
"""

# ╔═╡ 296e339f-296f-475c-884a-02ca5606fd36
md"""
![2layerocean.png](https://raw.githubusercontent.com/mitmath/JuliaComputation/main/notebooks/2layerocean.png)
"""


# ╔═╡ 59e682aa-0ccd-46eb-91cf-0c18bcf79575
md"""
The term $\mu (\delta T_u - \delta T_d)$ represents the exchange of heat between the upper layer and the deeper layer. We will use μ = 1.0 W/m^2 as a representative value.

Much like in the problem of coupling an ocean and an atmosphere, we once again have two timescales associated with the different heat capacities of the upper ocean (smaller) and the deep ocean (larger). 
"""

# ╔═╡ 06108680-874d-4eed-8524-8adb668095b4
begin
	year = 365 * 86400
	C_u = 4000 * 1000 * 100 * 0.7 / year # Heat capaicy of ocean mixed layer [Wyr/m^2/°K]
	C_d = 4000 * 1000 * 3900 * 0.7/ year # Heat capacity of deep ocean [Wyr/m^2/°K]
	δT₀ = 0 # Initial temperature peturbation
	μ = 1 # Rate of heat exchange between surface and deep ocean [W/m^2/K]
end

# ╔═╡ fc8f0d12-c4c1-4686-8fe6-e8c1c51640e6
function oceanmodel!(du, u, p, t)

	δT_u = u[1]
	δT_d = u[2]
	
    du[1] = (1/C_u) * (δF(430) - λ * δT_u - μ * (δT_u-δT_d))
    du[2] = (1/C_d) * ( μ * (δT_u-δT_d))

end

# ╔═╡ b43a8ff7-284d-41cd-aadc-8f684fc9705e
md"""
Δt = $(@bind Δt Slider(0:5:2000, show_value=true, default=100) )
"""

# ╔═╡ fd887ed0-0248-4849-b4a6-4d428650938f
begin
	p2l = ODEProblem(oceanmodel!, [δT₀; δT₀], (0.,Δt))
end

# ╔═╡ d13613d2-7907-4374-ab53-b42362fb0fee
begin
	sol2l=solve(p2l)
	plot(sol2l,             label = ["T_u" "T_d"], 
		 background_color_inside = :black,
		                  xlabel = "years",
	                      ylabel = "Temperature increase K",
                          ylim   = (0,2),
						  xlim   = (0,Δt))
	hline!([δF(430)/λ,δF(430)/λ], c=:red, ls=:dash, label=false)
	hline!([δF(430)/(λ+μ),δF(430)/(λ+μ)], c=:blue, ls=:dash, label=false)
	# annotate!(0.6*timespan, 0.5+δT₀, text("Initial Temperature = $(δT₀) K",color=:white))
	title!("Ocean response to radiative forcing")
end

# ╔═╡ 845a8226-a6ff-4549-8954-051f124ffc52
md"""
##### Short timescale (transient climate sensitivity)

On short timescales the deep ocean temperature hardly changes and thus $\delta T_d \simeq 0$. The evolution of the upper ocean reduces to:

```math
\begin{align}
&{C_u \frac{d δT_u}{dt}} = \delta F - (\lambda + \mu ) \delta T_u \\
\end{align}
```
Thus the transient climate sensitivity parameter which is relevant for short timesacles is given by (λ + μ). The addition of μ to the parameters represents the negative feedack of the deep ocean that takes heat out of the upper ocean and thus of the amtopshere, thereby slowly the warming for the time being. The transient equilibrium temperature is given by:

$$
\delta T_u^{tr} = \frac{\delta F}{\lambda + \mu}
$$

where the superscript $tr$ stands for transient equilibrium. This transient equilibrium temperature perturbation is achieved on a timescale of order:

$$
\tau^{tr} \simeq \frac{C_u}{\lambda + \mu}
$$

This is the value plotted as a dashed blue line in the graph.

The trasnient climate sensitivity is consistently defined as:

$$\Delta T_{2x} = \frac{\Delta F_{2x}}{\lambda + \mu}$$

and it is about half of the equilibrium climate sensitivity.

"""

# ╔═╡ be01be6f-c51c-493c-8306-bc4526c2c57a
ΔT₂ₓᵗʳ = δF₂ₓ / (λ + μ)

# ╔═╡ 8b99c85a-478b-4ffb-848d-2812bcf3a95d
τᵗʳ= C_u / (λ + μ ) # Timescale to reach transient equilibrium in upper ocean [years]

# ╔═╡ f59c6208-2911-406d-b5b4-88c13af21f04
md"""
##### Long timescale (equilibrium climate sensitivity)

On timescales much loonger than τᵗʳ, the upper ocean can be assumed to be in equilibrium and the system of equations reduces to:

```math
\begin{align}
&0 = \delta F - \lambda \delta T_u - \mu (\delta T_u -\delta T_d) \\
&{C_d \frac{d δT_d}{dt}} = \mu (\delta T_u -\delta T_d)
\end{align}
```

which can be comined into a single equation for $\delta T_d$:

```math
\begin{align}
&{C_d \frac{d δT_d}{dt}} = \frac{\mu}{\lambda +\mu} \delta F - \frac{\lambda \mu}{\lambda +\mu}\delta T_d
\end{align}
```

At equilibrium the deep ocean must have the same temperature peerturbation as the deep ocean and thus it is no surpise that the equilibrium sensitivity parameter for the two layer model is the same as the one layer model, becasue the two layers end up having the same temperature:

```math
\delta T_d^{eq} = \delta T_u^{eq} = \frac{\delta F}{\lambda}
```


This equilibrium temperature is achieved on the much longer timescale:

```math
\tau^{eq} = \frac{\lambda + \mu}{\lambda \mu} C_d =  \frac{(\lambda + \mu)^2}{\lambda \mu} \frac{C_d}{C_u} \tau^{tr} \gg \tau^{tr} 
```


"""

# ╔═╡ 683ad1f3-45bc-40a0-9f7d-49d9929dd783
τeq = (λ + μ) / (λ * μ) * C_d # Timescale to reach equilibrium in deep ocean [years]

# ╔═╡ 96459714-eb2a-4b6f-9b64-7b1935ff2acc
md"""

Kostov and collaborators (geophycial research Letters, 2014) find that this two layer ocean model descrives quite accurately the sea surface temeprature reponse to quadrupling CO$_2$ perturbation experiments simulated with full climate models. 

"""

# ╔═╡ f3f4733a-b962-43a7-8471-83db5a3b24be
html"""<img src="https://agupubs.onlinelibrary.wiley.com/cms/asset/f31a2a65-2052-454f-b317-c4ded2e19785/grl51455-fig-0001-m.jpgf" width=625>"""

# ╔═╡ 2870c288-1d32-435c-85d4-9f9a96887686
md"""
Figure. (a) Area-averaged SST anomaly in CMIP5 4 × CO2 simulations ; (b) Vertical distribution of the ocean heat anomaly in CMIP5 models, averaged over the World Ocean, 100 years after the CO2 quadrupling; (c) SST response under model-specific feedback and forcing (urn:x-wiley:grl:media:grl51455:grl51455-math-0001), but ensemble-mean ocean properties (q, h2, ϵ), as simulated by the two-layer ocean energy balance model (EBM) (see section 3); (d) SST response under model-specific ocean properties (q, h2, ϵ) but ensemble-mean feedback and forcing (urn:x-wiley:grl:media:grl51455:grl51455-math-0002), as simulated by the two-layer ocean EBM (see section 3). The eight CMIP5 models included here are those for which sufficient output was accessible at the time of our analysis (ocean temperature, sea surface heat flux, and AMOC data).
"""

# ╔═╡ b3f47df2-0575-4338-b10b-41a644fe6307
md"""
A major implication of our simple two layer ocean model is that the heat we have experience is the last century is probably only half of what we have already committed to, because the deep ocean will keep warming up.
"""

# ╔═╡ 393225c6-d748-45e3-951d-dc4f207b612c
md"""
### Applications to present climate
---
---

We now apply our simplwe model to see if it can predict the observed mean surface temperature increase in the last seventy years as a a function of CO$_2$ concentrations measured in the atmosphere over the same period.
 
"""

# ╔═╡ b426d86c-301f-469b-a515-e24f61c4581c
md"""
#### CO₂ concentrations measurements from Mauna Loa Volcano
---
![Mauna Loa Volcano](https://i.pinimg.com/originals/df/1a/e7/df1ae72cfd5e6d0d535c0ec99e708f6f.jpg)
"""

# ╔═╡ df4e8359-af8b-4bd5-aca0-7f6dd84859d4
CO2_historical_data_url = "https://scrippsco2.ucsd.edu/assets/data/atmospheric/stations/in_situ_co2/monthly/monthly_in_situ_co2_mlo.csv"

# ╔═╡ 4996492f-f1ed-43bf-8997-ebbe898369fb
CO2_historical_filename = download(CO2_historical_data_url)

# ╔═╡ c3b0b7fc-19be-4f04-8787-6349ab9bff7f
begin

	offset = findfirst(!startswith("\""), readlines(CO2_historical_filename))

	CO2_historical_data_raw = CSV.read(
		CO2_historical_filename, DataFrame; 
		header=offset, 
		skipto=offset + 3,
	);


	first(CO2_historical_data_raw, 11)
end

# ╔═╡ 81eba9ae-2801-4dad-9aae-e49d9472c022
validrowsmask = CO2_historical_data_raw[:, "     CO2"] .> 0

# ╔═╡ 382c2042-bd5c-4b85-9e41-ce49417c7199
CO2_historical_data = CO2_historical_data_raw[validrowsmask,:];

# ╔═╡ 0d9ef95a-c7c4-4053-b0bc-385d94c25da9
begin
	begin
		plot( CO2_historical_data[:, "      Date"] , CO2_historical_data[:, "     CO2"], label="Mauna Loa CO₂ data (Keeling curve)")
#		plot!( years, CO₂.(years.-1850), lw=3 , label="Cubic Fit", legend=:topleft)
		xlabel!("year")
		ylabel!("CO₂ (ppm)")
		title!("CO₂ observations")
		
	end
end

# ╔═╡ d3c9d49f-dccd-42eb-85f4-c81456eb3290
md"""
#### Global temperature measurements from NASA
---
![NASA](https://earthobservatory.nasa.gov/ContentWOC/images/globaltemp/global_gis_2021.jpg)
"""

# ╔═╡ 525c5d42-e0f8-439c-9b45-2f320833e81a
begin
	T_url = "https://data.giss.nasa.gov/gistemp/graphs/graph_data/Global_Mean_Estimates_based_on_Land_and_Ocean_Data/graph.txt";
	T_df = CSV.read(download(T_url),DataFrame, header=false, skipto=6,delim="     ");
    # T_df = T_df[:,[1,6]]
end

# ╔═╡ 1d73652e-b5e9-4a0b-8f51-3a8a0047df62
begin
	plot( parse.(Float64, T_df[:,1]), parse.(Float64, T_df[:,2]) .+ 14.15, color=:red, label="NASA Observations", legend=:topleft)
	xlabel!("year")
	ylabel!("Temp °C")	
end

# ╔═╡ 6c14ae3b-cc82-49ad-90b3-d312eb4cd1ee
md"""
#### Modeling temperature increase
---
"""

# ╔═╡ e9fa9953-715a-4531-93bb-2332c90322e4
md"""
Let's make a fit to the CO₂ data from Mouna Loa to extrapolate back in time and cover the same temporal range as the temp[erature data
"""

# ╔═╡ 9ce7348b-761a-4dd0-8523-08aaa9a78aa9
begin
	 # CO₂(t) = CO₂_PreIndust # no emissions
	 # CO₂(t) = CO₂_PreIndust * 1.01^t # test model
	  years = 1850:2020
	  modelCO₂(t) = CO₂_PI * (1+ (t/220)^3 )
end

# ╔═╡ 692a6928-c7a2-4b61-a794-16bef5d4e919
begin
	begin
		plot( CO2_historical_data[:, "      Date"] , CO2_historical_data[:, "     CO2"], label="Mauna Loa CO₂ data (Keeling curve)")
		plot!( years, modelCO₂.(years.-1850), lw=3 , label="Cubic Fit", legend=:topleft)
		xlabel!("year")
		ylabel!("CO₂ (ppm)")
		title!("CO₂ observations and fit")
		
	end
end

# ╔═╡ e45e36f6-6d45-42e7-b8d9-aff28bc57345
md"""
For simplicity we will consider only the transient reponse (i.e. we will assume the temperature of the deep ocean does not change), because it has little effect on the timescales over which we have a record.
"""

# ╔═╡ e174edd3-4c43-4fb0-9a6a-4ca53ad4aded
md"""
Climate feedback λₛ = $(@bind λₛ Slider(0:.1:4, show_value=true, default=λ+μ))

Upper ocean Heat Capacity C =$(@bind C Slider(0.1:.1:200, show_value=true, default=C_u))

Starting temperature T₀ = $(@bind T₀ Slider(12:.05:16; show_value=true, default=14))
"""

# ╔═╡ 1eea5e69-1380-485c-b67e-589f707cf315
pshort = ODEProblem( (temp, p, t)-> (1/C) * (λₛ*(T₀-temp)  + δF(modelCO₂(t))    ) , T₀,  (0.0, 170) )

# ╔═╡ d250f09d-3678-4093-bec6-6b7b17260fe8
solpshort = solve(pshort);

# ╔═╡ 352c81df-7bdd-4671-834e-fb875a78bdcc
begin
	plot(years,solpshort.(years.-1850),lw=2,label="Predicted Temperature from model", legend=:topleft)
	xlabel!("year")
	ylabel!("Temp °C")
	
	plot!( parse.(Float64, T_df[:,1]), parse.(Float64, T_df[:,2]) .+ 14.15, color=:black, label="NASA Observations", legend=:topleft)
end

# ╔═╡ e7ae1922-6327-40a5-995e-aeb6a2d10fa1
md""" ####  Best- and worst-case projections of future global warming
---

"""

# ╔═╡ 9fcb25f4-397b-4f1d-8b50-250f64bf44d2
md"""Consider two divergent hypothetical futures:
1. a **low-emissions** world in which emissions decrease such that CO2 concentrations stay below 500 ppm by 2100 (known in climate circles as "RCP2.6") and
2. a **high-emissions** world in which emissions continue increasing and CO2 concentrations soar upwards of 1200 ppm ("RCP8.5").
"""

# ╔═╡ 9014add9-262d-403b-b9de-5ba5b78ebb77
md"""
![](https://raw.githubusercontent.com/mitmath/18S191/Spring21/notebooks/week12/predictthefuture.svg)
"""

# ╔═╡ 00d30375-cbc4-4d6e-b353-5d20adbe0743
md"""
In the low-emissions scenario, the temperature increase stays below $ΔT = 2$ °C by 2100, while in the high-emissions scenario temperatures soar upwards of 3.5ºC above pre-industrial levels.
"""

# ╔═╡ 414f42ac-2d03-451c-8d45-7458726c7345
md"Although the greenhouse effect due to human-caused CO₂ emissions is the dominant forcing behind historical and future-projected warming, modern climate modelling considers a fairly exhaustive list of other forcing factors (aerosols, other greenhouse gases, ozone, land-use changes, etc.). The video below shows a breakdown of these forcing factors in a state-of-the-art climate model simulation of the historical period."

# ╔═╡ Cell order:
# ╟─42085492-ac8c-11eb-0620-adcb307077f1
# ╟─3e60b013-98cf-4057-9c96-b627662c85a4
# ╟─14195fc4-40e1-4576-973a-69d649fddc02
# ╟─dd6ba348-d0d7-46b7-a77f-351c00dc9c36
# ╟─2ab34e6f-9059-4f33-8abd-df15b0c00b6b
# ╟─a24c2177-5fee-4930-ab78-524085f65ed9
# ╟─b9eca29e-9028-4fd7-8c62-718a2dcf87d1
# ╟─231e4c3b-6998-4f3d-9cc3-14fa17941f7d
# ╟─482dd428-74f0-4c7c-afc9-db547777e79f
# ╠═f8868c0a-d0ec-45dc-844f-c053981277d9
# ╟─2ecbad61-0f94-4e0a-9b35-0a5a60d4405c
# ╟─2b7eeede-83ef-45ca-929b-19a3c369b105
# ╟─a8b9d935-d951-493f-9e91-45743a471249
# ╠═87c272a7-66bb-4c91-a8ee-30c74ce60461
# ╟─82e4f960-da7e-41ca-ab16-4d49636041a2
# ╟─54d73952-c016-48f5-9fb5-83aaea4363de
# ╟─05c9f594-1005-4662-ab1d-49f218012add
# ╟─1147a6ad-e528-4b41-bca6-63caa02f3a68
# ╟─37535223-1fce-402f-ab24-53d9609b2b9c
# ╠═487c6447-7d47-457f-8d0e-8ad25240a4d2
# ╟─c665a43c-5020-4cc9-8209-1a786e4c98ab
# ╟─ab4039d5-c564-4fcc-84b7-58fba714d735
# ╟─bb36eda4-91a2-4fd0-bce3-12891b610fb7
# ╟─44515eae-805e-445a-ac35-f5d9c40df83e
# ╟─37b5cafd-1147-4677-94d1-1a265736f794
# ╠═e372b079-53fc-4f6e-9365-e43ad8281f3c
# ╟─75a31c18-37c0-41db-afba-5d92f818be73
# ╠═91441230-1b1c-4702-b3a7-2f9adf2ddaaa
# ╟─576a94c7-64e7-41a8-b8cc-dc1b2e2380e2
# ╠═353e3341-5957-40e7-b2b9-800ba7a80063
# ╟─4c9e7ec6-64e9-4146-8558-f78f865df195
# ╟─2e91945b-6239-41df-83d1-cfed67081cf7
# ╠═69fa38d3-2411-496c-bf0a-af4e3531b2ae
# ╟─212d6995-d04b-4c8c-b0ed-b8b591c683e5
# ╠═3a443524-834c-44fc-a3dd-c72839adba1f
# ╟─b96b4e7c-1350-4c1a-a716-3623dae87574
# ╠═7f232e27-e2bb-4474-aadf-bebcd2e61e45
# ╟─6c2998d7-ec51-446a-a5f9-7dcef8f97454
# ╠═a71e2174-0a01-4b77-a1c8-bce3663f5485
# ╟─660aad5a-4fc3-4e0f-8d40-5884c7dde2fd
# ╠═553084e1-863d-4d01-9670-a0909732278b
# ╟─3fbc0b72-8228-4d2a-ae8e-9ca73393664b
# ╠═cd69218a-b7fb-4e70-8b17-3dadd0838d62
# ╠═296e339f-296f-475c-884a-02ca5606fd36
# ╟─59e682aa-0ccd-46eb-91cf-0c18bcf79575
# ╠═06108680-874d-4eed-8524-8adb668095b4
# ╠═fc8f0d12-c4c1-4686-8fe6-e8c1c51640e6
# ╠═fd887ed0-0248-4849-b4a6-4d428650938f
# ╠═b43a8ff7-284d-41cd-aadc-8f684fc9705e
# ╟─d13613d2-7907-4374-ab53-b42362fb0fee
# ╟─845a8226-a6ff-4549-8954-051f124ffc52
# ╠═be01be6f-c51c-493c-8306-bc4526c2c57a
# ╠═8b99c85a-478b-4ffb-848d-2812bcf3a95d
# ╟─f59c6208-2911-406d-b5b4-88c13af21f04
# ╠═683ad1f3-45bc-40a0-9f7d-49d9929dd783
# ╠═96459714-eb2a-4b6f-9b64-7b1935ff2acc
# ╠═f3f4733a-b962-43a7-8471-83db5a3b24be
# ╟─2870c288-1d32-435c-85d4-9f9a96887686
# ╟─b3f47df2-0575-4338-b10b-41a644fe6307
# ╟─393225c6-d748-45e3-951d-dc4f207b612c
# ╠═b426d86c-301f-469b-a515-e24f61c4581c
# ╠═df4e8359-af8b-4bd5-aca0-7f6dd84859d4
# ╠═4996492f-f1ed-43bf-8997-ebbe898369fb
# ╟─c3b0b7fc-19be-4f04-8787-6349ab9bff7f
# ╠═81eba9ae-2801-4dad-9aae-e49d9472c022
# ╠═382c2042-bd5c-4b85-9e41-ce49417c7199
# ╠═0d9ef95a-c7c4-4053-b0bc-385d94c25da9
# ╠═d3c9d49f-dccd-42eb-85f4-c81456eb3290
# ╠═525c5d42-e0f8-439c-9b45-2f320833e81a
# ╠═1d73652e-b5e9-4a0b-8f51-3a8a0047df62
# ╠═6c14ae3b-cc82-49ad-90b3-d312eb4cd1ee
# ╟─e9fa9953-715a-4531-93bb-2332c90322e4
# ╠═9ce7348b-761a-4dd0-8523-08aaa9a78aa9
# ╟─692a6928-c7a2-4b61-a794-16bef5d4e919
# ╠═e45e36f6-6d45-42e7-b8d9-aff28bc57345
# ╠═1eea5e69-1380-485c-b67e-589f707cf315
# ╟─e174edd3-4c43-4fb0-9a6a-4ca53ad4aded
# ╠═d250f09d-3678-4093-bec6-6b7b17260fe8
# ╠═352c81df-7bdd-4671-834e-fb875a78bdcc
# ╟─e7ae1922-6327-40a5-995e-aeb6a2d10fa1
# ╟─9fcb25f4-397b-4f1d-8b50-250f64bf44d2
# ╟─9014add9-262d-403b-b9de-5ba5b78ebb77
# ╟─00d30375-cbc4-4d6e-b353-5d20adbe0743
# ╟─414f42ac-2d03-451c-8d45-7458726c7345
