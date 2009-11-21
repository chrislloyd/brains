module States

  def self.included(obj)
    obj.extend(ClassMethods)
  end

  module ClassMethods

    def states(*states)
      unless states
        @states
      else
        @states = states
        states.each {|s| define_method("#{s}?") {state == s}}
      end
    end

  end

  attr_accessor :state

  class InvalidTransition < RuntimeError
    attr_accessor :from, :to
    
    def initialize(from, to)
      self.from = from
      self.to = to
    end
  end

  def any_state
    self.class.states
  end

  def changes(opts)
    unless opts[:from].include?(self.state) || any_state.include?(opts[:to])
      raise InvalidTransition(opts[:from], opts[:to])
    end
    self.state = opts[:to]
  end

end
