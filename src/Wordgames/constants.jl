CONSONANTS = collect("bcdfghjklmnpqrstvwxyz")
VOWELS = collect("aeiouàèìòù")

EN_ALPHABET = collect('a':'z')
IT_ALPHABET = setdiff(EN_ALPHABET,collect("jkxyw"))
# IT_ALPHABET = ['a','b','c','d','e','f','g','h','i','l','m','n','o','p','q','r','s','t','u','v','z']

language_corrections = Dict{String,Vector{Char}}(
    "en" => EN_ALPHABET,
    "it" => IT_ALPHABET
)

ACCENT_RULES = Dict(
    'à' => 'a','á' => 'a','â' => 'a','ä' => 'a',
    'é' => 'e','è' => 'e','ê' => 'e','ë' => 'e',
    'ì' => 'i','í' => 'i','î' => 'i','ï' => 'i',
    'ò' => 'o','ó' => 'o','ô' => 'o','ö' => 'o',
    'ù' => 'u','ú' => 'u','û' => 'u','ü' => 'u'
)
normalize_accents(w::AbstractString) = replace(w::AbstractString, ACCENT_RULES...)