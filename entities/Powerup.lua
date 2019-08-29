local class = require("lib/middleclass")
local Entity = require("entities/Entity")

local Powerup = class("Powerup", Entity)

function Powerup:initialize(opts, world)
  Entity.initialize(self, opts)

  self.w = 5
  self.h = 5
  self.causesDamage = false
  self.name=opts.name

  world:add(self, self.x, self.y, self.w, self.h)
end

function Powerup:update(dt)
  return
end

function Powerup:draw()
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

function Powerup:collected()
  self.dead = true
end

return Powerup