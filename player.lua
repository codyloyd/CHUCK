local class = require("lib/middleclass")
local Entity = require("entities/Entity")
local Player = class("Player", Entity)

function Player:initialize(opts)
  Entity.initialize(self, opts)
  self.hitTimer = 0
  self.invulnerableTimer = 0
  self.attackTimer = 0
  self.attackCooldown = 0
  self.jumpStrength = 260
  self.shortJumpStrength = 100
  self.jumpCount = 0
  self.powerups = {
    doubleJump = true
  }
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
  self.attackBox = {x=0, y=0, w=11, h=self.h, noClip=true}
  world:add(self.attackBox, 0, 0, 11, 16)
  self.noClip = true
end

local player = Player:new({
    x = 100,
    y = 100,
    w = 8, 
    h = 16,
    maxVx = 150,
    maxVy = 2000,
  })
world:add(player,player.x,player.y,player.w,player.h)

function player:takeDamage(direction)
  if self.invulnerableTimer <= 0 then
    self.hitTimer = 0.2
    self.invulnerableTimer = .6
    self.vy = 80

    -- TODO: Calcualte direction to knockback based on player direction and enemy direction(?)

    -- if direction - self.direction == 
    -- self.vx = direction > 0 and 300 or -300
  end
end

function player.collisionFilter(item, other)
  -- If the platform is jumpthrough-able, and if the players feet are above the top of the platform
  if other.jumpThrough and item.y + item.h > other.y then
    return nil
  elseif other == player.attackBox then
    return nil
  elseif other.causesDamage then
    return 'cross'
  else
    return 'slide'
  end
end

function player:update(dt)
  self:updateAnimation(dt)
  self:updateGravity(dt)
  self.spritesheet = self.knightspritesheet

  -- Timers
  if self.hitTimer > 0 then
    self.hitTimer = self.hitTimer - dt
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
    self.vx = math.min(self.vx + 16 * self.maxVx * dt, self.maxVx)
    self.direction = -1
  end

  if love.keyboard.isDown(RIGHT) then
    self.vx = math.max(self.vx - 16 * self.maxVx * dt, -self.maxVx)
    self.direction = 1
  end

  if not love.keyboard.isDown(LEFT) and not love.keyboard.isDown(RIGHT) then
    self.vx = self.vx * .9
  end

  -- Update animations
  if math.abs(player.vx) > 50 then
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
    local goalX = self.direction == -1 and self.x - self.attackBox.w or self.x + self.w
    local goalY = self.y
    local actualX, actualY, cols, len = world:move(self.attackBox, goalX, goalY, function() return "cross" end)
    self.attackBox.x = actualX
    self.attackBox.y = actualY
    for _, col in pairs(cols) do
      if (col.other.hp) then
        col.other:takeDamage()
      end
    end
  else
    self.attackBox.x, self.attackBox.y = 0, 0
    world:update(self.attackBox, 0, 0)
  end

  -- Handle collisions
  local cols, len = self:moveWithCollisions(dt)

  for _, col in pairs(cols) do
    if col.other.causesDamage then
      print(inspect(col.other))
      print(col.other.direction)
      self:takeDamage(col.other.direction)
    end

    if col.normal.y == -1 then
      self.grounded = true
      self.vy = 0
    end

  end
end

function player:draw()
  if self.hitTimer > 0.1 then
    love.graphics.setColor(1,0.3,0.3)
  end
  self.animation:draw(self.spritesheet,math.floor(self.x+self.w/2),math.ceil(self.y+self.h/2),nil,self.direction,1,8,8)
  love.graphics.setColor(1,1,1)
end

function player:keypressed(key)
  if key == JUMP and (self.grounded or (self.powerups.doubleJump and self.jumpCount < 2)) then
    self.vy = self.jumpStrength
    self.grounded = false
    self.jumpCount = self.jumpCount + 1
  end

  if key == ATTACK then
    if self.attackCooldown <= 0 then 
      self.attackTimer = .3
      self.attackCooldown = .4
      self.attacking:gotoFrame(1)
    end
  end

  if DEBUG_MODE then
    -- add debug controls here
  end
end

function player:keyreleased(key)
  if key == JUMP and not self.grounded then
    if self.vy > self.shortJumpStrength then 
      self.vy = self.shortJumpStrength 
    end
  end
end

function player:getPowerup(type) 
  if type == "doubleJump" then
    self.powerups.doubleJump = true
  end
end

return player
