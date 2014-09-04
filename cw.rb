# encoding: UTF-8
require 'pry'
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

CELL_HEIGHT = 5
CELL_WIDTH = 5

HEIGHT = 3
WIDTH = 5
NUMBER_OF_BLANK_SQUARES = 5

@words = []
@grid
@display_grid

class Word
	attr_accessor :hw, :length, :word, :dimension, :number
	def initialize(hw,len,word, dimension, number)
		@hw = hw
		@length = len
		@word = word
		@dimension = dimension
		@number = number
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

# ========================================
def create_grid
	@grid = Array.new(HEIGHT) { Array.new(WIDTH) { '.' } }
	add_random_blank_squares(NUMBER_OF_BLANK_SQUARES)
	remove_strange_blank_squares
	drop_outer_blanks
end

def add_random_blank_squares(number_of_blanks)
	number_of_blanks.times do |square|
		new_square = random_square
		if (@grid[new_square[0]][new_square[1]] == '█')
			redo
		else
			@grid[new_square[0]][new_square[1]] = '█'
		end
	end
end
# ========================================

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
			if n == ['█','█'] || n == ['█','█','█'] || n == ['█','█','█','█'] || n == ['█','█','█','█','█']
				@grid[height_index][width_index] = '█'
			end
		end
	end
end


# ========================================


# def add_borders_to_grid
# 	@grid.unshift([('#' * WIDTH).split(//)]) # Top Line
# 	@grid << [('#' * WIDTH).split(//)]		# Bottom Line
# 	@grid.each do |line|
# 		line.unshift '#'							# Left Column
# 		line << '#'									# Right Column
# 	end

# end
# ========================================

# def find_the_starting_points_for_words
# 	@grid.each_with_index do |height, height_index|
# 		height.each_with_index do |width, width_index|
# 			next unless @grid[height_index][width_index] == '.'
# 			if height_index == 0 || @grid[height_index-1][width_index] == '█' #|| # if the cell above is a border
# 				# We're working here... Hmmm...
# 			end
# 		end
# 	end
# end


def cell_is_at_the_top? h, w
	# print_grid
	is_at_top = true
	current = [h,w]

	while (current[0] > 0) # while our current 'selected' cell isn't at the top..
		# p "the cell one up is: #{@grid[current[0]-1][current[1]]}"
		unless @grid[current[0]-1][current[1]] == '#'
			is_at_top = false
		end
		# p
		current=[current[0]-1,current[1]]
	end
	is_at_top
end

def drop_blanks
	# p ''
	# print_grid
	max_lines = @grid.count
	@grid.each_with_index do |line, line_index|
		# if line_index == 0 || line_index == max_lines-1
		line.each_with_index do |cell, cell_index|
			if cell == '█'
				# p "focusing on cell #{[line_index, cell_index]}"
				#test to see if this is the top-most '█' cell.
				if (line_index == 0) || cell_is_at_the_top?(line_index, cell_index)
					line.each {|i| i.gsub! '█', '#'}
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

def deal_with_words
	fill_in_words('horizontal')
	@grid = @grid.transpose
	fill_in_words('vertical')
	@grid = @grid.transpose
end
def fill_in_words(dimension)
	word_number = 1
	@grid.each_with_index do |line, line_index|
		temp_width = line.count

		line.each_with_index do |cell, cell_index|
			if (@grid[line_index][cell_index] == '.')
				if cell_index == 0 || ((cell_index > 0) && (/█|#|-/.match @grid[line_index][cell_index-1]))
					selected = cell_index
					count = 0
					while (@grid[line_index][selected] == '.') && (selected <= temp_width)
						count += 1
						@grid[line_index][selected] = '-'
						selected += 1
					end

					coords = dimension == 'vertical' ? [cell_index, line_index] : [line_index, cell_index]
					@words << Word.new(coords,count,'.'*count, dimension, word_number)
					word_number += 1
				end
			end
		end
	end
	@grid.each{|i| i.each{|c| c.sub!('-','.')}}
end

def print_grid_properly
	new_grid = Array.new(HEIGHT * CELL_HEIGHT + 1) { Array.new(WIDTH * CELL_WIDTH + 1) {' ' }  } #░
	@grid.each_with_index do |line, line_index|
		line.each_with_index do |cell, cell_index|
			# p @grid[line_index][cell_index]
			draw_cell([line_index, cell_index], new_grid) if @grid[line_index][cell_index] == '.'
			draw_cell([line_index, cell_index], new_grid, '█') if @grid[line_index][cell_index] == '█'

		end
	end

	# new_grid = finish_borders_on_right_and_bottom new_grid

	new_grid.each do |line|
		line.join('')
	end
end

# def finish_borders_on_right_and_bottom new_grid
# 	number_of_lines = new_grid.count
# 	new_grid.each_with_index do |line,line_index|
# 		if /█|\./.match line.last
# 			line << '█'
# 		end
# 	end
# 	new_grid.each_with_index do |line,line_index|

# 		# p new_grid.count
# 		if line_index +1 == number_of_lines
# 			p 'this is the last line'
# 			new_grid << line.join(' ').gsub(/█|\./, '█').split
# 		end
# 	end
# end

def draw_cell(coords, new_grid, type='.')

	CELL_WIDTH.times do |w|
		# p [coords[0]]
		# p [coords[1]+w]
		new_grid[coords[0]*CELL_HEIGHT][coords[1]*CELL_WIDTH+w] = '█'
		new_grid[coords[0]*CELL_HEIGHT+CELL_HEIGHT][coords[1]*CELL_WIDTH+w] = '█'
	end
	CELL_HEIGHT.times do |h|
		new_grid[coords[0]*CELL_HEIGHT+h][coords[1]*CELL_WIDTH] = '█'
		new_grid[coords[0]*CELL_HEIGHT+h][coords[1]*CELL_WIDTH + CELL_WIDTH] = '█'
		# new_grid[coords[0]*CELL_HEIGHT+CELL_HEIGHT+h][coords[1]*CELL_WIDTH+] = '█'
	end
	new_grid[coords[0]*CELL_HEIGHT+CELL_HEIGHT][coords[1]*CELL_WIDTH+CELL_WIDTH] = '█'

	if type == '█'
		CELL_WIDTH.times do |w|
			CELL_HEIGHT.times do |h|
				new_grid[coords[0]*CELL_HEIGHT+h][coords[1]*CELL_WIDTH+w] = '█'
			end
		end
	end
end

def draw_numbers(word)
	real_coords = [word.hw[0] * CELL_HEIGHT, word.hw[1] * CELL_WIDTH ]#* 2 ] # * 2 at the end to compensate for spaces.
	# p real_coords
	# find word's coordinates
	# find the appropriate place to put them.
	# put them there.
	# ?potentially put an arrow to make it even easier...
	# ↓→
end



create_grid


deal_with_words

# @words.select!{|i| i.length > 1}

# add_borders_to_grid


@words.each {|w| p w}
print_grid
@display_grid = print_grid_properly
# @display_grid = @display_grid.transpose
word_list = {}
# @words.each do |word|
# 	text = (word.number.to_s + (word.dimension=='horizontal' ? '→' : '↓')).split(//)
# 	get_coords = word[@display_grid[draw_numbers(word)[0]+1][draw_numbers(word)[1]+1+n]]
# 	word[@display_grid[draw_numbers(word)[0]+1][draw_numbers(word)[1]+1+n]] << text
# end
@words.each do |word|
	if word_list[word.hw]
	p word_list[word.hw] 
end
	word_list[word.hw] = word.number.to_s + (word.dimension=='horizontal' ? '→' : '↓')
end

# @display_grid[draw_numbers(@words.first)[0]+1][draw_numbers(@words.first)[1]+1] = '@'
@words.each do |word|
	4.times do |n|
		text = (word.number.to_s + (word.dimension=='horizontal' ? '→' : '↓')).split(//)
		@display_grid[draw_numbers(word)[0]+1][draw_numbers(word)[1]+1+n] = text[n] if text[n] 
	end
end


@display_grid.each {|i| p i.join('')}
p word_list
# binding.pry
