local class = require('lib/middleclass')
local Entity = require('entities/Entity')
local mixins = require('entities/mixins')
local Projectile = require('entities/Projectile')

local Wizard = class('Wizard', Entity)
Wizard:include(mixins.Destructible)
Wizard:include(mixins.CanSeePlayer)

function Wizard:initialize(opts, world)
  Entity.initialize(self, opts, world)
  self.vx = 14
  self.w = 8
  self.h = 8
  self.hp = 5
  self.isAttacking = false
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
  self.projectiles = {}
  self.projectileTimer = 0

  self.world = world

  self.world:add(self, self.x, self.y, self.w, self.h)
end

function Wizard:shouldCleanUp()
  return self.dead == true and #self.projectiles == 0
end

function Wizard:shootProjectile(dir)
  tick.delay(function()
    if self.isAttacking then
      local wx = self.x
      local wy = self.y
      sounds.fireball:play()
      table.insert(self.projectiles, Projectile:new({
            x = wx,
            y = wy,
            direction = dir
        }, self.world))
    end
  end, .4)
end

function Wizard:update(dt)
  self:updateGravity(dt)
  self:updateAnimation(dt)

  if self.dead == true then
    for _,p in pairs(self.projectiles) do
      p.dead = true
    end
  end

  if self.projectileTimer > 0 then
    self.projectileTimer = self.projectileTimer - dt
  end

  local player = self:playerIsInRange(160)
  if player then
    self.isAttacking = true
  else
    self.isAttacking = false
  end

  if self.isAttacking and self.projectileTimer <= 0 then
    local dir = self.x > player.x and -1 or 1
    self:shootProjectile(dir)
    self.projectileTimer = 1.5
  end
  
  if math.abs(self.vx) > self.walkingSpeed then
    local multiplier = self.vx > 0 and 1 or -1
    self.vx = math.max(self.walkingSpeed, math.abs(self.vx) - (math.abs(self.vx) * 39 * dt)) * multiplier
  end

  if math.abs(self.vx) < self.walkingSpeed and not self.isAttacking then
    local multiplier = self.vx > 0 and 1 or -1
    self.vx = self.walkingSpeed * multiplier
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
    if self.isAttacking then
      if player.x > self.x then 
        self.direction = 1
      else
        self.direction = -1
      end
      local multiplier = self.vx > 0 and 1 or -1
      self.vx = 0.1 * multiplier
      self.animation = self.attacking
    else
      self.animation = self.walking
    end
  end
end

return Wizard
