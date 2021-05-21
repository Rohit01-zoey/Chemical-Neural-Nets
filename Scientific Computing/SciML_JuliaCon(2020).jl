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

using Plots
plot(sol)
plot(sol, vars = (1,2))

f(u, p,t) = 1.01*u
u0 = 1/2
tspan = (0.0,1.0)
prob = ODEProblem(f,u0,tspan)
sol = solve(prob)
plot(sol)

#!MY solution whats the error?????????????????????
α = 1.01
function linear_de!(du, u,p)
    r = u
    du = 1.01*r
end 
p = [1.5, 1.0, 3.0, 1.0]
u₀ = 1/2
t = (0.0, 1.0)
prob = ODEProblem(linear_de!, u₀, t)

sol = solve(prob,  Tsit5(), reltol=1e-8, abstol=1e-8)

#*---------------------------------
function lorentz!(du, u, p ,t)
    du[1] = 10.0*(u[2] - u[1])
    du[2] = u[1]*(28.0 - u[3]) - u[2]
    du[3] = u[1]*u[2] - (8/3)*u[3]
end

u₀ = [1.0; 0.0; 0.0]
t_span = (0.0, 100.0)
prob = ODEProblem(lorentz!, u₀, t_span)
sol = solve(prob)
plot(sol)
plot(sol, vars = (1,2 ,3))
plot(sol, vars = (1, 3))
plot(sol, vars = (0, 2))

function mult_noise!(du, u, p, t)
    r, w = u
    du[1] = 0.3*r
    du[2] = 0.3*w
    
end
prob = SDEProblem(latka_votlerra!,mult_noise!, u₀, t_span, p)
sol = solve(prob)

plot(sol)

eb = EnsembleProblem(prob)
sol = solve(eb,trajectories = 100)

plot(sol)
summ = EnsembleSummary(sol)
plot(summ)

τ = 1.0
function latka_votlerra!(du, u,h, p ,t)
    r, w = u
    delay_r = h(p, t-τ, idxs = 1)
    α, β, γ, δ = p
    du[1] = dr = α*delay_r - β*r*w
    du[2] = dw = γ*r*w - δ*w
end
u₀ = [1.0, 1.0]

t_span = (0.0, 10.0)
h(p, t) = [1.0, 1.0]
h(p, t; idxs = 1) = 1.0
p = [1.5, 1.0, 3.0, 1.0]

h(p, -0.5)

prob = DDEProblem(latka_votlerra!, u₀,h, t_span, p, constant_lag = [τ])
sol = solve(prob)

plot(sol)
#* Call back function
die_r_condition(u, t, integrator) = u[2] = 4
die_r_affect!(integator) = integator.u[2] -= 1
cb = ContinuousCallback(die_r_condition, die_r_affect!)
sol = solve(prob, callback = cb)
plot(sol)

