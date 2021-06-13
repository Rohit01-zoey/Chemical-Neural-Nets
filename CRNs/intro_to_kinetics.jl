using Catalyst

rn = @reaction_network begin
    α, S + I --> 2I
    β, I --> R
end α β

using DiffEqBase, OrdinaryDiffEq

p     = [.1/1000, .01]           # [α,β] i.e the reaction rates.
tspan = (0.0,250.0)
u0    = [999.0,1.0,0.0]          # [S,I,R] at t=0
op    = ODEProblem(rn, u0, tspan, p)
sol   = solve(op, Tsit5())       # use Tsit5 ODE solver

using Plots
plot(sol, lw=2)