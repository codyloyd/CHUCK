local class = require("lib/middleclass")
local Interactable = require("entities/Interactable")

local InteractableSpawner = class("InteractableSpawner")


function InteractableSpawner:eventHandlerFactory()
  local function eventHandler(event, data)
    if event == 'checkpoint' then
      local player = self.gameState.player
      player.health = player.maxHealth
      player.spawn = {
        scene=self.gameState.scene.current,
        spawnPoint=data
      }
    elseif event == 'open-door' then
      self.event('open-door')
    end
  end

  return eventHandler
end

function InteractableSpawner:initialize(gameMap, world, gameState, uiStack, eventHandler, player)
  self.world = world
  self.gameMap = gameMap
  self.gameState = gameState
  self.uiStack = uiStack
  self.event = eventHandler
  self.player = player

  local mapInteractables = self.gameState.interactables[self.gameState.scene.current] or {}

  self.interactables = {}
  if(self.gameMap.layers["interactables"]) then
    for _, inter in pairs(self.gameMap.layers["interactables"].objects) do
      if not mapInteractables[inter.name] then
        local i = Interactable:new({
          x=inter.x,
          y=inter.y, 
          h=inter.height, 
          w=inter.width, 

          name=inter.name,
          text=inter.properties.text,
          event=inter.properties.event,
          data=inter.properties.data,
          repeatDelay=inter.properties.repeatDelay,
          oneTime=inter.properties.oneTime,

          uiStack=self.uiStack,
          eventHandler=self:eventHandlerFactory(),
          gameState=self.gameState
        }, self.world) 

        table.insert(self.interactables, i)
      end
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
    -- Update Interactable timers
    inter:update(dt)

    -- Check if in range
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
