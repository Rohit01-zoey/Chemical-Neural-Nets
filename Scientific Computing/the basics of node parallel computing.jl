using StaticArrays, BenchmarkTools
function lorenz(u,p)
  α,σ,ρ,β = p
  @inbounds begin
    du1 = u[1] + α*(σ*(u[2]-u[1]))
    du2 = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
    du3 = u[3] + α*(u[1]*u[2] - β*u[3])
  end
  @SVector [du1,du2,du3]
end

function lorenz!(du,u,p)
  α,σ,ρ,β = p
  @inbounds begin
    du[1] = u[1] + α*(σ*(u[2]-u[1]))
    du[2] = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
    du[3] = u[3] + α*(u[1]*u[2] - β*u[3])
  end
end

function solve_system_save!(u,f,u0,p,n)
  @inbounds u[1] = u0
  @inbounds for i in 1:length(u)-1
    u[i+1] = f(u[i],p)
  end
  u
end

p = (0.02,10.0,28.0,8/3)
u = Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,1000)

const _u_cache = Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,1000)
const _u_cache_threads = [Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,1000) for i in 1:Threads.nthreads()]

function _compute_trajectory_mean4(u,u0,p)
  solve_system_save!(u,lorenz,u0,p,1000);
  mean(u)
end
compute_trajectory_mean4(u0,p) = _compute_trajectory_mean4(_u_cache,u0,p)
@btime compute_trajectory_mean4(@SVector([1.0,0.0,0.0]),p)

function compute_trajectory_mean5(u0,p)
  # u is automatically captured
  solve_system_save!(_u_cache_threads[Threads.threadid()],lorenz,u0,p,1000);
  mean(_u_cache)
end
@btime compute_trajectory_mean5(@SVector([1.0,0.0,0.0]),p)

function tmap2(f,ps)
  tasks = [Threads.@spawn f(ps[i]) for i in 1:1000]
  out = [fetch(t) for t in tasks]
  #fetch is a type of blocking operation which doesn not allow the task at hand to finish until the thread spun has finished
end

ps = [(0.02,10.0,28.0,8/3) .* (1.0,rand(3)...) for i in 1:1000]


threaded_out = tmap2(p -> compute_trajectory_mean5(@SVector([1.0,0.0,0.0]),p),ps)

#=

Julia has provided this with a dynamic scheduler and thus the operation while executing can choose between concurrent or parallel on its own
So the user does not have to choose
See the md file for an example >>>  or run the code below
=#

function withthreads()
    arr = zeros(Int, 10)
    Threads.@threads for i in 1:10
       sleep(3 * rand())
       arr[i] = i
    end
    println("with @threads: $arr")
end

function withspawn()
    arr = zeros(Int, 10)
    for i in 1:10
        Threads.@spawn begin
            sleep(3 * rand())
            arr[i] = i
        end
    end
    println("with @spawn: $arr")
end

function withsync()
    arr = zeros(Int, 10)
    @sync begin  #notice the syntax for this macro
        for i in 1:10
           Threads.@spawn begin
               sleep(3 * rand())
               arr[i] = i
           end
        end
    end
    println("with @sync: $arr")
end
withthreads()
withspawn()
withsync()

@btime withthreads();
@btime withspawn();
@btime withsync();
#----------------------------------------


function threaded(batches)
    ret = zeros(Int, Threads.nthreads())
    Threads.@threads for i in 1:batches
        ret[Threads.threadid()] += 1
    end
    return ret
end

function spawned(batches)
    ret = zeros(Int, Threads.nthreads())
    @sync for i in 1:batches
        Threads.@spawn ret[Threads.threadid()] += 1
    end
    return ret
end
threaded(10)
spawned(10)


@btime @sync for i in 1:10
    @async sleep(2)
end

@btime  for i in 1:10
    @async sleep(2)
end
