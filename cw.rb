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

def remove_strange_blank_squares(grid)
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

updated_grid = add_borders_to_grid grid
print_grid(updated_grid)
