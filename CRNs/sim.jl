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



#r rxns and n no of species
s° = [] #initial popualtion of species
s = [] #current pop
λ = [[]] #rΧn matrix
δ = [[]] #rXn matrix
state = [[]]

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
