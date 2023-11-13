### A Pluto.jl notebook ###
# v0.19.31

#> [frontmatter]
#> title = "HW3 - Pokémon"
#> date = "2023-09-28"

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

# ╔═╡ fcafb864-249b-11ed-3b73-774e1742704a
begin
	using BenchmarkTools
	using Colors
	using FileIO
	using ImageIO
	using ImageShow
	using Plots
	using PlutoUI
	using PlutoTeachingTools
end

# ╔═╡ d20423a3-a6d8-4b7a-83c7-f1539fcc4d72
md"""
Release date: Thursday, Sep 28, 2023

**Due date: Thursday, Oct 12, 2023 (11:59pm EST)**

Submission by: Jazzy Doe (jazz@mit.edu)
"""

# ╔═╡ 00992802-9ead-466b-8b01-bcaf0614b0c6
student = (name = "Jazzy Doe", kerberos_id = "jazz")

# ╔═╡ 1896271c-e5bf-428c-bc3e-7780e71a065f
md"""
# Part 1: Pokémon - _gotta dispatch 'em all_
"""

# ╔═╡ eee70c65-94b8-4f3d-a187-bbafb04b8eff
md"""
Show TOC $(@bind show_toc CheckBox(default=true))
"""

# ╔═╡ 9f1c224c-561e-4071-a909-0c951b9e3542
md"""
## 1.1 Implementing Pokémon behavior
"""

# ╔═╡ 6ae05ccb-c386-4139-817c-85959a20a4de
md"""
The goal of this part is to build a simple model of Pokémon behavior.
We will do this by exploiting two key assets of Julia: types and dispatch.

In terms of Julia syntax, we tried to make the following exercises self-contained.
Still, it may be a good idea to check out the language documentation on [types](https://docs.julialang.org/en/v1/manual/types/) and [methods](https://docs.julialang.org/en/v1/manual/methods/) in case you are stuck.
"""

# ╔═╡ d0634f27-ba12-4c53-be66-6d2f7bf74808
md"""
### Pokémon families
"""

# ╔═╡ a5d63fcc-9d84-4912-b6fe-3ddc937b3022
md"""
A major feature of Pokémon games is the type system, which is described [here](https://pokemondb.net/type).
In the following section, we draw inspiration from this [blog post](https://www.moll.dev/projects/effective-multi-dispatch/) to implement Pokémon types using Julia types.
To avoid confusion, we refer to Pokémon types as "families" from now on.
"""

# ╔═╡ 1b8b2a32-21fd-47e0-9c12-7a71e66fab4c
md"""
The first thing we want is an abstract type that encompasses every Pokémon we will create.
"""

# ╔═╡ 321c6dc8-9d87-47da-88b3-a41b55b179ff
abstract type Pokemon end

# ╔═╡ d931270d-1ceb-474f-b04e-0185595a4b5a
md"""
To make things simpler, we only consider the first few Pokémon families, which we define as abstract subtypes of `Pokémon`.
"""

# ╔═╡ 7dbd7cfd-5c52-4591-b6ba-eba7f3076a45
begin
	abstract type Normal <: Pokemon end
	abstract type Fire <: Pokemon end
	abstract type Water <: Pokemon end
	abstract type Grass <: Pokemon end
	abstract type Electric <: Pokemon end
end

# ╔═╡ 72ac44a7-7c18-4d0e-85e4-9ca9cb5173a8
md"""
Finally, we create one iconic Pokémon from each of these types.
This empty `struct` definition means that the structures we define have no attributes.
"""

# ╔═╡ 74a44465-7332-45b0-91c4-2ae5ed658160
begin
	struct Snorlax <: Normal end
	struct Charmander <: Fire end
	struct Squirtle <: Water end
	struct Bulbasaur <: Grass end
	struct Pikachu <: Electric end
end

# ╔═╡ ed8a218f-287c-425b-a6b6-793be7ad1a7b
md"""
Eevee is a very special Pokémon, because it can evolve into members of nearly every family.
"""

# ╔═╡ 037d04d4-f5f2-4b77-80ed-b799c1ea9b77
md"""
!!! danger "Task 1.1"
	Define new structures for Eevee (from the `Normal` family) and its evolutions Flareon, Vaporeon, Leafeon and Jolteon (respectively from the `Fire`, `Water`, `Grass` and `Electric` families).
"""

# ╔═╡ 87081f51-7c44-4365-b412-7b34ed2b3191
begin
	struct Eevee <: Normal end
	struct Flareon <: Fire end
	struct Vaporeon <: Water end
	struct Leafeon <: Grass end
	struct Jolteon <: Electric end
end

# ╔═╡ d4619cdf-f902-4a8e-8e60-b8606aee40d2
md"""
Here are some examples of structure creation and use.
"""

# ╔═╡ 2e9ddef4-688c-4623-8b58-578e7931204b
snorlax = Snorlax()

# ╔═╡ 3a99de95-3312-47f7-b46e-545aa75b82bf
pikachu = Pikachu()

# ╔═╡ 9b143e5c-04b6-4306-87c6-fc818747c20d
vaporeon = Vaporeon()

# ╔═╡ cb4ee69a-c992-45ae-b7a2-0cbc318a090e
snorlax isa Pokemon

# ╔═╡ 9b6b6596-7680-4864-9395-10fbf69ec0ae
pikachu isa Water

# ╔═╡ c137d356-f552-4e3e-92b7-a9ffc0df0266
vaporeon isa Water

# ╔═╡ 9e2898c5-5c90-4fca-8c60-1fc31db81ead
md"""
And here are some automatic checks for your answers.
Note that, depending on the task, they might not catch every possible mistake.
"""

# ╔═╡ 1dbbf479-1707-4dd0-90c8-394690fbac91
md"""
### Interlude: multiple dispatch
"""

# ╔═╡ c4063845-c70a-47ef-a4f7-ef2b3ea0f0d8
md"""
Before going further, we explain and illustrate a key feature of Julia: _multiple dispatch_.
In Julia, a _function_ is just a name, like `+` or `exp`.
Each function may possess several implementations called _methods_.
These methods are where the real magic happens, because adding two integers is very different from adding two floating point numbers or even matrices.
The right method is _dispatched_ "just in time" based on the types of all function arguments (not just the first one).
"""

# ╔═╡ 3d748f13-ef9c-4899-99d3-16743f0e2f5a
md"""
Here is an example inspired by the notebook on [abstraction](https://mit-c25-fall22.netlify.app/notebooks/1_abstraction) that you saw in the first class.
Let's ask Julia which method is chosen for addition, depending on what we try to add.
"""

# ╔═╡ 730ae9dc-34bf-4472-ae32-36fe10c54175
@which true + true  # add booleans

# ╔═╡ d0d2c56e-297d-4d35-afb7-bfd366815a95
@which 1 + 1  # add integers

# ╔═╡ 0eabf795-a9c5-4aa1-8282-e5e22b631c4d
@which 1//1 + 1//1  # add rationals

# ╔═╡ 57e16f0a-c0bc-4727-9315-701328989762
@which 1.0 + 1.0  # add floating point numbers

# ╔═╡ ab71225e-3d0e-4a11-a5de-6b1eea4048eb
@which [1 0; 0 1] + [1 0; 0 1]  # add matrices

# ╔═╡ ecebb7eb-000f-418d-bfb8-acb66b06c171
@which 1 + 1.0  # add elements of different types by promoting them to a common type

# ╔═╡ 7b2dbb37-9523-4150-bf23-4803ef0f31f1
md"""
Since each case has its own custom implementation, which is essential for performance reasons, the number of methods for addition is actually mind-blowing!
"""

# ╔═╡ ad26c7d9-f457-4dc0-8a70-8bac4b3c3a10
length(methods(+))

# ╔═╡ b6ebf9ce-0a8f-4f67-b324-3aa4da967d46
md"""
Whenever several methods are compatible with the argument types, the most specific method wins.
We can use this to our advantage by specifying default behavior for abstract types, and then being more specific when we need to be.
"""

# ╔═╡ d241fcec-3266-4175-abd5-7d26128dc923
md"""
### Attack mechanism
"""

# ╔═╡ 3eb3545e-d48a-41d7-ac31-b9b6d1b22af9
md"""
Here, we assume that the effectiveness of a Pokémon attack is determined only by the respective families of the attacker and defender.
True Pokémon fans will notice that this is an oversimplification.
Good for them.
"""

# ╔═╡ 58aed749-468e-477d-98c7-3a7a0c9ea7a0
begin
	const NOT_VERY_EFFECTIVE = 0.5
	const NORMAL_EFFECTIVE = 1.0
	const SUPER_EFFECTIVE = 2.0
end;

# ╔═╡ 80c63240-d4e8-4a4b-b34c-a14b064a75a5
md"""
Our goal here is to compute the effectiveness values by defining methods for the `attack` function.
And luckily, we can save some work by identifying patterns:
- in most cases, an attack is normally effective
- in most cases, an attack within the same family is not very effective
So let us start there.
"""

# ╔═╡ 9370b300-25a9-4342-803d-c2f1ba0d2b90
attack(att::Pokemon, def::Pokemon) = NORMAL_EFFECTIVE;

# ╔═╡ 595e20f1-150a-4224-aee5-607882486887
md"""
There is a special syntax we can use when both arguments of a function must have the same (super-)type.
"""

# ╔═╡ 136dbf04-77a0-4c14-868d-73a92a9028b5
attack(att::P, def::P) where {P<:Pokemon} = NOT_VERY_EFFECTIVE;

# ╔═╡ 390c7fe7-a27c-4f21-a8dc-c8cf19372857
md"""
Now we add special cases that deviate from these patterns.
"""

# ╔═╡ 5963a5b6-7939-49f5-9f5e-d1984afd8d79
begin
	attack(att::Normal, def::Normal) = NORMAL_EFFECTIVE

	attack(att::Fire, def::Water) = NOT_VERY_EFFECTIVE
	attack(att::Fire, def::Grass) = SUPER_EFFECTIVE
	
	attack(att::Water, def::Fire) = SUPER_EFFECTIVE
	attack(att::Water, def::Grass) = NOT_VERY_EFFECTIVE
	
	attack(att::Electric, def::Water) = SUPER_EFFECTIVE
	attack(att::Electric, def::Grass) = NOT_VERY_EFFECTIVE
	
	attack(att::Grass, def::Fire) = NOT_VERY_EFFECTIVE
	attack(att::Grass, def::Water) = SUPER_EFFECTIVE
end;

# ╔═╡ 520f5b7e-d5dd-4954-93a3-39e63d5d2a1b
md"""
This is a bit tedious, but thanks to the patterns we identified, we only need to handle a few exceptions instead of the full $25$ cases.
"""

# ╔═╡ 581e4013-692a-4a66-b210-b4db92112187
md"""
Now let's see how attacks work.
"""

# ╔═╡ 7b003215-ce5d-4063-9eb0-c05affd1d15e
md"""
## 1.2 Extending Pokémon behavior
"""

# ╔═╡ ffee9abf-d6ed-411e-bef7-15d52c084d3e
md"""
Until now, nothing extraordinary has happened.
You might even think it is simpler to just store the effectiveness values into a matrix and be done with it.
The reason why we use types and dispatch fits in one word: _composability_.

Imagine there is a package called `Pokemon.jl` that contains all of the stuff above.
Let's say that you wish to add your own family of Pokémon, or experiment with a new fight mechanism.
You probably want to extend the existing package, instead of recoding everything from scratch.
This is made very easy by multiple dispatch, because you can do the following:
- Define new types _in your code_ that work well with existing methods _from a package_
- Define new methods _in your code_ that apply to existing types _from a package_
As underlined by Stefan Karpinski in his [JuliaCon 2019 talk](https://youtu.be/kc9HwsxE1OY), there are very few languages where both of these tasks are easy to achieve.
Julia is one of them.
"""

# ╔═╡ 2016d37b-ab63-4956-8fe7-de7eaadfb29f
md"""
### Adding a Pokémon family
"""

# ╔═╡ cf769229-9766-40d5-a8e0-1b7cb0b8b16e
md"""
Professor Edelman wants to play Pokémon using Julia.
But to do that, he wants _you_ to implement the new `Corgi` family, full of legendary creatures with untold abilities.
"""

# ╔═╡ 3903ec25-8077-49e2-a711-2500defec7b5
md"""
!!! danger "Task 1.2.1"
	Define an abstract subtype of `Pokemon` named `Corgi`.
"""

# ╔═╡ a4c0fff3-b4fe-4c48-8680-c12bbf4f68f3
abstract type Corgi <: Pokemon end

# ╔═╡ 3d31d6ab-d466-4581-9ade-a8a541a03319
md"""
Note that, since this type is abstract, you cannot instantiate it directly.
It only serves as a layer in the type hierarchy.
"""

# ╔═╡ 88c8da1c-8cd8-4dad-961e-edf035790286
md"""
Pokemon of type `Corgi` have super effective attacks against every other family except `Normal`
"""

# ╔═╡ fb577ace-d7d1-4ac9-ad47-57d28528c243
md"""
!!! danger "Task 1.2.2"
	Extend the fight mechanism by defining appropriate methods for attackers of type `Corgi`.
"""

# ╔═╡ a2fe0244-361f-4154-af76-a56bd7928880
begin
	attack(att::Corgi, def::Fire) = SUPER_EFFECTIVE
	attack(att::Corgi, def::Water) = SUPER_EFFECTIVE
	attack(att::Corgi, def::Grass) = SUPER_EFFECTIVE
	attack(att::Corgi, def::Electric) = SUPER_EFFECTIVE
end;

# ╔═╡ ccc1dd94-a1db-4504-8d27-5fbf577cee30
md"""
Among the `Corgi` family, the one called `Philip` is by far the most powerful entity.
Unlike the other Pokémon we have encountered, `Philip` has a reserve of life points, which makes him more resilient against attacks.
"""

# ╔═╡ e2f9f8d1-0d83-415e-b459-4c6e36cc9ddf
md"""
!!! danger "Task 1.2.3"
	Define a new structure for `Philip` with a single attribute named `life`, of type `Int`. Add an inner constructor which takes `life` as an argument, and another one which sets `life` to be a random number between $1$ and $5$.
"""

# ╔═╡ f899ed08-4315-4c17-8792-84ad0cae631b
struct Philip <: Corgi
	life::Int
	# Constructors
	Philip(life) = new(life)
	Philip() = new(rand(1:5))
end

# ╔═╡ 28737ee7-6939-4830-95e3-fc08b6dcf1a4
hint(md"Take a look at the documentation on [composite types](https://docs.julialang.org/en/v1/manual/types/#Composite-Types) and [inner constructor methods](https://docs.julialang.org/en/v1/manual/constructors/#man-inner-constructor-methods)")

# ╔═╡ 24e23eb0-9341-4249-afe1-c6d94c57478e
md"""
Let's see what happens when we create a `Philip`... or two!
Remember, the constructor with no argument is random, so the following cells may return a different result if you run them repeatedly.
"""

# ╔═╡ f0705b81-3df4-4145-9de5-8a4d738f6398
philip = Philip()

# ╔═╡ f5604cbe-0348-475c-8e0f-43b7bb213b36
other_philip = Philip(4)

# ╔═╡ a4eedc3b-0808-42ec-88b0-d710497fcd68
philip.life, other_philip.life

# ╔═╡ eaea15b2-5918-4fc0-b44a-3cb0c085fa67
md"""
When an attack is launched against `Philip`, a random number is drawn between $1$ and `life`. If this number is equal to `life`, the attack is super effective, otherwise it is normally effective.
"""

# ╔═╡ 8fc13f81-3e49-4b98-8592-fb9f24eda900
md"""
!!! danger "Task 1.2.4"
	Extend the fight mechanism by defining appropriate methods for defenders of type `Philip`.
"""

# ╔═╡ cf737824-4aa3-409b-a914-be606c9668a0
function attack(pok::Pokemon, phil::Philip)
	strength = rand(1:phil.life)
	if strength == phil.life
		return SUPER_EFFECTIVE
	else
		return NORMAL_EFFECTIVE
	end
end;

# ╔═╡ eb29c4ee-2cd2-4c51-a1c3-954b5745b9a9
attack(pikachu, pikachu)  # Electric on Electric: not very effective

# ╔═╡ 5f605953-9216-41fc-b935-bb6c2ca5414e
attack(pikachu, vaporeon)  # Electric on Water: super effective

# ╔═╡ 35fe8041-58ba-419e-a9d2-f9fc97d13cce
attack(vaporeon, pikachu)  # Water on Electric: normally effective

# ╔═╡ 79b384b1-8393-4c8c-84e4-6c1c729c53eb
md"""
Now let's test just how strong `Philip` is.
Again, keep in mind that the following cells are non-deterministic.
"""

# ╔═╡ afdf5d1e-d19d-486e-ab4d-167d74975e5e
attack(philip, snorlax)

# ╔═╡ 996f35f9-8510-4cee-b923-1c11ef7244af
attack(philip, pikachu)

# ╔═╡ 3d800a03-06fc-46e4-b0d6-d123200fc26f
attack(vaporeon, philip)

# ╔═╡ d11432fc-cdee-4364-8159-49ce25d6c7e5
attack(vaporeon, other_philip)

# ╔═╡ d73978e5-ec24-4d71-82ca-184c76f00b74
attack(philip, other_philip)

# ╔═╡ 023a75a3-a7a6-4e2d-911b-8a5c54d86e80
md"""
### Adding a friendship mechanism
"""

# ╔═╡ 87cdb6d3-cfa6-4564-8ea4-e2f202d89eca
md"""
Professor Edelman won't stop at the introduction of the `Corgi` family.
Indeed, he has seen the true violence of the Pokémon universe, and he has said: "no more".
Why would Pokémon need to fight all the time, when they can be friends?
While attack effectiveness is defined at the level of families, friendship is naturally defined at the level of individual Pokémon.
"""

# ╔═╡ d5ba5a13-9242-480c-94d7-e681e0ecdf72
md"""
By default, two arbitrary Pokémon are not friends.
"""

# ╔═╡ 117ff067-08ae-4134-8d23-ef28d31a7b8f
friends(pok1::Pokemon, pok2::Pokemon) = false;

# ╔═╡ e65bfd90-83c6-4c93-9f7f-aa8d41c01531
md"""
But `Charmander`, `Squirtle` and `Bulbasaur` are friends because they all came of age together.
"""

# ╔═╡ 172d0f37-5214-4e73-8635-8bfe85011f4a
begin
	friends(pok1::Charmander, pok2::Squirtle) = true
	friends(pok1::Squirtle, pok2::Charmander) = true
	
	friends(pok1::Charmander, pok2::Bulbasaur) = true
	friends(pok1::Bulbasaur, pok2::Charmander) = true

	friends(pok1::Bulbasaur, pok2::Squirtle) = true
	friends(pok1::Squirtle, pok2::Bulbasaur) = true
end;

# ╔═╡ 86d0af15-ccf4-4254-a686-a6ace39a7a74
md"""
As a side note, this way of doing things might seem strange to people unfamiliar with Julia.
After all, we could simply use an `if / else` statement.
"""

# ╔═╡ 22633b0a-33c5-4b7d-98b0-42663adc1631
function friends_naive(pok1::Pokemon, pok2::Pokemon)
	if pok1 isa Charmander && pok2 isa Squirtle
		return true
	elseif pok1 isa Squirtle && pok2 isa Charmander
		return true
	elseif pok1 isa Charmander && pok2 isa Bulbasaur
		return true
	elseif pok1 isa Bulbasaur && pok2 isa Charmander
		return true
	elseif pok1 isa Bulbasaur && pok2 isa Squirtle
		return true
	elseif pok1 isa Squirtle && pok2 isa Bulbasaur
		return true
	else
		return false
	end
end;

# ╔═╡ 4885f35e-1875-4dca-8bad-f8ae94cb98b3
md"""
First, `friends_naive` is more tedious to write and read, because everything has to be in the same place.
Second, it is not easy to extend _a posteriori_.
And third, this paradigm often leads to less efficient functions.
Indeed, since multiple dispatch selects the appropriate method based on argument types, it can generate shorter machine code than the full `if / else` statement.
This doesn't seem to hold here however, probably because the compiler is smart enough to optimize away the difference.
"""

# ╔═╡ c64086a9-b749-4a5d-8665-0085ae4fb64e
md"""
!!! danger "Task 1.2.5"
	Extend the friendship mechanism to account for the fact that `Philip` is friends with everyone.
"""

# ╔═╡ 6daea6c1-6eb4-4117-8e11-63e9913792e3
begin
	friends(pok1::Philip, pok2::Pokemon) = true
	friends(pok1::Pokemon, pok2::Philip) = true
	friends(pok1::Philip, pok2::Philip) = true
end;

# ╔═╡ c491ca01-5a0b-4f91-825c-67f597aa788a
hint(md"You might get an error due to an ambiguous method. This means multiple dispatch has failed because there is no single most specific implementation. How do you fix this?")

# ╔═╡ d96068be-4ac9-4ff9-ae3e-4807df555a42
md"""
Let us check that everything works as expected.
"""

# ╔═╡ 2eb828db-1008-4551-819d-60ec0aa8eb7a
friends(snorlax, snorlax)

# ╔═╡ a637f11c-bd0a-4a87-a1b9-52fd43eb9fcc
friends(pikachu, philip)

# ╔═╡ c619533d-6e4c-4aae-b3a7-099f578f7b7d
friends(philip, vaporeon)

# ╔═╡ 076c200b-d1cf-4c17-91d3-84d447271560
friends(philip, philip)

# ╔═╡ 916540e4-d354-436e-8c79-a8e2aff4f591
md"""
## 1.3 Grid world simulation
"""

# ╔═╡ 9c41f013-38f4-41b4-a2c9-90a2f6f08356
md"""
Inspired by this [tweet](https://twitter.com/olafurw/status/1522273899441967104), we now simulate fights between Pokémon, in order to see which family ends up on top.
"""

# ╔═╡ e5bf5d32-2597-42d1-b9a6-eba666fe48d5
md"""
To visualize the simulation results, we assign a color to each Pokémon family.
"""

# ╔═╡ f911d885-cc82-4eff-bac2-310e49923c63
begin
	get_color(::Normal) = colorant"gray"
	get_color(::Fire) = colorant"red"
	get_color(::Water) = colorant"blue"
	get_color(::Grass) = colorant"green"
	get_color(::Electric) = colorant"yellow"
	if @isdefined(Corgi)
		get_color(::Corgi) = colorant"purple"
	end
end;

# ╔═╡ f7b8330e-5897-4b71-a9aa-64838cf2a9bd
md"""
### Initialization and evolution rules
"""

# ╔═╡ f2ea1753-e3d8-42e0-a495-5fd22abeb944
md"""
!!! danger "Task 1.3.1"
	Define a function `new_grid(pokemon_set; n, m)` that creates a matrix of Pokémon of size `n × m` and fills it with random picks from the set `pokemon_set`.
"""

# ╔═╡ b66b0c70-fdd1-4d43-8adf-807f59055f8c
function new_grid(pokemon_set; n, m)
	grid = Matrix{Pokemon}(undef, n, m)
	for i in 1:n, j in 1:m
		grid[i, j] = rand(pokemon_set)
	end
	return grid
end

# ╔═╡ e227d7f2-ddb7-415e-9b9e-e0efd8945ca0
begin
	g1 = new_grid([Pikachu(), Charmander(), Squirtle()]; n=5, m=8)
	get_color.(g1)
end

# ╔═╡ d8058473-2ffa-4ae4-8699-435bdf7d6f08
md"""
The rules of the fight are simple.
At each time step, the following events occur in order:
1. A random Pokémon is chosen from the grid to be the attacker.
2. A random neighbor (among 8) is selected to be the defender.
3. If the attack is super effective, the defender is replaced in the grid by a copy of the attacker.
"""

# ╔═╡ ebddaba7-792a-4546-9739-df271df2a880
md"""
!!! danger "Task 1.3.2"
	Define a function `step!(grid)` which applies one step of fight simulation to a matrix of Pokémon, modifying this matrix in the process.
"""

# ╔═╡ 52121c38-fe60-4c52-8c43-40970fc8d69c
function step!(grid::Matrix{<:Pokemon})
	n, m = size(grid)
	i, j = rand(1:n), rand(1:m)
	att = grid[i, j]
	possible_neighbors = [(i-1, j-1), (i-1, j), (i-1, j+1), (i, j-1), (i, j+1), (i+1, j-1), (i+1, j), (i+1, j+1)]
	neighbors = [(i2, j2) for (i2, j2) in possible_neighbors if (1 <= i2 <= n) && (1 <= j2 <= m)]
	i2, j2 = rand(neighbors)
	def = grid[i2, j2]
	if attack(att, def) == SUPER_EFFECTIVE
		grid[i2, j2] = att
	end
end

# ╔═╡ 04de7b1e-ea7c-438d-b16a-8e758bb40a70
T_test = 10

# ╔═╡ 4ea66307-dbfc-45d2-894c-fbd89f1957ce
begin
	g2 = copy(g1)
	for _ in 1:T_test
		step!(g2)
	end
	get_color.(g1), get_color.(g2)
end

# ╔═╡ 8d558109-3d41-4ed1-b855-2d7ce7f29369
md"""
!!! danger "Task 1.3.3"
	Implement a new function called `step_consider_friends!` where the attack doesn't happen if the attacker is friends with the defender.
	> What do you observe?
"""

# ╔═╡ 7f97374d-04d9-4241-b166-aa5a6e052c66
function step_consider_friends!(grid::Matrix{<:Pokemon})
	n, m = size(grid)
	i, j = rand(1:n), rand(1:m)
	att = grid[i, j]
	possible_neighbors = [(i-1, j-1), (i-1, j), (i-1, j+1), (i, j-1), (i, j+1), (i+1, j-1), (i+1, j), (i+1, j+1)]
	neighbors = [(i2, j2) for (i2, j2) in possible_neighbors if (1 <= i2 <= n) && (1 <= j2 <= m)]
	i2, j2 = rand(neighbors)
	def = grid[i2, j2]
	if !friends(att, def) && attack(att, def) == SUPER_EFFECTIVE
		grid[i2, j2] = att
	end
end

# ╔═╡ 2b34aa16-107c-4e17-88bb-6dfc6e2b4881
begin
	g3 = copy(g1)
	for _ in 1:T_test
		step_consider_friends!(g3)
	end
	get_color.(g1), get_color.(g3)
end

# ╔═╡ 51103ee4-b68b-48cf-addc-8905dda40747
md"""
Here is a function that runs a full simulation on $T$ steps and displays the result as a GIF.
"""

# ╔═╡ 012dd868-8815-4c3e-9adb-1ce854081bac
function simulation(pokemon_set; n, m, T, consider_friends=false, dT=1000)
	g = new_grid(pokemon_set; n=n, m=m)
	anim = @animate for t in 1:(T ÷ dT)
		for k in 1:dT
			if consider_friends
				step_consider_friends!(g)
			else
				step!(g)
			end
		end
		plot(get_color.(g), title="Time = $(t*dT)")
	end
	return gif(anim)
end

# ╔═╡ dd38f9f9-0da9-4039-b1bd-ed914d434c7f
md"""
### Experiments
"""

# ╔═╡ de109133-313f-4235-a885-eb8ca55cde67
basic_pokemon = [Snorlax(), Charmander(), Squirtle(), Bulbasaur(), Pikachu()]

# ╔═╡ 176c6971-483f-408c-abc2-994546a5f57f
simulation(
	basic_pokemon;
	n=100, m=100, T=100_000
)

# ╔═╡ 876837a1-06b7-4b86-829d-4edeae166dc3
eevees = [Eevee(), Flareon(), Vaporeon(), Leafeon(), Jolteon()]

# ╔═╡ fb8696b8-4d1b-49cf-8e25-703287d2b3f1
all_pokemon = vcat(basic_pokemon, eevees, Philip(5))

# ╔═╡ 97541230-5515-4b78-b211-2a01a2d9ed83
simulation(
	all_pokemon;
	n=100, m=100, T=100_000
)

# ╔═╡ e3478b55-7100-49c8-809f-4a8bf15071f3
simulation(
	all_pokemon;
	consider_friends=true, n=100, m=100, T=100_000
)

# ╔═╡ d4324265-e4af-4f00-ab00-d65976d8d583
md"""
!!! danger "Task 1.3.4" 
	Play around with the previous simulations.
	> Increase the duration, change the grid size, the set of Pokémon, the life of the `Philip` you include.
	> Comment on what you observe.
"""

# ╔═╡ 8e96478a-4dd4-4eab-bda3-e19e60adf332
simulation(
	all_pokemon;
	consider_friends=true, n=50, m=100, T=500_000
)

# ╔═╡ bd90221c-c590-4d36-bba4-6b0b2e4f2453
md"""
## Utilities 1
"""

# ╔═╡ 893c6a98-fc54-47de-b514-a6ac0722c0aa
md"""
Keep Scrolling Past Hidden Elements to get to Part 2 of the homework.
"""

# ╔═╡ 1910d57c-853a-4f31-b3e6-0921d775ff8a
if show_toc; TableOfContents(); end

# ╔═╡ d900e981-36d8-4a3c-a1bd-5809ee6e7c64
chart_path = download("https://img.pokemondb.net/images/typechart.png");

# ╔═╡ 6893ced3-012f-4dc2-8e1c-2a292bfe067e
load(chart_path)[170:392, 52:305]

# ╔═╡ 7c362af1-cc1a-47fc-b3a1-252a891849e5
begin
	snorlax_path = download("https://assets.pokemon.com/assets/cms2/img/pokedex/full/143.png")
	charmander_path = download("https://assets.pokemon.com/assets/cms2/img/pokedex/full/004.png")
	squirtle_path = download("https://assets.pokemon.com/assets/cms2/img/pokedex/full/007.png")
	bulbasaur_path = download("https://assets.pokemon.com/assets/cms2/img/pokedex/full/001.png")
	pikachu_path = download("https://assets.pokemon.com/assets/cms2/img/pokedex/full/025.png")

	eevee_path = download("https://assets.pokemon.com/assets/cms2/img/pokedex/full/133.png")
	flareon_path = download("https://assets.pokemon.com/assets/cms2/img/pokedex/full/136.png")
	vaporeon_path = download("https://assets.pokemon.com/assets/cms2/img/pokedex/full/134.png")
	leafeon_path = download("https://assets.pokemon.com/assets/cms2/img/pokedex/full/470.png")
	jolteon_path = download("https://assets.pokemon.com/assets/cms2/img/pokedex/full/135.png")
end;

# ╔═╡ d20b68c4-3091-4e49-8873-199672ed2695
begin
	(
		load(snorlax_path),
		load(charmander_path),
		load(squirtle_path),
		load(bulbasaur_path),
		load(pikachu_path)
	)
end

# ╔═╡ fc1c3e85-b1af-4cbb-a8fe-597174bea4d4
begin
	(
		load(eevee_path),
		load(flareon_path),
		load(vaporeon_path),
		load(leafeon_path),
		load(jolteon_path)
	)
end

# ╔═╡ 66e2042d-aedc-41cb-91c0-b364e014f7f0
check_eevee = if (
	(@isdefined Eevee) &&
	Eevee <: Normal &&
	isconcretetype(Eevee) &&
	isempty(fieldnames(Eevee))
)
	correct(md"`Eevee` is correctly defined")
else
	almost(md"You need to define `Eevee` correctly")
end;

# ╔═╡ f43cde45-9c12-430d-b75b-70a2c476db5b
check_eevee

# ╔═╡ 8b5e86e7-0f98-48b5-969d-e48daddf10cb
check_flareon = if (
	(@isdefined Flareon) &&
	Flareon <: Fire &&
	isconcretetype(Flareon) &&
	isempty(fieldnames(Flareon))
)
	correct(md"`Flareon` is correctly defined")
else
	almost(md"You need to define `Flareon` correctly")
end;

# ╔═╡ 04c69dcc-534a-4c52-a8a3-5a65fb5f0191
check_vaporeon = if (
	(@isdefined Vaporeon) &&
	Vaporeon <: Water &&
	isconcretetype(Vaporeon) &&
	isempty(fieldnames(Vaporeon))
)
	correct(md"`Vaporeon` is correctly defined")
else
	almost(md"You need to define `Vaporeon` correctly")
end;

# ╔═╡ ed80972f-648a-4975-b414-2e644565dccb
TwoColumn(check_flareon, check_vaporeon)

# ╔═╡ 0e502851-fa10-4d2c-aaf3-e47ca4bf4bcf
check_leafeon = if (
	(@isdefined Leafeon) &&
	Leafeon <: Grass &&
	isconcretetype(Leafeon) &&
	isempty(fieldnames(Leafeon))
)
	correct(md"`Leafeon` is correctly defined")
else
	almost(md"You need to define `Leafeon` correctly")
end;

# ╔═╡ 42631084-34ec-4482-9e10-84ff85067b93
check_jolteon = if (
	(@isdefined Jolteon) &&
	Jolteon <: Electric &&
	isconcretetype(Jolteon) &&
	isempty(fieldnames(Jolteon))
)
	correct(md"`Jolteon` is correctly defined")
else
	almost(md"You need to define `Jolteon` correctly")
end;

# ╔═╡ a33536e5-f9de-41d1-bd17-0a8dd8d577dc
TwoColumn(check_leafeon, check_jolteon)

# ╔═╡ 82751f0f-87fd-4110-9e86-0d0b1ad5cd36
check_corgi = if (
	(@isdefined Corgi) &&
	Corgi <: Pokemon &&
	!isconcretetype(Corgi)
)
	correct(md"`Corgi` is correctly defined")
else
	almost(md"You need to define `Corgi` correctly")
end;

# ╔═╡ c3a05713-b023-4f8f-9eb2-98dc818de3ca
check_corgi

# ╔═╡ a3e88d8f-72dd-495a-b61b-a969cac7e55a
check_attack_corgi = if (@isdefined Corgi)
	struct DummyCorgi <: Corgi end
	if (
		attack(DummyCorgi(), Snorlax()) == NORMAL_EFFECTIVE &&
		attack(DummyCorgi(), Charmander()) == SUPER_EFFECTIVE &&
		attack(DummyCorgi(), Squirtle()) == SUPER_EFFECTIVE &&
		attack(DummyCorgi(), Bulbasaur()) == SUPER_EFFECTIVE &&
		attack(DummyCorgi(), Pikachu()) == SUPER_EFFECTIVE
	)
		correct(md"`attack` is correctly defined for `Corgi` attackers")
	else
		almost(md"You need to define `attack` correctly for `Corgi` attackers")
	end
else
	almost(md"You need to define `attack` correctly for `Corgi` attackers")
end;

# ╔═╡ 2d0b80cb-01b4-429c-beed-c2c0d6f8626e
check_attack_corgi

# ╔═╡ a25c0f95-7c94-449f-a6c2-8acc649d3307
check_philip = if (
	(@isdefined Corgi) &&
	(@isdefined Philip) &&
	Philip <: Corgi &&
	isconcretetype(Philip) &&
	fieldnames(Philip) == (:life,) &&
	fieldtypes(Philip) == (Int,) &&
	all(in(1:5), [Philip().life for k in 1:100])
)
	correct(md"`Philip` is correctly defined")
else
	almost(md"You need to define `Philip` correctly")
end;

# ╔═╡ 7df61a7e-b8d0-4024-8dce-239cf0d0edd8
check_philip

# ╔═╡ 3117a299-06af-47d4-8fb3-3ce394b71050
check_defense_philip = if (
	(@isdefined Philip) &&
	Set(attack(Snorlax(), Philip()) for _ in 1:1000) == Set([NORMAL_EFFECTIVE, SUPER_EFFECTIVE])
)
	correct(md"`attack` is correctly defined for `Philip` defenders")
else
	almost(md"You need to define `attack` correctly for `Philip` defenders")
end;

# ╔═╡ 4abde394-998e-4ff2-ad27-0f86a169d841
check_defense_philip

# ╔═╡ 90c54b0f-0813-4813-8b8c-913a904817dd
check_friends_philip = if (
	(@isdefined Philip) &&
	friends(Philip(), Philip()) == true &&
	friends(Philip(), Charmander()) == true &&
	friends(Philip(), Squirtle()) == true &&
	friends(Philip(), Bulbasaur()) == true &&
	friends(Philip(), Pikachu()) == true
)
	correct(md"`friends` is correctly defined for `Philip` arguments")
else
	almost(md"You need to define `friends` correctly for `Philip` arguments")
end;

# ╔═╡ 5da5d4f3-a96c-4025-adf2-47978f441519
check_friends_philip

# ╔═╡ 2b8f9fce-639a-432c-986e-956297743f14
check_new_grid = begin
	if @isdefined new_grid 
		my_pokemon_set = [Snorlax()]
		my_grid = new_grid(my_pokemon_set; n=20, m=50)
		if my_grid isa Matrix{<:Pokemon}
			if size(my_grid) == (20, 50)
				contents = Set(my_grid)
				if Set(my_grid) == Set(my_pokemon_set)
					correct(md"`new_grid` is correctly defined.")
				else
					almost(md"Make sure that `new_grid` chooses random elements from the input `pokemon_set`.")
				end
			else
				almost(md"Make sure that `new_grid` returns a matrix of size `n × m`.")
			end
		else
			almost(md"Make sure that `new_grid` returns a `Matrix{<:Pokemon}`, i.e. a 2-dimensional array.")
		end
	else
		almost(md"Make sure that `new_grid` is defined")
	end
end;

# ╔═╡ 72f838ef-ecbd-412e-9ea6-88fc48fe8da6
check_new_grid

# ╔═╡ 5794e6ef-ccc0-448d-a881-328b057e0b1c
md"""
# Part 2: Callable structs
"""

# ╔═╡ efea9df5-8891-401a-a454-87151c79193f
md"""
The following cell can take some time to run, so it is disabled when we first give it to you. Start it, don't freak out and grab a cup of tea.
"""

# ╔═╡ 39f97748-50ce-4f77-a28a-f21eb23173f5
md"""
## 2.1 Abstract and concrete types
"""

# ╔═╡ c169b341-a099-42c2-8137-2c197afe00bd
md"""
Julia has a type hierarchy with two ingredients: abstract types and concrete types.
Concrete types (like `Float64` or `Int`) are the ones that you can actually instantiate, while abstract types (like `Real` or `Number`) serve to define generic methods for several concrete types at once.
"""

# ╔═╡ e833bbca-3d88-4467-ac28-03d1d45e10ab
md"""
Why does the difference matter?
Because with a concrete type, the memory layout of the object is well specified.
If the compiler knows it will work on `Float64` numbers, it can generate very efficient code that is taylored to this representation.
But if the compiler only knows it will work on `Real` numbers, then it must generate a very clunky code that works for all possible subtypes of real numbers: integers, rationals, floating point, etc.
"""

# ╔═╡ 90e3c840-1c83-4681-89b6-47290d43d30d
md"""
It is very simple to check whether you are dealing with an abstract or concrete type.
"""

# ╔═╡ ebafb690-9677-4342-9ca4-8e456ab0b3fb
isconcretetype(Float64), isconcretetype(Real)

# ╔═╡ a8a29bc5-9b80-48f7-a98b-3d57666ed8d4
print_tree(Real)

# ╔═╡ 44d87f80-a97b-4901-82b6-6f55900d3649
md"""
You can explore the relations between types with the functions `supertypes` and `subtypes`.
"""

# ╔═╡ 9b03fbf6-945b-4662-b270-4eab5229940d
subtypes(Real)  # gives all the children of a type

# ╔═╡ 56a31847-29c9-4ed2-8ade-a7139217fa20
md"""
!!! danger "Task 2.1"
	Implement a function `count_descendants(T)` which outputs the number of descendants (the node itself + all of its children, grandchildren, etc.) of a type `T` in the type tree.
	How many descendants does `Real` have?
	Does this number depend on the packages we have imported?
"""

# ╔═╡ 8a1dddcc-b448-421e-94b4-020c6adbef2d
count_descendants(T)::Int = 1 + sum(map(count_descendants, subtypes(T)))

# ╔═╡ e3584c01-d769-4fc1-a926-4ae6f8fca74c
let
	if @isdefined count_descendants
		try
			check = count_descendants(Integer) == 15
			if check
				correct()
			else
				almost(md"`count_descendants(Integer)` should be equal to 17")
			end
		catch e
			almost(md"`count_descendants(Integer)` throws an error")
		end
	else
		almost(md"You need to define `count_descendants`")
	end
end

# ╔═╡ 5b4a4e16-af38-40a7-b9a2-303952b2060f
md"""
## 2.2 Callable structs
"""

# ╔═╡ 2f2d3b08-b52d-464c-a840-7956601c4580
md"""
By now, you know how to define functions in Julia, using the syntax below.
"""

# ╔═╡ c28bc501-72e9-4ce0-9e18-d4261df1d4c1
function my_identity(x)
	return x
end

# ╔═╡ acf5df55-21c4-44e0-a5ff-b578e4859b0b
md"""
!!! danger "Task 2.2.1"
	What is the type of `my_identity`? What are its supertypes?
"""

# ╔═╡ 6494852e-4e0b-4f3d-8aba-1835e5d89862
typeof(my_identity)

# ╔═╡ 00679b2f-f1f6-42a2-bbf2-d68b5344f858
supertypes(typeof(my_identity))

# ╔═╡ 45b0f116-fb0a-4b71-b2a9-8ccf59cea3ce
md"""
Functions are just a particular kind of callable object (or "functor").
But as it turns out, every type can be made callable using a very simple trick: just define a function whose "name" is an instance of the type.
This is very useful when you want to perform operations with some internal parameters (like weights in a neural network, see below).
"""

# ╔═╡ 8a38a25e-9124-4f56-9e81-cfd86d655b0a
md"""
Here's a simple example, in which we define a `Multiplier` struct with a single attribute `a`.
When we call an instance `mult` of this type on a value `x`, we want to obtain the product `mult.a * x`.
"""

# ╔═╡ 43faaa6c-5798-4da7-9da0-86e6e5a23c2d
begin
	struct Multiplier
		a
	end

	function (mult::Multiplier)(x)
		return mult.a * x
	end
end

# ╔═╡ 60d59a6a-ccce-4d96-b651-7a5aebb948a0
md"""
Note that we put both definitions in the same cell because of Pluto quirks.
Now let's check that everything works as intended.
"""

# ╔═╡ eac42582-056f-4040-ae37-1f189e45dcb2
let
	scalar_mult = Multiplier(2.0)
	(
		scalar_mult(3),
		scalar_mult(4 + 5im),
		scalar_mult(6 * ones(2, 2))
	)
end

# ╔═╡ c0a81310-0e39-4c51-806c-18ab46bd1410
let
	matrix_mult = Multiplier([1 2; 3 4])
	(
		matrix_mult(3),
		matrix_mult(4 + 5im),
		matrix_mult(6 * ones(2, 2))
	)
end

# ╔═╡ ff7b2edc-9500-4e2f-acaa-bc18297348c0
md"""
We will encounter callable structs again in Sections 2 and 3, when we discuss time series and solutions to differential equations.
"""

# ╔═╡ 582f6bd8-2b83-4a6d-99f9-ba27961f35c5
md"""
!!! danger "Task 2.2.2"
	Implement a callable struct `FunctionWrapper` with a single field `f`.
	Whenever it is called, it should simply apply the function `f` to the input arguments.
"""

# ╔═╡ 059ca660-a954-4e9d-8ebc-6812ad73325f
hint(md"If you want a function to accept any number of positional and keyword arguments, the syntax is `f(args...; kwargs...)`")

# ╔═╡ 52447e60-2d11-42b9-b99b-947f3fdcb17e
begin
	struct FunctionWrapper
		f
	end
	
	(fw::FunctionWrapper)(args...; kwargs...) = fw.f(args...; kwargs...)
end

# ╔═╡ 8f025763-0f78-4d6b-a361-04e0634f3d5a
let
	if @isdefined FunctionWrapper
		fw = FunctionWrapper(sin)
		fw(1), sin(1)
	end
end

# ╔═╡ 077c7c21-b921-444f-8ba4-a5bec28254aa
let
	if @isdefined FunctionWrapper
		try
			fw = FunctionWrapper(sin)
			try
				check = fw(1) == sin(1)
				if check
					correct()
				else
					almost(md"`FunctionWrapper(sin)(1)` should be equal to`sin(1)`")
				end
			catch e
				almost(md"`FunctionWrapper(sin)(1)` throws an error")
			end
		catch e
			almost(md"`FunctionWrapper(sin)` throws an error")
		end
	else
		almost(md"You need to define `FunctionWrapper`")
	end
end

# ╔═╡ 0b343ca3-73a0-472b-9af6-d523b38e2e14
md"""
## 2.3 Type-stability
"""

# ╔═╡ 6953302e-6b11-4561-aa3d-1d9f93f1c506
md"""
Today is your lucky day, because I'm going to teach you about type stability, one of the secrets to writing high-performance Julia code!!

Type inference is the process by which Julia tries to deduce the type of every variable in your code before actually running it.
A code that enables successful type inference is called type-stable.

For each function you write, can you deduce the type of every intermediate and output quantity based only on the _types_ (not the _values_) of the inputs?
If the answer is yes, then your code is type-stable.
"""

# ╔═╡ 4b0fa9b0-51b9-4997-932c-074c122fc2a3
md"""
!!! danger "Task 2.3.1"
	Try to explain why the following function is type-unstable.
"""

# ╔═╡ d4a1731d-4b9f-4650-bda4-c9d3aa0e9263
function choice(x)
	if x < 0
		return "negative number"
	else
		return x
	end
end

# ╔═╡ 81a0bf4a-ad00-4adc-9d16-503a6f75f115
md"""
> The output type depends on the value of `x`: it can be either `String` or the type of `x` itself.
"""

# ╔═╡ cf15fa7c-50a9-4b72-b7ab-00bfa5a9ce0d
md"""
The `Multiplier` defined above works, but it is far from perfect.
Its biggest fault is that it doesn't "know" the type of the field `a`.
As a result, it generates type-unstable calls because Julia cannot predict the type of the output `a * x`.

Such problems can often be diagnosed with the `@code_warntype` macro, which is used before a function call.
As a rule of thumb, blue is good and red is bad, while yellow is "meh".
"""

# ╔═╡ d93e006f-3727-4197-a87c-4d01fd08b1fb
let
	a = 2.0
	x = 1.0
	@code_warntype a * x
end

# ╔═╡ f00a45b5-99db-4902-bc90-2e92de510b52
md"""
This is not easy to read, but what is important is the type of every intermediate quantity is correctly inferred as `Float64`.
"""

# ╔═╡ aa52a3a9-2ddc-4fcf-8235-1b5c926fa93f
let
	a = 2.0
	mult = Multiplier(a)
	x = 1.0
	@code_warntype mult(x)
end

# ╔═╡ ebfaaad3-be48-4f36-8502-ae969b574e60
md"""
On the other hand, since the type of `mult.a` is forgotten by the `Multiplier`, all we can infer is that it will be of type `Any`, which is a supertype of everything else (see `%1`).
As a consequence, the type of `Body` (which is the output of the function) is also inferred as `Any` (see `%2`).
"""

# ╔═╡ ee57c162-fc0c-497f-bca7-c5135e77ebee
md"""
But why is it bad to have type-instability?
Because Julia has to prepare for every possible type, which generates very lengthy and inefficient machine code.
This can be confirmed with the `@code_llvm` macro.
"""

# ╔═╡ 91498fc6-90c5-433b-ba02-cce4de287b00
let
	a = 2.0
	x = 1.0
	@code_llvm a * x
end

# ╔═╡ a5541b7c-6ecc-410f-817b-eead32f984ee
md"""
This low-level code is only a few lines long.
"""

# ╔═╡ 66e38fca-0013-4e59-bc21-3b29958289e2
let
	a = 2.0
	mult = Multiplier(a)
	x = 1.0
	@code_llvm mult(x)
end

# ╔═╡ a55d3b23-6ebd-4700-bd50-84d96df1c87e
md"""
Whereas this one is the stuff of nightmares.
"""

# ╔═╡ 4e20e7c4-8303-4d10-b232-886fe824b27a
md"""
!!! danger "Task 2.3.2"
	Test the type-stability of your `FunctionWrapper`.
"""

# ╔═╡ 401ff0a6-533f-4c2f-a200-969ac4871dc2
hint(md"Don't worry if it is not type-stable: that's okay for now.")

# ╔═╡ 27472118-bdb0-4a8b-b604-44da89f49216
let
	fw = FunctionWrapper(sin)
	@code_warntype fw(1)
end

# ╔═╡ c34522a6-dc5e-48c8-8bf8-5b75810611e6
md"""
## 2.4 Parametric types
"""

# ╔═╡ 88837b59-7771-40e9-86da-8ffa8ef01c2e
md"""
So how do we solve the type-instability issue?
Well, the general idea is to [avoid fields with abstract types](https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-fields-with-abstract-type) in user-defined structs.
The sames principle applies to [arrays and other containers](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-abstract-container).
If the type of each field (or element) is concrete, then type inference suceeds, which leads to better performance.
"""

# ╔═╡ e6214561-9871-4ea7-b215-da33f6ffbe18
md"""
Let's see if this criterion is satisfied by our `Multiplier` (spoiler alert: no it isn't).
"""

# ╔═╡ 9df6539e-ef87-4426-bb23-4fc40489d0bb
let
	scalar_mult = Multiplier(2.0)
	fieldnames(typeof(scalar_mult)), fieldtypes(typeof(scalar_mult))
end

# ╔═╡ 5ff6ece2-801c-4769-8e70-e437fa44ec6c
md"""
Of course, the easy way out would be to add a concrete type annotation for the field `a`.
"""

# ╔═╡ c6a338e8-f37e-4c74-8953-b7d9607a96b5
begin
	struct SpecificMultiplier
		a::Float64
	end

	function (mult::SpecificMultiplier)(x)
		return mult.a * x
	end
end

# ╔═╡ 565340e2-246f-453e-b478-8916a2f83e3f
let
	scalar_mult = SpecificMultiplier(2.0)
	(
		scalar_mult(3),
		scalar_mult(4 + 5im),
		scalar_mult(6 * ones(2, 2))
	)
end

# ╔═╡ 20e92ed7-c7f9-44d6-88d1-3e16e1dfec1e
md"""
This time, we can check that our struct has a concrete field type.
"""

# ╔═╡ e5702ada-5eff-425b-92db-3dd6033ea221
let
	scalar_mult = SpecificMultiplier(2.0)
	fieldnames(typeof(scalar_mult)), fieldtypes(typeof(scalar_mult))
end

# ╔═╡ 9b6d1a58-6fd6-40e1-866c-6b0351afb053
md"""
But if we go down that road, we will need a different struct for every possible type of `a`.
That seems a bit tedious, especially since the multiplication code does not change.
What we really need is a single struct that somehow "adapts" to the type of the field `a`.

You've already seen that kind of construct before, when we introduced arrays.
Vectors and matrices have a "type parameter", which refers to the elements they contain.
"""

# ╔═╡ 1e8e6334-b6d7-4305-984a-4f8143321da4
typeof([1, 2]), typeof([1.0, 2.0]), typeof([[1, 2]])

# ╔═╡ b592618c-ddca-40fa-87b2-eb783599f0e9
md"""
As a result, `Vector`, `Matrix` and `Array` are called [parametric types](https://docs.julialang.org/en/v1/manual/types/#Parametric-Types).
We can define our own parametric type with the following syntax.
"""

# ╔═╡ 36b54358-c4f4-4e63-9762-fd8521ce5657
begin
	struct GenericMultiplier{T}
		a::T
	end

	function (mult::GenericMultiplier)(x)
		return mult.a * x
	end
end

# ╔═╡ 25cb033e-e9cc-4338-8844-501ed262c2ee
md"""
Every time we create a `GenericMultiplier`, it will automatically choose the right type parameter based on the type of `a`.
"""

# ╔═╡ 7fbed24e-e1de-41f4-b8f1-2b5b69d48d9c
typeof(GenericMultiplier(2.0))

# ╔═╡ 5e76418d-e1ac-4d4d-8678-a65e88c181c9
typeof(GenericMultiplier([1 2; 3 4]))

# ╔═╡ 25920fa9-e213-42dc-9844-309d51797607
md"""
We can also be picky and specify the parameter ourselves at construction.
"""

# ╔═╡ 03d1132e-5e66-4fbb-87c6-9ee8dedf903d
typeof(GenericMultiplier{Matrix{Float64}}([1 2; 3 4])

# ╔═╡ 1c4034a4-ab54-4e52-8a62-39a051640956
md"""
This new struct works as expected, no matter what we throw at it.
"""

# ╔═╡ ba689c80-cbf9-4a67-ab26-15ac66239683
let
	scalar_mult = GenericMultiplier(2.0)
	(
		scalar_mult(3),
		scalar_mult(4 + 5im),
		scalar_mult(6 * ones(2, 2))
	)
end

# ╔═╡ 28cef3b8-6e9a-4720-a00d-d4ae13cc14be
let
	matrix_mult = GenericMultiplier([1 2; 3 4])
	(
		matrix_mult(3),
		matrix_mult(4 + 5im),
		matrix_mult(6 * ones(2, 2))
	)
end

# ╔═╡ f67e5107-c4ca-4be3-b94b-b65439df057d
md"""
Importantly, this generic approach does not prevent type inference.
"""

# ╔═╡ a316a8ad-1644-49b6-9fb5-1b0d23a62cd3
all(isconcretetype, fieldtypes(GenericMultiplier{Float64}))

# ╔═╡ 9a2f1673-b6d1-4804-9fa5-f7c7893a3560
let
	a = 2.0
	mult = GenericMultiplier(a)
	x = 1.0
	@code_warntype mult(x)
end

# ╔═╡ 42896a90-ccb2-4d21-93b3-72544d5ee8ac
md"""
As a result, the generated machine code is about as efficient as can be.
"""

# ╔═╡ b4cc74e2-5c3a-4ac8-af3b-1a52970272c0
md"""
But don't take my word for it, check it yourself!
"""

# ╔═╡ 5d92f230-e2f5-41e9-bf07-4234dabc3355
md"""
!!! danger "Task 2.4.1"
	Compare the performance of `Multiplier`, `SpecificMultiplier` and `GenericMultiplier{T}` with `BenchmarkTools.jl`.
"""

# ╔═╡ 1103e116-e04c-486f-822e-55b5d9de7224
hint(md"
You already know the `@btime` and `@belapsed` macros, why not try `@benchmark` this time?
And don't forget the dollar signs!
")

# ╔═╡ 558cfd36-57ac-4c0f-9040-db2863220e6e
let
	a = 2.0
	x = 1.0
	mult1 = Multiplier(a)
	mult2 = SpecificMultiplier(a)
	mult3 = GenericMultiplier(a)
	b1 = @benchmark $mult1($x)
	b2 = @benchmark $mult2($x)
	b3 = @benchmark $mult3($x)
	b1, b2, b3
end

# ╔═╡ 9fd78cf8-c1dd-46b6-8e5d-f81ad22ac3ed
md"""
In other words, `GenericMultiplier` combines the generic capabilities of `Multiplier` with the type-specific performance of `SpecificMultiplier`.
That is called having your cake and eating it too, which is a Julia specialty.
"""

# ╔═╡ 7c4ce606-3fad-4632-af93-8bcd62b757ca
md"""
## 2.5 Type constraints
"""

# ╔═╡ 06766592-adc9-444e-99b8-9d3b5d3378db
md"""
In some cases, we want to enforce constraints on the type parameters.
This is done with the `<:` operator, which indicates subtyping.
"""

# ╔═╡ 0159f8a1-74f3-4ffe-8eb4-079c48ec4758
Float64 <: AbstractFloat <: Real <: Number <: Any

# ╔═╡ 15c7d609-bcea-4b78-9864-eed171371a39
md"""
Here is a way to overcome this difficulty.
"""

# ╔═╡ 486639b6-4c15-4f64-ad9b-ad66220215a2
Vector{Float64} <: Vector{<:Real}  # note the <: before Real

# ╔═╡ dfdf8e82-307a-4fa9-b0ea-e9c0fe7d6a8a
md"""
Now say we want to define a `Multiplier` that only works when `a` is a matrix containing any subtype of real numbers.
Here are several ways to do it.
"""

# ╔═╡ 3e44ef15-9ca9-4d2e-927c-ed38241e7b12
begin
	abstract type AbstractMatrixMultiplier end
	
	function (m::AbstractMatrixMultiplier)(x)
		return m.a * x
	end
end

# ╔═╡ b5a900e9-db14-4527-a6e9-13fb69ca39ca
struct MatrixMultiplier1 <: AbstractMatrixMultiplier
	a::Matrix{Real}
end

# ╔═╡ cf8a04df-1f9c-43e2-810d-c1a7ee2f0f34
struct MatrixMultiplier2 <: AbstractMatrixMultiplier
	a::Matrix{<:Real}
end

# ╔═╡ b70abc1e-be9c-42d1-b84f-7edd9dafe5cc
struct MatrixMultiplier3{T<:Real} <: AbstractMatrixMultiplier
	a::Matrix{T}
end

# ╔═╡ 6d700e2e-7175-4c80-9d34-7fa020621705
struct MatrixMultiplier4{M<:Matrix{Real}} <: AbstractMatrixMultiplier
	a::M
end

# ╔═╡ 43b0bc76-d86b-439f-84e7-6f0e7fdd3b40
struct MatrixMultiplier5{M<:Matrix{<:Real}} <: AbstractMatrixMultiplier
	a::M
end

# ╔═╡ c6006ac5-8f2c-450b-b554-b0a261316128
struct MatrixMultiplier6{T<:Real,M<:Matrix{T}} <: AbstractMatrixMultiplier
	a::M
end

# ╔═╡ 14cd3db3-c158-48b9-af2e-11a0f8a8bbf5
md"""
!!! danger "Task 2.5.1"
	Based on our discussion sofar, experiment with these various `MatrixMultiplier` structs and decide which ones a) have the correct behavior with respect to our specification, and b) are type-stable.

	Sum up your answers in the table below.
	If you think a given `MatrixMultiplier` is incorrect, provide a code example where it throws an error.
	If you think a given `MatrixMultiplier` is type-unstable, provide a code example where `@code_warntype` contains red flags (with exception of MatrixMultiplier1, where @code_warntype cannot catch that it is type unstable)
"""

# ╔═╡ 859c6786-8561-4a3e-b63d-c6377d960718
md"""
| Struct | Correct | Performance |
| --- | --- | --- |
| `MatrixMultiplier1` | yes | bad  |
| `MatrixMultiplier2` | yes | bad  |
| `MatrixMultiplier3` | yes | good |
| `MatrixMultiplier4` | no  | n/a   |
| `MatrixMultiplier5` | yes | good |
| `MatrixMultiplier6` | yes | good |

If you answered `yes` to the type-stability of `MatrixMultiplier1`, you also get the points because `@code_warntype` does not show red. 
"""

# ╔═╡ 73b4c541-ce70-479c-9e85-ed22c7a809f9
let
	m1 = MatrixMultiplier1(rand(5, 5))
	x = rand(5)
	@code_warntype m1(x)  # no red BUT returns Vector{Any}
end

# ╔═╡ c1cc7207-4604-4211-a2dc-035cc43d0905
let
	m2 = MatrixMultiplier2(rand(5, 5))
	x = rand(5)
	@code_warntype m2(x)  # red, returns Any
end

# ╔═╡ ca209acb-8c5c-43ea-9276-1cd9dcc15d61
let
	m3 = MatrixMultiplier3(rand(5, 5))
	x = rand(5)
	@code_warntype m3(x)
end

# ╔═╡ 6a678f27-6962-4e3a-a382-caa42be97539
let
	m4 = MatrixMultiplier4(rand(5, 5))  # throws an error
	x = rand(5)
	@code_warntype m4(x)
end

# ╔═╡ 1fbf6cfa-953d-43c0-a49b-bb264d737853
let
	m5 = MatrixMultiplier5(rand(5, 5))
	x = rand(5)
	@code_warntype m5(x)
end

# ╔═╡ ca49bc12-17e1-44b2-9918-47495f8241b8
let
	m6 = MatrixMultiplier6(rand(5, 5))
	x = rand(5)
	@code_warntype m6(x)
end

# ╔═╡ 78116d52-d11f-4c6d-b8a5-ebb8e9efa7c8
md"""
## 2.6 Your first neural network
"""

# ╔═╡ a4f30ea4-4a03-4713-bb87-cade80f1d8ca
md"""
Callable structs come up a lot in deep learning, whenever we construct layers of a [neural network](https://en.wikipedia.org/wiki/Artificial_neural_network).
A neural network layer is a function of the form $x \in \mathbb{R}^n \longmapsto \sigma.(W x + b) \in \mathbb{R}^m$, where
- the matrix $W \in \mathbb{R}^{m \times n}$ contains connection weights
- the vector $b \in \mathbb{R}^m$ contains biases
- the function $\sigma: \mathbb{R} \longrightarrow \mathbb{R}$ is a nonlinear activation applied elementwise
"""

# ╔═╡ 9057a4de-c631-4e37-9f38-bc0049f4844d
md"""
!!! danger "Task 2.6.1"
	Implement a callable struct `Layer` with three fields `W`, `b` and `σ`, such that:

	- `W` must be a matrix containing any subtype of `Real` numbers
	- `b` must be a vector containing any subtype of `Real` numbers
	- `σ` can be anything.

	Whenever it is called, it should perform the operation described above.
"""

# ╔═╡ b7835ff2-d125-4f4f-bd03-34d901a8b103
begin
	struct Layer{T1<:Real,T2<:Real,F}
		W::Matrix{T1}
		b::Vector{T2}
		σ::F
	end
	
	(layer::Layer)(x) = layer.σ.(layer.W * x + layer.b)
end

# ╔═╡ 4ddbd792-fe9b-4ec0-b67c-c985a75b3854
let
	if @isdefined Layer
		n, m = 3, 4
		W = rand(m, n)
		b = rand(m)
		σ = tanh
		x = rand(n)
		layer = Layer(W, b, σ)
		layer(x)
	end
end

# ╔═╡ 22354a8a-500a-453f-90e4-12fb941e88d8
let
	begin
		struct MyFunctionWrapper{F}
			f::F
		end
	
		(mfw::MyFunctionWrapper)(args...; kwargs...) = mfw.f(args...; kwargs...)
	end;
	n, m = 3, 4
	x = rand(n)
	W = rand(m, n)
	b = rand(m)
	σ = tanh
	W_tricky = BigFloat.(W)
	b_tricky = BigFloat.(b)
	σ_tricky = MyFunctionWrapper(σ)

	if @isdefined Layer
		try
			layer = Layer(W, b, σ)
			Layer(W_tricky, b, σ)
			Layer(W, b_tricky, σ)
			Layer(W, b, σ_tricky)
			try
				Layer(b, W, σ)
				almost(md"The `Layer` constructor should only accept a matrix for `W` and a vector for `b`")
			catch e
				try
					Layer(Complex.(W), b, σ)
					almost(md"The `Layer` constructor should only accept real elements for the matrix `W` and the vector `b`")
				catch e
					try
						output = layer(x)
						check = output ≈ σ.(W * x + b)
						if check
							correct()
						else
							almost(md"Calling the `Layer` returns an incorrect result")
						end
					catch e
						almost(md"Calling the `Layer` throws an error")
					end
				end
			end
		catch e
			almost(md"The `Layer` constructor should accept generic element types for `W` and `b`, as well as a generic callable for `σ` (not just a function)")
		end
	else
		almost(md"You need to define `Layer`")
	end
end

# ╔═╡ e6002e59-96c2-44f1-aa82-a28d5fd23c4a
md"""
!!! danger "Task 2.6.2"
	Test the type-stability of your `Layer`.
"""

# ╔═╡ 281cbd26-3570-4fbe-9b7e-9e86a51c878d
let
	n, m = 3, 4
	
	W = rand(m, n)
	b = rand(m)
	σ = tanh
	layer = Layer(W, b, σ)
	
	x = rand(n)
	@code_warntype layer(x)
end

# ╔═╡ ab5d49c1-518d-4e36-82b3-52b1e481e525
let
	n, m = 3, 4
	W = rand(m, n)
	b = rand(m)
	σ = tanh

	if @isdefined Layer
		try
			layer = Layer(W, b, σ)
			if all(isconcretetype, fieldtypes(typeof(layer)))
				correct()
			else
				almost(md"The `Layer` struct has abstract field types")
			end
		catch e
			almost(md"The `Layer` constructor throws an error")
		end
	else
		almost(md"You need to define `Layer`")
	end
end

# ╔═╡ d080e107-48dd-419c-9e45-f007562d2ffa
md"""
A feedforward neural network is just a sequence of layers applied one after the other.
"""

# ╔═╡ 31edb851-96cd-4fe1-9873-52f6e4a08478
md"""
!!! danger "Task 2.6.3"
	Implement a callable struct `Network` with a single field `layers`, which is a vector whose elements are all `Layer`s
	Whenever it is called, it should apply each layer sequentially.
"""

# ╔═╡ 8147ab4f-a671-445b-8974-cfcead7e8d08
begin
	struct Network{L<:Layer}
		layers::Vector{L}
	end
	
	function (network::Network)(x)
		y = x
		for layer in network.layers
			y = layer(y)
		end
		return y
	end
end

# ╔═╡ fac4c3fc-9437-4110-911b-0643c2ebd51f
let
	if @isdefined Network
		n, m1, m2 = 3, 4, 5
		W1 = rand(m1, n)
		b1 = rand(m1)
		W2 = rand(m2, m1)
		b2 = rand(m2)
		σ = tanh
		x = rand(n)

		layer1 = Layer(W1, b1, σ)
		layer2 = Layer(W2, b2, σ)
		network = Network([layer1, layer2])
		network(x)
	end
end

# ╔═╡ dc7196ee-3b1b-4be4-aabe-17cb2fcf6560
let
	n, m1, m2 = 3, 4, 5
	W1 = rand(m1, n)
	b1 = rand(m1)
	W2 = rand(m2, m1)
	b2 = rand(m2)
	σ = tanh
	x = rand(n)

	if (@isdefined Layer) && (@isdefined Network)
		try
			layer1 = Layer(W1, b1, σ)
			layer2 = Layer(W2, b2, σ)
			try
				network = Network([layer1, layer2])
				try
					y = network(x)
					check = y ≈ σ.(W2 * σ.(W1 * x + b1) + b2)
					if check
						correct()
					else
						almost(md"Calling the `Network` returns an incorrect result")
					end
				catch e
					almost(md"Calling the `Network` throws an error")
				end
			catch e
				almost(md"The `Network` constructor throws an error")
			end
		catch e
			almost(md"The `Layer` constructor throws an error")
		end
	else
		almost(md"You need to define `Layer` and `Network`")
	end
end

# ╔═╡ 342fd9ce-3420-4094-89bb-59879aba9013
md"""
Why is it so important to use parametric types?
For one thing, if you remember HW2, it is essential for forward-mode automatic differentiation.
And if you coded your `Layer` properly, the following snippet will work just fine.
"""

# ╔═╡ 9733b693-0745-4492-a2d9-af8f764e3771
function loss(W, x)
	b = zeros(size(W, 1))
	σ = tanh
	layer = Layer(W, b, σ)
	y = layer(x)
	ℓ = sum(abs2, y)
	return ℓ
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
ImageIO = "82e4d734-157c-48bb-816b-45c225c6df19"
ImageShow = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BenchmarkTools = "~1.3.2"
Colors = "~0.12.10"
FileIO = "~1.16.1"
ImageIO = "~0.6.7"
ImageShow = "~0.3.8"
Plots = "~1.39.0"
PlutoTeachingTools = "~0.2.13"
PlutoUI = "~0.7.52"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "f34640c8f46e18e495488ad59cbd4a9daf6fef5a"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "76289dc51920fdc6e0013c872ba9551d54961c24"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e30f2f4e20f7f186dc36529910beaedc60cfa644"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.16.0"

[[deps.ChangesOfVariables]]
deps = ["InverseFunctions", "LinearAlgebra", "Test"]
git-tree-sha1 = "2fba81a302a7be671aefe194f0525ef231104e7f"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.8"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "a1296f0fe01a4c3f9bf0dc2934efbf4416f5db31"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "02aa26a4cf76381be7f66e020a3eddeb27b0a092"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.2"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "67c1f244b991cad9b0aa4b7540fb758c2488b129"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.24.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "8a62af3e248a8c4bad6b32cbbe663ae02275e32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "5372dbbf8f0bdb8c700db5367132925c0771ef7e"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.2.1"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

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

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "299dc33549f68299137e51e6d49a13b5b1da9673"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

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

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "d8db6a5a2fe1381c1ea4ef2cab7c69c2de7f9ea0"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.1+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "27442171f28c952804dede8ff72828a96f2bfc1f"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.10"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "025d171a2847f616becc0f84c8dc62fe18f0f6dd"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.10+0"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "e94c92c7bf4819685eb80186d51c43e71d4afa17"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.76.5+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "5eab648309e2e060198b45820af1a37182de3cce"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

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
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "2e4520d67b0cef90865b3ef727594d2a58e0e1f8"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.11"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "fc5d1d3443a124fde6e92d0260cd9e064eba69f8"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.1"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "bca20b2f5d00c4fbc192c3212da8fa79f4688009"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.7"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "355e2b974f2e3212a75dfb60519de21361ad3cb7"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.9"

[[deps.ImageShow]]
deps = ["Base64", "ColorSchemes", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "3b5344bcdbdc11ad58f3b1956709b5b9345355de"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.8"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "3d09a9f60edf77f8a4d99f9e015e8fbf9989605d"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.7+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "8e59ea773deee525c99a8018409f64f19fb719e6"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.7"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "68772f49f54b479fa88ace904f6127f0a3bb2e46"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.12"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterTools]]
git-tree-sha1 = "4ced6667f9974fc5c5943fa5e2ef1ca43ea9e450"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.8.0"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "d65930fa2bc96b07d7691c652d701dcbe7d9cf0b"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "81dc6aefcbe7421bd62cb6ca0e700779330acff8"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.25"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f689897ccbe049adb19a065c495e75f372ecd42b"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "15.0.4+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "f428ae552340899a935973270b8d98e5a31c49fe"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.1"

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

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "2da088d113af58221c52828a80378e16be7d037a"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.5.1+1"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "7d6dd4e9212aebaeed356de34ccf262a3cd415aa"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.26"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "0d097476b6c381ab7906460ef1ef1638fbce1d91"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.2"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "60168780555f3e663c536500aa790b6368adc02a"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.3.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.MappedArrays]]
git-tree-sha1 = "2dab0221fe2b0f2cb6754eaa743cc266339f527e"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.2"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "2ac17d29c523ce1cd38e27785a7d23024853a4bb"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.10"

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
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "a4ca623df1ae99d09bc9868b008262d0c0ac1e4f"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.4+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a12e56c72edee3ce6b96667745e6cbbe5498f200"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.23+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "9b02b27ac477cad98114584ff964e3052f656a0f"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.0"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "64779bc4c9784fee475689a1752ef4d5747c5e87"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.42.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "f92e1315dadf8c46561fb9396e525f7200cdc227"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.5"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "ccee59c6e48e6f2edf8a5b64dc817b6729f99eb5"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.39.0"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "8f5fa7056e6dcfb23ac5211de38e6c03f6367794"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.6"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "542de5acb35585afcf202a6d3361b430bc1c3fbd"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.13"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "00099623ffee15972c16111bcf84c58a0051257c"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.9.0"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "7c29f0e8c575428bd84dc3c72ece5178caa67336"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.5.2+2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "609c26951d80551620241c3d7090c71a73da75ab"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.6"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "30449ee12237627992a99d5e30ae63e4d78cd24a"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "2da10356e31327c7096832eb9cd86307a50b1eb6"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "1d77abd07f617c4868c33d4f5b9e1dbb2643c9cf"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

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
git-tree-sha1 = "b7dc44cb005a7ef743b8fe98970afef003efdce7"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.6"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "b7a5e99f24892b6824a954199a45e9ffcc1c70f0"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["ConstructionBase", "Dates", "InverseFunctions", "LinearAlgebra", "Random"]
git-tree-sha1 = "a72d22c7e13fe2de562feda8645aa134712a87ee"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.17.0"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "e2d817cc500e960fdbafcf988ac8436ba3208bfd"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.3"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "04a51d15436a572301b5abbb9d099713327e9fc4"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.4+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cf2c7de82431ca6f39250d2fc4aacd0daa1675c0"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.4.4+0"

[[deps.Xorg_libICE_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "e5becd4411063bdcac16be8b66fc2f9f6f1e8fe5"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.0.10+1"

[[deps.Xorg_libSM_jll]]
deps = ["Libdl", "Pkg", "Xorg_libICE_jll"]
git-tree-sha1 = "4a9d9e4c180e1e8119b5ffc224a7b59d3a7f7e18"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.3+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "b4bfde5d5b652e22b9c790ad00af08b6d042b97d"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.15.0+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "04341cb870f29dcd5e39055f895c39d016e18ccd"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.4+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "49ce682769cd5de6c72dcf1b94ed7790cd08974c"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.5+0"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "gperf_jll"]
git-tree-sha1 = "431b678a28ebb559d224c0b6b6d01afce87c51ba"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.9+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.gperf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3516a5630f741c9eecb3720b1ec9d8edc3ecc033"
uuid = "1a1c6b14-54f6-533d-8383-74cd7377aa70"
version = "3.1.1+0"

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

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "141fe65dc3efabb0b1d5ba74e91f6ad26f84cc22"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "ad50e5b90f222cfe78aa3d5183a20a12de1322ce"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.18.0+0"

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

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "814e154bdb7be91d78b6802843f76b6ece642f11"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.6+0"

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

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╠═d20423a3-a6d8-4b7a-83c7-f1539fcc4d72
# ╠═00992802-9ead-466b-8b01-bcaf0614b0c6
# ╟─1896271c-e5bf-428c-bc3e-7780e71a065f
# ╠═fcafb864-249b-11ed-3b73-774e1742704a
# ╟─eee70c65-94b8-4f3d-a187-bbafb04b8eff
# ╟─9f1c224c-561e-4071-a909-0c951b9e3542
# ╟─6ae05ccb-c386-4139-817c-85959a20a4de
# ╟─d0634f27-ba12-4c53-be66-6d2f7bf74808
# ╟─a5d63fcc-9d84-4912-b6fe-3ddc937b3022
# ╟─1b8b2a32-21fd-47e0-9c12-7a71e66fab4c
# ╠═321c6dc8-9d87-47da-88b3-a41b55b179ff
# ╟─d931270d-1ceb-474f-b04e-0185595a4b5a
# ╠═7dbd7cfd-5c52-4591-b6ba-eba7f3076a45
# ╟─72ac44a7-7c18-4d0e-85e4-9ca9cb5173a8
# ╟─d20b68c4-3091-4e49-8873-199672ed2695
# ╠═74a44465-7332-45b0-91c4-2ae5ed658160
# ╟─ed8a218f-287c-425b-a6b6-793be7ad1a7b
# ╟─fc1c3e85-b1af-4cbb-a8fe-597174bea4d4
# ╟─037d04d4-f5f2-4b77-80ed-b799c1ea9b77
# ╠═87081f51-7c44-4365-b412-7b34ed2b3191
# ╟─d4619cdf-f902-4a8e-8e60-b8606aee40d2
# ╠═2e9ddef4-688c-4623-8b58-578e7931204b
# ╠═3a99de95-3312-47f7-b46e-545aa75b82bf
# ╠═9b143e5c-04b6-4306-87c6-fc818747c20d
# ╠═cb4ee69a-c992-45ae-b7a2-0cbc318a090e
# ╠═9b6b6596-7680-4864-9395-10fbf69ec0ae
# ╠═c137d356-f552-4e3e-92b7-a9ffc0df0266
# ╟─9e2898c5-5c90-4fca-8c60-1fc31db81ead
# ╠═f43cde45-9c12-430d-b75b-70a2c476db5b
# ╠═ed80972f-648a-4975-b414-2e644565dccb
# ╠═a33536e5-f9de-41d1-bd17-0a8dd8d577dc
# ╟─1dbbf479-1707-4dd0-90c8-394690fbac91
# ╟─c4063845-c70a-47ef-a4f7-ef2b3ea0f0d8
# ╟─3d748f13-ef9c-4899-99d3-16743f0e2f5a
# ╠═730ae9dc-34bf-4472-ae32-36fe10c54175
# ╠═d0d2c56e-297d-4d35-afb7-bfd366815a95
# ╠═0eabf795-a9c5-4aa1-8282-e5e22b631c4d
# ╠═57e16f0a-c0bc-4727-9315-701328989762
# ╠═ab71225e-3d0e-4a11-a5de-6b1eea4048eb
# ╠═ecebb7eb-000f-418d-bfb8-acb66b06c171
# ╟─7b2dbb37-9523-4150-bf23-4803ef0f31f1
# ╠═ad26c7d9-f457-4dc0-8a70-8bac4b3c3a10
# ╟─b6ebf9ce-0a8f-4f67-b324-3aa4da967d46
# ╟─d241fcec-3266-4175-abd5-7d26128dc923
# ╟─3eb3545e-d48a-41d7-ac31-b9b6d1b22af9
# ╠═58aed749-468e-477d-98c7-3a7a0c9ea7a0
# ╟─6893ced3-012f-4dc2-8e1c-2a292bfe067e
# ╟─80c63240-d4e8-4a4b-b34c-a14b064a75a5
# ╠═9370b300-25a9-4342-803d-c2f1ba0d2b90
# ╟─595e20f1-150a-4224-aee5-607882486887
# ╠═136dbf04-77a0-4c14-868d-73a92a9028b5
# ╟─390c7fe7-a27c-4f21-a8dc-c8cf19372857
# ╠═5963a5b6-7939-49f5-9f5e-d1984afd8d79
# ╟─520f5b7e-d5dd-4954-93a3-39e63d5d2a1b
# ╟─581e4013-692a-4a66-b210-b4db92112187
# ╠═eb29c4ee-2cd2-4c51-a1c3-954b5745b9a9
# ╠═5f605953-9216-41fc-b935-bb6c2ca5414e
# ╠═35fe8041-58ba-419e-a9d2-f9fc97d13cce
# ╟─7b003215-ce5d-4063-9eb0-c05affd1d15e
# ╟─ffee9abf-d6ed-411e-bef7-15d52c084d3e
# ╟─2016d37b-ab63-4956-8fe7-de7eaadfb29f
# ╟─cf769229-9766-40d5-a8e0-1b7cb0b8b16e
# ╟─3903ec25-8077-49e2-a711-2500defec7b5
# ╠═a4c0fff3-b4fe-4c48-8680-c12bbf4f68f3
# ╟─3d31d6ab-d466-4581-9ade-a8a541a03319
# ╠═c3a05713-b023-4f8f-9eb2-98dc818de3ca
# ╟─88c8da1c-8cd8-4dad-961e-edf035790286
# ╟─fb577ace-d7d1-4ac9-ad47-57d28528c243
# ╠═a2fe0244-361f-4154-af76-a56bd7928880
# ╠═2d0b80cb-01b4-429c-beed-c2c0d6f8626e
# ╟─ccc1dd94-a1db-4504-8d27-5fbf577cee30
# ╟─e2f9f8d1-0d83-415e-b459-4c6e36cc9ddf
# ╠═f899ed08-4315-4c17-8792-84ad0cae631b
# ╟─28737ee7-6939-4830-95e3-fc08b6dcf1a4
# ╟─24e23eb0-9341-4249-afe1-c6d94c57478e
# ╠═f0705b81-3df4-4145-9de5-8a4d738f6398
# ╠═f5604cbe-0348-475c-8e0f-43b7bb213b36
# ╠═a4eedc3b-0808-42ec-88b0-d710497fcd68
# ╠═7df61a7e-b8d0-4024-8dce-239cf0d0edd8
# ╟─eaea15b2-5918-4fc0-b44a-3cb0c085fa67
# ╟─8fc13f81-3e49-4b98-8592-fb9f24eda900
# ╠═cf737824-4aa3-409b-a914-be606c9668a0
# ╟─79b384b1-8393-4c8c-84e4-6c1c729c53eb
# ╠═afdf5d1e-d19d-486e-ab4d-167d74975e5e
# ╠═996f35f9-8510-4cee-b923-1c11ef7244af
# ╠═3d800a03-06fc-46e4-b0d6-d123200fc26f
# ╠═d11432fc-cdee-4364-8159-49ce25d6c7e5
# ╠═d73978e5-ec24-4d71-82ca-184c76f00b74
# ╠═4abde394-998e-4ff2-ad27-0f86a169d841
# ╟─023a75a3-a7a6-4e2d-911b-8a5c54d86e80
# ╟─87cdb6d3-cfa6-4564-8ea4-e2f202d89eca
# ╟─d5ba5a13-9242-480c-94d7-e681e0ecdf72
# ╠═117ff067-08ae-4134-8d23-ef28d31a7b8f
# ╟─e65bfd90-83c6-4c93-9f7f-aa8d41c01531
# ╠═172d0f37-5214-4e73-8635-8bfe85011f4a
# ╟─86d0af15-ccf4-4254-a686-a6ace39a7a74
# ╠═22633b0a-33c5-4b7d-98b0-42663adc1631
# ╟─4885f35e-1875-4dca-8bad-f8ae94cb98b3
# ╟─c64086a9-b749-4a5d-8665-0085ae4fb64e
# ╠═6daea6c1-6eb4-4117-8e11-63e9913792e3
# ╟─c491ca01-5a0b-4f91-825c-67f597aa788a
# ╟─d96068be-4ac9-4ff9-ae3e-4807df555a42
# ╠═2eb828db-1008-4551-819d-60ec0aa8eb7a
# ╠═a637f11c-bd0a-4a87-a1b9-52fd43eb9fcc
# ╠═c619533d-6e4c-4aae-b3a7-099f578f7b7d
# ╠═076c200b-d1cf-4c17-91d3-84d447271560
# ╠═5da5d4f3-a96c-4025-adf2-47978f441519
# ╟─916540e4-d354-436e-8c79-a8e2aff4f591
# ╟─9c41f013-38f4-41b4-a2c9-90a2f6f08356
# ╟─e5bf5d32-2597-42d1-b9a6-eba666fe48d5
# ╠═f911d885-cc82-4eff-bac2-310e49923c63
# ╟─f7b8330e-5897-4b71-a9aa-64838cf2a9bd
# ╟─f2ea1753-e3d8-42e0-a495-5fd22abeb944
# ╠═b66b0c70-fdd1-4d43-8adf-807f59055f8c
# ╠═e227d7f2-ddb7-415e-9b9e-e0efd8945ca0
# ╠═72f838ef-ecbd-412e-9ea6-88fc48fe8da6
# ╟─d8058473-2ffa-4ae4-8699-435bdf7d6f08
# ╟─ebddaba7-792a-4546-9739-df271df2a880
# ╠═52121c38-fe60-4c52-8c43-40970fc8d69c
# ╠═04de7b1e-ea7c-438d-b16a-8e758bb40a70
# ╠═4ea66307-dbfc-45d2-894c-fbd89f1957ce
# ╟─8d558109-3d41-4ed1-b855-2d7ce7f29369
# ╠═7f97374d-04d9-4241-b166-aa5a6e052c66
# ╠═2b34aa16-107c-4e17-88bb-6dfc6e2b4881
# ╟─51103ee4-b68b-48cf-addc-8905dda40747
# ╠═012dd868-8815-4c3e-9adb-1ce854081bac
# ╟─dd38f9f9-0da9-4039-b1bd-ed914d434c7f
# ╠═de109133-313f-4235-a885-eb8ca55cde67
# ╠═176c6971-483f-408c-abc2-994546a5f57f
# ╠═876837a1-06b7-4b86-829d-4edeae166dc3
# ╠═fb8696b8-4d1b-49cf-8e25-703287d2b3f1
# ╠═97541230-5515-4b78-b211-2a01a2d9ed83
# ╠═e3478b55-7100-49c8-809f-4a8bf15071f3
# ╟─d4324265-e4af-4f00-ab00-d65976d8d583
# ╠═8e96478a-4dd4-4eab-bda3-e19e60adf332
# ╟─bd90221c-c590-4d36-bba4-6b0b2e4f2453
# ╟─893c6a98-fc54-47de-b514-a6ac0722c0aa
# ╟─1910d57c-853a-4f31-b3e6-0921d775ff8a
# ╟─d900e981-36d8-4a3c-a1bd-5809ee6e7c64
# ╟─7c362af1-cc1a-47fc-b3a1-252a891849e5
# ╟─66e2042d-aedc-41cb-91c0-b364e014f7f0
# ╟─8b5e86e7-0f98-48b5-969d-e48daddf10cb
# ╟─04c69dcc-534a-4c52-a8a3-5a65fb5f0191
# ╟─0e502851-fa10-4d2c-aaf3-e47ca4bf4bcf
# ╟─42631084-34ec-4482-9e10-84ff85067b93
# ╟─82751f0f-87fd-4110-9e86-0d0b1ad5cd36
# ╟─a3e88d8f-72dd-495a-b61b-a969cac7e55a
# ╟─a25c0f95-7c94-449f-a6c2-8acc649d3307
# ╟─3117a299-06af-47d4-8fb3-3ce394b71050
# ╟─90c54b0f-0813-4813-8b8c-913a904817dd
# ╟─2b8f9fce-639a-432c-986e-956297743f14
# ╟─5794e6ef-ccc0-448d-a881-328b057e0b1c
# ╟─efea9df5-8891-401a-a454-87151c79193f
# ╟─39f97748-50ce-4f77-a28a-f21eb23173f5
# ╟─c169b341-a099-42c2-8137-2c197afe00bd
# ╟─e833bbca-3d88-4467-ac28-03d1d45e10ab
# ╟─90e3c840-1c83-4681-89b6-47290d43d30d
# ╠═ebafb690-9677-4342-9ca4-8e456ab0b3fb
# ╠═a8a29bc5-9b80-48f7-a98b-3d57666ed8d4
# ╟─44d87f80-a97b-4901-82b6-6f55900d3649
# ╠═9b03fbf6-945b-4662-b270-4eab5229940d
# ╟─56a31847-29c9-4ed2-8ade-a7139217fa20
# ╠═8a1dddcc-b448-421e-94b4-020c6adbef2d
# ╟─e3584c01-d769-4fc1-a926-4ae6f8fca74c
# ╟─5b4a4e16-af38-40a7-b9a2-303952b2060f
# ╟─2f2d3b08-b52d-464c-a840-7956601c4580
# ╠═c28bc501-72e9-4ce0-9e18-d4261df1d4c1
# ╟─acf5df55-21c4-44e0-a5ff-b578e4859b0b
# ╠═6494852e-4e0b-4f3d-8aba-1835e5d89862
# ╠═00679b2f-f1f6-42a2-bbf2-d68b5344f858
# ╟─45b0f116-fb0a-4b71-b2a9-8ccf59cea3ce
# ╟─8a38a25e-9124-4f56-9e81-cfd86d655b0a
# ╠═43faaa6c-5798-4da7-9da0-86e6e5a23c2d
# ╟─60d59a6a-ccce-4d96-b651-7a5aebb948a0
# ╠═eac42582-056f-4040-ae37-1f189e45dcb2
# ╠═c0a81310-0e39-4c51-806c-18ab46bd1410
# ╟─ff7b2edc-9500-4e2f-acaa-bc18297348c0
# ╟─582f6bd8-2b83-4a6d-99f9-ba27961f35c5
# ╟─059ca660-a954-4e9d-8ebc-6812ad73325f
# ╠═52447e60-2d11-42b9-b99b-947f3fdcb17e
# ╠═8f025763-0f78-4d6b-a361-04e0634f3d5a
# ╟─077c7c21-b921-444f-8ba4-a5bec28254aa
# ╟─0b343ca3-73a0-472b-9af6-d523b38e2e14
# ╟─6953302e-6b11-4561-aa3d-1d9f93f1c506
# ╟─4b0fa9b0-51b9-4997-932c-074c122fc2a3
# ╠═d4a1731d-4b9f-4650-bda4-c9d3aa0e9263
# ╠═81a0bf4a-ad00-4adc-9d16-503a6f75f115
# ╟─cf15fa7c-50a9-4b72-b7ab-00bfa5a9ce0d
# ╠═d93e006f-3727-4197-a87c-4d01fd08b1fb
# ╟─f00a45b5-99db-4902-bc90-2e92de510b52
# ╠═aa52a3a9-2ddc-4fcf-8235-1b5c926fa93f
# ╟─ebfaaad3-be48-4f36-8502-ae969b574e60
# ╟─ee57c162-fc0c-497f-bca7-c5135e77ebee
# ╠═91498fc6-90c5-433b-ba02-cce4de287b00
# ╟─a5541b7c-6ecc-410f-817b-eead32f984ee
# ╠═66e38fca-0013-4e59-bc21-3b29958289e2
# ╟─a55d3b23-6ebd-4700-bd50-84d96df1c87e
# ╟─4e20e7c4-8303-4d10-b232-886fe824b27a
# ╟─401ff0a6-533f-4c2f-a200-969ac4871dc2
# ╠═27472118-bdb0-4a8b-b604-44da89f49216
# ╟─c34522a6-dc5e-48c8-8bf8-5b75810611e6
# ╟─88837b59-7771-40e9-86da-8ffa8ef01c2e
# ╟─e6214561-9871-4ea7-b215-da33f6ffbe18
# ╟─9df6539e-ef87-4426-bb23-4fc40489d0bb
# ╟─5ff6ece2-801c-4769-8e70-e437fa44ec6c
# ╠═c6a338e8-f37e-4c74-8953-b7d9607a96b5
# ╠═565340e2-246f-453e-b478-8916a2f83e3f
# ╟─20e92ed7-c7f9-44d6-88d1-3e16e1dfec1e
# ╠═e5702ada-5eff-425b-92db-3dd6033ea221
# ╟─9b6d1a58-6fd6-40e1-866c-6b0351afb053
# ╠═1e8e6334-b6d7-4305-984a-4f8143321da4
# ╟─b592618c-ddca-40fa-87b2-eb783599f0e9
# ╠═36b54358-c4f4-4e63-9762-fd8521ce5657
# ╟─25cb033e-e9cc-4338-8844-501ed262c2ee
# ╠═7fbed24e-e1de-41f4-b8f1-2b5b69d48d9c
# ╠═5e76418d-e1ac-4d4d-8678-a65e88c181c9
# ╟─25920fa9-e213-42dc-9844-309d51797607
# ╠═03d1132e-5e66-4fbb-87c6-9ee8dedf903d
# ╟─1c4034a4-ab54-4e52-8a62-39a051640956
# ╠═ba689c80-cbf9-4a67-ab26-15ac66239683
# ╠═28cef3b8-6e9a-4720-a00d-d4ae13cc14be
# ╟─f67e5107-c4ca-4be3-b94b-b65439df057d
# ╠═a316a8ad-1644-49b6-9fb5-1b0d23a62cd3
# ╠═9a2f1673-b6d1-4804-9fa5-f7c7893a3560
# ╟─42896a90-ccb2-4d21-93b3-72544d5ee8ac
# ╟─b4cc74e2-5c3a-4ac8-af3b-1a52970272c0
# ╟─5d92f230-e2f5-41e9-bf07-4234dabc3355
# ╟─1103e116-e04c-486f-822e-55b5d9de7224
# ╠═558cfd36-57ac-4c0f-9040-db2863220e6e
# ╟─9fd78cf8-c1dd-46b6-8e5d-f81ad22ac3ed
# ╟─7c4ce606-3fad-4632-af93-8bcd62b757ca
# ╟─06766592-adc9-444e-99b8-9d3b5d3378db
# ╠═0159f8a1-74f3-4ffe-8eb4-079c48ec4758
# ╟─15c7d609-bcea-4b78-9864-eed171371a39
# ╠═486639b6-4c15-4f64-ad9b-ad66220215a2
# ╟─dfdf8e82-307a-4fa9-b0ea-e9c0fe7d6a8a
# ╠═3e44ef15-9ca9-4d2e-927c-ed38241e7b12
# ╠═b5a900e9-db14-4527-a6e9-13fb69ca39ca
# ╠═cf8a04df-1f9c-43e2-810d-c1a7ee2f0f34
# ╠═b70abc1e-be9c-42d1-b84f-7edd9dafe5cc
# ╠═6d700e2e-7175-4c80-9d34-7fa020621705
# ╠═43b0bc76-d86b-439f-84e7-6f0e7fdd3b40
# ╠═c6006ac5-8f2c-450b-b554-b0a261316128
# ╟─14cd3db3-c158-48b9-af2e-11a0f8a8bbf5
# ╟─859c6786-8561-4a3e-b63d-c6377d960718
# ╠═73b4c541-ce70-479c-9e85-ed22c7a809f9
# ╠═c1cc7207-4604-4211-a2dc-035cc43d0905
# ╠═ca209acb-8c5c-43ea-9276-1cd9dcc15d61
# ╠═6a678f27-6962-4e3a-a382-caa42be97539
# ╠═1fbf6cfa-953d-43c0-a49b-bb264d737853
# ╠═ca49bc12-17e1-44b2-9918-47495f8241b8
# ╟─78116d52-d11f-4c6d-b8a5-ebb8e9efa7c8
# ╟─a4f30ea4-4a03-4713-bb87-cade80f1d8ca
# ╟─9057a4de-c631-4e37-9f38-bc0049f4844d
# ╠═b7835ff2-d125-4f4f-bd03-34d901a8b103
# ╠═4ddbd792-fe9b-4ec0-b67c-c985a75b3854
# ╟─22354a8a-500a-453f-90e4-12fb941e88d8
# ╟─e6002e59-96c2-44f1-aa82-a28d5fd23c4a
# ╠═281cbd26-3570-4fbe-9b7e-9e86a51c878d
# ╟─ab5d49c1-518d-4e36-82b3-52b1e481e525
# ╟─d080e107-48dd-419c-9e45-f007562d2ffa
# ╟─31edb851-96cd-4fe1-9873-52f6e4a08478
# ╠═8147ab4f-a671-445b-8974-cfcead7e8d08
# ╠═fac4c3fc-9437-4110-911b-0643c2ebd51f
# ╟─dc7196ee-3b1b-4be4-aabe-17cb2fcf6560
# ╟─342fd9ce-3420-4094-89bb-59879aba9013
# ╠═9733b693-0745-4492-a2d9-af8f764e3771
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
