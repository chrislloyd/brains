require 'rest_client'
require 'transaction/simple'

class Brains::Human < Brains::Actor
  include Transaction::Simple

  BRAIN_TIMEOUT = 1
  VALID_ACTIONS = %w(idle move attack turn)

  attr_accessor :brain

  def self.new_with_brain(brain)
    returning(new) do |h|
      h.brain = brain
    end
  end

  class BrainConnectionError < RuntimeError; end

  def think(env)
    start_transaction
    begin
      response = RestClient.post brain, env.to_json, :timeout => BRAIN_TIMEOUT, :open_timeout => BRAIN_TIMEOUT
      puts "-> response: #{response}"
      update! JSON.parse(response)
      self.errors = 0
      commit_transaction
    rescue # TODO Make this explicit
      abort_transaction
      self.errors += 1
      raise BrainConnectionError if self.errors >= 3
      rest!
    end
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
