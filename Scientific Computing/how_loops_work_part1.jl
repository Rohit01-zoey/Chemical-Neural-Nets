#* Discrete Dynamical Systems
 function solve_system(f, u0, p, n)
    u = u0
    for _ in 1:n-1
        u = f(u, p)
    end 
    u
end 
#p is just any parameter 
f(u,p) = u^2 - p*u
typeof(f)
#notice each function has its own unique type and hence inlining can occur automatically

#notice that for the fixed points we need f(u, p) = u i.e banach fixed poiint theorem
#putting that we get u = {0, p+1} and now we must check for the derivative <1
solve_system(f, 1.0, 0.25, 1000) #* evaluate for different n for egs 1,2,3 .... and finally 1000
solve_system(f, 1.1, 0.25, 1000) # again evaluates to 0
solve_system(f, 1.25, 0.25, 4) #notice that p+1 is a fixed point 
solve_system(f, 1.251, 0.25, 1000) # blows up to infinity




function lorenz(u,p)
    α,σ,ρ,β = p
    du1 = u[1] + α*(σ*(u[2]-u[1]))
    du2 = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
    du3 = u[3] + α*(u[1]*u[2] - β*u[3])
    [du1,du2,du3]
  end

using DifferentialEquations

p = (0.02,10.0,28.0,8/3)
solve_system(lorenz,[1.0,0.0,0.0],p,1000)

# * Notice the above just gives us the final value
#* WHat if we want each step's value

function solve_system_save(f,u0,p,n)
    u = Vector{typeof(u0)}(undef,n)
    u[1] = u0
    for i in 1:n-1
      u[i+1] = f(u[i],p)
    end
    u
  end

  to_plot = solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)

  #*PLotting  the graphs

  using Plots
x = [to_plot[i][1] for i in 1:length(to_plot)]
y = [to_plot[i][2] for i in 1:length(to_plot)]
z = [to_plot[i][3] for i in 1:length(to_plot)]
plot(x,y,z)

#! Chaotic Attractor
using BenchmarkTools
@btime solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)
#notice that we have 1001 allocations that extra 1 is for the matrix itself

function solve_system_save_push(f,u0,p,n)
    u = Vector{typeof(u0)}(undef,1)
    u[1] = u0
    for i in 1:n-1
      push!(u,f(u[i],p))
    end
    u
  end 

  @btime solve_system_save_push(lorenz,[1.0,0.0,0.0],p,1000) #! Takes more time ~30 us
# notice that we have 1010 allocations those extra 10 are for the Amortization taking place
  #! Amortizes ~ 𝚶(1)
  # at each step we double the memory i.e 2 then 4 then 8 .... or any other  growth rate could be chosen

  a = solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)
  a[2]
  reduce(hcat, a)

  @btime reduce(hcat, a)
  

  function solve_system_save_matrix(f,u0,p,n)
    u = Matrix{eltype(u0)}(undef,length(u0),n)
    u[:,1] = u0
    for i in 1:n-1
      u[:,i+1] = f(u[:,i],p)
    end
    u
  end
  @btime solve_system_save_matrix(lorenz,[1.0,0.0,0.0],p,1000) #! Much worse
  # not only does it take twice the time but also has twice the number of allocations
  #slicing creates a copy and thus we have twice the allocations
  #and that extra 1 allocation refers to the output itself 

  #* Ideal number of allocations = No of outputs so in this case 1000 allocations
  #! matrix has 2001 allocations 
  #! That odd 1 allocation is the outputs itself

  #! Slicing operations creates new vector for the i th column of u which we dont want 
  #!And due to this it takes more allocations and time

  function solve_system_save_matrix_view(f,u0,p,n)
    u = Matrix{eltype(u0)}(undef,length(u0),n)
    u[:,1] = u0
    for i in 1:n-1
      u[:,i+1] = f(@view(u[:,i]),p)
    end
    u
  end
  @btime solve_system_save_matrix_view(lorenz,[1.0,0.0,0.0],p,1000)
# @view macro does not create a copy i.e it just returns the required subarray and hence our allocations are much less 1002
#notice that we have created a matrix from before that means that most of the values are
#junk until we fill them and hence the computer pre caches these and this burdens the memory

  #* Here we still are using the entire matrix and slciing it what if we concat each uodated
  #* vector steo by step?
#now we load a vector line by line will this be better?
  function solve_system_save_matrix_resize(f,u0,p,n)
    u = Matrix{eltype(u0)}(undef,length(u0),1)
    u[:,1] = u0
    for i in 1:n-1
      u = hcat(u,f(@view(u[:,i]),p))
    end
    u
  end
  @btime solve_system_save_matrix_resize(lorenz,[1.0,0.0,0.0],p,1000)
  # ! Slowest Approcach 
  #this takes the most of the time why? notice we create a new matrix each time
  # and since Amortization takes place 24:00 #!not understanding

  #therefore we always go for the vector of vector approach 
  # a vector of vectors is actually a vector of pointers 
  # and vectors will have a fixed size and hence cheap to store more

  function lorenz(du,u,p)
    α,σ,ρ,β = p
    du[1] = u[1] + α*(σ*(u[2]-u[1]))
    du[2] = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
    du[3] = u[3] + α*(u[1]*u[2] - β*u[3])
  end
  p = (0.02,10.0,28.0,8/3)
  function solve_system_save(f,u0,p,n)
    u = Vector{typeof(u0)}(undef,n)
    du = similar(u0) #notice that du is a cache array
    u[1] = u0
    for i in 1:n-1
      f(du,u[i],p)
      u[i+1] = du
    end
    u
  end
  solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)
  @btime solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)
  # it has three allocations 1 for u 1 for du and the last for the output
  #notice that the ouput is junk why is that?
  #we want to give the user 3000 points so we atleast need those many allocations but we have only 3 so we are trying to cheat and its not possible
  #in this we allocate a cache vector and continaully reuse that cache vector again and again 
  # and it changes the pointer of the i th object to the cache vector and thus the i th vector points to the cache vector 

#! very fast but outputs bad!!!! anyway to keep the speed and the outputs

#! Notice du points the the same memory place i.e all places are updated for egs

b =  solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)
b[2][1] = 2.0
display(b)# notice that all values get updated

#* To use the mutating form we need to use a new pointer/ array

function solve_system_save_copy(f,u0,p,n)
    u = Vector{typeof(u0)}(undef,n)
    du = similar(u0)
    u[1] = u0
    for i in 1:n-1
      f(du,u[i],p)
      u[i+1] = copy(du)  #* Assigns a new place to each updates vector
    end
    u
  end
  solve_system_save_copy(lorenz,[1.0,0.0,0.0],p,1000)

  @btime solve_system_save_copy(lorenz,[1.0,0.0,0.0],p,1000)

  #! u[i+1] = du copies 'du' by reference thus u[i+1] and du point to the same object. therefore any changes in du reflect in u[i+1] and vice versa
  #! on the other hand copy makes a new object of the same type as the object which 'du' refers to, and makes 'u[i+1]' refer to it. therefore now we have 2 different objects
  #! for each field of the objects if it is immutable then it will be copied by value else if it is mutable then copied by reference 
  


  using StaticArrays
function lorenz(u,p)
  α,σ,ρ,β = p
  du1 = u[1] + α*(σ*(u[2]-u[1]))
  du2 = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
  du3 = u[3] + α*(u[1]*u[2] - β*u[3])
  @SVector [du1,du2,du3]
end
p = (0.02,10.0,28.0,8/3)
function solve_system_save(f,u0,p,n)
  u = Vector{typeof(u0)}(undef,n)
  u[1] = u0
  for i in 1:n-1
    u[i+1] = f(u[i],p)
  end
  u
end
solve_system_save(lorenz,@SVector[1.0,0.0,0.0],p,1000)
using BenchmarkTools
@btime solve_system_save(lorenz,@SVector[1.0,0.0,0.0],p,1000)

#* Puts everythong on the stack and then finally allocates the value.
