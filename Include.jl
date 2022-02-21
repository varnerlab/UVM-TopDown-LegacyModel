# what is the path?
_BASE_PATH = pwd()
_PATH_TO_SRC = joinpath(_BASE_PATH, "src")
_PATH_TO_DATA = joinpath(_BASE_PATH, "data")

# load external packages -
using DifferentialEquations
using CSV
using DataFrames
using LinearAlgebra
using Plots
using DataFrames
using StatsPlots
using StatsBase
using Statistics
using NumericalIntegration
using Flux
using BSON: @load
using BSON: @save

# load my codes -
include(joinpath(_PATH_TO_SRC, "Balances.jl"))
include(joinpath(_PATH_TO_SRC, "Kinetics.jl"))
include(joinpath(_PATH_TO_SRC, "Compute.jl"))
include(joinpath(_PATH_TO_SRC, "Factory.jl"))
include(joinpath(_PATH_TO_SRC, "Utilities.jl"))
include(joinpath(_PATH_TO_SRC, "Data.jl"))
include(joinpath(_PATH_TO_SRC, "Model.jl"))
include(joinpath(_PATH_TO_SRC, "Deep.jl"))
