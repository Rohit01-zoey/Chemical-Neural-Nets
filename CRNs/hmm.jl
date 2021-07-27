T = 4
N = 2#number of hidden states
M = 3 #numbaer of observable states
Q = [1, 2] #say H => 1 and C => 2
V = [0, 1, 2] #small => 0, medium => 1 and  large => 3

A = [0.7 0.3; 0.4 0.6]
B = [0.1 0.4 0.5; 0.7 0.2 0.1]

π = [0.6 0.4]

#now say we observe the follwing sequence :
O = [0, 1, 0, 2]

#given an input as a sequnce of hidden states whats the probability that this  sequnce of hidden states
#occured to give us what we observed

λ = (A, B, π)#Defining the hmm problem

X = [2, 2, 2, 2]


##the following is the random code for the general case when the umber of cases
#are small.
pr = π[X[1]] * B[X[1]][O[1]+1]
for i in 1:T-1
    pr *= (A[X[i], X[i+1]] * B[X[i+1], O[i+1]+1])
end

pr #gives the final probobility.

##
#evrything written  below is genral all that u hv to change is the above
#and the states poble in the combi !!!!!

#generating all the possible combinations of the given sequence

combi = reverse.(Iterators.product(fill(1:N, T)...))[:]

prob = []
for Xs in combi
    pr = π[Xs[1]] * B[Xs[1]][O[1]+1]
    for i in 1:T-1
        pr *= (A[Xs[i], Xs[i+1]] * B[Xs[i+1], O[i+1]+1])
    end
    append!(prob, pr)
end

prob

norm_prob = prob/sum(prob)

prob_per_step = zeros(length(Q), T)
for t in 1:T
    for iter in 1:length(combi)
        h = combi[iter][t]
        prob_x = norm_prob[iter]
        prob_per_step[h, t] += prob_x
    end
end
prob_per_step

#therefore the above matrix tells us the probabilities in the HMM sense
#now we can get the optimum sequncein the HMM sense
optimum = []
for i in 1:T
    append!(optimum, argmax(prob_per_step[:, i]))
end
optimum
#therfore the above is the hidden sequence most likely to occur

##

#=now we go to find the score for the sequnceof the observables this can be done 2 methods
1) brute force (2TN^{T}) complexity
2) Forward algo/α-pass method (N^{2} T) complexity
=#

#Implementing the forward pass algorithm:
#this is alpha pass 0
ω = reshape(B[:, O[1]+1], (1, 2))
α0 = π .* ω#how to improve this code!!!!!!!!!!!!!!!


function α_pass(t, α0, A, B, O, X, N)
    if t<=1 return α0 end
    return [(sum(α_pass(t-1, α0, A, B, O, X, N) * A)) * (B[X[i], O[t]+1])  for i in 1:N]
end
α_pass(2, α0, A, B, O, X, N)


using LinearAlgebra
