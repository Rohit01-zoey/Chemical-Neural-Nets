using Flux

NNODE = Chain(x -> [x], 
              Dense(1, 32, tanh),
              Dense(32, 1),
              first)

NNODE(1.0)

#! Flux Practice

x = [1 2; 3 4]

zeros(5, 5) .+ (1:5)
zeros(5, 5) .+ (1:5)'
(1:5)

rand(3,3)
randn(5, 5)

using BenchmarkTools
x = rand(5, 10)
y = randn(10)
@btime x*y


f(x) = 3x^2 + 2x + 6

df(x)  = gradient(f, x)
df(1)

myloss(W, b, x) = sum(W*x .+ b)

optim(W, b, x) = gradient(myloss, W, b, x)
W = randn(3, 5)
b = zeros(3)
x = rand(5)

optim(W, b, x)[3]

W = randn(3, 5)
b = zeros(3)
x = rand(5)

yy(x) = sum(W * x .+ b)
using Flux: params
grads = gradient(() -> yy(x),params([W, b]))

grads[W]
grads[b]

m = Dense(10, 5)
params(m)

x = rand(Float32, 10)

m = Chain(Dense(10, 5, relu), Dense(5, 2), softmax)

l(x) = Flux.Losses.crossentropy(m(x), [0.5, 0.5])
grads = gradient(params(m)) do 
    l(x)
    
end

for p in params(m)
    println(grads[p])
end