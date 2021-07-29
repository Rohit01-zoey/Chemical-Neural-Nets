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
α0 = π .* ω

α0 = α0/sum(α0)#how to improve this code!!!!!!!!!!!!!!!


function α_pass(t, α0, A, B, O, Q, N)
    if t<=1 return α0 end
    γ = [(reshape(α_pass(t-1, α0, A, B, O, X, N), (1, 2)) * A)[i] * (B[Q[i], O[t]+1])  for i in 1:N]
    return γ/sum(γ)
end
#thus we have set up the required recursion to find the required α pass values
#finding the final probability
γ = α_pass(T, α0, A, B, O, Q, N)
POλ = γ/sum(γ)
#constructing the α matrix which is  a TxN matrix we find the transpose of the required matrix.
α = [reshape(α_pass(t, α0, A, B, O, Q, N)/sum(α_pass(t, α0, A, B, O, Q, N)), (1, 2)) for t in 1:T]
#notice that the above is the tranpose of the matrix we require.

##
#now we can proceed to implement the β-pass algorithm -
β_T = ones((N,1))
#scaling the β vector
β_T = β_T/sum(β_T)

#implementing the β pass algorithm

function β_pass(t, β_T, A, B, O, Q, N, T)
    if t>=T return β_T  end
    γ = [(reshape(β_pass(t+1, α0, A, B, O, X, N, T), (1, 2)) * A')[i] * (B[X[i], O[t+1]+1])  for i in 1:N]
    return γ/sum(γ)
end

β_pass(3, β_T, A, B, O, X, N, T)


##
#implementing the above code in a better way neverthless not the most optimzed way !!
function α_pass_up(t, α0, A, B, O, Q, N)
    if t<=1 return α0 end
    α = []
    for i in 1:N
        s = 0
        for j in 1:N
            s += α_pass_up(t-1, α0, A, B, O, Q, N)[j] * A[j, i]
        end
        s *= B[i, O[t]+1]
        append!(α, s)
    end
    return α/sum(α)
end

#no point in setting up a recursion since we want the α of all the time sta
function α_pass_up_up(T, α0, A, B, O, Q, N)
    α = []
    append!(α, [α0])
    for t in 2:T
        ϕ = []
        for i in 1:N
            s = 0
            for j in 1:N
                s += α[t-1][j] * A[j, i]
            end
            s *= B[i, O[t]+1]
            append!(ϕ, s)
        end
        append!(α, [ϕ])
    end

    return α
end

#α = [reshape(α_pass_up_up(T, α0, A, B, O, Q, N), (1, N)) for t in 1:T]
α = α_pass_up_up(T, α0, A, B, O, Q, N)


function β_pass_up(t, β_T, A, B, O, Q, N, T)
    if t>=T return β_T  end
    β = []
    for i in 1:N
        s = 0
        for j in 1:N
            s += A[i, j]*B[j, O[t+1]+1]*β_pass_up(t+1, β_T, A, B, O, Q, N, T)[j]
        end
        append!(β, s)
    end
    return β
end
function β_pass_up_up(β_T, A, B, O, Q, N, T)
    #check the output of this function !!!!!
    β = []
    append!(β, [β_T])
    for t in T-1:-1:1
        Δ = []
        for i in 1:N
            s = 0
            for j in 1:N
                s += A[i, j]*B[j, O[t+1]+1]*β[T-t][j]
            end
            append!(Δ, s)
        end
        append!(β, [Δ])
    end
    return β
end
β = β_pass_up_up(β_T, A, B, O, Q, N, T)

function E_step_γ(α, β)
    #returns the gamma vector for the given HMM
    return [α[i] .* β[i]/sum(α[i] .* β[i]) for i in 1:T]
end


function E_step_ζ(A, B, α, β, T, N)
    #returns the ζ vector for the given HMM
    ζ = zeros((T-1, N, N))
    for l in 1:T-1
        for h in 1:N
            for g in 1:N
                ζ[l, h, g] += (α[l][g]* A[g, h] * B[h, O[l+1]+1] * β[l+1][h])
            end
        end
    end
    for l in 1:T-1
        ζ[l, :, :] /= sum(α[l] .* β[l])
    end
    return ζ
end

function M_step_θ(N, M, T, ζ)
    θ = zeros((N, N))
    for g in 1:N
        for h in 1:N
            θ[g, h] += (sum(ζ[l, g, h] for l in 1:T-1)/ sum(sum(ζ[l, g, f] for f in 1:N) for l in 1:T-1))
        end
    end
    return θ
end

function M_step_ψ(N, M, T, γ_norm)
    δ = zeros((M, M))
    for i in 1:M
        δ[i, i] = 1
    end
    ψ = zeros(N, M)
    for h in 1:N
        for w in 1:M
            ψ[h, w] += sum(γ_norm[l][h] * δ[w, O[l]+1] for l in 1:T)/sum(γ_norm[l][h] for l in 1:T)
        end
    end
    return ψ
end


#so we have defined all the functions we need to perform the iterations on the HMM we have.
##
β = [reshape(β_pass_up(t, β_T, A, B, O, Q, N, T)/sum(β_pass_up(t, β_T, A, B, O, Q, N, T)), (1, 2)) for t in T:-1:1]
β = reverse(β)
γ = [α[i] .* β[i] for i in 1:T]
γ_norm = [α[i] .* β[i]/sum(α[i] .* β[i]) for i in 1:T]



##
#implementing the E-step of the algorithm
ζ = zeros((T-1, N, N))
for l in 1:T-1
    for h in 1:N
        for g in 1:N
            ζ[l, h, g] += (α[l][g]* A[g, h] * B[h, O[l+1]+1] * β[l+1][h])
        end
    end
end
ζ

for l in 1:T-1
    ζ[l, :, :] /= sum(α[l] .* β[l])
end
ζ


##
#implementing the M-step of the algorithm.
δ = zeros((M, M))
for i in 1:M
    δ[i, i] = 1
end
δ

#estimating the transition matrix
θ = zeros((N, N))
for g in 1:N
    for h in 1:N
        θ[g, h] += (sum(ζ[l, g, h] for l in 1:T-1)/ sum(sum(ζ[l, g, f] for f in 1:N) for l in 1:T-1))
    end
end
θ

ψ = zeros(N, M)
for h in 1:N
    for w in 1:M
        ψ[h, w] += sum(γ_norm[l][h] * δ[w, O[l]+1] for l in 1:T)/sum(γ_norm[l][h] for l in 1:T)
    end
end
ψ

#thus we have the updated values for the next part of the simulation
A = θ
B = ψ
#now to find the fixed point of this method
#we update A and B at every iter

function solve_my_HMM(A, B, T, N, M, π, O, Q, iter)
    ω = reshape(B[:, O[1]+1], (1, 2))
    α0 = π .* ω
    α0 = α0/sum(α0)

    β_T = ones((N,1))
    #scaling the β vector
    β_T = β_T/sum(β_T)

    for i in 1:iter

        α = α_pass_up_up(T, α0, A, B, O, Q, N)
        β = [β_pass_up_up(β_T, A, B, O, Q, N, T)[i] for i in T:-1:1] #reversing the order
        γ = E_step_γ(α, β)
        ζ = E_step_ζ(A, B, α, β, T, N)
        θ = M_step_θ(N, M, T, ζ)
        ψ = M_step_ψ(N, M, T, γ)
        A = θ
        B = ψ
        print("-----iter no ", i, " complete--left", iter-i, "----\n")
    end
    return A, B
end

fA, fB = solve_my_HMM(A, B, T, N, M, π, O, Q,500)


N = 2#number of hidden states
M = 2 #numbaer of observable states
Q = [1, 2] #say H => 1 and C => 2
V = [0, 1] #small => 0, medium => 1 and  large => 3

A = [0.6 0.4; 0.3 0.7]
B = [0.5 0.5; 0.5 0.5]

π = [0.6 0.4]

#now say we observe the follwing sequence :
O = [0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1]
T = length(O)
#given an input as a sequnce of hidden states whats the probability that this  sequnce of hidden states
#occured to give us what we observed

λ = (A, B, π)#Defining the hmm problem

X = [2, 2, 2, 2]
