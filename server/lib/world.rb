class World

  MIN_ZOMBIES = 10
  MAX_ZOMBIES = 30

  PERIOD = 10000
  DECAY  = 500 # ticks

  attr_accessor :width, :height, :actors, :clock
  attr_writer :zombies, :robots

  class SteppingOnToesError < RuntimeError; end

  # Responds to #x and #y like an actor
  class Point
    attr_accessor :x, :y
    def self.random(width, height)
      returning(new){|p| p.x = rand(width); p.y = rand(height)}
    end
  end


  def initialize(width = 200, height = 200)
    self.width, self.height = width, height
    self.actors, self.clock = [], 0
  end
  
  def mutex
    @mutex ||= Mutex.new
  end

  def zombies
    actors.select {|a| a.is_a?(Zombie)}
  end

  def robots
    actors.select {|a| a.is_a?(Robot)}
  end

  def add(actor)
    actors << actor
    place(actor)
  end

  def place(actor)
    x, y = actor.class.place(width, height)
    try_to_place actor, x, y
    actor
  rescue SteppingOnToesError
    # TODO Only do this a certain number of times
    retry
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
      victim.hurt(attacker.damage)
      damage += attacker.damage
    end
    damage
  end

  def actors_visible_for(actor)
    case actor
    when Zombie
      robots.reject {|h| h.dead?}
    else
      actors.select {|a| actor.can_see?(a) || actor.can_sense?(a)}
    end
  end

  def pick_point
    Point.random(width, height)
  end

  def update
    actors.sort_by {rand}.each do |a|
      if a.dead?
        a.decays
      else
        a.think(current_environment_for(a)) unless a.is_a? Robot
      end
    end
  end

  def tick!
    self.clock += 1
    self.clock %= PERIOD
  end

  def clean
    actors.reject! {|a| a.decay > DECAY && db.delete(a.id) }
  end

  # Adds zombies in waves
  def spawn
    n_robots = robots.reject {|a| a.dead?}.size
    n_zombies = zombies.reject {|a| a.dead?}.size

    number_of_new_zombies = Math.max((n_robots * MIN_ZOMBIES) + (Math.sin(clock.to_rad).abs * (MAX_ZOMBIES-MIN_ZOMBIES)).round - n_zombies, 0)

    number_of_new_zombies.times do |i|
      add(rand(20) == 0 ? Tank.new : Zombie.new)
    end
  end

  def save
    actors.each do |a|
      db[a.id] = a.to_hash.to_json
    end
  end

end
