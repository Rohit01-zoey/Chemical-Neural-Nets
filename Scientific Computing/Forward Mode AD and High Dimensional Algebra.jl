eps(Float64)
#eps(Float64) is the smallest number such that 1+E does NOT equal 1
1.1 + 1e-16 #ideally should yield 1.10000000... but still yields 1.1 as the answer.


#Its all relative!!
@show eps(1.0)
@show eps(0.1)
@show eps(0.01)

ϵ = 1e-10rand()
@show ϵ
@show (1+ϵ)
ϵ2 = (1+ϵ) - 1
(ϵ - ϵ2)


struct Dual{T}
    val::T   # value
    der::T  # derivative
end


#we define a few functions we may need that is addition with different types.
Base.:+(f::Dual, g::Dual) = Dual(f.val + g.val, f.der + g.der)
Base.:+(f::Dual, α::Number) = Dual(f.val + α, f.der)
Base.:+(α::Number, f::Dual) = f + α

#=
You can also write:
import Base: +
f::Dual + g::Dual = Dual(f.val + g.val, f.der + g.der)
=#

Base.:-(f::Dual, g::Dual) = Dual(f.val - g.val, f.der - g.der)

# Product Rule
Base.:*(f::Dual, g::Dual) = Dual(f.val*g.val, f.der*g.val + f.val*g.der)
Base.:*(α::Number, f::Dual) = Dual(f.val * α, f.der * α)
Base.:*(f::Dual, α::Number) = α * f #notice that this calls the above function sice we are multiplying a Number and a dual

# Quotient Rule
#that is (f/g)' = (f'g - fg')/g^2
Base.:/(f::Dual, g::Dual) = Dual(f.val/g.val, (f.der*g.val - f.val*g.der)/(g.val^2))
Base.:/(α::Number, f::Dual) = Dual(α/f.val, -α*f.der/f.val^2)
Base.:/(f::Dual, α::Number) = f * inv(α) # Dual(f.val/α, f.der * (1/α))
#notice that the above call the multiple dispatches of *, + and - we had defined before.

Base.:^(f::Dual, n::Integer) = Base.power_by_squaring(f, n)  # use repeated squaring for integer powers
