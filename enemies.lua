local enemies = {}
enemies.table = {}
local Slime = require("entities/Slime")
local Wizard = require("entities/Wizard")
local Baddie = require("entities/Baddie")

function spawnEnemy(x,y,direction)
  local slime = Slime:new({
      x = x,
      y = y,
    })

  return slime
end 

-- loads enemies from tilemap into table
for i, e in pairs(gameMap.layers["enemies"].objects) do
  table.insert(enemies.table, spawnEnemy(e.x, e.y))
end

local wiz = Wizard:new({x=650, y=100})
table.insert(enemies.table, wiz)

local baddie = Baddie:new({x=550, y=100})
world:add(baddie, baddie.x, baddie.y, baddie.w, baddie.h)
table.insert(enemies.table, baddie)

function enemies:update(dt)
  for i, e in ipairs(self.table) do
    e:update(dt)
  end
end

function enemies:draw()
  for i, e in ipairs(self.table) do
    e.animation:draw(e.spritesheet,math.ceil(e.x + e.w/2),math.ceil(e.y),nil,e.direction,1,8,8)
  end
end


return enemies
