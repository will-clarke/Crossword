# encoding: UTF-8
require 'pry'
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

CELL_HEIGHT = 6
CELL_WIDTH = 4


HEIGHT = 3
WIDTH = 5
NUMBER_OF_BLANK_SQUARES = 2

@words = []

class Word
	attr_accessor :hw, :length, :word, :dimension
	def initialize(hw,len,word, dimension)
		@hw = hw
		@length = len
		@word = word
		@dimension = dimension
	end
end

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

# def find_the_starting_points_for_words
# 	@grid.each_with_index do |height, height_index|
# 		height.each_with_index do |width, width_index|
# 			next unless @grid[height_index][width_index] == '.'
# 			if height_index == 0 || @grid[height_index-1][width_index] == '■' #|| # if the cell above is a border 
# 				# We're working here... Hmmm...
# 			end
# 		end
# 	end
# end


def cell_is_at_the_top? h, w
	print_grid
	is_at_top = false
	current = [h,w]

	while (current[0] > 0) # while our current 'selected' cell isn't at the top..
		# p "the cell one up is: #{@grid[current[0]-1][current[1]]}"
		if @grid[current[0]-1][current[1]] == '#'
			is_at_top = true
		end
		# p 
		current=[current[0]-1,current[1]]
	end
	is_at_top
end

def drop_blanks
	p ''
	print_grid
	max_lines = @grid.count
	@grid.each_with_index do |line, line_index|
		# if line_index == 0 || line_index == max_lines-1
		line.each_with_index do |cell, cell_index|
			if cell == '■'
				p "focusing on cell #{[line_index, cell_index]}"
				#test to see if this is the top-most '■' cell.
				if (line_index == 0) || cell_is_at_the_top?(line_index, cell_index)
					line.each {|i| i.gsub! '■', '#'}
				end
			end
		end
	end
end

def drop_outer_blanks
	([HEIGHT, WIDTH].max * 4).times do
		2.times do
			drop_blanks
			@grid = @grid.transpose.reverse
		end
	end
end

def fill_in_words(dimension)
	@grid.each_with_index do |line, line_index|
		temp_width = line.count

		line.each_with_index do |cell, cell_index|
			if (@grid[line_index][cell_index] == '.')
				if cell_index == 0 || ((cell_index > 0) && (/■|#|-/.match @grid[line_index][cell_index-1]))
					selected = cell_index
					count = 0
					while (@grid[line_index][selected] == '.') && (selected <= temp_width)
						count += 1
						@grid[line_index][selected] = '-'
						selected += 1					
					end
					coords = dimension == 'horizontal' ? [cell_index, line_index] : [line_index, cell_index]
					@words << Word.new(coords,count,'.'*count, dimension)
				end
			end
		end
	end
	@grid.each{|i| i.each{|c| c.sub!('-','.')}}
end



@grid = Array.new(HEIGHT) { Array.new(WIDTH) { '.' } }
add_random_blank_squares(NUMBER_OF_BLANK_SQUARES)
print_grid 

remove_strange_blank_squares

drop_outer_blanks

fill_in_words('horizontal')
@grid.transpose
fill_in_words('vertical')
@grid.transpose

@words.select{|i| i.length > 1}
# find_the_starting_points_for_words --= delete?

# add_borders_to_grid

p ''
print_grid
@words.each {|w| p w}
print_grid

# binding.pry