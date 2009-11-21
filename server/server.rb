$LOAD_PATH << 'lib'

require 'brains'
require 'redis'
require 'logger'

def db; @db ||= Redis.new end

# Really bizarre bug where world was getting reset...
$world = World.new(800, 600)
def world; $world end

def logger; Logger.new(File.dirname(__FILE__) + "/../../brains.log"); end

def production?; ENV['ENVIRONMENT'] == 'production' end

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
  require 'heroes'
  heroes = Heroes.new
  heroes.watch!
end

loop do
  heroes.update! if production?

  world.tick!
  world.clean

  world.spawn

  world.update
  world.save
  sleep 1/30.0
end
