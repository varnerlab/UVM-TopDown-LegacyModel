function parameters()::Dict{String,Any}

    # initialize -
    pdict = Dict{String,Any}()

    # setup rate constants -
    κ = [
        0.1 1.0
        1.0 2.0
    ]

    # what are the static factors?
    static_factors = [
        1.0     # TF
        1.0     # TFPI
        10.0     # AT 
    ]

    # what is my g array?
    g = [

        # FII FIIa TF TFPI AT
        0.0 0.0 0.0 0.0 0.0  # 1 FII production
        1.0 0.01 1.0 -1.0 0.0 # 2 FIIa production
    ]

    h = [
        # FII FIIa TF TFPI AT
        1.0 0.01 1.0 -1.0 0.0    # 1 FII consumption
        0.0 1.0 0.0 0.0 2.0    # 2 FIIa consumption
    ]

    S = [
        0.0 -1.0
        1.0 -1.0
    ]

    # add stuff to the pdict -
    pdict["κ"] = κ
    pdict["static_factors"] = static_factors
    pdict["g"] = g
    pdict["h"] = h
    pdict["S"] = S

    # return -
    return pdict
end