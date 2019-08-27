local enemies = {}
enemies.table = {}
local Slime = require("entities/Slime")
local Wizard = require("entities/Wizard")

function spawnEnemy(x,y,direction)
  local slime = Slime:new({
      x = x,
      y = y,
    })

  -- maybe this should/could be in the initialize funciton?
  world:add(slime, slime.x, slime.y, slime.w, slime.h)
  return slime
end 

-- loads enemies from tilemap into table
for i, e in pairs(gameMap.layers["enemies"].objects) do
  table.insert(enemies.table, spawnEnemy(e.x, e.y))
end

local wiz = Wizard:new({x=650, y=100})
world:add(wiz, wiz.x, wiz.y, wiz.w, wiz.h)
table.insert(enemies.table, wiz)

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
