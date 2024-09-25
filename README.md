# Julia: Solving Real-World Problems with Computation, Fall 2024 <br>*(course material work in progress)*


|  |  |
|:---|---|
| <h3>Real-world problems</h3><p>We will take applications such as climate change and show how you can participate in the big open source community looking to find solutions to challenging problems with exposure to github and parallel computing.</p> | <img alt="An interactive lecture about climate economics. You can see the user moving the global CO2 emissions in one graph, and a second graph with global temperatures over 200 years responds." src="https://user-images.githubusercontent.com/6933510/136199652-0a1275ad-8452-4c9b-ac68-d33ed22f1d17.gif" width=200> |
| <h3>Corgi in the washing machine</h3><p>You will learn mathematical ideas by immersion into the mathematical process, performing experiments, seeing the connections, and seeing just how much fun math can be.</p> | <img src="https://user-images.githubusercontent.com/6933510/136203450-f1d38de6-f43c-4bfc-a987-f954e7a9da2e.png" alt="An image of prof. Philip the Corgi, but the whole image is swirled and twisted using a mathematical transformation. Overlaying grid lines are also twisted, showing the non-linearity of the transformation." width=200> |
| <h3>Revolutionary interactivity</h3><p>Our course material is built using real code, and instead of a book, we have a series of interactive <em>notebooks</em>. <strong>On our website, you can play with sliders, buttons and images to interact with our simulations.</strong> You can even go further, and modify and run any code on our website!</p> |  <img src="https://user-images.githubusercontent.com/6933510/136196607-16207911-53be-4abb-b90e-d46c946e6aaf.gif" alt="An interactive lecture about the Newton method. A parabolic function is graphed, and we use sliders to control the number of iterations of the Newton method. Each iteration shows a tangent, demonstrating the algorithm." width=200> |
| <h3>Learning Julia</h3> <p>In literature it’s not enough to just know the technicalities of grammar. In music it’s not enough to learn the scales. The goal is to communicate experiences and emotions. For a computer scientist, it’s not enough to write a working program, the program should be <strong>written with beautiful high level abstractions that speak to your audience</strong>. This class will show you how.</p> | <img src="https://user-images.githubusercontent.com/6933510/136203632-29ce0a96-5a34-46ad-a996-de55b3bcd380.png" alt="A snippet of Julia code defining a new type called Sphere, with fields 'position', 'radius' and 'index of refration'." width=200> |

> # Check out our interactive lecture material on [computationalthinking.mit.edu](https://computationalthinking.mit.edu)!

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Logistics

**MIT's numbering scheme gone nuts:** (1.C25/6.C25/12.C25/16.C25/18.C25/22.C25)  
This course is part of the [Common Ground](https://computing.mit.edu/cross-cutting/common-ground-for-computing-education/common-ground-subjects/).  

**Lectures:** Mondays and Wednesdays 1-2:30 PM in room 4-149.

**Prerequisites:** 6.100A, 18.03, 18.06 or equivalents (meaning some programming, dif eqs, and lin alg)

**Instructors:** A. Edelman, more TBA

**Teaching Assistants:** Raye Kimmerer

**Office Hours:** 
- Raye on Friday's 2:30 - 3:30PM in 32-G780. A map can be found here: [Map](https://www.csail.mit.edu/sites/default/files/resources/maps/7G/G780.gif), be sure you take the Gates tower elevators **not** the Dreyfoos tower elevators!!!


**Lecture Recordings:** ( Hopefully) Available on Canvas under the Panopto Video tab. Should be published the evening after each lecture.  
**Links:** Worth bookmarking.  

| Piazza https://piazza.com/mit/fall2024/18c25 | Canvas TBA | [Julia](https://julialang.org/) |  |
| ------------------------------------------------- | ---------------------------------------------- | ------------------------------- | ---------------------------------------- |
| Discussion                                        | HW submission                                  | Language                        |                                      |

## Description

Focuses on algorithms and techniques for writing and using modern technical software in a job, lab, or research group environment that may consist of interdisciplinary teams, where performance may be critical, and where the software needs to be flexible and adaptable. Topics include automatic differentiation, matrix calculus, scientific machine learning, parallel and GPU computing, and performance optimization with introductory applications to climate science, economics, agent-based modeling, and other areas. Labs and projects focus on performant, readable, composable algorithms and software. Programming will be in Julia. Expects students have some familiarity with Python, Matlab, or R. No Julia experience necessary.

Counts as an elective for CEE students, an advanced subject (18.100 and higher) for Math students, an advanced elective for EECS students, and a computation restricted elective for NSE students. AeroAstro students can petition department to count this class as a professional subject in the computing area.
(Professors may be open to petitioning for counting for other programs.)

Class is appropriate for those who enjoy math and wish to see math being used in modern contexts.

While not exactly the same as our past [Computational Thinking Class](https://computationalthinking.mit.edu/)... not entirely different either.

## Course Objective
Make mathematics your playground:
Throughout the course, students will be encouraged to adopt a new approach to thinking about, learning, and communicating technical systems and concepts.
We will demonstrate and produce Julia code which exemplifies a living, interactive approach to make math a fun and playful experience.  
Perhaps similar to a CIM class (though this class is NOT officially a CIM , sorry)
we will have students present early versions of notebooks, with critiques (and
you get to critique the professor too).  Nearly all university classes emphasize communication through writing and presentations, this class adds
*communication through computation*.


## Grading

Projects may be teams of 1, 2, or 3.

Homework:              25%
Class Participation: 10%


Project 1:   20%  (fairly soon)
Take an existing Pluto notebook from computationalthinking.mit.edu or some other place with our permission.  Modify the notebook to make it substantially better, possibly by adding content, but more importantly making it better from a communications standpoint. Choose between signing up to do an in class presentation or making a video of your notebook.

Project 2a: 10% (around the middle of the term)
Make a notebook of material from another class you are taking. Pretend you are presenting the material the C25 way rather than the way you learned it.  

Project 2b: 5%
Critique another team’s Project 2a, giving constructive suggestions.

Project 3:  30%  (towards the end of term)
Use your Project 2a, incorporating suggestions, to make an amazing Pluto notebook, with a video of your presentation.  



<!----- 1. Making mathematics your playground: By the end of the course, students will be able to write interactive Julia code that aids in their understanding of new mathematical systems or concepts.
 2. Abstractions: By the end of the course students will be able to use the unique abstractions that exist in the Julia language to write code that can be part of a huge ecosystem.  (By contrast many  "one-off"  homeworks in traditional courses are not able, by their very nature, to reveal the value of abstraction.)
3. Open Source and group collaborations: By the end of the course students will be able to participate in a larger open source project and also will have experienced how programming language can help break down barriers between areas making real the dream of scientific bilinguals that has been promoted at MIT. (See for example [former MIT President Reif in the NYT back in 2018](https://www.nytimes.com/2018/10/15/technology/mit-college-artificial-intelligence.html).)
----->
## Homeworks at a glance

| Homework                                                        | Assigned | Due    | Topic                                              | Solution                                                                             |
| --------------------------------------------------------------- | -------- | ------ | -------------------------------------------------- | ------------------------------------------------------------------------------------ |
| [HW0](https://mit-c25-fall23.netlify.app/homeworks/hw0-2024)         | Sep 4    | Sep 11 | Getting Started                                    |                                                                                      |
| [HW1](https://mit-c25-fall23.netlify.app/homeworks/hw1-2024) | Sep 11|Sep 18||
|  [HW2](https://canvas.mit.edu/courses/27400/assignments/363066) | Sep 18 |Varies||

## Lectures at a glance (Lectures being updated from 2023 as we go, but this semester there will be many more student presentations and discussions.  Participation is a must.)

| #   | Day | Date  | Lecturer          | Topic                                                | Slides / Notes                                                                                                                                    | Notebooks                                                                                                                                                                                                                                                                                                                                                                |
| --- | --- | ----- | ----------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 0   |     |       |                   | Julia tutorial                                       | [Cheat Sheets](https://computationalthinking.mit.edu/Fall23/cheatsheets/)                                                                         |                                                                                                                                                                                                                                                                                                                                                                          |
| 1   | W   | 9/4  | Edelman           | Communicate With Computation                                     |  [Intro to Class](https://docs.google.com/presentation/d/1hjbKbdZkC0mG_tlwakAa3mpFlhgEKU3HaJCBw1YZ0iQ/edit?usp=sharing)                                                                                                                                                 | [Intro to Julia](https://gdalle.github.io/IntroJulia/), [Tutorial](https://mit-c25-fall23.netlify.app/notebooks/0_julia_tutorial), [Hyperbolic Corgi](https://mit-c25-fall23.netlify.app/notebooks/1_hyperbolic_corgi), [Images](https://mit-c25-fall23.netlify.app/notebooks/1_images), [Abstraction](https://mit-c25-fall23.netlify.app/notebooks/1_abstraction),      |
| 2   | M   | 9/9  | Edelman           |  Maybe you know Random Variables, but not as types?                            | [slides](https://docs.google.com/presentation/d/1hjbKbdZkC0mG_tlwakAa3mpFlhgEKU3HaJCBw1YZ0iQ/edit#slide=id.g2fda8e38e1e_1_0)  [Pluto Video](https://www.youtube.com/watch?v=IAF8DjrQSSk)|   [Random Variables As Types](https://computationalthinking.mit.edu/Fall24/data_science/random_variables_as_types/)                                                                                   |                                                                                                                                                                                                      |
| 3   | W   | 9/13  | Edelman           |   Let's Really Learn Julia Now                         | |   [Jeremiah's Nice C25 Tutorial](https://mit-c25-fall23.netlify.app/notebooks/0_julia_tutorial)                                                                                                                   
|4| M| 9/16| Edelman |  When do I prefer Jupyter to Pluto?  || [Jupyter Notebook: Julia is Fast](https://github.com/mitmath/JuliaComputation/blob/Fall24/notebooks/3_Julia%20is%20fast.ipynb) [Jupyter Notebook: Autodiff](https://github.com/mitmath/JuliaComputation/blob/Fall24/notebooks/4.%20AutoDiff.ipynb) 
|5|W|9/18| Edelman |Automatic Differentiation||  [Reverse Mode AutoDiff in Pluto](https://simeonschaub.github.io/ReverseModePluto/notebook.html) 
|6|M|9/23| Edelman | Ambiguous Multiple Dispatch, Discrete and Continuous||
|7|W|9/25| Edelman |||
|8|M|9/30| Student Projects |||
| Upcoming...|
|15|M|10/28| R. Ferrari |||
|16|W|10/30| R. Ferrari |||
||W| 11/27| Class Cancelled, Thanksgving Travel |||
| MOSTLY IGNORE BELOW|
| 4   | T   | 9/19  | Edelman           | Matrix Calculus                                      | [Matrix Calc 1](https://docs.google.com/presentation/d/1TGZ5I3ZP907-itZrslKF4miReNzV1dAOXNU4QMCHkd8/edit#slide=id.p)                              | [Matrix Jacobians](<https://mit-c25-fall22.netlify.app/notebooks/2_matrix_jacobians>), [Finite Differences](<https://mit-c25-fall22.netlify.app/notebooks/2_finite_differences>)                                                                                                                                                                                         |
| 5   | R   | 9/21  | Edelman           | Matrix Calculus                                      | [Matrix Calc 2](https://docs.google.com/presentation/d/1IuwijmdWCes1Quh1gJxbHoMbA50Tk0xxXnaPvu3tQjQ/edit#slide=id.g15504621cdd_0_0)               | [Linear Transformations](https://mit-c25-fall22.netlify.app/notebooks/3_linear_transformations), [Symmetric Eigenproblems](https://mit-c25-fall22.netlify.app/notebooks/3_symmetric_eigenvalue_derivatives)                                                                                                                                                              |
| 6   | T   | 9/26  | Edelman           | Differential Equations Lec 1                         |                                                                                                                                                   | [Time Stepping (background)](https://computationalthinking.mit.edu/Fall23/climate_science/time_stepping), [ODEs and parameterized types (main topic)](https://mit-c25-fall22.netlify.app/notebooks/3_symmetric_eigenvalue_derivatives), [Resistors and Stencils (touched on this)](https://computationalthinking.mit.edu/Fall23/climate_science/resistors_and_stencils/) |
| 7   | R   | 9/28  | Edelman           | Differential Equations Lec 2                         |                                                                                                                                                   |                                                                                                                                                                                                                                                                                                                                                                          |
| 8   | T   | 10/3  | Edelman           | Imaging and Convolutions                             |                                                                                                                                                   | [Image Transformation notebook](https://computationalthinking.mit.edu/Fall23/images_abstractions/transforming_images/)                                                                                                                                                                                                                                                   |
| 9   | R   | 10/5  | Edelman           | Imaging and Convolutions 2                           |                                                                                                                                                   | [Seam Carving notebook](https://computationalthinking.mit.edu/Fall23/images_abstractions/seamcarving/), [Linear Transformations notebook](https://computationalthinking.mit.edu/Fall23/images_abstractions/transformations2/)                                                                                                                                            |
|     | T   | 10/10 | *Student Holiday* |                                                      |                                                                                                                                                   |                                                                                                                                                                                                                                                                                                                                                                          |
| 10  | R   | 10/12 | Edelman           | HPC and GPUs                                         | [HPC and GPU Slides](https://docs.google.com/presentation/d/1i6w4p26r_9lu_reHYZDIVnzh-4SdERVAoSI5i42lBU8/edit?usp=sharing)                        |                                                                                                                                                                                                                                                                                                                                                                          |
| 11  | T   | 10/17 | Dalle             | Package development                                  |                                                                                                                                                   | [Challenge](https://gdalle.github.io/IntroJulia/challenge.html), [Good practices](https://modernjuliaworkflows.github.io/)                                                                                                                                                                                                                                               |
| 12  | R   | 10/19 | Dalle             | Performance                                          | [Quiz](https://app.wooclap.com/JULIAPERF)                                                                                                         | [Package creation](https://gdalle.github.io/IntroJulia/package.html), [Performance](https://gdalle.github.io/IntroJulia/performance.html)                                                                                                                                                                                                                                |
| 13  | T   | 10/24 | Dalle             | Graphs                                               | [Quiz](https://app.wooclap.com/JULIAGRAPHS)                                                                                                       | [Graphs](https://gdalle.github.io/IntroJulia/graphs.html)                                                                                                                                                                                                                                                                                                                |
| 14  | R   | 10/26 | Dalle             | Linear programming                                   | [Quiz](https://app.wooclap.com/JULIALP)                                                                                                           | [Linear programming](https://gdalle.github.io/IntroJulia/linear_programming.html)                                                                                                                                                                                                                                                                                        |
| 15  | T   | 10/31 | Ferrari           | Greenhouse Effect                                    |                                                                                                                                                   |                                                                                                                                                                                                                                                                                                                                                                          |
| 16  | R   | 11/2  | Ferrari           | Equilibrium and transient climate sensitivity        |                                                                                                                                                   | [Earth's Temperature Model](https://mit-c25-fall23.netlify.app/notebooks/Lecture16a) [Mean Surface Temp Modeling](https://mit-c25-fall23.netlify.app/notebooks/Lecture16b)                                                                                                                                                                                               |
| 17  | T   | 11/7  | Drake             | Economic Model of Climate                            | [Slides](slides_old/ClimateMARGO.pdf)                                                                                                             | [Economic Model](https://computationalthinking.mit.edu/Fall23/climate_science/inverse_climate_model/), [Optimization with JUMP](https://computationalthinking.mit.edu/Fall23/climate_science/optimization_with_JuMP/)                                                                                                                                                    |
| 18  | R   | 11/9  | Edelman           | Snowball Earth & Parallel/GPU computing              |                                                                                                                                                   | [Snowball Earth and hysteresis](https://computationalthinking.mit.edu/Fall23/climate_science/climate2_snowball_earth/)                                                                                                                                                                                                                                                   |
| 19  | T   | 11/14 | Persson           | Mesh Generation                                      | [Mesh generation](slides_old/mesh_generation.pdf)                                                                                                 | [Computational Geometry](https://mit-c25-fall22.netlify.app/notebooks/4_computational_geometry)                                                                                                                                                                                                                                                                          |
| 20  | R   | 11/16 | Persson           | Mesh Generation                                      |                                                                                                                                                   |                                                                                                                                                                                                                                                                                                                                                                          |
| 21  | T   | 11/21 | Edelman           | Floating-point Arithmetic                            |                                                                                                                                                   |                                                                                                                                                                                                                                                                                                                                                                          |
|     | R   | 11/23 | *Thanksgiving*    |                                                      |                                                                                                                                                   |                                                                                                                                                                                                                                                                                                                                                                          |
| 22  | T   | 11/28 | Klugman           | Fast inverse square root                             |                                                                                                                                                   | [Notebook](https://mit-c25-fall23.netlify.app/notebooks/fast_inv_sqrt)                                                                                                                                                                                                                                                                                                   |
| 23  | R   | 11/30 | Silvestri         | Climate Science                                      |                                                                                                                                                   | [Solving the climate system](https://mit-c25-fall22.netlify.app/notebooks/10_climate_science)                                                                                                                                                                                                                                                                            |
| 24  | T   | 12/5  | Silvestri         | Climate Science                                      |                                                                                                                                                   |                                                                                                                                                                                                                                                                                                                                                                          |
| 25  | R   | 12/7  | Edelman           | Discrete and Continuous, are they so very different? |                                                                                                                                                   |                                                                                                                                                                                                                                                                                                                                                                          |
| 26  | T   | 12/12 | Class Party       |                                                      |                                                                                                                                                   |                                                                                                                                                                                                                                                                                                                                                                          |
