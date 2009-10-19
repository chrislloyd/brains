# require 'init'

def returning(obj)
  yield obj
  obj
end

module Actor
  def self.included(actor); actor.extend(ClassMethods); end

  module ClassMethods
    def damage_from(sources)
      sources.each do |source, amount|
        define_method("takes_damage_from_#{source}"){ hurt(amount) }
      end
    end

    def valid_accessor(attr)
      attr_accessor attr
      define_method("#{attr}=") do |val|
        yield(val) ? send("#{attr}=", val) : raise ArgumentError
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



  damage_from :zombie => 20,
              :bullet => 50


  attr_accessor :brain
  attr_accessor :state, :x, :y, :dir, :health
  
  
  valid_accessor :dir {|dir| (-1..1).include?(dir)}
  valid_accessor :x {|x| (0..1).include?(x)}
  valid_accessor :y {|y| (0..1).include?(y)}
  valid_accessor :state {|y| %w().include?(y)}
  

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
