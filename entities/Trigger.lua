local class = require("lib/middleclass")
local Entity = require("entities/Entity")

local Trigger = class("Trigger", Entity)

function Trigger:initialize(opts, world)
  Entity.initialize(self, opts)

  self.type = opts.type
  self.action = opts.action
  self.name = opts.name
  self.noClip = true
end

return Trigger