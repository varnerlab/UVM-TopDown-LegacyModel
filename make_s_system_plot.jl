# run the simulation -
include("Simulation.jl")

# make a plot -
plot(T, X, legend = false, lw = 1, c = :black, background_color = "lightgray")
xlabel!("Time (min)", fontsize = 18)
ylabel!("Thrombin FIIa (nmol/L)", fonstize = 18)