require 'sinatra'
require 'json'

helpers do
  def json(obj)
    content_type :json
    obj.to_json
  end

  def random_direction
    # (-1 + rand(3))
    2
  end

  def random_movement
    # (-1 + rand(3))
    2
  end
end

post '/' do

  puts params

  moves = [
    {:action => 'turn', :direction => random_direction},
    {:action => 'move', :x => random_movement, :y => random_movement}
  ]

  move = moves[rand(moves.size)]

  puts move

  json move
end
