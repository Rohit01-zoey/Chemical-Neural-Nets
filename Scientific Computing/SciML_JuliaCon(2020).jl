#* Univeral Approx. Thm:  Any Neural net can get ϵ close to any polynomial function
#* SInDy : Sparse Indentification of Dynamical Systems
#* Discretization
#* Stiffness of a DE

using DifferentialEquations

#! Lotka Votlerra DE

function latka_votlerra!(du, u, p ,t)
    r, w = u
    α, β, γ, δ = p
    du[1] = dr = α*r - β*r*w
    du[2] = dw = γ*r*w - δ*w
end

u₀ = [1.0, 1.0]

t_span = (0.0, 10.0)

p = [1.5, 1.0, 3.0, 1.0]
prob = ODEProblem(latka_votlerra!, u₀, t_span, p)

sol = solve(prob)

f(u, p,t) = 1.01*u
u0 = 1/2
tspan = (0.0,1.0)
prob = ODEProblem(f,u0,tspan)
sol = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-2)
