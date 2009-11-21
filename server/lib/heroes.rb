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
    clean_disconnected_hosts
  end

  def add_clients
    browser.replies.each do |reply|
      host = reply.target
      add_client host unless clients.include?(host)
    end
  end

  def add_client(host)
    puts "Adding client #{host}"
    r = Robot.new_with_brain("http://#{host}:4567", host)
    world.add(r)
    self.clients << host
    r.run
  end

  def clean_disconnected_hosts
    self.clients = humans.collect {|h| h.name}
  end

  def known_hosts
    @browser.replies.map { |r| r.target }
  end
  
  def humans
    world.actors.select {|a| a.is_a? Robot and a.health != -1 and a.health != 0 }
  end
end
