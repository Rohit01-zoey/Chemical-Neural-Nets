#* Discrete Dynamical Systems
 function solve_system(f, u0, p, n)
    u = u0
    for _ in 1:n-1
        u = f(u, p)
    end 
    u
end 

f(u,p) = u^2 - p*u
typeof(f)

solve_system(f, 1.251, 0.25, 100000)

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

function solve_system_save_push(f,u0,p,n)
    u = Vector{typeof(u0)}(undef,1)
    u[1] = u0
    for i in 1:n-1
      push!(u,f(u[i],p))
    end
    u
  end 

  @btime solve_system_save_push(lorenz,[1.0,0.0,0.0],p,1000) #! Takes more time ~30 us

  #! Amortizes ~ 𝚶(1)

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
  @btime solve_system_save_matrix(lorenz,[1.0,0.0,0.0],p,1000) #! Much worst

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

  #* Here we still are using the entire matrix and slciing it what if we concat each uodated
  #* vector steo by step?

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

  function lorenz(du,u,p)
    α,σ,ρ,β = p
    du[1] = u[1] + α*(σ*(u[2]-u[1]))
    du[2] = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
    du[3] = u[3] + α*(u[1]*u[2] - β*u[3])
  end
  p = (0.02,10.0,28.0,8/3)
  function solve_system_save(f,u0,p,n)
    u = Vector{typeof(u0)}(undef,n)
    du = similar(u0)
    u[1] = u0
    for i in 1:n-1
      f(du,u[i],p)
      u[i+1] = du
    end
    u
  end
  solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)
  @btime solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)
#! very fast but outputs bad!!!! anyway to keep the speed and the outputs

#! Notice du points the the same memory place i.e all places are updated for egs

b =  solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)
b[2][1] = 2.0
display(b)

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
