require 'gosu'
require 'redis'
require 'json'

require 'pp'

def returning(obj)
  yield obj
  obj
end

def db
  @redis ||= Redis.new
end

class Array
  def pick
    self[rand(size)]
  end
end


class ZIndex
  LAYERS = [:world, :dead, :robot, :zombie, :overlay]

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

  def self.font
    @font ||= Gosu::Font.new(window, Gosu::default_font_name, 12)
  end

  def self.new_from_string(string)
    returning(new) do |a|
      a.data_from_string(string)
    end
  end

  def self.update_from_string(actor,string)
    if actor
      actor.update_from_string(string)
      actor
    else
      new_from_string(string)
    end
  end

  def data_from_string(string)
    @data = JSON.parse(string)
  end

  def update_from_string(string)
    @previous_data = @data
    data_from_string(string)
  end

  def changed?(key)
    @data[key] != @previous_data[key]
  end


  Deaths = [
    "%s was bitten to death.",
    "%s was et.",
    "%s's brains were yummy.",
    "The bullet bit %s",
    "Boom! Headchomp! %s!"
  ]
  
  def tell_us_the_news(hint=nil)
    return unless robot?

    if ! @previous_data
      window.news.add "#{name} joined the apocalypse."
    elsif data['state'] == 'dead' && changed?('state')
      window.news.add :death, (Deaths.pick % name)
    end
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

    draw_health if robot? && !dead?
  end

  def font
    self.class.font
  end

  def name
    @name ||= data['name'].sub(/\.local$/,'')
  end

  def draw_health
    label = "#{name} (#{data['health']})"

    label_width = font.text_width(label)
    overlay_x = x - label_width / 2
    overlay_y = y - 30

    bg_color = 0x33000000

    ldim = {
      :left => overlay_x -2,
      :top => overlay_y -2,
      :right => (x + label_width/2) + 2,
      :bottom => overlay_y + 14
    }

    window.draw_quad(
      ldim[:left], ldim[:top], bg_color,
      ldim[:right], ldim[:top], bg_color,
      ldim[:right], ldim[:bottom], bg_color,
      ldim[:left], ldim[:bottom], bg_color,
      ZIndex.for(:overlay)
    )

    font.draw(label, overlay_x, overlay_y, ZIndex.for(:overlay), 1.0, 1.0, 0xFF000000)
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

  def robot?
    data['type'] == 'robot'
  end

  def dead?
    data['state'] == 'dead'
  end
  
  def score
    data['score']
  end

end

class Console
  attr_reader :buffer

  def initialize(window,x,y,width,height)
    @window = window
    @x,@y,@width,@height = x,y,width,height
    @buffer = []
    @spacing = 20
    @limit = 5
  end

  def add(tag,msg=nil)
    tag,msg = :normal,tag unless msg

    @buffer << [tag,msg]
    if @buffer.size > @limit
      @buffer.shift
    end
  end

  def icons(called)
    @icons ||=  Dir['icons/*.png'].inject({}) do |icons,f|
      name = File.basename(f,'.png')
      icons[name.to_sym] = Gosu::Image.new(@window, f, false)
      icons
    end

    @icons[called.to_sym]
  end

  def style(name)
    @colour = 0xff000000
    @icon = nil

    case name
    when :death
      @colour = 0xffff0000
      @icon = icons(:death)
    end

    @icon ||= icons(:robot)

    yield
  end

  def draw
    @window.clip_to(@x, @y, @width, @height) do
      @buffer.reverse.each_with_index do |(tag,msg),i|
        y = @y + @spacing*i
        style(tag) do
          @icon.draw(@x,y, ZIndex.for(:overlay)) if @icon
          @window.font.draw(msg, @x+20, y, ZIndex.for(:overlay), 1, 1, @colour)
        end
      end
    end
  end

  # def draw_scores
  #   humans.each_with_index do |human, i|
  #     font.draw("#{human.name}: #{human.score}", 0, i*20, ZIndex.for(:overlay), 1.0, 1.0, 0xFF000000)
  #   end
  # end
end

class Window < Gosu::Window

  attr_accessor :grid, :actors, :news

  def initialize
    super(800, 600, false)

    self.news = Console.new(self,0,0,200,600)

    self.caption = 'Brains'
    self.grid = 1

    self.actors  = {}

    Actor.window = self
    @grass     = Gosu::Image.new(self, 'tiles/grass.png', true)
    @shrubbery = Gosu::Image.new(self, 'tiles/shrubbery.png', true)
  end
  
  def font
    @font ||= Gosu::Font.new(self, Gosu::default_font_name, 12)
  end

  def update
    unless $testing
      keys = db.keys('*')
      
      keys.each do |id|
        if raw = db[id]
          actors[id] = Actor.update_from_string(actors[id],raw)
          actors[id].tell_us_the_news
        end
      end

      (actors.keys - keys).each {|key| actors.delete(key)}
    end
  end

  def draw
    draw_scenery
    actors.each {|_,a| a.draw }
    news.draw
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
  
  def humans
    actors.select {|a| a.robot? }
  end
  

end


$testing = false

window = Window.new

if $testing
  a = Actor.new
  window.actors['122'] = a
  a.data = {
    'dir' => 90,
    'type' => 'robot',
    'state' => 'moving',

    'x' => 400,
    'y' => 300,

    'name' => 'bob',
    'health' => 10
  }
end

window.show
