class World

  attr_accessor :width, :height, :actors, :clock

  attr_writer :zombies, :humans

  def initialize(width = 200, height = 200)
    self.width, self.height = width, height
    self.actors, self.clock = [], 0
  end

  def zombies
    @zombies ||= actors.select {|a| a.is_a?(Zombie)}
  end

  def humans
    @humans ||= actors.select {|a| a.is_a?(Human)}
  end

  def add(actor)
    actors << actor
    place(actor)
  end

  class SteppingOnToesError < RuntimeError; end

  def try_to_place(actor, x, y)
    if actors.detect {|a| a != actor && a.x == x && a.y == y}
      raise SteppingOnToesError
    else
      actor.x, actor.y = x, y
    end
  end

  def place(actor)
    x, y = case actor
    when Zombie
      place_zombie(actor)
    when Human
      place_human(actor)
    end
    try_to_place actor, x, y
    actor
  rescue SteppingOnToesError
    retry
  end

  def place_zombie(actor)
    x = rand(0, width + 1)
    y = height + 1
    [x, y]
  end

  def place_human(actor)
    x_variance = self.width * 0.1
    x = rand(-x_variance, x_variance) + self.width / 2
    y_variance = self.height * 0.1
    y = rand(-y_variance, y_variance) + self.height / 2
    [x, y]
  end

  def current_environment_for(actor)
    case actor
    when Zombie
      {:visible => humans.reject {|h| h.dead?}}
    when Human
      {:x => actor.x,
       :y => actor.y,
       :dir => actor.dir,
       :health => actor.health,
       :visible => actors_visible_for(actor)
      }
    end
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
      humans
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

  MIN_NUMBER_OF_ZOMBIES = 10
  ZOMBIE_MUTLIPLIER = 10
  PERIOD = 10000

  def tick!
    self.clock += 1
    self.clock %= PERIOD
  end

  DEAD_TIME = 30 # ticks

  # TODO Leave dead actors on the board for a number of ticks
  def clean
    self.zombies = nil
    self.humans = nil

    actors.
      each {|a| db.delete(a.id) if a.dead? }.
      reject! {|a| a.dead? }
  end

  def spawn
    n_players = humans.reject {|a| a.dead?}.size
    n_zombies = zombies.reject {|a| a.dead?}.size

    number_of_new_zombies = Math.max((n_players * MIN_NUMBER_OF_ZOMBIES) + (Math.sin(clock.to_rad).abs * ZOMBIE_MUTLIPLIER).round - n_zombies, 0)

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
