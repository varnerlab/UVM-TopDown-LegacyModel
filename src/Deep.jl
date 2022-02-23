function sample(model, input::Array{Float32,2}; 
    outdim::Int = 5)::Array{Float32,2}

    # get the size of the input -
    (R,C) = size(input)
    output_array = Array{Float32,2}(undef, R, outdim)

    for i ∈ 1:R
        output_sample = model(input[i,:])
        for j ∈ 1:outdim
            output_array[i,j] = output_sample[j] 
        end
    end

    return output_array
end