require 'json'
require 'brains/bonjour/advertiser'

module Math
  def self.min(x,y)
    x < y ? x : y
  end
  def self.max(x,y)
    x > y ? x : y
  end
end

class Numeric
  def to_deg
    self * (180 / Math::PI)
  end
  def to_rad
    self * (Math::PI / 180)
  end
  def near?(other, precision=1)
    (other - precision) <= self && self <= (other + precision)
  end
end

def brain(options)
  Advertiser.new(options).go!
end

helpers do
  def env
    @payload ||= JSON.parse(request.body.read)
  end

  def json(obj)
    content_type :json
    obj.to_json
  end

  def direction(x1, y1, x2, y2)
    (Math.atan2(x1-x2, y1-y2).to_deg + 180) % 360
  end

  alias :direction_to :direction

  def distance(x1, y1, x2, y2)
    Math.sqrt(((x1 - x2).abs ** 2) + ((y1 - y2).abs ** 2))
  end

  alias :distance_to :distance

  def roll_dice(sides=6)
    rand(sides).zero?
  end

  def rand_x
    [-1,1][rand(2)]
  end

  alias :rand_y :rand_x

  def rest!
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
