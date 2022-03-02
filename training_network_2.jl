include("Include.jl")

# extra:
using Flux
using Flux: @epochs
using BSON: @save

# load training set -
full_training_data_frame = load_fibrinolysis_training_data()

# filter out the data -
experimental_data_table = filter(:visitid => x -> (x == 2 || x == 3 || x == 1), full_training_data_frame)

# initialize storage for the training data -
training_data = Vector{Tuple{Vector{Float32},Vector{Float32}}}()

# build a model architecture -
has_TM_flag = 0
number_of_inputs = 14
number_of_outputs = 4
dimension_hidden_layer = number_of_inputs + 2
deep_fibrinolysis_model = Chain(Dense(number_of_inputs, dimension_hidden_layer, σ), Dense(dimension_hidden_layer, number_of_outputs));

# setup a loss function -
loss(x, y) = Flux.Losses.mae(deep_fibrinolysis_model(x), y; agg = mean)

# pointer to params -
ps = Flux.params(deep_fibrinolysis_model)

# # use old school gradient descent -
opt = Momentum(0.1, 0.95)

# main training loop -
(P, D) = size(experimental_data_table)

for i ∈ 1:P

    for j = 1:P

        # leave one out -
        if (i != j)

            # get input and output data -
            input_data = convert.(Float32, Vector(experimental_data_table[j, 3:16]))
            output_data = convert.(Float32, Vector(experimental_data_table[j, 17:20]))
            data_example = (input_data, output_data)

            # capture -
            push!(training_data, data_example)
        end
    end

    # ok, so have the training data for this case -
    # train -
    @epochs 12000 Flux.train!(loss, ps, training_data, opt)

    # save -
    model_name = "deep_fibrinolysis_model-L$(i)O-TF-TM-$(has_TM_flag)-ALL.bson"
    model_file_path = joinpath(_PATH_TO_MODELS, model_name)
    @save model_file_path deep_fibrinolysis_model

    # need to empty the training data -
    empty!(training_data)
end