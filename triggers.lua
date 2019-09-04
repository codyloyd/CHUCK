
local class = require("lib/middleclass")
local Trigger = require("entities/Trigger")

local TriggerSpawner = class("TriggerSpawner")

function TriggerSpawner:initialize(gameMap, world, gameState)
  self.world = world
  self.gameMap = gameMap
  self.gameState = gameState

  self.triggers = {}
  if(self.gameMap.layers["triggers"]) then
    for _, trig in pairs(self.gameMap.layers["triggers"].objects) do
      local t = Trigger:new({
        x=trig.x,
        y=trig.y, 
        h=trig.height, 
        w=trig.width, 
        name=trig.name,
        type=trig.properties.type,
        action=trig.properties.action
      }, self.world) 

      table.insert(self.triggers, t)
    end
  end
end

local function triggerFilter(item)
  if item.class and item.class.name ~= "Player" then 
    return nil 
  end

  return "cross"
end

function TriggerSpawner:update(dt) 
  for _, trig in pairs(self.triggers) do
    local items, len = self.world:queryRect(trig.x,trig.y,trig.w,trig.h, triggerFilter)
    if len > 0 then
      if trig.type == "change-scene" then
        self.changeSceneCallback(trig.action)
      elseif trig.type == "checkpoint" then
        self.gameState.player.spawn.scene = self.gameState.scene.current
        self.gameState.player.spawn.spawnPoint = trig.action
      end
    end
  end
end

function TriggerSpawner:draw()
  for _, p in pairs(self.triggers) do
    p:draw()
  end
end

return TriggerSpawner