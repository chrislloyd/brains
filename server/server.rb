$LOAD_PATH << 'lib'

require 'brains'
require 'redis'

require File.dirname(__FILE__) + "/lib/browser"

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

@browser = Browser.new('_http._tcp,_brains')
@browser.watch!

brain_clients = []

loop do
  @browser.replies.each do |reply|
    host = reply.target
    unless brain_clients.include?(host)
      puts "Adding client #{host}"
      world.add(Robot.new_with_brain("http://#{host}:4567"))
      brain_clients << host
    end
  end
  
  world.tick!
  world.clean


  # world.add_players(bonjour_players)

  world.spawn

  world.update
  world.save
  sleep 1/30.0
end
