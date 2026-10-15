### A Pluto.jl notebook ###
# v1.0.3

using Markdown
using InteractiveUtils

# ╔═╡ 92a193f2-7022-488e-9862-55c313f4d11a
using CSV,DataFrames,LinearAlgebra

# ╔═╡ db24490e-7eac-11ea-094e-9d3fc8f22784
md"# Ranking College Football Teams with Linear Algebra

Our goal is to use linear algebra to assign a numeric score to every college FBS football team from the 2022 season, resulting in a full ranking of all 131 teams.

### Importing Data

First, we need to gather the data. Thanks to our friends at Sports-Reference.com, we can find data on all of the games of the 2022 regular season (except Army-Navy) quite easily.

We will input two files: 

The first lists all FBS teams, each team's conference, and their division within that conference, if applicable.

The second lists all games of the 2022 regular season featuring a FBS football team (except Army-Navy), including the teams involved, score, loacation, and week of the season."

# ╔═╡ 2e965e40-01f0-4544-a42b-95b0070d7076
		md"First, let's input the teams and their conference data (as of the 2022 season):"

# ╔═╡ 5f54e11d-161b-4851-aa4c-26ea2b26f2a9
begin
	teamdata = CSV.read("team_data.csv", DataFrame)
end

# ╔═╡ 1351fe53-ebef-4b96-842e-79b85d28a290
md"Next, we'll input all the games:"

# ╔═╡ bd24d02c-7eac-11ea-14ab-95021678e71e
begin
	gamedata = CSV.read("game_data.csv", DataFrame)
end

# ╔═╡ cf72c8a2-7ead-11ea-32b7-d31d5b2dacc2
md"### Cleaning Data

One problem with the data we obtained from Sports-Reference.com is that if a team was ranked in the Associated Press (AP) Top 25, their ranking is listed ahead of their team name. In order to properly associate the game result with the correct team, we will remove these numbers:"

# ╔═╡ cb1fd532-7eac-11ea-307c-ab16b1977819
begin	
	games_clean = gamedata
	teams = teamdata
	forbid = ['(',')','0','1','2','3','4','5','6','7','8','9']	
	for i in 1:size(gamedata)[1]				
		games_clean[i,2] = lstrip(strip(gamedata[i,2],forbid))	
		games_clean[i,5] = lstrip(strip(gamedata[i,5],forbid))		
	end
	for i in 1:size(teamdata)[1]
		teams[i,2] = lstrip(strip(teamdata[i,2],forbid))
	end
	games_clean
end

# ╔═╡ 816ea402-7eae-11ea-2134-fb595cca3068
md"Another issue is that the above table contains all games featuring a FBS football team, when we actually want all games between two FBS teams (though some ranking systems treat all FCS teams as a single opponent). To fix this, we search for all the non-FBS teams:"

# ╔═╡ ae52ad1a-6b0e-4d9c-b32b-0409c3df14ef
begin
	fcs_teams = []
	for i in 1:size(gamedata)[1]	
		if (games_clean[i,2] in teams[:,2])==false
			push!(fcs_teams,games_clean[i,2])
		end	
		if (games_clean[i,5] in teams[:,2])==false
			push!(fcs_teams,games_clean[i,5])
		end				
	end
	fcs_teams
end

# ╔═╡ e4addf68-0b11-47dd-8290-4adc281ea794
md"We have a problem. Looking at the list, we see a number of FBS teams, like Pittsburgh and USC. The issue is that the label in the team data is slightly different than the game data. Thankfully there are not many examples, and so we can fix these small inconsistencies manually:"

# ╔═╡ 59ace2d7-c126-49a2-ba43-00cca2ee91bb
begin
	teamdata[113,2]="Alabama-Birmingham"
	teamdata[17,2]="Brigham Young"
	teamdata[114,2]="Central Florida"
	teamdata[55,2]="Louisiana State"
	teamdata[85,2]="Mississippi"
	teamdata[89,2]="Pittsburgh"
	teamdata[116,2]="Southern California"
	teamdata[95,2]="Southern Methodist"
	teamdata[119,2]="Texas-El Paso"
	teamdata[120,2]="Texas-San Antonio"
	
	fcs = []
	fcsgames = []
	for i in 1:size(games_clean)[1]	
		if (games_clean[i,2] in teamdata[:,2])==false
			push!(fcs,games_clean[i,2])
			push!(fcsgames,i)
		end	
		if (games_clean[i,5] in teamdata[:,2])==false
			push!(fcs,games_clean[i,5])
			push!(fcsgames,i)
		end				
	end
	fcs
end

# ╔═╡ a2fe31a4-6d45-443d-85af-37e8955fd65b
md"Here are all the games featuring an FCS team:"

# ╔═╡ 70dc26d3-88e3-45f7-a33e-8266c3c92a59
games_clean[fcsgames,:]

# ╔═╡ 1d9b291c-a19f-4e83-a19f-22100aad4c9c
md"We're finally ready to output our list of games between two FBS teams:"

# ╔═╡ c6f55d4c-50d7-407d-96f1-be376dce8c92
games = games_clean[setdiff(collect(1:size(gamedata)[1]),fcsgames),:]

# ╔═╡ 02ffe2cc-4331-4d55-a3d9-7150b4a6cce6
md"### Transition Matrix and Stationary Vector

Now that we have input and cleaned our data, we're prepared to define a directed multigraph for college football. The idea is that the teams are the vertices, and there is an edge from vertex i to vertex j for every time team i lost to team j (e.g., if a team loses twice to another, there are two edges between the vertices)."

# ╔═╡ 6eb9d59b-4341-4b7f-99b0-bd2533f5b3cc
md"Let's define a random walk on our multigraph, where the states are the teams, and at each step, we either move to a team our current team lost to, stay at our current team (with probability proportional to the team's win percentage), and with a small probability moves to an arbitrary team (to avoid reducibility):

$$\mathbb{P}[X_{t+1} = i \, | \, X_t = j] = \begin{cases} \displaystyle{ \frac{(\text{\# times team i beat team j}) + 1/131}{\text{(\# games team j played)}+1}} &\quad \text{for } \; i \ne j \\ \\
\displaystyle{\frac{\text{(\# wins team j has)} + 1/131}{\text{(\# games team j played)} +1 } }&\quad \text{for } \;i=j \end{cases}$$

Here's the associated transition matrix:
"

# ╔═╡ dfcff12e-58a7-4e39-9713-9e85781e36a2
begin
	A = ones(size(teams)[1],size(teams)[1])/size(teams)[1]
	for i in 1:size(games)[1]
		j = findall( x -> x == games[i,2],teams[:,2])[1]
		k = findall( x -> x == games[i,5],teams[:,2])[1]
		A[k,j] += 1
		A[j,j] += 1
	end
	sums = sum(A,dims=2)
	T = A
	for i=1:size(teams)[1]
		T[i,:]=T[i,:]/sums[i,1]
	end
	T
end

# ╔═╡ 7f9e2d05-4adb-486b-b067-d61ec70d81c3
md"As one last check that we did this correctly, let's look at the number of games each team played:"

# ╔═╡ a715f87b-5337-4a51-abb5-a1a1af21b44e
showsums = DataFrame(Team = teams[:,2], Games = (sums[:,1]-ones(size(teams)[1],1))[:,1])

# ╔═╡ ab38e70f-b3df-46e2-b809-f6655dbced33
md"Using the power method, we can compute the stationary distribution:"

# ╔═╡ 8333a269-8397-4a79-aa38-47ab330d0b5a
begin
	pv = rand(1,size(teams)[1])
	pv = pv/sum(pv)
	for i in 1:200
		pv = pv*T
		pv = pv/sum(pv)
	end
	
	CFP25 = 1000*ones(Int32,131)
	CFP25[3] = 6
	CFP25[22] = 9
	CFP25[33] = 13
	CFP25[35] = 1
	CFP25[47] = 10
	CFP25[55] = 14
	CFP25[62] = 2
	CFP25[66] = 24
	CFP25[74] = 23
	CFP25[75] = 25
	CFP25[79] = 21
	CFP25[81] = 5
	CFP25[86] = 16
	CFP25[87] = 15
	CFP25[88] = 8
	CFP25[97] = 19
	CFP25[103] = 7
	CFP25[104] = 20
	CFP25[106] = 3
	CFP25[111] = 18
	CFP25[114] = 22
	CFP25[115] = 17
	CFP25[116] = 4
	CFP25[117] = 11
	CFP25[125] = 12
	
	ratings = [teams[:,2] 131*pv' CFP25]
	ratings = ratings[sortperm(-ratings[:, 2]), :]
	
	walk_ranking = DataFrame(Team = ratings[:,1], Value = ratings[:,2], CFPRanking = ratings[:,3])
end

# ╔═╡ eedec611-3eae-40bd-b593-1c9bed069663
md"Interestingly, using only a very basic technique and the win-loss results of the season, all of the CFP top 25 teams are in our top 31, and we have predicted the top five, in the correct order!

But can we do better...?


In lecture a number of alternative methods were proposed. We will conisder two of them."

# ╔═╡ acabea7a-1ceb-432e-945b-7dce5502bd94
md"### Alternate Method 1: Random Walk Weighted by score differential

Let's see what happens when we re-weight the transition probabilities based on the amount a team lost by:"

# ╔═╡ ce25d6ff-bb0c-40e0-956e-51a27aadcac0
begin
	Aw = zeros(size(teams)[1],size(teams)[1])
	for i in 1:size(games)[1]
		j = findall( x -> x == games[i,2],teams[:,2])[1]
		k = findall( x -> x == games[i,5],teams[:,2])[1]
		Aw[k,j] += games[i,3]-games[i,6]
		Aw[j,j] += games[i,3]-games[i,6]
	end
	sumw = sum(Aw,dims=2)
	Tw = Aw
	for i=1:size(teams)[1]
		Tw[i,:]=(Tw[i,:]/sumw[i,1])*(11/12) + ones(size(teams)[1])/(12*size(teams)[1])
	end
	Tw
end

# ╔═╡ 0baa5cf4-36fb-4667-8ac4-3e5c8576cf07
begin
	pvw = rand(1,size(teams)[1])
	pvw = pvw/sum(pvw)
	for i in 1:200
		pvw = pvw*Tw
		pvw = pvw/sum(pvw)
	end
	
	ratingw = [teams[:,2] 131*pvw' 131*pv' CFP25]
	ratingw = ratingw[sortperm(-ratingw[:, 2]), :]
	
	weight_ranking = DataFrame(Team = ratingw[:,1], WeightedWalk = ratingw[:,2], Walk = ratingw[:,3],CFPRanking = ratingw[:,4])
end

# ╔═╡ d9b8c505-c458-4f9a-9065-480ef279767d
md"### Alternate Method 2: Elo Rating System

Let's give each team an initial rating of R = 1500, and update ratings after each game between a pair of teams. If teams i and j have ratings R_i and R_j, then using those ratings we expect team i to win 

$$E_i= 10^{R_i/400}/(10^{R_i/400}+10^{R_j/400})$$ 

fraction of the time (and team j win $E_j=1-E_i$ fraction of the time). If team i does win, we update the ratings to account for the additional information:

$$R_i = R_i+ K E_j \quad R_j = R_j -KE_j$$

Using this model (with a K-factor of 40), we obtain the following results:
"

# ╔═╡ ec3c3fd5-6d2e-4aeb-a418-5fac0f29f0d7
begin
	elo = 1500*ones(1,size(teams)[1])
	K = 40
	for i in 1:size(games)[1]
		j = findall( x -> x == games[i,2],teams[:,2])[1]
		k = findall( x -> x == games[i,5],teams[:,2])[1]
		Ek = 10^(elo[1,k]/400)/(10^(elo[1,k]/400) + 10^(elo[1,j]/400))
		elo[1,j] += K*Ek
		elo[1,k] -= K*Ek
	end
	ratinge = [teams[:,2] elo' 131*pvw' 131*pv' CFP25]
	ratinge = ratinge[sortperm(-ratinge[:, 2]), :]
	
	elo_ranking = DataFrame(Team = ratinge[:,1], Elo = ratinge[:,2], WeightedWalk = ratinge[:,3], Walk = ratinge[:,4],CFPRanking = ratinge[:,5])
end

# ╔═╡ 1bc33096-3f07-4665-81dc-4495d4e8b520
md"### Graph Laplacians and a Simple Rating System

Inspired by the previous attempts we've made, let's try a fairly simple approach. Let's give each team a rating R_i, and simply require that the rating of a team is equal to the average rating of the teams it played plus (or minus) the average score differential:

$R_i = \frac{\displaystyle{\sum_{\text{opponents j team i played}} R_j + \text{score differential in game between i and j}}}{\text{total \# games team i played}}$

It's not obvious that these conditions are enough to guarantee a unique solution, but it turns out that this is actually a linear system $L x = b$, where $b$ is the vector of total score differentials for each team, and $L$ is the graph Laplacian of the associated network. If the network is connected, then there is a unique rating assignment $x$ (up to a constant shift in all ratings):
"

# ╔═╡ 2197b572-09b2-49e0-8c50-1bbe369dde3a
begin
	L = zeros(size(teams)[1],size(teams)[1])
	b = zeros(size(teams)[1],1)
	for i in 1:size(games)[1]
		j = findall( x -> x == games[i,2],teams[:,2])[1]
		k = findall( x -> x == games[i,5],teams[:,2])[1]
		diff = games[i,3]-games[i,6]
		if abs(diff)<10
			diff = 10*sign(diff)
		elseif abs(diff)>30
			diff = 30*sign(diff)
		end
		if ismissing(games[i,4])
			diff -= 3
		elseif games[i,4] == "@"
			diff += 3
		end
		b[j,1] += diff
		b[k,1] -= diff
		L[j,k] -= 1
		L[k,j] -= 1
		L[j,j] += 1
		L[k,k] += 1
	end
	x = L\b
	x = x-(sum(x)/131)*ones(size(teams)[1],1)
end

# ╔═╡ b7c8ea00-a367-4b4d-a751-0d41d288c3f6
norm(b-L*x)

# ╔═╡ a42428a2-f895-4587-8e2f-04fd7b026344
begin
	rating = [teams[:,2] x elo' 131*pvw' 131*pv' CFP25]
	rating = rating[sortperm(-rating[:, 2]), :]
	
	final_ranking = DataFrame(Team = rating[:,1], SRS = rating[:,2], Elo = rating[:,3], WeightedWalk = rating[:,4], Walk = rating[:,5],CFPRanking = rating[:,6])
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[compat]
CSV = "~0.10.15"
DataFrames = "~1.7.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.6"
manifest_format = "2.0"
project_hash = "784582d884aff988e0acb46585ee6e1ca3650b19"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "deddd8725e5e1cc49ee205a1964256043720a6c3"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.15"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "9d8a54ce4b17aa5bdce0ea5c34bc5e7c340d16ad"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "a37ac0840a1196cd00317b57e39d6586bf0fd6f6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.7.1"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "e357641bb3e0638d353c4b29ea0e40ea644066a6"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.3"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "3bab2c5aa25e7840a4b065805c0cdfc01f3068d2"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.24"

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

    [deps.FilePathsBase.weakdeps]
    Mmap = "a63ad114-7e13-5084-954f-fe012c677804"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.InlineStrings]]
git-tree-sha1 = "8f3d257792a522b4601c24a577954b0a8cd7334d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.5"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.InvertedIndices]]
git-tree-sha1 = "6da3c4316095de0f5ee2ebd875df8721e7e0bdbe"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "0f27480397253da18fe2c12a4ba4eb9eb208bf3d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.0"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "66b20dd35966a748321d3b2537c4584cf40387c7"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.3.2"

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
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "712fb0231ee6f9120e005ccd56297abbc053e7e0"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.8"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "64d974c2e6fdf07f8155b5b2ca2ffa9069b608d9"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.2"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a04cabe79c5f01f4d723cc6704070ada0b9d46d5"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.4"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "f2c1efbc8f3a609aadf318094f8fc5204bdaf344"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.1"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"
"""

# ╔═╡ Cell order:
# ╠═92a193f2-7022-488e-9862-55c313f4d11a
# ╟─db24490e-7eac-11ea-094e-9d3fc8f22784
# ╟─2e965e40-01f0-4544-a42b-95b0070d7076
# ╠═5f54e11d-161b-4851-aa4c-26ea2b26f2a9
# ╟─1351fe53-ebef-4b96-842e-79b85d28a290
# ╠═bd24d02c-7eac-11ea-14ab-95021678e71e
# ╟─cf72c8a2-7ead-11ea-32b7-d31d5b2dacc2
# ╠═cb1fd532-7eac-11ea-307c-ab16b1977819
# ╟─816ea402-7eae-11ea-2134-fb595cca3068
# ╠═ae52ad1a-6b0e-4d9c-b32b-0409c3df14ef
# ╟─e4addf68-0b11-47dd-8290-4adc281ea794
# ╠═59ace2d7-c126-49a2-ba43-00cca2ee91bb
# ╟─a2fe31a4-6d45-443d-85af-37e8955fd65b
# ╠═70dc26d3-88e3-45f7-a33e-8266c3c92a59
# ╟─1d9b291c-a19f-4e83-a19f-22100aad4c9c
# ╠═c6f55d4c-50d7-407d-96f1-be376dce8c92
# ╟─02ffe2cc-4331-4d55-a3d9-7150b4a6cce6
# ╟─6eb9d59b-4341-4b7f-99b0-bd2533f5b3cc
# ╠═dfcff12e-58a7-4e39-9713-9e85781e36a2
# ╟─7f9e2d05-4adb-486b-b067-d61ec70d81c3
# ╠═a715f87b-5337-4a51-abb5-a1a1af21b44e
# ╟─ab38e70f-b3df-46e2-b809-f6655dbced33
# ╠═8333a269-8397-4a79-aa38-47ab330d0b5a
# ╟─eedec611-3eae-40bd-b593-1c9bed069663
# ╟─acabea7a-1ceb-432e-945b-7dce5502bd94
# ╠═ce25d6ff-bb0c-40e0-956e-51a27aadcac0
# ╠═0baa5cf4-36fb-4667-8ac4-3e5c8576cf07
# ╟─d9b8c505-c458-4f9a-9065-480ef279767d
# ╠═ec3c3fd5-6d2e-4aeb-a418-5fac0f29f0d7
# ╟─1bc33096-3f07-4665-81dc-4495d4e8b520
# ╠═2197b572-09b2-49e0-8c50-1bbe369dde3a
# ╠═b7c8ea00-a367-4b4d-a751-0d41d288c3f6
# ╠═a42428a2-f895-4587-8e2f-04fd7b026344
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
