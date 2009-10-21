module Energy
  attr_accessor :energy

  class NoEnergy < RuntimeError; end

  def work(amount)
    (self.energy < amount) ? raise(NoEnergy) : self.energy -= amount
  end
end

module Mortality
  attr_accessor :health

  def hurt(amount)
    (self.health < amount) ? kill! : self.health -= amount
  end
end


class Actor
  include States
  include Energy
  include Mortality

  N_DIRECTIONS = 8

  class_inheritable_accessor :world

  attr_accessor :x, :y, :dir

  states :idle, :moving, :turning, :attacking, :dead

  def initialize
    self.state = :idle

    # TODO Initialize properly
    self.x, self.y, self.dir = 0, 0, 0
  end

  def rest!
    changes :from => being_alive, :to => :idle
  end

  # Needs to be in a transaction
  def move(dx,dy)
    validate(dx) {|x| [-1,1].include?(x)}
    validate(dy) {|y| [-1,1].include?(y)}

    $world.try_to_place(self, x+dx, y+dy)

    changes :from => being_alive, :to => :moving
  end

  def attack!
    changes :from => being_alive, :to => :attacking
  end

  def turn(deg)
    validate(deg) {|deg| [-1,1].include?(deg) }

    self.dir = (self.dir + deg) % N_DIRECTIONS
    changes :from => being_alive, :to => :turning
  end

  def kill!
    self.health = -1
    changes :from => being_alive, :to => :dead
  end

  def distance_to(actor)
    Math.sqrt((actor.x - self.x)**2 + (actor.y-self.y)**2)
  end

# private

  def being_alive
    [:idle, :moving, :turning, :attacking]
  end

  # TODO Add error collection so we can send it back to the client
  def validate(arg)
    raise ArgumentError unless yield(arg)
  end

  # TODO Fix hack!
  def id
    @id ||= rand(10000000)
  end

end


