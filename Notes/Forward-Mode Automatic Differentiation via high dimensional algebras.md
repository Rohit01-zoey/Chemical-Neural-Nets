# Machine epsilon
Most real numbers cannot be represented exactly with floating-point numbers, and so for many purposes it is important to know the distance between two adjacent representable floating-point numbers, which is often known as [machine epsilon](https://en.wikipedia.org/wiki/Machine_epsilon).

Julia provides `eps`, which gives the distance between `1.0` and the next larger representable floating-point value:
```julia-repl
julia> eps(Float32)
1.1920929f-7

julia> eps(Float64)
2.220446049250313e-16

julia> eps() # same as eps(Float64)
2.220446049250313e-16
```
These values are `2.0^-23` and `2.0^-52` as `Float32` and `Float64` values, respectively. The `eps` function can also take a floating-point value as an argument, and gives the absolute difference between that value and the next representable floating point value. That is, `eps(x)` yields a value of the same type as `x` such that `x + eps(x)` is the next representable floating-point value larger than `x`:

```julia-repl
julia> eps(1.0)
2.220446049250313e-16

julia> eps(1000.)
1.1368683772161603e-13

julia> eps(1e-27)
1.793662034335766e-43

julia> eps(0.0)
5.0e-324
```
> The distance between two adjacent representable floating-point numbers is not constant, but is smaller for smaller values and larger for larger values.

>  In other words, the representable floating-point numbers are densest in the real number line near zero, and grow sparser exponentially as one moves farther away from zero. By definition, `eps(1.0)` is the same as `eps(Float64)` since `1.0` is a 64-bit floating-point value.

Julia also provides the `nextfloat` and `prevfloat` functions which return the next largest or smallest representable floating-point number to the argument respectively:

```julia-repl
julia> x = 1.25f0
1.25f0

julia> nextfloat(x)
1.2500001f0

julia> prevfloat(x)
1.2499999f0

julia> bitstring(prevfloat(x))
"00111111100111111111111111111111"

julia> bitstring(x)
"00111111101000000000000000000000"

julia> bitstring(nextfloat(x))
"00111111101000000000000000000001"
```

> This example highlights the general principle that the adjacent representable floating-point numbers also have adjacent binary integer representations.

![](../Images/IEEE_float32.png)
Therefore, the above leads to many problems:

For example, when we add two numbers we need to ensure their in the same base. Thus, if the numbers are very far apart in terms of order then we need to 'drop' off many digits off the smaller number for the exponents that is the orders off the 2 numbers to match.

This also leads to `Round off Error`.

Thus issues with *roundoff error* come when one subtracts out the higher digits.
For example, $(x + \epsilon) - x$ should just be $\epsilon$ if there was no
roundoff error, but if $\epsilon$ is small then this kicks in. If $x = 1$
and $\epsilon$ is of size around $10^{-10}$, then $x+ \epsilon$ is correct for
10 digits, dropping off the smallest 6 due to error in the addition to $1$.
But when you subtract off $x$, you don't get those digits back, and thus you
only have 6 digits of $\epsilon$ correct.
```julia-repl
julia> ϵ = 1e-10rand()
julia> @show ϵ
ϵ = 1.1923160486570606e-12
1.1923160486570606e-12

julia> @show (1+ϵ)
1 + ϵ = 1.0000000000011924
1.0000000000011924
```
Notice that the few digits of $\epsilon$ have been dropped off while addition.

```julia-repl
julia> ϵ2 = (1+ϵ) - 1
1.1923795284474181e-12

julia> (ϵ - ϵ2)
-6.347979035750706e-17
```
Ideally, we should get 0 as the answer for the above calculation.However, that's not the case. Notice that we get the subtraction of the order of `-17`. Recall that the smallest number that can be represented is of the order of `-16`.


See how $\epsilon$ is only rebuilt at accuracy around $10^{-16}$ and thus we only
keep around 6 digits of accuracy when it's generated at the size of around $10^{-10}$!

>Thus, due to this Roundoff error that we have we can say that Floating point numbers are NOT associative  nor commutative under addition or subtraction.

Refer to the following for more information on [Loss of Significance](https://en.wikipedia.org/wiki/Loss_of_significance)

---

# Finite Differencing and Numerical Stability

To start understanding how to compute derivatives on a computer, we start with
*finite differencing*. For finite differencing, recall that the definition of
the derivative is:

$$f'(x) = \lim_{\epsilon \rightarrow 0} \frac{f(x+\epsilon)-f(x)}{\epsilon}$$
> Notice where the problem is. Recall what we did above. When we do $\epsilon 2$ = (1+$\epsilon$) - 1, the compiler cut off many digits off of $\epsilon$. Now , when we divide this value by $\epsilon$ again, we shift the number in terms of the power/order which means our error increases. So, we will get few good digits at first, but soon we would get only junk digits.

> One can build a random number generator from this :)
* Finite differencing directly follows from this definition by choosing a small
$\epsilon$.
* However, choosing a good $\epsilon$ is very difficult. 
* If $\epsilon$ is too large than there is error since this definition is asymtopic.
* However, if $\epsilon$ is too small, you receive roundoff error. 
* To understand why you would get roundoff error, recall that floating point error is relative, and can essentially store 16 digits of accuracy. 
* So let's say we choose $\epsilon = 10^{-6}$. Then $f(x+\epsilon) - f(x)$ is roughly the same in the first 6 digits, meaning that after the subtraction there is only 10 digits of
accuracy, and then dividing by $10^{-6}$ simply brings those 10 digits back up
to the correct relative size.

![](https://www.researchgate.net/profile/Jongrae_Kim/publication/267216155/figure/fig1/AS:651888458493955@1532433728729/Finite-Difference-Error-Versus-Step-Size.png)


> This means that we want to choose $\epsilon$ small enough that the
$\mathcal{O}(\epsilon^2)$ error of the truncation is balanced by the $O(1/\epsilon)$
roundoff error. Under some minor assumptions, one can argue that the average
best point is $\sqrt(E)$, where E is machine epsilon

```julia-repl
julia> @show eps(Float64)
eps(Float64) = 2.220446049250313e-16
2.220446049250313e-16

julia> @show sqrt(eps(Float64))
sqrt(eps(Float64)) = 1.4901161193847656e-8
1.4901161193847656e-8

```
This means we should not expect better than 8 digits of accuracy, even when
things are good with finite differencing.

![](../Images/derivative%20vs%20epsilon.png)
!! The above image uses `h` in place of $\epsilon$. That is, that while differentiating a function `f` we must do $\frac{f(x+h) - f(x)}{h}$ 
> Notice that in the above image we have the  optimum $\epsilon$ of the order $10^{-8}$ which is what we had calculated as the square root of the machine epsilon!!!

The centered difference formula is a little bit better, but this picture
suggests something much better...