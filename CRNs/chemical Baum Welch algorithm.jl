using Catalyst

N = 2#number of hidden states
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


E = zeros(M, M)

#initialisation of concentrations at t=0
for i in 1:M
    E[i, i] = 1
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


rn_α_ini = @reaction_network begin
    c1, α_1 + π_star + ψ_star + E --> α_1_star + π_star + ψ_star + E
    c2, α_1_star + p + ψ + E --> α_1 + p + ψ + E
    #p --> π since π is not allowed as an symbol
end c1 c2
