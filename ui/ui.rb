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
  attr_accessor :data

  def self.window=(window); @window = window end
  def self.window; @window end

  def self.sprites
    @sprites ||=  Dir['sprites/*.png'].inject({}) do |sprites,f|
      sprite = File.basename(f,'.*').split('-')
      sprites[sprite.first] ||= {}
      sprites[sprite.first][sprite.last] = Gosu::Image.new(window, f, true)
      sprites
    end
  end

  def self.new_from_string(string)
    returning(new) do |a|
      a.data = string
    end
  end

  def data=(json)
    @data = JSON.parse(json)
  end

  def image
    self.class.sprites[data['type']][data['state']]
  end

  def draw
    image.draw_rot(data['x']*window.grid, window.height - data['y']*window.grid, 1, data['dir']) if image
  end

  def window
    self.class.window
  end

end

class Window < Gosu::Window

  attr_accessor :grid, :actors

  def initialize
    super(640, 480, false)
    self.caption = 'Brains'
    self.grid = 1
    self.actors = []
    Actor.window = self
  end

  def update
    actors.clear
    db.keys('*').each do |id|
      if raw = db[id]
        actors << Actor.new_from_string(raw)
      end
    end
  end

  def draw
    actors.each {|a| a.draw }
  end

  def button_down(id)
    close if id == Gosu::Button::KbEscape
  end
end

window = Window.new
window.show