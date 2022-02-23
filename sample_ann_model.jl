include("Include.jl")

# extra:
using Flux

# load the data -
path_data_file = joinpath(_PATH_TO_DATA, "Thrombin-TF.csv")
experimental_data_table = load(path_data_file)

# get input and output data -
input_data = convert.(Float32, Matrix(experimental_data_table[!, 3:13]))
output_data = convert.(Float32, Matrix(experimental_data_table[!, 14:18]))

# compute the cov matrix -
Σ = cov(input_data)
μ = mean(input_data,dims=1)
𝒩 = MvNormal(μ[1,:],Σ)

# load a model -
model_file_path = joinpath(_PATH_TO_MODELS, "deep_coag_model.bson")
@load model_file_path deep_coag_model

# generate a set of samples -
number_of_samples = 1000
number_of_outputs = 5
sample_input_array_normal = Matrix(transpose(rand(𝒩, number_of_samples)))
sample_output_array_normal = sample(deep_coag_model, sample_input_array_normal)

# sample w/diff range -
number_of_input_types = 11
δ = 0.90
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

sample_output_array_random = sample(deep_coag_model, sample_input_array_random)