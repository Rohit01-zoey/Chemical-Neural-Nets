#no point in setting up a recursion since we want the α of all the time stamps
using Plots
function α_pass_up_up(T, α0, A, B, O, Q, N)
    α = []
    append!(α, [α0])
    for t in 2:T
        ϕ = []
        for h in 1:N
            s = 0
            for g in 1:N
                s += (α[t-1][g] * A[g, h] * B[h, O[t]+1])
            end
            append!(ϕ, s)
        end
        append!(α, [ϕ/sum(ϕ)])
    end

    return α
end

function α_up_up_up(T, α0, A, B, O, Q, N)
    α = []
    append!(α, [α0])
    for t in 2:T
        ϕ = (reshape(α[t-1], (1, 2))*A) .* reshape(B[:, O[t]+1], (1,2))
        append!(α, [ϕ/sum(ϕ)])
    end
    return α
end
#α = α_up_up_up(T, α0, A, B, O, Q, N)
function β_pass_up_up(β_T, A, B, O, Q, N, T)
    #check the output of this function !!!!!
    β = []
    append!(β, [β_T])
    for t in T-1:-1:1
        Δ = []
        for h in 1:N
            s = 0
            for g in 1:N
                s += A[h, g]*B[g, O[t+1]+1]*β[T-t][g]
            end
            append!(Δ, s)
        end
        append!(β, [Δ/sum(Δ)])
    end
    return β
end
function β_up_up_up(β_T, A, B, O, Q, N, T)
    β = []
    append!(β, [β_T])
    for t in T-1:-1:1
        Δ = A * reshape(B[:, O[t+1]+1], (2, 1)) .* β[T-t]
        append!(β, [Δ/sum(Δ)])
    end
    return β
end

#β = β_pass_up_up(β_T, A, B, O, Q, N, T)

function E_step_γ(α, β, T, N)
    #returns the gamma vector for the given HMM
    γ = zeros(T, N)
    for l in 1:T
        for h in 1:N
            γ[l, h] += (α[l][h]*β[l][h])
        end
        γ[l] /= (sum(α[l].*β[l]))
    end
    return γ
end

function E_step_γ_up(α, β, T, N)
    γ = zeros(T, N)
    for l in 1:T
        γ[l, :] +=  vec(sum((reshape(α[1], (1, 2)).*A') .*reshape(B[:, O[l]+1], (2, 1)).*β[l], dims = 1))
        #γ[l] /= (sum(α[l].*β[l]))
        γ[l] /= sum(α[T])
    end
    return γ
end


function E_step_ζ(A, B, α, β, T, N)
    #returns the ζ vector for the given HMM
    ζ = zeros(T-1, N, N)
    for l in 1:T-1
        for h in 1:N
            for g in 1:N
                ζ[l, h, g] += (α[l][g]* A[g, h] * B[h, O[l+1]+1] * β[l+1][h])/ sum(α[l] .* β[l])
            end
        end
    end
    #for l in 1:T-1
    #    ζ[l, :, :] /= sum(α[l] .* β[l])
    #end
    return ζ
end



function M_step_θ(N, M, T, ζ)
    θ = zeros(N, N)
    for g in 1:N
        for h in 1:N
            θ[g, h] += (sum(ζ[l, g, h] for l in 1:T-1)/ sum(sum(ζ[l, g, f] for f in 1:N) for l in 1:T-1))
        end
    end
    return θ
end

function M_step_ψ(N, M, T, γ_norm)
    δ = zeros(M, M)
    for i in 1:M
        δ[i, i] = 1
    end
    ψ = zeros(N, M)
    for h in 1:N
        for w in 1:M
            ψ[h, w] += sum(γ_norm[l, h] * δ[w, O[l]+1] for l in 1:T)/sum(γ_norm[l, h] for l in 1:T)
        end
    end
    return ψ
end
function solve_my_HMM(A, B, T, N, M, π, O, Q, iter)
    ω = reshape(B[:, O[1]+1], (1, 2))
    α0 = vec(π .* ω)
    α0 = α0/sum(α0)

    β_T = vec(ones((N,1)))
    #scaling the β vector
    β_T = β_T/sum(β_T)
    iter_A = [A]
    iter_B = [B]

    for i in 1:iter
        ω = reshape(B[:, O[1]+1], (1, 2))
        α0 = vec(π .* ω)
        α0 = α0/sum(α0)
        α = α_up_up_up(T, α0, A, B, O, Q, N)
        β = [β_up_up_up(β_T, A, B, O, Q, N, T)[i] for i in T:-1:1] #reversing the order
        γ = E_step_γ(α, β, T, N)
        ζ = E_step_ζ(A, B, α, β, T, N)
        θ = M_step_θ(N, M, T, ζ)
        ψ = M_step_ψ(N, M, T, γ)
        A = θ
        B = ψ
        π = reshape(γ[1, :], (1,2)) #updating the initial condition
        append!(iter_A, [A])
        append!(iter_B, [B])
        print("-----iter no ", i, " complete--left ", iter-i, "----\n")
    end
    return A, B, iter_A, iter_B
end

function plot_iters(iter_matrix, label_of_curve)
    pl = plot()
    (r, c) = size(iter_matrix[1])
    for j in 1:r
        for k in 1:c
                plot!([iter_matrix[i][j, k] for i in 1:iter], label = label_of_curve*string(j)*string(k))
        end
    end
    return pl
end


N = 2#number of hidden states)
M = 2 #numbaer of observable states
Q = [1, 2] #say H => 1 and C => 2
V = [0, 1] #small => 0, medium => 1 and  large => 3

A = [0.6 0.4 ; 0.3 0.7]
B = [0.2 0.8; 0.5 0.5]

π = [0.6 0.4]

#now say we observe the follwing sequence :
O = [0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1]
#O= [0, 1, 0, 1, 0 ]
T = length(O)
iter = 200
fA, fB, iter_A, iter_B = solve_my_HMM(A, B, T, N, M, π, O, Q,iter)


plot_iters(iter_A, "θ")
plot_iters(iter_B, "ψ")
