# what is the path?
_BASE_PATH = pwd()
_PATH_TO_SRC = joinpath(_BASE_PATH, "src")

# load external packages -
using DifferentialEquations
using CSV
using DataFrames
using LinearAlgebra
using Plots

# load my codes -
include(joinpath(_PATH_TO_SRC, "Balances.jl"))
include(joinpath(_PATH_TO_SRC, "Kinetics.jl"))
include(joinpath(_PATH_TO_SRC, "Model.jl"))
include(joinpath(_PATH_TO_SRC, "Factory.jl"))
