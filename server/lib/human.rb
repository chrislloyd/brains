require 'rest_client'

class Human < Actor

  MAX_RESPONSE_LENGTH = 256
  VALID_ACTIONS = %w(idle move attack turn)

  attr_accessor :brain

  def self.place(width, height)
    x_variance = width * 0.1
    x = rand(-x_variance, x_variance) + width / 2
    y_variance = height * 0.1
    y = rand(-y_variance, y_variance) + height / 2
    [x, y]
  end

  def self.new_with_brain(url)
    returning(new) do |h|
      h.brain = url
    end
  end

  def initialize
    super
    self.energy = 100
  end

  BRAIN_TIMEOUT = 100
  BRAIN_CONNECT_TIMEOUT = 100000
  BRAIN_MAX_REDIRECTS = 1

  def send_request(env)
    RestClient.post brain, env.to_json, :timeout => BRAIN_TIMEOUT, :open_timeout => BRAIN_TIMEOUT
  end

  def think(env)
    response = normalize_response(send_request(env))
    update! response
  rescue RestClient::Exception, ArgumentError
    rest!
  end

  def normalize_response(response)
    raise RestClient::Exception unless response.code == 200
    raise ArgumentError if response.length > MAX_RESPONSE_LENGTH

    validate_response JSON.parse(response)
  end

  def validate_response(json)
    returning(json) do |j|
      {
        'action' => lambda {|action| VALID_ACTIONS.include?(action)},
        'x' => lambda {|x| (-1..1).include?(x)},
        'y' => lambda {|y| (-1..1).include?(y)},
        'dir' => lambda {|dir| dir.is_a?(Numeric)}
      }.each do |key, validator|
        validate(j[key], &validator) if j[key]
      end
    end
  end

  def update!(cmd)
    case cmd['action']
    when 'idle'
      work(:idle)
      rest!
    when 'move'
      work(:move)
      move(cmd['x'], cmd['y'])
    when 'turn'
      work(:turn)
      turn(cmd['dir'])
    when 'attack'
      work(:attack)
      shoot
    end
  rescue World::SteppingOnToesError, ExhaustedError
    rest!
  end

  attr_accessor :energy

  class ExhaustedError < RuntimeError; end

  EXPENSES = {
    :idle => 20,
    :move => -20,
    :turn => -30,
    :attack => -100
  }

  def work(task)
    amount = EXPENSES[task]
    (energy < -amount) ? raise(ExhaustedError) : self.energy += amount
  end

  def shoot
    world.shoot_from(self)
  end

  def validate(arg)
    raise ArgumentError unless yield(arg)
  end

  def damage; 60 end
  def attack_range; 200 end
  def eyesight; 200 end

end
