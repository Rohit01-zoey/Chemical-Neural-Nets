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



# !!!!!!! @btime @async sleep(2) this crashes my laptopn

#=
Notice that too much of parallelism slows down computations so we must have task based parallelism.
'Task Based parallelism' has a dynamic scheduler in the background ensures effecient parallelism
=#
@btime tmap2(p -> compute_trajectory_mean5(@SVector([1.0,0.0,0.0]),p),ps)

# example of static vs dynamic scheduling
function sleepmap_static()
  out = Vector{Int}(undef,24)
  Threads.@threads for i in 1:24
    sleep(i/10)
    out[i] = i
  end
  out
end

isleep(i) = (sleep(i/10);i)

function sleepmap_spawn()
  tasks = [Threads.@spawn(isleep(i)) for i in 1:24]
  out = [fetch(t) for t in tasks]
end

@btime sleepmap_static()
@btime sleepmap_spawn()

#thus we notice that THreads.@threads takes ~9 seconds while Threads.@spawn takes only ~2
#Why isit so?
#=
the dynamic scheduler assignes the task sequetially to each thread in Threads.@threads =>
that in our egs since we have 6 threads and 24 tasks => 4 per thread i.e first 4 to first thread and so on
on the contrary the Threads.@spawn alots these at runtime.

See the detailed calculations below:-
=#
Threads.nthreads()

sum(i/10 for i in 1:4)

sum(i/10 for i in 21:24)
#= notice that the above takes 9 seconds and this agrees with out @btime calculations for Threads.@threads

9 seconds (which is precisely the result!). Thus by unevenly distributing the runtime, we run as fast as the slowest thread.
 However, dynamic scheduling allows new tasks to immediately run when another is finished, meaning that the in that case the
 shorter tasks tend to be piled together, causing a faster execution. Thus whether dynamic or static scheduling
 is beneficial is dependent on the problem and the implementation of the static schedule.

 =#
