require_relative "evolution"

# number of bits in the bitvector
length = 30
# energy function that returns energy of a bitvector
# (the lower the number, the fitter the bitvector)
energy = lambda do |value|
  # convert value in string of bits with fixed width
  s = "%.#{length}b" % value
  # return the number of zeros as energy
  # (yes, this is a nonsense example!)
  s.count('0')
end

e = Evolution.new({
  :length => length,
  :energy => energy,
  :size => 10,
  :crossover => 5,
  :mutation => 5,
  :flip => 0.1,
  :selection => 0.5
})

e.iterate({
  :n => 100,
  :energy => 0,
  :logging => true
})

puts 'number of iterations: ' + e.iterations.to_s
puts ''
puts 'final population:'
puts e.population.map{|i| i[:energy].to_s + "\t" + i[:value].to_s + "\t" + "%.#{length}b" % i[:value]}.join("\n")
puts ''
puts 'all energies created:'
puts e.individuals.map{|i| i[:energy].to_s + "\t" + i[:value].to_s + "\t" + "%.#{length}b" % i[:value]}.join("\n")