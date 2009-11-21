class Tank < Zombie
  def damage; 15 end
  def range; 20 end
  def eyesight; 10 end
  
  def initialize
    super
    self.health = 500
  end
end