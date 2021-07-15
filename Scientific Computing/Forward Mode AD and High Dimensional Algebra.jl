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
