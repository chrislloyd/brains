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
    if env[:visible].empty?
      if target.is_a?(Robot) || x.near?(target.x, 40) || y.near?(target.y, 40)
        self.target = world.pick_point
      end
    else
      self.target = env[:visible].sort_by {|r| distance_to(r)}.first
    end

    if target.is_a?(Robot) && can_attack?(target)
      attack
    else
      move_to(target)
    end

  rescue World::SteppingOnToesError
    rest
  end

# private

  def find_target(actors)
    actors.sort_by {|a| self.distance_to(a)}.first || world.pick_point
  end

  def needs_target?
    !target || (target.is_a?(Robot) && target.dead?) || (target.is_a?(World::Point) && x.near?(target.x, 40) && y.near?(target.y, 40))
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
