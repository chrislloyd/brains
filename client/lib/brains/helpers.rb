require 'sinatra'
require 'json'

helpers do
  def env
    @payload ||= JSON.parse(request.body.read)
  end

  def json(obj)
    content_type :json
    obj.to_json
  end

  def direction_to(x1, y1, x2, y2, y)
    (Math.atan2(x1-x2, y1-y2).to_deg + 180) % 360
  end

  def roll_dice(sides=6)
    rand(sides).zero?
  end
 
  def rand_x
    [-1,1][rand(2)]
  end

  alias :rand_y, :rand_x

  def idle!
    json :action => :idle
  end

  def shoot!
    json :action => :attack
  end

  def move!(x,y)
    json :action => :move, :x => x, :y => y
  end

  def turn!(dir)
    json :action => :turn, :dir => dir
  end

end
