using Distributions
using Plots
using Catalyst
using ModelingToolkit
using StaticArrays


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
function choose_ups(i, j)
    return factorial(i)/(factorial(j)*factorial(i-j))
end
function propensity(k, s, coef)
          @assert length(s)==length(coef)
          prop = k
          for i in 1:length(s)
              prop *= choose(s[i], coef[i])
          end
          return prop
end

function exponential_my(λ)
    return -log(1-rand(Uniform(0, 1)))/λ
end

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
    @assert length(c) == r
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
                break
            end
        end
        state = [state; s'] #appends the current state to the array of states
    end
    return state end

function plot_my_rxn!(rn, state)
    mapping = speciesmap(rn)
    p1  = plot()
    for (i, j) in mapping
        plot!(state[:, j] , label = string(i))
    end
    return p1
end

rn = @reaction_network begin
  c1, S + E --> SE
  c2, SE --> S + E
  c3, SE --> P + E
end c1 c2 c3

c = [0.00166,0.0001,0.1]
u = [301., 100., 0., 0.]
state = []
state = solve_my_rxn(rn, c ,u, 600)

state

plot_my_rxn!(rn, state)
