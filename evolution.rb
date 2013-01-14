class Evolution

  # number of iterations done
  attr_reader :iterations

  def population
    @population.sort{ |a,b| a[:energy] <=> b[:energy] }
  end
  
  # returns a list of individuals that were born first with its energy
  def individuals
    @log.values.sort{ |a,b| a[:energy] <=> b[:energy] }
  end
  
  def initialize(options)
    # fix length of the bitvectors generated as individuals in the population
    @length = options[:length]
    # energy function that retrieves such a bitvector (a number representing
    # a vector of bits and returns a number as energy indicator -- lower energy
    # corresponds to fitter individuals)
    @energy = options[:energy]
    # size of the pupulation (this number of individuals will be generated
    # in the initial random generation and will be keept in the selection step)
    @size = options[:size] || 100
    # number of new individuals created using crossover
    @crossover = options[:crossover] || 100
    # number of new individuals created using mutation
    @mutation = options[:mutation] || 100
    # propability to flip a bit during mutation
    @flip = options[:flip] || 0.1
    # randomness of selection (1 = maximal randomness, 0 = fully deterministic)
    @selection = options[:selection] || 0.5
  end
  
  # Generate the initial population of individuals randomly - first Generation
  def start
    @log = {}
    @population = @size.times.map do
      bear(rand(1<<@length))
    end
  end
  
  # Breed new individuals through crossover operations
  # to give birth to offspring
  def crossover
    @population += @crossover.times.map do
      pos = rand(@length)
      first, second = 2.times.map{ @population[rand(@population.length)][:value] }
      firstmap = (1<<@length)-(1<<pos)
      secondmap = (1<<pos)-1
      value = (first & firstmap) + (second & secondmap)
      # puts ("%.#{@length}b" % first) + ' cross(' + ("%5i" % pos) + ') ' + ("%.#{@length}b" % second) + ' --> ' + ("%.#{@length}b" % value)
      bear(value)
    end
  end
  
  # Breed new individuals through mutation operations
  # to give birth to offspring
  def mutation
    @population += @mutation.times.map do
      mask = 0
      0.upto(@length-1) do |i|
        mask += 1<<i if rand < @flip
      end
      individual = @population[rand(@population.length)][:value]
      value = individual ^ mask
      # puts ("%.#{@length}b" % individual) + ' xor          ' + ("%.#{@length}b" % mask) + ' --> ' + ("%.#{@length}b" % value)
      bear(value)
    end
  end
  
  # Perform one evolutionary step: create the next generation and select the
  # fittest indivudals
  def step
    crossover
    mutation
    # Compute selection order based on energy
    p = @population.map{ |i| [i, i[:energy] * (1 - @selection + rand * @selection) ] }
    # Select next generation: fitter individuals (lower energy number)
    # will be selected with higher propability  
    @population = p.sort{ |a,b| a[1] <=> b[1] }[0..@size].map{|i, o| i}
  end
  
  def iterate(options)
    # enable logging (needed to get all individuals with different energy)
    @logging = options[:logging]
    # number of iterations
    n = options[:n] || 100
    # target energy: stop iteration if an individual with energy lower than
    # this exists in the population
    energy = options[:energy]
    # actual iteration
    start
    i = 0
    while i < n do
      return @iterations = i if energy and @population.any?{ |i| i[:energy] <= energy }
      step
      i += 1
    end
    return @iterations = i
  end
  
  def bear(value)
    energy = @energy.call(value)
    individual = {:value => value, :energy => energy}
    @log[energy] = individual unless @log.has_key?(energy) if @logging
    individual
  end
end