# assumption: already ran the sample code -

# what output are we looking at?
output_index = 4
#xlabel_text = "Clot time CT (min)"
#xlabel_text = "MCF (mm)"
#xlabel_text = "α (deg)"
xlabel_text = "AUC (mm*s)"
#xlabel_text = "Area under FIIa curve (nmol-min/L)"

#μ_bias = 1.2
#μ_bias = 38.32

dm = Normal(mean(S[:, output_index]), std(S[:, output_index]))
dd = Normal(mean(validation_data_array[:, output_index]), std(validation_data_array[:, output_index]))
μ_bias = mean(dd) - mean(dm)
#μ_bias = 0.0 # no mean correction

# sample -
number_of_samples = 10000
dms = rand(dm, number_of_samples) .+ μ_bias
dds = rand(dd, number_of_samples)

# plot -
number_of_bins = round(Int64, 0.02 * number_of_samples)
stephist(dms, bins = number_of_bins, label = "Model", lw = 2, normed = true)
stephist!(dds, bins = number_of_bins, label = "Measured", lw = 2, normed = true)

# labels -
xlabel!(xlabel_text, fontsize = 18)
ylabel!("Frequency of occurance (dimensionless)", fontsize = 18)

# dump fig -
fig_file_name = "Fig-distribution-OI-$(output_index)-N2-TPA-0.pdf"
savefig(joinpath(_PATH_TO_FIGS, fig_file_name))

