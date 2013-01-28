require_relative "evolution"
require_relative "snake"

snake = Snake.new("IIXXXIXXIXXXIXIXXXXIXIXIXII")

e = Evolution.new({
  :length => snake.length,
  :energy => snake.energy_a,
  :size => 15,
  :crossover => 5,
  :mutation => 15,
  :flip => 0.3,
  :selection => 1
})

e.iterate({
  :n => 10000,
  :energy => 9,  # use 9 for energy_a, 1 for energy_b and -15 for energy_c
  :logging => true
})

print_individual = lambda do |i|
  s = snake.to_string.call(i[:value])
  puts "%f\t%.#{snake.length}b\t%s" % [i[:energy], i[:value], s]
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
board = snake.to_board.call(snake.to_string.call(opt[:value]))
puts board.map{|x| x.join("")}.join("\n")