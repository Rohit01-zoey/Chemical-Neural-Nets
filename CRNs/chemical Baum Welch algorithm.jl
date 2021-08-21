using Catalyst
using DifferentialEquations
using SymbolicUtils

N = 2#number of hidden states|
M = 2 #numbaer of observable states
Q = [1, 2] #say H => 1 and C => 2
V = [0, 1] #small => 0, medium => 1 and  large => 3

A = [0.6 0.4; 0.3 0.7]
B = [0.5 0.5; 0.5 0.5]

π = [0.6 0.4]

#now say we observe the follwing sequence :
O = [0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1]
#O= [0, 1, 0, 1, 0 ]
T = length(O)

##Initialising the system with E and β matrix
E = zeros(T, M)

#initialisation of concentrations at t=0
for i in 1:T
    E[i, O[i]+1] = 1
end
E


β  = zeros(T, N)
β[1, 1:2] =[1, 1]
β


α= zeros(T, N)
α0 = vec(π .* reshape(B[:, O[1]+1], (1, 2)))
α0 = α0/sum(α0)
α[1, 1:2] = α0
α

##Picking up h* at random to brake symetry

H = rand(1:N)

##defining the reaction network
rn_α_ini = @reaction_network begin
    c1, α_1 + π_star + ψ_star + E --> α_1_star + π_star + ψ_star + E
    c2, α_1_star + p + ψ + E --> α_1 + p + ψ + E
    #p --> π since π is not allowed as an symbol
end c1 c2

rn_α = @reaction_network begin
   c1, α_1 + α_lg + θ_ghstar + ψ_hstarw + E --> α_1star + α_lg + θ_ghstar + ψ_hstarw + E
   c2, α_1star + α_lg + θ_gh + ψ_hw + E --> α_1 + α_lg + θ_gh + ψ_hw + E
end c1 c2



##defining the reaction network
speciesmap(rn_α_ini)

species(rn_α_ini)






speciesmap(rn_α)






## implementing the α pass algo
u0 = []

for i in setdiff(1:N, H)
    for j in 1:M
        if(E[i, j]==1)
           pp = [1, 1]
           tspan = (0.,2.)
           print(j)
           append!(u0, rand(2))
           append!(u0, [B[H, j], E[1, j]])
           append!(u0, rand(2))
           append!(u0,  B[i, j])
           u0 = u0 .*100
           #u0 = rand(7)
           #u0 = [rand(1), π[H], rand(1), rand(1), rand(1), rand(1), rand(1)]
         end
   end
end
u0
pp = [1, 1]
tspan = (0.,2.)
oprob = ODEProblem(rn_α_ini, u0, tspan, pp)
osol  = solve(oprob, Tsit5())
osol
v = last(osol)
u0
α = zeros(T, N)
α[1, setdiff(1:N, H)[1]] = v[1]/100
α[1, H] = v[5]/100
α

for l in 2:T
   for g in Q
   u0 = []
   for i in setdiff(1:N, H)
         for j in 1:M
            if(E[i, j]==1)
               pp = [1, 1]
              tspan = (0.,2.)
              append!(u0, rand(1))
              append!(u0, α[l-1, g])
              append!(u0, A[g, H])
              append!(u0, B[H, O[j]+1])
              append!(u0, E[l, j])
              append!(u0, rand(1))
              append!(u0,  A[i, g])
              append!(u0, B[H, O[j]+1])
              u0 = u0 .*100
              #u0 = rand(7)
              #u0 = [rand(1), π[H], rand(1), rand(1), rand(1), rand(1), rand(1)]
            end
      end
   end
   u0
   pp = [1, 1]
   tspan = (0.,3.)
   oprob = ODEProblem(rn_α, u0, tspan, pp)
   osol  = solve(oprob, Tsit5())
   osol
   v = last(osol)
   α[l, setdiff(1:N, H)[1]] += v[1]/100
   α[l, H] += v[6]/100
   end
end
α

##implementing the β algorithm
rn_β = @reaction_network begin
   c1, β_lh + β_1 + θ_hstarg + ψ_gw + E --> β_lhstar + β_1 + θ_hstarg + ψ_gw + E
   c2, β_lhstar + β_1 + θ_hg + ψ_gw + E --> β_lh + β_1 + θ_hg + ψ_gw + E
end c1 c2
speciesmap(rn_β)
β = zeros(T, N)

β[T, :] += [1,1]
β


for l in T-1:-1:1
   for g in Q
   u0 = []
   for i in setdiff(1:N, H)
         for j in 1:M
            if(E[i, j]==1)
               pp = [1, 1]
              tspan = (0.,2.)
              append!(u0, rand(1))
              append!(u0, β[l+1, g])
              append!(u0, A[H, g])
              append!(u0, B[g, O[j]+1])
              append!(u0, E[l, j])
              append!(u0, rand(1))
              append!(u0,  A[i, g])
              u0 = u0 .*100
              #u0 = rand(7)
              #u0 = [rand(1), π[H], rand(1), rand(1), rand(1), rand(1), rand(1)]
            end
      end
   end
   u0
   pp = [1, 1]
   tspan = (0.,3.)
   oprob = ODEProblem(rn_β, u0, tspan, pp)
   osol  = solve(oprob, Tsit5())
   osol
   v = last(osol)
   β[l, setdiff(1:N, H)[1]] += v[1]/100
   β[l, H] += v[6]/100
   end
end
β

##γ algorithm implementation
rn_γ = @reaction_network begin
   c1, γ_lh + α_lhstar + β_lhstar --> γ_lhstar + α_lhstar + β_lhstar
   c2, γ_lhstar + α_lh + β_lh --> γ_lh + α_lh + β_lh
end c1 c2
speciesmap(rn_γ)

γ = zeros(T, N)
for l in 1:T
   for h in setdiff(1:N, H)
      u0 = []
      append!(u0, rand(1))
      append!(u0, α[l, H])
      append!(u0, β[l, H])
      append!(u0, rand(1))
      append!(u0, α[l, h])
      append!(u0, β[l, h])
      u0 = u0 .* 100
      pp = [1, 1]
      tspan = (0.,3.)
      oprob = ODEProblem(rn_γ, u0, tspan, pp)
      osol  = solve(oprob, Tsit5())
      osol
      v = last(osol)
      γ[l, h] += v[1]/100
      γ[l, H] += v[4]/100
   end
end
γ

## ζ algorithm implementation
rn_ζ = @reaction_network begin
   c1, ζ_lgh + α_lhstar + θ_hstarhstar + β_l1hstar + ψ_hstarw + E --> ζ_lhstarhstar +  α_lhstar + θ_hstarhstar + β_l1hstar + ψ_hstarw + E
   c2, ζ_lhstarhstar+ α_lg + θ_gh + β_l1g + ψ_hw + E --> ζ_lgh + α_lg + θ_gh + β_l1g + ψ_hw + E
end c1 c2
speciesmap(rn_ζ)

ζ = zeros(N, N, T)

for l in 1:T
   for g in 1:N
      for h in 1:N
         u0 = []
         append!(u0, rand(1))
         append!(u0, α[l, H])
         append!(u0, B[H, H])
         append!(u0, β[l+1, H])
         append!(u0, B[H, O[l]+1])
         append!(u0, E[l, O[l]+1])
         append!(u0, rand(1))
         append!(u0, α[l, g])
         append(u0, B[g, h])
         append!(u0, β[l+1, g])
         u0 = u0 .* 100
         pp = [1, 1]
         tspan = (0.,3.)
         oprob = ODEProblem(rn_γ, u0, tspan, pp)
         osol  = solve(oprob, Tsit5())
         osol
         v = last(osol)


## TRIAL !!!!!
i = 1
j = 1
for i in setdiff(1:N, H)
    for j in 1:M
        if(E[i, j]==1)
           pp = [1, 1]
           tspan = (0.,2.)
           print(j)
           u0 = []
           append!(u0, rand(2))
           append!(u0, [B[H, j], E[1, j]])
           append!(u0, rand(2))
           append!(u0,  B[i, j])
           #u0 = [rand(1), rand(1), B[H, j], E[1, j], rand(1),rand(1), B[i, j]]
        end
     end
  end
u0


E
trial = @reaction_network begin
    c1,  A+C +E + F--> B+C+E + F
    c2, B +D + G + F--> A + D + G + F
end c1 c2

p = [1, 1]
tspan = (0.,3.)
u0 = rand(8)
s = []
append!(s, rand(2))
append!(s, [1, 2])   # [X]

# solve ODEs
oprob = ODEProblem(trial, u0, tspan, p)
osol  = solve(oprob, Tsit5())
osol
j = rand(1:100)
for i in 1:10
    print(j)
end


for i in setdiff(1:N, H)
    for j in 1:M
        if(E[i, j]==1)
           pp = [1, 1]
           tspan = (0.,2.)
           #u0 = [rand(1), rand(1), B[H, j], E[1, j], rand(1),rand(1), B[i, j]]
           u0 = []
           append!(u0, rand(2))
           append!(u0, [B[H, j],E[i, j]])
           print(H)
           append!(u0, rand(2))
           append!(u0, [B[i, j]])
           print(u0)
           #u0 = rand(7)
           #u0 = [rand(1), π[H], rand(1), rand(1), rand(1), rand(1), rand(1)]
    else break
    end
    end
end
u0 = u0 .*100
u0 = rand(8)
pp = [1, 1, 1,1 ]
tspan = (0.,2.)
oprob = ODEProblem(rn_α_ini, u0, tspan, pp)
osol  = solve(oprob, Tsit5())
osol



@parameters k1 k2 t
@variables  α_11(t) π_star(t) p(t) ψ(t) E(t) α_1_star(t) ψ_star(t)

rxns1 = [Reaction(k1, [α_11 , π_star , ψ_star, E], [α_1_star , π_star , ψ_star , E])]
         Reaction(k2, [α_1_star , p , ψ , E], [α_11 , p , ψ , E])
addspecies!(rn_α_ini, α_11)

addreaction!(rn_α_ini, Reaction(k1, [α_11[1] , π_star , ψ_star, E], [α_1_star , π_star , ψ_star , E]))
addreaction!(rn_α_ini, Reaction(k2, [α_1_star , p , ψ , E], [α_11 , p , ψ , E]))

speciesmap(rn_α_ini)
