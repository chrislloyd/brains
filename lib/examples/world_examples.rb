require 'exemplor'
$: << File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'brains'

eg 'it should place a zombie somewhere at the top' do
  zombie = World.new(200,200).place(Zombie.new)
  
  Check(zombie)
end

eg 'it should place a human somewhere in the middle' do
  human = World.new(200,200).place(Human.new)
  
  Check(human)
end

