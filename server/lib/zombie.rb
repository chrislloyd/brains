class Zombie < Actor

  def think(env)
    dinner = env[:visible].select {|h| can_attack?(h)}

    if dinner.empty?
      self.target = find_target(env[:visible]) if needs_target?
      move_to(target)
    else
      bite(dinner.first)
    end
  rescue World::SteppingOnToesError
    rest!
  end

# private

  attr_accessor :target

  def find_target(actors)
    actors.sort_by {|h| self.distance_to(h)}.first || world.pick_point
  end

  def needs_target?
    !target || (target.is_a?(Human) && target.dead?) || (target.is_a?(World::Point) && x.near?(target.x, 40) && y.near?(target.y, 40))
  end

  def move_to(target)
    direction = direction_to(target)
    if (direction - self.dir).abs < 5
      x = Math.sin(direction).round
      y = Math.cos(direction).round
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

  def bite(player)
    world.try_to_attack(self, player)
  end

  def self.place(width, height)
    x = rand(0, width + 1)
    y = height + 1
    [x, y]
  end

  def damage; 30 end
  def attack_range; 20 end

end
