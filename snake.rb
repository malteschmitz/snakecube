require_relative "evolution"

# base string of snake
snake_static = "IIXXXIXXIXXXIXIXXXXIXIXIXII"

# number of bits in the bitvector
length = snake_static.count("X")

build_board = lambda do |snake|
  # build board (2d array with n times n size, where n = 2*snake.length + 1)
  board = []
  (2*snake.length+1).times do
    board << Array.new(2*snake.length+1, 0)
  end
  
  x = snake.length
  y = snake.length
  dir_x = 1
  dir_y = 0
  max_x = snake.length
  max_y = snake.length
  min_x = snake.length
  min_y = snake.length
  
  board[y][x] = 1
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
    if board[y][x] != 0
      return nil
    end
    board[y][x] = 1
    
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
  
  return minimized_board
end

snake_to_string = lambda do |length, value|
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
  if board[y] && board[y][x] == 0
    board[y][x] = 1
    
    flood_fill(board, x+1, y)
    flood_fill(board, x, y+1)
    flood_fill(board, x-1, y)
    flood_fill(board, x, y-1)
  end
end

# fitness function that returns fitness of a bitvector
# (the lower the number, the fitter the bitvector)

fitness_a = lambda do |value|
  snake = snake_to_string.call(length, value)
  board = build_board.call(snake)
  
  if board != nil
    width = board[0].length
    height = board.length
  
    return Math.sqrt(width*width + height*height)
  else
    return Float::INFINITY
  end
end

fitness_b = lambda do |value|
  snake = snake_to_string.call(length, value)
  board = build_board.call(snake)
  
  if board != nil
  
    width = board[0].length
    height = board.length
       
    1.upto(width-1) { |x| flood_fill(board, x, 0) }
    1.upto(height-1) { |y| flood_fill(board, width-1, y) }
    (width-2).downto(0) { |x| flood_fill(board, x, height-1) }
    (height-2).downto(0) { |y| flood_fill(board, 0, y) }
    
    #puts board.map{|x| x.join("")}.join("\n")
    
    sum = 0
    board.each{ |row| row.each { |x| sum += x } }
    
    holes = width*height - sum
    if holes == 0
      return Float::INFINITY
    else
      return holes
    end
  else
    return Float::INFINITY
  end
end

e = Evolution.new({
  :length => length,
  :fitness => fitness_a,
  :size => 10,
  :crossover => 5,
  :mutation => 5,
  :flip => 0.1,
  :selection => 0
})

e.iterate({
  :n => 100,
  :fitness => 0
})

puts e.population.map{|i| i[:fitness].to_s + "  " + i[:value].to_s}.join("\n")

optimum = e.population.min_by{|i| i[:fitness]}
optimal_snake = snake_to_string.call(length, optimum[:value])
puts optimal_snake
puts build_board.call(optimal_snake).map{|x| x.join("")}.join("\n")
