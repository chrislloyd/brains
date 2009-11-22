$LOAD_PATH << 'lib'

LOOP_TIME = 1/30.0

require 'brains'
require 'boot'

EM.run do
  world.add(Robot.new('http://localhost:4567', 'Hans')) unless env.production?

  EM.add_periodic_timer(LOOP_TIME) do
    heroes.update! if env.production?

    world.tick!
    world.clean

    world.spawn

    world.update
    world.save
  end
end
