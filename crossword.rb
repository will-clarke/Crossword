#!/usr/bin/env ruby
# encoding: UTF-8
load 'dict.rb'
require 'pry'
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

PERCENTAGE_OF_BLANK_SQUARES = 30
HEIGHT = 5
WIDTH = 5

CELL_HEIGHT = 5
CELL_WIDTH = 8

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
	number_of_blank_squares = (HEIGHT * WIDTH * (PERCENTAGE_OF_BLANK_SQUARES.to_f / 100)).to_i
	add_random_blank_squares(number_of_blank_squares)
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
	p 'add_random_blank_squares'
	@grid.each {|i| p i.join(' ')}
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
	p 'remove remove_strange_blank_squares'
	@grid.each {|i| p i.join ' '}
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
	p 'drop_outer_blanks'
	@grid.each {|i| p i.join (' ')}
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
			case @grid[line_index][cell_index]
			when '█'
				draw_cell([line_index, cell_index], new_grid, '█')
			when '.'
				draw_cell([line_index, cell_index], new_grid)
			end
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
	# unless is_finished?
	@words.sample.find_random_word_and_update_grid word
	# end
end



def update_keys
	@keys = @dict.map{|i| i[0]}
end

# =================================================================
def is_finished?
	r = true
	count = 0
	@words.each do |w|
		if w.word.include? '.'
			r = false
			count += 1
		end
	end
	p count
	# !(@temp_grid.last.flatten.include? '.')
	r
end


def create_shortlist_of_potential_words w
	@keys.map {|k| k.match(Regexp.new ('^' + w.word + '$'), true).to_s}.reject{|i| i==''}
end

# =================================================================

def update_current_word_from_grid w
	count = w.length
	current_grid = Marshal.load( Marshal.dump(@temp_grid.last.dup) )
	current_word = ''
	dimension = w.dimension == 'horizontal' ?  [0,1] : [1,0]
	starting_position = w.hw

	count.times do |n|
		# p [w.hw[0]+(dimension[0]*n), w.hw[1]+(dimension[1]*n)]
		current_word = current_word + current_grid[w.hw[0]+(dimension[0]*n)][w.hw[1]+(dimension[1]*n)]
	end
	w.word = current_word

end

def update_current_word_to_grid w

	current_grid = Marshal.load( Marshal.dump(@temp_grid.last.dup) )
	count = w.length
	dimension = w.dimension == 'horizontal' ?  [0,1] : [1,0]

	count.times do |n|
		current_grid[w.hw[0]+(dimension[0]*n)][w.hw[1]+(dimension[1]*n)] = w.word[n]
	end
	current_grid
end


def find_total_cells_in_the_word w
	return_array = []
	starting position = w.hw
	dimension = w.dimension == 'horizontal' ?  [0,1] : [1,0]
	length = w.length


	w.length.times do |n|
		return_array << [[w.hw[0]+(dimension[0]*n)],[w.hw[1]+(dimension[1]*n)]]
	end
	return_array
end

def populate_list_of_words_intersecting_these_cells cells
	return_array = []
	cells.each do |cell|
		@words.each do |word|
			p "word.hw: #{word.hw} -- cell: #{cell}"
			return_array << word if word.hw == cell
		end
	end
	return_array
end

def find_intersecting_words w
	cells = find_total_cells_in_the_word w
	populate_list_of_words_intersecting_these_cells cells
end

def remove_this_word w
	#remove word.word
	# remove FROM tmp_GRID.last

end

def find_random_word_and_update_grid

	# @words.sort{ |a,b| a.hw <=> b.hw }.each{|i| p i}
	word = @words.select{|i| i.word.include? '.'}.sample
	# p "looking at: #{word.hw}"
	# @words.each {|i| update_current_word_from_grid i}
	update_current_word_from_grid word
	# p "need to fit: #{word.word}"
	shortlist = create_shortlist_of_potential_words word

	if shortlist.any?
		new_word = shortlist.sample
		# p "found: #{new_word}"
	else
		# p 'nope. Nothing fits'
		@temp_grid.pop
		@words.each {|i| update_current_word_from_grid i}
		@words.each do |word|
			if !word.word.include?('.')
				unless @dict.select {|i| i[0].downcase == word.word.downcase}
					p 'OMG. We have a rogue word. OMG.'
					word.word = '.'
					# if there's a word at the starting point, remove that word:
					if find_intersecting_words word
						remove_this_word(find_intersecting_words(word).sample)
					end
				end
			end
		end


		# @temp_grid.last.each {|i| p i }
		# p ''
		word.word = '.'
		# p "word reset: #{word}"
		# p "word reset: #{word.word}"
		# p word
		# @words.sort{ |a,b| a.hw <=> b.hw }.each{|i| p i}

		return nil
	end

	word.word = new_word

	@temp_grid << (update_current_word_to_grid word)

	# @temp_grid.last.each {|i| p i }
	# p ''

end
# =================================================================
def get_definition w
	word = @dict.select{|i| i[0].downcase==w.downcase}
	begin
		definition = word[0][1].sample
		definition.strip!
		definition.gsub!(/^\.|\.$/, '')
		definition.strip!
		definition[0] = definition[0].upcase
	rescue
		binding.pry
	end
	definition
end

def find_and_display_clues
	list_of_clues={}
	list_of_clues['accross'] = []
	list_of_clues['down'] = []
	@words.each do |word|
		@dict.select
		display_info = "#{sprintf("%-3d", word.number)} - #{get_definition word.word} (#{word.length})"
		orientation = ((word.dimension == 'horizontal') ? 'accross' : 'down')
		list_of_clues[orientation] << display_info
	end
	p ' ' * @grid[0].count * CELL_WIDTH
	p ' ' * @grid[0].count * CELL_WIDTH
	p ' ' * @grid[0].count * CELL_WIDTH

	p 'Accross'
	p ' ' * @grid[0].count * CELL_WIDTH

	list_of_clues['accross'].sort_by{|i| i[0..3].to_i}.each do |i|
		p i
	end

	p ' ' * @grid[0].count * CELL_WIDTH
	p ' ' * @grid[0].count * CELL_WIDTH

	p 'Down'
	p ' ' * @grid[0].count * CELL_WIDTH

	list_of_clues['down'].sort_by{|i| i[0..3].to_i}.each do |i|
		p i
	end

end


# =================================================================

create_grid
deal_with_words
# add_borders_to_grid
@temp_grid << @grid.dup
@display_grid = print_grid_properly
sort_out_words
draw_numbers_and_symbols_to_grid

update_keys

count = 0
while !is_finished?
	# p count
	if count > ((WIDTH + 2) * (HEIGHT + 2))
		Kernel.exec 'ruby crossword.rb'
	end
	count += 1
	find_random_word_and_update_grid
end
# find_random_word_and_update_grid
# find_random_words_for_each_word
# @words.each {|w| p w}
# @grid.each {|i| p i.join('')}


# @temp_grid.last.each {|i| p i.join('')}
# @words.each {|i| p i}
@display_grid.each {|i| p i.join('')}
find_and_display_clues
p ' ' * @grid[0].count * CELL_WIDTH
p ' ' * @grid[0].count * CELL_WIDTH
p ' ' * @grid[0].count * CELL_WIDTH
p 'Answer:'
p ' ' * @grid[0].count * CELL_WIDTH
p ' ' * @grid[0].count * CELL_WIDTH

@temp_grid.last.each {|i| p i.join(' ').upcase}
