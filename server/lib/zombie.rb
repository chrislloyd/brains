class Zombie < Actor

  clean_writer :damage, :range, :eyesight, :speed, :initial_health
  attr_accessor :target

  damage 5
  range 20
  speed 1
  initial_health 100

  def self.place(width, height)
    { :top => [rand(-1, width+1), height+1],
      :right => [width+1, rand(-1, height+1)],
      :bottom => [rand(-1, width+1), -1],
      :left => [-1, rand(-1, height+1)]
    }.pick
  end

  def initialize
    super
    self.health = initial_health
  end

  def think(env)
    unless env[:visible].empty?
      self.target = env[:visible].sort_by {|r| distance_to(r)}.first
    else
      self.target = world.pick_point if needs_point?(env[:visible])
    end

    if target.is_a?(Robot) && can_attack?(target)
      attack
    else
      move_to(target)
    end

  rescue World::SteppingOnToesError
    rest
  rescue InvalidTransition
  end

# private

  def find_target(actors)
    actors.sort_by {|a| self.distance_to(a)}.first || world.pick_point
  end

  def needs_point?(visible)
    (target.is_a?(Robot) && visible.empty?) || (target.is_a?(World::Point) && distance_to(target) < 5)
  end

  def move_to(target)
    direction = direction_to(target)
    if (direction - dir).abs < 5
      dx = Math.min(speed, distance_to(target)) * Math.sin(direction)
      dy = Math.min(speed, distance_to(target)) * Math.cos(direction)
      move(dx,dy)
    else
      turn direction
    end
  end

end
