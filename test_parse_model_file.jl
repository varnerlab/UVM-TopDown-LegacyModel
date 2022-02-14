include("Include.jl")

# path to file -
path_model_file = "Coagulation.net"

# load the file -
model_buffer = read_model_file(path_model_file)

# build the default dictionary -
dd = build_default_model_dictionary(model_buffer)