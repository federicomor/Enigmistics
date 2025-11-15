dictionary = readlines("../dictionaries/italian.txt")

# let's filter only feasible and reasonable words, of length between 3 and 21
lengths = length.(dictionary)

words = Dict{Int,Vector{String}}()
for i in 3:21
    words[i] = copy(dictionary[lengths .== i])
end

function fitting_words(pattern::Regex, min_len::Int, max_len::Int)
    results = Dict{Int,Vector{String}}()
    for len in min_len:max_len
        results[len] = filter(w -> occursin(pattern,w), get(words,len,String[]))
    end
    return results
end

fitting_words(r"^a.a$", 3, 5)
fitting_words(r"^a.*a$", 3, 5) 

g = create_grid(6,6)

