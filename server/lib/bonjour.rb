require 'thread'
require 'timeout'

class Bonjour
  
  def initialize
    @mutex = Mutex.new
    @players = []
    watch!
  end
    

  def each_player
    # Lock mutex
    # yield player
    # Unlock mutex
  end
  
# private
  
  def discover(timeout=1)
    waiting_thread = Thread.current

    dns = DNSSD.browse "_brains._tcp" do |reply|
      DNSSD.resolve reply.name, reply.type, reply.domain do |resolve_reply|
        service = Service.new(reply.name,
                                 resolve_reply.target,
                                 resolve_reply.port,
                                 "brains")
        begin
          yield service
        rescue Done
          waiting_thread.run
        end
      end
    end

    sleep timeout
    dns.stop
  end
  
  
  
end


class Service < Struct.new(:name, :target, :port, :description)
end

$mutex = Mutex.new
$new_robots = []

Thread.new do
  while true
    discover do |service|
      $mutex.synchronize do
        $new_robots << "http://#{service.target}:#{service.port}"
      end
    end
  end
end



# Add in any players found via bonjour
$mutex.synchronize do
  while !$new_robots.empty?
    new_robot = $new_robots.pop
    unless world.robots.detect {|robot| robot.brain == new_robot }
      puts "Adding new robot: #{new_robot}"
      world.add(Robot.new_with_brain(new_robot))
    end
  end
end

