local mixins = {}

mixins.Destructible = {
  hp = hp or 2,
  dead = false,
  takeDamage = function(self)
    print('HITTTTTTT')
    print(self.hp)
    self.hp = self.hp - 1
    if self.hp <=0 then
      -- :( 
      self.dead = true
    end
  end
}

return mixins
