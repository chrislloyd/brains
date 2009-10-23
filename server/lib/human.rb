require 'rest_client'
require 'transaction/simple'

class Human < Actor
  include Transaction::Simple

  BRAIN_TIMEOUT = 1
  VALID_ACTIONS = %w(idle move attack turn)

  attr_accessor :brain

  def self.new_with_brain(brain)
    returning(new) do |h|
      h.brain = brain
    end
  end

  # TODO Inherit
  class BrainConnectionError < RuntimeError; end

  # TODO Rename
  def send_request(env)
    RestClient.post brain, env.to_json, :timeout => BRAIN_TIMEOUT, :open_timeout => BRAIN_TIMEOUT
  rescue RestClient::Exception
    raise BrainConectionError
  end

  def think(env)
    # This is all fucked
    start_transaction
    begin
      response = send_request(env)
      update! JSON.parse(response)
      self.errors = 0
      commit_transaction
    rescue Exception => e # TODO Make this explicit
      puts e
      puts e.backtrace

      abort_transaction
      self.errors += 1
      raise BrainConnectionError if self.errors >= 3
      rest!
    end
  end

  def validate_response(r)
    validate(r['cmd']) {|cmd| VALID_ACTIONS.include?(cmd)}
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
    {:state => self.state, :x => self.x, :y => self.y, :dir => self.dir, :errors => self.errors}.to_json
  end

# private

  attr_writer :errors

  def errors
    @errors || 0
  end

end
