#!/usr/bin/env ruby
require 'RMagick'
require 'json'

WIDTH = 240
HEIGHT = 135

Sprites = {
  'red_robot' => ->(x,y) {
    rect = Magick::Draw.new
    rect.stroke('black').stroke_width(1)
    rect.fill('#F00')
    rect.rectangle(x, y,  x+1,y+1)
    rect
  },

  'blue_robot' => ->(x,y) {
    rect = Magick::Draw.new
    rect.stroke('black').stroke_width(1)
    rect.fill('#00F')
    rect.rectangle(x, y,  x+1,y+1)
    rect
  }
}

canvas = Magick::ImageList.new
canvas.ticks_per_second = 1

STDIN.readlines.each do |line|
  cmd, args = line.strip.split(' ', 2)
  case cmd
  when 'TICK'
    canvas.new_image(WIDTH*2, HEIGHT*2)

    JSON.parse(args).each do |entity|
      sprite = Sprites.fetch(entity[0]).call(entity[1], entity[2])
      sprite.draw(canvas)
    end
  end
end

canvas.write(ARGV.first)
