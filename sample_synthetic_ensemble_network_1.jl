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

# what is the size of the system?
(P, D) = size(experimental_data_table)

# mean correction -
b = zeros(5)
b[1] = 1.24
b[2] = 46.91
b[3] = 0.24
b[4] = 29.56
b[5] = 415.97

# how many synthetic models do we have?
ℳ = 85

# initialize some space -
outdim = 5
indim = 12
validation_output_data_array = Array{Float32,2}(undef, P, outdim)
validation_input_data_array = Array{Float32,2}(undef, P, indim)
simulation_output_array = Array{Float32,2}(undef, P, outdim)
tmp_array = Array{Vector{Float32},1}()

# main training loop -
for i ∈ 1:P

    # we used all data *except* i to train the model -
    validation_input_data = convert.(Float32, Vector(experimental_data_table[i, 3:14]))
    validation_output_data = convert.(Float32, Vector(experimental_data_table[i, 15:19]))

    # package the data -
    for k ∈ 1:outdim
        validation_output_data_array[i, k] = validation_output_data[k]
    end

    for k ∈ 1:indim
        validation_input_data_array[i, k] = validation_input_data[k]
    end
end

# load a specific model -
output_dict = Dict{Int,Matrix{Float32}}()
for m ∈ 1:ℳ
    model_name = "deep_coag_model-L$(m)O-TF-TM-$(has_TM_flag)-synthetic-V2-V3.bson"
    model_file_path = joinpath(_PATH_TO_MODELS, model_name)
    @load model_file_path deep_coag_model
    tmp = sample(deep_coag_model, validation_input_data_array)
    output_dict[m] = tmp
end

# compute patient specific average -
patient_specific_dict = Dict()
for p ∈ 1:P

    VA = Array{Vector{Float32},1}()
    for m ∈ 1:ℳ
        local_model = output_dict[m]
        v = local_model[p, :]
        push!(VA, v)
    end

    V = transpose(hcat(VA...))
    patient_specific_dict[p] = V
end

