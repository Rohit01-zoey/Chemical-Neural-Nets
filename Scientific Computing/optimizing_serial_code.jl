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
      val = [A[i,j] + B[i,j]]
      C[i,j] = val[1]
    end
  end
  @btime inner_alloc!(C,A,B)


  function inner_noalloc!(C,A,B)
    for j in 1:100, i in 1:100
      val = A[i,j] + B[i,j]
      C[i,j] = val[1]
    end
  end
  @btime inner_noalloc!(C,A,B)

  #! the only way to store variable sized arrays is to hv a pointer pointing to that memory

  using StaticArrays
  val = SVector{3, Float64}(1.0, 2.0, 3.0)
  typeof(val)
  #* Thus notice that we need 64*3 bits to store all the data.

#!--------------------------------------------------------
function static_inner_alloc!(C,A,B)
  for j in 1:100, i in 1:100
    val = @SVector [A[i,j] + B[i,j]]
    C[i,j] = val[1]
  end
end
@btime static_inner_alloc!(C,A,B)
#* notice that we get 0 allocations here since size is known and 
#* thusit lives on the stack and Hence 0 allocations.
#! @SVector is a macro i.e Syntatic sugar for
    #! (SArray{Tuple{1}, T, 1, 1} where T)((A[i,j] + B[i,j],))

#! Stack follows LIFO and Hence putting huge data into the stack 
#! does not imply faster operations

#!--------------------------------------------------------
function inner_noalloc!(C,A,B)
    for j in 1:100, i in 1:100
      val = A[i,j] + B[i,j]
      C[i,j] = val[1]
    end
  end
  @btime inner_noalloc!(C,A,B)

  #* Bang => mutating => chnages the first value of the parameters
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

  #SIDENOTE 2D arrays can be indexed even with a single number
  #! Recall the linear model for a 2d array --> single idex wld refer to thus

  