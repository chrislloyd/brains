module Mortality
  attr_accessor :health

  def hurt(amount)
    (self.health <= amount) ? kill! : self.health -= amount
  end
end


class Actor
  include States
  include Mortality

  attr_accessor :x, :y, :dir, :dead_time

  states :idle, :moving, :turning, :attacking, :dead

  def initialize
    self.state, self.x, self.y, self.dir, self.health = :idle, 0, 0, 0, 100
    self.decay = 0
  end

  def rest!
    changes :from => being_alive, :to => :idle
  end

  def move(dx,dy)
    world.try_to_place(self, x+dx, y+dy)
    changes :from => being_alive, :to => :moving
  end

  def attack!
    changes :from => being_alive, :to => :attacking
  end

  def turn(deg)
    self.dir = deg
    changes :from => being_alive, :to => :turning
  end

  def kill!
    self.health = -1
    changes :from => being_alive, :to => :dead
  end

  def distance_to(actor)
    distance(actor.x, actor.y)
  end

  def dir=(dir)
    @dir = dir % 360
  end

  attr_accessor :decay

  def decays
    self.decay += 1
  end

  def distance(x,y)
    Math.sqrt((x - self.x)**2 + (y-self.y)**2)
  end

  def being_alive
    [:idle, :moving, :turning, :attacking]
  end

  def to_hash
    {:state => state, :x => x, :y => y, :dir => dir, :type => self.class.name.downcase, :health => health, :decay => decay}
  end

  # TODO Fix hack! Replace with uuid
  def id
    @id ||= rand(10000000)
  end

  def direction_to(actor)
    dx = x - actor.x
    dy = y - actor.y

    (Math.atan2(dx, dy).to_deg + 180) % 360
  end

  def can_see?(actor)
    in_range?(actor, 60, eyesight)
  end

  def can_attack?(victim)
    self != victim && !victim.dead? && in_range?(victim, 10, attack_range)
  end

  def in_range?(victim, scope, dist_limit)
    (direction_to(victim) - dir).abs < scope && distance_to(victim) <= dist_limit
  end

end


