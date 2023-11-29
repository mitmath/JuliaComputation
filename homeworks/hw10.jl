### A Pluto.jl notebook ###
# v0.19.31

using Markdown
using InteractiveUtils

# ╔═╡ 9ea8ed00-7484-11ee-0824-0b5807b13a8f
md"""
Homework 10 of the MIT Course [_Julia: solving real-world problems with computation_](https://github.com/mitmath/JuliaComputation)

Release date: Thursday, Nov 28th, 2023 (version 1)

**Due date: Thursday, Dec 5th, 2023 at 11:59pm EST**

**Instructions: Submit a url to your github repository to Canvas.**
"""

# ╔═╡ 16086277-f9a9-4866-80d6-181d1d18519a
md"""
# Google Hashcode Optimization Challenge: Repository Submission

### Overview
This final project report is your opportunity to showcase the culmination of your skills and knowledge gained throughout the course. You've already made it quite a ways, completing various parts through hw6 and hw8. Your repository will now be graded based on the following attributes, each carrying a specific weight towards your final score. While we won't be grading hashly by any means, previous points were awarded by completion, while these points are awarded more by quality. 

### Grading Attributes and Tasks

#### 1. Documentation (3/10 Points)
**Task**: Create a comprehensive documentation page and a clear README for your Julia package.
- Ensure your documentation covers all aspects of using your package.
- The README should provide a quick start guide, installation instructions, and examples.

Note, this takes a particularly heavy weight in the project. This is because you will not be submissing a report. The repository is the report for itself! For documenation guidance, please see [Julia Reach Dev Docs](https://juliareach.github.io/JuliaReachDevDocs/latest/guidelines/)

#### 2. Types for Storing Problem Instances and Solutions (2/10 Points)
**Task**: Develop and document custom types for storing problem instances and solutions.
- Focus on the efficiency and appropriateness of the types for the given problem.
- Document how these types are used within the package.

Most of these points will be awarded by demonstrating the value of the custom type. Put yourself in the shoes of someone else who might be using the package, would they understand how to use your custom type? 

#### 3. Functions for Checking the Feasibility of a Solution (1/10 Points)
**Task**: Document the functions you have developed for checking the feasibility of solutions.
- Emphasize the quality of documentation, explaining how these functions integrate into the overall package.

We'd like to understand how you check your solution (likely using HashCode2014). Demonstrate how this check should interact with your custom types. You don't have to overcomplicate this part. It may also be something good to include in the README. 

#### 4. Algorithms for Generating a Good Solution (1/10 Points)
**Task**: Implement algorithms that generate effective solutions and beat Guillaume's baseline.
- Document the algorithm design and its efficiency in terms of both distance and computation time.
- Specific targets: Beat Guillaume's baseline in both 54000s and 18000s scenarios (0.25 points for beating each time and distance per scenario).

#### 5. Finding an Upper Bound on the Best Objective Value (1/10 Points)
**Task**: Develop a method to find an upper bound on the best objective value that beats or matches Guillaume's baseline.  
- Document your approach and how it integrates with the overall problem-solving strategy.

#### 6. Competition Points (1/10 Points)
**Task**: Achieve the best performance in one of the following categories: fastest solution, longest distance, or lowest bound with a correct proof. In each of these cases, it has to match or exceed Guillaume's baseline in the other attributes (i.e. a fast solution that doesn't at least match Guillaume's baseline doesn't get awarded the point).

These are the hardest points to get, so don't fret too much! 90% is still an A

#### 7. Unit Tests and CI/CD (1/10 Points)
**Task**: Expand the existing CI/CD setup with at least one more relevant unit test (so at least two tests that have specific purpose).
- Document the purpose and implementation of the new test. 
"""

# ╔═╡ 75aab5f9-458f-452d-bd22-41e5ca5b5b97
md"""
# Algorithm Suggestions for Performance Improvement in Distance Calculation

The use of one of these algorithms is not required. But try looking into them and think if they could be applied to the problem. This package can be a wonderful addition to your github profile, and the use of these algorithms can be quite shiny in job or internship applications...

1. **Max Flow Algorithms**
   - *Ford-Fulkerson Algorithm*: A method for finding the maximum flow in a flow network.
     - Resource: [Ford-Fulkerson Algorithm](https://www.geeksforgeeks.org/ford-fulkerson-algorithm-for-maximum-flow-problem/)

2. **Graph Traversal Algorithms**
   - *Dijkstra’s Algorithm*: Used for finding the shortest paths between nodes in a graph.
     - Resource: [Dijkstra’s Algorithm](https://www.geeksforgeeks.org/dijkstras-shortest-path-algorithm-greedy-algo-7/)

3. **Greedy Algorithms**
   - *Nearest Neighbor Algorithm*: A heuristic used in routing problems like the Traveling Salesman Problem.
     - Resource: [Nearest Neighbor Algorithm](https://blog.devgenius.io/traveling-salesman-problem-nearest-neighbor-algorithm-solution-e78399d0ab0c)

4. **Dynamic Programming**
   - *Bellman-Ford Algorithm*: Computes shortest paths in a weighted graph, useful for negative weight edges.
     - Resource: [Bellman-Ford Algorithm](https://www.geeksforgeeks.org/bellman-ford-algorithm-dp-23/)

5. **Metaheuristic Algorithms**
   - *Genetic Algorithms*: Simulates natural selection, useful for complex optimization problems.
     - Resource: [Genetic Algorithms](https://www.geeksforgeeks.org/genetic-algorithms/)

6. **Integer Linear Programming (ILP)**
   - *Branch and Bound*: A method for solving integer linear programming problems.
     - Resource: [Branch and Bound Method](https://www.geeksforgeeks.org/introduction-to-branch-and-bound-data-structures-and-algorithms-tutorial/)

"""

# ╔═╡ Cell order:
# ╟─9ea8ed00-7484-11ee-0824-0b5807b13a8f
# ╟─16086277-f9a9-4866-80d6-181d1d18519a
# ╟─75aab5f9-458f-452d-bd22-41e5ca5b5b97
