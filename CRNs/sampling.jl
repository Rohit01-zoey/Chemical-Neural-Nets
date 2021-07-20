function cdf_inv(λ, y_0)
     return -log(1-y_0)/λ
 end

cdf_inv(0.1, 0.3)

using Distributions
u = rand(Uniform(0, 1))
λ = 0.0
cdf_inv(λ, u)
arr_1 = []
for _ in 1:1000
    u = rand(Uniform(0, 1))
    push!(arr_1, cdf_inv(λ, u))
end

arr_1

using Plots

histogram(arr_1)

λ = 1.0
cdf_inv(λ, u)
arr_2 = []
for _ in 1:1000
    u = rand(Uniform(0, 1))
    push!(arr_2, cdf_inv(λ, u))
end

arr_2
histogram!(arr_2)


λ = 1.5
cdf_inv(λ, u)
arr_3 = []
for _ in 1:10000
    u = rand(Uniform(0, 1))
    push!(arr_3, cdf_inv(λ, u))
end

arr_3

histogram!(arr_3)

e = rand(Exponential(0.5))
arr_4 = []
for _ in 1:10000
    push!(arr_4, rand(Exponential(0.5)))
end

arr_4

histogram(arr_4)

using BenchmarkTools
arr_4 = []
function exp_ours!(arr_4)
    for _ in 1:10000
        push!(arr_4, rand(Exponential(0.5)))
    end
end

@btime exp_ours!(arr_4)

λ= 0.5
arr_2 = []
function exp_theirs!(arr_2)
    for _ in 1:10000
        u = rand(Uniform(0, 1))
        push!(arr_2, cdf_inv(λ, u))
    end
end

@btime exp_theirs!(arr_2)
