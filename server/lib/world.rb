class World

  attr_accessor :width, :height, :actors
  
  def initialize(width = 200, height = 200)
    self.width, self.height = width, height
    self.actors = []
  end

  def zombies
    actors.select {|a| a.is_a?(Zombie)}
  end

  def humans
    actors.select {|a| a.is_a?(Human)}
  end
  
  def add(actor)
    actors << actor
    place(actor)
  end

  class SteppingOnToesError < RuntimeError; end

  def try_to_place(actor, x, y)
    if actors.detect {|a| a != actor && a.x == x && a.y == y}
      raise SteppingOnToesError
    else
      actor.x, actor.y = x, y
    end
  end

  def place(actor)
    x, y = case actor
    when Zombie
      place_zombie(actor)
    when Human
      place_human(actor)
    end
    try_to_place actor, x, y
    actor
  rescue SteppingOnToesError
    retry
  end
  
  def place_zombie(actor)
    x = rand(0, width + 1)
    y = height + 1
    [x, y]
  end
  
  def place_human(actor)
    x_variance = self.width * 0.1
    x = rand(-x_variance, x_variance) + self.width / 2
    y_variance = self.height * 0.1
    y = rand(-y_variance, y_variance) + self.height / 2
    [x, y]
  end
  
  def current_environment_for(actor)
    case actor
    when Zombie
      {'visible' => humans}
    when Human
      {}
    end
  end

  def update
    self.actors.each do |a|
      a.think(current_environment_for(a))
    end
  end

  def save
    actors.each do |a|
      db[a.id] = a.to_hash.to_json
    end
  end

end