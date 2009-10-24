class Zombie < Actor

  def think(env)
    self.target ||= find_target(env['visible'])
    
    direction = direction_to(target)
    if (direction - self.dir).abs < 45
      x = Math.sin(direction).round
      y = Math.cos(direction).round
      move(x, y)
    else
      turn direction
    end
  rescue World::SteppingOnToesError
    rest!
  end

# private

  attr_accessor :target
  
  def find_target(actors)
    actors.
      reject {|a| a.is_a?(Zombie)}.
      sort_by {|h| self.distance_to(h) }.
      first
  end
  
  def direction_to(actor)
    dx = x - actor.x
    dy = y - actor.y

    (Math.atan2(dx, dy).to_deg + 180) % 360
  end

end