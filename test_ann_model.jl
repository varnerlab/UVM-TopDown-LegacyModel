include("Include.jl")

# extra:
using Flux
using Flux: @epochs
using BSON: @save

# load the data -
path_data_file = joinpath(_PATH_TO_DATA, "Thrombin-TF.csv")
experimental_data_table = load(path_data_file)

# get input and output data -
number_training_samples = 27
input_data = convert.(Float32, Matrix(experimental_data_table[!, 3:13]))
output_data = convert.(Float32, Matrix(experimental_data_table[!, 14:18]))
training_data = [(transpose(input_data[1:number_training_samples, :]), transpose(output_data[1:number_training_samples, :]))]

# build a model architecture -
deep_coag_model = Chain(Dense(11, 11, σ), Dense(11, 5));

# setup a loss function -
loss(x, y) = Flux.Losses.mae(deep_coag_model(x), y; agg = mean)

# pointer to params -
ps = Flux.params(deep_coag_model)

# # use old school gradient descent -
opt = Momentum(0.05, 0.95)

# # train -
@epochs 10000 Flux.train!(loss, ps, training_data, opt)

# save -
model_file_path = joinpath(_PATH_TO_MODELS, "deep_coag_model.bson")
@save model_file_path deep_coag_model






