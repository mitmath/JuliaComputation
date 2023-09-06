### A Pluto.jl notebook ###
# v0.19.11

#> [frontmatter]
#> title = "HW1a - Pokémon"
#> date = "2022-09-15"

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
Homework 1a of the MIT Course [_Julia: solving real-world problems with computation_](https://github.com/mitmath/JuliaComputation)

Release date: Thursday, Sep 15, 2022 (version 1)

**Due date: Thursday, Sep 22, 2022 (11:59pm EST)**

Submission by: Jazzy Doe (jazz@mit.edu)
"""

# ╔═╡ 00992802-9ead-466b-8b01-bcaf0614b0c6
student = (name = "Jazzy Doe", kerberos_id = "jazz")

# ╔═╡ 1896271c-e5bf-428c-bc3e-7780e71a065f
md"""
# Pokémon - _gotta dispatch 'em all_
"""

# ╔═╡ eee70c65-94b8-4f3d-a187-bbafb04b8eff
md"""
Show TOC $(@bind show_toc CheckBox(default=true))
"""

# ╔═╡ 9f1c224c-561e-4071-a909-0c951b9e3542
md"""
# A. Implementing Pokémon behavior
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
## Pokémon families
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
> Task: Define new structures for Eevee (from the `Normal` family) and its evolutions Flareon, Vaporeon, Leafeon and Jolteon (respectively from the `Fire`, `Water`, `Grass` and `Electric` families).
"""

# ╔═╡ 87081f51-7c44-4365-b412-7b34ed2b3191


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
## Interlude: multiple dispatch
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
Here is an example inspired by the notebook on [abstraction](https://mit-c25.netlify.app/notebooks/1_abstraction) that you saw in the first class.
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
## Attack mechanism
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

# ╔═╡ eb29c4ee-2cd2-4c51-a1c3-954b5745b9a9
attack(pikachu, pikachu)  # Electric on Electric: not very effective

# ╔═╡ 5f605953-9216-41fc-b935-bb6c2ca5414e
attack(pikachu, vaporeon)  # Electric on Water: super effective

# ╔═╡ 35fe8041-58ba-419e-a9d2-f9fc97d13cce
attack(vaporeon, pikachu)  # Water on Electric: normally effective

# ╔═╡ 7b003215-ce5d-4063-9eb0-c05affd1d15e
md"""
# B. Extending Pokémon behavior
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
## Adding a Pokémon family
"""

# ╔═╡ cf769229-9766-40d5-a8e0-1b7cb0b8b16e
md"""
Professor Edelman wants to play Pokémon using Julia.
But to do that, he wants _you_ to implement the new `Corgi` family, full of legendary creatures with untold abilities.
"""

# ╔═╡ 3903ec25-8077-49e2-a711-2500defec7b5
md"""
> Task: Define an abstract subtype of `Pokemon` named `Corgi`.
"""

# ╔═╡ a4c0fff3-b4fe-4c48-8680-c12bbf4f68f3


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
> Task: Extend the fight mechanism by defining appropriate methods for attackers of type `Corgi`.
"""

# ╔═╡ a2fe0244-361f-4154-af76-a56bd7928880


# ╔═╡ ccc1dd94-a1db-4504-8d27-5fbf577cee30
md"""
Among the `Corgi` family, the one called `Philip` is by far the most powerful entity.
Unlike the other Pokémon we have encountered, `Philip` has a reserve of life points, which makes him more resilient against attacks.
"""

# ╔═╡ e2f9f8d1-0d83-415e-b459-4c6e36cc9ddf
md"""
> Task: Define a new structure for `Philip` with a single attribute named `life`, of type `Int`. Add an inner constructor which takes `life` as an argument, and another one which sets `life` to be a random number between $1$ and $5$.
"""

# ╔═╡ f899ed08-4315-4c17-8792-84ad0cae631b


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
> Task: Extend the fight mechanism by defining appropriate methods for defenders of type `Philip`.
"""

# ╔═╡ cf737824-4aa3-409b-a914-be606c9668a0


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
## Adding a friendship mechanism
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
> Task: Extend the friendship mechanism to account for the fact that `Philip` is friends with everyone.
"""

# ╔═╡ 6daea6c1-6eb4-4117-8e11-63e9913792e3


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
# C. Grid world simulation
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
## Initialization and evolution rules
"""

# ╔═╡ f2ea1753-e3d8-42e0-a495-5fd22abeb944
md"""
> Task: Define a function `new_grid(pokemon_set; n, m)` that creates a matrix of Pokémon of size `n × m` and fills it with random picks from the set `pokemon_set`.
"""

# ╔═╡ b66b0c70-fdd1-4d43-8adf-807f59055f8c


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
> Task: Define a function `step!(grid)` which applies one step of fight simulation to a matrix of Pokémon, modifying this matrix in the process.
"""

# ╔═╡ 52121c38-fe60-4c52-8c43-40970fc8d69c


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
> Task: Implement a new function called `step_consider_friends!` where the attack doesn't happen if the attacker is friends with the defender.
> What do you observe?
"""

# ╔═╡ 7f97374d-04d9-4241-b166-aa5a6e052c66


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
## Experiments
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
> Task: Play around with the previous simulations.
> Increase the duration, change the grid size, the set of Pokémon, the life of the `Philip` you include.
> Comment on what you observe.
"""

# ╔═╡ 8e96478a-4dd4-4eab-bda3-e19e60adf332


# ╔═╡ bd90221c-c590-4d36-bba4-6b0b2e4f2453
md"""
# D. Appendix
"""

# ╔═╡ 1910d57c-853a-4f31-b3e6-0921d775ff8a
if show_toc; TableOfContents(); end

# ╔═╡ d900e981-36d8-4a3c-a1bd-5809ee6e7c64
chart_path = download("https://img.pokemondb.net/images/typechart.png")

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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
ImageIO = "82e4d734-157c-48bb-816b-45c225c6df19"
ImageShow = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
Colors = "~0.12.8"
FileIO = "~1.15.0"
ImageIO = "~0.6.6"
ImageShow = "~0.3.6"
Plots = "~1.32.1"
PlutoTeachingTools = "~0.1.7"
PlutoUI = "~0.7.39"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.1"
manifest_format = "2.0"
project_hash = "8a8171ae13d8c5a889e267b5e0b17f763675975a"

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

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

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
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "80ca332f6dcb2508adba68f22f551adb2d00a624"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.3"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "1833bda4a027f4b2a1c984baddcf755d77266818"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.1.0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

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

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "5856d3031cdb1f3b2b6340dfdc66b6d9a149a374"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.2.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

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

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "5158c2b41018c5f7eb1470d558127ac274eca0c9"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

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
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "ccd479984c7838684b3ac204b716c89955c76623"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "94f5101b96d2d968ace56f7f2db19d0a5f592e28"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.15.0"

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
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

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
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "cf0a9940f250dc3cb6cc6c6821b4bf8a4286cf9c"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.66.2"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "2d908286d120c584abbe7621756c341707096ba4"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.66.2+0"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "fb28b5dc239d0174d7297310ef7b84a11804dfab"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.0.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "a7a97895780dab1085a97769316aa348830dc991"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.3"

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

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "59ba44e0aa49b87a8c7a8920ec76f8afe87ed502"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.3.3"

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
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "b51bb8cae22c66d0f6357e3bcb6363145ef20835"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.5"

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

[[deps.ImageShow]]
deps = ["Base64", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "b563cf9ae75a635592fc73d3eb78b86220e55bd8"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.6"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "b3364212fb5d870f724876ffcd34dd8ec6d98918"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.7"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

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

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0f960b1404abb0b244c1ece579a0ec78d056a5d1"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.15"

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
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "1a43be956d433b5d0321197150c2f94e16c0aaa0"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.16"

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
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

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

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

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

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "dedbebe234e06e1ddad435f5c6f4b85cd8ce55f7"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.2.2"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "ae6676d5f576ccd21b6789c2cbe2ba24fcc8075d"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.5"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

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

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "e925a64b8585aa9f4e3047b8d2cdc3f0e79fd4e4"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.16"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "0044b23da09b5608b4ecacb4e5e6c6332f833a7e"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.2"

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

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "8162b2f8547bc23876edd0c5181b27702ae58dce"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.0.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "e9cab2c5e3b7be152ad6241d2011718838a99a27"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.32.1"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "0e8bcc235ec8367a8e9648d48325ff00e4b0a545"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.5"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "67c917d383c783aeadd25babad6625b834294b30"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.1.7"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8d1f54886b9037091edf146b517989fc4a09efec"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.39"

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

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "e7eac76a958f8664f2718508435d058168c7953d"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.3"

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

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "dad726963ecea2d8a81e26286f625aee09a91b7c"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.4.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

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
git-tree-sha1 = "dfec37b90740e3b9aa5dc2613892a3fc155c3b42"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.6"

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

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArraysCore", "Tables"]
git-tree-sha1 = "8c6ac65ec9ab781af05b08ff305ddc727c25f680"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.12"

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
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

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
git-tree-sha1 = "ed5d390c7addb70e90fd1eb783dcb9897922cbfa"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.8"

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

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

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

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

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
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

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

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─d20423a3-a6d8-4b7a-83c7-f1539fcc4d72
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
# ╠═1910d57c-853a-4f31-b3e6-0921d775ff8a
# ╠═d900e981-36d8-4a3c-a1bd-5809ee6e7c64
# ╠═7c362af1-cc1a-47fc-b3a1-252a891849e5
# ╠═66e2042d-aedc-41cb-91c0-b364e014f7f0
# ╠═8b5e86e7-0f98-48b5-969d-e48daddf10cb
# ╠═04c69dcc-534a-4c52-a8a3-5a65fb5f0191
# ╠═0e502851-fa10-4d2c-aaf3-e47ca4bf4bcf
# ╠═42631084-34ec-4482-9e10-84ff85067b93
# ╠═82751f0f-87fd-4110-9e86-0d0b1ad5cd36
# ╠═a3e88d8f-72dd-495a-b61b-a969cac7e55a
# ╠═a25c0f95-7c94-449f-a6c2-8acc649d3307
# ╠═3117a299-06af-47d4-8fb3-3ce394b71050
# ╠═90c54b0f-0813-4813-8b8c-913a904817dd
# ╠═2b8f9fce-639a-432c-986e-956297743f14
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
