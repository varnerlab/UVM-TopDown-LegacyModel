include("Include.jl")

# extra:
using Flux
using Flux: @epochs
using BSON: @load

# load training set -
full_training_data_frame = load_training_data()

# filter -
has_TM_flag = 0
experimental_data_table = filter([:visitid, :TM] => (x, y) -> ((x == 2 || x == 3) && y == has_TM_flag), full_training_data_frame)

# what is the size of the system?
(P, D) = size(experimental_data_table)

# How are we going to do this?
# ...

