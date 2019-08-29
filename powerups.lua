local powerups = {}
powerups.table = {}

local Powerup = require("entities/Powerup")

function spawnPowerup(x,y, name)
  local powerup = Powerup:new({
    x=x,
    y=y,
    name=name
  })

  return powerup
end

for _, p in pairs(gameMap.layers["powerups"].objects) do
  table.insert(powerups.table, spawnPowerup(p.x,p.y, p.name))
end

function powerups:draw()
  for _, p in pairs(self.table) do
    p:draw()
  end
end

return powerups
