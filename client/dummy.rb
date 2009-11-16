require 'sinatra'
require 'json'

require '../server/lib/core_ext'

helpers do
  def json(obj)
    content_type :json
    obj.to_json
  end

  def env
    @payload ||= JSON.parse(request.body.read)
  end

  def rand_move
    [-1,1][rand(2)]
  end

  def direction_to(actor)
    dx = env['x'] - actor['x']
    dy = env['y'] - actor['y']

    (Math.atan2(dx, dy).to_deg + 180) % 360
  end

end

post '/' do
  env['visible'].reject! {|a| a['state'] == 'dead'}

  if rand(4) == 0
    if env['visible'].empty?
      json :action => 'turn', :dir => (env['dir'] + 10)
    else
      dir = direction_to(env['visible'].first)
      if (dir - env['dir']).abs < 10
        json :action => 'attack'
      else
        json :action => 'turn', :dir => dir
      end
    end
  else
    json :action => 'idle'
  end
end
