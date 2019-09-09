local class = require("lib/middleclass")

local Slime = require("entities/Slime")
local Wizard = require("entities/Wizard")
local Baddie = require("entities/Baddie")
local Skeleton = require("entities/Skeleton")

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
    elseif e.name == "skeleton" then
      table.insert(self.enemies, Skeleton:new({x=e.x, y=e.y}, self.world))
    end
  end

end

function EnemySpawner:update(dt)
  for i, e in ipairs(self.enemies) do
    e:update(dt)
    if e.projectiles then
      for i, p in ipairs(e.projectiles) do
        p:update(dt)
        if p:shouldCleanUp() == true then
          table.remove(e.projectiles, i)
          self.world:remove(p)
        end
      end
    end
    if e.shouldCleanUp and e:shouldCleanUp() == true then
      table.remove(self.enemies, i)
      self.world:remove(e)
    end
  end
end

function EnemySpawner:draw()
  for i, e in ipairs(self.enemies) do
    if e.hitTimer and e.hitTimer > 0 then
      for i=1,3 do 
        love.graphics.setColor(1,0,0)
        e.animation:draw(e.spritesheet,math.ceil(e.x + e.w/2 + math.random(-4,4)),math.ceil(e.y + math.random(-4,4)),nil,e.direction,1,8,8)
      end
      love.graphics.setColor(1,0,0,.7)
    else 
      love.graphics.setColor(1,1,1)
    end
    e.animation:draw(e.spritesheet,math.ceil(e.x + e.w/2),math.ceil(e.y),nil,e.direction,1,8,8)
    love.graphics.setColor(1,1,1)
    if e.projectiles then
      for _, p in pairs(e.projectiles) do
        p:draw()
      end
    end
  end
end


return EnemySpawner
