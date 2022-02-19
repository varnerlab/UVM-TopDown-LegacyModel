include("Include.jl")

# load data file -
path_data_file = joinpath(_PATH_TO_DATA, "Thrombin-TF.csv")

# load the experimental data -
df = load(path_data_file)