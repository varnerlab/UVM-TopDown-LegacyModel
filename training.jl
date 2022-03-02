include("Include.jl")

# extra:
using Flux
using Flux: @epochs
using BSON: @save

# load training set -
full_training_data_frame = load_training_data()

# filter -
has_TM_flag = 0
experimental_data_table = filter([:visitid, :TM] => (x, y) -> ((x == 2 || x == 3) && y == has_TM_flag), full_training_data_frame)

# initialize storage for the training data -
training_data = Vector{Tuple{Vector{Float32}, Vector{Float32}}}()

# build a model architecture -
deep_coag_model = Chain(Dense(12, 16, σ), Dense(16, 5));

# setup a loss function -
loss(x, y) = Flux.Losses.mae(deep_coag_model(x), y; agg = mean)

# pointer to params -
ps = Flux.params(deep_coag_model)

# # use old school gradient descent -
opt = Momentum(0.1, 0.95)

# main training loop -
(P,D) = size(experimental_data_table)
for i ∈ 1:P

    for j = 1:P
        
        # leave one out -
        if (i != j)

            # get input and output data -
            input_data = convert.(Float32, Vector(experimental_data_table[j, 3:14]))
            output_data = convert.(Float32, Vector(experimental_data_table[j, 15:19]))
            data_example = (input_data, output_data)

            # capture -
            push!(training_data, data_example)
        end
    end

    # ok, so have the training data for this case -
    # train -
    @epochs 12000 Flux.train!(loss, ps, training_data, opt)

    # save -
    model_name = "deep_coag_model-L$(i)O-TF-TM-$(has_TM_flag)-V2-V3.bson"
    model_file_path = joinpath(_PATH_TO_MODELS, model_name)
    @save model_file_path deep_coag_model
    
    # need to empty the training data -
    empty!(training_data)
end