import Base: show

mutable struct CrosswordWord 
	word::String
	row::Int
	col::Int
	direction::Symbol # :vertical or :horizontal 
end 

mutable struct CrosswordBlackCell
	count::Float64 # count of words that share that black cel
	manual::Bool # was automatic based on surronding words or was manually set by user
end


mutable struct CrosswordPuzzle
	grid::Matrix{Char}
	words::Vector{CrosswordWord}
	black_cells::Dict{Tuple{Int,Int}, CrosswordBlackCell}

	function CrosswordPuzzle(grid::Matrix{Char},words::Vector{CrosswordWord},black_cells::Dict{Tuple{Int,Int}, CrosswordBlackCell})
		cw = new(grid, words, black_cells); # uses default `new` constructor
		update_crossword!(cw); # post-construction initialization
		return cw;
	end
end


function CrosswordPuzzle(rows::Int, cols::Int) 
	grid = create_grid(rows,cols,type="blank");
	words = CrosswordWord[];
	black_cells = Dict{Tuple{Int,Int}, CrosswordBlackCell}();
	return CrosswordPuzzle(grid,words,black_cells);
end


"""
	update_crossword!(cw)

Update the crossword grid based on the current words and black cells. It is called internally after any change (e.g. a word or black cell addition or remotion) to keep the grid consistent with the internal information.
"""
function update_crossword!(cw::CrosswordPuzzle)
	nrows, ncols = size(cw.grid)
	new_grid = create_grid(nrows, ncols, type="blank")
	new_black_cells = Dict{Tuple{Int,Int}, CrosswordBlackCell}()

	# preserve manually placed black cells
	for (key, cell) in cw.black_cells
		if cell.manual == true
			new_black_cells[key] = cell
			new_black_cells[key[1],key[2]] = BLACK_CELL
		end
	end

	# inserting words
	for w in cw.words
		lw = length(w.word)
		if w.direction == :horizontal
			for (i, ch) in enumerate(w.word)
				new_grid[w.row, w.col + i - 1] = ch
			end
			# updating black cells
			# if a black cell already exists, we update its count based on this logic:
			# user placement => count = Infinity, automatic/derived placement: count += 1
			# otherwise we create a new black cell, initialized with count = 1 and manual = false
			if w.col-1>=1
				idx = (w.row,w.col-1) 
				new_grid[idx[1],idx[2]] = BLACK_CELL
				cell = get!(new_black_cells, idx, CrosswordBlackCell(0, false))
				cell.count += cell.manual ? Inf : 1 
			end
			if w.col+lw<=ncols 
				idx = (w.row,w.col+lw) 
				new_grid[idx[1],idx[2]] = BLACK_CELL
				cell = get!(new_black_cells, idx, CrosswordBlackCell(0, false))
				cell.count += cell.manual ? Inf : 1 
			end
		elseif w.direction == :vertical
			for (i, ch) in enumerate(w.word)
				new_grid[w.row + i - 1, w.col] = ch
			end
			# updating black cells
			if w.row-1>=1
				idx = (w.row-1,w.col) 
				new_grid[idx[1],idx[2]] = BLACK_CELL
				cell = get!(new_black_cells, idx, CrosswordBlackCell(0, false))
				cell.count += cell.manual ? Inf : 1             
			end
			if w.row+lw<=nrows 
				idx = (w.row+lw,w.col) 
				new_grid[idx[1],idx[2]] = BLACK_CELL
				cell = get!(new_black_cells, idx, CrosswordBlackCell(0, false))
				cell.count += cell.manual ? Inf : 1             
			end
		end
	end
	setfield!(cw, :grid, new_grid)
	setfield!(cw, :black_cells, new_black_cells)
end

function shrink!(cw::CrosswordPuzzle)
	

end

function enlarge!(cw::CrosswordPuzzle, how::Symbol, times::Int=1)
	if !(how in (:row_above, :row_below, :col_left, :col_right))
		@warn "Enlargement direction not available. No changes on the original grid."
		return false
	end
	# enlarge the grid
	new_grid = enlarge(cw.grid, how, times)
	setfield!(cw, :grid, new_grid)
	
	# if directions are :col_right or :row_below => nothing more to do
	# otherwise we need to shift words and black cells
	if how == :row_above
		for cword in cw.words
			cword.row += times
		end
		bc_new = Dict{Tuple{Int64, Int64}, CrosswordBlackCell}()
		for (key,cell) in cw.black_cells
			if cell.manual
				bc_new[key .+ (times,0)] = cell
			end
		end
		setfield!(cw, :black_cells, bc_new)
		update_crossword!(cw)
	elseif how == :col_left
		for cword in cw.words
			cword.col += times
		end
		bc_new = Dict{Tuple{Int64, Int64}, CrosswordBlackCell}()
		for (key,cell) in cw.black_cells
			if cell.manual
				bc_new[key .+ (0,times)] = cell
			end
		end
		setfield!(cw, :black_cells, bc_new)
		update_crossword!(cw)
	end
	return true
end

cw
enlarge!(cw,:col_left);cw
enlarge!(cw,:col_right);cw
enlarge!(cw,:row_below);cw
enlarge!(cw,:row_above);cw

function shrink!(cw::CrosswordPuzzle)


end


function Base.show(io::IO, cw::CrosswordPuzzle)
	show_crossword(io, cw, show_words=false, show_black_cells=false)
end
# the 3-argument show used by display(obj) on the REPL
function Base.show(io::IO, mime::MIME"text/plain", cw::CrosswordPuzzle)
	show_crossword(io, cw, show_words=true, show_black_cells=true)
end

"""
	show_crossword(cw; verbose=false)

Print the crossword grid along with the list of words, as well as the  black cells information if `verbose` is set to true.
"""
function show_crossword(io::IO, cw::CrosswordPuzzle; show_words=true, show_black_cells=true)
	# grid
	show_grid(io, cw.grid)
	# words
	if show_words
		if any([w.direction == :horizontal for w in cw.words]) 
			println(io, "Horizontal:")
			for w in filter(w -> w.direction == :horizontal, cw.words)
				println(io, " - '", w.word, "' at (", w.row, ", ", w.col, ")")
			end
		end
		if any([w.direction == :vertical for w in cw.words]) 
				println(io, "Vertical:")
			for w in filter(w -> w.direction == :vertical, cw.words)
				println(io, " - '", w.word, "' at (", w.row, ", ", w.col, ")")
			end
		end
	end
	# black cells
	if show_black_cells && !isempty(cw.black_cells)
		println(io, "Black cells:")
		for (pos,cell) in cw.black_cells
			println(io, " - at $pos was $(cell.manual==true ? "manually placed" : "automatically derived") (count=$(cell.count))")
		end
	end
end
show_crossword(cw::CrosswordPuzzle; show_words=true, show_black_cells=true) = show_crossword(stdout, cw; show_words=show_words, show_black_cells=show_black_cells)

xx = CrosswordPuzzle(5,5)
yy = CrosswordPuzzle(create_grid(5,5,type="blank"), CrosswordWord[], Dict{Tuple{Int,Int}, CrosswordBlackCell}())


words = [
	 CrosswordWord("cat", 2, 2, :horizontal) 
	,CrosswordWord("bat", 1, 3, :vertical)
	,CrosswordWord("sir", 4, 4, :horizontal)
	]
cw= CrosswordPuzzle(create_grid(6,6,type="blank"), words, Dict{Tuple{Int,Int}, CrosswordBlackCell}())
CrosswordPuzzle(5,5)
update_crossword!(cw)
cw
show_crossword(cw)

"""
	remove_word!(cw, word::String)

Remove a word from the crossword puzzle. Returns true if the word was found and removed, false otherwise.
"""
function remove_word!(cw::CrosswordPuzzle, word::String)
	if !(word in [w.word for w in cw.words])
		@warn "Word '$word' not found in the crossword. No changes on the original grid."
		return false
	end
	# @show cw.words
	deleteat!(cw.words,findfirst(w->w.word==word,cw.words))
	# @show cw.words
	update_crossword!(cw)
	return true
end
"""
	remove_word!(cw, cword::CrosswordWord)

Remove a word from the crossword puzzle. Returns true if the word was found and removed, false otherwise.
"""
remove_word!(cw::CrosswordPuzzle, cword::CrosswordWord) =  remove_word!(cw,cword.word)

cw
remove_word!(cw,"dog")
remove_word!(cw,"cat")
cw
show_crossword(cw,)

"""
	can_place_word(cw, word::String, row, col, direction::Symbol)

Check if a word can be placed in the crossword puzzle at the given position and direction (accepted values are `:horizontal` and `:vertical`). Returns true if the word can be placed, false otherwise.
"""
function can_place_word(cw::CrosswordPuzzle, word::String, row::Int, col::Int, direction::Symbol)
	lw = length(word)
	if direction == :horizontal
		if row+lw-1 > size(cw.grid,2)
			@warn "Word '$word' does not fit in the grid horizontally at ($row, $col). No changes on the original grid."
			return false
		end 
		for (i, ch) in enumerate(word)
			if !(cw.grid[row, col + i - 1] == EMPTY_CELL || cw.grid[row, col + i - 1] == ch)
				@warn "Cannot place word '$word' at ($row, $col) horizontally due to conflict at cel ($row, $(col + i - 1)). No changes on the original grid."
				return false
			end
		end
	elseif direction == :vertical
		if col+lw-1 > size(cw.grid,1)
			@warn "Word '$word' does not fit in the grid vertically at ($row, $col). No changes on the original grid."
			return false
		end 
		for (i, ch) in enumerate(word)
			if !(cw.grid[row + i - 1, col] == EMPTY_CELL || cw.grid[row + i - 1, col] == ch)
				@warn "Cannot place word '$word' at ($row, $col) vertically due to conflict at cell ($(row + i - 1), $col). No changes on the original grid."
				return false
			end
		end
	else
		@error "Wrong direction provided; use :horizontal or :vertical. No changes on the original grid."
		return false
	end
	return true
end
"""
	can_place_word(cw, cwword::CrosswordWord)

Check if a word can be placed in the crossword puzzle at the given position and direction (accepted values are `:horizontal` and `:vertical`). Returns true if the word can be placed, false otherwise.
"""
can_place_word(cw::CrosswordPuzzle, cword::CrosswordWord) = can_place_word(cw, cword.word, cword.row, cword.col, cword.direction)

"""
	place_word!(cw, word::String, row, col, direction::Symbol)

Place a word in the crossword puzzle at the given position and direction (accepted values are `:horizontal` and `:vertical`). Returns true if the word was successfully placed, false otherwise.
"""
function place_word!(cw::CrosswordPuzzle, word::String, row::Int, col::Int, direction::Symbol)
	if word in [w.word for w in cw.words]
		@warn "Word '$word' is already present in the crossword. No changes on the original grid."
		return false
	end
	if can_place_word(cw, word, row, col, direction)
		push!(cw.words, CrosswordWord(word, row, col, direction))
		update_crossword!(cw)
		return true
	else 
		return false
	end
end
"""
	place_word!(cw, cword::CrosswordWord)

Place a word in the crossword puzzle at the given position and direction (accepted values are `:horizontal` and `:vertical`). Returns true if the word was successfully placed, false otherwise.
"""
place_word!(cw::CrosswordPuzzle, cword::CrosswordWord) = place_word!(cw::CrosswordPuzzle, cword.word, cword.row, cword.col, cword.direction)

cw
place_word!(cw, "dog", 1, 1, :horizontal)
cw
place_word!(cw, "seb", 1, 1, :horizontal)
cw
remove_word!(cw, "seb")
place_word!(cw, "pratter", 2, 1, :horizontal)

"""
	place_black_cell!(cw, row, col)

Place a black cell in the crossword puzzle at the given position. Returns true if the black cell was successfully placed, false otherwise.
"""
function place_black_cell!(cw::CrosswordPuzzle, row::Int, col::Int)
	idx = (row, col)
	if haskey(cw.black_cells, idx)
		@assert cw.grid[row, col] == BLACK_CELL
		@warn "Black cell already present at position $idx. No changes on the original grid."
		return false
	end
	if cw.grid[row, col] != EMPTY_CELL 
		@warn "Cannot place black cell at position $idx since cell is not empty. No changes on the original grid."
		return false
	end
	cw.black_cells[idx] = CrosswordBlackCell(Inf64, true) # we manually placed it
	update_crossword!(cw)
end

# place_black_cell!(cw, 3, 2)
place_black_cell!(cw, 5, 1)
cw
place_word!(cw, "tv", 3, 1, :vertical)

"""
	remove_black_cell!(cw, row, col)

Remove a black cell from the crossword puzzle at the given position. Returns true if the black cell was successfully placed, false otherwise.
"""
function remove_black_cell!(cw::CrosswordPuzzle, row::Int, col::Int)
	idx = (row, col)
	if !haskey(cw.black_cells, idx)
		@warn "Black cell not present at position $idx. No changes on the original grid."
		return false
	else
		if cw.black_cells[idx].manual == true
			delete!(cw.black_cells, idx)
			update_crossword!(cw)
			return true
		else
			@warn "Cannot remove automatically placed black cell at position $idx since it's needed as a word delimiter. No changes on the original grid."
			return false
		end
	end
end
cw
place_black_cell!(cw, 5, 1)
cw
remove_black_cell!(cw, 5, 1)
cw
place_black_cell!(cw,5,5); cw
remove_black_cell!(cw,5,5); cw
