local class = require("lib/middleclass")
local Powerup = require("entities/Powerup")

local PowerupSpawner = class("PowerupSpawner")

local function spawnPowerup(x,y, name)
  local powerup = Powerup:new({
    x=x,
    y=y,
    name=name
  })

  return powerup
end

function PowerupSpawner:initialize(gameMap)
  self.powerups = {}

  for _, p in pairs(gameMap.layers["powerups"].objects) do
    table.insert(self.powerups, spawnPowerup(p.x,p.y, p.name))
  end
end

function PowerupSpawner:update(dt) 
  for i, p in pairs(self.powerups) do
    p:update(dt)

    if p.dead then
      table.remove(self.powerups, i)
      world:remove(p)
    end
  end
end

function PowerupSpawner:draw()
  for _, p in pairs(self.powerups) do
    p:draw()
  end
end

return PowerupSpawner
