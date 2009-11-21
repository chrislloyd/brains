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

  def remove(host)
    clients.delete host
  end
end
