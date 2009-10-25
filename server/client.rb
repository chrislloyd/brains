require 'sinatra'
require 'json'

helpers do
  def json(obj)
    content_type :json
    obj.to_json
  end

  def rand_val; [-1,1][rand(2)] end

end

post '/' do
  env = JSON.parse(params[:env])
  visible_zombies = env["visible"].select { |a| a["type"] == 'zombie' }
  p "#{visible_zombies.length} zombies spotted!"
  moves = [
    {:action => 'turn', :dir => rand(360)},
    {:action => 'move', :x => rand_val, :y => rand_val}
  ]
  
  json moves[rand(moves.size)]
end
