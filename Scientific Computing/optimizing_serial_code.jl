using BenchmarkTools

A = rand(100,100)
B = rand(100,100)
C = rand(100,100)
function inner_rows!(C,A,B)
  for i in 1:100, j in 1:100
    C[i,j] = A[i,j] + B[i,j]
  end
  end
@btime inner_rows!(C,A,B)

function inner_cols!(C,A,B)
    for j in 1:100, i in 1:100
      C[i,j] = A[i,j] + B[i,j]
    end
  end
  @btime inner_cols!(C,A,B)
  #* Notice that the data is stored column wise and so inner_cols shd ideally
  #* run faster since it looks ahaed in data and grabs that data but in inner_rows wise
  #* we don't choose data sequentially and so ideally shd take more time

  