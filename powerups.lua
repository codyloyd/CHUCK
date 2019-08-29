local class = require("lib/middleclass")
local Powerup = require("entities/Powerup")

local PowerupSpawner = class("PowerupSpawner")

function PowerupSpawner:initialize(gameMap, world)
  self.powerups = {}
  self.world = world
  self.gameMap = gameMap

  for _, p in pairs(self.gameMap.layers["powerups"].objects) do
    table.insert(self.powerups, Powerup:new({x=p.x,y=p.y, name=p.name}, self.world))
  end
end

function PowerupSpawner:update(dt) 
  for i, p in pairs(self.powerups) do
    p:update(dt)

    if p.dead then
      table.remove(self.powerups, i)
      self.world:remove(p)
    end
  end
end

function PowerupSpawner:draw()
  for _, p in pairs(self.powerups) do
    p:draw()
  end
end

return PowerupSpawner
