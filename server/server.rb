$: << 'lib'

require 'brains'
require 'redis'

def db
  @db ||= Redis.new
end

# Really bizarre bug where world was getting reset...
$world = World.new(640, 480)
def world; $world end

# TODO Perhaps remove this?
db.flush_db

h = world.add(Human.new_with_brain('http://localhost:4567'))

# TODO Have a seperate thread which checks bonjour
# When a remote is found, send a verification code

loop do
  world.tick!
  world.clean

  # Add in any players found via bonjour

  world.spawn

  world.update
  world.save
  sleep 1/30.0
end
