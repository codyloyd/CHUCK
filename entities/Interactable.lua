local class = require("lib/middleclass")
local Entity = require("entities/Entity")
local InteractableUi = require("UI/InteractableUi")
local particlesController = require("particlesController")

local Interactable = class("Interactable", Entity)

function Interactable:initialize(opts, world)
  Entity.initialize(self, opts)
  self.noClip = true

  self.name = opts.name
  self.type = opts.type
  self.text = opts.text
  self.event = opts.event
  self.data = opts.data
  self.interacting = false
  self.uiStack = opts.uiStack
  self.uiStackLocation = nil
  self.repeatDelay = opts.repeatDelay
  self.repeatTimer = 0
  self.ranAction = false
  self.gameState = opts.gameState
  self.oneTime = opts.oneTime

  self.eventHandler = opts.eventHandler

  self.textLocation = {
    x = self.x,
    y = self.y,
    limit = self.w * 2 -- Not sure why we need to multiply by 2
  }

  if not self.gameState.interactables[self.gameState.scene.current] then 
    self.gameState.interactables[self.gameState.scene.current] = {}
  end

end

function Interactable:update(dt)
  if self.repeatDelay and self.ranAction and not self.oneTime then
    if self.repeatTimer <= 0 then
      self.ranAction = false
      self:showText()
    else
      self.repeatTimer = self.repeatTimer - dt
    end
  end
end

function Interactable:sendEvent()
  -- Wrapping function to keep proper `self` context
  return function()
    if not self.ranAction then
      if self.oneTime then
        self.gameState.interactables[self.gameState.scene.current][self.name] = true
      end
      print(self.event)

      self.eventHandler(self.event, self.data)
      particlesController:createFirework(self.x + self.w/2, self.y + self.h/2 - 3)
      self.repeatTimer = self.repeatDelay
      self.ranAction = true
      self:removeText()
    end
  end
end

function Interactable:removeText()
  if self.uiStackLocation then
    table.remove(self.uiStack, self.uiStackLocation)
    self.uiStackLocation = nil
  end
end

function Interactable:showText()
  if self.uiStackLocation == nil and self.interacting then
    table.insert( self.uiStack, InteractableUi.new(self.uiStack, self.text, self:sendEvent(), self.textLocation))
    self.uiStackLocation = #self.uiStack
  end
end


function Interactable:interact()
  if not self.interacting and not self.ranAction then
    self.interacting = true
    self:showText()
  end
end

function Interactable:noInteract()
  if self.interacting then
    self.interacting = false
    self:removeText()
  end
end

return Interactable
