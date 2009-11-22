$LOAD_PATH << 'lib'

LOOP_TIME = 1/30.0

require 'brains'
require 'boot'

if env.production?
  require 'browser'
  logger.info 'watching bonjour'
  heroes.watch!
else
  world.add(Robot.new('http://localhost:4567', 'Hans'))
end

EM.run do

  EM.add_periodic_timer(2) do
    heroes.update! if env.production?
  end

  EM.add_periodic_timer(LOOP_TIME) do
    world.tick!
    world.spawn

    world.update

    world.save
  end
end
