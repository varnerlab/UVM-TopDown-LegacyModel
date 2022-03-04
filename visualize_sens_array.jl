using DelimitedFiles
using Statistics

# define my colors -
negative_color = (1/255)*[255,51,51]
positive_color = (1/255)*[51,153,255]

function reduce(path_to_sensitivity_array::String; epsilon::Float64=1e-2)

    
    # load -
    sensitivity_array = readdlm(path_to_sensitivity_array)

    # parameters to kepp -
    index_keep_p = Int64[]

    # the parameters are on the rows - are any values abpove a threshold -
    (NR,NC) = size(sensitivity_array)
    for row_index = 1:NR
        
        # get the row data -
        row_data = sensitivity_array[row_index, :]
        
        # check -
        idx_check = findall(x->x>=epsilon, row_data)
        if (isempty(idx_check) == false)
            push!(index_keep_p, row_index)
        end
    end

    # pull out rows -
    reduced_array = sensitivity_array[index_keep_p, :]

    # last thing - lets put things in groups of 0,1,2,3 (or none,low,medium,high)
    (NR,NC) = size(reduced_array)
    category_array = zeros(NR,NC)
    for row_index = 1:NR
        for col_index = 1:NC
            
            old_value = reduced_array[row_index, col_index]
            order_of_magnitude = floor(Int,log10(old_value))
            oom_eps = floor(Int,log10(epsilon))

            # rules -
            if (order_of_magnitude<-4)                                  # below -4
                category_array[row_index, col_index] = 0
            elseif (order_of_magnitude == -4)                           # O(-3)
                category_array[row_index, col_index] = 1
            elseif (order_of_magnitude == -3)                           # O(-2)
                category_array[row_index, col_index] = 2
            elseif (order_of_magnitude == -2)                           # O(-1)
                category_array[row_index, col_index] = 3
            elseif (order_of_magnitude == -1 )                           # O(0)
                category_array[row_index, col_index] = 4
            elseif (order_of_magnitude == 0)                            # O(1)
                category_array[row_index, col_index] = 5
            elseif (order_of_magnitude == 1)                            # O(2)
                category_array[row_index, col_index] = 6
            elseif (order_of_magnitude == 2)                            # O(3)
                category_array[row_index, col_index] = 7
            else
                category_array[row_index, col_index] = 8
            end
        end
    end

    # return -
    return category_array
end

function visualize(sarray)

    epsilon = 0.2;
    (NR,NC) = size(sarray)

    for i ∈ 1:NC

        for j ∈ 1:NR

            # compute origin point -
            x = [
                (i - 1), (i - 1)*epsilon + 1, (i - 1)*epsilon + 1, (i - 1)*epsilon + 1, (i - 1), (i - 1), (i - 1), (i - 1)
            ];

            y = [
                (j - 1), (j - 1), (j - 1), (j - 1)*epsilon + 1, (j - 1)*epsilon + 1, (j - 1)*epsilon + 1, (j - 1), (j - 1)
            ];
        
            t = Shape(x,y)
            plot!(t, legend=false)
        end
    end
    current()

end

# setup path to sensitvity array -
path_to_sensitivity_array = "./Sens.dat"

# execute -
rsa = reduce(path_to_sensitivity_array; epsilon=1e-6)