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
a = all.values.sort { |a,b| a[:energy] <=> b[:energy] }
a.each { |i| puts "%f\t%.#{snake.length}b" % [i[:energy], i[:value]] }
