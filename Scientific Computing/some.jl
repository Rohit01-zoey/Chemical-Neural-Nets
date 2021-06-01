using StaticArrays
arr = SVector{5}([1,2,3])
arr2 = @SVector [1,2,3]

A = rand(3, 3)
A[4]
typeof(A)
B = SMatrix{3,3}(A)

C = @SArray rand(2,2,2)
rand(2, 2,2)

length([1, 2, 3])