include("Include.jl")

# extra:
using Flux
using Flux: @epochs
using BSON: @save

# load the data -
path_data_file_TF = joinpath(_PATH_TO_DATA, "Training-Thrombin-TF.csv")
full_data_table_TF = load(path_data_file_TF)
path_data_file_TF_TM = joinpath(_PATH_TO_DATA, "Training-Thrombin-TF-TM.csv")
full_data_table_TF_TM = load(path_data_file_TF_TM)
full_training_data_frame = vcat(full_data_table_TF, full_data_table_TF_TM)

# filter -
has_TM_flag = 1
experimental_data_table = filter([:visitid, :TM] => (x, y) -> (x == 2 || x == 3), full_training_data_frame)

# get input and output data -
input_data = convert.(Float32, Matrix(experimental_data_table[!, 3:14]))
output_data = convert.(Float32, Matrix(experimental_data_table[!, 15:19]))
training_data = [(transpose(input_data), transpose(output_data))]

# build a model architecture -
deep_coag_model = Chain(Dense(12, 12, σ), Dense(12, 5));

# setup a loss function -
loss(x, y) = Flux.Losses.mae(deep_coag_model(x), y; agg = mean)

# pointer to params -
ps = Flux.params(deep_coag_model)

# # use old school gradient descent -
opt = Momentum(0.25, 0.95)

# # train -
@epochs 10000 Flux.train!(loss, ps, training_data, opt)

# save -
model_file_path = joinpath(_PATH_TO_MODELS, "deep_coag_model.bson")
@save model_file_path deep_coag_model






