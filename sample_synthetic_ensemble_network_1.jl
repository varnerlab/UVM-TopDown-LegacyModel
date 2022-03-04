include("Include.jl")

# extra:
using Flux
using Flux: @epochs
using BSON: @load

# load training set -
full_training_data_frame = load_tga_training_data()

# filter -
has_TM_flag = 0
experimental_data_table = filter([:visitid, :TM] => (x, y) -> ((x == 2 || x == 3) && y == has_TM_flag), full_training_data_frame)

# what is the size of the system?
(P, D) = size(experimental_data_table)

# mean correction -
b = zeros(5)
b[1] = 1.24
b[2] = 46.91
b[3] = 0.24
b[4] = 29.56
b[5] = 415.97

# how many synthetic models do we have?
ℳ = 24

# initialize some space -
outdim = 5
indim = 12
validation_output_data_array = Array{Float32,2}(undef, P, outdim)
validation_input_data_array = Array{Float32,2}(undef, P, indim)
simulation_output_array = Array{Float32,2}(undef, P, outdim)
tmp_array = Array{Vector{Float32},1}()

# main training loop -
for i ∈ 1:P

    # we used all data *except* i to train the model -
    validation_input_data = convert.(Float32, Vector(experimental_data_table[i, 3:14]))
    validation_output_data = convert.(Float32, Vector(experimental_data_table[i, 15:19]))

    # package the data -
    for k ∈ 1:outdim
        validation_output_data_array[i, k] = validation_output_data[k]
    end

    for k ∈ 1:indim
        validation_input_data_array[i, k] = validation_input_data[k]
    end
end

# load a specific model -
output_dict = Dict{Int,Matrix{Float32}}()
mv = 1:ℳ
for m ∈ mv
    model_name = "deep_coag_model-L$(m)O-TF-TM-$(has_TM_flag)-V2-V3.bson"
    model_file_path = joinpath(_PATH_TO_MODELS, "network-1-epoch-12k", model_name)
    @load model_file_path deep_coag_model
    tmp = sample(deep_coag_model, validation_input_data_array)
    output_dict[m] = tmp
end

# compute patient specific average -
patient_specific_dict = Dict()
for p ∈ 1:P

    VA = Array{Vector{Float32},1}()
    for m ∈ mv
        local_model = output_dict[m]
        v = local_model[p, :]
        push!(VA, v)
    end

    V = transpose(hcat(VA...))
    patient_specific_dict[p] = V
end

# make some plots -
# NP = 1
# oi = 5
# for i ∈ 1:NP

#     Z = patient_specific_dict[1][rand(1:ℳ, 24), oi]
#     if (i == 1)
#         scatter(Z, validation_output_data_array[:, oi], legend = false, xlims = (1600.0, 2200.0), ylims = (1600.0, 2200.0), ms = 4)
#     else
#         scatter!(Z, validation_output_data_array[:, oi])
#     end

#     xlabel!("Simulated peak time (min)", fontsize = 18)
#     ylabel!("Measured peak time (min)", fontsize = 18)
# end
# current()

oi = 1
Z = patient_specific_dict[1][:, oi]
scatter(Z, validation_output_data_array[:, oi], legend = false, xlims = (1600.0, 2200.0), ylims = (1600.0, 2200.0), ms = 4)
xlabel!("Simulated AUC (nM*min)", fontsize = 18)
ylabel!("Measured AUC (nM*min)", fontsize = 18)
