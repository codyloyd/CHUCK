local class = require('lib/middleclass')
local Entity = require('entities/Entity')
local mixins = require('entities/mixins')
local Skeleton = class('Skeleton', Entity)
Skeleton:include(mixins.Destructible)
Skeleton:include(mixins.CanSeePlayer)

function Skeleton:initialize(opts, world)
  Entity.initialize(self, opts)
  self.vx = 14
  self.w = 8
  self.h = 8
  self.hp = 4
  self.walkingSpeed = 14
  self.spritesheet = love.graphics.newImage('assets/SKELETON.png')
  self.animationGrid = anim8.newGrid(16,16,64,64)
  self.walking = anim8.newAnimation(self.animationGrid('1-4',2), 0.2)
  self.standing = anim8.newAnimation(self.animationGrid('1-4',1), 0.3)
  self.jumping = anim8.newAnimation(self.animationGrid('1-1',3), 1)
  self.falling = anim8.newAnimation(self.animationGrid('3-3', 3), 1)
  self.attacking = anim8.newAnimation(self.animationGrid('1-4', 4), 0.1)
  self.hurt = anim8.newAnimation(self.animationGrid('3-3', 3), 1)
  self.dead = anim8.newAnimation(self.animationGrid('4-4', 3), 1)
  self.animation = self.standing
  self.jumpTimer = 0

  self.world = world

  self.world:add(self, self.x, self.y, self.w, self.h)
end

function Skeleton:update(dt)
  self:updateGravity(dt)
  self:updateAnimation(dt)


  self:chasePlayer(150, 100)

  local player = self:playerIsInRange(50, 20)
  if player and self.grounded and self.jumpTimer <= 0 and self.hitTimer <= 0 then
    self.jumpTimer = 1.5
    self.vy = 200
    self.vx = 100
    local direction = self.vx > 0 and 1 or -1
    local playerDirection = player.x > self.x and 1 or -1
    if playerDirection == direction and self.hitTimer <= 0 and self.grounded then
      self.vx = self.vx * -1
    else
    end
  end

  if self.jumpTimer > 0 then
    self.jumpTimer = self.jumpTimer - dt
  end

  

  if math.abs(self.vx) > self.walkingSpeed and self.grounded or self.hitTimer > 0 then
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
    if len == 0 and self.grounded then
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

  local multiplier = self.vx > 0 and 1 or -1

  if self.hitTimer > 0 then
    self.hitTimer = self.hitTimer - dt
    self.animation = self.hurt
  else
    self.animation = self.walking
  end
end

return Skeleton
