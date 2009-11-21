$LOAD_PATH << 'lib'

require 'brains'
require 'redis'
require 'logger'
require 'heroes'

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

# If you are running the server on your local machine, run your bot at
#  localhost:4567
unless production?
  r = Robot.new_with_brain('http://localhost:4567', 'Hans')
  world.add(r)
  r.run
else
  require 'browser'
  heroes.watch!
end

loop do
  old_time = Time.now
  heroes.update! if production?

  world.tick!
  world.clean

  world.spawn

  world.update
  world.save

  loop_time = Time.now - old_time
  sleep LOOP_TIME - loop_time if loop_time < LOOP_TIME
end
