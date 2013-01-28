require_relative "snake"

snake = Snake.new("IIXXXIXXIXXXIXIXXXXIXIXIXII")

# print all possible energy values for energy_a
all = {}
0.upto(2**snake.length-1) do |value|
  energy = snake.energy_a.call(value)
  if energy < Float::INFINITY
    individual = {:energy => energy, :value => value}
    all[energy] = individual unless all.has_key?(energy)
  end
end

print_individual = lambda do |i|
  s = snake.to_string.call(i[:value])
  puts "%f\t%.#{snake.length}b\t%s" % [i[:energy], i[:value], s]
end

a = all.values.sort { |a,b| a[:energy] <=> b[:energy] }

puts 'all energies and first found individual with that energy:'
a.each { |i| print_individual.call(i) }
puts ''
puts 'first found fittest individual:'
opt = a.first
print_individual.call(opt)
board = snake.to_board.call(snake.to_string.call(opt[:value]))
puts ''
puts board.map{|x| x.join("")}.join("\n")
puts ''
puts 'first found unfittest individual:'
worst = a.last
print_individual.call(worst)
board = snake.to_board.call(snake.to_string.call(worst[:value]))
puts ''
puts board.map{|x| x.join("")}.join("\n")