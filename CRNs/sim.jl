#X+Y --> 2X  (k1)
# 2Y --> X  (k2)
using Distributions
using Plots
function my_range(lower, upper)
    arr = []
    stoppage = upper-lower+1
    iter = upper
    while iter>stoppage
        push!(arr, iter)
        iter -= one(upper)
    end
    push!(arr, stoppage)
    return arr
end

function choose(i, j)
    if(j!=0 && i!=0)
        num = one(i)
        den = one(i)
        for l in my_range(j, i)
            num *= l
        end
        for l in my_range(j,j)
            den *= l
        end
    elseif (j!=0 && i<j)
        num=0
        den = 1

    elseif j==0
        num = 1
        den = 1
    end
      return num/den end


function propensity(k, x, y, coef_x, coef_y)
    prop = k * choose(x, coef_x) * choose(y, coef_y)
    return prop
end



x = 1000
y = 500
s = [1000.0, 500.0]
k1 = 1
k2 = 10
λ1 = propensity(k1, s[1], s[2], 1, 1)
λ2 = propensity(k2, s[1], s[2], 0, 2)

π1 = λ1/(λ1 + λ2)
π2 = λ2/(λ1 + λ2)

δ1 = [1, -1]
δ2 = [1, -2]

state_x = [s[1]]
state_y = [s[2]]
for _ in 1:300
    λ1 = propensity(k1, s[1], s[2], 1, 1)
    λ2 = propensity(k2, s[1], s[2], 0, 2)
    e1 = rand(Exponential(λ1))
    e2 = rand(Exponential(λ2))
    if (e1 > e2)
        s = s .+ δ2
    else
        s = s .+ δ1
    end
    #=
    π1 = λ1/(λ1 + λ2)
    π2 = λ2/(λ1 + λ2)


    if(π1 > π2)
        s = s .+ δ1
    else
        s = s.+ δ2
    end
=#
    push!(state_x, s[1])
    push!(state_y, s[2])
end


plot(state_x, state_y)

#-------------
#For the next set of reactions:
function propensity(k, s, coef)
    @assert length(s)==length(coef)
    prop = k
    for i in 1:length(s)
        prop *= choose(s[i], coef[i])
    end
    return prop
end


#for the given rxn we define the properties as [E, P, S, SE]
s° = [100.0, 0, 301., 0]
s = s° # the species of the rxn
#defining the coefficient matrix [γ1, γ2, γ3]^T
γ1 = [1, 0, 1, 0]
γ2 = [0, 0, 0, 1]
γ3 = [0, 0, 0, 1]

#defining the direction matrix
δ1 = [-1, 0, -1, 1]
δ2 = [1, 0, 1, -1]
δ3 = [1, 1, 0, -1]

#defining the rate constant matrix
c = [0.00166,0.0001,0.1]


#defing the probability constant
λ1 = propensity(c[1], s, γ1)
λ2 = propensity(c[2], s, γ2)
λ3 = propensity(c[3], s, γ3)

state_e = [s[1]]
state_p = [s[2]]
state_s = [s[3]]
state_se = [s[4]]

#Exponential doesnt allow λ to go to 0, hence had to take the normal way.

function exponential_my(λ)
    return -log(1-rand(Uniform(0, 1)))/λ
end
for _ in 1:700
    λ1 = propensity(c[1], s, γ1)
    λ2 = propensity(c[2], s, γ2)
    λ3 = propensity(c[3], s, γ3)
    e1 = exponential_my(λ1)
    e2 = exponential_my(λ2)
    e3 = exponential_my(λ3)
    if (e1 == min(e1, e2, e3))
        s = s .+ δ1
    elseif e2 == min(e1, e2, e3)
        s = s .+ δ2
    elseif e3 == min(e1, e2, e3)
        s = s .+ δ3
    end
    push!(state_e, s[1])
    push!(state_p, s[2])
    push!(state_s, s[3])
    push!(state_se, s[4])

end


plot(state_s, label = "S(t)")
plot!(state_e, label = "E(t)")
plot!(state_se, label = "SE(t)")
plot!(state_p, label = "P(t)")
# See rxn2 plot.png from images directry of the repo




s° = [5.]
s = s° # the species of the rxn
#defining the coefficient matrix [γ1, γ2, γ3]^T
γ1 = [1]
γ2 = [1]
γ3 = [0]

#defining the direction matrix
δ1 = [1]
δ2 = [-1]
δ3 = [1]

#defining the rate constant matrix
c = [1.0, 2.0, 50.]

state_x = [s[1]]
for _ in 1:700
    λ1 = propensity(c[1], s, γ1)
    λ2 = propensity(c[2], s, γ2)
    λ3 = propensity(c[3], s, γ3)
    e1 = exponential_my(λ1)
    e2 = exponential_my(λ2)
    e3 = exponential_my(λ3)
    if (e1 == min(e1, e2, e3))
        s = s .+ δ1
    elseif e2 == min(e1, e2, e3)
        s = s .+ δ2
    elseif e3 == min(e1, e2, e3)
        s = s .+ δ3
    end
    push!(state_x, s[1])
end


plot(state_x, label = "x(t)")


using Catalyst
using ModelingToolkit
using StaticArrays

#r rxns and n no of species
s° = [] #initial popualtion of species - length = n
s = [] #current pop - length = n
λ = [[]] #rΧn matrix
δ = [[]] #rXn matrix
state = [[]]

rn = @reaction_network mine begin
    α, S + I --> 2I
    β, I --> R
end α β

n = length(species(rn))
r = numreactions(rn)
s° =[] #defined by user
s = [1, 2,3 ]
speciesmap(rn)

paramsmap(rn)
arr = []
for (i, p) in enumerate(parameters(rn))
    append!(arr, i)
end
arr
((i, p) for (i,p) in enumerate(parameters(rn))) #taken from official documentation
k = []
γ = substoichmat(rn; smap=speciesmap(rn))
c = rate_constants!(k, rn)
k
λ = []
for j in 1:r
    append!(λ, propensity(k[j], s, γ[j, :]))
end
λ
δ = netstoichmat(rn; smap=speciesmap(rn))
minimum(exponential_my.(λ))
γ[1,:]


#---

rn = @reaction_network begin
    c1, X --> 2X
    c2, X --> 0
    c3 , 0 --> X
end c1 c2 c3
speciesmap(rn)
function rate_constants!(k, rn)
    for (i, p) in enumerate(parameters(rn))
        append!(k, i)
    end
end

function solve_my_rxn(rn, c, s°, iter)
    state = s°'
    n = numspecies(rn)
    r = numreactions(rn)
    @assert length(s°) == n
    s = s°
    γ = substoichmat(rn; smap=speciesmap(rn))
    #rate_constants!(c, rn)
    δ = netstoichmat(rn; smap=speciesmap(rn))
    for _ in 1:iter
        λ = []
        for j in 1:r
            append!(λ, propensity(c[j], s, γ[j, :]))
        end
        e =exponential_my.(λ)
        for m in 1:r
            if(e[m] == minimum(e))
                s = s .+ δ[m, :]
            end
        end
        state = [state; s']
    end
    return state end
c = [1.0, 2.0, 50.]
u = [5.]
state = []
state = solve_my_rxn(rn, c ,u, 600)

state


function plot_my_rxn!(rn, state)
    mapping = speciesmap(rn)
    p1  = plot()
    for (i, j) in mapping
        plot!(state[:, j] , label = string(i))
    end
    return p1
end
plot_my_rxn!(rn, state)








#---

@parameters β γ t
@variables S(t) I(t) R(t)

rxs = [Reaction(β, [S,I], [I], [1,1], [2])
       Reaction(γ, [I], [R])]
rs  = ReactionSystem(rxs, t, [S,I,R], [β,γ])

u₀map    = [S => 999.0, I => 1.0, R => 0.0]
parammap = [β => 1/10000, γ => 0.01]

rs

numspecies(rs)
substoichmat(rs; smap=speciesmap(rs))
parameters(rs)
k = []
rate_constants!(k, rs)
