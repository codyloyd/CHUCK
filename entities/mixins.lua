local mixins = {}

mixins.Destructible = {
  hp = hp or 6,
  dead = false,
  hitTimer = 0,

  takeDamage = function(self, direction)
    if self.hitTimer <= 0 then
      self.hitTimer = .3
      self.hp = self.hp - 1
      -- TODO knockback
      self.vx = 900 * -direction
      self.vy = 80
    end

    if self.hp <=0 then
      -- :( 
      self.dead = true
    end
  end

}

return mixins
