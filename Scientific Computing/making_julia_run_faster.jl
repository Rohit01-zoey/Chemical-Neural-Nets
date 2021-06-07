#Juliacon2020| Make your Julia code run faster and compatible with non-julia code

using BenchmarkTools
using LinearAlgebra
A= rand(1000, 1000)
@btime norm(A)


function timing_from_a_function_error()
    B = rand(1000, 1000)
    @btime norm(B)
    #notice that we  need to reference the local scope julia automatically references the global scope.
end

function timing_from_a_function()
    B = rand(1000, 1000)
    @btime norm($B)
    #notice that we  need to reference the local scope julia automatically references the global scope.
end
timing_from_a_function_error()
timing_from_a_function()

A = rand(10_000, 10_000)
b = @benchmark norm($A)
b.times.*10^-9

#tinkering around with the samples:
b = @benchmark(norm($A), samples = 10)
b.times

#changing the default values of the number of samples
BenchmarkTools.DEFAULT_PARAMETERS.samples #gives 10000
#change it by equating the above to some number
# BenchmarkTools.DEFAULT_PARAMETERS.samples = 1000

#so why isnt our earlier example not running 10000 times? because of the following :
BenchmarkTools.DEFAULT_PARAMETERS.seconds#gives 5 as the answer
# the above means the following that return all  those iterations fitting within the 5 seconds thus we see only 84
# iterations for the norm example and not 10000
#change it by assigning any other number
# BenchmarkTools.DEFAULT_PARAMETERS.seconds = 10 for example
