#X+Y --> 2X  (k1)
# 2Y --> X  (k2)
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
    if(j!=0)
        num = one(i)
        den = one(i)
        for l in my_range(j, i)
            num *= l
        end
        for l in my_range(j,j)
            den *= l
        end
    else
        num = 1
        den = 1
    end
    return num/den
end


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
for i in 1:300
    λ1 = propensity(k1, s[1], s[2], 1, 1)
    λ2 = propensity(k2, s[1], s[2], 0, 2)

    π1 = λ1/(λ1 + λ2)
    π2 = λ2/(λ1 + λ2)


    if(π1 > π2)
        s = s .+ δ1
    else
        s = s.+ δ2
    end
    push!(state_x, s[1])
    push!(state_y, s[2])
end
using Plots

plot(state_x, state_y)
