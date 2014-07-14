#!/usr/bin/env ruby
require 'RMagick'

WIDTH = 640
HEIGHT = 480

canvas = Magick::ImageList.new


sprite_library = {
  'red_robot' => ->(x,y) {
    rect = Magick::Draw.new
    rect.stroke('black').stroke_width(1)
    rect.fill('#F00')
    rect.rectangle(x, y,  x+1,y+1)
  },

  'blue_robot' => ->(x,y) {
    rect = Magick::Draw.new
    rect.stroke('black').stroke_width(1)
    rect.fill('#00F')
    rect.rectangle(x, y,  x+1,y+1)
  }
}

STDIN.readlines.each do |line|
  cmd = line.split(' ')
  case cmd[0]
  when 'DRAW'
    sprite = sprite_library.fetch(cmd[1]).call(cmd[2].to_i, cmd[3].to_i)
    sprite.draw(canvas)
  when 'FRAME'
    if canvas.any?
      canvas.append(canvas.cur_image.dup)
    else
      canvas.new_image(WIDTH, HEIGHT) { self.background_color = 'white' }
    end
  end
end

canvas.write(ARGV.first)
