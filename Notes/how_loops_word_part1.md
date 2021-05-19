# How Loops Work, An Introduction to Discrete Dynamics
## How Loops Work 1
Link to the video

---
# Contents
1. Preliminaries
   - [Cauchy's Theorem](#cauchys-theorem)
   -  [Metric Spaces](#metric-space)
2. [Banach Fixed Point Theorem](#banach-fixed-point-theorem)

---
---

## Cauchy's Theorem 
If a sequence (*x*<sub>*n*</sub>) converges then it satisfies the
Cauchy’s criterion: for *ϵ* \> 0, there exists N such that:
\|*x*<sub>*n*</sub>−*x*<sub>*m*</sub>\| \< *ϵ* for all *n*, *m* ≥ *N*

---
---
## Metric Space
A **metric space** is an *ordered pair* (*M*,*d*) where *M* is a set and
*d* is a **metric** on *M*, i.e., a **function**

*d* : *M* × *M* → ℝ

such that for any *x*, *y*, *z* ∈ *M*, the following holds:

  
1. *d*(*x*,*y*) = 0 ⇔ *x* = *y*  [identity of indiscernibles]
2. *d*(*x*,*y*) = *d*(*y*,*x*)    [symmetry] 
3. *d*(*x*,*z*) ≤ *d*(*x*,*y*) + *d*(*y*,*z*) [subadditivity] or
[triangle inequality] 

---
---

##  Lipschitz 
* Given two metric spaces (*X*, *d*<sub>*X*</sub>) and (*Y*,*d*<sub>*Y*</sub>), where *d*<sub>*X*</sub> denotes the metric on the set *X* and *d*<sub>*Y*</sub> is the metric on set *Y*, a function
*f* : *X* → *Y* is called **Lipschitz continuous** if there exists a real constant *K* ≥ 0 such that, for all *x*<sub>1</sub> and
*x*<sub>2</sub> in *X*,

*d*<sub>*Y*</sub>(*f*(*x*<sub>1</sub>),*f*(*x*<sub>2</sub>)) ≤ *K* *d*<sub>*X*</sub>(*x*<sub>1</sub>,*x*<sub>2</sub>).

* Any such *K* is referred to as **a Lipschitz constant** for the
function *f*. The smallest constant is sometimes called **the (best)
Lipschitz constant**; however, in most cases, the latter notion is less
relevant. 
   - If *K* = 1 the function is called a **short map**, and if
   - 0 ≤ *K* \< 1 and *f* maps a metric space to itself, the function is
called a **contraction**.

* In particular, a real-valued function *f* : ℝ → ℝ is called
Lipschitz continuous if there exists a positive real constant K such
that, for all real *x*<sub>1</sub> and *x*<sub>2</sub>,

\|*f*(*x*<sub>1</sub>)−*f*(*x*<sub>2</sub>)\| ≤ *K*\|*x*<sub>1</sub>−*x*<sub>2</sub>\|.

   - In this case, *Y* is the set of real numbers ℝ  with the standard metric *d*<sub>*Y*</sub>(*y<sub>1</sub>*, *y<sub>2</sub>*) =
\|*y<sub>1</sub>* − *y<sub>2</sub>*\|, and *X* is a subset of ℝ.

---

* ### *Theorem 1*
  
  Let *I* be an interval in ℝ (bounded or unbounded). Let f : I → ℝ be differentiable, with the property that | f ′(x) | ≤ M , ∀ x ∈ *I*.

Then we can show that |f(x)−f(y)| ≤ M |x−y|, for all x∈*I*.

Proof : Mean Value Theorem: *|f(x)−f(y)|=|f ′(ξ<sub>x,y</sub>)| |x−y| ≤ M |x−y|.*

---
---

## Banach Fixed Point Theorem
**Banach’s Fixed Point Theorem**, also known as **The Contraction Theorem**, concerns certain mappings (so-called contractions) of a **complete metric space** into
itself. It states conditions sufficient for the existence and uniqueness of a fixed
point, which we will see is a point that is mapped to itself. The theorem also gives
an iterative process by which we can obtain approximations to the fixed point along
with error bounds.

---

### Complete Metric Space
A metric space *M* is said to be **complete** if every [Cauchy sequence](https://en.wikipedia.org/wiki/Cauchy_sequence) converges in *M*. That is to say: if
*d*(*x*<sub>*n*</sub>,*x*<sub>*m*</sub>) → 0 as both *n* and *m*
independently go to infinity, then there is some *y* ∈ *M* with
*d*(*x*<sub>*n*</sub>,*y*) → 0.

---

### **Definition 1** - Fixed Point of a mapping
 A fixed point of a mapping T : X → X of a set X into itself
is an x ∈ X which is mapped onto itself, that is
T(x) = x.

---

* Banach’s Fixed Point Theorem is an existence and uniqueness theorem for fixed points of certain mappings.
*  As we will see from the proof, it also provides us with a constructive procedure for getting better and better approximations of the fixed
point. 
   - This procedure is called iteration; we start by choosing an arbitrary x<sub>0</sub> in a
given set, and calculate recursively a sequence x<sub>1</sub>, x<sub>2</sub>, x<sub>3</sub>, . . . by letting: 
<p style="text-align: center;">
x<sub>n+1</sub> = T x<sub>n</sub> , n = 0, 1, 2 . . .
</p>

---
## Contraction Mapping
Let (X,d) be a metric space (X is the set of points we are thinking of, here the real numbers. d is a distance function). 

Function 'f' is a *contraction mapping* if

           d(f(x),f(y)) ≤ q d(x,y) where q<1

That is, if applying f always decreases the distance.

---

## Banach Fixed Point Theorem statement and Proof
Refer [Banach Fixed Point thm](https://wiki.math.ntnu.no/_media/tma4145/2020h/banach.pdf)

---



