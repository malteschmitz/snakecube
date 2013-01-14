require_relative "evolution"

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
  :fitness => 0,
  :logging => true
})

puts 'number of iterations: ' + e.iterations.to_s
puts ''
puts 'final population:'
puts e.population.map{|i| i[:fitness].to_s + "\t" + i[:value].to_s + "\t" + "%.#{length}b" % i[:value]}.join("\n")
puts ''
puts 'all fitnesses created:'
puts e.individuals.map{|i| i[:fitness].to_s + "\t" + i[:value].to_s + "\t" + "%.#{length}b" % i[:value]}.join("\n")