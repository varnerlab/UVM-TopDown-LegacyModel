include("Include.jl")

# Phase 1: build a default model dictionary -
path_model_file = "Coagulation.net"

# load the file -
model_buffer = read_model_file(path_model_file)

# build the default dictionary -
dd = build_default_model_dictionary(model_buffer)

# Phase 2: customize the dictionary -
sfa = dd["static_factors_array"]
sfa[3] = 1.0
sfa[6] = 1.0

ℳ = dd["number_of_dynamic_states"]
xₒ = zeros(ℳ)
xₒ[1] = 10.0
xₒ[2] = 10.0
xₒ[3] = 10.0
xₒ[4] = 10.0
xₒ[5] = 10.0
xₒ[6] = 10.0
xₒ[7] = 10.0
xₒ[8] = 10.0

# setup the solver -
tspan = (0.0, 10.0)
prob = ODEProblem(balances, xₒ, tspan, dd)
soln = solve(prob)

T = soln.t
X = hcat(soln.u...)