local class = require("lib/middleclass")
local Interactable = require("entities/Interactable")
local InteractableUi = require("UI/InteractableUi")

local InteractableSpawner = class("InteractableSpawner")

function InteractableSpawner:initialize(gameMap, world, gameState, uiStack)
  self.world = world
  self.gameMap = gameMap
  self.gameState = gameState
  self.uiStack = uiStack

  self.interactables = {}
  if(self.gameMap.layers["interactables"]) then
    for _, inter in pairs(self.gameMap.layers["interactables"].objects) do
      local i = Interactable:new({
        x=inter.x,
        y=inter.y, 
        h=inter.height, 
        w=inter.width, 

        name=inter.name,
        text=inter.properties.text,
        event=inter.properties.event,
        data=inter.properties.data
      }, self.world) 

      table.insert(self.interactables, i)
    end
  end
end

local function InteractableFilter(item)
  if item.class and item.class.name ~= "Player" then 
    return nil 
  end

  return "cross"
end

function InteractableSpawner:update(dt) 
  for _, inter in pairs(self.interactables) do
    local items, len = self.world:queryRect(inter.x,inter.y,inter.w,inter.h, InteractableFilter)
    if len > 0 and not inter.interacting then
      inter.interacting = true
      table.insert( self.uiStack, InteractableUi.new(self.uiStack, "test", nil, {x=inter.x, y=inter.y}))
    end

    if len == 0 then
      inter.interacting = false
    end
  end
end

function InteractableSpawner:draw()
end

return InteractableSpawner
