local mixins = {}

mixins.Destructible = {
  hp = hp or 6,
  dead = false,
  hitTimer = 0,

  takeDamage = function(self)
    if self.hitTimer <= 0 then
      self.hitTimer = .2
      self.hp = self.hp - 1
      self.vy = 30
      print(self.hp)
    end
    if self.hp <=0 then
      -- :( 
      self.dead = true
    end
  end,

  destructibleUpdate = function(self, dt)
    if self.hitTimer > 0 then
      print(self.hp)
      self.hitTimer = self.hitTimer - dt 
    end
  end
}

return mixins
