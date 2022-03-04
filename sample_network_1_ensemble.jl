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

# setup sampling -
δ = 0.9
number_of_samples = 100
number_of_input_types = 12
input_range_array = Array{Float32,2}(undef, number_of_input_types, 2)
for i ∈ 1:number_of_input_types
    L = (1 - δ) * minimum(input_data[:, i])
    U = (1 + δ) * maximum(input_data[:, i])
    input_range_array[i, 1] = L
    input_range_array[i, 2] = U
end

# archive -
ensemble_archive = Array{Matrix{Float32},1}()

# build an input array -
sample_input_array_random = Array{Float32,2}(undef, number_of_samples, number_of_input_types)
for i ∈ 1:number_of_samples
    for j ∈ 1:number_of_input_types
        L = input_range_array[j, 1]
        U = input_range_array[j, 2]
        r = rand()
        v = L + r * (U - L)
        sample_input_array_random[i, j] = v

        if (j == number_of_input_types)
            sample_input_array_random[i, j] = has_TM_flag
        end
    end
end

# main training loop -
for i ∈ 1:P

    # load a model -
    model_name = "deep_coag_model-L$(i)O-TF-TM-$(has_TM_flag)-V2-V3.bson"
    model_file_path = joinpath(_PATH_TO_MODELS, "network-1-epoch-12k", model_name)
    @load model_file_path deep_coag_model


    # sample -
    simulated_output_data = sample(deep_coag_model, sample_input_array_random)
    push!(ensemble_archive, simulated_output_data)
end


S = vcat(ensemble_archive...)

# save -
# path_to_input = joinpath(_PATH_TO_DATA, "synthetic_input_array.dat")
# CSV.write(path_to_input, Tables.table(sample_input_array_random))

# path_to_output = joinpath(_PATH_TO_DATA, "synthetic_output_array.dat")
# CSV.write(path_to_output, Tables.table(S))



