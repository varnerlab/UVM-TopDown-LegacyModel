include("Include.jl")

# extra:
using Flux
using Flux: @epochs
using BSON: @save

# flags -
has_TM_flag = 0

# load training set -
full_training_data_frame = load_fibrinolysis_training_data()

# filter out the data -
experimental_data_table = filter(:visitid => x -> (x == 2 || x == 3 || x == 1), full_training_data_frame)
input_data = convert.(Float32, Matrix(experimental_data_table[!, 3:16]))
validation_data_array = convert.(Float32, Matrix(experimental_data_table[!, 17:20]))

# what is the size of the system?
(P, D) = size(experimental_data_table)

# setup sampling -
δ = 0.9
number_of_samples = 100
number_of_input_types = 14
input_range_array = Array{Float32,2}(undef, number_of_input_types, 2)
for i ∈ 1:number_of_input_types
    L = (1 - δ) * minimum(input_data[:, i])
    U = (1 + δ) * maximum(input_data[:, i])
    input_range_array[i, 1] = L
    input_range_array[i, 2] = U
end

# archive -
ensemble_archive = Array{Vector{Float32},1}()

# build an input array -
sample_input_array_random = Array{Float32,2}(undef, number_of_samples, number_of_input_types)
for i ∈ 1:number_of_samples
    for j ∈ 1:number_of_input_types
        L = input_range_array[j, 1]
        U = input_range_array[j, 2]
        r = rand()
        v = L + r * (U - L)
        sample_input_array_random[i, j] = v
    end
end

# main training loop -
for i ∈ 1:39

    # load a model -
    model_name = "deep_fibrinolysis_model-L$(i)O-TF-TM-$(has_TM_flag)-ALL.bson"
    model_file_path = joinpath(_PATH_TO_MODELS, "network-2-all-data-epoch-12k", model_name)
    @load model_file_path deep_fibrinolysis_model

    # sample -
    simulated_output_data = deep_fibrinolysis_model(input_data[i,:])
    push!(ensemble_archive, simulated_output_data)
end

S = transpose(hcat(ensemble_archive...))