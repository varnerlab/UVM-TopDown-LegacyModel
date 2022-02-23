include("Include.jl")

# extra:
using Flux

# load the data -
path_data_file = joinpath(_PATH_TO_DATA, "Thrombin-TF.csv")
experimental_data_table = load(path_data_file)

# get input and output data -
number_training_samples = 0
input_data = convert.(Float32, Matrix(experimental_data_table[!, 3:13]))
output_data = convert.(Float32, Matrix(experimental_data_table[!, 14:18]))
test_output_data = convert.(Float32, Matrix(experimental_data_table[!, 14:18]))[(number_training_samples+1):end,:]

# compute the cov matrix -
Σ = cov(input_data)
μ = mean(input_data,dims=1)
𝒩 = MvNormal(μ[1,:],Σ)

# load a model -
model_file_path = joinpath(_PATH_TO_MODELS, "deep_coag_model.bson")
@load model_file_path deep_coag_model

# generate a set of samples -
number_of_samples = 10000
number_of_outputs = 5
sample_input_array_normal = Matrix(transpose(rand(𝒩, number_of_samples)))
sample_output_array_normal = sample(deep_coag_model, sample_input_array_normal)

# sample w/diff range -
number_of_input_types = 11
δ = 0.10
input_range_array = Array{Float32,2}(undef,number_of_input_types,2)
for i ∈ 1:number_of_input_types
    L = (1-δ)*minimum(input_data[:,i])
    U = (1+δ)*maximum(input_data[:,i])
    input_range_array[i,1] = L
    input_range_array[i,2] = U
end

# let's draw a sample from this range -
sample_input_array_random = Array{Float32,2}(undef,number_of_samples,number_of_input_types)
for i ∈ 1:number_of_samples
    for j ∈ 1:number_of_input_types
        L = input_range_array[j,1]
        U = input_range_array[j,2]
        r = rand()
        v = L + r*(U-L)
        sample_input_array_random[i,j] = v
    end
end

# sample the random -
sample_output_array_random = sample(deep_coag_model, sample_input_array_random)
μ_normal = mean(sample_output_array_normal,dims=1)
σ_normal = std(sample_output_array_normal,dims=1)
μ_random = mean(sample_output_array_random,dims=1)
σ_random = std(sample_output_array_random,dims=1)
μ_data = mean(test_output_data,dims=1)
σ_data = std(test_output_data,dims=1)

# create a pretty table -
table_data_array = Array{Any,2}(undef, number_of_outputs, 7)
label_data_array = ["τ_lag (min)", "peak (nM)", "τ_peak (min)", "max rate (nM/min)", "AUC (nM*min)"]
header_data = (["quantity","μ_normal","σ_normal","μ_random","σ_random", "μ_data","σ_data"])

for i ∈ 1:number_of_outputs
    table_data_array[i,1] = label_data_array[i]
    table_data_array[i,2] = μ_normal[i]
    table_data_array[i,3] = σ_normal[i]
    table_data_array[i,4] = μ_random[i]
    table_data_array[i,5] = σ_random[i]
    table_data_array[i,6] = μ_data[i]
    table_data_array[i,7] = σ_data[i]
end


pretty_table(table_data_array; header=header_data)


