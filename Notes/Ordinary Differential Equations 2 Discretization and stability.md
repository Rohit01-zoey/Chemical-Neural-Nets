## 0.1. Linear Ordinary Differential Equations

The simplest ordinary differential equation is the scalar linear ODE, which
is given in the form

$$u' = \alpha u$$

We can solve this by noticing that $(e^{\alpha t})^\prime = \alpha e^{\alpha t}$
satisfies the differential equation and thus the general solution is:

$$u(t) = u(0)e^{\alpha t}$$

From the analytical solution we have that:

- If $Re(\alpha) > 0$ then $u(t) \rightarrow \infty$ as $t \rightarrow \infty$
- If $Re(\alpha) < 0$ then $u(t) \rightarrow 0$ as $t \rightarrow \infty$
- If $Re(\alpha) = 0$ then $u(t)$ has a constant or periodic solution.

This theory can then be extended to multivariable systems in the same way as the
discrete dynamics case. Let $u$ be a vector and have

$$u' = Au$$

be a linear ordinary differential equation. Assuming $A$ is diagonaliziable,
we diagonalize $A = P^{-1}DP$ to get

$$Pu' = DPu$$

and change coordinates $z = Pu$ so that we have

$$z' = Dz$$

which decouples the equation into a system of linear ordinary differential
equations which we solve individually. 
Notice that the diagonal matrix has the diagonal made up of the eigenvalues of the matrix $A$.

Thus we see that, similarly to the
discrete dynamical system, we have that:

- If all of the eigenvalues negative, then $u(t) \rightarrow 0$ as $t \rightarrow \infty$
- If any eigenvalue is positive, then $u(t) \rightarrow \infty$ as $t \rightarrow \infty$

## 0.2. Nonlinear Ordinary Differential Equations

As with discerte dynamical systems, the geometric properties extend locally to
the linearization of the continuous dynamical system as defined by:

$$u' = \frac{df}{du} u$$

where $\frac{df}{du}$ is the Jacobian of the system. This is a consequence of the Hartman-Grubman Theorem.

## 0.3. [Hartman Grubman Theorem](https://en.wikipedia.org/wiki/Hartman%E2%80%93Grobman_theorem)
> The theorem states that the behaviour of a dynamical system in a domain near a hyperbolic equilibrium point is qualitatively the same as the behaviour of its linearisation near this equilibrium point, where hyperbolicity means that no eigenvalue of the linearisation has real part equal to zero. 

Therefore, when dealing with such dynamical systems one can use the simpler linearisation of the system to analyse its behaviour around equilibria.

In simpler terms, 
$$f(u^{*}) = u^{*}$$
In other words if we are where the fixed point is then we  have the following :
$$u'|_{u = u^{*}} = 0$$
But we were are around the fixed point then how would the function behave:
$$ u' = f(u, p, t) $$
$$ u' \approx \frac{d f(u^{*})}{du} u$$
The above equation is basically linearizing the given DE.

So, now we look at the eigenvalues of $\frac{d f(u^{*})}{du}$
- If all of the eigenvalues negative, then soln goes towards steady state.
- If any eigenvalue is positive, then $u(t) \rightarrow \infty$.

---
---

# 1. Numerically Solving Ordinary Differential Equations

## 1.1. Euler's Method

To numerically solve an ordinary differential equation, one turns the continuous
equation into a discrete equation by *discretizing* it. The simplest discretization
is the *Euler method*. The Euler method can be thought of as a simple approximation
replacing $dt$ with a small non-infinitesimal $\Delta t$. Thus we can approximate

$$f(u,p,t) = u' = \frac{du}{dt} \approx \frac{\Delta u}{\Delta t}$$

and now since $\Delta u = u_{n+1} - u_n$ we have that

$$\Delta t f(u,p,t) = u_{n+1} - u_n$$

We need to make a choice as to where we evaluate $f$ at. The simplest approximation
is to evaluate it at $t_n$ with $u_n$ where we already have the data, and thus
we re-arrange to get

$$u_{n+1} = u_n + \Delta t f(u,p,t)$$

This is the Euler method.


We can interpret it more rigorously by looking at the Taylor series expansion.
First write out the Taylor series for the ODE's solution in the near future:

$$u(t+\Delta t) = u(t) + \Delta t u'(t) + \frac{\Delta t^2}{2} u''(t) + \ldots$$

Recall that $u' = f(u,p,t)$ by the definition of the ODE system, and thus we have
that

$$u(t+\Delta t) = u(t) + \Delta t f(u,p,t) + \mathcal{O}(\Delta t^2)$$

This is a first order approximation because the error in our step can be
expresed as an error in the derivative, i.e.

$$\frac{u(t + \Delta t) - u(t)}{\Delta t} = f(u,p,t) + \mathcal{O}(\Delta t)$$

Since the error is a first order eqn in $\Delta t$, we call Eulers method as first order approximation.

---
## Higher Order Methods

We can use this analysis to extend our methods to higher order approximation
by simply matching the Taylor series to a higher order. Intuitively, when we
developed the Euler method we had to make a choice:

$$u_{n+1} = u_n + \Delta t f(u,p,t)$$

where do we evaluate $f$? One may think that the best derivative approximation
my come from the middle of the interval, in which case we might want to evaluate
it at $t + \frac{\Delta t}{2}$. To do so, we can use the Euler method to
approximate the value at $t + \frac{\Delta t}{2}$ and then use that value to
approximate the derivative at $t + \frac{\Delta t}{2}$. This looks like:

$$k_1 = f(u_n,p,t) $$
$$u_{n+1/2} = u_{n} + \frac{\Delta t}{2} f(u_{n}, p, t)\implies u_{n+1/2} = u_{n} + \frac{\Delta t}{2} k_1$$
Thus, the value of the derivative at $u_{n+1/2}$ defined by $k_2$ is given by 
$$k_2 = f(u_n + \frac{\Delta t}{2} k_1,p,t + \frac{\Delta t}{2})$$
$$u_{n+1} = u_n + \Delta t k_2$$
which we can also write as:

$$
u_{n+1} = u_n + \Delta t f(t + \frac{\Delta t}{2},u_n + \frac{\Delta t}{2} f_n)
$$

where $f_n = f(u_n,p,t)$.

>In simpler words we approximate the value of the derivative at the time point $t + \frac{\Delta t}{2}$ using Eulers method and then assume that this is the true value of the derivative in the nbd $(t, t + \Delta t)$ and use this value in approximating $u_{n+1}$

>Notice that this is different from taking 2 time steps( in which case we would have had $\frac{\Delta t}{2}$). That is we would have had the following equations: $$u_{n+1/2} = u_{n} + \frac{\Delta t}{2} f(u_{n}, p, t)$$ and similarly for $$u_{n+1} = u_{n+1/2} + \frac{\Delta t}{2}  f(u_{n+1/2}, p, t)$$


> Definition:  $n^{th}$ -degree Taylor Polynomial for a function of two variables
> 
> For a function of two variables  $f(x,y)$  whose partials all exist to the  $n^{th}$  partials at the point  $(a,b)$ , the  $n^{th}$ -degree Taylor polynomial of  $f$  for  $(x,y)$  near the point  $(a,b)$  is:
> $$P_n(x,y) = \sum_{i=0}^n \sum_{j=0}^{n - i} \frac{\frac{d^{(i+j)}f}{∂x^i∂y^{j}}(a,b) }{i!j!}(x-a)^i(y-b)^j $$ 

 If we do the two-dimensional Taylor expansion we get:

$$
u_{n+1} = u_n + \Delta t f_n + \frac{\Delta t^2}{2}(f_t + f_u f)(u_n,p,t)+ 
\frac{\Delta t^3}{6} (f_{tt} + 2f_{tu}f + f_{uu}f^2)(u_n,p,t)
$$ (????)

which when we compare against the true Taylor series:

$$
u(t+\Delta t) = u_n + \Delta t f(u_n,p,t) + \frac{\Delta t^2}{2}(f_t + f_u f)(u_n,p,t)
+ \frac{\Delta t^3}{6}(f_{tt} + 2f_{tu} + f_{uu}f^2 + f_t f_u + f_u^2 f)(u_n,p,t)
$$ (?????)

and thus we see that

$$
u(t + \Delta t) - u_n = \mathcal{O}(\Delta t^3)
$$

Thus, we get the following : 
$$\frac{u(t + \Delta t) - u(t)}{\Delta t} = f(u,p,t) + \mathcal{O}(\Delta t ^2)$$
Since we get $\mathcal{O}(\Delta t ^2)$ as the error much better than $\mathcal{O}(\Delta t)$.

>Notice that in the above methods we assume that the derivative is constant for t = t to to = t + $\Delta t$
---

## Runge-Kutta Methods

More generally, Runge-Kutta methods are of the form:

$$
k_1 = f(u_n,p,t)\\
k_2 = f(u_n + \Delta t (a_{21} k_1),p,t + \Delta t c_1)\\
k_3 = f(u_n + \Delta t (a_{31} k_1 + a_{32} k_2),p,t + \Delta t c_2)\\
\vdots \\
u_{n+1} = u_n + \Delta t (b_1 k_1 + \ldots + b_s k_s)
$$

where $s$ is the number of stages. These tableaus can be expressed as a tableau:

![](https://en.wikipedia.org/wiki/List_of_Runge%E2%80%93Kutta_methods)

The order of the Runge-Kutta method is simply the number of terms in the Taylor
series that ends up being matched by the resulting expansion. For example, for
the 4th order you can expand out and see that the following equations need to
be satisfied:

![](https://user-images.githubusercontent.com/1814174/95117136-105ae780-0716-11eb-9f6a-49fecf7adbeb.PNG)

The classic Runge-Kutta method is also known as RK4 and is the following 4th
order method:

$$
k_1 = f(u_n,p,t)\\
k_2 = f(u_n + \frac{\Delta t}{2} k_1,p,t + \frac{\Delta t}{2})\\
k_3 = f(u_n + \frac{\Delta t}{2} k_2,p,t + \frac{\Delta t}{2})\\
k_4 = f(u_n + \Delta t k_3,p,t + \Delta t)\\
u_{n+1} = u_n + \frac{\Delta t}{6}(k_1 + 2 k_2 + 2 k_3 + k_4)\\
$$

> Notice that in the above calculaltions we are finding the approximation of u' at the midpoint by using Euler's method again and again.

While it's widely known and simple to remember, it's not necessarily good. The
way to judge a Runge-Kutta method is by looking at the size of the coefficient
of the next term in the Taylor series: if it's large then the true error can
be larger, even if it matches another one asymtopically.

# What Makes a Good Method?

## Leading Truncation Coeffcients

For given orders of explicit Runge-Kutta methods, lower bounds for the number of
`f` evaluations (stages) required to receive a given order are known:

![](https://user-images.githubusercontent.com/1814174/95117078-f8836380-0715-11eb-9acf-0626338307d1.PNG)

While uninuitive, using the method is not necessarily the one that reduces the
coefficient the most. The reason is because what is attempted in ODE solving
is precisely the opposite of the analysis. In the ODE analysis, we're looking at
behavior as $\Delta t \rightarrow 0$. However, when efficiently solving ODEs, we
want to use the largest $\Delta t$ which satisfies error tolerances.

The most widely used method is the Dormand-Prince 5th order Runge-Kutta method,
whose tableau is represented as:

![](http://rotordynamics.files.wordpress.com/2014/05/new-picture6.png)

Notice that this method takes 7 calls to `f` for 5th order. The key to this method
is that it has optimized leading truncation error coefficients, under some extra
assumptions which allow for the analysis to be simplified.

### Looking at the Effects of RK Method Choices and Code Optimizations

Pulling from the [SciML Benchmarks](https://github.com/SciML/SciMLBenchmarks.jl),
we can see the general effect of these different properties on a given set of
Runge-Kutta methods:

![](https://user-images.githubusercontent.com/1814174/95118000-7c8a1b00-0717-11eb-8080-2179da500cd2.PNG)

Here, the order of the method is given in the name. We can see one immediate factor
is that, as the requested error in the calculation decreases, the higher order
methods become more efficient. This is because to decrease error, you decrease
$\Delta t$, and thus the exponent difference with respect to $\Delta t$ has more
of a chance to pay off for the extra calls to `f`. Additionally, we can see that
order is not the only determining factor for efficiency: the Vern8 method seems
to have a clear approximate 2.5x performance advantage over the whole span of the
benchmark compared to the DP8 method, even though both are 8th order methods.
This is because of the leading truncation terms: with a small enough $\Delta t$,
the more optimized method (Vern8) will generally have low error in a step for the
same $\Delta t$ because the coefficients in the expansion are generally smaller.

This is a factor which is generally ignored in high level discussions of
numerical differential equations, but can lead to orders of magnitude differences!
This is highlighted in the following plot:

![](https://user-images.githubusercontent.com/1814174/95118457-544eec00-0718-11eb-8c19-f402e2cb8842.PNG)

Here we see ODEInterface.jl's ODEInterfaceDiffEq.jl wrapper into the SciML
common interface for the standard `dopri` method from Fortran, and ODE.jl, the
original ODE solvers in Julia, have a performance disadvantage compared to the
DifferentialEquations.jl methods due in part to some of the coding performance
pieces that we discussed in the first few lectures.

Specifically, a large part of this can be attributed to inlining of the higher order
functions, i.e. ODEs are defined by a user function and then have to be called
from the solver. If the solver code is compiled as a shared library ahead of
time, like is commonly done in C++ or Fortran, then there can be a function
call overhead that is eliminted by JIT compilation optimizing across the
function call barriers (known as interprocedural optimization). This is one way
which a JIT system can outperform an AOT (ahead of time) compiled system in
real-world code (for completeness, two other ways are by doing full function
specialization, which is something that is [not generally possible in AOT
languages given that you cannot know all types ahead of time for a fully generic
function](https://scalac.io/specialized-generics-object-instantiation/),
and [calling C itself, i.e. c-ffi (foreign function interface), can be optimized
using the runtime information of the JIT compiler to outperform C!](https://github.com/dyu/ffi-overhead#results-500m-calls)).

The other performance difference being shown here is due to optimization of the
method. While a slightly different order, we can see a clear difference in the
performance of RK4 vs the coefficient optimized methods. It's about the same
order of magnitude as "highly optimized code differences", showing that what's
different about a both the Runge-Kutta coefficients and the code implementation
can both have a significant impact on performance.

Taking a look at what happens when interpreted languages get involved highlights
some of the code challenges in this domain. Let's take a look at for example the
results when simulating 3 ODE systems with the various RK methods:

![](https://user-images.githubusercontent.com/1814174/95131785-b1549d00-072c-11eb-8d2a-490f69a4b99f.PNG)

We see that using interpreted languages introduces around a 50x-100x performance
penalty. If the you recall in your previous lecture, the discrete dynamical
system that was being simulated was the 3-dimensional Lorenz equation discretized
by Euler's method, meaning that the performance of that implementation is a good
proxy for understanding the performance differences in this graph. Recall that
in previous lectures we saw an approximately 5x performance advantage when
specializing on the system function and size and around 10x by reducing
allocations: these features account for the performance differences noticed
between library implementations, which are then compounded by the use of
different RK methods (note that R uses "call by copy" which even further increases
the memory usages and makes standard usage of the language incompatible with
mutating function calls!).

### Stability of a Method

Simply having an order on the truncation error does not imply convergence of the
method. The disconnect is that the errors at a given time point may not dissipate.
What also needs to be checked is the asymtopic behavior of a disturbance. To
see this, one can utilize the linear test problem:

$$u' = \alpha u$$

and ask the question, does the discrete dynamical system defined by the
discretized ODE end up going to zero? You would hope that the discretized
dynamical system and the continuous dynamical system have the same properties
in this simple case, and this is known as linear stability analysis of the
method.

As an example, take a look at the Euler method. Recall that the Euler method
was given by:

$$u_{n+1} = u_n + \Delta t f(u_n,p,t)$$

When we plug in the linear test equation, we get that

$$u_{n+1} = u_n + \Delta t \alpha u_n$$

If we let $z = \Delta t \alpha$, then we get the following:

$$u_{n+1} = u_n + z u_n = (1+z)u_n$$

which is stable when $z$ is in the shifted unit circle. This means that, as a
necessary condition, the step size $\Delta t$ needs to be small enough that
$z$ satisfies this condition, placing a stepsize limit on the method.

![](https://user-images.githubusercontent.com/1814174/95117231-3c766880-0716-11eb-9069-039253bcebda.PNG)

If $\Delta t$ is ever too large, it will cause the equation to overshoot zero,
which then causes oscillations that spiral out to infinity.

![](https://user-images.githubusercontent.com/1814174/95132604-0d6bf100-072e-11eb-8af5-663512a0db14.PNG)

![](https://user-images.githubusercontent.com/1814174/95132963-9125dd80-072e-11eb-878e-61f77a20d03e.gif)

Thus the stability condition places a hard constraint on the allowed $\Delta t$
which will result in a realistic simulation.

For reference, the stability regions of the 2nd and 4th order Runge-Kutta methods
that we discussed are as follows:

![](https://user-images.githubusercontent.com/1814174/95117286-56b04680-0716-11eb-9c6a-07fc4d190a09.PNG)

### Interpretation of the Linear Stability Condition

To interpret the linear stability condition, recall that the linearization of
a system interprets the dynamics as locally being due to the Jacobian of the
system. Thus

$$u' = f(u,p,t)$$

is locally equivalent to

$$u' = \frac{df}{du}u$$

You can understand the local behavior through diagonalizing this matrix. Therefore,
the scalar for the linear stability analysis is performing an analysis on the
eigenvalues of the Jacobian. The method will be stable if the largest eigenvalues
of df/du are all within the stability limit. This means that stability effects
are different throughout the solution of a nonlinear equation and are generally
understood locally (though different more comprehensive stability conditions
exist!).

### Implicit Methods

If instead of the Euler method we defined $f$ to be evaluated at the future
point, we would receive a method like:

$$u_{n+1} = u_n + \Delta t f(u_{n+1},p,t+\Delta t)$$

in which case, for the stability calculation we would have that

$$u_{n+1} = u_n + \Delta t \alpha u_n$$

or

$$(1-z) u_{n+1} = u_n$$

which means that

$$u_{n+1} = \frac{1}{1-z} u_n$$

which is stable for all $Re(z) < 0$ a property which is known as A-stability.
It is also stable as $z \rightarrow \infty$, a property known as L-stability.
This means that for equations with very ill-conditioned Jacobians, this method
is still able to be use reasonably large stepsizes and can thus be efficient.

![](https://user-images.githubusercontent.com/1814174/95117191-28326b80-0716-11eb-8e17-889308bdff53.PNG)

### Stiffness and Timescale Separation

From this we see that there is a maximal stepsize whenever the eigenvalues
of the Jacobian are sufficiently large. It turns out that's not an issue if
the phonomena we fast to see is fast, since then the total integration time
tends to be small. However, is we have some equations with both fast modes
and slow modes, like the Robertson equation, then it is very difficult because
in order to resolve the slow dynamics over a long timespan, one needs to ensure
that the fast dynamics do not diverge. This is a property known as stiffness.
Stiffness can thus be approximated in some sense by the condition number of
the Jacobian. The condition number of a matrix is its maximal eigenvalue divided
by its minimal eigenvalue and gives an rough measure of the local timescale
separations. If this value is large and one wants to resolve the slow dynamics,
then explict integrators, like the explicit Runge-Kutta methods described before,
have issues with stability. In this case implicit integrators (or other forms
of stabilized stepping) are required in order to efficiently reach the end
time step.

![](https://user-images.githubusercontent.com/1814174/95132552-f6c59a00-072d-11eb-881e-24364b7b728f.PNG)

## Exploiting Continuity

So far, we have looked at ordinary differential equations as a $\Delta t \rightarrow 0$
formulation of a discrete dynamical system. However, continuous dynamics and
discrete dynamics have very different characteristics which can be utilized in
order to arrive at simpler models and faster computations.

### Geometric Properties: No Jumping and the Poincaré–Bendixson theorem

In terms of geometric properties, continuity places a large constraint on the
possible dynamics. This is because of the physical constraint on "jumping", i.e.
flows of differential equations cannot jump over each other. If you are ever
at some point in phase space and $f$ is not explicitly time-dependent, then
the direction of $u'$ is uniquely determined (given reasonable assumptions on
$f$), meaning that flow lines (solutions to the differential equation) can never
cross.

A result from this is the Poincaré–Bendixson theorem, which states that, with
any arbitrary (but nice) two dimensional continuous system, you can only have
3 behaviors:

- Steady state behavior
- Divergence
- Periodic orbits

A simple proof by picture shows this.