class Point
  attr :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def +(other)
    self.class.new(@x + other.x, @y + other.y)
  end
  
  def inspect
    "<%d,%d>" % [@x, @y]
  end
  
  # rotation of 90° in left ('L') or right ('R') direction
  # (in a coordinate system growing down and right)
  def rotate!(d)
    if d == 'L'
      @x, @y = @y, -@x
    elsif d == 'R'
      @x, @y = -@y, @x
    end
    self
  end
  
  # computes the minimum per coordinates
  def self.min(a, b)
    self.new([a.x, b.x].min, [a.y, b.y].min)
  end
  
  # computes the maximum per coordinates
  def self.max(a, b)
    self.new([a.x, b.x].max, [a.y, b.y].max)
  end
end
