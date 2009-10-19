class Brains::Human
  include Brains::Actor

  BRAIN_TIMEOUT = 0.5
  VALID_ACTIONS = %w(idle move attack turn)

  attr_accessor :brain

  def new_with_brain(brain)
    returning(new) do |h|
      h.brain = brain
    end
  end

  def think(env)
    response = RestClient.post brain, 'payload', :timeout => BRAIN_TIMEOUT, :open_timeout => BRAIN_TIMEOUT
    update! JSON.parse(response)
    self.errors = 0
  rescue
    self.errors += 1
    rest!
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
      move(cmd['deg'])
    end
  end

# private

  attr_writer :errors

  def errors
    @errors || 0
  end

end
