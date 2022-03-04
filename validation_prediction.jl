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

# initialize some space -
outdim = 5
validation_data_array = Array{Float32,2}(undef, P, outdim)
S = Array{Float32,2}(undef, P, outdim)

# mean correction -
b = zeros(5)

# main training loop -
for i ∈ 1:2

    # we used all data *except* i to train the model -
    validation_input_data = convert.(Float32, Vector(experimental_data_table[i, 3:14]))
    validation_output_data = convert.(Float32, Vector(experimental_data_table[i, 15:19]))

    # load a model -
    model_name = "deep_coag_model-L$(i)O-TF-TM-$(has_TM_flag)-synthetic-V2-V3.bson"
    model_file_path = joinpath(_PATH_TO_MODELS, model_name)
    @load model_file_path deep_coag_model

    # sample -
    simulated_output_data = sample(deep_coag_model, validation_input_data)

    # package the data -
    for j ∈ 1:outdim
        validation_data_array[i, j] = validation_output_data[j]
        S[i, j] = max.(0, simulated_output_data[j])
    end
end