$:.push 'lib'

require 'brains'


h = Brains::Human.new_with_brain('localhost:4567')

puts h.to_json

loop do

  env = {:visible => []}

  puts '-> thinking'

  h.think(env)

  puts h.to_json
  sleep 0.5
end



