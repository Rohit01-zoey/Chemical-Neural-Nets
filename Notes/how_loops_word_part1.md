# How Loops Work, An Introduction to Discrete Dynamics
## How Loops Work 1
Link to the video

---
### Cauchy's Theorem
If a sequence (*x*<sub>*n*</sub>) converges then it satisfies the
Cauchy’s criterion: for *ϵ* \> 0, there exists N such that:
\|*x*<sub>*n*</sub>−*x*<sub>*m*</sub>\| \< *ϵ* for all *n*, *m* ≥ *N*

---
### Metric Space
A **metric space** is an *ordered pair* (*M*,*d*) where *M* is a set and
*d* is a **metric** on *M*, i.e., a **function**

*d* : *M* × *M* → ℝ

such that for any *x*, *y*, *z* ∈ *M*, the following holds:

  
1. *d*(*x*,*y*) = 0 ⇔ *x* = *y*  [identity of indiscernibles]
2. *d*(*x*,*y*) = *d*(*y*,*x*)    [symmetry] 
3. *d*(*x*,*z*) ≤ *d*(*x*,*y*) + *d*(*y*,*z*) [subadditivity] or
[triangle inequality] 

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

