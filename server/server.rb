$LOAD_PATH << 'lib'

require 'brains'
require 'boot'

LOOP_TIME = 1/30.0

loop do
  old_time = Time.now
  heroes.update! if production?

  world.tick!
  world.clean

  world.spawn

  world.update
  world.save

  loop_time = Time.now - old_time
  sleep LOOP_TIME - loop_time if loop_time < LOOP_TIME
end
