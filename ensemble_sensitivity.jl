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
number_of_samples = 1000
indim = 12
outdim = 5
input_range_array = Array{Float32,2}(undef, indim, 2)
for i ∈ 1:indim
    L = (1 - δ) * minimum(input_data[:, i])
    U = (1 + δ) * maximum(input_data[:, i])
    input_range_array[i, 1] = L
    input_range_array[i, 2] = U
end

# archive -
simulation_dict = Dict()
ℳ = 24

# for now - load a particular model -
m = 2
model_name = "deep_coag_model-L$(m)O-TF-TM-$(has_TM_flag)-V2-V3.bson"
model_file_path = joinpath(_PATH_TO_MODELS, "network-1-epoch-12k", model_name)
@load model_file_path deep_coag_model

# run the model on the unperturbed data -
base_line = sample(deep_coag_model, input_data)

oi = 5
sensitivity_array = Array{Float64,2}(undef, (indim - 1), number_of_samples)
for i ∈ 1:indim-1

    # get the range for this input -
    L = input_range_array[i, 1]
    U = input_range_array[i, 2]

    # initialize space for the simulation data -
    simulation_archive = Array{Matrix{Float32},1}()
    input_archive = Array{Matrix{Float32},1}()

    # how many samples?
    for j ∈ 1:number_of_samples
        
        # compute a new input for channel i
        r = rand(P)
        v = L .+ r .* (U - L)

        # build the input data set -
        perturbed_input_data = copy(input_data)
        for k ∈ 1:P
            perturbed_input_data[k,i] = v[k]
        end

        # run the models on the pertubed input, collect the output -
        perturbed_output_data = sample(deep_coag_model, perturbed_input_data)
        Δ_out = perturbed_output_data .- base_line
        Δ_in = perturbed_input_data .- input_data
        sensitivity_array[i,j] = var(Δ_out[:,oi])/var(Δ_in[:,i])
    end
end