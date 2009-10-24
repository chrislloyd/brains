require 'rest_client'

class Human < Actor

  VALID_ACTIONS = %w(idle move attack turn)

  attr_accessor :brain

  def self.new_with_brain(brain)
    returning(new) do |h|
      h.brain = brain
    end
  end
  
  BRAIN_TIMEOUT = 0.5

  # TODO Rename
  def send_request(env)
    RestClient.post brain, env.to_json, :timeout => BRAIN_TIMEOUT, :open_timeout => BRAIN_TIMEOUT
  end

  def think(env)
    response = normalize_response(send_request(env))
    update! response
  rescue RestClient::Exception, ArgumentError
    rest!
  end
  
  MAX_RESPONSE_LENGTH = 256
  
  def normalize_response(response)
    raise ArgumentError if response.length < MAX_RESPONSE_LENGTH
    
    validate_response JSON.parse(response)
  end

  def validate_response(json)
    validate(r['cmd']) {|cmd| VALID_ACTIONS.include?(cmd)}
    validate(r['x']) {|x| x && (-1..1).include?(x)}
    validate(r['y']) {|y| y && (-1..1).include?(y)}
    validate(r['dir']) {|dir| dir && dir.is_a?(Numeric)}
  end

  def update!(cmd)
    case cmd['action']
    when 'idle'
      rest!
    when 'move'
      move(cmd['x'], cmd['y'])
    when 'attack'
      attack!
    when 'turn'
      turn(cmd['direction'])
    end
  end

end
