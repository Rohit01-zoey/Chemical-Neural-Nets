# Concurrency vs Parallelism

---
Ref - [site](https://medium.com/@itIsMadhavan/concurrency-vs-parallelism-a-brief-review-b337c8dac350#:~:text=Concurrency%20is%20about%20dealing%20with,at%20the%20same%20time%20instant.)

---
## Concurrency
* Concurrency means that an application is making progress on more than one task at the same time (concurrently). Well, if the computer only has one CPU the application may not make progress on more than one task at exactly the same time, but more than one task is being processed at a time inside the application. It does not completely finish one task before it begins the next.
* Let's take an example in real life: There’s a challenge that requires you to both eat a whole huge cake and sing a whole song. You’ll win if you’re the fastest who sings the whole song and finishes the cake. So the rule is that you sing and eat simultaneously, How you do that does not belong to the rule. You can eat the whole cake, then sing the whole song, or you can eat half a cake, then sing half a song, then do that again, etc.
* Concurrency means executing multiple tasks at the same time but not necessarily simultaneously. There are two tasks executing concurrently, but those are run in a 1-core CPU, so the CPU will decide to run a task first and then the other task or run half a task and half another task, etc. Two tasks can start, run, and complete in overlapping time periods i.e Task-2 can start even before Task-1 gets completed. It all depends on the system architecture.
>Concurrency means executing multiple tasks at the same time but not necessarily simultaneously.


---
## Parallelism
* Parallelism means that an application splits its tasks up into smaller subtasks which can be processed in parallel, for instance on multiple CPUs at the exact same time.
* Parallelism does not require two tasks to exist. It literally physically run parts of tasks OR multiple tasks, at the same time using the multi-core infrastructure of CPU, by assigning one core to each task or sub-task.
* If we keep going with the same example as above, the rule is still singing and eating concurrently, but this time, you play in a team of two. You probably will eat and let your friend sing (because she sings better and you eat better). So this time, the two tasks are really executed simultaneously, and it’s called parallel.
* Parallelism requires hardware with multiple processing units, essentially. In single-core CPU, you may get concurrency but NOT parallelism. Parallelism is a specific kind of concurrency where tasks are really executed simultaneously.

---

## What is the difference between parallel programming and concurrent programming?
- For instance, *The Art of Concurrency* defines the difference as follows:

>A system is said to be concurrent if it can support two or more actions in progress at the same time. A system is said to be parallel if it can support two or more actions executing simultaneously.

* The key concept and difference between these definitions is the phrase **“in progress.”**

* This definition says that, in concurrent systems, multiple actions can be in progress (may not be executed) at the same time. Meanwhile, multiple actions are simultaneously executed in parallel systems. 
* In fact, concurrency and parallelism are conceptually overlapped to some degree, but “in progress” clearly makes them different.
* Concurrency is about dealing with lots of things at once.
*  Parallelism is about doing lots of things at once.
*  An application can be concurrent — but not parallel, which means that it processes more than one task at the same time, but no two tasks are executing at the same time instant.
*  An application can be parallel — but not concurrent, which means that it processes multiple sub-tasks of a task in multi-core CPU at the same time.
*  An application can be neither parallel — nor concurrent, which means that it processes all tasks one at a time, sequentially.
*  An application can be both parallel — and concurrent, which means that it processes multiple tasks concurrently in multi-core CPU at the same time.

---

# Threads and Processes 

---
---
## Processes
* A process is a program in execution. For example, when we write a program in C or C++ and compile it, the compiler creates binary code. The original code and binary code are both programs. When we actually run the binary code, it becomes a process. 
* A process is an ‘active’ entity, as opposed to a program, which is considered to be a ‘passive’ entity. A single program can create many processes when run multiple times; for example, when we open a .exe or binary file multiple times, multiple instances begin (multiple processes are created). 

---
## Process in memory
1. *Text Section*: A Process, sometimes known as the Text Section, also includes the current activity represented by the value of the Program Counter. 

2. *Stack*: The stack contains the temporary data, such as function parameters, returns addresses, and local variables. 
   
3. *Data Section*: Contains the global variable. 
   
4. *Heap Section*: Dynamically allocated memory to process during its run time.


![img1](https://media.geeksforgeeks.org/wp-content/cdn-uploads/gq/2015/06/process.png)

---
## Context switching
The process of saving the context of one process and loading the context of another process is known as Context Switching. In simple terms, it is like loading and unloading the process from the running state to the ready state. 

## When does context switching happen? 
1. When a high-priority process comes to a ready state (i.e. with higher priority than the running process)
    
2. An Interrupt occurs 
   
3. User and kernel-mode switch (It is not necessary though) 
   
4. Preemptive CPU scheduling used.

---
---
## What is a Thread?
* A thread is a path of execution within a process. 
* A process can contain multiple threads.
  
## Why Multithreading?
* A thread is also known as lightweight process. 
* *The idea is to achieve parallelism by dividing a process into multiple threads.* 
* For example, in a browser, multiple tabs can be different threads. MS Word uses multiple threads: one thread to format the text, another thread to process inputs, etc. More advantages of multithreading are discussed below

## Process vs Thread?
* The primary difference is that threads within the same process run in a shared memory space, while processes run in separate memory spaces.
* Threads are not independent of one another like processes are, and as a result threads share with other threads their code section, data section, and OS resources (like open files and signals). 
* But, like process, a thread has its own program counter (PC), register set, and stack space.
  
## Advantages of Thread over Process
1. Responsiveness: If the process is divided into multiple threads, if one thread completes its execution, then its output can be immediately returned.

2. Faster context switch: Context switch time between threads is lower compared to process context switch. Process context switching requires more overhead from the CPU.

3. Effective utilization of multiprocessor system: If we have multiple threads in a single process, then we can schedule multiple threads on multiple processor. This will make process execution faster.

4. Resource sharing: Resources like code, data, and files can be shared among all threads within a process.
Note: stack and registers can’t be shared among the threads. Each thread has its own stack and registers.

5. Communication: Communication between multiple threads is easier, as the threads shares common address space. while in process we have to follow some specific communication technique for communication between two process.




6. Enhanced throughput of the system: If a process is divided into multiple threads, and each thread function is considered as one job, then the number of jobs completed per unit of time is increased, thus increasing the throughput of the system.

---
---

![img2](https://blog-assets.risingstack.com/2017/02/kernel-processes-and-threads-1.png)
good image in mind to have for a process
1. Notice that each thread has its own stack and virtual CPU and so a thread can not access the stack of another thread despite being part of the same process.
2. However notice that the heap is common to all and hence the heap can be used to share data.

---

## Types of concurrency
* Blocking vs non blocking : Whether the thread will periodically poll for whether that task is complete, or whether it should wait for the task to complete before doing anything else

* Synchronous vs Asynchronus: Whether to execute the operation as initiated by the program or as a response to an event from the kernel.


>I/O operations cause a privileged context switch, allowing the task which is handling the I/O to directly be switched to in order to continue actions.

---
---
## Event loop

The Main Event Loop
Julia, along with other languages with a runtime (Javascript, Go, etc.) at its core is a single process running an event loop. This event loop has is the main thread, and "Julia program" or "script" that one is running is actually ran in a green thread that is controlled by the main event loop. The event loop takes over to look for other work whenever the program hits a yield point. More yield points allows for more aggressive task switching, while it also means more switches to the event loop which suspends the numerical task, i.e. making it slower. Thus yielding shouldn't interrupt the main loop!

This is one area where languages can wildly differ in implementation. Languages structured for lots of I/O and input handling, like Javascript, have yield points at every line (it's an interpreted language and therefore the interpreter can always take control). In Julia, the yield points are minimized. The common yield points are allocations and I/O (println). This means that a tight non-allocating inner loop will not have any yield points and will be a thread that is not interruptable. While this is great for numerical performance, it is something to be aware of.

Side effect: if you run a long tight loop and wish to exit it, you may try Ctrl + C and see that it doesn't work. This is because interrupts are handled by the event loop. The event loop is never re-entered until after your tight numerical loop, and therefore you have the waiting occur. If you hit Ctrl + C multiple times, you will escalate the interruption until the OS takes over and then this is handled by the signal handling of the OS's event loop, which sends a higher level interrupt which Julia handles the moment the safety locks says it's okay (these locks occur during memory allocations to ensure that memory is not corrupted)

See it by running the following example


```julia
function f(j)
    for i in 1:1000000000000rand()
        j += i
    end
    j
end
```
```julia
f(1)
```

****Do the above with caution causes REPL to crash.**


---

## Data-Parallel Problems
So not every setup is amenable to parallelism. Dynamical systems are natorious for being quite difficult to parallelize because the dependency of the future time step on the previous time step is clear, meaning that one cannot easily "parallelize through time" (though it is possible, which we will study later).

However, one common way that these systems are generally parallelized is in their inputs. The following questions allow for independent simulations:

* What steady state does an input u0 go to for some list/region of initial conditions?
* How does the solution vary when I use a different p?

The problem has a few descriptions. For one, it's called an **embaressingly parallel problem** since the problem can remain largely intact to solve the parallelism problem. To solve this, we can use the exact same solve_system_save_iip!, and just change how we are calling it. Secondly, this is called a data parallel problem, since it parallelized by splitting up the input data (here, the possible u0 or ps) and acting on them independently.

---

## [Embarrassingly Parallel Algorithms Explained](https://www.freecodecamp.org/news/embarrassingly-parallel-algorithms-explained-with-examples/)
![img2](https://cdn-media-2.freecodecamp.org/w1280/5f9c9f0c740569d1a4ca4093.jpg)

>In parallel programming, an embarrassingly parallel algorithm is one that requires no communication or dependency between the processes. Unlike distributed computing problems that need communication between tasks—especially on intermediate results, embarrassingly parallel algorithms are easy to perform on server farms that lack the special infrastructure used in a true supercomputer cluster.

Due to the nature of embarrassingly parallel algorithms, they are well suited to large, internet-based distributed platforms, and do not suffer from parallel slowdown. The opposite of embarrassingly parallel problems are inherently serial problems, which cannot be parallelized at all.

The ideal case of embarrassingly parallel algorithms can be summarized as following:

1. All the sub-problems or tasks are defined before the computations begin.
2. All the sub-solutions are stored in independent memory locations (variables, array elements).

Thus, the computation of the sub-solutions is completely independent.
If the computations require some initial or final communication, then we call it nearly embarrassingly parallel.
Many may wonder the etymology of the term “embarrassingly”. In this case, embarrassingly has nothing to do with embarrassment; in fact, it means an overabundance—here referring to parallelization problems which are “embarrassingly easy”.

A common example of an embarrassingly parallel problem is 3d video rendering handled by a graphics processing unit, where each frame or pixel can be handled with no interdependency. Some other examples would be protein folding software that can run on any computer with each machine doing a small piece of the work, generation of all subsets, random numbers, and Monte Carlo simulations.

Also can refer to this [site](https://www.cise.ufl.edu/research/ParallelPatterns/PatternLanguage/AlgorithmStructure/EmbParallel.htm)
# [Multi-Threading](https://docs.julialang.org/en/v1/manual/multi-threading/#Starting-Julia-with-multiple-threads)

## Starting Julia with multiple threads

By default, Julia starts up with a single thread of execution. This can be verified by using the
command [`Threads.nthreads()`](@ref):

```julia-repl
julia> Threads.nthreads()
1
```

The number of execution threads is controlled either by using the
`-t`/`--threads` command line argument or by using the
[`JULIA_NUM_THREADS`](@ref JULIA_NUM_THREADS) environment variable. When both are
specified, then `-t`/`--threads` takes precedence.

!!! compat "Julia 1.5"
    The `-t`/`--threads` command line argument requires at least Julia 1.5.
    In older versions you must use the environment variable instead.

Lets start Julia with 4 threads:

```bash
$ julia --threads 4
```

Let's verify there are 4 threads at our disposal.

```julia-repl
julia> Threads.nthreads()
4
```

But we are currently on the master thread. To check, we use the function [`Threads.threadid`](@ref)

```julia-repl
julia> Threads.threadid()
1
```

---
---

## The `@threads` Macro

Let's work a simple example using our native threads. Let us create an array of zeros:

```jldoctest
julia> a = zeros(10)
10-element Vector{Float64}:
 0.0
 0.0
 0.0
 0.0
 0.0
 0.0
 0.0
 0.0
 0.0
 0.0
```

Let us operate on this array simultaneously using 4 threads. We'll have each thread write its
thread ID into each location.

Julia supports parallel loops using the [`Threads.@threads`](@ref) macro. This macro is affixed
in front of a `for` loop to indicate to Julia that the loop is a multi-threaded region:

```julia-repl
julia> Threads.@threads for i = 1:10
           a[i] = Threads.threadid()
       end
```

The iteration space is split among the threads, after which each thread writes its thread ID
to its assigned locations:

```julia-repl
julia> a
10-element Array{Float64,1}:
 1.0
 1.0
 1.0
 2.0
 2.0
 2.0
 3.0
 3.0
 4.0
 4.0
```

Note that [`Threads.@threads`](@ref) does not have an optional reduction parameter like [`@distributed`](@ref).

---
---
# [Performance Tips](https://docs.julialang.org/en/v1.5/manual/performance-tips/)

In the following sections, we briefly go through a few techniques that can help make your Julia
code run as fast as possible.

## Performance critical code should be inside a function

>Any code that is performance critical should be inside a function. Code inside functions tends to run much faster than top level code, due to how Julia's compiler works.

The use of functions is not only important for performance: functions are more reusable and testable, and clarify what steps are being done and what their inputs and outputs are, [Write functions, not just scripts](@ref) is also a recommendation of Julia's Styleguide.

>The functions should take arguments, instead of operating directly on global variables, see the next point.

## Avoid global variables

>>A global variable might have its value, and therefore its type, change at any point. This makes it difficult for the compiler to optimize code using global variables. Variables should be local, or passed as arguments to functions, whenever possible.


We find that global names are frequently constants, and declaring them as such greatly improves
performance:

```julia
const DEFAULT_VAL = 0
```

Uses of non-constant globals can be optimized by annotating their types at the point of use:

```julia
global x = rand(1000)

function loop_over_global()
    s = 0.0
    for i in x::Vector{Float64}
        s += i
    end
    return s
end
```

Passing arguments to functions is better style. It leads to more reusable code and clarifies what the inputs and outputs are.


>   All code in the REPL is evaluated in global scope, so a variable defined and assigned at top level will be a **global** variable. Variables defined at top level scope inside modules are also global.

In the following REPL session:

```julia-repl
julia> x = 1.0
```

is equivalent to:

```julia-repl
julia> global x = 1.0
```

so all the performance issues discussed previously apply.

## Measure performance with [`@time`](@ref) and pay attention to memory allocation

A useful tool for measuring performance is the [`@time`](@ref) macro. We here repeat the example
with the global variable above, but this time with the type annotation removed:

```jldoctest; setup = :(using Random; Random.seed!(1234)), filter = r"[0-9\.]+ seconds \(.*?\)"
julia> x = rand(1000);

julia> function sum_global()
           s = 0.0
           for i in x
               s += i
           end
           return s
       end;

julia> @time sum_global()
  0.009639 seconds (7.36 k allocations: 300.310 KiB, 98.32% compilation time)
496.84883432553846

julia> @time sum_global()
  0.000140 seconds (3.49 k allocations: 70.313 KiB)
496.84883432553846
```

On the first call (`@time sum_global()`) the function gets compiled. (If you've not yet used [`@time`](@ref)
in this session, it will also compile functions needed for timing.)  You should not take the results
of this run seriously. For the second run, note that in addition to reporting the time, it also
indicated that a significant amount of memory was allocated. We are here just computing a sum over all elements in
a vector of 64-bit floats so there should be no need to allocate memory (at least not on the heap which is what `@time` reports).

> Unexpected memory allocation is almost always a sign of some problem with your code, usually a problem with type-stability or creating many small temporary arrays.

> Consequently, in addition to the allocation itself, it's very likely that the code generated for your function is far from optimal. Take such indications seriously and follow the advice below.

If we instead pass `x` as an argument to the function it no longer allocates memory
(the allocation reported below is due to running the `@time` macro in global scope)
and is significantly faster after the first call:

```jldoctest sumarg; setup = :(using Random; Random.seed!(1234)), filter = r"[0-9\.]+ seconds \(.*?\)"
julia> x = rand(1000);

julia> function sum_arg(x)
           s = 0.0
           for i in x
               s += i
           end
           return s
       end;

julia> @time sum_arg(x)
  0.006202 seconds (4.18 k allocations: 217.860 KiB, 99.72% compilation time)
496.84883432553846

julia> @time sum_arg(x)
  0.000005 seconds (1 allocation: 16 bytes)
496.84883432553846
```

The 1 allocation seen is from running the `@time` macro itself in global scope. If we instead run
the timing in a function, we can see that indeed no allocations are performed:

```jldoctest sumarg; filter = r"[0-9\.]+ seconds"
julia> time_sum(x) = @time sum_arg(x);

julia> time_sum(x)
  0.000001 seconds
496.84883432553846
```

In some situations, your function may need to allocate memory as part of its operation, and this
can complicate the simple picture above. In such cases, consider using one of the [tools](@ref tools)
below to diagnose problems, or write a version of your function that separates allocation from
its algorithmic aspects (see [Pre-allocating outputs](@ref)).

!!! note
    For more serious benchmarking, consider the [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl)
    package which among other things evaluates the function multiple times in order to reduce noise.

---
---
# [Closures](https://riptutorial.com/julia-lang/example/23207/introduction-to-closures#:~:text=Functions%20are%20an%20important%20part,functions%20are%20called%20%22closures%22.)

Functions are an important part of Julia programming. They can be defined directly within modules, in which case the functions are referred to as top-level. 
>But functions can also be defined within other functions. Such functions are called "closures".

Closures capture the variables in their outer function. A top-level function can only use global variables from their module, function parameters, or local variables:
```julia
x = 0  # global
function toplevel(y)
    println("x = ", x, " is a global variable")
    println("y = ", y, " is a parameter")
    z = 2
    println("z = ", z, " is a local variable")
end
```
> A closure, on the other hand, can use all those in addition to variables from outer functions that it captures:
```julia
x = 0  # global
function toplevel(y)
    println("x = ", x, " is a global variable")
    println("y = ", y, " is a parameter")
    z = 2
    println("z = ", z, " is a local variable")

    function closure(v)
        println("v = ", v, " is a parameter")
        w = 3
        println("w = ", w, " is a local variable")
        println("x = ", x, " is a global variable")
        println("y = ", y, " is a closed variable (a parameter of the outer function)")
        println("z = ", z, " is a closed variable (a local of the outer function)")
    end
end
```
If we run `c = toplevel(10)`, we see the result is

```julia-repl
julia> c = toplevel(10)
x = 0 is a global variable
y = 10 is a parameter
z = 2 is a local variable
(::closure) (generic function with 1 method)
```
Note that the tail expression of this function is a function in itself; that is, a closure. We can call the closure `c` like it was any other function:

```julia-repl
julia> c(11)
v = 11 is a parameter
w = 3 is a local variable
x = 0 is a global variable
y = 10 is a closed variable (a parameter of the outer function)
z = 2 is a closed variable (a local of the outer function)
```
Note that `c` still has access to the variables `y` and `z` from the toplevel call — even though `toplevel` has already returned! Each closure, even those returned by the same function, closes over different variables. We can call `toplevel` again

```julia-repl
julia> d = toplevel(20)
x = 0 is a global variable
y = 20 is a parameter
z = 2 is a local variable
(::closure) (generic function with 1 method)
```

```julia-repl
julia> d(22)
v = 22 is a parameter
w = 3 is a local variable
x = 0 is a global variable
y = 20 is a closed variable (a parameter of the outer function)
z = 2 is a closed variable (a local of the outer function)

```

```julia-repl
julia> c(22)
v = 22 is a parameter
w = 3 is a local variable
x = 0 is a global variable
y = 10 is a closed variable (a parameter of the outer function)
z = 2 is a closed variable (a local of the outer function)
```
> Note that despite `d` and `c` having the same code, and being passed the same arguments, their output is different. They are distinct closures.


---
---
# [What does the `...` operator do?](https://docs.julialang.org/en/v1.5/manual/faq/#What-does-the-...-operator-do?)

## The two uses of the `...` operator: slurping and splatting

Many newcomers to Julia find the use of `...` operator confusing. Part of what makes the `...`
operator confusing is that it means two different things depending on context.

## `...` combines many arguments into one argument in function definitions

In the context of function definitions, the `...` operator is used to combine many different arguments
into a single argument. This use of `...` for combining many different arguments into a single
argument is called slurping:

```jldoctest
julia> function printargs(args...)
           println(typeof(args))
           for (i, arg) in enumerate(args)
               println("Arg #$i = $arg")
           end
       end
printargs (generic function with 1 method)

julia> printargs(1, 2, 3)
Tuple{Int64, Int64, Int64}
Arg #1 = 1
Arg #2 = 2
Arg #3 = 3
```

If Julia were a language that made more liberal use of ASCII characters, the slurping operator
might have been written as `<-...` instead of `...`.

#### `...` splits one argument into many different arguments in function calls


>In contrast to the use of the `...` operator to denote slurping many different arguments into one argument when defining a function, the `...` operator is also used to cause a single function argument to be split apart into many different arguments when used in the context of a function call. This use of `...` is called splatting:

```jldoctest
julia> function threeargs(a, b, c)
           println("a = $a::$(typeof(a))")
           println("b = $b::$(typeof(b))")
           println("c = $c::$(typeof(c))")
       end
threeargs (generic function with 1 method)

julia> x = [1, 2, 3]
3-element Vector{Int64}:
 1
 2
 3

julia> threeargs(x...)
a = 1::Int64
b = 2::Int64
c = 3::Int64
```

If Julia were a language that made more liberal use of ASCII characters, the splatting operator
might have been written as `...->` instead of `...`.

---
---

# [Maps](https://docs.julialang.org/en/v1/base/collections/#Base.map)
    map(f, c...) -> collection
Transform collection `c` by applying `f` to each element. For multiple collection arguments,
apply `f` elementwise.

# Examples
```jldoctest
julia> map(x -> x * 2, [1, 2, 3])
3-element Vector{Int64}:
 2
 4
 6
julia> map(+, [1, 2, 3], [10, 20, 30])
3-element Vector{Int64}:
 11
 22
 33
```

---
---
# [Learning the hard way](https://github.com/JuliaLang/IJulia.jl/issues/882)

Running Threads.nthreads() on jupyter notebook gives 1 as the output and hence the effects of parallelism are not observed. 

There's no way to start more Julia threads at runtime, unfortunately. Beyond that,
```julia
Threads.nthread() = 12
```

is not really idiomatic Julia. All it does is overwrite the function that calls into Julia's internals to determine the number of threads so that it just returns the number 12 - it doesn't actually increase the number of threads in any way. Typically, the kinds of APIs that do that kind of thing will look like Threads.set_nthreads!(12) (but, as I mentioned, that doesn't exist in Julia).

If you want to do multithreading in Julia with Jupyter, you have to create a new kernelspec.
```julia
using IJulia
IJulia.installkernel("Julia 12 Threads", env=Dict(
    "JULIA_NUM_THREADS" => "12",
))
```
Then you can create a new notebook using that kernel (or change the kernel of an existing notebook in the Kernel > Change Kernel menu) and run code as you expect.
```julia
Threads.@threads for i in 1:10
    println(Threads.threadid())
end
```
outputs (on my machine)
```julia-repl
5
3
6
4
8
7
2
9
1
10
```