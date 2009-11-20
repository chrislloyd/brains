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
# When a remote is found, send a verification cod e

world.add(Robot.new_with_brain('http://localhost:4567'))

loop do
  world.tick!
  world.clean


  # world.add_players(bonjour_players)

  world.spawn

  world.update
  world.save
  sleep 1/30.0
end
