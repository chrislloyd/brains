require 'rest_client'
require 'timeout'
require 'benchmark'

class Robot < Actor

  class OutOfEnergyError < RuntimeError; end
  class ActionParseError < RuntimeError; end

  VALID_ACTIONS = %w(idle move attack turn)
  MAX_LENGTH = 256
  TIMEOUT = 15

  STARTING_ENERGY = 3
  MAX_ENERGY = 6

  SPAWN_BOX = 0.8 # %

  attr_accessor :url, :uri, :energy, :name, :exception
  clean_writer :damage, :range, :eyesight

  damage {30 + rand(0,30)}
  range 200
  eyesight 200

  def self.place(width, height)
    x_variance = width * (SPAWN_BOX/2)
    x = rand(-x_variance, x_variance) + width / 2
    y_variance = height * (SPAWN_BOX/2)
    y = rand(-y_variance, y_variance) + height / 2
    [x, y]
  end

  def initialize(url, name)
    super()
    self.url = url
    self.uri = URI.parse(url)
    self.name = name
    self.energy = STARTING_ENERGY
  end

  def awaiting_response?; @awaiting_response end
  def awaiting_response!; @awaiting_response = true end
  def responded!; @awaiting_response = false end

  def think(env)
    return if awaiting_response?

    awaiting_response!
    request = EM::Protocols::HttpClient.request({
      :verb => 'POST',
      :host => uri.host,
      :port => uri.port,
      :request => "/",
      :content => env.to_json
    })

    request.timeout(TIMEOUT)

    request.callback do |response|
      begin
        responded!
        valid_response = validate(response)
        action = parse_action(valid_response)
        update(action)
      rescue ActionParseError, EventMachine::ConnectionError, JSON::ParserError
        kill!
      end
    end

    request.errback do
      logger.info("#{name} error'd")
      kill!
    end
  end

  def to_hash
    returning(super.merge({
      :name => name,
      :energy => energy,
      :score => score
    })) do |h|
      h[:exception] = exception if exception
    end
  end

# private

   def work
     (energy < 1) ? raise(OutOfEnergyError) : self.energy -= 1
   end

   def restock
     self.energy += 1 if energy < MAX_ENERGY
   end

  def validate(response)
    if response[:status] != 200 || response[:content].length > MAX_LENGTH
      raise ActionParseError
    else
      response[:content]
    end
  end

  def parse_action(response)
    returning(JSON.parse(response)) do |j|
      { 'action' => lambda {|action| VALID_ACTIONS.include?(action)},
        'x' => lambda {|x| (-1..1).include?(x)},
        'y' => lambda {|y| (-1..1).include?(y)},
        'dir' => lambda {|dir| dir.is_a?(Numeric)}
      }.each do |key, validator|
        raise ActionParseError if j[key] && !validator.call(j[key])
      end
    end
  end

  def update(action)
    case action['action']
    when 'idle'
      restock
      rest
    when 'move'
      move(action['x'], action['y'])
    when 'turn'
      turn(action['dir'])
    when 'attack'
      work
      attack
    end
  rescue World::SteppingOnToesError, OutOfEnergyError => e
    self.exception = e.message
    rest
  rescue InvalidTransition
  end

end
