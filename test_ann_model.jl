include("Include.jl")

# load the data -
path_data_file = joinpath(_PATH_TO_DATA, "Thrombin-TF.csv")
experimental_data_table = load(path_data_file)

# get input and output data -
input_data = convert.(Float32,Matrix(experimental_data_table[!,3:13]))
output_data = convert.(Float32, Matrix(experimental_data_table[!,14:18]))
training_data = zip(input_data, output_data)

# build a model architecture -
deep_coag_model = Chain(Dense(11, 7, σ), Dense(7, 5));

# setup a loss function -
loss(x, y) = Flux.Losses.mae(deep_coag_model(x), y)

# pointer to params -
ps = Flux.params(deep_coag_model)

# use old school gradient descent -
opt = Descent(0.1)

# train -
using Flux: @epochs
@epochs 5000 Flux.train!(loss, ps, [(transpose(input_data), transpose(output_data))], opt)







