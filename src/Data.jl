function load(path_to_file::String)::DataFrame
    return CSV.read(path_to_file, DataFrame)
end

function load_tga_training_data()

    # load the data -
    path_data_file_TF = joinpath(_PATH_TO_DATA, "Training-Thrombin-TF.csv")
    full_data_table_TF = load(path_data_file_TF)
    path_data_file_TF_TM = joinpath(_PATH_TO_DATA, "Training-Thrombin-TF-TM.csv")
    full_data_table_TF_TM = load(path_data_file_TF_TM)

    # return a complete set -
    return vcat(full_data_table_TF, full_data_table_TF_TM)
end

function load_fibrinolysis_training_data()
    # load the data -
    path_data_file_TF = joinpath(_PATH_TO_DATA, "Training-Fibrinolysis-TF.csv")
    full_data_table_TF = load(path_data_file_TF)
    return full_data_table_TF
end