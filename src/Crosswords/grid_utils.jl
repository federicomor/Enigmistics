using Random

BLACK_CELL = '■'
EMPTY_CELL = ' '

ALPHABET = collect('A':'Z')
EXT_ALPHABET = copy(ALPHABET)
push!(EXT_ALPHABET,BLACK_CELL)
push!(EXT_ALPHABET,EMPTY_CELL)

HORIZONTAL = :horizontal
VERTICAL = :vertical

ROW_ABOVE = :row_above
ROW_BELOW = :row_below
COL_LEFT = :col_left
COL_RIGHT = :col_right

"""
   create_grid(rows::Int, cols::Int; type="blank", probability=1.0, from=ALPHABET)

Create a grid of given number of `rows` and `cols`. 

The argument `type` can either be "blank" (all empty cells) or "random" (grid randomly filled with density proportional to the given probability), while `from` indicates the set of characters to use when filling the grid randomly (default is ALPHABET, which contains only letters, otherwise there is EXT_ALPHABET which also contains black and empty cells).

# Examples
```julia-repl   
julia> create_grid(4,4,type="blank")
4×4 Matrix{Char}:
 ' '  ' '  ' '  ' '
 ' '  ' '  ' '  ' '
 ' '  ' '  ' '  ' '
 ' '  ' '  ' '  ' '

julia> create_grid(4,4,type="random")
4×4 Matrix{Char}:
 'G'  'V'  'A'  'Y'
 'X'  'U'  'N'  'B'
 'X'  'Z'  'P'  'B'
 'J'  'E'  'Z'  'U'

julia> create_grid(4,4,type="random",probability=0.7, from=EXT_ALPHABET)
4×4 Matrix{Char}:
 ' '  'H'  'D'  ' '
 ' '  ' '  'H'  ' '
 'U'  'E'  ' '  'P'
 '■'  'B'  'C'  'A'
```
"""
function create_grid(rows::Int, cols::Int; type="blank", probability=1.0, from=ALPHABET)
    grid = fill(' ', (rows, cols))
    if type=="blank" 
        return grid
    elseif type=="random"
        for i in 1:rows, j in 1:cols
            if rand() <= probability 
                grid[i, j] = rand(from)
            end
        end
        return grid
    else 
        error("Unknown grid type: $type")
    end
end

# create_grid(4,4,type="blank")
# create_grid(4,4,type="random")
# create_grid(4,4,type="random",probability=0.7, from=EXT_ALPHABET)
"""
    show_grid(grid::Matrix{Char}; empty_placeholder = "⋅", style="single")

Show the grid in the console, with optional placeholder for empty cells and style of borders (either "single" or "double").    

# Examples
```julia-repl
julia> g = create_grid(9,11,type="random", from=EXT_ALPHABET);

julia> show_grid(g,style="single")
     1  2  3  4  5  6  7  8  9 10 11 
   ┌─────────────────────────────────┐
1  │ Z  P  E  X  T  U  O  B  E  N  V │
2  │ V  A  R  R  D  N  Q  F  Z  I  T │
3  │ Y  U  R  ⋅  F  ⋅  S  Z  K  C  D │
4  │ D  N  Y  U  L  L  ■  S  G  Q  C │
5  │ D  D  W  V  Q  S  L  M  O  P  J │
6  │ ■  K  O  G  I  ■  D  Z  Q  A  ⋅ │
7  │ U  U  C  X  G  S  Y  C  F  W  E │
8  │ Q  D  V  W  G  O  O  B  Y  P  S │
9  │ L  H  Y  B  Q  Q  S  B  M  ■  S │
   └─────────────────────────────────┘

julia> show_grid(g,style="double", empty_placeholder = "_")
     1  2  3  4  5  6  7  8  9 10 11 
   ╔═════════════════════════════════╗
1  ║ Z  P  E  X  T  U  O  B  E  N  V ║
2  ║ V  A  R  R  D  N  Q  F  Z  I  T ║
3  ║ Y  U  R  _  F  _  S  Z  K  C  D ║
4  ║ D  N  Y  U  L  L  ■  S  G  Q  C ║
5  ║ D  D  W  V  Q  S  L  M  O  P  J ║
6  ║ ■  K  O  G  I  ■  D  Z  Q  A  _ ║
7  ║ U  U  C  X  G  S  Y  C  F  W  E ║
8  ║ Q  D  V  W  G  O  O  B  Y  P  S ║
9  ║ L  H  Y  B  Q  Q  S  B  M  ■  S ║
   ╚═════════════════════════════════╝
```
"""
function show_grid(io::IO,grid::Matrix{Char}; empty_placeholder = "⋅", style="single")
    nrows, ncols = size(grid)
    pad = ndigits(maximum(size(grid)))+1

    borders = ['┌','┐','─','│','└','┘']
    if style == "double"
        borders = ['╔','╗','═','║','╚','╝']
    end

    # column indexes
    print(io, " "^(pad+1))
    for j in 1:ncols
        if j%10 == 0
            printstyled(io, j<10 ? " $j " : "$j ",italic=true)
        else
            print(io, j<10 ? " $j " : "$j ")
        end
    end
    println(io, "")

    # top border
    print(io, " "^pad, borders[1], borders[3]^(ncols*3), borders[2])
    println(io, "")
    
    for i in 1:nrows
        # row indexes
        if i%10 == 0
            printstyled(io, rpad(i, pad, " "),italic=true)
            print(io, borders[4])
        else
            print(io, rpad(i, pad, " "), borders[4])
        end
        # actual content
        for j in 1:ncols
            print(io, " ", grid[i, j] == ' ' ? empty_placeholder : grid[i,j], " ")
        end
        print(io, borders[4])
        println(io, "")
    end

    # bottom border
    print(io, " "^pad, borders[5], borders[3]^(ncols*3), borders[6])
    println(io, "")
end
show_grid(grid::Matrix{Char}; empty_placeholder = "⋅", style="single") = show_grid(stdout,grid; empty_placeholder=empty_placeholder,style=style)

# g = create_grid(9,11,type="random", from=EXT_ALPHABET);
# show_grid(g,style="single")
# show_grid(g,style="double", empty_placeholder = "_")


"""
    insert_row_above(grid::Matrix{Char})

Take a grid and insert an empty row above it, returning the new grid.

# Examples
```julia-repl
julia> g = create_grid(3,3,type="random")
3×3 Matrix{Char}:
 'Z'  'D'  'S'
 'W'  'N'  'Q'
 'U'  'V'  'S'

julia> insert_row_above(g)
4×3 Matrix{Char}:
 ' '  ' '  ' '
 'Z'  'D'  'S'
 'W'  'N'  'Q'
 'U'  'V'  'S'
```
"""
function insert_row_above(grid::Matrix{Char})
    old_nrows, old_ncols = size(grid)
    new_grid = create_grid(old_nrows+1, old_ncols, type="blank")
    for i in 1:old_nrows
        for j in 1:old_ncols
            new_grid[i+1, j] = grid[i, j]
        end
    end
    return new_grid
end

"""
    insert_row_below(grid::Matrix{Char})

Take a grid and insert an empty row below it, returning the new grid.

# Examples
```julia-repl
julia> g = create_grid(3,3,type="random")
3×3 Matrix{Char}:
 'Z'  'D'  'S'
 'W'  'N'  'Q'
 'U'  'V'  'S'

julia> insert_row_below(g)
4×3 Matrix{Char}:
 'Z'  'D'  'S'
 'W'  'N'  'Q'
 'U'  'V'  'S'
 ' '  ' '  ' '
```
"""
function insert_row_below(grid::Matrix{Char})
    old_nrows, old_ncols = size(grid)
    new_grid = create_grid(old_nrows+1, old_ncols, type="blank")
    for i in 1:old_nrows
        for j in 1:old_ncols
            new_grid[i, j] = grid[i, j]
        end
    end
    return new_grid
end

"""
    insert_col_right(grid::Matrix{Char})

Take a grid and insert an empty column on the right of it, returning the new grid.

# Examples
```julia-repl
julia> g = create_grid(3,3,type="random")
3×3 Matrix{Char}:
 'Z'  'D'  'S'
 'W'  'N'  'Q'
 'U'  'V'  'S'

julia> insert_col_right(g)
3×4 Matrix{Char}:
 'Z'  'D'  'S'  ' '
 'W'  'N'  'Q'  ' '
 'U'  'V'  'S'  ' '

```
"""
function insert_col_right(grid::Matrix{Char})
    old_nrows, old_ncols = size(grid)
    new_grid = create_grid(old_nrows, old_ncols+1, type="blank")
    for i in 1:old_nrows
        for j in 1:old_ncols
            new_grid[i, j] = grid[i, j]
        end
    end
    return new_grid
end

"""
    insert_col_left(grid::Matrix{Char})

Take a grid and insert an empty column on the left of it, returning the new grid.

# Examples
```julia-repl
julia> g = create_grid(3,3,type="random")
3×3 Matrix{Char}:
 'Z'  'D'  'S'
 'W'  'N'  'Q'
 'U'  'V'  'S'

julia> insert_col_left(g)
3×4 Matrix{Char}:
 ' '  'Z'  'D'  'S'
 ' '  'W'  'N'  'Q'
 ' '  'U'  'V'  'S'

```
"""
function insert_col_left(grid::Matrix{Char})
    old_nrows, old_ncols = size(grid)
    new_grid = create_grid(old_nrows, old_ncols+1, type="blank")
    for i in 1:old_nrows
        for j in 1:old_ncols
            new_grid[i, j+1] = grid[i, j]
        end
    end
    grid = new_grid
end

# g = create_grid(3,3,type="random")
# insert_col_left(g)
# insert_col_right(g)
# insert_row_above(g)
# insert_row_below(g)

"""
    insert(grid::Matrix{Char}, what::Symbol)

Take a grid and insert an empty row or column above/below or left/right of it, based on the 
symbol given by `what` (`:row_above`, `:row_below`, `:col_left`, `:col_right`), returning the new grid.
"""
function insert(grid::Matrix{Char}, what::Symbol)
    what in (:row_above, :row_below, :col_left, :col_right) && return eval(Symbol("insert_", what))(grid)
end

"""
    shrink(grid::Matrix{Char})

Take a grid and remove all-empty rows and columns from its borders. I.e., fits its contents to the smallest possible bounding box.

# Examples
```julia-repl
julia> using Random; Random.seed!(83)
julia> g = create_grid(7,7,type="random",probability=0.2)
7×7 Matrix{Char}:
 ' '  ' '  ' '  ' '  ' '  'C'  ' '
 ' '  ' '  ' '  ' '  ' '  ' '  'M'
 ' '  ' '  ' '  ' '  ' '  ' '  ' '
 ' '  ' '  'V'  ' '  ' '  ' '  ' '
 ' '  ' '  ' '  ' '  'A'  ' '  ' '
 ' '  ' '  ' '  'K'  ' '  ' '  ' '
 ' '  ' '  ' '  'Z'  ' '  ' '  ' '

julia> shrink(g)
7×5 Matrix{Char}:
 ' '  ' '  ' '  'C'  ' '
 ' '  ' '  ' '  ' '  'M'
 ' '  ' '  ' '  ' '  ' '
 'V'  ' '  ' '  ' '  ' '
 ' '  ' '  'A'  ' '  ' '
 ' '  'K'  ' '  ' '  ' '
 ' '  'Z'  ' '  ' '  ' '
```
"""
function shrink(grid::Matrix{Char})
    nrows, ncols = size(grid)
    top, bottom = 1, nrows
    left, right = 1, ncols

    # top boundary
    while top <= nrows && all(grid[top, :] .== ' ')
        top += 1
    end
    # bottom boundary
    while bottom >= 1 && all(grid[bottom, :] .== ' ')
        bottom -= 1
    end

    # left boundary
    while left <= ncols && all(grid[:, left] .== ' ')
        left += 1
    end
    # right boundary
    while right >= 1 && all(grid[:, right] .== ' ')
        right -= 1
    end

    # If the grid is entirely empty, return a minimal grid
    if top > bottom || left > right
        return create_grid(1, 1, type="blank")
    end
    return grid[top:bottom, left:right]
end

# i = rand(Int8); @show i; Random.seed!(i); g = create_grid(7,7,type="random",probability=0.2)
# Random.seed!(83); g = create_grid(7,7,type="random",probability=0.2)
# # show_grid(g)
# gg = shrink(g)
# g = shrink(g)
# # show_grid(gg)

