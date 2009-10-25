require 'exemplor'
$: << File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'brains'

$world = World.new

eg.setup do
  $world.actors = []
end

eg.helpers do
  def human(x, y)
    returning(Human.new) { |h| h.x = x; h.y = y; h.dir = 0; $world.actors << h }
  end
  def zombie(x, y)
    returning(Zombie.new) { |z| z.x = x; z.y = y; z.dir = 0; $world.actors << z }
  end
end

eg 'it identifies the nearest target and aligns towards it' do
  z = zombie(0,0)
  
  z.think 'visible' => [human(-1,-1), human(100,100)]
  
  Check(z.dir).is(225)
end

eg 'it charges/lumbers at the nearest target when it is aligned to it' do
  z = zombie(0,0)
  z.dir = 0
  z.think 'visible' => [human(0,10), human(100,100)]
  
  Check(z.x).is(0)
  Check(z.y).is(1)
end