local class = require('lib/middleclass')
local Entity = require('entities/Entity')
local mixins = require('entities/mixins')
local Wizard = class('Wizard', Entity)
Wizard:include(mixins.Destructible)

function Wizard:initialize(opts, world)
  Entity.initialize(self, opts, world)
  self.vx = 14
  self.w = 8
  self.h = 8
  self.hp = 5
  self.spritesheet = love.graphics.newImage('assets/WIZARD_WHITE.png')
  self.animationGrid = anim8.newGrid(16,16,64,64)
  self.walking = anim8.newAnimation(self.animationGrid('1-4',2), 0.2)
  self.standing = anim8.newAnimation(self.animationGrid('1-4',1), 0.3)
  self.jumping = anim8.newAnimation(self.animationGrid('1-1',3), 1)
  self.falling = anim8.newAnimation(self.animationGrid('2-2', 3), 1)
  self.attacking = anim8.newAnimation(self.animationGrid('1-4', 4), 0.1)
  self.hurt = anim8.newAnimation(self.animationGrid('3-3', 3), 1)
  self.dead = anim8.newAnimation(self.animationGrid('4-4', 3), 1)
  self.animation = self.standing

  self.world = world

  self.world:add(self, self.x, self.y, self.w, self.h)
end

function Wizard:update(dt)
  -- just call Entity.update for default behavior
  -- Entity.update(self, dt)

  -- override Entity.update for custom behavior
  self:updateGravity(dt)
  self:updateAnimation(dt)
  
  if math.abs(self.vx) > self.walkingSpeed then
    local multiplier = self.vx > 0 and 1 or -1
    self.vx = math.max(self.walkingSpeed, math.abs(self.vx) - (math.abs(self.vx) * 39 * dt)) * multiplier
  end

  -- check for platform/falling
  if self.hitTimer <= 0 then 
    local checkXOffset = math.max(self.w * self.direction, -1)
    local checkX = self.x + checkXOffset
    local checkY = self.y + self.h + 1
    local items, len = self.world:queryPoint(checkX, checkY)

    -- turn around instead of falling off platform
    if len == 0 then
      self.vx = -self.vx
    end
  end

  local cols, len = self:moveWithCollisions(dt)

  --basic AI: turn around when X collision
  for _, col in pairs(cols) do
    if not col.other.noClip and math.abs(col.normal.x) == 1 then
      self.vx = -self.vx
    end
  end

  -- direction only matters for animation/drawing
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

  if self.hitTimer > 0 then
    self.hitTimer = self.hitTimer - dt
    self.animation = self.hurt
  else
    self.animation = self.walking
  end
end

return Wizard
