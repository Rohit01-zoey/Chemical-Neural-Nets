### Linear Ordinary Differential Equations

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
equations which we solve individually. Thus we see that, similarly to the
discrete dynamical system, we have that:

- If all of the eigenvalues negative, then $u(t) \rightarrow 0$ as $t \rightarrow \infty$
- If any eigenvalue is positive, then $u(t) \rightarrow \infty$ as $t \rightarrow \infty$

### Nonlinear Ordinary Differential Equations

As with discerte dynamical systems, the geometric properties extend locally to
the linearization of the continuous dynamical system as defined by:

$$u' = \frac{df}{du} u$$

where $\frac{df}{du}$ is the Jacobian of the system. This is a consequence of
the Hartman-Grubman Theorem.