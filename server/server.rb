$LOAD_PATH << 'lib'

require 'brains'
require 'redis'
require 'dnssd'

def db
  @db ||= Redis.new
end

# Really bizarre bug where world was getting reset...
$world = World.new(640, 480)
def world; $world end

# TODO Perhaps remove this?
db.flush_db

# TODO Have a seperate thread which checks bonjour
# When a remote is found, send a verification code
class Service < Struct.new(:name, :target, :port, :description)
end

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

loop do
  world.tick!
  world.clean

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

  world.spawn

  world.update
  world.save
  sleep 1/30.0
end
