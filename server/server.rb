$LOAD_PATH << 'lib'

require 'brains'
require 'redis'

require 'browser'
require 'heroes'

def db
  @db ||= Redis.new
end

# Really bizarre bug where world was getting reset...
$world = World.new(800, 600)
def world; $world end

# TODO Perhaps remove this?
db.flush_db

# TODO Have a seperate thread which checks bonjour
# When a remote is found, send a verification code

heroes = Heroes.new
heroes.watch!

loop do
  heroes.update!

  world.tick!
  world.clean

  world.spawn

  world.update
  world.save
  sleep 1/30.0
end
