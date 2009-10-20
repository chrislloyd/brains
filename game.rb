require 'gosu'
require 'redis'
require 'json'

$r = Redis.new

class Actor
  attr_accessor :id, :x, :y, :dir
  def id; @id end
  def initialize(window, id)
    @image = Gosu::Image.new(window, 'zombie.png', true)
    @id = id
  end

  def update
    data = JSON.parse($r[id])
    self.x = data['x'].abs
    self.y = data['y'].abs
    self.dir = data['dir']
  end

  def draw
    @image.draw_rot(x * 20, y * 20, 1, dir * 45)
  end
end



class Window < Gosu::Window

  def initialize
    super(640, 480, false)
    self.caption = 'Brains'

    @actors = $r.keys('*').map do |k|
      a = Actor.new(self, k)
      a.update
      a
    end

  end

  def update
    @actors.each {|a| a.update }
  end

  def draw
    @actors.each {|a| a.draw }
  end

  def button_down(id)
    close if id == Gosu::Button::KbEscape
  end
end

window = Window.new
window.show