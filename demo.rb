require_relative "evolution"

# base string of snake
@snake_static = "IXIIXIXXIXIXIXXIIXIXIXXIIXIXXIXIIXIXIIXXXIXIIXIXIXIIXIXXIIXIXI"

# number of bits in the bitvector
length = 30

# fitness function that returns fitness of a bitvector
# (the lower the number, the fitter the bitvector)
fitness = lambda do |value|
  # convert value in string of bits with fixed width
  s = "%.#{length}b" % value
  # return the number of zeros as fitness
  # (yes, this is a nonsense example!)
  s.count('0')
end

def snake_to_string(length, value)
  configuration = "%.#{length}b" % value
  directions = ['R', 'L']
  direction = 0
  snake = @snake_static
  
  while snake.include?'X' do
    i = snake.index('X')
    snake.slice!(i)
    if(configuration.slice(0) != '0')
      direction = 1-direction
    end
    snake.insert(i, directions[direction])
  end
  
  return snake
end

e = Evolution.new({
  :length => length,
  :fitness => fitness,
  :size => 10,
  :crossover => 5,
  :mutation => 5,
  :flip => 0.1,
  :selection => 0.5
})

e.iterate({
  :n => 100,
  :fitness => 0
})

puts e.population.map{|i| i[:fitness].to_s + "  " + i[:value].to_s + "  " + snake_to_string(length, i[:value])}.join("\n")
