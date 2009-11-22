$LOAD_PATH << 'lib'

require 'brains'
require 'redis'
require 'logger'
require 'heroes'
require 'eventmachine'

def db; @db ||= Redis.new end

LOOP_TIME = 1/30.0

# Really bizarre bug where world was getting reset...
$world = World.new(800, 600)
def world; $world end

def logger; Logger.new(File.dirname(__FILE__) + "/../../brains.log"); end

def production?; ENV['ENVIRONMENT'] == 'production' end

def heroes
  @heroes ||= Heroes.new
end

logger.info "Starting up"

db.flush_db

if production?
  require 'browser'
  heroes.watch!
end

EM.run do
  # Running in local-server mode with a single robot...
  if !production? && @robot.nil?
    @robot = Robot.new('http://localhost:4567', 'Hans')
    world.add(@robot)
  end
  
  EM.add_periodic_timer(LOOP_TIME) do
    heroes.update! if production?
    
    world.tick!
    world.clean

    world.spawn

    world.update
    world.save
  end
end
