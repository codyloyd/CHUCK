local mixins = {}

mixins.Destructible = {
  hp = hp or 6,
  dead = false,
  hitTimer = 0,

  takeDamage = function(self, direction)
    if self.hitTimer <= 0 then
      self.hitTimer = .1
      self.hp = self.hp - 1
      -- TODO knockback
      self.vx = 1000 * -direction
      self.vy = 80
    end

    if self.hp <=0 then
      -- :( 
      self.dead = true
    end
  end

}

mixins.CanSeePlayer = {
  playerIsInRange = function(self, xRange, yRange)
    local xRange = xRange or 50
    local yRange = yRange or self.h
    local filter = function(item)
      if item.name == "PLAYER" then
        return item
      else 
        return false
      end
    end
    local l = self.x - xRange
    local t = self.y - yRange
    local w = xRange * 2
    local h = yRange * 2
    local items, len = self.world:queryRect(l,t,w,h,filter)
    if len > 0 then return items[1] else return false end
  end,

  chasePlayer = function(self, xRange, yRange)
    local player = self:playerIsInRange(xRange, yRange)
    if player then
      local direction = self.vx > 0 and 1 or -1
      local playerDirection = player.x > self.x and 1 or -1
      if playerDirection == direction and self.hitTimer <= 0 then
        self.vx = self.vx * -1
      else
      end
    end
  end
}

return mixins
