function balances(dx, x, p, t)

    # initialize -
    state_array = Array{Float64,1}()

    # grab data from the p dictionary -
    κ = p["κ"]
    g = p["g"]
    h = p["h"]
    f = p["static_factors"]
    S = p["S"]
    number_of_dynamic_states = length(x)
    number_of_static_states = length(f)

    # build the total factor array -
    # dynamic states -
    for i ∈ 1:number_of_dynamic_states
        push!(state_array, x[i])
    end

    # static states -
    for i ∈ 1:number_of_static_states
        push!(state_array, f[i])
    end

    # compute the power law kinetics -
    r_forward = powerlaw(state_array, κ[:, 1], g)
    r_reverse = powerlaw(state_array, κ[:, 2], h)

    @show (r_forward, r_reverse)

    # populate the dx vector -
    for i ∈ 1:number_of_dynamic_states
        dx[i] = S[i, 1] * r_forward[i] + S[i, 2] * r_reverse[i]
    end
end