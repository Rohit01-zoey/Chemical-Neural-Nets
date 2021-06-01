# Values vs. Bindings: The Map is Not the Territory

Refer : [site](https://www.juliabloggers.com/values-vs-bindings-the-map-is-not-the-territory-3/)

Re-posted from: [here](http://www.johnmyleswhite.com/notebook/2014/09/06/values-vs-bindings-the-map-is-not-the-territory/)

Many newcomers to Julia are confused by the seemingly dissimilar behaviors of the following two functions:

```julia
julia> a = [1, 2, 3]
3-element Array{Int64,1}:
 1
 2
 3
 
julia> function foo!(a)
           a[1] = 10
           return
       end
foo! (generic function with 1 method)
 
julia> foo!(a)
 
julia> a
3-element Array{Int64,1}:
 10
  2
  3
 ```
 ```julia
julia> function bar!(a)
           a = [1, 2]
           return
       end
bar! (generic function with 1 method)
 
julia> bar!(a)
 
julia> a
3-element Array{Int64,1}:
 10
  2
  3
```

Why does the first function successfuly alter the global variable a, but the second function does not?

To answer that question, we need to explain the distinction between values and bindings. We’ll start with a particularly simple example of a value and a binding.

In Julia, the number 1 is a value:

```julia
julia> 1
1
```
In contrast to operating on a value, the Julia assignment operation shown below creates a bindng:
```julia
julia> a = 1
1
```
This newly created **binding** is an *association between the symbolic name a and the value 1*. *In general, a binding operation always associates a specific value with a specific name*. In Julia, the valid names that can be used to create bindings are symbols, because it is important that the names be parseable without ambiguity. For example, the string "a = 1" is not an acceptable name for a binding, because it would be ambiguous with the code that binds the value 1 to the name a.

This first example of values vs. bindings might lead one to believe that values and bindings are very easy to both recognize and distinguish. Unfortunately, the values of many common objects are not obvious to many newcomers.

What, for example, is the value of the following array?

```julia
julia> [1, 2, 3]
3-element Array{Int64,1}:
 1
 2
 3
 ```
To answer this question, note that the **value of this array is not defined by the contents of the array**. You can confirm this by checking whether Julia considers two objects to be exactly identical using the === operator:

```julia
julia> 1 === 1
true
```
```julia
julia> [1, 2, 3] === [1, 2, 3]
false
```
The general rule is simple, but potentially non-intuitive: **two arrays with identical contents are not the same array**. To motivate this, think of arrays as if they were cardboard boxes. If I have two cardboard boxes, each of which contains a single ream of paper, I would not claim that the two boxes are the exact same box just because they have the same contents. Our intuitive notion of object identity is rich enough to distinguish between two containers with the same contents, but it takes some time for newcomers to programming languages to extend this notion to their understanding of arrays.

Because every container is distinct regardless of what it contains, every array is distinct because every array is its own independent container. An array’s identity is not defined by what it contains. As such, its value is not equivalent to its contents. Instead,**an array’s value is a unique identifier that allows one to reliably distinguish each array from every other array**. Think of arrays like numbered cardboard boxes. The value of an array is its identifier: thus the value of [1, 2, 3] is something like the identifier “Box 1″. Right now, “Box 1″ happens to contain the values 1, 2 and 3, but it will continue to be “Box 1″ even after its contents have changed.

Hopefully that clarifies what the value of an array is. Starting from that understanding, we need to re-examine bindings because bindings themselves behave like containers.

A binding can be thought of as a named box that can contain either 0 or 1 values. Thus, when a new Julia session is launched, the name a has no value associated with it: it is an empty container. But after executing the line, a = 1, the name has a value: the container now has one element in it. Being a container, the name is distinct from its contents. As such, the name can be rebound by a later operation: the line a = 2 will change the contents of the box called a to refer to the value 2.

The fact that bindings behave like containers becomes a source of confusion when the value of a binding is itself a container:

```julia
a = [1, 2, 3]
```

In this case, the value associated with the name a is the identifier of an array that happens to have the values 1, 2, and 3 in it. But if the contents of that array are changed, the name a will still refer to the same array — because the value associated with a is not the contents of the array, but the identifier of the array.

As such, there is a very large difference between the following two operations:

```julia
a[1] = 10
a = [1, 2]
```
* In the first case, we are changing the contents of the array that a refers to.
* In the second case, we are changing which array a refers to.
  * In this second case, we are actually creating a brand new container as an intermediate step to changing the binding of a. 
  * This new container has, as its initial contents, the values 1 and 2. 
  * After creating this new container, the name a is changed to refer to the value that is the identifier of this new container.

This is why the two functions at the start of this post behave so differently: one mutates the contents of an array, while the other mutates which array a name refers to. Because variable names in functions are local, changing bindings inside of a function does not change the bindings outside of that function. Thus, the function bar! does not behave as some would hope. To change the contents of an array wholesale, you must not change bindings: you must change the contents of the array. To do that, bar! should be written as:

```julia
function bar!(a)
    a[:] = [1, 2]
    return
end
```

The notation `a[:]` allows one to talk about the contents of an array, rather than its identifier. In general, you should not expect that you can change the contents of any container without employing some indexing syntax that allows you to talk about the contents of the container, rather than the container itself.