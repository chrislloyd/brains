class World

  attr_accessor :width, :height, :actors

  def initialize
    self.actors = []
  end

  def zombies
    self.actors.select {|a| a.is_a?(Zombie)}
  end

  def humans
    self.actors.select {|a| a.is_a?(Human)}
  end

  class SteppingOnToesError < RuntimeError; end

  def try_to_place(actor, x, y)
    if self.actors.detect {|a| a != actor && a.x == x && a.y == y}
      raise SteppingOnToesError
    else
      actor.x, actor.y = x, y
    end
  end

  def connect_human(addr)
    h = Human.new_with_brain(addr)
    actors << h
    h
  end

  def current_environment_for(actor)
    {}
  end

  def update
    self.actors.each do |a|
      a.think(current_environment_for(a))
    end
  end

  def save
    actors.each do |a|
      $r[a.id] = a.to_json
    end
  end

end
