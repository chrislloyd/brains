require 'gosu'
require 'redis'
require 'json'


def returning(obj)
  yield obj
  obj
end

def db
  @redis ||= Redis.new
end

class Actor
  attr_accessor :window, :image, :stale

  attr_accessor :id, :x, :y, :dir

  def id; @id end

  def initialize(window, id, data)
    self.window, self.id = window, id
    self.image = Gosu::Image.new(window, "#{data['type']}.png", true)
    update(data)
  end

  def update(data)
    self.x, self.y, self.dir = data['x'], data['y'], data['dir']
    self.stale = false
  end

  def draw
    puts x*window.grid
    puts y*window.grid
    image.draw_rot(x*window.grid, window.height - y*window.grid, 1, dir)
    self.stale = true
  end

  def stale?
    self.stale
  end

end



class Window < Gosu::Window

  attr_accessor :grid, :actors

  def initialize
    self.grid = 5
    super(640, 480, false)

    self.caption = 'Brains'

    self.actors = {}
  end

  def update
    db.keys('*').each do |id|
      data = JSON.parse(db[id])
      if actors[id]
        actors[id].update(data)
      else
        actors[id] = Actor.new(self, id, data)
      end
    end
    actors.reject!{|_,a| a && a.stale? }
  end

  def draw
    actors.each {|_,a| a.draw }
  end

  def button_down(id)
    close if id == Gosu::Button::KbEscape
  end
end

window = Window.new
window.show