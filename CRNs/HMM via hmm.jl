using HMMBase
using Distributions
T = 4 #
N = 2#number of hidden states
M = 3 #numbaer of observable states
Q = [1, 2] #say H => 1 and C => 2
V = [0, 1, 2] #small => 0, medium => 1 and  large => 3

A = [0.7 0.3; 0.4 0.6]
B = [0.1 0.4 0.5; 0.7 0.2 0.1]
B = [MvNormal([0.0, 5.0], ones(2) * 1), MvNormal([0.0, 5.0], ones(2) * 3)]

π = [0.6, 0.4] #intial state distribution

#now say we observe the follwing sequence :
O = [0, 1, 0, 2]

hmm = HMM(π, A, B)
