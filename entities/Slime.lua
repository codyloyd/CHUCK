local class = require('lib/middleclass')
local Entity = require('entities/Entity')
local mixins = require('entities/mixins')
local Slime = class('Slime', Entity)
Slime:include(mixins.Destructible)
Slime:include(mixins.CanSeePlayer)
Slime:include(mixins.DropsHealth)

function Slime:initialize(opts, world)
  Entity.initialize(self, opts, world)
  self.vx = 24
  self.w = 8
  self.h = 8
  self.hp = 2
  self.spritesheet = love.graphics.newImage('assets/SLIME.png')
  self.animationGrid = anim8.newGrid(16,16,64,64)
  self.walking = anim8.newAnimation(self.animationGrid('1-4',1),.2)
  self.falling = anim8.newAnimation(self.animationGrid('2-2',3),.2)
  self.hurt = anim8.newAnimation(self.animationGrid('3-3',3),.2)
  self.animation = self.walking

  world:add(self, self.x, self.y, self.w, self.h)
end

function Slime:update(dt)
  -- override Entity.update for custom behavior
  self:updateGravity(dt)
  self:updateAnimation(dt)

  self:chasePlayer()

  if math.abs(self.vx) > self.walkingSpeed then
    local multiplier = self.vx > 0 and 1 or -1
    self.vx = math.max(self.walkingSpeed, math.abs(self.vx) - (math.abs(self.vx) * 39 * dt)) * multiplier
  end

  local cols, len = self:moveWithCollisions(dt)

  --basic AI: turn around when X collision
  for _, col in pairs(cols) do
    if not col.other.noClip and math.abs(col.normal.x) == 1 then
      self.vx = -self.vx
    end
  end

  -- direction only matters for animation/drawing
  if self.hitTimer <= 0 then
    if self.vx > 0 then
      self.direction = -1
    else
      self.direction = 1
    end
  end

  if self.vy < -1 then
    self.animation = self.falling
  else
    self.animation = self.walking
  end

  if self.hitTimer > 0 then
    self.hitTimer = self.hitTimer - dt
    self.animation = self.hurt
  else
    self.animation = self.walking
  end
end

return Slime
