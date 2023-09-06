# Julia: Solving Real-World Problems with Computation, Fall 2023 (under construction)

## Logistics

**MIT's numbering scheme gone nuts:** (1.C25/6.C25/12.C25/16.C25/18.C25/22.C25)  
This course is part of the [Common Ground](https://computing.mit.edu/cross-cutting/common-ground-for-computing-education/common-ground-subjects/).  

**Lectures:** Tuesdays & Thursdays 1-2:30 PM in room 2-142 

**Prerequisites:** 6.100A, 18.03, 18.06 or equivalents (meaning some programming, dif eqs, and lin alg) 

**Instructors:** A. Edelman, R. Ferrari, Y. Marzouk, P. Persson (UCB), S. Silvestri, J. Urschel, J. Williams  
**Teaching Assistants:** 
**Office Hours:** TBD

**Grading:** Homeworks that may be spaced one or two weeks, to be submitted on canvas. No exams.  
**Lecture Recordings:** Available on Canvas under the Panopto Video tab. Should be published the evening after each lecture.  
**Links:** Worth bookmarking.  

| [Piazza](https://piazza.com/mit/fall2022/179e6) | [Canvas](https://canvas.mit.edu/courses/15758) | [Julia](https://julialang.org/) | [JuliaHub](https://juliahub.com/ui/Home) |
| ----------------------------------------------- | ---------------------------------------------- | ------------------------------- | ---------------------------------------- |
| Discussion                                      | HW submission                                  | Language                        | GPUs                                     |

## Description

Focuses on algorithms and techniques for writing and using modern technical software in a job, lab, or research group environment that may consist of interdisciplinary teams, where performance may be critical, and where the software needs to be flexible and adaptable. Topics include automatic differentiation, matrix calculus, scientific machine learning, parallel and GPU computing, and performance optimization with introductory applications to climate science, economics, agent-based modeling, and other areas. Labs and projects focus on performant, readable, composable algorithms and software. Programming will be in Julia. Expects students have some familiarity with Python, Matlab, or R. No Julia experience necessary.

Counts as an elective for CEE students, an advanced subject (18.100 and higher) for Math students, an advanced elective for EECS students, and a computation restricted elective for NSE students. AeroAstro students can petition department to count this class as a professional subject in the computing area.
(Professors may be open to petitioning for counting for other programs.)

Class is appropriate for those who enjoy math and wish to see math being used in modern contexts.

While not exactly the same as our past [Computational Thinking Class](https://computationalthinking.mit.edu/Spring21/)... not entirely different either.

## Homeworks at a glance

| Homework                                                                                               | Assigned | Due    | Topic                                             |
| ------------------------------------------------------------------------------------------------------ | -------- | ------ | ------------------------------------------------- |
| [HW0](https://mit-c25.netlify.app/homeworks/hw0)                                                       | Sep 7    | Sep 14 | Getting Started                                   |

Each student gets to turn in one homework late without justification.
Further late turn ins must be justified.
Remember: just because the automated tests succeed doesn't mean your code is 100% correct.
It is a necessary, but not sufficient condition.

Homework solutions will be put online after each deadline.

## Lectures at a glance   (based on the 2022 class, will be modified based on students' interest this year)

| #      | Day | Date  | Lecturer                        | Topic                                                | Slides / Notes                                                                                                                                                                                                       | Notebooks                                                                                                                                                                                                   |
| ------ | --- | ----- | ------------------------------- | ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0      |     |       | TAs                             | Julia tutorial                                       | [Cheat Sheets](https://computationalthinking.mit.edu/Fall23/cheatsheets/)                                                                                                                                            | [Intro to Julia](https://gdalle.github.io/IntroJulia/), [Tutorial](https://mit-c25.netlify.app/notebooks/0_julia_tutorial)                                                                                  |
| 1      | R   | 9/7| Edelman                         | Intro to Julia                                       |                                                                                                                                                                                                                      | [Hyperbolic Corgi](https://mit-c25.netlify.app/notebooks/1_hyperbolic_corgi), [Images](https://mit-c25.netlify.app/notebooks/1_images), [Abstraction](https://mit-c25.netlify.app/notebooks/1_abstraction), |
| 2      | T   | 9/12 | Edelman                         | Matrix Calculus                                      | [Matrix Calc 1](https://docs.google.com/presentation/d/1TGZ5I3ZP907-itZrslKF4miReNzV1dAOXNU4QMCHkd8/edit#slide=id.p)                                                                                                 | [Matrix Jacobians](<https://mit-c25.netlify.app/notebooks/2_matrix_jacobians>), [Finite Differences](<https://mit-c25.netlify.app/notebooks/2_finite_differences>)                                          |
| 3      | R   | 9/14  | Edelman                         | Matrix Calculus                                      | [Matrix Calc 2](https://docs.google.com/presentation/d/1IuwijmdWCes1Quh1gJxbHoMbA50Tk0xxXnaPvu3tQjQ/edit#slide=id.g15504621cdd_0_0)                                                                                  | [Linear Transformations](https://mit-c25.netlify.app/notebooks/3_linear_transformations), [Symmetric Eigenproblems](https://mit-c25.netlify.app/notebooks/3_symmetric_eigenvalue_derivatives)               |
| 4      | T   | 9/19  | Edelman                         | Automatic Differentiation                            | [Scribed notes](https://hackmd.io/L2asbUw4RMCtGbknFOmTWw)                                                                                                                                                            |
| 5      | R   | 9/21  | Edelman                         | Automatic Differentiation                            | [Handwritten Notes (to be improved)](https://github.com/mitmath/JuliaComputation/blob/main/slides/ad_handwritten.pdf)                                                                                                | [Reverse Mode AutoDiff Demo](https://simeonschaub.github.io/ReverseModePluto/notebook.html)                                                                                                                 |
| 6      | T   | 9/26  | Persson                         | Mesh Generation                                      | [Mesh generation](slides/mesh_generation.pdf)                                                                                                                                                                        | [Computational Geometry](https://mit-c25.netlify.app/notebooks/4_computational_geometry)                                                                                                                    |
| 7      | R   | 9/28  | Persson                         | Mesh Generation                                      |                                                                                                                                                                                                                      |
| 8      | T   | 10/3  | Ferrari                         | Greenhouse Effect                                    |                                                                                                                                                                                                                      | [Greenhouse effect](https://mit-c25.netlify.app/notebooks/8_greenhouse_effect)                                                                                                                              |
| 9      | R   | 10/5  | Ferrari                         | Equilibrium and transient climate sensitivity        |                                                                                                                                                                                                                      | [Climate sensitivity](https://mit-c25.netlify.app/notebooks/9_climate_sensitivity.html)                                                                                                                     |
|        | T   | 10/10 | *Student Holiday*               |                                                      |
| 10     | R   | 10/12 | Silvestri                       | Climate Science                                      |                                                                                                                                                                                                                      | [Solving the climate system](https://mit-c25.netlify.app/notebooks/10_climate_science)                                                                                                                      |
| 11     | T   | 10/17 | Silvestri                       | Climate Science                                      |                                                                                                                                                                                                                      |                                                                                                                                                                                                             |
| 12     | R   | 10/19 | Edelman                         | Economic Model of Climate                            |                                                                                                                                                                                                                      | [Economic Model](https://computationalthinking.mit.edu/Spring21/inverse_climate_model/), [Optimization with JUMP](https://computationalthinking.mit.edu/Spring21/optimization_with_JuMP/)                   |
| 13     | T   | 10/24 | Edelman                         | HPC and GPUs                                         | [HPC and GPU Slides](https://docs.google.com/presentation/d/1i6w4p26r_9lu_reHYZDIVnzh-4SdERVAoSI5i42lBU8/edit?usp=sharing)                                                                                           | [N-body with FLoops](https://mit-c25.netlify.app/notebooks/floop_nbody), [JuliaHub demo](https://mit-c25.netlify.app/notebooks/juliahub_in_class_110122)                                                    |
| 14     | R   | 10/26 | Edelman                         | HPC and GPUs                                         |
| 15     | T   | 10/31 | Edelman                         | Imaging and Convolutions                             |
| 16     | R   | 11/2  | Edelman                         | Convolutions and PDEs                                |
| 17     | T   | 11/7 |                        | Handling Satellite Climate Data                      | [Lesson plan](https://docs.google.com/document/d/1G_FKAgjBiHD4XdCW6kH5-x_3rz2JiCIkil5xIxT0eEg/edit), [Problem set](https://docs.google.com/document/d/1AAsKg9ZclFNPI_vDZP-9FVif8qBwBLvonIS-DBu4c7k/edit?usp=sharing) |
| 18     | R   | 11/9 |                        | Apache Arrow in Julia for massive datastores         | [Lesson plan](https://docs.google.com/document/d/15DKYzkX00B8ottqq-Qv51oo30iU3VJezu0U82R-1EJk/edit)                                                                                                                  |
| 19     | T   | 11/14 | Dalle                           | Good programming practices + challenge               |                                                                                                                                                                                                                      | [Good practices](https://mit-c25.netlify.app/notebooks/gdalle/good_practices), [Challenge](https://mit-c25.netlify.app/notebooks/gdalle/challenge)                                                          |
| 20     | R   | 11/16 | Dalle                           | Performance recap + graph representations            |                                                                                                                                                                                                                      | [Performance](https://mit-c25.netlify.app/notebooks/gdalle/performance), [Graphs](https://mit-c25.netlify.app/notebooks/gdalle/graphs)                                                                      |
| 21     | T   | 11/21| Dalle                           | Formulating and solving linear programs              |                                                                                                                                                                                                                      | [Linear programming](https://mit-c25.netlify.app/notebooks/gdalle/linear_programming)                                                                                                                       |
|        | R   | 11/23| *Thanksgiving*                  |                                                      |
| 22     | T   | 11/28 | Dalle                           | Implicit differentiation                             | [Paper](https://arxiv.org/abs/2105.15183), [Talk](https://youtu.be/TkVDcujVNJ4)                                                                                                                                      | [Package](https://github.com/gdalle/ImplicitDifferentiation.jl)                                                                                                                                             |                                                                                                                                                    |
| 23     | R   | 11/30  | Urschel                         | Computational sports mathematics                     |
| 24     | T   | 12/5  | Urschel                         | Computational sports mathematics                     |
| 25     | R   | 12/7  | Edelman                         | Discrete and Continuous, are they so very different? |                                                                                                                                                                                                                      |
| 26     | T   | 12/12 | Class Party                    |                                                      |


