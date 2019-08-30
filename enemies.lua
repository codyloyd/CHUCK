local class = require("lib/middleclass")

local Slime = require("entities/Slime")
local Wizard = require("entities/Wizard")
local Baddie = require("entities/Baddie")

local EnemySpawner = class("EnemieSpawner")

function EnemySpawner:initialize(gameMap, world) 
  self.enemies = {}
  self.gameMap = gameMap
  self.world = world

  -- loads enemies from tilemap into table
  for i, e in pairs(self.gameMap.layers["enemies"].objects) do
    -- table.insert(self.enemies, spawnEnemy(e.x, e.y))
    if e.name == "slime" then
      table.insert(self.enemies, Slime:new({x=e.x, y=e.y}, self.world))
    elseif e.name == "wizard" then
      table.insert(self.enemies, Wizard:new({x=e.x, y=e.y}, self.world))
    elseif e.name == "baddie" then
      table.insert(self.enemies, Baddie:new({x=e.x, y=e.y}, self.world))
    end
  end

end

function EnemySpawner:update(dt)
  for i, e in ipairs(self.enemies) do
    e:update(dt)
    if e.dead == true then
      table.remove(self.enemies, i)
      self.world:remove(e)
    end
  end
end

function EnemySpawner:draw()
  for i, e in ipairs(self.enemies) do
    e.animation:draw(e.spritesheet,math.ceil(e.x + e.w/2),math.ceil(e.y),nil,e.direction,1,8,8)
  end
end


return EnemySpawner
