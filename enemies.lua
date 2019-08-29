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
    table.insert(self.enemies, Slime:new({x=e.x, y=e.y}, self.world))
  end

  local wiz = Wizard:new({x=650, y=100}, self.world)
  table.insert(self.enemies, wiz)

  local baddie = Baddie:new({x=550, y=100}, self.world)
  table.insert(self.enemies, baddie)
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
