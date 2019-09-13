local class = require("lib/middleclass")
local Entity = require("entities/Entity")

local Powerup = class("Powerup", Entity)

function Powerup:initialize(opts, world)
  Entity.initialize(self, opts)

  self.w = 15
  self.h = 15
  self.causesDamage = false
  self.name=opts.name

  -- Animation
  self.originX = opts.x
  self.originY = opts.y
  self.spritesheet=love.graphics.newImage('assets/POWERUP.png')
  self.healthspritesheet=love.graphics.newImage('assets/BIGHEALTH.png')
  self.movingUp=true
  self.noClip = true

  world:add(self, self.x, self.y, self.w, self.h)
end

function Powerup:update(dt)
  if self.movingUp then
    self.y = self.y - 0.6 * dt
    if self.y < self.originY - 1.2 then self.movingUp = false end
  else
    self.y = self.y + 0.6 * dt
    if self.y > self.originY then self.movingUp = true end
  end
end

function Powerup:draw()
  if (string.find(self.name, "healthIncrease")) then
    love.graphics.draw(self.healthspritesheet, self.x, self.y, 0)
  else
    love.graphics.draw(self.spritesheet, self.x, self.y, 0)
  end
end

function Powerup:collected()
  self.dead = true
end

return Powerup
