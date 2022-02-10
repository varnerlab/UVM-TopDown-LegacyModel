include("Include.jl")

# load the system model -
model = parameters();

# setup the solver -
xₒ = [100.0; 0.0001]
tspan = (0.0, 10.0)
prob = ODEProblem(balances, xₒ, tspan, model)
sol = solve(prob)