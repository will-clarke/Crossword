# encoding: UTF-8
require 'pry'
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

AVERAGE_WORD_LENGTH = 8
SIZE = 4
MAX_TIMES = 10000000

load 'dict.rb'

words_which_are_the_right_length = []

@dict.each do |i|
  if i[0].length == SIZE
    words_which_are_the_right_length <<  [i[0].upcase, i[1]]
  end
end

count = 0
loop do |l|

  grid = Array.new(SIZE) { Array.new(SIZE) {nil} }


  # p words_which_are_the_right_length[rand( words_which_are_the_right_length.count )]


  grid.map! do |i|
    a = words_which_are_the_right_length[rand( words_which_are_the_right_length.count )][0].split''
    # p a
    a
  end

  # p ''
  # p ''

  transposed = grid.transpose
  words = transposed.map do |i|
    i.join
  end

  matches = []
  words.each do |w|
    words_which_are_the_right_length.each do |i|
      if i[0] == w
        # p '=' * 20
        # p w
        unless matches.include? w
          matches << w
        end
      end
    end
  end

  if matches.count == SIZE
    p "FOUND ONE!    .. after #{count} tries... "
    grid.each do |i|
      p i
    end

    p ''
    p ''
    p up = words
    p down = grid.map {|i| i.join }

    p 'Accross:'
    down_clues = down.map do |d|
      words_which_are_the_right_length.map do |w|
        if w[0] == d
          w
        end
      end.compact
    end.compact.flatten(1).uniq{|i| i[0]}





    down_clues.each {|i| p i}

    p 'Down:'
    up_clues = up.map do |d|
      words_which_are_the_right_length.map do |w|
        if w[0] == d
          w
        end
      end.compact
    end.compact.flatten(1).uniq{|i| i[0]}


    up_clues.each {|i| p i}

    break
  end
  count += 1
  break if count > MAX_TIMES
end
# p words_which_are_the_right_length
# binding.pry
