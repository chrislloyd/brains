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

class ZIndex
  LAYERS = [:world, :robot, :zombie]

  def self.for(type); LAYERS.index(type) end
end

class Actor
  attr_accessor :data

  def self.window=(window); @window = window end
  def self.window; @window end

  def self.sprites
    @sprites ||=  Dir['sprites/*.png'].inject({}) do |sprites,f|
      sprite = File.basename(f,'.*').split('-')
      sprites[sprite.first] ||= {}
      sprites[sprite.first][sprite.last] = Gosu::Image.new(window, f, false)
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
    image.draw_rot(data['x']*window.grid, window.height - data['y']*window.grid, ZIndex.for(data['type'].to_sym), data['dir']) if image
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
    @grass = Gosu::Image.new(self, 'tiles/grass.png', true)
    @shrubbery = Gosu::Image.new(self, 'tiles/shrubbery.png', true)
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
    draw_scenery
    actors.each {|a| a.draw }
  end

  def button_down(id)
    close if id == Gosu::Button::KbEscape
  end

  # private

  def tile_positions
    w, h = @grass.width, @grass.height
    @tile_positions ||= {
      :x => (0...width).to_a.inject([]) {|a,x| a << x if x % w == 0; a},
      :y => (0...height).to_a.inject([]) {|a,y| a << y if y % h == 0; a}
    }
  end

  def map
    @map ||= tile_positions[:y].map do |y|
      tile_positions[:x].map do |x|
        {
          :x => x,
          :y => y,
          :tile => (rand(32) % 32 == 0) ? @shrubbery : @grass
        }
      end
    end
  end

  def draw_scenery
    map.each do |row|
      row.each do |col|
        col[:tile].draw(col[:x], col[:y], ZIndex.for(:world))
      end
    end
  end

end

window = Window.new
window.show