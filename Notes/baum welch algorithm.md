# Stochastic map
A stoshastic map is a $P \times Q$ matrix, where P and Q are 2 finite sets, matrix $A = (a_{pq})_{P\times Q}$ such that  $a_{pq}>=0, \forall p \in P$ and $q \in Q$ and $\Sigma_{q} a_{pq} = 1$ for all $p \in P$.


# Hidden Markov Models and Baum Welch Algorithm
An HMM($H, V, \theta, \psi, \pi$) consists of finite sets H (for 'hidden') and V(for 'visible')

> Transition matrix : a stochastic map $\theta$ from H to H


> Emission matrix: a stochastic map 
$\psi$ from H to V

> Initial probability distribution:  $\pi = (\pi_{h})h\in H$ on $H$, i.e., $\pi_{h}$ ≥ 0 for all $h\in H$ and $\Sigma_{h\in H} π_{h} = 1$.

Taken from [here](https://medium.com/@kangeugine/hidden-markov-model-7681c22f5b9)

T = length of the observation sequence

N = number of states in the model

M = number of observations symbols

Q = {$q_{0}, q_{1}, q_{2}, ....$} = distinct states of  the markov process

V = {$0, 1, 2 ........ M-1$} = set of possible observations

A = state transition probabilities

B = observation probability matrix

$\pi$ = initial state distribution

$\mathcal{O} = (\mathcal{O}_{0}, \mathcal{O}_{1},\mathcal{O}_{2}........., \mathcal{O}_{T-1})$ = observation sequence.



$a_{ij}$ = Pr(state $q_{j}$ at t+1|state $q_{i}$ at t)


$b_{j}(k)$ = Pr(observation k at t| state $q_j$ at t)

$\alpha_{t}(i)$ = Pr($\mathcal{O}_0, \mathcal{O}_1......, x_t = q_i|\lambda$)

$\alpha_0(i) = \pi_i b_i(\mathcal{O}_0)$

Refer to [this](https://drive.google.com/viewerng/viewer?url=https%3A//www.cs.sjsu.edu/%7Estamp/RUA/HMM.pdf&embedded=true)