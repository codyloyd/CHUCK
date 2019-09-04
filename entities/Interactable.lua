local class = require("lib/middleclass")
local Entity = require("entities/Entity")

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
end

return Interactable
