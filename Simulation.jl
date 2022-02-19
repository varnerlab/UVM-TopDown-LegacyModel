# include 
include("Include.jl")

# load data and model files -
path_model_file = "Coagulation.net"
path_data_file = joinpath(_PATH_TO_DATA, "Thrombin-TF.csv")

# load the experimental data -
data_table = load(path_data_file)
model_buffer = read_model_file(path_model_file)

# get size -
(ℛ, 𝒞) = size(data_table)
SF = 1e9 # all concentrations are in nmol/L

# build the default dictionary -
model = build_default_model_dictionary(model_buffer)

# setup -
FIIa_archive = Array{Array{Float64,1},1}(undef, ℛ)
T_archive = Array{Array{Float64,1},1}(undef, ℛ)

# main loop -
for i ∈ 1:ℛ

    # build new model -
    dd = deepcopy(model)

    # setup static -
    sfa = dd["static_factors_array"]
    sfa[1] = (2.5e-9) * SF        # 1 TFPI
    sfa[2] = (3.4e-6) * SF        # 2 AT
    sfa[3] = (5e-12) * SF         # 3 TF
    sfa[6] = 0.005                # 6 TRAUMA

    # grab the multiplier from the data -
    ℳ = dd["number_of_dynamic_states"]
    xₒ = zeros(ℳ)
    xₒ[1] = (1.4e-6) * (data_table[i, :II] / 100.0)     # 1 FII 
    xₒ[2] = (1e-8) * (data_table[i, :VII] / 100.0)      # 2 FVII 
    xₒ[3] = (2e-8) * (data_table[i, :V] / 100.0)        # 3 FV
    xₒ[4] = (1.6e-7) * (data_table[i, :X] / 100.0)      # 4 FX
    xₒ[5] = (7e-10) * (data_table[i, :VIII] / 100.0)    # 5 FVIII
    xₒ[6] = (9e-8) * (data_table[i, :IX] / 100.0)       # 6 FIX
    xₒ[7] = (1e-8) * (data_table[i, :XI] / 100.0)       # 7 FXI
    xₒ[8] = (1e-8) * (data_table[i, :XII] / 100.0)      # 8 FXII 
    xₒ[9] = (1e-13)  # 9 FIIa
    xₒ = SF * xₒ # convert to nmol

    # update α -
    α = dd["α"]
    α[1] = 0.061
    α[9] = 0.70

    # setup -
    G = dd["G"]
    idx = indexin(dd, "FVIIa")
    G[idx, 4] = 0.1

    # what is the index of TRAUMA?
    idx = indexin(dd, "AT")
    G[idx, 9] = 0.045

    # what is the index of TFPI?
    idx = indexin(dd, "TFPI")
    G[idx, 1] = -0.65

    # Phase 3: solve the model -
    # setup the solver -
    tspan = (0.0, 20.0)
    prob = ODEProblem(balances, xₒ, tspan, dd; saveat = 0.01)
    soln = solve(prob)

    T = soln.t
    X = hcat(soln.u...)

    FIIa_archive[i] = X[9, :]
    T_archive[i] = T
end

# put simulation archives -
X = hcat(FIIa_archive...)
T = hcat(T_archive...)

# compute the stylized fact -
lagtime_array = τ_lag(x -> x > 2.0, T, X)
peak_FIIa = max_FIIa(X)
pta = peak_time(T, X)