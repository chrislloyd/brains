class Zombie < Actor

  attr_accessor :target

  def self.place(width, height)
    {
      :top => [rand(-1, width+1), height+1],
      :right => [width+1, rand(-1, height+1)],
      :bottom => [rand(-1, width+1), -1],
      :left => [-1, rand(-1, height+1)]
    }.pick
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
    if (direction - self.dir).abs < 5
      x = Math.sin(direction)
      y = Math.cos(direction)
      move(x, y)
    else
      turn direction
    end
  end

  def direction_to(actor)
    dx = x - actor.x
    dy = y - actor.y

    (Math.atan2(dx, dy).to_deg + 180) % 360
  end

  def damage; 5 end
  def range; 10 end
  def eyesight; 10 end

end