using Flux

NNODE = Chain(x -> [x],
               Dense(1, 32, tanh),
               Dense(32, 1),
               first)

NNODE(1.0)

g(t) = t*NNODE(t) + 1f0 #* Universal Approximator

using Statistics

ϵ = sqrt(eps(Float32))  #! why square root FOR LATER

loss() = mean(abs2(((g(t+ϵ) - g(t))/ϵ) - cos(2π*t)) for t in 0:1f-2:1f0)

opt = Flux.Descent(0.01)
data = Iterators.repeated((), 5000)
iter = 0
cb = function()
    global iter += 1
    if iter%500==0
        display(loss())
    end
end 

display(loss())

Flux.train!(loss, Flux.params(NNODE), data, opt; cb=cb)

using Plots

t = 0:0.001:1.0
plot(t, g.(t), label = "NN")
plot!(t, 1.0 .+ sin.(2π.*t)/2π, label = "True Solution")

using DifferentialEquations

NNForce = Chain(x -> [x],
                Dense(1, 32, tanh),
                Dense(32, 1),
                first)
k = 2
random_pos = [2rand() - 1 for _ in 1:100]
loss_ode() = sum(abs2, NNForce(x) - (-k*x) for x in random_pos)

loss_ode()