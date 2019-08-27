local class = require('lib/middleclass')
local Entity = require('entities/Entity')
local Slime = class('Slime', Entity)

function Slime:initialize(opts)
  Entity.initialize(self, opts)
  self.vx = 24
  self.w = 8
  self.h = 8
  self.spritesheet = love.graphics.newImage('assets/SLIME.png')
  self.animationGrid = anim8.newGrid(16,16,64,64)
  self.walking = anim8.newAnimation(self.animationGrid('1-4',1),.2)
  self.falling = anim8.newAnimation(self.animationGrid('2-2',3),.2)
  self.animation = self.walking
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

  if self.vx > 0 then
    self.direction = -1
  else
    self.direction = 1
  end

  if self.vy < -1 then
    self.animation = self.falling
  else
    self.animation = self.walking
  end
end

return Slime
