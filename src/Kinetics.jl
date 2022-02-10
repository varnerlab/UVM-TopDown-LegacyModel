function powerlaw(x, k, order)

    # set negatives ot zero -
    x = max.(0.0, x)

    # compute in log sapce -
    a = log.(k)
    y = log.(x)
    number_of_dynamic_states = length(a)

    tmp = Array{Float64,1}(undef, number_of_dynamic_states)
    for s ∈ 1:number_of_dynamic_states
        tmp[s] = a[s] + dot(order[s, :], y)
    end

    # return -
    return exp.(tmp)
end