require 'redis'
require 'logger'
require 'core_ext'
require 'environment'

def env
  @env ||= StringInquirer.new(ENV['ENVIRONMENT'] || 'development')
end

def logger
  @logger ||= Logger.new(env.production? ? '../brains.log' : $stdout)
end

logger.info 'starting game in #{env}'

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
logger.info 'playing with Hans'
r = Robot.new_with_brain('http://localhost:4567', 'Hans')
world.add(r)
r.run
