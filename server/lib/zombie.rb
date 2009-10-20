class Zombie < Actor

  def turn_cw_or_ccw(deg)
    diff = (deg - self.deg)
    diff / diff
  end

  def think(env)
    find_target! env['visible']

    # Turn around to target first (as attacks are directed)
    # Then start moving

    unless target
      rest!
    end
  end

# private

  attr_accessor :target

  def find_target!(actors)
    self.target ||= actors.
      reject {|a| a.is_a?(Zombie)}.
      sort_by {|h| self.distance_to(h) }.
      first
  end

end
