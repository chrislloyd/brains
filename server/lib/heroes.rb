class Heroes
  attr_accessor :clients, :browser

  def initialize
    self.clients = []
    self.browser = Browser.new '_http._tcp,_brains'
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
    world.add(Robot.new("http://#{host}:4567", host))
    self.clients << host
  end

  def has_robot?(robot)
    browser.replies.detect {|rep| rep.target == robot.name}
  end

  def delete_dead_clients
    world.robots.
      select {|r| !has_robot?(r) }.
      each do |r|
        world.delete(r)
        self.clients.delete r.name
      end
  end
end
