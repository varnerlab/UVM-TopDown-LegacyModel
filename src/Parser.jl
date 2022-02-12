import Base.+

function +(buffer::Array{String,1}, line::String)
    push!(buffer, line)
end

function parse_species_record(buffer::Array{String,1})::Array{String,1}

    # initialize -
    species_symbol_array = Array{String,1}()

    # main -
    for line ∈ buffer

        # split around the ,
        tmp_array = String.(split(line,","))

        for species ∈ tmp_array
            
            species_symbol_string =  species |> lstrip |> rstrip
            if (in(species_symbol_string, species_symbol_array) == false)
               push!(species_symbol_array,species_symbol_string)
            end
        end
    end

    return species_symbol_array
end

function parse_model_file(model_buffer::Array{String,1})::Dict{String,Any}

    # initialize -
    model_dict = Dict{String,Any}()

    # get the sections of the model file -
    dynamic_section = extract_model_section(model_buffer,"#pragma::dynamic","#dynamic::end")
    static_section = extract_model_section(model_buffer,"#pragma::static","#static::end")
    structure_section = extract_model_section(model_buffer,"#pragma::structure","#structure::end")
    factor_section = extract_model_section(model_buffer,"#pragma::factor","#factor::end")

    # get list of dynamic species -
    list_of_dynamic_species = parse_species_record(dynamic_section)
    number_of_dynamic_states = length(list_of_dynamic_species)

    # get list of static species -
    list_of_static_species = parse_species_record(static_section)
    number_of_static_states = length(list_of_static_species)

    # build the stoichiometric (connectivity) array -
    # ...

    # populate -
    model_dict["number_of_dynamic_states"] = number_of_dynamic_states
    model_dict["number_of_static_states"] = number_of_static_states
    model_dict["list_of_dynamic_species"] = list_of_dynamic_species
    model_dict["list_of_static_species"] = list_of_static_species

    # return -
    return model_dict
end

function read_model_file(path_to_file::String)::Array{String,1}

    # initialize -
    model_file_buffer = String[]
    model_buffer = Array{String,1}()

    # Read in the file -
    open("$(path_to_file)", "r") do file
        for line in eachline(file)
            +(model_file_buffer,line)
        end
    end

    # process -
    for line ∈ model_file_buffer
        
        # skip comments and empty lines -
        if (occursin("//", line) == false && 
            isempty(line) == false)
        
            # grab -
            push!(model_buffer,line)
        end
    end

    # return -
    return model_buffer
end

function extract_model_section(file_buffer_array::Array{String,1},
    start_section_marker::String,end_section_marker::String)::Array{String,1}

    # initialize -
    section_buffer = String[]

    # find the SECTION START AND END -
    section_line_start = 1
    section_line_end = 1
    for (index, line) in enumerate(file_buffer_array)

        if (occursin(start_section_marker, line) == true)
            section_line_start = index
        elseif (occursin(end_section_marker, line) == true || length(line) == index)
            section_line_end = index
        end
    end

    for line_index = (section_line_start+1):(section_line_end-1)
        line_item = file_buffer_array[line_index]
        push!(section_buffer, line_item)
    end

    # return -
    return section_buffer
end