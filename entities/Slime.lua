local class = require('lib/middleclass')
local Entity = require('entities/Entity')
local Slime = class('Slime', Entity)

function Slime:initialize(opts)
  Entity.initialize(self, opts)
  self.vx = 30
  self.w = 8
  self.h = 8
  self.spritesheet = love.graphics.newImage('SLIME.png')
  self.animationGrid = anim8.newGrid(16,16,64,64)
  self.animation = anim8.newAnimation(self.animationGrid('1-4',1),.2)
end

function Slime:update(dt)
  -- just call Entity.update for default behavior
  -- remove and override for custom behavior
  Entity.update(self, dt)
end

return Slime
