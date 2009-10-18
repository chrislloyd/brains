# require 'init'

def returning(obj)
  yield obj
  obj
end

module Actor
  def self.included(actor); actor.extend(ClassMethods); end

  module ClassMethods
    def costs(costs=nil)
      costs.nil? ? @costs : @costs = costs
    end
    def damage_from(sources)
      sources.each do |source, amount|
        define_method("takes_damage_from_#{source}") do
          self.health -= amount
        end
    end
  end


  attr_accessor :health, :energy, :state

  class TooTired < RuntimeError; end
  class Dead < RuntimeError; end

  def spend_energy(type)
    cost = self.class.costs[type]
    if self.energy >= cost
      yield
      self.energy -= cost
    else
      raise TooTired
    end
  end

  def is_now(state)
    self.state = state
  end

  def hurt(amount)
    self.health -= amount
    is_now(state) if self.health <= 0
  end

end

class Player
  include Actor

  # Time in ms
  costs :turning,  :energy => 20, :time => 50
  costs :moving,   :energy => 40, :time => 150
  costs :shooting, :energy => 70, :time => 100

  damage_from :zombie => 20,
              :bullet => 50


  attr_accessor :brain
  attr_accessor :state, :x, :y, :dir, :health

  attr_accessor :locked_until

  def self.new_with_brain(brain)
    returning(new) {|p| p.brain = brain}
  end

  def initialize
    self.state, self.health, self.energy = :flacid, 100, 100
    # TODO Randomise
    self.x, self.y, self.dir = 0, 0, 0
  end

  def receive(json)
    # {:locked_until => 21312124}
  end

  def lock!(ms)
    self.locked_until = Time.now.to_f + (ms.to_f/1000)
  end

  class LockedError < RuntimeError; end

  def locked?
    Time.now.to_f < locked_until
  end

  def turn(cw=nil)
    spend_energy(:turning) do
      self.dir += (cw ? 1 : -1)
    end
  end

  def move(x,y)
    spend_energy(:moving) do
      self.x += x
      self.y += y
    end
  end

  def shoot
    spend_energy(:shooting) do
      context.fire_shot_from(self)
      is_now :shooting
    end
  end

  def gets_shot
    takes_damage_from_bullet
    is_now :hurting
  end

  def gets_eaten
    takes_damage_from_zombie
    is_now :flinching
  end

end

def World

  attr_accessor :players

end

p = Player.new_with_brain('foo.local')
p.turn(-1)
