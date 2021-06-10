# SIMD
Refer [site](http://ftp.cvut.cz/kernel/people/geoff/cell/ps3-linux-docs/CellProgrammingTutorial/)

# Why is vectorization fast?
References. 
* [Site1](https://stackoverflow.com/questions/35091979/why-is-vectorization-faster-in-general-than-loops)
  
Vectorization (as the term is normally used) refers to SIMD (single instruction, multiple data) operation.

That means, in essence, that one instruction carries out the same operation on a number of operands in parallel. For example, to multiply a vector of size N by a scalar, let's call M the number of operands that size that it can operate on simultaneously. If so, then the number of instructions it needs to execute is approximately N/M, where (with purely scalar operations) it would have to carry out N operations.

For example, Intel's current AVX 2 instruction set uses 256-bit registers. These can be used to hold (and operate on) a set of 4 operands of 64-bits apiece, or 8 operands of 32 bits apiece.

So, assuming you're dealing with 32-bit, single-precision real numbers, that means a single instruction can do 8 operations (multiplications, in your case) at once, so (at least in theory) you can finish N multiplications using only N/8 multiplication instructions. At least, in theory, this should allow the operation to finish about 8 times as fast as executing one instruction at a time would allow.

Of course, the exact benefit depends on how many operands you support per instruction. Intel's first attempts only supported 64-bit registers, so to operate on 8 items at once, those items could only be 8 bits apiece. They currently support 256-bit registers, and they've announced support for 512-bit (and they may have even shipped that in a few high-end processors, but not in normal consumer processors, at least yet). Making good use of this capability can also be non-trivial, to put it mildly. Scheduling instructions so you actually have N operands available and in the right places at the right times isn't necessarily an easy task (at all).

To put things in perspective, the (now ancient) Cray 1 gained a lot of its speed exactly this way. Its vector unit operated on sets of 64 registers of 64 bits apiece, so it could do 64 double-precision operations per clock cycle. On optimally vectorized code, it was much closer to the speed of a current CPU than you might expect based solely on its (much lower) clock speed. Taking full advantage of that wasn't always easy though (and still isn't).

Keep in mind, however, that vectorization is not the only way in which a CPU can carry out operations in parallel. There's also the possibility of instruction-level parallelism, which allows a single CPU (or the single core of a CPU) to execute more than one instruction at a time. Most modern CPUs include hardware to (theoretically) execute up to around 4 instructions per clock cycle1 if the instructions are a mix of loads, stores, and ALU. They can fairly routinely execute close to 2 instructions per clock on average, or more in well-tuned loops when memory isn't a bottleneck.

Then, of course, there's multi-threading--running multiple streams of instructions on (at least logically) separate processors/cores.

So, a modern CPU might have, say, 4 cores, each of which can execute 2 vector multiplies per clock, and each of those instructions can operate on 8 operands. So, at least in theory, it can be carrying out 4 * 2 * 8 = 64 operations per clock.

Some instructions have better or worse throughput. For example, FP adds throughput is lower than FMA or multiply on Intel before Skylake (1 vector per clock instead of 2). But boolean logic like AND or XOR has 3 vectors per clock throughput; it doesn't take many transistors to build an AND/XOR/OR execution unit, so CPUs replicate them. Bottlenecks on the total pipeline width (the front-end that decodes and issues into the out-of-order part of the core) are common when using high-throughput instructions, rather than bottlenecks on a specific execution unit.

But, over time CPUs tend to have more resources available, so this number rises.[Refer [site](https://stackoverflow.com/questions/35091979/why-is-vectorization-faster-in-general-than-loops)]

---
# [Atomics]()
    Threads.Atomic{T}
>Holds a reference to an object of type `T`, ensuring that it is only accessed atomically, i.e. in a thread-safe manner.

Only certain "simple" types can be used atomically, namely the
primitive boolean, integer, and float-point types. These are `Bool`,
`Int8`...`Int128`, `UInt8`...`UInt128`, and `Float16`...`Float64`.
New atomic objects can be created from a non-atomic values; if none is
specified, the atomic object is initialized with zero.
Atomic objects can be accessed using the `[]` notation:
## Examples
```julia-repl
julia> x = Threads.Atomic{Int}(3)
Base.Threads.Atomic{Int64}(3)
julia> x[] = 1
1
julia> x[]
1
```
Atomic operations use an `atomic_` prefix, such as `atomic_add!`,
`atomic_xchg!`, etc.

---
# [Using Ref{T} (Core.Ref)](https://docs.julialang.org/en/v1/base/c/#Core.Ref)
    Ref{T}
* An object that safely references data of type `T`. 
* This type is guaranteed to point to valid, Julia-allocated memory of the correct type. 
* The underlying data is protected from freeing by the garbage collector as long as the `Ref` itself is referenced.
* In Julia, `Ref` objects are dereferenced (loaded or stored) with `[]`.
* Creation of a `Ref` to a value `x` of type `T` is usually written `Ref(x)`.
* Additionally, for creating interior pointers to containers (such as Array or Ptr), it can be written `Ref(a, i)` for creating a reference to the `i`-th element of `a`.
* `Ref{T}()` creates a reference to a value of type `T` without initialization.
* For a bitstype `T`, the value will be whatever currently resides in the memory allocated. 
* For a non-bitstype `T`, the reference will be undefined and attempting to
dereference it will result in an error, "UndefRefError: access to undefined reference".
* To check if a `Ref` is an undefined reference, use [`isassigned(ref::RefValue)`](@ref).
* For example, `isassigned(Ref{T}())` is `false` if `T` is not a bitstype.
* If `T` is a bitstype, `isassigned(Ref{T}())` will always be true.
* When passed as a `ccall` argument (either as a `Ptr` or `Ref` type), a `Ref` object will be converted to a native pointer to the data it references.
* For most `T`, or when converted to a `Ptr{Cvoid}`, this is a pointer to the object data. When `T` is an `isbits` type, this value may be safely mutated, otherwise mutation is strictly undefined behavior.
* As a special case, setting `T = Any` will instead cause the creation of a
pointer to the reference itself when converted to a `Ptr{Any}`
(a `jl_value_t const* const*` if T is immutable, else a `jl_value_t *const *`).
* When converted to a `Ptr{Cvoid}`, it will still return a pointer to the data region as for any other `T`.

* A `C_NULL` instance of `Ptr` can be passed to a `ccall` `Ref` argument to initialize it.
## Use in broadcasting
`Ref` is sometimes used in broadcasting in order to treat the referenced values as a scalar.
## Examples
```julia
julia> Ref(5)
Base.RefValue{Int64}(5)
julia> isa.(Ref([1,2,3]), [Array, Dict, Int]) # Treat reference values as scalar during broadcasting
3-element BitVector:
 1
 0
 0
julia> Ref{Function}()  # Undefined reference to a non-bitstype, Function
Base.RefValue{Function}(#undef)
julia> try
           Ref{Function}()[] # Dereferencing an undefined reference will result in an error
       catch e
           println(e)
       end
UndefRefError()
julia> Ref{Int64}()[]; # A reference to a bitstype refers to an undetermined value if not given
julia> isassigned(Ref{Int64}()) # A reference to a bitstype is always assigned
true
julia> Ref{Int64}(0)[] == 0 # Explicitly give a value for a bitstype reference
true
```
---

# [Reentrancy](https://stackoverflow.com/questions/1312259/what-is-the-re-entrant-lock-and-concept-in-general)
 ## Re-entrant locking

A reentrant lock is one where a process can claim the lock multiple times without blocking on itself. It's useful in situations where it's not easy to keep track of whether you've already grabbed a lock. If a lock is non re-entrant you could grab the lock, then block when you go to grab it again, effectively deadlocking your own process.

Reentrancy in general is a property of code where it has no central mutable state that could be corrupted if the code was called while it is executing. Such a call could be made by another thread, or it could be made recursively by an execution path originating from within the code itself.

If the code relies on shared state that could be updated in the middle of its execution it is not re-entrant, at least not if that update could break it.

## A use case for re-entrant locking

A (somewhat generic and contrived) example of an application for a re-entrant lock might be:

1. You have some computation involving an algorithm that traverses a graph (perhaps with cycles in it). A traversal may visit the same node more than once due to the cycles or due to multiple paths to the same node.

2. The data structure is subject to concurrent access and could be updated for some reason, perhaps by another thread. You need to be able to lock individual nodes to deal with potential data corruption due to race conditions. For some reason (perhaps performance) you don't want to globally lock the whole data structure.

3. Your computation can't retain complete information on what nodes you've visited, or you're using a data structure that doesn't allow 'have I been here before' questions to be answered quickly.

An example of this situation would be a simple implementation of Dijkstra's algorithm with a priority queue implemented as a binary heap or a breadth-first search using a simple linked list as a queue. In these cases, scanning the queue for existing insertions is O(N) and you may not want to do it on every iteration.

In this situation, keeping track of what locks you've already acquired is expensive. Assuming you want to do the locking at the node level a re-entrant locking mechanism alleviates the need to tell whether you've visited a node before. You can just blindly lock the node, perhaps unlocking it after you pop it off the queue.

## Re-entrant mutexes

A simple mutex is not re-entrant as only one thread can be in the critical section at a given time. If you grab the mutex and then try to grab it again a simple mutex doesn't have enough information to tell who was holding it previously. To do this recursively you need a mechanism where each thread had a token so you could tell who had grabbed the mutex. This makes the mutex mechanism somewhat more expensive so you may not want to do it in all situations.

IIRC the POSIX threads API does offer the option of re-entrant and non re-entrant mutexes.

# !!!!!!! Explain reentrancy NOT UNDERSTOOD
---

There are two meanings of the word “vectorization” in common usage, and they refer to different things. When we talk about “vectorized” code in Python/Numpy/Matlab/etc., we are usually referring to the fact that code like:
```python
x = [1, 2 3]
y = x + 1
```
is faster than:
```python
x = [1, 2, 3]
for i in 1:3  
  y[i] = x[i] + 1
end
```
This kind of vectorization is helpful in languages like Python and Matlab because every operation in Python is slow. Every loop iteration, every call to +, every array lookup, etc. has an inherent overhead from the way the language works. So in Python and Matlab, it’s faster to “vectorize” your code by, for example, only paying the cost of looking up the + operation once for the entire vector x rather than once for each element x[i].

Julia does not have this problem. In Julia, `y .= x .+ 1` and `for i in 1:3; y[i] = x[i] + 1`; end compile down to almost exactly the same code and perform comparably. So the kind of vectorization you need in Python and Matlab is not necessary in Julia.

The other kind of vectorization refers to SIMD operations (discussed above), and refers to your CPUs ability to perform some operations on multiple values in a single clock cycle. Julia benefits from this just as much as any other fast language. Refer [site](https://discourse.julialang.org/t/why-are-vectorized-operations-faster-in-julia/22603/4)

---

## UMA vs NUMA [taken from the notes]
Last time we described a simple multithreaded program and noticed that multithreading
has an overhead cost of around 50ns-100ns. This is due to the construction of the
new stack (amont other things) each time a new computational thread is spun up.
This means that, unlike SIMD, some thought needs to be put in as to when to
perform multithreading: it's not always a good idea. It needs to be high enough
on the cost for this to be counter-balanced.

One abstraction that was glossed over was the memory access style. Before, we
were considering a single heap, or an UMA style:

![](https://software.intel.com/sites/default/files/m/2/0/4/e/d/39352-figure-1.jpg)

However, this is the case for all shared memory devices. For example, compute
nodes on the HPC tend to be "dual Xeon" or "quad Xeon", where each Xeon processor
is itself a multicore processor. But each processor on its own accesses its own
local caches, and thus one has to be aware that this is setup in a NUMA
(non-uniform memory access) manner:

![](https://software.intel.com/sites/default/files/m/2/d/c/b/2/39353-figure-2.jpg)

where there is a cache that is closer to the processor and a cache that is further
away. Care should be taken in this to localize the computation per thread,
otherwise a cost associated with the memory sharing will be hit (but all sharing
will still be automatic).

In this sense, interthread communication is naturally done through the heap:
if you want other threads to be able to touch a value, then you can simply place
it on the heap and then it'll be available. We saw this last time by how overlapping
computations can re-use the same heap-based caches, meaning that care needs to
be taken with how one writes into a dynamically-allocated array.