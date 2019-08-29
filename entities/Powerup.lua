local class = require("lib/middleclass")
local Entity = require("entities/Entity")

local Powerup = class("Powerup", Entity)

function Powerup:initialize(opts)
  Entity.initialize(self, opts)

  self.w = 5
  self.h = 5
  self.name=opts.name
end

function Powerup:draw()
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

return Powerup