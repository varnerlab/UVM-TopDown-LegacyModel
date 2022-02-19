function τ_lag(rule::Function, T::Array{Float64,1}, X::Array{Float64,1})::Float64

    # filter -
    idx = findfirst(rule, X)

    # return -
    return T[idx]
end

function τ_lag(rule::Function, T::Array{Float64,2}, X::Array{Float64,2})::Array{Float64,1}

    # initialize -
    time_lag_array = Array{Float64,1}()

    # size -
    (_, C) = size(X)
    for i ∈ 1:C

        # compute -
        τ = τ_lag(rule, T[:, i], X[:, i])

        # filter -
        push!(time_lag_array, τ)
    end

    # return -
    return time_lag_array
end

function max_FIIa(X::Array{Float64,2})::Array{Float64,1}

    # initialize -
    peak_array = Array{Float64,1}()

    # size -
    (R, C) = size(X)
    for i ∈ 1:C

        # get sim run -
        sim_col = X[:, i]

        # what is the max value?
        max_value = maximum(sim_col)

        # capture -
        push!(peak_array, max_value)
    end

    # return -
    return peak_array
end

function peak_time(T::Array{Float64,1}, X::Array{Float64,1})::Float64

    # find the index of the max value -
    idx = argmax(X)
    return T[idx]
end

function peak_time(T::Array{Float64,2}, X::Array{Float64,2})::Array{Float64,1}

    # initialize -
    peak_time_array = Array{Float64,1}()
    (R, C) = size(X)
    for i ∈ 1:C
        value = peak_time(T[:, i], X[:, i])
        push!(peak_time_array, value)
    end

    # return -
    return peak_time_array
end