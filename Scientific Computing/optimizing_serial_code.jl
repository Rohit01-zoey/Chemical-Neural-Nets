using BenchmarkTools

A = rand(100,100)
B = rand(100,100)
C = rand(100,100)
function inner_rows!(C,A,B)
  for i in 1:100, j in 1:100
    C[i,j] = A[i,j] + B[i,j]
  end
  end
@btime inner_rows!(C,A,B)

function inner_cols!(C,A,B)
    for j in 1:100, i in 1:100
      C[i,j] = A[i,j] + B[i,j]
    end
  end
  @btime inner_cols!(C,A,B)
  #* Notice that the data is stored column wise and so inner_cols shd ideally
  #* run faster since it looks ahaed in data and grabs that data but in inner_rows wise
  #* we don't choose data sequentially and so ideally shd take more time

  #* Julia has Dynamically sized arrays => sees type at run time
  #* for egs
  A = rand(100,100)
  typeof(A)
  #! Hence Arrays are always stored in heap not Stack since size not known/variable.

  function inner_alloc!(C,A,B)
    for j in 1:100, i in 1:100
      val = [A[i,j] + B[i,j]] # putting the result in an array 
      C[i,j] = val[1]
    end
  end
  @btime inner_alloc!(C,A,B)
#! Here we have heap allocations and these are costly hence inner_alloc take a lot of time
#notice that we have 100^2 allocations since each time an array val is created that is a pointer to the memory 
#further notice that val is an array and thus is not type specialised and hence Julia cant specialise
#all arrays live on the heap and therefore whenever we create new arrays we have to create new pointers to memory/heap

#* scalars size known from before
  function inner_noalloc!(C,A,B)
    for j in 1:100, i in 1:100
      val = A[i,j] + B[i,j]
      C[i,j] = val[1]
    end
  end
  @btime inner_noalloc!(C,A,B)

  #! the only way to store variable sized arrays is to hv a pointer pointing to that memory

  #!therefore to minimize time we must reduce the number of heap allocations

  using StaticArrays
  #StaticArrays encodes within it the size also 
  val = SVector{3, Float64}(1.0, 2.0, 3.0)
  typeof(val)
  #* Thus notice that we need 64*3 bits to store all the data. that is we know the size of the array and hence it can be put on the stack


#!--------------------------------------------------------
function static_inner_alloc!(C,A,B)
  for j in 1:100, i in 1:100
    val = @SVector [A[i,j] + B[i,j]]
    C[i,j] = val[1]
  end
end
@btime static_inner_alloc!(C,A,B)
#* notice that we get 0 allocations here since size is known and 
#* thus it lives on the stack and Hence 0 allocations.
#! @SVector is a macro i.e Syntatic sugar for
    #! (SArray{Tuple{1}, T, 1, 1} where T)((A[i,j] + B[i,j],))
@macroexpand @SVector [A[i,j] + B[i,j]]


#! Stack follows LIFO and Hence putting huge data into the stack 
#! does not imply faster operations

# thus for really large matrices we can neither have them in the stack nor the heap thus the ans is mutation

#!--------------------------------------------------------
function inner_noalloc!(C,A,B)
    for j in 1:100, i in 1:100
      val = A[i,j] + B[i,j]
      C[i,j] = val[1]
    end
  end
  @btime inner_noalloc!(C,A,B)

  #* Bang => mutating => chnages the first value of the parameters and hence we have zero allocations
  #! again 0 allocations since we don't assign a new value
#? Example of muating function
#! Notice that Int64, Float64 are immutable and won't change subject
#! to such fucntions and evem Tuples
#! lists, arrays etc change
a ,b=[2.0, 4.0],4
  function ll!(a, b)
    a[1] = b+2
  end 
ll!(a, b)
a
#!--------------------------------------------------------
function inner_alloc(A,B)
    C = similar(A)
    for j in 1:100, i in 1:100
      val = A[i,j] + B[i,j]
      C[i,j] = val[1]
    end
  end
  @btime inner_alloc(A,B)

  # there is a slight slow down and the reason for that is that we have created a heap allocated array.
  #* We still get 2 allocations 1 for matrix C and 1 for return value

  function f(A, B)
    sum([A .+ B for k in 1:10])
  end
  @btime f(A, B)

  #? Any better way?

 function ff(A, B)
    sum([A + B for k in 1:10])
  end
  @btime ff(A, B)

  #? Any better way?

  function fff(A, B)
    C = similar(A)
    for _ in 1:10
        C .+= A .+ B
    end 
    C
  end
  @btime fff(A, B) 

  #fff is faster since we have allocated one matrix already (heap allocated) and then broadcasting it


  #SIDENOTE 2D arrays can be indexed even with a single number
  #! Recall the linear model for a 2d array --> single idex wld refer to this

  function dotstar(A, B, C)
    tmp = similar(A)
    for i in 1:length(A)
        tmp[i] = A[i] * B[i]
    end
    tmp2 = similar(C)
    for i in 1:length(C)
        tmp2[i] = tmp[i]*C[i]
    end
end
@btime dotstar(A, B, C)


function dotstar2(A, B, C)
    tmp = similar(A)
    for i in 1:length(A)
        tmp[i] = A[i] * B[i] * C[i]
    end
end
@btime dotstar2(A, B, C)
#notice that the memory used for the dotstar2 is almost half this is the benefit of loop fusion
#when julia comes across a . operator it git compiles and creates a new function 
#thus under the hood the . operator is fusing many of the loops making it much  faster and less memory intesive


function unfused(A,B,C)
    tmp = A .+ B
    tmp .+ C
  end
@btime unfused(A,B,C)

fused(A,B,C) = A .+ B .+ C
@btime fused(A,B,C);
#In the above fused function we still have 2 allocations what id we dont want any allocations

#! we do the following that is use a mutating function

D = similar(A)
fused!(D,A,B,C) = (D .= A .+ B .+ C)
@btime fused!(D,A,B,C);

#? Our final aim is to use as many less loops as possible and allocate as less memory as  possible
#? Thus fusing as many loops as possible using the . operator
tmp = zeros(100,100)
function vectorized!(tmp, A, B, C)
    tmp .= A .* B.* C 
    nothing
end

function non_vectorized!(tmp, A, B, C)
    for i in 1:length(tmp)
        tmp[i] = A[i] * B[i] * C[i]
    end
     nothing
end

function non_vectorized!(tmp, A, B, C)
    for i in 1:length(tmp)
        tmp[i] = A[i] * B[i] * C[i]
    end
     nothing
end

function non_vectorized_faster!(tmp, A, B, C)
    @inbounds for i in 1:length(tmp)
        tmp[i] = A[i] * B[i] * C[i]
    end
     nothing
end

@btime vectorized!(tmp, A, B, C)
@btime non_vectorized!(tmp, A, B, C)
@btime non_vectorized_faster!(tmp, A, B, C)
#? These times tell us that checking for bounds is quite expensive and hence a code can be made faster by removing these restrictions
#? in other high level languages like python etc you are not allowed to change values outsife the bounds of the array coz this may lead to changing of data the computer might be using 
#? however we are allowed to change such values in C.
#? Thus vectorization  is fast because it utilises code from C.

#! the dot operator does a bound check at the beginning and then runs the loop and hence it still takes a little more time as compares to @inbounds

A[50, 50] #not heap allocated since size is known

@btime A[1:5, 1:5]
@btime @view A[1:5, 1:5]

#! julia when it git compiles is a fucntions calls so when we put everything in a function it runs its optimization on the entire function
#! if we were to call it directly in the repl it git compiles each individual function and hence to write faster code and benchmark things we must write them in function format.

function ff2(A)
  A[1:5, 1:5]
end
function ff3(A)
  @view A[1:5, 1:5]
end

@btime ff2(A)
@btime ff3(A)
#notice that ff3 takes very less memory 
# @view creates a pointer to that piece of memory (the same as A in this case)
#therefore if we change anything in the view A also gets changed egs
A
E = @view A[1:5, 1:5]
E[1,1]  = 2
A
#on the other hand the conventional slicing creates a new array 
A
E_slice =  A[1:5, 1:5]
E_slice[1,1]  = 4
A



using LinearAlgebra, BenchmarkTools
function alloc_timer(n)
    A = rand(n,n)
    B = rand(n,n)
    C = rand(n,n)
    t1 = @belapsed $A .* $B
    t2 = @belapsed ($C .= $A .* $B)
    t1,t2
end
ns = 2 .^ (2:11)
res = [alloc_timer(n) for n in ns]
alloc   = [x[1] for x in res]
noalloc = [x[2] for x in res]

using Plots
plot(ns,alloc,label="=",xscale=:log10,yscale=:log10,legend=:bottomright,
     title="Micro-optimizations matter for BLAS1")
plot!(ns,noalloc,label=".=")





function alloc_timer(n)
  A = rand(n,n)
  B = rand(n,n)
  C = rand(n,n)
  t1 = @belapsed $A*$B
  t2 = @belapsed mul!($C,$A,$B)
  t1,t2
end
ns = 2 .^ (2:7)
res = [alloc_timer(n) for n in ns]
alloc   = [x[1] for x in res]
noalloc = [x[2] for x in res]

using Plots
plot(ns,alloc,label="*",xscale=:log10,yscale=:log10,legend=:bottomright,
   title="Micro-optimizations only matter for small matmuls")
plot!(ns,noalloc,label="mul!")