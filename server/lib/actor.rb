# module Energy
#   attr_accessor :energy
#
#   class NoEnergy < RuntimeError; end
#
#   def work(amount)
#     (self.energy < amount) ? raise(NoEnergy) : self.energy -= amount
#   end
# end

module Mortality
  attr_accessor :health

  def hurt(amount)
    (self.health < amount) ? kill! : self.health -= amount
  end
end


class Actor
  include States
  include Mortality
  # include Energy

  attr_accessor :x, :y, :dir

  states :idle, :moving, :turning, :attacking, :dead

  def initialize
    self.state, self.x, self.y, self.dir = :idle, 0, 0, 0
  end

  def rest!
    changes :from => being_alive, :to => :idle
  end

  def move(dx,dy)
    world.try_to_place(self, x+dx, y+dy)
    changes :from => being_alive, :to => :moving
  end

  def attack!
    world.bite(self)
    changes :from => being_alive, :to => :attacking
  end

  def turn(deg)
    self.dir = deg
    changes :from => being_alive, :to => :turning
  end

  def kill!
    self.health = -1
    puts 'I\'m dead!'
    changes :from => being_alive, :to => :dead
  end

  def distance_to(actor)
    distance(actor.x, actor.y)
  end

# private

  def distance(x,y)
    Math.sqrt((x - self.x)**2 + (y-self.y)**2)
  end

  def being_alive
    [:idle, :moving, :turning, :attacking]
  end

  # TODO Add error collection so we can send it back to the client
  def validate(arg)
    raise ArgumentError(arg) unless yield(arg)
  end

  def to_hash
    {:state => self.state, :x => self.x, :y => self.y, :dir => self.dir, :type => self.class.name.downcase}
  end

  # TODO Fix hack!
  def id
    @id ||= rand(10000000)
  end
  
  def direction_to(actor)
    dx = x - actor.x
    dy = y - actor.y

    (Math.atan2(dx, dy).to_deg + 180) % 360
  end
  
  def can_see(actor)
    (direction_to(actor) - self.dir).abs < 45
  end

end


