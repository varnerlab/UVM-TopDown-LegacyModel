include("Include.jl")

# extra:
using Flux
using Flux: @epochs
using BSON: @load

# load training set -
full_training_data_frame = load_tga_training_data()

# filter -
has_TM_flag = 0
experimental_data_table = filter([:visitid, :TM] => (x, y) -> ((x == 2 || x == 3) && y == has_TM_flag), full_training_data_frame)
input_data = convert.(Float32, Matrix(experimental_data_table[!, 3:14]))
validation_data_array = convert.(Float32, Matrix(experimental_data_table[!, 15:19]))

# what is the size of the system?
(P, D) = size(experimental_data_table)

# How are we going to do this?
δ = 0.90
number_of_samples = 1
indim = 12
outdim = 5
input_range_array = Array{Float32,2}(undef, indim, 2)
for i ∈ 1:indim
    L = (1 - δ) * minimum(input_data[:, i])
    U = (1 + δ) * maximum(input_data[:, i])
    input_range_array[i, 1] = L
    input_range_array[i, 2] = U
end

m = 2
model_name = "deep_coag_model-L$(m)O-TF-TM-$(has_TM_flag)-V2-V3.bson"
model_file_path = joinpath(_PATH_TO_MODELS, "network-1-epoch-12k", model_name)
@load model_file_path deep_coag_model

# baseline -
baseline = sample(deep_coag_model,input_data[1,:])

# create some storage -
tmp_dict = Dict()
sensitivity_dict = Dict()

for i ∈ 1:number_of_samples

    p_input_array = Array{Vector{Float32},1}()
    p_output_array = Array{Vector{Float32},1}()

    for j ∈ 1:indim

        # get the range for this input -
        L = input_range_array[j, 1]
        U = input_range_array[j, 2]

        # create a p + Δp -
        #r = rand()
        #v = L .+ r .* (U - L)
        
        # create a pertubed input data set -
        perturbed_input = copy(input_data[1,:])
        perturbed_input[j] = 1000.0     
    
        # run the model -
        model_out = sample(deep_coag_model, perturbed_input)

        # grab -
        push!(p_input_array, perturbed_input)
        push!(p_output_array, model_out)
    end

    tmp_dict[i] = p_input_array => p_output_array
end



# get the data for a trial -
for t ∈ 1:number_of_samples

    p = tmp_dict[t].first
    x = tmp_dict[t].second

    # initialize -
    SA = Array{Float32,2}(undef, outdim, (indim-1))

    for i ∈ 1:outdim

        for j ∈ 1:(indim-1)
            
            # compute Δx -
            Δx = (x[j] .- baseline)[i]
    
            # compute Δp -
            Δp = (p[j] .- input_data[1,:])[j]
            
            # sensitivity -
            SF = 1.0
            SA[i,j] = SF*(Δx)/(Δp)
        end
    end

    sensitivity_dict[t] = SA
end

# process individual sensitivity arrays -
master_sens_array = zeros(outdim, indim-1)
for t ∈ 1:number_of_samples

    ASA = abs.(sensitivity_dict[t])

    for i ∈ 1:outdim
        for j ∈ 1:(indim - 1)
            old_value = master_sens_array[i,j]
            master_sens_array[i,j] = old_value + ASA[i,j]
        end
    end
end


