#* Discrete Dynamical Systems
 function solve_system(f, u0, p, n)
    u = u0
    for _ in 1:n-1
        u = f(u, p)
    end 
    u
end 

f(u,p) = u^2 - p*u
typeof(f)

solve_system(f, 1.251, 0.25, 100000)