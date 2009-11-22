class Zombie < Actor

  clean_writer :damage, :range, :eyesight, :speed, :initial_health

  attr_accessor :target

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
    dinner = env[:visible].find {|r| can_attack?(r)}

    if rand(0,3) == 0
      if dinner
        attack
      else
        self.target = find_target(env[:visible]) if needs_target?
        move_to(target)
      end
    else
      rest
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
      dx = Math.sin(direction)
      dy = Math.cos(direction)
      move(dx,dy)
    else
      turn direction
    end
  end

end
