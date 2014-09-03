# encoding: UTF-8
require 'pry'
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

HEIGHT = 3
WIDTH = 5
NUMBER_OF_BLANK_SQUARES = 7

def print_grid
	@grid.each do |i|
		p i.join(' ')
	end
end

def random_square
	[(rand HEIGHT), (rand WIDTH)]
end

def add_random_blank_squares(number_of_blanks)
	number_of_blanks.times do |square|
		new_square = random_square
		if (@grid[new_square[0]][new_square[1]] == '■')
			redo
		else
			@grid[new_square[0]][new_square[1]] = '■'
		end
	end
end

def neighbours(h, w)
	return_array = []
# 	neighbours = [-1,0,1].product([-1,0,1]) - [0,0] #=> [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 0], [0, 1], [1, -1], [1, 0], [1, 1]]
	# return_array << @grid[h+1][w+1] 	unless ((h+2 > HEIGHT) || (w+1 < WIDTH)) # diagonal
	return_array << @grid[h+1][w] 	unless ( h+2 > HEIGHT) 
	# return_array << @grid[h+1][w-1] 	unless ((h+2 > HEIGHT )|| (w-1 < 0)) # diagonal
	return_array << @grid[h][w+1] 	unless (					w+1 > WIDTH)
	# return_array << @grid[h][h]    #Commented out because it's the current square.
	return_array << @grid[h][w-1] 	unless (					w-1 < 0	)
	# return_array << @grid[h-1][w+1] 	unless ((h-1 < 0) 	|| (w+1 > WIDTH)) # diagonal
	return_array << @grid[h-1][w]  	unless (	h-1 < 0	)
	# return_array << @grid[h-1][w-1]	  unless ((h-1 < 0) 	|| (w-1 < 0)) # diagonal
	return_array.compact

end

def remove_strange_blank_squares
	# @grid[1][1]= '?'
	@grid.each_with_index do |height, height_index|
		height.each_with_index do |width, width_index|
			n = neighbours(height_index, width_index)
			if n == ['■','■'] || n == ['■','■','■'] || n == ['■','■','■','■'] || n == ['■','■','■','■','■']
				@grid[height_index][width_index] = '■'
			end
		end
	end
end




def add_borders_to_grid
	@grid.unshift([('#' * WIDTH).split(//)]) # Top Line
	@grid << [('#' * WIDTH).split(//)]		# Bottom Line
	@grid.each do |line|
		line.unshift '#'							# Left Column
		line << '#'									# Right Column
	end

end

def find_the_starting_points_for_words
	@grid.each_with_index do |height, height_index|
		height.each_with_index do |width, width_index|
			next unless @grid[height_index][width_index] == '.'
			if height_index == 0 || @grid[height_index-1][width_index] == '■' #|| # if the cell above is a border 
				# We're working here... Hmmm...
			end
		end
	end
end


def drop_outer_blanks
	# @grid = 

end


@grid = Array.new(HEIGHT) { Array.new(WIDTH) { '.' } }
add_random_blank_squares(NUMBER_OF_BLANK_SQUARES)
print_grid 

remove_strange_blank_squares

drop_outer_blanks

find_the_starting_points_for_words


add_borders_to_grid

p ''
print_grid

