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
  last_direction = 'R'
  config_index = 0
  result = ""
  @snake_static.each_char do |c|
    if c != 'X'
      result << c
    else
      if configuration[config_index] != '0'
        if last_direction == 'R'
          last_direction = 'L'
        else
          last_direction = 'R'
        end
      end
      result << last_direction
      config_index += 1
    end
  end
  result
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
