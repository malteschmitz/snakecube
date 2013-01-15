require_relative "evolution"
require_relative "point"

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

  p = Point.new(snake.length, snake.length)
  dir = Point.new(1,0)
  max = p.dup
  min = p.dup

  snake.each_char do |c|
    # exit if current position is not blank
    return nil if board[p.y][p.x] != ' '
    # set current position
    board[p.y][p.x] = c
    # compute next position
    dir.rotate!(c)
    p += dir
    # update min and max
    max = Point.max(max, p)
    min = Point.min(min, p)
  end  
  #set last position
  return nil if board[p.y][p.x] != ' '
  board[p.y][p.x] = 'X'

  minimized_board = []
  min.y.upto(max.y) do |y|
    minimized_board[y - min.y] = []
    min.x.upto(max.x) do |x|
      minimized_board[y - min.y][x - min.x] = board[y][x]
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

# energy function which uses energy_b to maximize the holes
energy_c = lambda do |value|
  e_b = energy_b.call(value)
  return 0 if e_b == Float::INFINITY
  -e_b
end

e = Evolution.new({
  :length => length,
  :energy => energy_c,
  :size => 15,
  :crossover => 5,
  :mutation => 15,
  :flip => 0.3,
  :selection => 1
})

e.iterate({
  :n => 10000,
  :energy => -15,  # use 9 for energy_a, 1 for energy_b and -15 for energy_c
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
