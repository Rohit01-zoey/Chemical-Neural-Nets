# Heaps and stacks

Both the stack and the heap are parts of the memory that are available to your code to use during runtime, but are structured in different ways. 

## Stack

* The stack stores values in LIFO *last in first out.*
* Think of a plate of plates; when you add more plates, you put them on top of  the pile, and when you need the plate, you take one off the top. Adding plates from the middle or the bottom would not work as well
*  Adding data is called *pushing onto* the stack and removing data is called *popping off* the stack.

---

## Differenece between the two
* All data stored on the stack must have a known, fixed size. 
* Data with an unknown size at compile time or a size that might change must be stored on the heap instead. 
* The heap is less organized: when you put data on the heap, you request a certain amount of space. The memory allocator finds an empty spot in the heap that is big enough, marks it as being in use, and returns a pointer, which is the address of that location.
*  This process is called *allocating on the heap* and is sometimes abbreviated as just *allocating*.
*   Pushing values onto the stack is not considered allocating. Because the pointer is a known, fixed size, you can store the pointer on the stack, but when you want the actual data, you must follow the pointer.
*   Think of being seated at a restaurant. When you enter, you state the number of people in your group, and the staff finds an empty table that fits everyone and leads you there. If someone in your group comes late, they can ask where you’ve been seated to find you.

---

## Which is faster? - Pushing data
* **Pushing to the stack is faster** than allocating on the heap because the allocator never has to search for a place to store new data; that location is always at the top of the stack.
* Comparatively, allocating space on the heap requires more work, because the allocator must first find a big enough space to hold the data and then perform bookkeeping to prepare for the next allocation.

---

## Which is faster? - Popping data
* **Accessing data in the heap is slower than accessing data on the stack** because you have to follow a pointer to get there. 
* Contemporary processors are faster if they jump around less in memory. 
* Continuing the analogy, consider a server at a restaurant taking orders from many tables. It’s most efficient to get all the orders at one table before moving on to the next table. Taking an order from table A, then an order from table B, then one from A again, and then one from B again would be a much slower process.
*  By the same token, a processor can do its job better if it works on data that’s close to other data (as it is on the stack) rather than farther away (as it can be on the heap). 
*  Allocating a large amount of space on the heap can also take time.

---

## Example

```julia
using BenchmarkTools
using StaticArrays
```
```julia
function normal_array()
    arr = [1,2,3]
    return arr.^2
end
@btime normal_array()
```
```julia
julia> @btime normal_array()
 51.624 ns (2 allocations: 224 bytes)
3-element Array{Int64,1}:
 1
 4
 9
 ```
Notice that array is heap allocated. Array only encodes the datatype and so at runtime size isnt known.
```julia
function static_array()
    arr = SVector(1,2,3)
    return arr.^2
end
@btime static_array()
```
```julia
julia> @btime static_array()
  0.001 ns (0 allocations: 0 bytes)
3-element SArray{Tuple{3},Int64,1,3} with indices SOneTo(3):
 1
 4
 9
 ```
Now static vectors encode their size as well as their type and hence can be pushed onto the stack.

Thus, we observe 0 allocations for the static vector

Alse notice that stack operations are much faster.