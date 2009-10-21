$:.push 'lib'

require 'brains'

require 'redis'

$r = Redis.new
$r.flush_db

$world = World.new

h = $world.connect_human('localhost:4567')

loop do

  puts '-> thinking'

  $world.update

  $world.save

  $r.keys('*').each {|k| puts $r[k]}

  puts $world.actors.to_json
  sleep 0.05
end
