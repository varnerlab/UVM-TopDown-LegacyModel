include("Include.jl")

# load the data -
path_data_file = joinpath(_PATH_TO_DATA, "Thrombin-TF.csv")
experimental_data_table = load(path_data_file)

# get input and output data -
input_data = convert.(Float32,Matrix(experimental_data_table[!,3:13]))
output_data = convert.(Float32, Matrix(experimental_data_table[!,14:18]))
training_data = [(transpose(input_data), transpose(output_data))]

# build a model architecture -
deep_coag_model = Chain(Dense(11, 7, σ), Dense(7, 5));

# setup a loss function -
loss(x, y) = Flux.Losses.mae(deep_coag_model(x), y)

# pointer to params -
ps = Flux.params(deep_coag_model)

# # use old school gradient descent -
opt = Momentum(0.05,0.95)

# # train -
using Flux: @epochs
using BSON: @save
@epochs 5000 Flux.train!(loss, ps, training_data, opt)

# save -
@save "deep_coag_model.bson" deep_coag_model

Z = zeros(30,5)
for i ∈ 1:30
    tmp = deep_coag_model(input_data[i,:])
    for j ∈ 1:5
        Z[i,j] = tmp[j]
    end
end






