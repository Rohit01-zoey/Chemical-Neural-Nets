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