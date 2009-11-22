class Heroes
  attr_accessor :clients, :browser

  def initialize
    self.clients = []
    self.browser = Browser.new '_http._tcp,_brains'
  end

  def watch!
    self.browser.watch!
  end

  def update!
    add_clients
    delete_dead_clients
  end

  def add_clients
    browser.replies.each do |reply|
      host = reply.target
      unless self.clients.include?(host)
        add_client(host)
      end
    end
  end

  def add_client(host)
    r = Robot.new_with_brain("http://#{host}:4567", host)
    world.add(r)
    self.clients << host
    r.run
  end
  
  def delete_dead_clients
    world.humans.each do |human|
      if human.dead? or !browser.replies.detect { |r| r.target == human.name }
        self.clients.delete human.name
        world.delete(human.name).stop!
      end
    end
  end
end
