# encoding: UTF-8
load 'dict.rb'
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
@temp_grid = []
@display_grid
@keys = []


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
	@words.reject!{|w| w.length<2}
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

def sort_out_words
	word_list = {}
	@words.each do |word|
	# 	if word_list[word.hw]
	# 	# p word_list[word.hw] 
	# end
		word_list[word.hw] = word.number.to_s + (word.dimension=='horizontal' ? '→' : '↓')
	end

	word_list.sort.each_with_index do |coord, num|
		@words.each do |word|
			if word.hw == coord[0]
				word.number = num+1
			end
		end
	end
end

def draw_numbers_and_symbols_to_grid
	@words.each do |word|
		4.times do |n|
			text = (word.number.to_s + (word.dimension=='horizontal' ? '→' : '↓')).split(//)
			if @display_grid[draw_numbers(word)[0]+1][draw_numbers(word)[1]+1+n] != ' '
				# p @display_grid[draw_numbers(word)[0]+1][draw_numbers(word)[1]+1+n]
				if @display_grid[draw_numbers(word)[0]+1][draw_numbers(word)[1]+1+n] == '→'
					@display_grid[draw_numbers(word)[0]+1][draw_numbers(word)[1]+1+n + 1] = '↓'
				end
				# @display_grid[draw_numbers(word)[0]+1].join.gsub!('→ ','→↓').split(//)
			else
				@display_grid[draw_numbers(word)[0]+1][draw_numbers(word)[1]+1+n] = text[n] if text[n] 
			end
		end
	end
end

def find_random_words_for_each_word
	unless is_finished?
		@words.sample.find_random_word_and_update_grid word
	end
end

def duplicate_temp_grid
	tmp = @temp_grid.last.dup
	@temp_grid << tmp
end

def find_random_word_and_update_grid
	# duplicate_temp_grid
	word = @words.select{|i| i.word.include? '.'}.sample
	update_current_word_from_grid word
	shortlist = create_shortlist_of_potential_words word
	
	if shortlist
		new_word = shortlist.sample
	else
		@temp_grid.pop
		return nil
	end

	word.word = new_word
	p word
	
	@temp_grid << (update_current_word_to_grid word)
end

def is_finished?
	r = true
	@words.each do |w|
		r = false if w.word.include? '.'
	end
	r 
end

def update_current_word_from_grid w
	count = w.length
	current_grid = @temp_grid.last.dup
	current_word = ''
	dimension = w.dimension == 'horizontal' ?  [0,1] : [1,0]
	starting_position = w.hw

	# p w
	# p dimension
	# p "count=#{count}"
	# current_grid[w.hw[0]+dimension[0]*n][w.hw[1]+dimension[1]*n]
	count.times do |n|
		p [w.hw[0]+(dimension[0]*n), w.hw[1]+(dimension[1]*n)]
		current_word = current_word + current_grid[w.hw[0]+(dimension[0]*n)][w.hw[1]+(dimension[1]*n)]
	end
	# p "current_word=#{current_word}"
	w.word = current_word
end

def update_current_word_to_grid w

	current_grid = @temp_grid.last.dup
	count = w.length
	dimension = w.dimension == 'horizontal' ?  [0,1] : [1,0]

	count.times do |n|
		begin
		current_grid[w.hw[0]+(dimension[0]*n)][w.hw[1]+(dimension[1]*n)] = w.word[n]
	rescue
		binding.pry
	end
	end
	current_grid
end

def update_keys
	@keys = @dict.map{|i| i[0]}
end

def create_shortlist_of_potential_words w
	@keys.map {|k| k.match(Regexp.new (w.word)).to_s}.reject{|i| i==''}
end


create_grid
deal_with_words
# add_borders_to_grid
print_grid
@temp_grid << @grid.dup
@display_grid = print_grid_properly
sort_out_words
draw_numbers_and_symbols_to_grid

 
update_keys

find_random_word_and_update_grid
find_random_word_and_update_grid
find_random_word_and_update_grid
find_random_word_and_update_grid


# find_random_words_for_each_word
# @words.each {|w| p w}
@display_grid.each {|i| p i.join('')}
@grid.each {|i| p i.join('')}
p @temp_grid
binding.pry