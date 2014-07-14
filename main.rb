#!/usr/bin/env ruby
require 'securerandom'
require 'json'
require 'time'

TPS = 1
MAX_TICKS = TPS * 10 # 10s
WIDTH = 640
HEIGHT = 480

def pick_game
  'localhost:6666'
end

def log(cmd, args=[])
  puts [cmd.to_s.upcase, *args].join(' ')
end

# --

def join!(id, url)
  log(:join, [id, url])
  {id: id, url: url}
end

def start!(game_url, round_id, robots)
  draw_calls = # send_start_game_to_game(url, [id, robots])
    [
      [:red_robot, rand(WIDTH), rand(HEIGHT)],
      [:blue_robot, rand(WIDTH), rand(HEIGHT)]
    ]

  log(:start, [game_url, round_id])

  draw_calls
end

def flush_draw_actions!(draw_actions)
  draw_actions.each do |draw_call|
    log(:draw, draw_call)
  end
end

def frame!(tick)
  log(:frame, [tick])
end

def update!(robot, tick)
  robot_state = {} # fetch_robot_state(game, robot[:id])
  actions = [[:say, 'Hello World']] # call_robot(robot[:url], tick, robot_state)
  log(:update, [robot[:id], robot_state.to_json, actions.to_json])

  actions
end

# --

def main
  # Arguments
  game = pick_game
  round_id = SecureRandom.uuid

  # Initialize robots
  robots = []
  robots << join!('robot_a', 'https://localhost:5001')
  robots << join!('robot_b', 'https://localhost:5002')

  # Tell game to start robots
  # draw_actions = []
  draw_actions = start!(game, round_id, robots)

  tick = 0
  playing = true


  while playing && tick < MAX_TICKS
    frame!(tick)

    robots.each_with_object([]) do |robot, action_pipeline|
      actions = update!(robot, tick)
      action_pipeline << [robot, actions]
    end

    # perform_actions!(game, action_pipeline)
    flush_draw_actions!(draw_actions)
    draw_actions = []

    tick += 1
  end


end

main()
