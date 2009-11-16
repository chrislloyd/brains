class World

  attr_accessor :width, :height, :actors, :clock

  attr_writer :zombies, :robots

  def initialize(width = 200, height = 200)
    self.width, self.height = width, height
    self.actors, self.clock = [], 0
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

  class SteppingOnToesError < RuntimeError; end

  def try_to_place(actor, x, y)
    if actors.detect {|a| a != actor && a.x == x && a.y == y && !a.dead?}
      raise SteppingOnToesError
    else
      actor.x, actor.y = x, y
    end
  end

  def place(actor)
    x, y = actor.class.place(width, height)
    try_to_place actor, x, y
    actor
  rescue SteppingOnToesError
    # TODO Only do this a certain number of times
    retry
  end

  def current_environment_for(actor)
    actor.to_hash.merge :visible => actors_visible_for(actor)
  end

  def try_to_attack(actor, victim)
    issue_attack(actor, victim) if actor.can_attack?(victim)
  end

  def shoot_from(actor)
    victim = actors.
      select {|a| actor.can_attack?(a)}.
      sort_by {|a| actor.distance_to(a)}.
      first
    issue_attack(actor, victim) if victim
  end

  def issue_attack(from, to)
    from.attack!
    to.hurt(from.damage)
  end

  def actors_visible_for(actor)
    case actor
    when Zombie
      robots.
        reject {|h| h.dead?}
    else
      actors.
        select { |a| actor.can_see?(a) && a != actor }.
        map {|a| a.to_hash }
    end
  end

  class Point
    attr_accessor :x, :y
    def self.random(width, height)
      returning(new){|p| p.x = rand(width); p.y = rand(height)}
    end
  end

  def pick_point
    Point.random(width, height)
  end

  def update
    actors.sort_by {rand}.each do |a|
      a.think(current_environment_for(a)) unless a.dead?
    end
  end

  def tick!
    self.clock += 1
    self.clock %= PERIOD

    actors.select {|a| a.dead? }.each {|a| a.decays }
  end

  DECAY_LIMIT = 500 # ticks

  def clean
    actors.reject! {|a| a.decay > DECAY_LIMIT && db.delete(a.id) }
  end

  MIN_NUMBER_OF_ZOMBIES = 10
  ZOMBIE_MUTLIPLIER = 60
  PERIOD = 10000

  def spawn
    n_robots = robots.reject {|a| a.dead?}.size
    n_zombies = zombies.reject {|a| a.dead?}.size

    number_of_new_zombies = Math.max((n_robots * MIN_NUMBER_OF_ZOMBIES) + (Math.sin(clock.to_rad).abs * ZOMBIE_MUTLIPLIER).round - n_zombies, 0)

    number_of_new_zombies.times do
      add(Zombie.new)
    end
  end

  def save
    actors.each do |a|
      db[a.id] = a.to_hash.to_json
    end
  end

end
