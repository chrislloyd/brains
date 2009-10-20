require 'rest_client'

class Brains::Human < Brains::Actor

  BRAIN_TIMEOUT = 1
  VALID_ACTIONS = %w(idle move attack turn)

  attr_accessor :brain

  def self.new_with_brain(brain)
    returning(new) do |h|
      h.brain = brain
    end
  end

  def think(env)
    response = RestClient.post brain, env.to_json, :timeout => BRAIN_TIMEOUT, :open_timeout => BRAIN_TIMEOUT
    puts "-> response: #{response}"
    update! JSON.parse(response)
    self.errors = 0
  # rescue Exception => e
  #   puts e
  #   self.errors += 1
  #   rest!
  end

  def update!(cmd)
    validate(cmd) {|cmd| VALID_ACTIONS.include?(cmd['action']) }

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

  def to_json
    {:state => self.state, :x => self.x, :y => self.y, :dir => self.dir}.to_json
  end

# private

  attr_writer :errors

  def errors
    @errors || 0
  end

end
