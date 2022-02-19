function load(path_to_file::String)::DataFrame
    return CSV.read(path_to_file, DataFrame)
end