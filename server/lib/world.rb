Thread.abort_on_exception = true

class World

  MIN_ZOMBIES = 10
  MAX_ZOMBIES = 20

  PERIOD = 10000
  DECAY  = 500 # ticks

  attr_accessor :width, :height, :clock, :lock
  attr_accessor :actors

  class SteppingOnToesError < RuntimeError; end

  # Responds to #x and #y like an actor
  class Point
    attr_accessor :x, :y
    def self.random(width, height)
      returning(new){|p| p.x = rand(width); p.y = rand(height)}
    end
  end

  def initialize(width = 800, height = 600)
    self.width, self.height = width, height
    self.clock = 0
    self.actors = []
  end

  def add(actor)
    actors << actor
    place(actor)
  end

  def humans
    actors.select { |a| a.is_a? Robot }
  end

  def dead_humans
    humans.select {|h| h.dead?}
  end

  def place(actor)
    x, y = actor.class.place(width, height)
    try_to_place actor, x, y
    actor
  rescue SteppingOnToesError
    # TODO Only do this a certain number of times
    retry
  end

  def robots
    actors.select {|a| a.is_a? Robot }
  end

  def zombies
    actors.select {|a| a.is_a? Zombie }
  end

  def try_to_place(actor, x, y)
    if actors.detect {|a| a != actor && a.x == x && a.y == y && !a.dead?}
      raise SteppingOnToesError
    elsif !actor.is_a?(Zombie) && (x < 0 || y < 0 || x > width || y > height)
      actor.hurt(20)
    else
      actor.x, actor.y = x, y
    end
  end

  def current_environment_for(actor)
    actor.to_hash.merge :visible => actors_visible_for(actor)
  end

  def attack_from(attacker)
    damage = 0
    actors.select {|a| attacker.can_attack?(a)}.each do |victim|
      if attacker.is_a?(Robot) && victim.is_a?(Robot)
        attacker.hurt(attacker.damage)
        damage -= attacker.damage
      else
        victim.hurt(attacker.damage)
        damage += attacker.damage
      end
    end
    damage
  end

  def actors_visible_for(actor)
    case actor
    when Zombie
      robots.reject {|h| h.dead?}
    else
      actors.select {|a| actor.can_see?(a)}
    end
  end

  def pick_point
    Point.random(width, height)
  end

  def update
    actors.sort_by {rand}.each do |actor|
      if actor.dead?
        if actor.is_a?(Robot)
          respawn(actor)
        else
          delete(actor)
        end
      else
        actor.think(current_environment_for(actor))
      end
    end
  end

  def delete(actor)
    actors.reject! {|a| a == actor && db.delete(actor.id)}
  end

  def respawn(actor)
    delete(actor)
    add(Robot.new(actor.url, actor.name)) if heroes.has_robot?(actor)
  end

  def tick!
    self.clock += 1
    self.clock %= PERIOD
  end

  # Adds zombies in waves
  def spawn
    n_robots = robots.reject {|a| a.dead?}.size
    n_zombies = zombies.reject {|a| a.dead?}.size

    number_of_new_zombies = Math.max((n_robots * MIN_ZOMBIES) + (Math.sin(clock.to_rad).abs * (MAX_ZOMBIES-MIN_ZOMBIES)).round - n_zombies, 0)

    number_of_new_zombies.times do |i|
      add pick_zombie.new
    end
  end

  # TODO Refactor
  def pick_zombie
    case rand(1000)
    when 0...50
      Witch
    when 50...100
      Tank
    else
      Zombie
    end
  end

  def save
    actors.each do |a|
      db[a.id] = a.to_hash.to_json
    end
  end

end
