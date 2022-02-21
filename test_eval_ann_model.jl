include("Include.jl")

# load the data -
path_data_file = joinpath(_PATH_TO_DATA, "Thrombin-TF.csv")
experimental_data_table = load(path_data_file)

# get input and output data -
input_data = convert.(Float32, Matrix(experimental_data_table[!, 3:13]))
output_data = convert.(Float32, Matrix(experimental_data_table[!, 14:18]))

# load the model -
@load "deep_coag_model.bson" deep_coag_model
