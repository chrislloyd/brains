require 'sinatra'
require 'json'

helpers do
  def json(obj)
    content_type :json
    obj.to_json
  end

  def env
    JSON.parse(params.keys().first)
  end

  def rand_move
    [-1,1][rand(2)]
  end

  def rand_dir
    env['dir'] + rand_move*rand(5)
  end
end

post '/' do
  env = JSON.parse(params.to_s)
  p env
  @health = env['health']
  puts "Health: #{@health}"
  
  moves = [
    {:action => 'turn', :dir => rand_dir},
    {:action => 'move', :x => rand_move, :y => rand_move}
  ]

  json moves[rand(moves.size)]
end
