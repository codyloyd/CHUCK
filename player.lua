local class = require("lib/middleclass")
local Entity = require("entities/Entity")
local Player = class("Player", Entity)

local lastSafeGround = {}

function Player:initialize(gameMap, world, playerState, spawnPos, eventHandler)
  Entity.initialize(self, opts, world)

  -- Constants
  self.name = "PLAYER"
  self.x = spawnPos.x
  self.y = spawnPos.y
  self.w = 8
  self.h = 13
  self.maxVx = 150
  self.maxVy = 2000
  self.shortJumpStrength = 100
  self.wallJumpXStrength = 200
  self.wallJumpYStrength = 300
  self.noClip = true
  self.playerState = playerState

  -- Timers
  self.hitTimer = 0
  self.invulnerableTimer = 0
  self.knockbackTimer = 0
  self.attackTimer = 0
  self.attackCooldown = 0
  self.jumpStrength = 260

  -- Counters
  self.jumpCount = 0

  -- Variables
  self.health = self.playerState.health or 5
  self.maxHealth = self.playerState.maxHealth or 5
  self.powerups = {
    doubleJump = self.playerState.powerups.doubleJump or false,
    wallJump = self.playerState.powerups.wallJump or false
  }

  self.wallSliding = false
  self.wallJumpDirection = 0

  -- Sprite and Animations
  self.knightspritesheet = love.graphics.newImage('assets/KNIGHT_WHITE.png')
  self.knight2spritesheet = love.graphics.newImage('assets/KNIGHT_WHITE2.png')
  self.spritesheet = love.graphics.newImage('assets/KNIGHT_WHITE.png')
  self.animationGrid = anim8.newGrid(16,16,64,64)
  self.animation2Grid = anim8.newGrid(28,16,112,64)
  self.walking = anim8.newAnimation(self.animationGrid('1-4',2), 0.1)
  self.standing = anim8.newAnimation(self.animationGrid('1-4',1), 0.3)
  self.jumping = anim8.newAnimation(self.animationGrid('1-1',3), 1)
  self.falling = anim8.newAnimation(self.animationGrid('2-2', 3), 1)
  self.attacking = anim8.newAnimation(self.animation2Grid('1-4', 4), {0.08,0.05,0.05,1})
  self.hurt = anim8.newAnimation(self.animationGrid('3-3', 3), 1)
  self.deadAnimation = anim8.newAnimation(self.animationGrid('4-4', 3), 1)
  self.animation = self.standing

  self.world = world

  -- Sword attack (offset from player location, multiplied by direction)
  self.swordAttackHitbox = {w=13, h=self.h - 2}
  -- self.world:add(self.attackBox, 0, 0, 13, 16)

  -- eventHandler callback
  self.sendEvent = eventHandler

  -- Add player to world
  self.world:add(self, self.x, self.y, self.w, self.h)
end

function Player:takeDamage(other, noKnockback)
  if self.invulnerableTimer <= 0 then
    self.health = self.health - 1
    self.playerState.health = self.health
    self.hitTimer = 0.2
    self.invulnerableTimer = .8

    if not noKnockback then
      self.vy = 70
      local direction = other.x > self.x and 1 or -1
      self.vx = 300 * direction
    end

    particles:createFlash({.1,.1,.2})
    sounds.hurt:play()
    sounds.hurt2:play()
    self.sendEvent('take-damage')

    if self.health < 1 then
      self.sendEvent('player-death')
      sounds.playerdeath:play()
      self.dead = true
      self.attackTimer = 0
    end
  end
end

function Player.collisionFilter(item, other)
  -- If the platform is jumpthrough-able, and if the players feet are above the top of the platform
  if other.jumpThrough and item.y + item.h > other.y then
    return nil
  elseif other.causesDamage then
    return 'cross'
  elseif other.class and other.class.name == "Powerup" then
    return 'cross'
  elseif other.dropType and other.dropType == "health" then
    return 'cross'
  elseif other.class and other.class.name == "Door" and other.inactive then
    return nil
  else
    return 'slide'
  end
end

function Player:update(dt)
  self.health = self.playerState.health
  self:updateAnimation(dt)
  self:updateGravity(dt)
  self.spritesheet = self.knightspritesheet

  -- Timers
  if self.hitTimer > 0 then
    self.hitTimer = self.hitTimer - dt
  end

  if self.knockbackTimer > 0 then 
    self.knockbackTimer = self.knockbackTimer - dt
  end

  if self.invulnerableTimer > 0 then
    self.invulnerableTimer = self.invulnerableTimer - dt
  end

  -- Return here to prevent being able to attack after death
  if self.dead then
    self.animation = self.deadAnimation
    return
  end

  if self.attackTimer > 0 then
    self.attackTimer = self.attackTimer - dt
  end

  if self.attackCooldown > 0 then
    self.attackCooldown = self.attackCooldown - dt
  end

  -- input handlers
  if love.keyboard.isDown(LEFT) then
    if self.hitTimer <= 0  and self.knockbackTimer <= 0 then
      self.vx = math.min(self.vx + 16 * self.maxVx * dt, self.maxVx)
    else
      self.vx = self.vx * .9
    end
    self.direction = -1
  end

  if love.keyboard.isDown(RIGHT) then
    if self.hitTimer <= 0 and self.knockbackTimer <= 0 then
      self.vx = math.max(self.vx - 16 * self.maxVx * dt, -self.maxVx)
    else
      self.vx = self.vx * .9
    end
    self.direction = 1
  end

  if not love.keyboard.isDown(LEFT) and not love.keyboard.isDown(RIGHT) then
    if self.hitTimer <= 0 and self.knockbackTimer <= 0 then
      self.vx = self.vx * .6
    else
      self.vx = self.vx * .9
    end
  end

  -- Update animations
  if math.abs(self.vx) > 50 then
    self.animation = self.walking
  else 
    self.animation = self.standing
  end
  
  if self.vy > 0 and not self.grounded then
    self.animation = self.jumping
  end

  if self.vy < 0 and not self.grounded then
    self.animation = self.falling
  end
  
  if self.attackTimer > 0 then
    self.spritesheet = self.knight2spritesheet
    self.animation = self.attacking
  end

  if self.hitTimer > 0 then
    self.animation = self.hurt
  end

  --
  if self.grounded then 
    self.jumpCount = 0
  end

  if self.attackTimer > 0 then
    local attack = self:getSwordAttackHitbox()
    local items, len = self.world:queryRect(attack.x, attack.y, attack.w, attack.h)

    for _, item in pairs(items) do
      if (item.hp) then
        local direction = item.x > self.x and 1 or -1
        sounds.hit:play()
        item:takeDamage(self.direction)
        particles:createHit(item.x + item.w/2, item.y + item.h/2, direction)
        self.sendEvent("take-damage", {time=.05})
        self.vx = 100 * direction
        self.knockbackTimer = .08
      end
    end
  end

  -- Handle collisions
  local cols, len = self:moveWithCollisions(dt)

  -- if no collisions, set everything to default
  if len < 1 then
    self.wallSliding = false
    self.grounded = false
    self.gravity = 790
  end


  for _, col in pairs(cols) do
    if col.other.causesDamage then
      self:takeDamage(col.other)
      if col.other.class.name == "Projectile" then
        col.other.dead = true
      end
    end

    if col.normal.y == -1 then
      self.grounded = true
      self.vy = 0
    end

    --hit ceiling
    if col.normal.y == 1 then
      self.vy = 0
    end

    if self.grounded and not col.other.spikes then
      if col.otherRect.x < self.x and col.otherRect.x + col.otherRect.w > self.x + self.w then
        local items, len = self.world:queryRect(self.x-30, self.y - 4, self.w+60, self.h + 8, 
          function(item)
            return item.spikes
          end)
        if len < 1 then
          lastSafeGround.x, lastSafeGround.y = self.x, self.y
        end
      end
    end

    -- Walljump
    if self.powerups.wallJump                      -- Check if player has walljump, 
    and not self.grounded                          -- and not if grounded
    and (col.other.class and col.other.class.name == "Platform") -- the other is a platform, 
    and not col.other.jumpThrough                  -- but not a jumpthrough, 
    and col.normal.y == 0                          -- and not hitting head, 
    and self.vy < 0                                -- and not moving upwards
    and col.other.y + col.other.h > self.y + 11    -- Check feet vs bottom of platform to prevent head from sticking
    and (love.keyboard.isDown(RIGHT) or love.keyboard.isDown(LEFT))
    then
      -- Set vy to zero on initial contact
      if not self.wallSliding then
        self.vy = 0
      end

      self.jumpCount = 0
      self.wallSliding = true

      -- Changing gravity to simulate friction against wall
      self.gravity = 50
    else 
      self.wallSliding = false
      self.gravity = 790
    end


    if col.other.spikes then
      self:takeDamage(col.other, true)
      particles:createFirework(self.x+self.w/2, self.y+self.h/2, {.4,.4,.4})
      particles:createFlash()
      self.x, self.y = lastSafeGround.x, lastSafeGround.y
      self.world:update(self, self.x, self.y)
    end

    if col.other.class and col.other.class.name == "Powerup" then
      self:getPowerup(col.other.name)
      col.other:collected()
    end

    if col.other.dropType and col.other.dropType == "health" then
      sounds.pickup:play()
      if col.other.life > 0 then
        self.health = math.min(self.health+1, self.maxHealth)
        self.playerState.health = self.health
        col.other.life = 0
      end
    end
  end

  if math.abs(self.vx) > 10 and self.grounded then
    sounds.walk:play()
  else
    sounds.walk:stop()
  end
end

function Player:getSwordAttackHitbox()
  -- define attack hitbox
  local attack = {}
  attack.y = self.y 
  attack.h = self.swordAttackHitbox.h

  if self.direction == 1 then            -- Facing Right
    attack.x = self.x + self.w 
    attack.w = self.swordAttackHitbox.w
  else                                   -- Facing Left
    -- Have to keep the width positive, so we have to shift the `x` position to the left
    attack.x = self.x - self.swordAttackHitbox.w 
    attack.w = self.swordAttackHitbox.w
  end

  return attack
end

function Player:draw()
  if self.hitTimer > 0.1 then
    love.graphics.setColor(1,0.3,0.3)
  end
  self.animation:draw(self.spritesheet,math.floor(self.x+self.w/2),math.ceil(self.y+(self.h/2) - 1.5),nil,self.direction,1,8,8)
  love.graphics.setColor(1,1,1)

  if DEBUG_MODE then
    if self.attackTimer > 0 then

      -- Draw attack hitbox
      local attack = self:getSwordAttackHitbox()
      love.graphics.rectangle('line', attack.x, attack.y, attack.w, attack.h)
    end
  end
end

function Player:keypressed(key)
  if key == JUMP and ((self.grounded or self.wallSliding) or (self.powerups.doubleJump and self.jumpCount < 2)) then
    if self.wallSliding then 
      if love.keyboard.isDown(LEFT) then
        self.wallJumpDirection = -1
        self.vx = -self.wallJumpXStrength
      else
        self.wallJumpDirection = 1
        self.vx = self.wallJumpXStrength
      end
      self.vy = self.wallJumpYStrength
    else
      self.vy = self.jumpStrength
    end
    self.grounded = false
    self.jumpCount = self.jumpCount + 1
    sounds.jump:play()
  end

  if key == ATTACK then
    if self.attackCooldown <= 0 and not self.dead then 
      self.attackTimer = .25
      self.attackCooldown = .4
      self.attacking:gotoFrame(1)
      sounds.attack:play()
    end
  end

    if DEBUG_MODE then
    end
end

function Player:keyreleased(key)
  if key == JUMP and not self.grounded then
    if self.vy > self.shortJumpStrength then 
      self.vy = self.shortJumpStrength 
    end

    if self.wallJumpDirection ~= 0 then
      self.vx = 0
    end

    self.wallJumpDirection = 0
  end
end

function Player:getPowerup(type) 
  if type == "doubleJump" then
    self.powerups.doubleJump = true
    self.playerState.powerups.doubleJump = true
  elseif type == "wallJump" then
    self.powerups.wallJump = true
    self.playerState.powerups.wallJump = true
  elseif string.find(type, "healthIncrease") then
    self.maxHealth = self.maxHealth + 1
    self.health = self.maxHealth
    self.playerState.health = self.health
    self.playerState.maxHealth = self.maxHealth
    self.playerState.powerups[type] = true
  end

  self.sendEvent("got-powerup", type)
end

return Player
