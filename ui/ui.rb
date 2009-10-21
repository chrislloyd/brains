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

  def initialize(window, id, raw)
    self.window, self.id = window, id
    self.image = Gosu::Image.new(window, 'zombie.png', true)
    update(raw)
  end



  def update(raw)
    data = JSON.parse(raw)
    self.x, self.y, self.dir = data['x'], data['y'], data['dir']
    self.stale = false
  end

  def draw
    image.draw_rot(x*window.grid, y*window.grid, 1, dir * 45)
    self.stale = true
  end

  def stale?
    self.stale
  end

end



class Window < Gosu::Window

  attr_accessor :grid, :actors

  def initialize
    self.grid = 20
    super(32*grid, 24*grid, false)

    self.caption = 'Brains'

    self.actors = {}
  end

  def update
    db.keys('*').each do |id|
      if actors[id]
        actors[id].update(db[id])
      else
        actors[id] = Actor.new(self, id, db[id])
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