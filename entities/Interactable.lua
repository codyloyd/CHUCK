local class = require("lib/middleclass")
local Entity = require("entities/Entity")
local InteractableUi = require("UI/InteractableUi")

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
  self.uiStackLocation = #self.uiStack + 1
  self.repeatDelay = opts.repeatDelay

  self.eventHandler = opts.eventHandler

  self.textLocation = {
    x = self.x,
    y = self.y,
    limit = self.w * 2 -- Not sure why we need to multiply by 2
  }
end

function Interactable:update(dt)
end

function Interactable:sendEvent()
  -- Wrapping function to keep proper `self` context
  return function()
    self.eventHandler(self.event, self.data)
  end
end

function Interactable:interact()
  if not self.interacting then
    self.interacting = true
    table.insert( self.uiStack, InteractableUi.new(self.uiStack, self.text, self:sendEvent(), self.textLocation))
  end
end

function Interactable:noInteract()
  if self.interacting then
    self.interacting = false
    table.remove(self.uiStack, self.uiStackLocation)
  end
end

return Interactable
