import Base.indexin

function indexin(dd::Dict{String,Any},species_symbol::String)::Union{Nothing,Int}

    # get the total species list -
    if (haskey(dd,"total_species_list") == false)
        return nothing
    end
    total_species_list = dd["total_species_list"]

    # check -
    return findfirst(x->x==species_symbol,total_species_list)
end