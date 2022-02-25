include("Include.jl")

# extra:
using Flux

# load the data -
path_data_file_TF = joinpath(_PATH_TO_DATA, "Training-Thrombin-TF.csv")
full_data_table_TF = load(path_data_file_TF)
path_data_file_TF_TM = joinpath(_PATH_TO_DATA, "Training-Thrombin-TF-TM.csv")
full_data_table_TF_TM = load(path_data_file_TF_TM)
full_training_data_frame = vcat(full_data_table_TF, full_data_table_TF_TM)

# filter -
has_TM_flag = 0
experimental_data_table = filter([:visitid, :TM] => (x, y) -> (x == 2 || x == 3) && y == has_TM_flag, full_training_data_frame)

# get input and output data -
input_data = convert.(Float32, Matrix(experimental_data_table[!, 3:14]))
output_data = convert.(Float32, Matrix(experimental_data_table[!, 15:19]))

# compute the cov matrix -
Σ = cov(input_data[:, 1:end-1])
μ = mean(input_data[:, 1:end-1], dims = 1)
𝒩 = MvNormal(μ[1, :], Σ)

# load a model -
model_file_path = joinpath(_PATH_TO_MODELS, "deep_coag_model.bson")
@load model_file_path deep_coag_model

# generate a set of samples -
number_of_samples = 25000
number_of_outputs = 5
sample_input_array_normal = Matrix(transpose(rand(𝒩, number_of_samples)))
sample_input_array_normal = convert.(Float32, [sample_input_array_normal has_TM_flag * ones(number_of_samples)])
sample_output_array_normal = sample(deep_coag_model, sample_input_array_normal)

# sample w/diff range -
number_of_input_types = 12
δ = 0.9
input_range_array = Array{Float32,2}(undef, number_of_input_types, 2)
for i ∈ 1:number_of_input_types
    L = (1 - δ) * minimum(input_data[:, i])
    U = (1 + δ) * maximum(input_data[:, i])
    input_range_array[i, 1] = L
    input_range_array[i, 2] = U
end

# let's draw a sample from this range -
sample_input_array_random = Array{Float32,2}(undef, number_of_samples, number_of_input_types)
for i ∈ 1:number_of_samples
    for j ∈ 1:number_of_input_types
        L = input_range_array[j, 1]
        U = input_range_array[j, 2]
        r = rand()
        v = L + r * (U - L)
        sample_input_array_random[i, j] = v

        if (j == number_of_input_types)
            sample_input_array_random[i, j] = has_TM_flag
        end
    end
end

# sample the random -
sample_output_array_random = sample(deep_coag_model, sample_input_array_random)
μ_normal = mean(sample_output_array_normal, dims = 1)
σ_normal = std(sample_output_array_normal, dims = 1)
μ_random = mean(sample_output_array_random, dims = 1)
σ_random = std(sample_output_array_random, dims = 1)
μ_data = mean(output_data, dims = 1)
σ_data = std(output_data, dims = 1)

# create a pretty table -
table_data_array = Array{Any,2}(undef, number_of_outputs, 7)
label_data_array = ["τ_lag (min)", "peak (nM)", "τ_peak (min)", "max rate (nM/min)", "AUC (nM*min)"]
header_data = (["quantity", "μ_normal", "σ_normal", "μ_random", "σ_random", "μ_data", "σ_data"])

for i ∈ 1:number_of_outputs
    table_data_array[i, 1] = label_data_array[i]
    table_data_array[i, 2] = μ_normal[i]
    table_data_array[i, 3] = σ_normal[i]
    table_data_array[i, 4] = μ_random[i]
    table_data_array[i, 5] = σ_random[i]
    table_data_array[i, 6] = μ_data[i]
    table_data_array[i, 7] = σ_data[i]
end


pretty_table(table_data_array; header = header_data)


