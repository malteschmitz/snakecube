class Evolution

  attr_reader :population
  
  def initialize(options)
    # fix length of the bitvectors generated as individuals in the population
    @length = options[:length]
    # fitness function that retrieves such a bitvector (a number representing
    # a vector of bits and returns a number as fitness indicator -- lower values
    # corresponds to fitter individuals)
    @fitness = options[:fitness]
    # size of the pupulation (this number of individuals will be generated
    # in the initial random generation and will be keept in the selection step)
    @size = options[:size] || 100
    # number of new individuals created using crossover
    @crossover = options[:crossover] || 100
    # number of new individuals created using mutation
    @mutation = options[:mutation] || 100
    # propability to flip a bit during mutation
    @flip = options[:flip] || 0.1
    # randomness of selection (1 = fully random, 0 = fully by fitness)
    @selection = options[:selection] || 0.5
  end
  
  # Generate the initial population of individuals randomly - first Generation
  def start
    @population = @size.times.map do
      bear(rand(1<<@length))
    end
  end
  
  # Breed new individuals through crossover operations
  # to give birth to offspring
  def crossover
    @population += @crossover.times.map do
      pos = rand(@length)
      first, second = 2.times.map { @population[rand(@population.length)][:value] }
      firstmap = (1<<@length)-(1<<pos)
      secondmap = (1<<pos)-1
      bear((first & firstmap) + (second & secondmap))
    end
  end
  
  # Breed new individuals through mutation operations
  # to give birth to offspring
  def mutation
    @population += @mutation.times.map do
      mask = 0
      0.upto(@length) do |i|
        mask += 1<<i if rand < @flip
      end
      individual = @population[rand(@population.length)][:value]
      bear(individual ^ mask)
    end
  end
  
  # Perform one evolutionary step: create the next generation and select the
  # fittest indivudals
  def step
    crossover
    mutation
    # Compute selection order based on fitness
    p = @population.map { |i| [i, i[:fitness] * (1 - @selection + rand * @selection) ] }
    # Select next generation: fitter individuals (lower fitness number)
    # will be selected with higher propability  
    @population = p.sort { |a,b| a[1] <=> b[1] }[0..@size].map {|i, o| i}
  end
  
  def iterate(options)
    # number of iterations
    n = options[:n] || 100
    # target fitness: stop iteration if an individual with fitness lower than
    # this exists in the population
    fitness = options[:fitness]
    # actual iteration
    start
    i = 0
    while i < n do
      return if fitness and @population.any? { |i| i[:fitness] <= fitness }
      step
      i += 1
    end
  end
  
  def bear(value)
    fitness = @fitness.call(value)
    {:value => value, :fitness => fitness}
  end
end