class Tank < Zombie
  damage { 15 + (rand(3).zero? ? 60 : 0)}
  range 20
  speed 0.6
  initial_health 500
end
