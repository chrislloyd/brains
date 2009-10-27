require 'patron'

class Human < Actor

  MAX_RESPONSE_LENGTH = 256
  VALID_ACTIONS = %w(idle move attack turn)

  attr_accessor :brain

  def self.new_with_brain(url)
    returning(new) do |h|
      h.brain = url
    end
  end

  BRAIN_TIMEOUT = 100
  BRAIN_CONNECT_TIMEOUT = 100000
  BRAIN_MAX_REDIRECTS = 1

  def brain=(url)
    @brain = returning(Patron::Session.new) do |b|
      b.connect_timeout = BRAIN_CONNECT_TIMEOUT
      b.timeout = BRAIN_TIMEOUT
      b.max_redirects = BRAIN_MAX_REDIRECTS
      b.base_url = url
      b.headers['User-Agent'] = 'brains/1.0'
    end
  end

  def send_request(env)
    brain.post '/', env.to_json, {'Content-Type' => 'application/json'}
  end

  def think(env)
    response = normalize_response(send_request(env))
    update! response
  rescue Patron::Error, ArgumentError
    rest!
  end

  def normalize_response(response)
    raise Patron::ConnectionFailed unless response.status == 200
    raise ArgumentError if response.body.length > MAX_RESPONSE_LENGTH

    validate_response JSON.parse(response.body)
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
      rest!
    when 'move'
      move(cmd['x'], cmd['y'])
    when 'attack'
      shoot
    when 'turn'
      turn(cmd['dir'])
    end
  rescue World::SteppingOnToesError
    rest!
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
