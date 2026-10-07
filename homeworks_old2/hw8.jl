### A Pluto.jl notebook ###
# v0.19.31

using Markdown
using InteractiveUtils

# ╔═╡ 25c1f001-8e4b-41aa-926e-9ff1550eae35
begin
	using PlutoTeachingTools
end

# ╔═╡ 9ea8ed00-7484-11ee-0824-0b5807b13a8f
md"""
Homework 8 of the MIT Course [_Julia: solving real-world problems with computation_](https://github.com/mitmath/JuliaComputation)

Release date: Thursday, Nov 9th, 2023 (version 1)

**Due date: Thursday, Nov 17th, 2023 at 11:59pm EST**

**Instructions: Submit a pdf to canvas by selecting Pluto export to PDF.**

Submission by: Jazzy Doe (jazz@mit.edu)
"""

# ╔═╡ 48b82457-95d0-4ccc-bec0-8d40e01760f3
student = (name = "Jazzy Doe", kerberos_id = "jazz")

# ╔═╡ 16086277-f9a9-4866-80d6-181d1d18519a
md"""
**Project Second Check-In**
This homework is to follow up on your progress for Guillaume's challenge problem **(https://gdalle.github.io/IntroJulia/challenge.html)**. 
This counts as equal weight to other homeworks, which equates to 25% of the challenge. 

As you progress in developing your Julia package for the semester project, it's essential to build upon a foundation of good practices that not only facilitate code functionality but also ensure maintainability, efficiency, and collaboration. This check-in is designed to reinforce the critical components required for a robust Julia package:

**Types for Storing Problem Instances and Solutions**: Custom types are the backbone of your package, allowing you to define structures that represent complex data and operations in an intuitive and efficient way.

**Functions for Checking the Feasibility and Computing Objective Values**: Functions that operate on your custom types should not only perform the necessary computations but also validate the feasibility of solutions within the context of the problem.

**Algorithms for Generating Good Solutions and Finding Upper Bounds**: Good solutions are born from algorithms that efficiently navigate the problem space, guided by bounds that benchmark the solution quality.

**Thorough Unit Tests**: These are your first line of defense against bugs, ensuring each part of your code behaves as expected, even as you make changes and add new features.

**Detailed Documentation**: Well-documented code is as valuable as well-written code, providing clarity on the usage and purpose of your package's components.

**Continuous Integration**: A CI system automates the testing of your codebase, ensuring that changes do not break existing functionality, and helps maintain code quality throughout the development process.

The following sections of this assignment will delve into each of these areas, helping you to strengthen your package by applying these principles. The sections are interrelated, and while they can be addressed sequentially, you may find it beneficial to read through the entire assignment first to understand how each part complements the others. This way, you can plan your approach, decide on the order of tasks, and ensure that your work is cohesive and strategically aligned with the project's objectives.

As you embark on this check-in, remember that the goal is to deepen your understanding of these principles and to directly apply them to your project, illustrating your mastery of both Julia and the best practices in software development.
"""

# ╔═╡ 3d6772be-2ad6-4f9b-94a6-2cd75252d9cd
md"""
# 1. Effectiveness of a Custom Type Design
"""

# ╔═╡ 6a501c3e-0bae-428d-b8cd-2b430afbb6b5
md"""
**Introduction**: In Julia, the design of custom types is not only about storing data but also about aligning with the language's multiple dispatch system to write more efficient and clearer code. This approach can significantly optimize the execution time, especially in computational tasks such as optimization problems, by ensuring that operations are specialized for the types of data they operate on. 
"""

# ╔═╡ d32ee0f3-4009-41ff-8bd3-04d8e92bfa8b
md"""
The routing problem involves managing complex data structures that represent the city's layout and the various routes within it. For example, an effectively designed custom type, which we might call RouteGrid, could encapsulate the nuances of this layout, such as distances between points, connectivity, and traffic patterns. By creating a type tailored to these specific needs, algorithms can more directly address the problem's constraints, such as minimizing travel distance or time, potentially leading to more efficient and effective routing solutions. **The custom type can also facilitate the implementation of methods that manipulate this data**, taking advantage of Julia's multiple dispatch to provide optimized performance for operations like route addition, deletion, or adjustment.
"""

# ╔═╡ 08165c83-3772-49e7-96c9-ee133708b6a8
md"""
!!! danger "Task 1"
	Create a custom type, such as RouteGrid type that encapsulates the city's grid layout and the routes, and provide documentation on it's use. 
	- The type should include fields that represent the necessary components of the grid, such as intersections, streets, and delivery endpoints.
	- Include methods for common operations that will be performed on the grid, such as adding a route or checking for an intersection.
	If you are further along in the project, you are also welcome to create a different custom type, not relating to the manipulation of the city's grid layout and routes. This problem will be graded on the usefulness of the custom type and its supporting documentation. 
"""

# ╔═╡ e430eb66-1a00-4d7d-990c-7dbbde96cc8a
md"""
Link to Documentation: https://www...
Link to Type in Repository Code: https://www...
"""

# ╔═╡ 99b8ff51-5b21-45d9-bca8-1d21ff37f23b
md"""
# 2. Solution Feasibility: Understanding the Bounds of the Problem
"""

# ╔═╡ c5e62fd0-a827-4efe-8da8-dcc77b7a5d3d
md"""
**Introduction**: Estimating an upper bound for optimization problems is crucial for evaluating algorithmic performance and understanding the scope of potential solutions. A well-calculated upper bound can guide decision-making and heuristic development. """

# ╔═╡ fd90f0f3-a4a3-445b-9b84-b12cae29dbcc
md"""
Calculating an improved upper bound on the optimal route distance is directly applicable to assessing the efficiency of the routing algorithms used in the project. By establishing a more realistic upper bound that accounts for the actual distribution of delivery points and the city's street layout, you can better evaluate your routing solutions against this benchmark. This encourages the development of algorithms that do not just seek any solution but strive for the optimality within the bounds of the problem's constraints. It can guide the algorithm refinement process, helping to prioritize which aspects of the algorithm need improvement to approach or surpass the theoretical upper bound.
"""

# ╔═╡ 09ba7470-55f6-437c-910f-48f43eb3ff6a
md"""
!!! danger "Task 2.1"
	Propose and document an algorithm for calculating an improved upper bound for the objective value.
	- Ideally, your algorithm should leverage the structure of the city grid and the distribution of delivery points. (And not just the total distance of roads in city, the first obvious upper bound)
	- Justify your algorithm's approach and its potential impact on solution quality.
"""

# ╔═╡ 2ba3f41a-07c0-4b42-91e1-ebb35e9eeefd
md"""
Link to algorithm documentation: https://www...
"""

# ╔═╡ 01aea163-dc8f-4dd8-b669-c84bc879f41d
md"""
!!! danger "Task 2.2"
	Calculate the bounds based on your algorithm
"""

# ╔═╡ 50fdc883-4956-4311-8fec-dda5060c7b48
md"""
54000 Sec Bound (m): ?

18000 Sec bound (m): ? 

Also put these bounds in the spreadsheet <https://docs.google.com/spreadsheets/d/1ZIlY3XCDXl7TMssk1ibN8bRk073RHepLTd_r5uoA-ok/edit?usp=sharing>
"""

# ╔═╡ 11aeaeb7-4106-4a02-a822-6d2ce24d38cc
md"""
# 3. Unit Testing: Your First Unit Test
"""

# ╔═╡ 67f8ba14-7f27-467b-a3e2-aac03bc3d5f3
md"""
**Introduction**: Unit testing is a software testing method by which individual units of source code—sets of one or more program functions—are tested to determine whether they are fit for use. It ensures that code changes don't break existing functionality, leading to more stable software builds. A comprehensive guide on unit testing in Julia can be found in Julia's documentation on testing <https://docs.julialang.org/en/v1/stdlib/Test/>
"""

# ╔═╡ 79af0d11-9b79-4a20-8376-4257c5b4d097
md"""
For your routing solution, unit tests will validate each function's behavior, ensuring the code is not only correct but also resilient to changes over time.
"""

# ╔═╡ 2e56a5c5-e90d-4840-bce9-1213fcf8c24e
md"""
!!! danger "Task 3"
	Write and integrate any form of a unit test for your package. 
	- It should benchmark either the code efficiency or correctness
	- The unit test case in your code should be passing at the time of submission (which could obviously change by the time we're grading)
"""

# ╔═╡ 61df1e85-3b98-497a-8e12-906cb3c0de44
md"""
Test case code: https://www...
"""

# ╔═╡ 6f417269-dca9-4db3-ae0e-d60dfd261e01
md"""
# 4. Continous Integration Setup
"""

# ╔═╡ b84c91fc-c06c-447c-aae1-64b2f0378158
md"""
**Introduction**: Continuous Integration (CI) practices are fundamental in modern software development, ensuring that code changes are automatically tested, which helps in identifying issues early on. It also enforces discipline in testing and can reduce integration problems, allowing for faster iterative development. A detailed explanation of CI benefits can be found in Martin Fowler's article on Continuous Integration. <https://martinfowler.com/articles/continuousIntegration.html>
"""

# ╔═╡ eade570d-c7f6-4aee-be86-0010cc32ea92
md"""
The setup of a Continuous Integration (CI) system is a step towards professional software engineering practices. For the routing challenge, CI ensures that any changes to the codebase do not inadvertently break the solution. As you develop their algorithms and make improvements to their code, CI automatically verifies that the code compiles, all tests pass, and, in some configurations, that the code adheres to style guidelines. This instant feedback loop is crucial, especially in a collaborative project where multiple people might be working on different parts of the code. It encourages an iterative approach to development, where you can make small, frequent changes while maintaining the integrity of the overall solution.
"""

# ╔═╡ 65a19c8e-3cad-41b6-b56e-0dc31168b103
md"""
!!! danger "Task 4"
	Set up a CI workflow with GitHub Actions or another CI service of your choice.
	- The workflow should trigger a build and run your test suite on every push to the repository. 
"""

# ╔═╡ 88e42108-ee9f-445d-a29d-607ce3056e45
md"""
Link to github page (showing CI icon): https://www...
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"

[compat]
PlutoTeachingTools = "~0.2.13"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.5"
manifest_format = "2.0"
project_hash = "7a42974596e9e12c27f0417f760c666a50853d11"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "c0216e792f518b39b22212127d4a84dc31e4e386"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.5"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0592b1810613d1c95eeebcd22dc11fba186c2a57"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.26"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "f428ae552340899a935973270b8d98e5a31c49fe"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.1"

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

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

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

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "2e73fe17cac3c62ad1aebe70d44c963c3cfdc3e3"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.2"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

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

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "ba168f8fc36bf83c8d0573d464b7aab0f8a81623"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.5.7"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═9ea8ed00-7484-11ee-0824-0b5807b13a8f
# ╠═48b82457-95d0-4ccc-bec0-8d40e01760f3
# ╟─16086277-f9a9-4866-80d6-181d1d18519a
# ╟─25c1f001-8e4b-41aa-926e-9ff1550eae35
# ╟─3d6772be-2ad6-4f9b-94a6-2cd75252d9cd
# ╟─6a501c3e-0bae-428d-b8cd-2b430afbb6b5
# ╟─d32ee0f3-4009-41ff-8bd3-04d8e92bfa8b
# ╟─08165c83-3772-49e7-96c9-ee133708b6a8
# ╠═e430eb66-1a00-4d7d-990c-7dbbde96cc8a
# ╟─99b8ff51-5b21-45d9-bca8-1d21ff37f23b
# ╟─c5e62fd0-a827-4efe-8da8-dcc77b7a5d3d
# ╟─fd90f0f3-a4a3-445b-9b84-b12cae29dbcc
# ╟─09ba7470-55f6-437c-910f-48f43eb3ff6a
# ╠═2ba3f41a-07c0-4b42-91e1-ebb35e9eeefd
# ╟─01aea163-dc8f-4dd8-b669-c84bc879f41d
# ╠═50fdc883-4956-4311-8fec-dda5060c7b48
# ╟─11aeaeb7-4106-4a02-a822-6d2ce24d38cc
# ╟─67f8ba14-7f27-467b-a3e2-aac03bc3d5f3
# ╟─79af0d11-9b79-4a20-8376-4257c5b4d097
# ╟─2e56a5c5-e90d-4840-bce9-1213fcf8c24e
# ╠═61df1e85-3b98-497a-8e12-906cb3c0de44
# ╟─6f417269-dca9-4db3-ae0e-d60dfd261e01
# ╟─b84c91fc-c06c-447c-aae1-64b2f0378158
# ╟─eade570d-c7f6-4aee-be86-0010cc32ea92
# ╟─65a19c8e-3cad-41b6-b56e-0dc31168b103
# ╠═88e42108-ee9f-445d-a29d-607ce3056e45
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
