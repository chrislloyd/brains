class Brains::Zombie
  include Brains::Actor

  def think(env)
    find_target! env[:visible]

    # Turn around to target first (as attacks are directed)
    # Then start moving

  end

# private

  attr_accessor :target

  def find_target!(actors)
    self.target ||= actors.
      reject {|a| a.is_a?(Brains::Zombie)}.
      sort_by {|h| self.distance_to(h) }.
      first
  end

end
