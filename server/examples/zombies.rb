require 'exemplor'
require 'mash'
$:.push File.dirname(File.expand_path(__FILE__)) + '/../lib'
require 'brains'

eg.helpers do

  def randomly_place(n, type, lower, upper)
    Array.new(n) do
      returning(type.new) do |obj|
        obj.x, obj.y = lower+rand(upper), lower+rand(upper)
      end
    end
  end

end

eg.setup do
  @z = Brains::Zombie.new
end

eg 'Starts idle' do
  Check(@z.idle?).is(true)
end

eg 'measuring' do
  player = {:x => 3, :y => 4}.to_mash
  @z.x, @z.y = 0, 0
  Check(@z.distance_to(player)).is(5)
end

eg 'targeting' do
  humans = randomly_place(10, Brains::Human, 10, 50)
  zombies = randomly_place(10, Brains::Zombie, 10, 50)
  close_human = Brains::Human.new
  close_human.x, close_human.y = 1, 1
  humans << close_human
  @z.x, @z.y = 0, 0

  @z.find_target!(humans + zombies)
  Check(@z.target).is(close_human)
end

# eg 'Updates itself' do
#   @z.update :visible => Array.new(5) do
#     z = Brains::Zombie.new
#     z.x, z.y = rand(20), rand(20)
#   end
#   Check(@z.state)
# end
