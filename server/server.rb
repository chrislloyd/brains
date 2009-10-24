$:.push 'lib'

require 'brains'

require 'redis'

def db
  @db ||= Redis.new
end
db.flush_db

$world = World.new(640,480)

10.times do 
  $world.add(Zombie.new)
end

h = $world.add(Human.new_with_brain('localhost:4567'))

loop do

  # puts '-> thinking'

  $world.update

  $world.save

  # db.keys('*').each {|k| puts db[k]}
  
  # puts $world.actors.to_json
  sleep 1/30.0
end
