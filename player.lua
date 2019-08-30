local class = require("lib/middleclass")
local Entity = require("entities/Entity")
local Player = class("Player", Entity)

function Player:initialize(gameMap, world)
  Entity.initialize(self, opts, world)
  local player = gameMap.layers["spawn"].objects[1]

  -- Constants
  self.x = player.x
  self.y = player.y
  self.w = 8
  self.h = 16
  self.maxVx = 150
  self.maxVy = 2000
  self.shortJumpStrength = 100
  self.wallJumpPower = 400
  self.noClip = true

  -- Timers
  self.hitTimer = 0
  self.invulnerableTimer = 0
  self.knockbackTimer = 0
  self.attackTimer = 0
  self.attackCooldown = 0
  self.jumpStrength = 260

  -- Counters
  self.jumpCount = 0


  self.powerups = {
    doubleJump = false,
    wallJump = false
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
  self.dead = anim8.newAnimation(self.animationGrid('4-4', 3), 1)
  self.animation = self.standing

  self.world = world
  -- Sword attack
  self.attackBox = {x=0, y=0, w=11, h=self.h, noClip=true}
  self.world:add(self.attackBox, 0, 0, 11, 16)

  -- Add player to world
  self.world:add(self, self.x, self.y, self.w, self.h)
end

function Player:takeDamage(other)
  if self.invulnerableTimer <= 0 then
    self.hitTimer = 0.2
    self.invulnerableTimer = .6
    self.vy = 80

    local direction = other.x > self.x and 1 or -1
    self.vx = 500 * direction
  end
end

function Player.collisionFilter(item, other)
  -- If the platform is jumpthrough-able, and if the players feet are above the top of the platform
  if other.jumpThrough and item.y + item.h > other.y then
    return nil
  elseif other == item.attackBox then
    return nil
  elseif other.causesDamage then
    return 'cross'
  elseif other.class and other.class.name == "Powerup" then
    return 'cross'
  else
    return 'slide'
  end
end

function Player:update(dt)
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

  -- check attackBox
  if self.attackTimer > 0 then
    local goalX = self.direction == -1 and self.x - self.attackBox.w + 2 or self.x + self.w - 2
    local goalY = self.y
    local actualX, actualY, cols, len = self.world:move(self.attackBox, goalX, goalY, function() return "cross" end)
    self.attackBox.x = actualX
    self.attackBox.y = actualY
    for _, col in pairs(cols) do
      if (col.other.hp) then
        col.other:takeDamage(self.direction)

        -- knockback self if hit enemy
        local direction = col.other.x > self.x and 1 or -1
        self.vx = 100 * direction
        self.knockbackTimer = .08
      end
    end
  else
    self.attackBox.x, self.attackBox.y = 0, 0
    self.world:update(self.attackBox, 0, 0)
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
    end

    if col.normal.y == -1 then
      self.grounded = true
      self.vy = 0
    end

    --hit ceiling
    if col.normal.y == 1 then
      self.vy = 0
    end

    -- Walljump
    if self.powerups.wallJump                -- Check if player has walljump, 
    and not self.grounded                    -- and not if grounded
    and col.other.class.name == "Platform"   -- the other is a platform, 
    and not col.other.jumpThrough            -- but not a jumpthrough, 
    and col.normal.y == 0                    -- and not hitting head, 
    and self.vy < 0                          -- and not moving upwards
    and math.abs(col.move.x) > 1.5           -- and moving into platform | TODO: calculate off vx maybe?
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

    if col.other.class and col.other.class.name == "Powerup" then
      self:getPowerup(col.other.name)
      col.other:collected()
    end
  end
end

function Player:draw()
  if self.hitTimer > 0.1 then
    love.graphics.setColor(1,0.3,0.3)
  end
  self.animation:draw(self.spritesheet,math.floor(self.x+self.w/2),math.ceil(self.y+self.h/2),nil,self.direction,1,8,8)
  love.graphics.setColor(1,1,1)
end

function Player:keypressed(key)
  if key == JUMP and ((self.grounded or self.wallSliding) or (self.powerups.doubleJump and self.jumpCount < 2)) then
    if self.wallSliding then 
      if love.keyboard.isDown(LEFT) then
        self.wallJumpDirection = -1
        self.vx = -self.wallJumpPower
      else
        self.wallJumpDirection = 1
        self.vx = self.wallJumpPower
      end
    end
    self.vy = self.jumpStrength
    self.grounded = false
    self.jumpCount = self.jumpCount + 1
  end

  if key == ATTACK then
    if self.attackCooldown <= 0 then 
      self.attackTimer = .25
      self.attackCooldown = .4
      self.attacking:gotoFrame(1)
    end
  end

  if DEBUG_MODE then
    -- add debug controls here
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
  if type == "double-jump" then
    self.powerups.doubleJump = true
  elseif type == "wall-jump" then
    self.powerups.wallJump = true
  end
end

return Player
