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
acc[]  #notice that the answer is 10000 which is correct

# using atomics -->

x = Threads.Atomic{Int}(4)
atomic_add!(x, 2)
x[]
#=
When an atomic add is being done, all other threads wishing to do the same computation are blocked.
This of course can have a massive effect on performance since atomic computations are not parallel.

Or we can use locks  --->
=#
a = Ref{Int64}(2)
a[] +=1
a[]

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

#= notice that the atomics is faster than f1 and f2 so we shd utilize atomics whenever we can but the number of functions is limited
so we are at a disadvantage.
f1 is faster than f2 since we have additional safety in f2 => that in f1 we lock at the beginning and if we were to call  a function(a multithreaded one)
 which were to lock the threads again then we would be in deadlock and the execution of the computer would just stop.

 further notice that even thought h() is a serial code it is the fastest why????? becoz julia has analysed the code and since the code was
 serial it knows that it just has to add a 1 10_000 times and so just adds 10000 rather than summing up 1's.
 one can see this by seeing the code_llvm  --->look for this line "icmp eq i64 %value_phi, 10000"
=#
@code_llvm h()

# It just knows to add 10000. So to get a proper timing let's make the size mutable:

#be careful what the above means we are creating a constant pointer of type Int  whose value may be anything
const len = Ref{Int}(10_000)
# so the value is still mutable
# len[] = 11_000 does NOT give a  "WARNING: redefinition of constant len. This may fail, cause incorrect answers, or produce other errors."
function h2()
  global acc_s
  global len
  for i in 1:len[]
      acc_s[] += 1
  end
end
@btime h2()

#notice that the now julia cant specialise and add a 10000 directly since the len value is mutable .
#but notice that we still ending up getting a faster code....how?
#julia knows we are adding just one at each step and so just adds len[] direclty and circumvents the loop completely.
#So we do the following :

@code_llvm h2()

non_const_len = 10000
#note that global variables are not type inferred (=> type instability) and so may give error while iterating
function h3()
  global acc_s
  global non_const_len
  len2::Int = non_const_len #changing to int so that the loop does not throw an error.
  for i in 1:len2
      acc_s[] += 1
  end
end

@btime h3()
#its still quite fast


#=
Note that what is shown here is a type-declaration. a::T = ... forces a to be of type T throughout the whole function.
By giving the compiler this information, I am able to use the non-constant global in a type-stable manner.

One last thing to note about multithreaded computations, and parallel computations, is that one cannot assume that the
parallelized computation is computed in any given order. For example, the following will has a quasi-random ordering:
=#
lg = nthreads()*10
const a2 = zeros(lg)
const thread_no = zeros(lg)
const acc_lock2 = Ref{Int64}(0)
const splock2 = SpinLock()
function f_order()
    @threads for i in 1:length(a2)
        lock(splock2)
        acc_lock2[] += 1
        a2[i] = acc_lock2[]
        thread_no[i] = Threads.threadid()
        unlock(splock2)
    end
end
f_order()
a2
thread_no

#=
notice the thread_no array => in order of their priority
since @threads has a Static scheduler => loop of 60 and 6 threads => per thread 10 loops
=#

#= notice how the threads are assigned. Thread  1 has highest priority so always assigned first and followed by the rest.
So while assigning, we can assume tasks are given our 1 by 1 say -> every 6 tasks assigned to all 6 threads and so on.
If at the end for egs 3 tasks remain then threads 1, 2 and 3 are assigned the task.

Try running the above example with different values of lg.

Further  we also notice that task switching can only take place when we have an yield point but here after the unlock statement
it keeps on computing since it sees no yield point and thus has no chance of switching over from the current task.
=#
# DID NOT UNDERSTAND THE ABOVE CONCEPT !!!!!!!!!!!!!!!!!!!!!!!!!!

(0.1 + 0.01 + 0.3) - (0.1 + 0.01 + 0.3)
(0.1 + 0.01 + 0.3) - (0.1 + 0.3 + 0.01)
# the above answer is not 0 notice the ordering of the floating point of numbers => floating point is NOT associative
# GPU computing example :-

using CUDA

N = 2^20
x_d = CUDA.fill(1.0f0, N)  # a vector stored on the GPU filled with 1.0 (Float32)
y_d = CUDA.fill(2.0f0, N)  # a vector stored on the GPU filled with 2.0

function gpu_add2!(y, x)
    index = threadIdx().x    # this example only requires linear indexing, so just use `x`
    stride = blockDim().x
    for i = index:stride:length(y)
        @inbounds y[i] += x[i]
    end
    return nothing
end

fill!(y_d, 2)
@cuda threads=256 gpu_add2!(y_d, x_d)
all(Array(y_d) .== 3.0f0)
