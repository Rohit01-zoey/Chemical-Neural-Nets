T = 4
N = 2
M = 3
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



#generating all the possible combinations of the given sequence
N = 4
combi = reverse.(Iterators.product(fill(1:2, N)...))[:]

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
