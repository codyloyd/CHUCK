local class = require("lib/middleclass")
local Interactable = require("entities/Interactable")

local InteractableSpawner = class("InteractableSpawner")


function InteractableSpawner:eventHandlerFactory()
  local function eventHandler(event, data)
    if event == 'checkpoint' then
      self.gameState.player.spawn = {
        scene=self.gameState.scene.current,
        spawnPoint=data
      }
    end
  end

  return eventHandler
end

function InteractableSpawner:initialize(gameMap, world, gameState, uiStack, player)
  self.world = world
  self.gameMap = gameMap
  self.gameState = gameState
  self.uiStack = uiStack
  self.player = player

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
        data=inter.properties.data,
        uiStack=self.uiStack,
        eventHandler=self:eventHandlerFactory()
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
      inter:interact()
    end

    if len == 0 then
      inter:noInteract()
    end
  end
end

function InteractableSpawner:draw()
end

return InteractableSpawner
