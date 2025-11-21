# Crosswords
```@contents
Pages = ["crosswords.md"]
Depth = 2:3
```

## Interface 
```@docs
CrosswordWord
CrosswordBlackCell
CrosswordPuzzle
show_crossword
enlarge!
shrink!
can_place_word(cw::CrosswordPuzzle, word::String, row::Int, col::Int, direction::Symbol)
place_word!
remove_word!
place_black_cell!
remove_black_cell!
```
