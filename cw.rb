# encoding: UTF-8
require 'pry'
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

HEIGHT = 3
WIDTH = 5
NUMBER_OF_BLANK_SQUARES = 7

def print_grid(grid)
	grid.each do |i|
		p i.join(' ')
	end
end

def random_square
	[(rand HEIGHT), (rand WIDTH)]
end

def add_random_blank_squares(number_of_blanks, grid)
	number_of_blanks.times do |square|
		new_square = random_square
		if (grid[new_square[0]][new_square[1]] == '■')
			redo
		else
			grid[new_square[0]][new_square[1]] = '■'
		end
	end
end

def neighbours(h, w, grid)
	p "height=#{h} -- width=#{w}"
	return_array = []
# 	neighbours = [-1,0,1].product([-1,0,1]) - [0,0] #=> [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 0], [0, 1], [1, -1], [1, 0], [1, 1]]
# 	neighbours.each do |f,s|
# 		unless (w < 0) || (w > WIDTH) || (h < 0) || (h > HEIGHT)
# 			return_array << grid[w+f][h+s]
# 		end
# 	end
# 	return_array
# rescue
# 	pry
p (h+1 > HEIGHT)
	return_array << grid[h+1][w+1] 	unless ((h+2 > HEIGHT) || (w+1 < WIDTH))
	return_array << grid[h+1][w] 	unless ( h+2 > HEIGHT)
	return_array << grid[h+1][w-1] 	unless ((h+2 > HEIGHT )|| (w-1 < 0))
	return_array << grid[h][w+1] 	unless (					w+1 > WIDTH)
	# return_array << grid[h][h]
	return_array << grid[h][w-1] 	unless (					w-1 < 0	)
	return_array << grid[h-1][w+1] 	unless ((h-1 < 0) 	|| (w+1 > WIDTH))
	return_array << grid[h-1][w]  	unless (	h-1 < 0	)
	return_array << grid[h-1][w-1]	  unless ((h-1 < 0) 	|| (w-1 < 0))
	return_array.compact

end

def remove_strange_blank_squares(grid)
	# grid[1][1]= '?'
	grid.each_with_index do |height, height_index|
		height.each_with_index do |width, width_index|
			# p grid
			# p grid[height][width]	
			n = neighbours(height_index, width_index, grid)
			if n == ['■','■','■'] || n == ['■','■','■','■'] || n == ['■','■','■','■','■']
				grid[height][width] = '■'
			end
		end
	end
end




def add_borders_to_grid(grid)
	updated_grid = grid.dup
	updated_grid.unshift([('#' * WIDTH).split(//)]) # Top Line
	updated_grid << [('#' * WIDTH).split(//)]		# Bottom Line
	updated_grid.each do |line|
		line.unshift '#'							# Left Column
		line << '#'									# Right Column
	end

end

grid = Array.new(HEIGHT) { Array.new(WIDTH) { '.' } }
add_random_blank_squares(NUMBER_OF_BLANK_SQUARES, grid)
print_grid grid

remove_strange_blank_squares grid

updated_grid = add_borders_to_grid grid
p ''
print_grid(updated_grid)

