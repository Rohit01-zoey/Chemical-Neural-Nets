## Ordinary Differential Equations
An ODE is given by :
```
u' = f(u, p, t)
where u is state values
      p is the parameters
      t is the time/independent variable
```
Notice that the above equation can be written as vector form too.

Thus, we have the following equations(assuming we are in 3-space) :
```
u1' = f([u1, u2, u3], p, t)
u2' = f([u1, u2, u3], p, t)
u3' = f([u1, u2, u3], p, t)
```
Thus,
```
u := [u1, u2, u2]
Thus, u' = [u1', u2', u3']
=> u' = f(u, p, t)
```

### Transforming a second order differential equation to system of ODEs

Say, we have the following equation : 
```
mu'' = -ku
```
By substituiting v = u' we can write the above as :-
```
u' = v
mv' = -ku
```