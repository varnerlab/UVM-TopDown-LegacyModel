include("Include.jl")

# load the data -
path_data_file_TF = joinpath(_PATH_TO_DATA, "Training-Thrombin-TF.csv")
full_data_table_TF = load(path_data_file_TF)
path_data_file_TF_TM = joinpath(_PATH_TO_DATA, "Training-Thrombin-TF-TM.csv")
full_data_table_TF_TM = load(path_data_file_TF_TM)
full_training_data_frame = vcat(full_data_table_TF, full_data_table_TF_TM)

# filter -
experimental_data_table = filter(:visitid => x -> x == 1, full_training_data_frame)