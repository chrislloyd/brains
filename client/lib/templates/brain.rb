require 'sinatra'
require 'brains/helpers'

brain :name => "Your name here"

post '/' do
  if roll_dice(3)
    case rand(3)
    when 0
      move! rand_x, rand_y
    when 1
      turn! rand(360)
    when 2
      shoot!
    end
  else
    rest!
  end
end
