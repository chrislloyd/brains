require 'redis'
require 'logger'

def production?
  ENV['ENVIRONMENT'] == 'production'
end

def logger
  Logger.new(production? ? '../brains.log' : $stdout)
end

logger.info 'spawning redis'

redis = fork do
  Signal.trap('SIGKILL') { exit }
  system '../bin/redis-server ../bin/redis.conf'
end

at_exit do
  Process.kill('SIGKILL', redis)
  Process.wait(redis)
end

sleep 1

logger.info 'starting game'

def db
  @db ||= Redis.new
end

# Really bizarre bug where world was getting reset...
$world = World.new(800, 600)
def world; $world end

logger.info 'flushing database'

db.flush_db

# If you are running the server on your local machine, run your bot at
#  localhost:4567
unless production?
  logger.info 'playing with Hans'
  r = Robot.new_with_brain('http://localhost:4567', 'Hans')
  world.add(r)
  r.run
else
  logger.info 'searching for robots'
  require 'browser'
  require 'heroes'
  heroes = Heroes.new
  heroes.watch!
end
