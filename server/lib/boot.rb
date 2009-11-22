require 'redis'
require 'logger'
require 'core_ext'
require 'environment'
require 'heroes'
require 'eventmachine'

def env
  @env ||= StringInquirer.new(ENV['ENVIRONMENT'] || 'development')
end

def logger
  # @logger ||= Logger.new(env.production? ? '../brains.log' : $stdout)
  @logger ||= Logger.new($stdout)
end

logger.info "starting game in #{env}"

def db
  @db ||= Redis.new
end

# Really bizarre bug where world was getting reset...
$world = World.new(800, 600)
def world; $world end

logger.info 'flushing database'

db.flush_db

def heroes
  @heroes ||= Heroes.new
end

if env.production?
  require 'browser'
  heroes.watch!
end
