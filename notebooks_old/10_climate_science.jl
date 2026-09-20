### A Pluto.jl notebook ###
# v0.19.13

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

# ╔═╡ d8e3d937-bcda-4c84-b543-e1324f696bbc
begin 
	
	import Pkg
	using Printf, CairoMakie, PlutoUI, JLD2
	using LinearAlgebra, SparseArrays, Optim
	using DataDeps
	
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
	"><em>Sections 2.3 and 2.4</em></p>
	<p style="text-align: center; font-size: 2rem;">
	<em> Climate models: solving the climate system in Julia </em>
	</p>
	
	<style>
	body {
	overflow-x: hidden;
	}
	</style>"""
end

# ╔═╡ 8ef88534-dac4-4a62-b623-dcaf63482a96
md"""
# Section 2.3: a latitude-dependent climate

##### What is a climate model?

A climate model is a complex PDE solver that solves a set of differential equations on a discretized version of the earth, with land, ocean, and atmosphere discretized on a three-dimensional grid. The equations usually ensure the conservation of mass, momentum, and energy.

$(Resource("https://d32ogoqmya1dw8.cloudfront.net/images/eet/envisioningclimatechange/gcm_grid_graphic.jpg", :height => 400))

**Figure**: schematic depicting the discretization in a general circulation model (GCM) \
Climate models are usually massive, sophisticated models which require years to develop and have to run on high-performance computing centers.

##### Improving our first climate model
In section 2.1 you have seen your first climate model, a system of equations that predicts the earth's average surface temperature depending on the sun's forcing and the absorption of the atmosphere. 

```math
\begin{align}
C_a \frac{d T_a}{dt} & = \varepsilon \sigma T_s ^4 - 2\varepsilon \sigma T_a^4 \\
C_s \frac{d T_s}{dt} & = \varepsilon \sigma T_a^4 - \sigma T_s ^4 + (1 - \alpha) \frac{S_0}{4}
\end{align}
```

$(Resource("https://www.acs.org/content/acs/en/climatescience/atmosphericwarming/singlelayermodel/_jcr_content/articleContent/columnbootstrap_2/column0/image.img.jpg/1374081917968.jpg", :height => 300))
**Figure**: Earth's energy budget

This simple model is handy for predicting global heating and cooling but does not bring us much further. In order to characterize our climate, an essential quantity we are interested in predicting is the temperature difference between low and high latitudes. The latitudinal temperature gradient is a significant quantity that drives motions in the atmosphere and is the cause of all major climatic events. We will also later see that the latitudinal temperature gradient is one measure of the efficiency of the global climate system in redistributing heat and is used to test the ability of models to represent the climate system through time

To improve our simple model, we will introduce an extra dimension, the latitude


$(Resource("https://raw.githubusercontent.com/simone-silvestri/ComputationalThinking/main/two-models.png", :height => 200))

**Figure**: difference between a 0D model (averaged over earth's surface) and a 1D model (averaged over spherical segments)

"""

# ╔═╡ cfb8f979-37ca-40ab-8d3c-0053911717e7
md"""
## Variable insolation

Let us introduce some variability in our climate system. The variability is imposed on the system by the forcing. You already saw that the spatially and annual averaged radiative flux that reaches the earth (in units of W/m²) is
```math
S_0 / 4 , \ \ \ \ \text{with} \ \ \ \ S_0 \approx 1365 \ W m^{-2}
```
of which only ``(1 - \alpha)`` is absorbed (where ``\alpha`` is the albedo (or reflectivity) of the surface). This flux is not distributed equally along the surface of the planet. The insolation amount and intensity vary in different locations, days, seasons, and years. \

Three main parameters affect the intensity of the incoming solar radiation:

- the latitude
- the hour of the day
- the day of the year

In practice, we will simplify the system by averaging the dependencies on hour and day. What remains is a 1D model which depends on time and latitude.
"""

# ╔═╡ eb95e773-b12a-40a4-a4f1-9dced86fc8a2
md"""
##### Latitudinal dependency (angle ``\phi``)

Different parts of Earth’s surface receive different amounts of sunlight (Figure below). The Sun’s rays strike Earth’s surface most directly at the equator. This focuses the rays on a small area.  Near the poles, the Sun’s rays strike the surface at a slant. This spreads the rays over a wide area.  The more focused the rays are, the more energy an area receives, and the warmer it is.

$(Resource("https://static.manitobacooperator.ca/wp-content/uploads/2020/02/18151642/insolation_CMYK.jpg#_ga=2.245013061.1375356746.1664813564-1302273094.1664813564", :height => 300))

##### Hourly dependency (angle ``h``)

As the earth rotates along its axis, the same happens in the east-west direction. At noon, the rays will be parallel to the earth, facing the smallest surface area. In the evening/morning, rays are slanted, facing a larger surface area. We can express this dependency as an angle (``h``) that takes the value of 0 at noon, positive values in the afternoon, and negative values in the morning. Since the Earth rotates 15° per hour, each hour away from noon corresponds to an angular motion of the sun in the sky of 15°

##### Seasonal dependency (angle ``\delta``)

The declination of the sun is the angle between the equator and a line drawn from the center of the Earth to the center of the sun. It is positive when it is north and negative when it is south. The declination reaches its maximum value, +23° 17', on 21 June (the summer solstice in the northern hemisphere, the winter solstice in the southern hemisphere). The minimum value, −23° 27', is reached on 20 December. 
[Animation showing the declination angle.](https://www.pveducation.org/sites/default/files/PVCDROM/Properties-of-Sunlight/Animations/earth-rotation/earth-rotation_HTML5.html)
The declination, in degrees, for any given day may be calculated (approximately) with the equation:

```math
\delta = 23.45^\circ \sin{\left(\frac{360}{365.25} \cdot (\text{day} - 81)\right)}
```

where ``\text{day}`` starts from 1 on the 1st of January and ends at 365 on December 31st, while the 81st day is the spring equinox (22nd of March), where the earth's axis is perpendicular to the orbit



$(Resource("https://ars.els-cdn.com/content/image/3-s2.0-B9780080247441500061-f01-03-9780080247441.gif", :height => 300))
**Figure**: Declination angle (``\delta``) versus days after the equinox. 
"""

# ╔═╡ 75cacd05-c9f8-44ba-a0ce-8cde93fc8b85
md"""
#### Bringing it all together

$(Resource("https://raw.githubusercontent.com/simone-silvestri/ComputationalThinking/main/angles.png", :height => 300))
**Figure:** Angles that define solar flux with respect to earth)

We model the instantaneous solar flux with
```math
Q \approx S_0 \left( \underbrace{\sin{\phi} \sin{\delta} + \cos{h} \cos{\delta} \cos{\phi}}_{\cos{\theta_z}} \right)
```

where ``\theta_z`` is the zenith angle, shown in the figure below

$(Resource("https://ars.els-cdn.com/content/image/3-s2.0-B9780128121498000028-f02-02-9780128121498.jpg", :height => 300))
**Figure:** Zenith angle, (M. Rosa-Clot & G. Tina, Submerged and Floating Photovoltaic Systems, 2018, chapter 2)

The cosine of the zenith angle is the useful percentage of ``S_0`` which strikes the earth's surface.
What does the first term on the right-hand side express? And the second?
Negative insolation does not exist... so negative values of ``\cos{\theta_z}`` indicate night-time, for which ``Q=0``. When ``cos(\theta_z)`` is exactly equal to zero, we are at sunset or sunrise.
We can calculate the sunset (and sunrise) hour angle (``h_{ss}``) as follows
```math
\cos{h_{ss}} = - \tan{\phi}\tan{\delta}
```

##### Polar Sunrise and Sunset

Due to the inclination of the earth's axis, some regions experience days and nights that extend beyond 24 hours. This phenomenon is called Polar day and Polar night. The longest days and nights are at -90/90 ᵒN (the poles), which experience a single day and night in the year. Polar sunrise and sunset occur at a latitude that satisfies
```math
|\phi| > 90ᵒ - |\delta|
```
``\delta`` and ``\phi`` of the same sign mean that the sun is rising, vice-versa, if the signs are opposite the sun is setting

##### Daily Insolation

Let's calculate the daily insolation (in 24 hr). Since we express the day in ``2\pi`` radians and ``Q = 0`` if ``|h| > h_{ss}``

```math
\langle Q \rangle_{day}  = \frac{S_0}{2\pi} \int_{-h_{ss}}^{h_{ss}} (\sin{\phi}\sin{\delta} + \cos{\phi}\cos{\delta}\cos{h} ) \ dh
```

which is easily integrated to 

```math
\langle Q \rangle_{day}  = \frac{S_0}{\pi} \left( h_{ss}\sin{\phi}\sin{\delta}  + \cos{\phi}\cos{\delta}\sin{h_{ss}} \right)
```

"""


# ╔═╡ 18ddf155-f9bc-4e5b-97dc-762fa83c9931
function daily_insolation(lat; day = 81, S₀ = 1365.2)

	march_first = 81.0
	ϕ = deg2rad(lat)
	δ = deg2rad(23.45) * sind(360*(day - march_first) / 365.25)

	h₀ = abs(δ) + abs(ϕ) < π/2 ? # there is a sunset/sunrise
		 acos(-tan(ϕ) * tan(δ)) :
		 ϕ * δ > 0 ? π : 0.0 # all day or all night
		
	# Zenith angle corresponding to the average daily insolation
	cosθₛ = h₀*sin(ϕ)*sin(δ) + cos(ϕ)*cos(δ)*sin(h₀)
	
	Q = S₀/π * cosθₛ 

	return Q
end

# ╔═╡ 87fdc7c2-536e-4aa1-9f68-8aec4bc7069d
md""" day $(@bind day_in_year PlutoUI.Slider(1:365, show_value=true)) """

# ╔═╡ 8d4d8b93-ebfe-41ff-8b9e-f8931a9e83c2
begin
	latitude = -90:90
	δ = (23 + 27/60) * sind(360*(day_in_year - 81.0) / 365.25)
	
	polar_ϕ = 90 - abs(δ)

	function day_to_date(day)
		months = (:Jan, :Feb, :Mar, :Apr, :May, :Jun, :Jul, :Aug, :Sep, :Oct, :Nov, :Dec)
		days_in_months   = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 31, 31)
		days_till_months = [1, [sum(days_in_months[1:i]) for i in 1:11]...]

		month = searchsortedlast(days_till_months, day)
		day_in_month = month > 1 ? day - sum(days_in_months[1:month-1]) : day
		
		return "$(day_in_month) " * string(months[month])
	end
	
	Q = daily_insolation.(latitude; day = day_in_year)
	fig = Figure(resolution = (700, 300))
	ax = Axis(fig[1, 1], title = "Daily average insolation, Day: $(day_in_year) ($(day_to_date(day_in_year)))", xlabel = "latitude ᵒN", ylabel ="daily ⟨Q⟩ Wm⁻²")
	lines!(ax, latitude, Q, linewidth = 2, color=:red)
	lines!(ax,  polar_ϕ*[1, 1], [0, 600], linestyle=:dash, color=:yellow)
	lines!(ax, -polar_ϕ*[1, 1], [0, 600], linestyle=:dash, color=:yellow)
	ax.xticks = [-90, -90+23, -25, -50, 0, 25, 50, 90-23, 90]
	ylims!(ax, -10, 600)
	
	md"""
	$(current_figure())
	**Figure**: daily average insolation in Wm⁻². The yellow lines correspond to the latitude of polar sunset (sunrise), above (below) which it is only night (day) 

	$(Resource("https://ars.els-cdn.com/content/image/1-s2.0-S0074614202800171-gr8.jpg", :height => 400))
	**Figure**: Daily mean solar insolation (Q/24 hr) as a function of latitude and day of year in units of W m−2 based on a solar constant of 1366 W m−2. The shaded areas denote zero insolation. The position of vernal equinox (VE), summer solstice (SS), autumnal equinox (AE), and winter solstice (WS) are indicated with solid vertical lines. Solar declination is shown with a dashed line (K.N. Liou, An Introduction to Atmospheric Radiation, 2002, chapter 2)
	"""
end

# ╔═╡ 25223f7b-22f7-46c2-9270-4430eb6c186e
begin
	function annual_mean_insolation(lat; S₀ = 1365.2)
		Q_avg = 0
		for day in 1:365
			Q_avg += daily_insolation(lat; day, S₀) / 365
		end

		return Q_avg
	end
	
	Q_avg = zeros(length(-90:90))
	for (idx, lat) in enumerate(-90:90)
		Q_avg[idx] += annual_mean_insolation(lat)
	end

	fm = Figure(resolution = (700, 300))
	am = Axis(fm[1, 1], title = "Yearly average insolation", xlabel = "latitude ᵒN", ylabel ="yearly ⟨Q⟩ Wm⁻²")
	lines!(am, -90:90, Q_avg)

	md"""
	For our purposes, let's forget about the seasons and calculate the yearly average mean isolation

	```math
	\langle Q \rangle_{\text{yr}} = \frac{1}{365}\sum_{\text{day} = 1}^{365} \langle Q \rangle_{\text{day}}
	```
	
	$(current_figure())
	**Figure**: Annual mean insolation
	
	We can see that the average insolation is much lower (~2.5X) at the poles compared to the equator! This is reassuring given the climate we experience!
	
	"""
end


# ╔═╡ 034fc483-b188-4b2a-891a-61b76c74072d
md"""
## Solving the climate system: equilibrium solution

Let us recall the system of ODE that governs the surface and atmospheric temperature. \
The forcing is now be latitude-dependent, resulting in a latitude-dependent temperature

```math
\begin{align}
C_a \frac{d T_a}{dt} & = \varepsilon \sigma T_s ^4 - 2\varepsilon \sigma T_a^4 \\
C_s \frac{d T_s}{dt} & = \varepsilon \sigma T_a^4 - \sigma T_s ^4 + (1 - \alpha)  Q(\phi)
\end{align}
```
Here ``T_s`` is the surface (or ocean) temperature, ``T_a`` is the atmospheric temperature, ``\varepsilon`` in the emissivity of the atmosphere, ``\alpha`` is the earth's albedo and ``C_s`` and ``C_a`` are the heat capacities of the surface and atmosphere, respectively. ``Q(\phi)`` is the yearly averaged latitudinal insolation.  When the system reaches equilibrium it stops evolving in time \
(i.e the ``dT/dt = 0``)
```math
\begin{align}
& \varepsilon \sigma T_{E,s}^4 - 2\varepsilon \sigma T_{E,a}^4 = 0 \\
& \varepsilon \sigma T_{E,a}^4 - \sigma T_{E,s}^4 + (1 - \alpha) Q(\phi) = 0
\end{align}
```

which yields
```math
\begin{align}
& T_{E,a}(\phi) = \sqrt[4]{\frac{(1 - \alpha) Q (\phi)}{\sigma (2 - \varepsilon)}} \\
& T_{E,s}(\phi) = \sqrt[4]{\frac{2(1 - \alpha) Q (\phi)}{\sigma (2 - \varepsilon)}}
\end{align}
```
"""

# ╔═╡ 5d31e2a8-e357-4479-bc48-de1a1b8bc4d4
md"""
## Solving the climate system: numerical solution

The equilibrium solution is a good approximation, but the climate is always evolving, so being able to solve the time-dependent system is important for climate predictions. The system is too complicated to be solved analytically, but we can easily solve it numerically. A numerical solution of a differential equation is an approximation of the analytical solution usually computed by _discretizing_ the derivatives.

Let's see how to do this with two different methods:
- explicit time stepping
- implicit time stepping

We first assume that the time derivative can be written simply as
```math
\frac{d T}{dt} \approx \frac{T^{(n+1)} - T^{(n)}}{t^{(n+1)} - t^{(n)}}
```
where the ``n`` superscript stands for the time instant and the time step ``\Delta t`` is defined as ``\Delta t = t^{(n+1)} - t^{(n)}``

Now we can rewrite the equations as
```math 
\begin{align}
C_a \frac{T_a^{(n+1)} -  T_a^{(n)}}{\Delta t} & = G_a \\
C_s \frac{T_s^{(n+1)} -  T_s^{(n)}}{\Delta t} & = G_s 
\end{align}
```
where ``G`` are the _tendency terms_ defined as
```math
\begin{align} 
G_a & = \varepsilon \sigma T_s ^4 - 2\varepsilon \sigma T_a^4  \\ 
G_s & = \varepsilon \sigma T_a^4 - \sigma T_s ^4 + F 
\end{align}
```
and ``F`` is the _forcing_
```math
F = (1-\alpha) Q
```

#### Explicit time stepping

\

The tendencies are calculated at time ``n``, so the update rule becomes:
```math 
\begin{align}
T_a^{(n+1)} & = T_a^{(n)} + \frac{\Delta t}{C_a} G_a^{(n)} \\
T_s^{(n+1)} & = T_s^{(n)} + \frac{\Delta t}{C_s} G_s^{(n)} 
\end{align}
```
It is called _explicit time stepping_ because the values of ``G_a^{(n)}`` and ``G_s^{(n)}`` are readily available and the update rule for the time step ``n+1`` is explicitly dependent on time step ``n``.
Explicit time stepping is fast and simple to implement, but it has some shortcomings when time stepping with large ``\Delta t``

#### Implicit time stepping

\

The tendencies are calculated at time ``n+1``. This means that they are not readily available and we have to relate them to temperatures at time ``n+1``. Then
```math
\begin{align} 
G_a^{(n+1)} & = \varepsilon \sigma \left(T_s^{(n+1)}\right) ^4 - 2\varepsilon \sigma \left(T_a^{(n+1)}\right)^4 \\ 
G_s^{(n+1)} & = \varepsilon \sigma \left(T_a^{(n+1)}\right)^4 - \sigma \left(T_s^{(n+1)}\right)^4 + F
\end{align}
```
We would like to express the ODEs as a linear system, but these equations are non-linear. \
Fortunately, if we assume that the temperature does not change significantly in one-time step (``T^{(n+1)} - T^{(n)} \ll T^{(n)}``) we can linearize ``\left(T^{(n+1)}\right)^4`` as
```math
\left(T^{(n+1)}\right)^4 \approx \left(T^{(n)}\right)^3 T^{(n+1)}
```

```math
\begin{align} 
G_a^{(n+1)} & = \varepsilon \sigma \left(T_s^{(n)}\right)^3 T_s^{(n+1)} - 2\varepsilon \sigma \left(T_a^{(n)}\right)^3 T_a^{(n+1)} \\ 
G_s^{(n+1)} & = \varepsilon \sigma \left(T_a^{(n)}\right)^3 T_a^{(n+1)} - \sigma \left(T_s^{(n)}\right)^3 T_s^{(n+1)} + F
\end{align}
```

Substituting the expressions for the tendencies in the update equations we get
```math
\begin{align}
\left(C_a + \Delta t 2 \varepsilon \sigma \left(T_a^{(n)}\right)^3\right) T_a^{(n+1)} - \Delta t \varepsilon \sigma \left(T_s^{(n)}\right)^3 T_s^{(n+1)} & = C_a T_a^{(n)}\\
\left( C_s  + \Delta t \sigma\left(T_s^{(n)}\right)^3 \right) T_s^{(n+1)} - \Delta t \varepsilon \sigma \left(T_a^{(n)}\right)^3 T_a^{(n+1)} & = C_s T_s^{(n)} + \Delta t F
\end{align}
```

This is a system of linear equations in the variables ``T = [T_a^{(n+1)}``; ``T_s^{(n+1)}]`` representable as the linear system
```math
A T = b
```
where the matrix ``A`` is
```math
A = \begin{bmatrix}
C_a  + \Delta t 2 \varepsilon \sigma \left(T_a^{(n)}\right)^3 & - \Delta t\varepsilon \sigma \left(T_s^{(n)}\right)^3 \\
 - \Delta t  \varepsilon \sigma \left(T_a^{(n)}\right)^3  &  
C_s  + \Delta t \sigma\left(T_s^{(n)}\right)^3 \\ 
\end{bmatrix}
```
and the right hand side (``b``) is
```math
b = 
\begin{bmatrix}
C_a T_a^{(n)} \\ C_s T_s^{(n)} + \Delta t F
\end{bmatrix}
```

"""

# ╔═╡ 724901e9-a19a-4d5f-aa6a-79ec0f230f24
md"""
# Let's code our model in Julia

We can start creating a ```struct``` that contains the information we need, i.e., the parameters, the state, and the solution method of the system.

Some comments: 
- Temperature (and forcing) are vectors depending on the discrete latitudinal grid ``\phi``
- To retrieve parameters of the `struct` it is useful to write functions that we can later extend
- It is convenient to write a constructor with some default values and a `show` method 
"""

# ╔═╡ 15dee5d8-e995-4e5a-aceb-48bcce42e76d
md"""
### Coding an explicit time stepping function

Now we can write a function which evolves our model of a time step ``\Delta t``.
"""

# ╔═╡ 2287bff1-6fb0-4431-8e15-aff3d7b6e005
md"""
### Coding an implicit time stepping function

If we want to time step implicitly we have to solve the ``AT=b`` linear system \
Fortunately in Julia, solving a linear system is as simple as writing
```
T = A \ b
```

the only tricky part remaining is to construct the matrix \
Since temperature can be vectors, we align them starting from the surface temperature and following with the atmospheric temperature. Let us imagine we have three different latitudes (−45,0,45) where subscript refers to ``\phi = -45``, while 2 and 3 to ``0`` and ``45``. We can arrange our matrix in the following way
```math
  \begin{bmatrix}
    {D_a}_{1} & & & {d_a}_1 & &\\
    & {D_a}_{2} & & & {d_a}_2 & \\
	& & {D_a}_{3}  & & & {d_a}_2 \\
	{d_s}_1 & & & {D_s}_{1} & & \\
    & {d_s}_2 & & & {D_s}_{2} & \\
    & & {d_s}_3 & & & {D_s}_{3}  \\
  \end{bmatrix} \begin{bmatrix}
{T_a}_1^{n+1} \\ {T_a}_2^{n+1} \\ {T_a}_3^{n+1} \\ {T_s}_1^{n+1} \\ {T_s}_2^{n+1} \\ {T_s}_3^{n+1}
\end{bmatrix} = 
\begin{bmatrix}
C_a {T_a}_1^{n} \\ C_a {T_a}_2^{n} \\ C_a {T_a}_3^{n} \\ C_s {T_s}_1^{n} + \Delta t F_1  \\ C_s {T_s}_2^{n} + \Delta t F_2  \\ C_s {T_s}_3^{n} + \Delta t F_3
\end{bmatrix} 

```
where the diagonal terms are the sink terms, while the off-diagonal are the interexchange terms between surface and atmosphere. (Following the A matrix outlined above)
"""

# ╔═╡ e24e54a7-804e-40e8-818e-8766e5e3732b
md"""
Implicit time stepping implies constructing the matrix, calculating the rhs and solving the linear system
"""

# ╔═╡ 049e2164-24ac-467c-9d96-77510ac6ff57
md"""
### Model verification

Let's verify that our model reaches equilibrium with both implicit and explicit time stepping.

Some constants to be defined:
- the stefan Boltzmann constant (σ) in [Wm⁻²K⁻⁴]
- the oceanic and atmospheric heat capacity in [Wm⁻²K⁻¹⋅day]

Note that we need the heat capacity in those units to be able to time step in [days].
"""

# ╔═╡ f07006ac-c773-4829-9a38-6f9991403386
begin
	const σ  = 5.67e-8	
	const Cₛ = 1000.0 * 4186.0 * 100 / (3600 * 24) #  ρ * c * H / seconds_per_day
	const Cₐ = 1e5 / 10 * 1000 / (3600 * 24)       # Δp / g * c / seconds_per_day
end

# ╔═╡ 039ec632-d238-4e63-81fc-a3225ccd2aee
latitude_dependent_equilibrium_temperature(lat, ε, α) =  
                 (2 * annual_mean_insolation(lat) * (1 - α) / (2 - ε) / σ )^(1/4)

# ╔═╡ 1431b11f-7838-41da-92e3-bcca9f4215b3
begin 
	struct RadiativeModel{S, T, E, A, F, C}
		stepper :: S  # time stepping method
		Tₛ :: T       # surface temperature
		Tₐ :: T       # atmospheric temperature
		ε  :: E       # atmospheric emissivity
		α  :: A       # surface albedo
		Q  :: F       # forcing
		Cₛ :: C       # surface heat capacity
		Cₐ :: C       # atmospheric heat capacity
	end
	
	# Types that specify the time-stepping method
	struct ExplicitTimeStep end
	struct ImplicitTimeStep end

	# convenience alias for dispatch
	const ExplicitRadiativeModel = RadiativeModel{<:ExplicitTimeStep}
	const ImplicitRadiativeModel = RadiativeModel{<:ImplicitTimeStep}
	
	# Let's define functions to retrieve the properties of the model.
	# It is always useful to define functions to extract struct properties so we 
	# have the possibility to extend them in the future
	# emissivity and albedo
	albedo(model)     = model.α
	emissivity(model) = model.ε

	# Utility functions to @show the model
	timestepping(model::ExplicitRadiativeModel) = "Explicit"
	timestepping(model::ImplicitRadiativeModel) = "Implicit"

	# A pretty show method that displays the model's parameters
	function Base.show(io::IO, model::RadiativeModel)
		print(io, "Radiative energy budget model with:", '\n',
		"├── time stepping: $(timestepping(model))", '\n',
		"├── length model: $(length(model.Tₛ))", '\n',
    	"├── ε: $(emissivity(model))", '\n',
        "├── α: $(albedo(model))", '\n',
        "└── Q: $(model.Q) Wm⁻²")
	end

	# A constructor with some defaults...
	function RadiativeModel(step = ImplicitTimeStep(); 
						ε = 0.8, 
					    α = 0.2985, 
						ϕ = range(-89.0, 89.0,length=90))
		N = length(ϕ)
		Q = annual_mean_insolation.(ϕ)
		Tₛ_init = 200.0 .* ones(N)
		Tₐ_init = 180.0 .* ones(N)

		args = (Tₛ_init, Tₐ_init, ε, α, Q, Cₛ, Cₐ)
		return RadiativeModel(step, args...)
	end
end

# ╔═╡ de5d415f-8216-473d-8e0b-a73139540e1e
# Let's test the constructor and the show method
RadiativeModel(ϕ = 45)

# ╔═╡ b85fdf41-ef8f-4314-bc3c-383947b9f02c
@bind values PlutoUI.combine() do Child
	md"""
	What happens if we change latitude (``\phi``)? \
	And if we change ``\varepsilon`` or ``\alpha``? \
	And if we increase our Δt? (hint: try increasing Δt with high ``\varepsilon`` and low ``\alpha``)

	
	``\varepsilon`` $(
		Child(PlutoUI.Slider(0:0.05:1, show_value=true, default=0.75))
	) \
	
	``\alpha`` $(
		Child(PlutoUI.Slider(0:0.05:1, show_value=true, default=0.3))
	) \
	
	``\phi`` $(
		Child(PlutoUI.Slider(-89:2:89, show_value=true, default=45))
	) \
	
	``\Delta t`` $(
		Child(PlutoUI.Slider(30:5:100, show_value=true, default=20))
	)

	"""
end


# ╔═╡ 16ca594c-c9db-4528-aa65-bab12cb6e22a
md"""
## Stability of time stepping methods

Temperature starts oscillating and then explodes when using a large Δt, this is because of the intrinsic stability of the time stepping method. A method is considered _unstable_ when it leads to unbounded growth despite the stability of the underlying differential equation. 
Let's analyze this by simplifying a bit our discretized atmospheric equation. We remove the coupling between the surface and the atmosphere. This is like saying that all of a sudden the atmosphere becomes transparent to the radiation coming from the earth (unlikely)
```math
C_a \frac{T_a^{(n+1)} - T_a^{(n)}}{\Delta t} = -2\varepsilon \sigma T_a^4
```
Since there is no source, the temperature will exponentially decrease until it reaches equilibrium at 0 K. \
let us define
```math
D = \frac{2 \varepsilon \sigma \left( T_a^{(n)}\right)^3}{C_a}
```

The update rule for the explicit time stepping is
```math
T_a^{(n+1)} = T_a^{(n)}(1 - D \Delta t)
```

We know that temperature should remain positive
```math
\frac{T_a^{(n+1)}}{T_a^{(n)}} = (1 - D\Delta t)> 0 \ .
```
This translates in the condition on ``\Delta t``
```math
\Delta t < \frac{1}{D} = \frac{C_a}{2\varepsilon \sigma \left( T_a^{(n)}\right)^3}
```
For ``T_a`` equal to 288 K, ``\Delta t`` should be lower than $(@sprintf "%.2f" Cₐ / (2 * 0.5 * σ * 288^3)) days \
Going back to the previous plot, which combination of parameters will make my model the most unstable?

What happens for implicit time stepping? We have that
```math
\frac{T_a^{(n+1)}}{T_a^n} = \frac{1}{1 + D\Delta t} > 0
```
Since ``D > 0``, implicit time stepping is stable for _any_ positive ``\Delta t`` \

In summary, for an ODE: 
- _Explicit time stepping_ is generally **_conditionally stable_**, i.e. the discrete system is stable given ``\Delta t < C`` where ``C`` depends on the system. 
- _Implicit time stepping_, on the other hand, is generally **_unconditionally stable_**
"""

# ╔═╡ ea517bbf-eb14-4d72-a4f4-9bb823e02f88
md"""
# Predicting earth's temperature distribution
"""

# ╔═╡ b65e2af0-9a08-4915-834b-1a20b2440891
md"""
Let's define some utility functions: 
- a function that evolves our model in time
- a function that plots the results as a function of ϕ
"""

# ╔═╡ 91dec8b7-a9da-4c62-973e-2fd8e0a92e58
function plot_latitudinal_variables!(ϕ, vars, labels, colors, styles; 
									 ylabel  = "Temperature [ᵒC]", 
									 ylims   = nothing, 
									 title   = "", 
									 leg_pos = :cb,
									 ax_pos  = [1, 1],
									 res     = (700, 350),
									 fig     = Figure(resolution = res))

	axis = Axis(fig[ax_pos...]; title, ylabel, xlabel = "latitude [ᵒN]")	
	colors = 
	for (var, label, color, linestyle) in zip(vars, labels, colors, styles)
		lines!(axis, ϕ, var; linestyle, label, color)
	end
	axislegend(axis, position = leg_pos, framevisible = false)
	!isnothing(ylims) && ylims!(axis, ylims)
	
	return fig
end

# ╔═╡ 140bcdac-4145-47b3-952f-bfe50f6ed41c
md"""
$(Resource("https://www.researchgate.net/profile/Anders-Levermann/publication/274494740/figure/fig9/AS:668865801506834@1536481442913/a-Surface-air-temperature-as-a-function-of-latitude-for-land-dashed-line-corrected.png", :height => 400))

**Figure**: Observed temperature profile from: Feulner et al, _On the Origin of the Surface Air Temperature Difference between the Hemispheres in Earth's Present-Day Climate_ (2013), Journal of Climate.
"""

# ╔═╡ 849775fa-4990-47d3-afe0-d0a049bb90af
md"""
We download the annually and zonally average observed temperature and radiation profiles from `https://github.com/simone-silvestri/ComputationalThinking/raw/main/` using the Julia package DataDeps and open it using the JLD2 package
"""

# ╔═╡ 4d517df8-0496-40a2-8e44-5beda6cd7226
# ╠═╡ show_logs = false
begin
	# We use the package DataDeps to download the data stored at `online_path`
	ENV["DATADEPS_ALWAYS_ACCEPT"]="true"	
	
	online_path = "https://github.com/simone-silvestri/ComputationalThinking/raw/main/"

	dh = DataDep("computional_thinking_data",
	    "Data for class",
	    [online_path * "observed_radiation.jld2",   # Observed ASR and OLR (absorbed shortwave and outgoing longwave radiation)
	     online_path * "observed_T.jld2"]
		)

	DataDeps.register(dh)

	datadep"computional_thinking_data"

	obs_temp_path = @datadep_str "computional_thinking_data/observed_T.jld2"
	obs_rad_path  = @datadep_str "computional_thinking_data/observed_radiation.jld2"
	
	# Load the observed zonally and yearly averaged temperature profile
	T_obs = jldopen(obs_temp_path)["T"]
end

# ╔═╡ 6932b969-0760-4f09-935a-478ac56de262
md""" ε $(@bind ε PlutoUI.Slider(0:0.01:1, show_value=true, default = 0.0)) """

# ╔═╡ 6ce47d90-d5a2-43c0-ad64-27c13aa0f5db
# RadiativeModel has parametric types {S, T, E, A, F, C} where the third one (E) 
# corresponds to theemissivity
emissivity(model::RadiativeModel{<:Any, <:Any, <:Function}) = model.ε(model)

# ╔═╡ a93c36c9-b687-44b9-b0b6-5fe636ab061c
# Remember that our temperature can be a scalar or a vector, 
# depending on the latitude given to construct the model
function time_step!(model::ExplicitRadiativeModel, Δt)
	# Temperatures at time step n
	Tₛ = model.Tₛ
	Tₐ = model.Tₐ

	α = albedo(model)
	ε = emissivity(model)

	# Calculate the explicit tendencies
	Gₛ = @. σ * (ε * Tₐ^4 - Tₛ^4) + (1 - α) * model.Q 
	Gₐ = @. σ * ε * (Tₛ^4 - 2*Tₐ^4)

	# update temperatures to time step n+1
	@. model.Tₛ += Δt * Gₛ / model.Cₛ
	@. model.Tₐ += Δt * Gₐ / model.Cₐ
end

# ╔═╡ c0ff6c61-c4be-462b-a91c-0ee1395ef584
function construct_matrix(model, Δt)
	# Temperatures at time step n
	Tₛ = model.Tₛ
	Tₐ = model.Tₐ

	ε = emissivity(model)
	Q = model.Q

	Cₐ = model.Cₐ
	Cₛ = model.Cₛ

	m = length(Tₛ)
	
	eₐ = @. Δt * σ * Tₐ^3 * ε
	eₛ = @. Δt * σ * Tₛ^3

	# We build and insert the diagonal entries
	Da = @. Cₐ + 2 * eₐ
	Ds = @. Cₛ + eₛ
	
	D  = [Da..., Ds...] 

	# the off-diagonal entries corresponding to the interexchange terms
	da = @. -ε * eₛ
	ds = @. -eₐ
	
	# spdiagm(idx => vector) constructs a sparse matrix 
	# with vector `vec` at the `idx`th diagonal 
	A = spdiagm(0 => D,
				m => da,
			   -m => ds)
	return A
end

# ╔═╡ 97e1ce89-f796-4bd1-8e82-94fc838829a6
function time_step!(model::ImplicitRadiativeModel, Δt)
	# Construct the LHS matrix
	A = construct_matrix(model, Δt)

	α = albedo(model)

	# Calculate the RHS
	rhsₐ = @. model.Cₐ * model.Tₐ
	rhsₛ = @. model.Cₛ * model.Tₛ + Δt * (1 - α) * model.Q

	rhs = [rhsₐ..., rhsₛ...]

	# Solve the linear system
	T = A \ rhs

	nₐ = length(model.Tₐ)
	nₛ = length(model.Tₛ)

	@inbounds @. model.Tₐ .= T[1:nₐ]
	@inbounds @. model.Tₛ .= T[nₐ+1:nₐ+nₛ]
end

# ╔═╡ 00776863-2260-48a8-83c1-3f2696f11d96
begin 
	function compare_methods!(ε, α, ϕ, Δt)

		# Construct the two models
		model_explicit = RadiativeModel(ExplicitTimeStep(); α, ε, ϕ)
		model_implicit = RadiativeModel(ImplicitTimeStep(); α, ε, ϕ)

		# Time stepping parameters
		stop_year = 50
		nsteps = Int((stop_year * 365) ÷ Δt) # in Δt days

		# Vectors holding Tₛ(time)
		T_explicit = zeros(nsteps)
		T_implicit = zeros(nsteps)

		# Time step and save temperature information
		@inbounds for step in 1:nsteps
			time_step!(model_explicit, Δt)
			time_step!(model_implicit, Δt)
			T_explicit[step] = model_explicit.Tₛ[1]
			T_implicit[step] = model_implicit.Tₛ[1]
		end

		# Calculate equilibrium temperature analytically
		T_equilibrium = latitude_dependent_equilibrium_temperature(ϕ, ε, α) .* ones(nsteps)
		T_reference   = latitude_dependent_equilibrium_temperature(45.0, 0.75, 0.3) .* ones(nsteps)

		time_axis = (1:nsteps) .* (Δt / 365)
		
		title = @sprintf("final temperature at %d ᵒN: (T_eq, T_exp, T_imp) = (%.2f, %.2f, %.2f) ᵒC", ϕ, T_equilibrium[end], T_explicit[end], T_implicit[end])

		# Plot the results
		fig = Figure(resolution = (800, 300))
		ax  = Axis(fig[1, 1]; title, ylabel = "Temperature [K]", xlabel = "time [yr]")
		lines!(ax, time_axis, T_reference, color = :black, linewidth = 1, linestyle=:dash, label = "equilibrium at 45 ᵒN and ε = 0.75, α = 0.3")
		lines!(ax, time_axis, T_equilibrium, color = :red, linewidth = 1, linestyle=:dashdot, label = "equilibrium temperature")
		lines!(ax, time_axis, T_explicit , color = :blue, linewidth = 2, label = "explicit time stepping")	
		lines!(ax, time_axis, T_implicit , color = :green, linewidth = 2, label = "implicit time stepping")	

		axislegend(ax, position = :rb, framevisible = false)

		return fig
	end

	compare_methods!(values[1], values[2], values[3], values[4])
	current_figure()
end

# ╔═╡ dfde2f6a-f612-4013-8d42-5590221167c9
function evolve_model!(model; Δt = 30.0, stop_year = 40)
	stop_iteration = Int(stop_year * 365 ÷ Δt)
	@inbounds for iter in 1:stop_iteration
		time_step!(model, Δt)
	end
end

# ╔═╡ 1d8a69b7-52db-4865-8bf2-712c2b6442f5
# ╠═╡ show_logs = false
begin 
	ϕ = range(-89, 89, length=90)
	
	# calculating the equilibrium temperature
	T_eq  = latitude_dependent_equilibrium_temperature.(ϕ, Ref(ε), Ref(0.2985));

	# construct and evolve a zero d model with constant ε
	model_lat = RadiativeModel(; ε, ϕ)
	evolve_model!(model_lat, Δt = 50, stop_year = 50);

	# plot the latitudinal dependent temperatures
	plot_latitudinal_variables!(ϕ, [T_obs.-273.15, T_eq.-273.15, model_lat.Tₛ .- 273.15],
								   ["observed T", "equilibrium T", "modelled T"],
								   [:black, :green, :red], 
								   [:dashdot, :solid, :solid]; ylims = (-60, 50), title = "emissivity: $ε");
	md""" 
	$(current_figure())
	**Figure**: Comparison between observed (dashed-dotted line) and temperature calculated by the model
	"""
end

# ╔═╡ 5884999f-f136-4ae7-8831-cc3a36f50a98
begin
	ASR_obs = jldopen(obs_rad_path)["ASR"]
	ASR(model) = (1 .- albedo(model)) .* model.Q 
	
	plot_latitudinal_variables!(ϕ, [ASR(model_lat), ASR_obs],
								["modeled ASR [W/m²]", "observed ASR [W/m²]"],
								[:red, :red], 
								[:solid, :dashdot],
								ylabel = "")
	md""" 
	## Improving the model

	the model we constructed has several approximations which we can improve on
	
	### Latitude-dependent albedo

	Till now, we assumed the albedo to be equal to 0.2985 because it gave us the best fit with observations in an averaged global scenario. However, is a constant albedo a good approximation when considering latitudinal dependency? We can infer the earth's _real_ albedo by looking at the absorbed radiation at the surface (ASR or absorbed shortwave radiation). In our model we can calculate it as such
	```
	ASR(model) = @. (1 - albedo(model)) * model.Q
	```
	$(current_figure())
	**Figure**: comparison between ASR used to force the RadiativeModel and the observed ASR (from [NCEP reanalysis](https://psl.noaa.gov/data/gridded/data.ncep.reanalysis.html))

	The ASR seems lower at the poles, suggesting that the albedo is higher in those regions. This is a result of the lower sun angle present at the poles but also, the higher presence of fresh snow, ice, and smooth open water- all areas prone to high levels of reflectivity
	
	``\alpha`` can be approximated with a function of ``\sin{\phi}`` that allows us to have a lower albedo at the poles than the one at the equator
	```math
	\alpha(\phi) = \alpha_0 + \frac{\alpha_1}{2}\left( 3\sin^2{\phi} - 1\right)
	```
	### Temperature-dependent emissivity

	If the temperature rises, the saturation pressure rises, allowing more water vapor to remain in equilibrium in the gaseous form in the atmosphere. Since the emissivity is largely dependent on the water vapor content, a temperature rise causes an increase in the atmosphere's emissivity. You have seen in 2.2 that this _feedback_ effect can be modeled with a linear function of temperature:
	```math
	\varepsilon = \varepsilon_0 + \varepsilon_1 \log{\frac{\text{CO}_2}{{\text{CO}_2}_{\text{PRE}}}} + \varepsilon_2(T-T_{\text{PRE}})
	```
	Where the subscript ``\text{PRE}`` indicates pre-industrial values. Remember! The temperature in the above formula is the _surface_ temperature. The effect of water vapor is not hugely important in the climate change context, as the vapor pressure of H₂O is capped by the saturation pressure, but is of great importance in shaping the latitudinal temperature profile (it is much colder in the poles that in the equator).
	To allow a temperature-dependent emissivity, we have to extend the ```emissivity``` method to ensure it can accept functions. We can define a function that accepts the model as an input and returns the temperature-dependent emissivity and use it as an input to our model
	```
	varε(model) = ε₀ + ε₁ * log2(440.0/280) + ε₂ * (model.Tₛ - 286.38)
	```
	We that have to dispatch the emissivity function to behave in a different way when the ε field of our RadiativeModel is a function	
	```
	emissivity(model::RadiativeModel{<:Any, <:Any, <:Function}) = model.ε(model)
	```
	Note! Physical values of emissivity range between 0 and 1!
	"""
end

# ╔═╡ f2510e0a-23f2-4a40-a7db-7b59898facfa
begin
	# variable albedo
	a₀ = 0.312
	a₁ = 0.15 
	varα = @. a₀ + a₁ .* 0.5 * (3 * sind(ϕ)^2 .- 1)

	# variable emissivity (function that depends on the model state)
	ε₀, ε₁, ε₂ = (0.75, 0.02, 0.005)
	function varε(model) 
		return @. min(max(ε₀ + ε₁ * log2(440.0/280) + ε₂ * (model.Tₛ - 286.38), 0), 1.0)
	end
end

# ╔═╡ 4640a179-3373-4901-ac31-31022e8c7eb2
begin
	feedback_model  = RadiativeModel(; ε = varε, α = varα, ϕ)
	reference_model = RadiativeModel(; ε = 0.8, ϕ)

	evolve_model!(feedback_model,  Δt = 50, stop_year = 50)
	evolve_model!(reference_model, Δt = 50, stop_year = 50);

	α_obs = 1 .- ASR_obs ./ feedback_model.Q

	fig_temp = plot_latitudinal_variables!(ϕ, [albedo(feedback_model), ϕ ./ ϕ .* 0.2985, α_obs],
											  ["varα(model)", "α = 0.2985", "observed α"], 
											  [:blue, :red, :black], 
											  [:solid, :solid, :dashdot], ylabel = "albedo",
											  ylims = (0.0, 0.8), 
											  leg_pos = :ct, 
											  res = (700, 600))
	
	fig_temp = plot_latitudinal_variables!(ϕ, [emissivity(feedback_model), ϕ ./ ϕ .* 0.75],
											  ["varε(model)", "ε = 0.75"], 
											  [:blue, :red], 
											  [:solid, :dash], ylabel = "emissivity",
											  fig = fig_temp, 
											  ax_pos = [1, 2],
											  ylims = (0.3, 1.0))
	
	fig_temp = plot_latitudinal_variables!(ϕ, [feedback_model.Tₛ .- 273.15,
											   reference_model.Tₛ .- 273.15,
											   T_obs .- 273],
											  ["variable ε and α",
											   "constant ε and α", 
											   "observed T"], 
											  [:blue, :red, :black, :purple], 
											  [:solid, :solid, :dashdot, :dash], 
											  ylims = (-70, 70),
											  ax_pos = [2:2, 1:2], 
											  fig = fig_temp)
	
	md"""
	Let's take a look at our final latitudinal temperature model, complete with varying emissivity and albedo. 

	$(current_figure())
	**Figure**: comparison between observed temperature (dashed-dotted line), temperature calculated from a model with constant ``\varepsilon`` and ``\alpha`` (red) and from a model with latitude-dependent ``\alpha`` and water vapor feedback (blue)

	The prediction worsens when compared to the simple constant emissivity/constant albedo model. This is usually a sign that we are neglecting some important physical phenomenon.
	"""
end

# ╔═╡ d13c319d-345a-40b8-b90d-b0b226225434
begin
	OLR_obs = jldopen(obs_rad_path)["OLR"]

	OLR(model) = σ .* ((1 .- emissivity(model)) .* model.Tₛ.^4 + emissivity(model) .* model.Tₐ.^4)

	plot_latitudinal_variables!(ϕ, [ASR_obs, ASR(feedback_model), OLR_obs, OLR(feedback_model)],
								["Observed ASR",
								 "Modeled ASR",
								 "Observed OLR",
								 "Modeled OLR"],
								[:red, :red, :blue, :blue],
								[:dashdot, :solid, :dashdot, :solid],
								ylabel = "ASR and OLR [W/m²]")
	
	md"""
	### Outgoing Longwave Radiation (OLR)
	
	Outgoing longwave radiation is the energy that the earth loses to space in the form of radiative emission. It has a contribution from the atmosphere and a contribution from the emitted energy from the surface that manages to escape from the absorption of the atmosphere
	```
	OLR(model) = @. (1 - emissivity(model)) * σ * model.Tₛ^4 + emissivity(model) * σ * model.Tₐ^4
	```

	$(current_figure())
	**Figure**: comparison between observed and calculated ASR and OLR

	The OLR and ASR from our model match quite closely. This is expected: since every latitude in our model is independent, the incoming energy (ASR) must match the outgoing energy (OLR) for energy conservation to hold. This is not the case for the observed profiles. We see that at the equator the incoming energy is larger than the emission and vice-versa happens at the poles. This is an indication that, in the real climate system, energy is transported from the equator to the poles. The mechanism that allows this heat transport is the presence of a global atmospheric circulation. 
	"""
end

# ╔═╡ 8f21fc70-e369-4938-b0c2-5a4fbae71713
md"""
### Global atmospheric circulation

There are three main factors that we have to take into account when considering large scale atmospheric circulation:
- hot air rises
- cold air sinks
- Coriolis force pushes winds to the right in the upper hemisphere and to the left in the lower hemisphere

Hot air in the equator rises upwards and moves towards the pole. It cools down in the process and about 30ᵒ it starts to sink creating large circulation cells called Hadley cells. At the poles, cold dense air tends to sink and move down towards the equator, creating the Polar pressure cells. While moving toward the equator, the air coming from the pole encounters faster spinning latitudes and is, therefore, diverted by the Coriolis effect. In between these two major cells, we form strong winds which are diverted towards the east (westerlies)

$(Resource("https://tdgil.com/wp-content/uploads/2020/04/Hadley-Cells-and-Wind-Directions.jpg", :height => 500))
**Figure**: schematic depicting the global atmospheric circulation

Global circulation requires the solution of a complex system of partial differential equations on the sphere. These equations (named Navier-Stokes equations) the conservation of mass, momentum, and energy in the climate system.
```math
\begin{align}
 & \frac{\partial\boldsymbol{\rho u}}{\partial t} + \boldsymbol{\nabla} \cdot (\rho \boldsymbol{u} \otimes \boldsymbol{u}) + f\widehat{\boldsymbol{z}} \times \boldsymbol{u} = - \boldsymbol{\nabla} p + \rho \boldsymbol{g} \\
& \frac{\partial \rho e}{\partial t} + \boldsymbol{\nabla}\cdot (\boldsymbol{u} (\rho e + p)) = Q_{incom} - \varepsilon \sigma T^4 \\
& \frac{\partial \rho}{\partial t} + \boldsymbol{\nabla} \cdot (\rho \boldsymbol{u}) = 0 \\
\end{align}
```
complemented by an equation of state (usually ideal gas) in the form ``p = EOS(\rho, e)``. General Circulation Models (or GCMs) solve this system of equations on a discrete three-dimensional grid to provide velocities and temperatures on the surface and in the atmosphere.
"""

# ╔═╡ 901548f8-a6c9-48f8-9c8f-887500081316
md"""
# Section 2.4: Heat transport

We have seen that the latitudinal temperature gradient generates a global circulation that transports heat from the equator to the poles. It is too computationally expensive to solve the governing equations here (General Circulation Models, or GCMs run ono supercomputers for days to solve the climate system). So we have to model our latitudinal transport in an easier way
"""

# ╔═╡ 567fa8d3-35b4-40d7-8404-ae78d2874380
md"""
## Modeling latitudinal transport
what do we have to add to our model to include atmospheric circulation?

```math
\begin{align}
C_a \frac{dT_a}{dt} & = \sigma T_s^4 - 2\varepsilon \sigma T_a^4 + \mathcal{T}_a \\
C_s \frac{dT_s}{dt} & = - \sigma T_s^4 + \varepsilon \sigma T_a^4 + (1 - \alpha) Q + \mathcal{T}_s
\end{align}
```

where ``\mathcal{T}_a`` and ``\mathcal{T}_s`` represent the source/sink caused by heat transported around by currents in the atmosphere and in the ocean.

How can we calculate these additional terms?

$(Resource("https://raw.githubusercontent.com/simone-silvestri/ComputationalThinking/main/schematic.png", :height => 400))
**Figure**: energy fluxes in our control volume.

In our control volume we have a flux in ``F^+`` and a flux out ``F^-``
The energy stored in out control volume (``\mathcal{T}``) will be the difference of the fluxes divided by the surface are of the control volume, where
```math
A = \underbrace{2\pi R \cos{\phi}}_{\text{circumference}} \cdot \underbrace{R\Delta \phi}_{\text{width}}
```
So 
```math
\mathcal{T} = - \frac{1}{2\pi R^2 \cos{\phi}} \frac{F^- - F^+}{\Delta \phi}
```
taking ``\Delta \phi \rightarrow 0``
```math
\mathcal{T} = - \frac{1}{2\pi R^2 \cos{\phi}} \frac{\partial F}{\partial \phi}
```

How can we represent ``F``? 
Mathematically, the flux at the boundary of a computational element is calculated as ``(V\cdot T)``. The velocity ``V`` is the flow velocity at the interface of the element, which is determined by the Navier-Stokes equations, 3-dimensional PDEs that ensure momentum conservation in fluid dynamic systems. These equations are notoriously hard to solve, they require very fine grids due to the chaotic nature of fluid flows. Therefore, we will take a shortcut and _parametrize_ the flux at the interface (i.e., approximate the flux with a semi-empirical model).
We can think at the transport of heat by the atmosphere as moving heat from _HOT_ to _COLD_ regions of the earth. In general, this holds if we zoom out enough. We can think of the transport by the atmosphere as a diffusion process, which goes "DOWN" the gradient of temperature. As such we can parametrize the heat flux with an effective conductivity
```math
F \approx - 2\pi R^2 \cos{\phi} \cdot \kappa \frac{\partial T}{\partial \phi}
```
where ``\kappa`` is the "conductivity" of our climate system in W/(m²K) due to the movement in the atmosphere
And, finally assuming that ``\kappa`` does not vary in latitude (very strong assumption!) we can model the heat source due to transport as
```math
\mathcal{T} = \frac{\kappa}{\cos{\phi}} \frac{\partial}{\partial \phi} \left(\cos{\phi}  \frac{\partial T}{\partial \phi} \right)
```

NOTE: in a metal rod, where the area does not vary with length, the ``cos`` terms drop and a heat diffusion can be modelled with just
```math
\mathcal{T} \approx D \frac{\partial^2 T}{\partial x^2}
```
"""

# ╔═╡ 0d8fffdc-a9f5-4d82-84ec-0f27acc04c21
md"""
## Let's code it up!

Our governing system of equation is now a system of PDE, so we have to solve the ϕ-direction as well at the time.

```math
\begin{align}
C_a \frac{\partial T_a}{\partial t} & = \sigma T_s^4 - 2\varepsilon \sigma T_a^4 + \frac{\kappa}{\cos{\phi}} \frac{\partial}{\partial \phi} \left(\cos{\phi}  \frac{\partial T_a}{\partial \phi} \right)\\
C_s \frac{\partial T_s}{\partial t} & = - \sigma T_s^4 + \varepsilon \sigma T_a^4 + (1 - \alpha) Q + \frac{\kappa}{\cos{\phi}} \frac{\partial}{\partial \phi} \left(\cos{\phi}  \frac{\partial T_s}{\partial \phi} \right)
\end{align}
```

We need to define a ``\Delta x`` (or ``\Delta \phi`` in our case) and we can discretize a spatial derivative in the same way as the time-derivative
```math
\left[\frac{1}{\cos{\phi}} \frac{\partial}{\partial \phi} \left(\cos{\phi}  \frac{\partial T}{\partial \phi} \right) \right]_j \approx \frac{1}{\cos{\phi_j} \Delta \phi} \left(\left[ \cos{\phi} \frac{\partial T}{\partial \phi} \right]_{j+1/2} - \left[ \cos{\phi} \frac{\partial T}{\partial \phi} \right]_{j-1/2} \right)
```
In the same way we can approximate the first derivative on interfaces as
```math
\left[\cos{\phi}\frac{\partial T}{\partial \phi} \right]_{j+1/2} \approx \cos{\phi_{j+1/2}}\frac{T_{j+1} - T_{j}}{\Delta \phi}
```
The additional tendency term caused by heat transport becomes:
```math
G_\kappa = \frac{\kappa}{\cos{\phi_j}\Delta \phi} \left(\cos{\phi_{j+1/2}} \frac{T_{j+1} - T_j}{\Delta \phi} - \cos{\phi_{j-1/2}} \frac{T_{j} - T_{j-1}}{\Delta \phi} \right)
```
"""


# ╔═╡ 930935f8-832a-45b4-8e5e-b194afa917c6
# begin 	
# 	struct DiffusiveModel{S, T, K, E, A, F, C, ΦF, ΦC}
# 		stepper :: S
# 		Tₛ :: T # surface temperature
# 		Tₐ :: T # atmospheric temperature
# 		κₛ :: K # surface diffusivity
# 		κₐ :: K # atmospheric diffusivity
# 		ε  :: E # atmospheric emissivity
# 		α  :: A # surface albedo
# 		Q  :: F # forcing
# 		Cₛ :: C # surface heat capacity
# 		Cₐ :: C # atmospheric heat capacity
# 		ϕᶠ :: ΦF # the latitudinal grid at interface points
# 		ϕᶜ :: ΦC # the latitudinal grid at center points
# 	end

# 	const ExplicitDiffusiveModel   = DiffusiveModel{<:ExplicitTimeStep}
# 	const ImplicitDiffusiveModel   = DiffusiveModel{<:ImplicitTimeStep}

# 	timestepping(model::ExplicitDiffusiveModel) = "Explicit"
# 	timestepping(model::ImplicitDiffusiveModel) = "Implicit"

# 	# We define a constructor for the DiffusiveModel
# 	function DiffusiveModel(step, N; κ = 0.55, κₛ = κ, ε = 0.5, α = 0.2985, Q = 341.3)
# 		Cₛ = 1000.0 * 4182.0 * 100 / (3600 * 24) # ρ * c * H / seconds_per_day
# 		Cₐ = 1e5 / 10 * 1000 / (3600 * 24) 		 # Δp / g * c / seconds_per_day
# 		ϕᶠ = range(-π/2, π/2, length=N+1)
# 		ϕᶜ = 0.5 .* (ϕᶠ[2:end] .+ ϕᶠ[1:end-1])
# 		Tₛ = 288.0 * ones(N)
# 		Tₐ = 288.0 * ones(N)
# 		return DiffusiveModel(step, Tₛ, Tₐ, κₛ, κ, ε, α, Q, Cₛ, Cₐ, ϕᶠ, ϕᶜ)
# 	end

# 	# A pretty show method that displays the model's parameters
# 	function Base.show(io::IO, model::DiffusiveModel)
# 		print(io, "One-D energy budget model with:", '\n',
# 		"├── time stepping: $(timestepping(model))", '\n',
#     	"├── ε: $(emissivity(model))", '\n',
#         "├── α: $(albedo(model))", '\n',
#         "├── κ: $(model.κₛ)", '\n',
#         "└── Q: $(model.Q) Wm⁻²")
# 	end

# 	# We define, again, the emissivities and albedo as function of the model
# 	emissivity(model::DiffusiveModel) = model.ε
# 	emissivity(model::DiffusiveModel{<:Any, <:Any, <:Any, <:Function}) = model.ε(model)

# 	albedo(model::DiffusiveModel) = model.α
# 	albedo(model::DiffusiveModel{<:Any, <:Any, <:Any, <:Any, <:Function}) = model.α(model)
# end

# ╔═╡ abdbbcaa-3a76-4a47-824d-6da73bc71c31
# test_1D_model = DiffusiveModel(ImplicitTimeStep(), 90)

# ╔═╡ 1cef338d-5c4a-4ea5-98d7-9ac4f11922f3
md"""
### Coding explicit time stepping with diffusion

Coding the explicit time stepping won't be too different than what we did with the ODE. \ 
We define the tendencies and add the explicit diffusion term calculated as above. \
This time we need boundary conditions for our PDE. 

We assume that there are no fluxes over the poles.
```math
F^+(90^\circ) = F^-(-90^\circ) = 0
```

"""

# ╔═╡ 71cff056-a36c-4fd4-babb-53018894ac5c
# begin
# 	function explicit_diffusion(T, Δϕ, ϕᶠ, ϕᶜ)
# 		# Calculate the flux at the interfaces
# 		Flux = cos.(ϕᶠ[2:end-1]) .* (T[2:end] .- T[1:end-1]) ./ Δϕ
# 		# add boundary conditions
# 		# We impose 0-flux boundary conditions
# 		Flux = [0.0, Flux..., 0.0]
# 		return 1 ./ cos.(ϕᶜ) .* (Flux[2:end] .- Flux[1:end-1]) ./ Δϕ
# 	end
	
# 	function tendencies(model)
# 		Tₛ = model.Tₛ
# 		Tₐ = model.Tₐ
# 		α  = albedo(model)
# 		ε  = emissivity(model)

# 		Δϕ = model.ϕᶠ[2] - model.ϕᶠ[1]
# 		Dₛ = model.κₛ .* explicit_diffusion(model.Tₛ, Δϕ, model.ϕᶠ, model.ϕᶜ)
# 		Dₐ = model.κₐ .* explicit_diffusion(model.Tₐ, Δϕ, model.ϕᶠ, model.ϕᶜ)

# 		Gₛ = @. (1 - α) * model.Q + σ * (ε * Tₐ^4 - Tₛ^4) + Dₛ
# 		Gₐ = @. σ * ε * (Tₛ^4 - 2 * Tₐ^4) + Dₐ
# 		return Gₛ, Gₐ
# 	end

# 	function time_step!(model::ExplicitDiffusiveModel, Δt)

# 		Gₛ, Gₐ = tendencies(model)
	
# 		model.Tₛ .+= Δt * Gₛ / model.Cₛ
# 		model.Tₐ .+= Δt * Gₐ / model.Cₐ
# 	end
# end

# ╔═╡ 83be4f9d-6c85-4e5b-9379-00618c9e39be
md"""
### Coding implicit time stepping with diffusion

to code an implicit time stepping method, we can reutilize the matrix we used before (the sources and interexchange terms do not change)
There are new terms to be added:

```math
G_\kappa^{(n+1)} = \frac{\kappa}{\cos{\phi_j}\Delta \phi} \left(\cos{\phi_{j+1/2}} \frac{T_{j+1}^{(n+1)} - T_j^{(n+1)}}{\Delta \phi} - \cos{\phi_{j-1/2}} \frac{T_{j}^{(n+1)} - T_{j-1}^{(n+1)}}{\Delta \phi} \right)
```
we can rearrange it as
```math
G_\kappa^{(n+1)} = \kappa\frac{\cos{\phi_{j-1/2}}}{\cos{\phi_j}\Delta\phi^2}  T_{j-1}^{(n+1)} + \kappa\frac{\cos{\phi_{j+1/2}}}{\cos{\phi_j}\Delta\phi^2}  T_{j+1}^{(n+1)} - \kappa\frac{\cos{\phi_{j+1/2}} + \cos{\phi_{j-1/2}}}{\cos{\phi_j}\Delta\phi^2} T_j^{(n+1)}
```
```math
G_\kappa^{(n+1)} = a T_{j-1}^{(n+1)} + c T_{j+1}^{(n+1)} - (a+c) T_j^{(n+1)}
```
where 
```math
a = \kappa\frac{\cos{\phi_{j-1/2}}}{\cos{\phi_j}\Delta\phi^2} \ \ \ \text{and} \ \ \ c = \kappa\frac{\cos{\phi_{j+1/2}}}{\cos{\phi_j}\Delta\phi^2}
```
we have to add ``(a+c)`` to the diagonal, ``a`` to the diagonal at position ``-1`` and ``c`` to the diagonal at position ``+1``

**_Adding boundary conditions_** \
at ``j = 1/2`` we impose a no flux boundary condition. This implies that
```math
F_{1/2} = 0 \Rightarrow T_0 = T_1
```
then ``G_{\kappa}^{(n+1)}`` at 1 simplifies to
```math
\left[G_\kappa^{(n+1)}\right]_1 = c T_{2}^{(n+1)} - c T_1^{(n+1)}
```
Simply put, we avoid adding ``a`` to the first row. The same happens for ``G_{\kappa}^{(n+1)}`` at ``m`` (with ``m`` the length of ``\phi``) where, assuming that ``F_{m+1/2} = 0`` implies that
```math
\left[G_\kappa^{(n+1)}\right]_m = a T_{m-1}^{(n+1)} - a T_m^{(n+1)}
```
"""

# ╔═╡ 7c7439f0-d678-4b68-a5e5-bee650fa17e2
# function construct_diffusion_matrix(model, Δt)

# 	A = construct_matrix(model, Δt)
	
# 	cosϕᶜ = cos.(model.ϕᶜ)
# 	Δϕ = model.ϕᶠ[2] - model.ϕᶠ[1]

# 	a = @. 1 / Δϕ^2 / cosϕᶜ * cos(model.ϕᶠ[1:end-1])
# 	c = @. 1 / Δϕ^2 / cosϕᶜ * cos(model.ϕᶠ[2:end])

# 	m = length(model.Tₛ)
#     for i in 1:m
# 		# Adding the off-diagonal entries corresponding to Tⱼ₊₁ (exclude the last row)
#         if i < m
#             A[i  , i+1]   = - Δt * model.κₐ * c[i]
#             A[i+m, i+1+m] = - Δt * model.κₛ * c[i]
# 		end
# 		# Adding the off-diagonal entries corresponding to Tⱼ₋₁ (exclude the first row)
#         if i > 1 
#             A[i,   i-1]   = - Δt * model.κₐ * a[i]
#             A[i+m, i-1+m] = - Δt * model.κₛ * a[i]
#         end
# 		# Adding the diagonal entries
#         A[i  , i]   += Δt * model.κₐ * (a[i] + c[i])
#         A[i+m, i+m] += Δt * model.κₛ * (a[i] + c[i])
#     end
	
# 	return A
# end

# ╔═╡ 57dde8ad-f7de-4ca6-bfab-235bc13131c0
md"""
Last thing to do is calculate the rhs and solve the linear system
"""

# ╔═╡ 9a5ac384-f5e6-41b0-8bc4-44e2ed6be472
# function time_step!(model::ImplicitDiffusiveModel, Δt)
	
# 	A = construct_diffusion_matrix(model, Δt)
# 	α = albedo(model)

# 	rhsₐ = model.Cₐ .* model.Tₐ
# 	rhsₛ = model.Cₛ .* model.Tₛ .+ Δt .* (1 .- α) .* model.Q
	
# 	rhs = [rhsₐ..., rhsₛ...]

# 	T = A \ rhs

# 	nₐ = length(model.Tₐ)
# 	nₛ = length(model.Tₛ)

# 	model.Tₐ .= T[1:nₐ]
# 	model.Tₛ .= T[nₐ+1:nₐ+nₛ]
# end

# ╔═╡ d1a741ad-f28d-48c7-9f15-d55d0801573d
md"""
# Temperature distribution with diffusion
"""

# ╔═╡ a046b625-b046-4ca0-adde-be5249a420f4
md""" κ $(@bind κ_slider PlutoUI.Slider(0:0.01:1, show_value=true)) """

# ╔═╡ 514ee86b-0aeb-42cd-b4cd-a795ed23b3de
# begin
# 	F = annual_mean_insolation.(ϕ)

# 	model_1D = DiffusiveModel(ImplicitTimeStep(), length(F); κ = κ_slider, ε = varε, α = varα, Q = F)
	
# 	evolve_model!(model_1D, Δt = 1, stop_year = 50)
	
# 	DTκ0 = feedback_model.Tₛ[45] - feedback_model.Tₛ[end]
# 	DTκ1 = model_1D.Tₛ[45] - model_1D.Tₛ[end]
# 	DTob = T_obs[45] - T_obs[end-6]

# 	title = @sprintf("T(0ᵒ) - T(90ᵒ): %.2f (κ = 0), %.2f (κ = %.2f), %.2f (obs)", 
# 					 DTκ0, DTκ1, κ_slider, DTob)
	
# 	plot_latitudinal_variables!(ϕ, [feedback_model.Tₛ .- 273, 
# 									model_1D.Tₛ .- 273,
# 									T_obs .- 273], 
# 									["model with κ = 0",
# 									 "model with κ = $κ_slider",
# 									 "observed T"], 
# 									[:blue, :blue, :black], 
# 									[:dash, :solid, :dashdot];
# 									ylims = (-70, 70), title)
	
# 	current_figure()	
# end

# ╔═╡ c98fcf26-d715-47c2-84ac-63bffe02d813
md"""
Is this a sensible conductivity value? Heat transport is caused by atmospheric circulation, so what is a plausible value of the diffusivity caused by atmospheric motion? If we take into account the velocity of a typical atmospheric eddy ``V``, the order of magnitude of the flux is ``V \cdot T`` (where ``T`` is a temperature scale). We parameterize this with a term that looks like ``K \cdot T / L`` where ``K`` is our diffusivity expressed in m²/s and ``L`` is a typical length scale of movement in the atmosphere. Then it should hold that
```math
K \cdot\frac{T}{L} \sim V \cdot T 
```
If we fill in typical values for atmospheric velocity and length scales (about ``20`` m/s and ``2000`` km) we get that
```math
K \sim V\cdot L \sim 10^7 \ \ \text{m}^2/s
```
This diffusivity corresponds to a conductivity ``\kappa`` (in W/m²K) of
```math
\kappa \sim \frac{K C_a}{2\pi R^2} \approx 0.45 \ \ \text{W}/\text{m}^2\text{K}
```
"""

# ╔═╡ 6534f98d-1270-4e7c-8ce8-66a6b1ee48f7
# begin	
# 	HF(model) = model.κₛ .* explicit_diffusion(model.Tₛ, deg2rad(2), model.ϕᶠ, model.ϕᶜ) 

# 	plot_latitudinal_variables!(ϕ, [ASR(model_1D), 
# 									OLR(model_1D), 
# 									HF(model_1D)], 
# 									["ASR", "OLR", "transport"], 
# 									[:red, :blue, :green], 
# 									[:solid, :dash, :solid, :dash, :solid],
# 									ylabel = "Energy Budget Wm⁻²",
# 									leg_pos = :cc)
# 	md"""
# 	$(current_figure())
# 	**Figure**: Energy budget for a climate with transport.
# 	"""
# end

# ╔═╡ 77a73a9d-9d78-4cf5-ae19-f1107fa5b4c2
begin
	md"""
	
	Heat flux can only redistribute energy. It is then important to check that our solution method does not create or destroy energy.
	Let's compute the integral of the transport term in latitude
	```math
	\int_{-90^o}^{90^o} \mathcal{T} \cos{\phi} d\phi \approx \sum_{j = 1}^N \mathcal{T}_j \cos{\phi_j} \cdot (\phi_{j+1/2} - \phi_{j-1/2}) 
	```
	This is a good sanity check to make sure that our model is doing what is intended
	"""
end

# ╔═╡ 80c72898-139e-44af-bab0-ca638f282188
# sum(HF(model_1D) .* cos.(model_1D.ϕᶜ) .* (model_1D.ϕᶠ[2:end] .- model_1D.ϕᶠ[1:end-1]))

# ╔═╡ b0ca64b8-0211-4d1c-b007-7583bf8ac908
md"""
## Stability of a diffusive model

Let's, once again, reduce the two equations to a more simple, 1D partial differential equation, which only has a diffusion term. You can imagine that greenhouse gases are immediately removed from the atmosphere. As a result, the atmosphere stops absorbing heat from the surface and emitting it in space. The remaining heat then will only redistribute via transport along the atmosphere. (we also simplify the earth to be "flat", i.e., no cosines)

```math
\frac{\partial T}{\partial t} = K \frac{\partial^2 T}{\partial x^2}
```
where ``K`` is the diffusivity in m²/s
```math
\frac{T^{(n+1)}_j - T^{(n)}_j}{\Delta t} = K \frac{T^{(n)}_{j+1} - 2T^{(n)}_j+ T^{(n)}_j}{\Delta x^2}
```

Imagine the initial temperature profile can be approximated by a spatial wave of wavenumber ``k``, i.e,
```math
T^{(n)}_j = \xi^{(n)}e^{ikx_j} \ , \ \ \ \ \text{where} \ \ \ \ x_j = j\Delta x
```

Let's substitute in the following equation and divide by ``\xi^{(n)}e^{ikj\Delta x}``
```math
\left( \frac{\xi^{(n+1)}}{\xi^{(n)}} - 1\right) = K\Delta t \frac{e^{ik \Delta x} - 2 + e^{- ik \Delta x}}{\Delta x^2}
```

we can use ``e^{i\theta} + e^{-i\theta} = 2\cos{\theta}`` and we get
```math
\frac{\xi^{(n+1)}}{\xi^{(n)}} = 1 +\frac{K \Delta t}{\Delta x^2} \underbrace{\left( 2\cos{k\Delta x} - 2\right)}_{\text{between \ } -4 \text{ \ and \ } 0}
```

The worst-case scenario occurs for wavenumbers ``k`` which give 
```math
\frac{\xi^{(n+1)}}{\xi^{(n)}} = 1 - 4\frac{K \Delta t}{\Delta x^2} 
```
again, we want the amplitude to remain positively correlated (otherwise it means that heat transfers from cold to hot temperatures), so we must ensure that 
```math
\Delta t < \frac{\Delta x^2}{4K}
```
In the previous case, we had that at temperatures which were reasonable for the atmosphere, the limitation was in the tenth of days... \
We already saw that a reasonable diffusivity (in m²/s) for the atmosphere is 
```math
K \approx 10^7 \ \ \text{m}^2/\text{s}
```
If we have a model with a two-degree resolution (90 points), then ``\Delta x = R \Delta \phi \approx 200`` km, which means that the condition on the time step is
```math
\Delta t < \frac{(2\cdot 10^{5})^2}{4 \cdot 10^7}  = 1000 s
```
We introduced another limitation in our explicit time stepping. The time step is connected with the spatial resolution of our model. This limitation is called CFL condition (Courant–Friedrichs–Lewy condition) and ensures that the temperature does not move more than one spatial grid cell in one-time step. 

**do it by yourself** \
Demonstrate that implicit time stepping does not have the same limitations
"""

# ╔═╡ 51f3fd00-508b-4b42-bd95-ae19cb19b4db
md"""
## Ice-albedo feedback and the Snowball earth

The albedo of Earth's surface varies from about 0.1 for the oceans to 0.6–0.9 for ice and clouds — meaning that clouds, snow, and ice are good radiation reflectors while liquid water is not. 
We can build this process in our model by imagining the earth covered by ice when we lower the temperature below a certain threshold ``T_{ice}``

```math
\alpha(\phi, T) = \begin{cases} \alpha(\phi) & \ \ \text{if} \ \ T > T_{ice} \\ \alpha_{ice} &  \ \ \text{if} \ \ T \le T_{ice} \end{cases} 
```
where ``\alpha(\phi)`` is our previously defined array `varα`, ``T_{ice} = -10`` ``^\circ``C and ``\alpha_{ice} = 0.7``
"""

# ╔═╡ 65dedef2-03e5-4e0f-8022-53168952e7a8
# begin 	
# 	α_feedback(T, α) = T > 273.15 - 10.0 ? α : 0.7
# 	κ = 0.5
# 	α_model(model) = α_feedback.(model.Tₛ, varα)

# 	current_climate_model = DiffusiveModel(ImplicitTimeStep(), length(F); κ = 0.5, ε = varε, α = α_model, Q = F)

# 	current_climate_model.Tₛ .= model_1D.Tₛ
# 	current_climate_model.Tₐ .= model_1D.Tₐ

# 	evolve_model!(current_climate_model, Δt = 50, stop_year = 150)
# 	plot_latitudinal_variables!(ϕ, [feedback_model.Tₛ .- 273, 
# 									model_1D.Tₛ .- 273,
# 									current_climate_model.Tₛ .- 273,
# 									T_obs .- 273], 
# 									["model with κ = 0",
# 									 "model with κ = $κ_slider",
# 									 "model with α feedback",
# 									 "observed T"], 
# 									[:blue, :blue, :red, :black], 
# 									[:dash, :solid, :solid, :dashdot];
# 									ylims = (-70, 70))


# 	current_figure()
# end

# ╔═╡ 8afe64e3-d19a-4801-b7b8-56d886f7a59a
# plot_latitudinal_variables!(ϕ, [ASR(current_climate_model), 
# 								OLR(current_climate_model), 
# 								HF(current_climate_model)], 
# 								["ASR", "OLR", "transport"], 
# 								[:red, :blue, :green], 
# 								[:solid, :solid, :solid],
# 								ylabel = "Energy Budget Wm⁻²",
# 								leg_pos = :cc)

# ╔═╡ ebcf224f-c006-4098-abf0-5c3644e2ee97
md"""
There will be a latitude where ``T_{\phi} = T_{ice}`` above which the earth will be covered in ice. We call this latitude ice line.
Let's define an **ice_line** function that retreives this latitude
"""

# ╔═╡ 73238f6c-b8d3-4f92-bdfe-1c657e239903
# function ice_line(model)
# 	idx = searchsortedlast(model.Tₛ, 273.15 - 10)

# 	return idx == 0 ? 90.0 : idx > length(model.ϕᶜ) ? 0.0 :  - rad2deg(model.ϕᶜ[idx])
# end

# ╔═╡ 247b4c3a-2777-47ed-8cc9-e90a5cdb640b
# "the ice line of our model is at $(ice_line(current_climate_model)) ᵒN"

# ╔═╡ 0353c906-55d9-4419-a55d-8fcd374004d7
# begin
# 	function calc_different_climates(initial_condition_model; forcing)
# 		ice_line_model = zeros(length(forcing))
# 		for (idx, S₀) in enumerate(forcing)
# 			F₂ = annual_mean_insolation.(ϕ; S₀)
# 			model_tmp = DiffusiveModel(ImplicitTimeStep(), length(F₂); κ, ε = varε, α = α_model, Q = F₂)
	
# 			model_tmp.Tₛ .= initial_condition_model.Tₛ
# 			model_tmp.Tₐ .= initial_condition_model.Tₐ
	
# 			evolve_model!(model_tmp, Δt = 100, stop_year = 100)
	
# 			ice_line_model[idx] = ice_line(model_tmp)
# 		end
# 		return ice_line_model
# 	end
# end

# ╔═╡ 1c33dc21-04af-4139-9061-696db73c3249
# begin 
# 	S₀₁ = range(1200.0, 1450, length = 25)
# 	ice_line_current = calc_different_climates(current_climate_model, forcing = S₀₁)

# 	figure_ice = Figure(resolution = (500, 300))
	
# 	ax_ice = Axis(figure_ice[1, 1], title = "ice line", ylabel = "ϕ [ᵒN]", xlabel = "forcing S₀ [W/m²]")
# 	lines!(ax_ice, S₀₁, ice_line_current, label = "initial condition: current climate")
# 	current_figure()
# end

# ╔═╡ 70713834-3246-45a4-a4c8-68513bb853ce
md"""
Let's start from another initial condition

"""

# ╔═╡ 2b33a8a1-3772-4fb3-a914-a20a7aae91bc
# begin
# 	low_F = annual_mean_insolation.(ϕ; S₀ = S₀₁[1])
# 	cold_climate_model = DiffusiveModel(ImplicitTimeStep(), length(low_F); κ, ε = varε, α = α_model, Q = low_F)
# 	evolve_model!(cold_climate_model, Δt = 100, stop_year = 100)

# 	new_current_climate_model = DiffusiveModel(ImplicitTimeStep(), length(low_F); κ, ε = varε, α = α_model, Q = F)
# 	new_current_climate_model.Tₛ .= cold_climate_model.Tₛ
# 	new_current_climate_model.Tₐ .= cold_climate_model.Tₐ
	
# 	evolve_model!(new_current_climate_model, Δt = 100, stop_year = 1000)

	
# 	plot_latitudinal_variables!(ϕ, [current_climate_model.Tₛ .- 273,
# 									cold_climate_model.Tₛ .- 273, 
# 									new_current_climate_model.Tₛ .- 273], 
# 									["current climate",
# 									 "cold climate (S₀ = 1200)",
# 									 "current climate, different initial conditions"], 
# 									[:blue, :blue, :red, :black], 
# 									[:dash, :solid, :solid, :dashdot];
# 									ylims = (-100, 70))
# end

# ╔═╡ b768707a-5077-4662-bcd1-6d38b3e4f929
html"""
        <style>
                main {
                        margin: 0 auto;
                        max-width: 2000px;
                padding-left: max(320px, 10%);
                padding-right: max(320px, 10%);
                }
        </style>
        """


# ╔═╡ 419c8c31-6408-489a-a50e-af712cf20b7e
TableOfContents(title="📚 Table of Contents", indent=true, depth=4, aside=true)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
DataDeps = "124859b0-ceae-595e-8997-d05f6a7a8dfe"
JLD2 = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Optim = "429524aa-4258-5aef-a3af-852621145aeb"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[compat]
CairoMakie = "~0.8.13"
DataDeps = "~0.7.10"
JLD2 = "~0.4.23"
Optim = "~1.7.3"
PlutoUI = "~0.7.40"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "c8c9f931ec61b36fd507e482034d6aa1f2bc84c3"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "5c0b629df8a5566a06f5fef5100b53ea56e465a0"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.2"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterfaceCore]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "5bb0f8292405a516880a3809954cb832ae7a31c5"
uuid = "30b0a656-2188-435a-8636-2ec0e6a096e2"
version = "0.1.20"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "84259bb6172806304b9101094a7cc4bc6f56dbc6"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.5"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA"]
git-tree-sha1 = "387e0102f240244102814cf73fe9fbbad82b9e9e"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.8.13"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "dc4405cee4b2fe9e1108caec2d760b7ea758eca2"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.5"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "5856d3031cdb1f3b2b6340dfdc66b6d9a149a374"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.2.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "fb21ddd70a051d882a1686a5a550990bbe371a95"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.4.1"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataDeps]]
deps = ["HTTP", "Libdl", "Reexport", "SHA", "p7zip_jll"]
git-tree-sha1 = "bc0a264d3e7b3eeb0b6fc9f6481f970697f29805"
uuid = "124859b0-ceae-595e-8997-d05f6a7a8dfe"
version = "0.7.10"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "992a23afdb109d0d2f8802a30cf5ae4b1fe7ea68"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.11.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "34a557ce10eb2d9142f4ef60726b4f17c1c30941"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.73"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "5158c2b41018c5f7eb1470d558127ac274eca0c9"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.Extents]]
git-tree-sha1 = "5e1e4c53fa39afe63a7d356e30452249365fba99"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.1"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "90630efff0894f8142308e334473eba54c433549"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.5.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "94f5101b96d2d968ace56f7f2db19d0a5f592e28"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.15.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "87519eb762f85534445f5cda35be12e32759ee14"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.4"

[[deps.FiniteDiff]]
deps = ["ArrayInterfaceCore", "LinearAlgebra", "Requires", "Setfield", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "5a2cff9b6b77b33b89f3d97a4d367747adce647e"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.15.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "187198a4ed8ccd7b5d99c41b69c679269ea2b2d4"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.32"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics"]
git-tree-sha1 = "b5c7fe9cea653443736d264b85466bad8c574f4a"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.9"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "fb28b5dc239d0174d7297310ef7b84a11804dfab"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.0.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "12a584db96f1d460421d5fb8860822971cdb8455"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.4"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "53c7e69a6ffeb26bd594f5a1421b889e7219eeaa"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.9.0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "4abede886fcba15cd5fd041fef776b230d004cee"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.4.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "342f789fd041a55166764c351da1710db97ce0e0"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.6"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "f67b55b6447d36733596aea445a9f119e83498b6"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.5"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "076bb0da51a8c8d1229936a1af7bdfacd65037e1"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.2"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "b3364212fb5d870f724876ffcd34dd8ec6d98918"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.7"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLD2]]
deps = ["FileIO", "MacroTools", "Mmap", "OrderedCollections", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "6c38bbe47948f74d63434abed68bdfc8d2c46b99"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.23"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "a77b273f1ddec645d1b7c4fd5fb98c8f90ad10a5"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.1"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "9816b296736292a80b9a3200eb7fbb57aaa3917a"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.5"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "7bbea35cec17305fc70a0e5b4641477dc0789d9d"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.2.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "5d4d2d9904227b8bd66386c1138cf4d5ffa826bf"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.9"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "41d162ae9c868218b1f3fe78cba878aa348c2d26"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.1.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Makie]]
deps = ["Animations", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "RelocatableFolders", "Serialization", "Showoff", "SignedDistanceFields", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "UnicodeFun"]
git-tree-sha1 = "b0323393a7190c9bf5b03af442fc115756df8e59"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.17.13"

[[deps.MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "fbf705d2bdea8fc93f1ae8ca2965d8e03d4ca98c"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.4.0"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Match]]
git-tree-sha1 = "1d9bc5c1a6e7ee24effb93f175c9342f9154d97f"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.2.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "Test"]
git-tree-sha1 = "114ef48a73aea632b8aebcb84f796afcc510ac7c"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.4.3"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "6872f9594ff273da6d13c7c1a1545d5a8c7d0c1c"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.6"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "50310f934e55e5ca3912fb941dec199b49ca9b68"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.2"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "dfd8d34871bc3ad08cd16026c1828e271d554db9"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.1"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "1ea784113a6aa054c5ebd95945fa5e52c2f378e7"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.7"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "02be9f845cb58c2d6029a6d5f67f4e0af3237814"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.1.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e60321e3f2616584ff98f0a4f18d98ae6f89bbb3"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.17+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Optim]]
deps = ["Compat", "FillArrays", "ForwardDiff", "LineSearches", "LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "b9fe76d1a39807fdcf790b991981a922de0c3050"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.7.3"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "e925a64b8585aa9f4e3047b8d2cdc3f0e79fd4e4"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.16"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "1155f6f937fa2b94104162f01fa400e192e4272f"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.4.2"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a121dfbba67c94a5bec9dde613c3d0cbcf3a12b"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.3+0"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "3d5bf43e3e8b412656404ed9466f1dcbf7c50269"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "a602d7b0babfca89005da04d89223b867b55319f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.40"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "3c009334f45dfd546a16a57960a821a1a023d241"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.5.0"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "22c5201127d7b243b9ee1de3b43c408879dff60f"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.3.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
git-tree-sha1 = "7dbc15af7ed5f751a82bf3ed37757adf76c32402"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.4.1"

[[deps.ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "2436b15f376005e8790e318329560dcc67188e84"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.3"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "8fb59825be681d451c246a795117f317ecbcaa28"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.2"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "efa8acd030667776248eabb054b1836ac81d92f0"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.7"

[[deps.StaticArraysCore]]
git-tree-sha1 = "ec2bd695e905a3c755b33026954b119ea17f2d22"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.3.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArraysCore", "Tables"]
git-tree-sha1 = "8c6ac65ec9ab781af05b08ff305ddc727c25f680"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.12"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "7149a60b01bf58787a1b83dad93f90d4b9afbe5d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.8.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "70e6d2da9210371c927176cb7a56d41ef1260db7"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.1"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"
"""

# ╔═╡ Cell order:
# ╟─d8e3d937-bcda-4c84-b543-e1324f696bbc
# ╟─8ef88534-dac4-4a62-b623-dcaf63482a96
# ╟─cfb8f979-37ca-40ab-8d3c-0053911717e7
# ╟─eb95e773-b12a-40a4-a4f1-9dced86fc8a2
# ╟─75cacd05-c9f8-44ba-a0ce-8cde93fc8b85
# ╠═18ddf155-f9bc-4e5b-97dc-762fa83c9931
# ╟─87fdc7c2-536e-4aa1-9f68-8aec4bc7069d
# ╟─8d4d8b93-ebfe-41ff-8b9e-f8931a9e83c2
# ╟─25223f7b-22f7-46c2-9270-4430eb6c186e
# ╟─034fc483-b188-4b2a-891a-61b76c74072d
# ╠═039ec632-d238-4e63-81fc-a3225ccd2aee
# ╟─5d31e2a8-e357-4479-bc48-de1a1b8bc4d4
# ╟─724901e9-a19a-4d5f-aa6a-79ec0f230f24
# ╠═1431b11f-7838-41da-92e3-bcca9f4215b3
# ╠═de5d415f-8216-473d-8e0b-a73139540e1e
# ╟─15dee5d8-e995-4e5a-aceb-48bcce42e76d
# ╠═a93c36c9-b687-44b9-b0b6-5fe636ab061c
# ╟─2287bff1-6fb0-4431-8e15-aff3d7b6e005
# ╠═c0ff6c61-c4be-462b-a91c-0ee1395ef584
# ╟─e24e54a7-804e-40e8-818e-8766e5e3732b
# ╠═97e1ce89-f796-4bd1-8e82-94fc838829a6
# ╟─049e2164-24ac-467c-9d96-77510ac6ff57
# ╠═f07006ac-c773-4829-9a38-6f9991403386
# ╟─b85fdf41-ef8f-4314-bc3c-383947b9f02c
# ╠═00776863-2260-48a8-83c1-3f2696f11d96
# ╟─16ca594c-c9db-4528-aa65-bab12cb6e22a
# ╟─ea517bbf-eb14-4d72-a4f4-9bb823e02f88
# ╟─b65e2af0-9a08-4915-834b-1a20b2440891
# ╠═dfde2f6a-f612-4013-8d42-5590221167c9
# ╠═91dec8b7-a9da-4c62-973e-2fd8e0a92e58
# ╟─140bcdac-4145-47b3-952f-bfe50f6ed41c
# ╟─849775fa-4990-47d3-afe0-d0a049bb90af
# ╠═4d517df8-0496-40a2-8e44-5beda6cd7226
# ╟─6932b969-0760-4f09-935a-478ac56de262
# ╠═1d8a69b7-52db-4865-8bf2-712c2b6442f5
# ╟─5884999f-f136-4ae7-8831-cc3a36f50a98
# ╠═f2510e0a-23f2-4a40-a7db-7b59898facfa
# ╠═6ce47d90-d5a2-43c0-ad64-27c13aa0f5db
# ╟─4640a179-3373-4901-ac31-31022e8c7eb2
# ╟─d13c319d-345a-40b8-b90d-b0b226225434
# ╟─8f21fc70-e369-4938-b0c2-5a4fbae71713
# ╟─901548f8-a6c9-48f8-9c8f-887500081316
# ╟─567fa8d3-35b4-40d7-8404-ae78d2874380
# ╟─0d8fffdc-a9f5-4d82-84ec-0f27acc04c21
# ╠═930935f8-832a-45b4-8e5e-b194afa917c6
# ╠═abdbbcaa-3a76-4a47-824d-6da73bc71c31
# ╟─1cef338d-5c4a-4ea5-98d7-9ac4f11922f3
# ╠═71cff056-a36c-4fd4-babb-53018894ac5c
# ╟─83be4f9d-6c85-4e5b-9379-00618c9e39be
# ╠═7c7439f0-d678-4b68-a5e5-bee650fa17e2
# ╟─57dde8ad-f7de-4ca6-bfab-235bc13131c0
# ╠═9a5ac384-f5e6-41b0-8bc4-44e2ed6be472
# ╟─d1a741ad-f28d-48c7-9f15-d55d0801573d
# ╟─a046b625-b046-4ca0-adde-be5249a420f4
# ╠═514ee86b-0aeb-42cd-b4cd-a795ed23b3de
# ╟─c98fcf26-d715-47c2-84ac-63bffe02d813
# ╠═6534f98d-1270-4e7c-8ce8-66a6b1ee48f7
# ╟─77a73a9d-9d78-4cf5-ae19-f1107fa5b4c2
# ╠═80c72898-139e-44af-bab0-ca638f282188
# ╟─b0ca64b8-0211-4d1c-b007-7583bf8ac908
# ╟─51f3fd00-508b-4b42-bd95-ae19cb19b4db
# ╠═65dedef2-03e5-4e0f-8022-53168952e7a8
# ╠═8afe64e3-d19a-4801-b7b8-56d886f7a59a
# ╟─ebcf224f-c006-4098-abf0-5c3644e2ee97
# ╠═73238f6c-b8d3-4f92-bdfe-1c657e239903
# ╠═247b4c3a-2777-47ed-8cc9-e90a5cdb640b
# ╠═0353c906-55d9-4419-a55d-8fcd374004d7
# ╠═1c33dc21-04af-4139-9061-696db73c3249
# ╟─70713834-3246-45a4-a4c8-68513bb853ce
# ╠═2b33a8a1-3772-4fb3-a914-a20a7aae91bc
# ╟─b768707a-5077-4662-bcd1-6d38b3e4f929
# ╟─419c8c31-6408-489a-a50e-af712cf20b7e
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
