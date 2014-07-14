#!/usr/bin/env ruby
require 'securerandom'
require 'json'
require 'time'

TPS = 1
MAX_TICKS = TPS * 10 # 10s
WIDTH = 240
HEIGHT = 135

class Actor < Struct.new(:id, :url)
end

class Game < Actor
  attr_accessor :robots
  def start(robots)  # POST /
    @robots = robots
    @pos = {
      'robot_a' => {x: 10, y: 10},
      'robot_b' => {x: 40, y: 40}
    }
  end

  def state # GET /state
    [
      ['red_robot', @pos['robot_a'][:x], @pos['robot_a'][:y]],
      ['blue_robot', @pos['robot_b'][:x], @pos['robot_b'][:y]]
    ]
  end

  def localstate(robot) # GET /:robot
    {}
  end

  def process_action(robot, action) # PATCH /
    case action[0]
    when :right
      @pos[robot.id][:x] += 1
    when :down
      @pos[robot.id][:y] += 1
    when :up
      @pos[robot.id][:y] -= 1
    when :left
      @pos[robot.id][:x] -= 1
    end
  end
end

class Robot < Actor
  def think(game, frame, state)
    [[:down], [:right]]
  end
end

class Salmon < Robot
  def think(game, frame, state)
    [[:up], [:left]]
  end
end

# --

def save(action, *args)
  puts [action.to_s.upcase, *args].join(' ')
end

# --

# Initialize
game = Game.new('game_id', 'localhost:6666')
a = Robot.new('robot_a', 'https://localhost:5001')
b = Salmon.new('robot_b', 'https://localhost:5002')

game.start([a, b])
save :start, game.id, game.url, *game.robots.map {|r| [r.id, r.url] }.flatten

tick = 0
playing = true
save :tick, game.state.to_json

while playing && tick < MAX_TICKS
  game.robots.each do |robot|
    actions = robot.think(game.id, tick, game.localstate(robot))
    actions.each do |action|
      game.process_action(robot, action)
    end
  end

  tick += 1
  save :tick, game.state.to_json
end

save :end, game.robots.sample.id
