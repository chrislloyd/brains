module Brains::Energy
  attr_accessor :energy

  class NoEnergy < RuntimeError; end

  def work(amount)
    (self.energy < amount) ? raise(NoEnergy) : self.energy -= amount
  end
end

module Brains::Mortality
  attr_accessor :health

  def hurt(amount)
    (self.health < amount) ? kill! : self.health -= amount
  end
end


class Brains::Actor
  include Brains::States
  include Brains::Energy
  include Brains::Mortality

  N_DIRECTIONS = 8

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
  def move(x,y)
    validate(x) {|x| (-1..1).include?(x)}
    validate(y) {|y| (-1..1).include?(y)}

    # TODO Actually move
    self.x += x
    self.y += y


    changes :from => being_alive, :to => :moving
  end

  def attack!
    changes :from => being_alive, :to => :attacking
  end

  def turn(deg)
    validate(deg) {|deg| (-1..1).include?(deg) }

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

  def validate(arg)
    raise ArgumentError unless yield(arg)
  end

end


