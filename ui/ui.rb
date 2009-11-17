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
  LAYERS = [:world, :dead, :robot, :zombie]

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
    image.draw_rot(x, y, z, data['dir'])

    if data['type'] == 'robot' && data['state'] == 'attacking'
      x2 = x + Gosu.offset_x(data['dir'], 200)
      y2 = y + Gosu.offset_y(data['dir'], 200)

      window.draw_line(x, y, 0x00FF0000, x2, y2, 0x99FF0000)
    end
  end

  def x
    data['x']*window.grid
  end

  def y
    window.height - data['y']*window.grid
  end

  def z
    (data['state'] == 'dead') ? ZIndex.for(:dead) : ZIndex.for(data['type'].to_sym)
  end

  def window
    self.class.window
  end
  
  def zombie?
    data['type'] == 'zombie'
  end
  
  def method_missing(method_name, *args)
    data[method_name.to_s]
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
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
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
    draw_text
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

  def draw_text
    brainbots.each do |bb|
      health = bb.health > 0 ? bb.health : "DEAD"
      @font.draw("#{bb.name}: #{health}", 10, 10, 10, 1.0, 1.0, 0xffff0000)
    end
  end
  
  def brainbots
    actors.reject { |a| a.zombie? }
  end
end

window = Window.new
window.show