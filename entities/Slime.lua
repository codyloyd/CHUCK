local class = require('lib/middleclass')
local Entity = require('entities/Entity')
local Slime = class('Slime', Entity)

function Slime:initialize(opts)
  Entity.initialize(self, opts)
  self.vx = 30
  self.w = 8
  self.h = 8
  self.spritesheet = love.graphics.newImage('assets/SLIME.png')
  self.animationGrid = anim8.newGrid(16,16,64,64)
  self.animation = anim8.newAnimation(self.animationGrid('1-4',1),.2)
end

function Slime:update(dt)
  -- just call Entity.update for default behavior
  -- Entity.update(self, dt)

  -- override Entity.update for custom behavior
  self:updateGravity(dt)
  self:updateAnimation(dt)
  local cols, len = self:moveWithCollisions(dt)

  --basic AI: turn around when X collision
  for _, col in pairs(cols) do
    if math.abs(col.normal.x) == 1 then
      self.vx = -self.vx
    end
    if col.other == player then
      player:takeDamage(col.normal)
    end
  end
end

return Slime
