# get list of files -
LOF = readdir(_PATH_TO_FIGS)

for filename ∈ LOF

    path_to_fig = joinpath(_PATH_TO_FIGS, filename)
    command = `pdfcrop $(path_to_fig) $(path_to_fig)`
    run(command)
end