include("Include.jl")

# Phase 1: build a default model dictionary -
path_model_file = "Coagulation.net"

# load the file -
model_buffer = read_model_file(path_model_file)

# build the default dictionary -
dd = build_default_model_dictionary(model_buffer)


# Phase 2: customize the dictionary -
SF = 1e9 # all concentrations are in nmol/L
sfa = dd["static_factors_array"]
# sfa[1] = (2.5e-9) # 1 TFPI
# sfa[2] = (3.4e-6) # 2 AT
# sfa[3] = (5e-12)  # 3 TF
# sfa[6] = (1e-9)   # 6 TRAUMA

sfa[2] = (3.4e-6)*SF        # 2 AT
sfa[3] = (5e-12)*SF         # 3 TF
sfa[6] = 0.01              # 6 TRAUMA
#sfa = SF*sfa

ℳ = dd["number_of_dynamic_states"]
xₒ = zeros(ℳ)
xₒ[1] = (1.4e-6)    # 1 FII 
xₒ[2] = (1e-8)      # 2 FVII 
xₒ[3] = (2e-8)      # 3 FV
xₒ[4] = (1.6e-7)    # 4 FX
xₒ[5] = (7e-10)     # 5 FVIII
xₒ[6] = (9e-8)      # 6 FIX
xₒ[7] = (1e-8)      # 7 FXI
xₒ[8] = (1e-8)      # 8 FXII 
xₒ[9] = (1e-13)     # 9 FIIa
xₒ = SF*xₒ # convert to nmol

# update the G -
G = dd["G"]
G[10,4] = 0.1

# what is the index of TRAUMA?
idx = indexin(dd,"AT")
G[idx,9] = 0.01

# Phase 3: solve the model -
# setup the solver -
tspan = (0.0, 10.0)
prob = ODEProblem(balances, xₒ, tspan, dd; saveat=0.01)
soln = solve(prob)

T = soln.t
X = hcat(soln.u...)