require 'brains/helpers'

helpers do

  def quiver!
    if roll_dice(3)
      if roll_dice(2)
        move! rand_x, rand_y
      else
        turn! rand(360)
      end
    else
      rest!
    end
  end

end

post '/' do
  quiver!
end

get('/name') {'Scaredy Cat'}
