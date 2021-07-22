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

f = Dual(3, 4)
g = Dual(5, 6)

f + g

f*g

f*(g+g)

add(a1, a2, b1, b2) = (a1+b1, a2+b2)

add(1, 2, 3, 4)

using BenchmarkTools
a, b, c, d = 1, 2, 3, 4
@btime add($(Ref(a))[], $(Ref(b))[], $(Ref(c))[], $(Ref(d))[])

a = Dual(1, 2)
b = Dual(3, 4)

add(j1, j2) = j1 + j2
add(a, b)
@btime add($(Ref(a))[], $(Ref(b))[])
#notice that the above is actually faster than the add function we had defined. Notice below in the @code_native add(a,b)we have vmov.. and vpadd..
#which are basically SIMD operations and hence these are a bit faster.

@code_native add(1, 2, 3, 4)

@code_native add(a, b)

import Base: exp
exp(f::Dual) = Dual(exp(f.val), exp(f.val) * f.der) #function is e^f(x) whose definition is f'(x) e^f(x) and f'(x) is f.der according to our definitoinions
f
exp(f)

h(x) = x^2 + 2
a = 3
xx = Dual(a, 1)
xy = Dual(a, 2)
h(xx)
h(xy)
#notice that for xy, the derivative part is twice of what it it was for h(xx) and this is what we had expected.

#assuming that xx is of the form (f(x), f'(x)) so we are saying that assume at a certain 'x' we have f(x) = 3 and f'(x) = 1 for a certain f
#thus now we want h(xx) which is basically saying we want h(f(x)) which by previous notions we would have the answer as Dual(h(f(x)), h'(f(x)̇×f'(x))) which is
# basically Dual(h(3), h'(3)×f'(x)) = Dual(11, 6×1) = Dual(11, 6)
#notice by using the above defined rules for arithmetic of Dual numbers we still get the same answer.


derivative(f, x) = f(Dual(x, one(x))).der
#one(x) gives us a '1' of the same type of x since we had made the val and der of any Dual number the same type and hence one
# should be careful here.
#notice what's happening above … again like above assume that a function 'g' exists such  that ∃ yϵ \mathbb{R} such that g(y) = x (parameter) and
#g'(y) = one(x) as given in the defined function. So now we say we want the composition of f(g(y)) and this spits out a Dual number.
#as expected this Dual number is Dual(f(g(y)), f'(g(y))×g'(y))  = Dual(f(x), f'(x)×1) = Dual(f(x), f'(x)) which is what we want.
#so here that one(x) is basically telling us how many times to scale f'(x)

derivative(x -> 3x^5 + 2, 2)


function newtons(x)
   a = x
   for i in 1:300
       a = 0.5 * (a + x/a) #iterative process of calculaing the square root of a number.
       #since its just +, / etc it's compatible with our dual numbers.
   end
   a
end
@show newtons(2.0)
@show (newtons(2.0+sqrt(eps())) - newtons(2.0))/ sqrt(eps())


newtons(Dual(2.0,1.0))
#notiice that the 2 calculations made for the square root of a number are correct upto 8 dp which is consistent with our previous discussion on precision


## Higher dimensions

ff(x, y) = x^2 + x*y


a, b = 3.0, 4.0

ff_1(x) = ff(x, b)  # single-variable function


ff(Dual(a, one(a)), b)

ff_2(y) = ff(a, y)  # single-variable function

derivative(ff_2, b)

#---
