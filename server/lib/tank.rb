class Tank < Zombie
  damage { 15 + (rand(3).zero? ? 60 : 0)}
  range 20
  speed 0.8
  initial_health 600
end
