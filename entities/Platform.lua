local class = require("lib/middleclass")
local Entity = require("entities/Entity")

local Platform = class("Platform", Entity)

function Platform:initialize(opts, world)
  Entity.initialize(self, opts, world)

  self.causesDamage = false

  -- Must be nonzero
  self.w = self.w > 0 and self.w or 1
  self.h = self.h > 0 and self.h or 1

  -- Prevent it from moving
  self.maxVx = 0
  self.maxVy = 0
  self.jumpThrough = opts.jumpThrough or false

  world:add(self, self.x, self.y, self.w, self.h)
end

function Platform:update(dt)
  -- No-op, platforms don't do anything
end

return Platform