struct MyComplex
  real::Float64
  imag::Float64
end

arr = [MyComplex(rand(),rand()) for i in 1:100]
#the values of real and imag are stores as a rand(2, 100) type array
#recall they are stored sequetially and julia is column major

isbitstype(MyComplex)

struct MyComplexes
  real::Vector{Float64}
  imag::Vector{Float64}
end

arr2 = MyComplexes(rand(100),rand(100))
#notice the difference in the structure of arr and arr2
#arr2 has 'real' memory contiguous and 'complex' contiguous
# while arr has real, imag, real,imag..... seqeuntially stored.

using InteractiveUtils

Base.:+(x::MyComplex,y::MyComplex) = MyComplex(x.real+y.real,x.imag+y.imag)
Base.:/(x::MyComplex,y::Int) = MyComplex(x.real/y,x.imag/y)
average(x::Vector{MyComplex}) = sum(x)/length(x)

@code_llvm average(arr)

#=
What this is doing is creating small little vectors and then parallelizing the
 operations of those vectors by calling specific vector-parallel instructions.
  Keep this in mind
  =#

function parallel!(x,y)
   y .= x .+ 1
end
function no_parallel!(x, y)
  for i in 1:100
    y[i] = x[i] +1
  end
end


using BenchmarkTools
x = rand(100)
y= zeros(100)
@btime parallel!(x, y)

x = rand(100)
y = zeros(100)
@btime no_parallel!(x, y)

using SIMD
v = Vec{4,Float64}((1,2,3,4))
@show v+v # basic arithmetic is supported
@show sum(v) # basic reductions are supported

#=
Most performance optimization is not trying to do something really good for performance.
Most performance optimization is trying to not do something that is actively bad for performance.
=#

Threads.nthreads()
using Base.Threads
using BenchmarkTools
acc = 0
@threads for i in 1:10_000
    global acc
    acc += 1
end
acc

#=
Notice that everytime we run the program we get a different output further one also observes that the final value in acc  is always less than 10000
why so?
The reason for this behavior is that there is a difference between the reading and the writing step to an array.
Here, values are being read while other threads are writing, meaning that they see a lower value than when they are attempting to write into it.
The result is that the total summation is lower than the true value because of this clashing.

The way out of this is using Atomics -->
=#
acc = Atomic{Int64}(0)
@threads for i in 1:10_000
    atomic_add!(acc, 1)
end
acc
#=
When an atomic add is being done, all other threads wishing to do the same computation are blocked.
This of course can have a massive effect on performance since atomic computations are not parallel.

Or we can use locks  --->
=#

const acc_lock = Ref{Int64}(0)
const splock = SpinLock()
function f1()
    @threads for i in 1:10_000
        lock(splock)
        acc_lock[] += 1
        unlock(splock)
    end
end
const rsplock = ReentrantLock()
function f2()
    @threads for i in 1:10_000
        lock(rsplock)
        acc_lock[] += 1
        unlock(rsplock)
    end
end
acc2 = Atomic{Int64}(0)
function g()
  @threads for i in 1:10_000
      atomic_add!(acc2, 1)
  end
end
const acc_s = Ref{Int64}(0)
function h()
  global acc_s
  for i in 1:10_000
      acc_s[] += 1
  end
end
@btime f1()
@btime f2()
@btime g()
@btime h()
