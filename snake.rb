require_relative "evolution"

# base string of snake
snake_static = "IIXXXIXXIXXXIXIXXXXIXIXIXII"

# number of bits in the bitvector
length = snake_static.count("X")

build_board = lambda do |snake|
  # build board (2d array with n times n size, where n = 2*snake.length + 1)
  board = []
  (2 * snake.length + 1).times do
    board << Array.new(2 * snake.length + 1, ' ')
  end

  x = snake.length
  y = snake.length
  dir_x = 1
  dir_y = 0
  max_x = x
  max_y = y
  min_x = x
  min_y = y

  board[y][x] = 'X'
  snake.each_char do |c|
    if c == 'R'
      tmp = dir_x
      dir_x = -dir_y
      dir_y = tmp
    elsif c == 'L'
      tmp = dir_x
      dir_x = dir_y
      dir_y = -tmp
    end

    x += dir_x
    y += dir_y
    return nil if board[y][x] != ' '
    board[y][x] = 'x'

    max_x = x if x > max_x
    min_x = x if x < min_x
    max_y = y if y > max_y
    min_y = y if y < min_y
  end

  minimized_board = []
  (max_y - min_y + 1).times do
    minimized_board << Array.new(max_x - min_x + 1, 0)
  end

  min_y.upto(max_y) do |y|
    min_x.upto(max_x) do |x|
      minimized_board[y-min_y][x-min_x] = board[y][x]
    end
  end

  minimized_board
end

snake_to_string = lambda do |value|
  configuration = ("%.#{length}b" % value).reverse.split("")
  directions = ['R', 'L']
  direction = 0
  snake = snake_static.split("")

  snake.each_with_index do |c, i|
    if c == 'X'
      if configuration.pop == '1'
      direction = 1 - direction
      end
    snake[i] = directions[direction]
    end
  end

  snake.join("")
end

flood_fill = lambda do |board, x, y|
  if board[y] && board[y][x] == ' '
    board[y][x] = 'o'

    flood_fill.call(board, x+1, y)
    flood_fill.call(board, x, y+1)
    flood_fill.call(board, x-1, y)
    flood_fill.call(board, x, y-1)
  end
end

# energy function that returns energy of a bitvector
# (the lower the number, the fitter the bitvector)

energy_a = lambda do |value|
  snake = snake_to_string.call(value)
  board = build_board.call(snake)

  return Float::INFINITY unless board

  width = board[0].length
  height = board.length
  Math.sqrt(width*width + height*height)
end

energy_b = lambda do |value|
  snake = snake_to_string.call(value)
  board = build_board.call(snake)

  return Float::INFINITY unless board

  width = board[0].length
  height = board.length

  1.upto(width-1) { |x| flood_fill.call(board, x, 0) }
  1.upto(height-1) { |y| flood_fill.call(board, width-1, y) }
  (width-2).downto(0) { |x| flood_fill.call(board, x, height-1) }
  (height-2).downto(0) { |y| flood_fill.call(board, 0, y) }

  holes = board.map { |x| x.join('') }.join('').count(' ')
  holes = Float::INFINITY if holes == 0
  holes
end

e = Evolution.new({
  :length => length,
  :energy => energy_b,
  :size => 15,
  :crossover => 5,
  :mutation => 15,
  :flip => 0.3,
  :selection => 1
})

e.iterate({
  :n => 10000,
  :energy => 1,  # use 9 for energy_a and 1 for energy_b
  :logging => true
})

print_individual = lambda do |i|
  snake = snake_to_string.call(i[:value])
  puts "%f\t%.#{length}b\t%s" % [i[:energy], i[:value], snake]
end

puts "number of iterations:\n#{e.iterations}\n\n"
puts 'final population:'
e.population.each { |i| print_individual.call(i) }
puts ''
puts 'all energies:'
e.individuals.each { |i| print_individual.call(i) }
puts ''
puts 'fittest individual:'
opt = e.population.first
puts print_individual.call(opt)
board = build_board.call(snake_to_string.call(opt[:value]))
puts board.map{|x| x.join("")}.join("\n")

=begin
# print all possible energy values for energy_a
all = {}
0.upto(2**length-1) do |value|
  energy = energy_a.call(value)
  if energy < Float::INFINITY
    individual = {:energy => energy, :value => value}
    all[energy] = individual unless all.has_key?(energy)
  end
end
a = all.values.sort { |a,b| a[:energy] <=> b[:energy] }
a.each { |i| puts "%f\t%.#{length}b" % [i[:energy], i[:value]] }
=end