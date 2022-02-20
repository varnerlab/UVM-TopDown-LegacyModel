function simulation(model::Dict{String,Any}, trainingdata::DataFrame;
    speciesindex::Int64 = 9)::Tuple{Array{Float64,2},Array{Float64,2}}

    # define contents -
    SF = 1e9 # all concentrations are in nmol/L

    # get size of the training data set -
    (ℛ, 𝒞) = size(trainingdata)

    # setup -
    species_archive = Array{Array{Float64,1},1}(undef, ℛ)
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
        xₒ[1] = (1.4e-6) * (trainingdata[i, :II] / 100.0)     # 1 FII 
        xₒ[2] = (1e-8) * (trainingdata[i, :VII] / 100.0)      # 2 FVII 
        xₒ[3] = (2e-8) * (trainingdata[i, :V] / 100.0)        # 3 FV
        xₒ[4] = (1.6e-7) * (trainingdata[i, :X] / 100.0)      # 4 FX
        xₒ[5] = (7e-10) * (trainingdata[i, :VIII] / 100.0)    # 5 FVIII
        xₒ[6] = (9e-8) * (trainingdata[i, :IX] / 100.0)       # 6 FIX
        xₒ[7] = (1e-8) * (trainingdata[i, :XI] / 100.0)       # 7 FXI
        xₒ[8] = (1e-8) * (trainingdata[i, :XII] / 100.0)      # 8 FXII 
        xₒ[9] = (1e-13)  # 9 FIIa
        xₒ = SF * xₒ # convert to nmol

        # setup the solver -
        tspan = (0.0, 20.0)
        prob = ODEProblem(balances, xₒ, tspan, dd; saveat = 0.01)
        soln = solve(prob)

        # smuch -
        T = soln.t
        X = hcat(soln.u...)

        # capture -
        species_archive[i] = X[speciesindex, :]
        T_archive[i] = T
    end

    # return -
    return (T_archive, species_archive)
end

function objective(model::Dict{String,Any}, trainingdata::DataFrame)

    # run the simulation -
    (T,X) = simulation(model, trainingdata)

    # compute the error vector -
    # think about this ...
    return nothing
end