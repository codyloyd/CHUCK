local class = require("lib/middleclass")
local Entity = require("entities/Entity")
local Player = class("Player", Entity)

function Player:initialize(opts)
  Entity.initialize(self, opts)
  self.hitTimer = 0
  self.jumpStrength = 260
  self.shortJumpStrength = 100
  self.jumpCount = 0
  self.powerups = {
    doubleJump = true
  }
  self.spritesheet = love.graphics.newImage('assets/KNIGHT_WHITE.png')
  self.animationGrid = anim8.newGrid(16,16,64,64)
  self.walking = anim8.newAnimation(self.animationGrid('1-4',2), 0.1)
  self.standing = anim8.newAnimation(self.animationGrid('1-4',1), 0.3)
  self.jumping = anim8.newAnimation(self.animationGrid('1-1',3), 1)
  self.falling = anim8.newAnimation(self.animationGrid('2-2', 3), 1)
  self.attacking = anim8.newAnimation(self.animationGrid('1-4', 4), 0.1)
  self.hurt = anim8.newAnimation(self.animationGrid('3-3', 3), 1)
  self.dead = anim8.newAnimation(self.animationGrid('4-4', 3), 1)
  self.animation = self.standing
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

function player:takeDamage(normal)
  if self.hitTimer <= 0 then
    self.hitTimer = 0.2
    self.vy = 80
    self.vx = normal.x > 0 and 100 or -100
  end
end

function player:update(dt)
  self:updateAnimation(dt)
  self:updateGravity(dt)
  
  if self.hitTimer > 0 then
    self.hitTimer = self.hitTimer - dt
  end
  print(self.hitTimer)

  if not (math.abs(self.vy) <= self.gravity * dt) then
    self.grounded = false

    if self.jumpCount < 1 then
      self.jumpCount = 1
    end
  end

  if love.keyboard.isDown("left") then
    if self.hitTimer <= 0 then
      self.vx = math.min(self.vx + 16 * self.maxVx * dt, self.maxVx)
    end
    self.direction = -1
  end

  if love.keyboard.isDown("right") then
    if self.hitTimer <= 0 then
      self.vx = math.max(self.vx - 16 * self.maxVx * dt, -self.maxVx)
    end
    self.direction = 1
  end

  if not love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
    if self.hitTimer <= 0 then 
      self.vx = self.vx * .9
    end
  end

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
  
  if self.hitTimer > 0 then
    self.animation = self.hurt
  end

  if self.grounded then 
    self.jumpCount = 0
  end

  local cols, len = self:moveWithCollisions(dt)

  for _, col in pairs(cols) do
    if math.abs(col.normal.x) == 1 then
      self.vx = 0
    end

    if col.normal.y == 1 then
      self.vy = 0
    end

    if col.normal.y == -1 then
      self.grounded = true
      self.vy = 0
    end

    if col.other.causesDamage then
      self:takeDamage(col.normal)
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
  if key == "up" and (self.grounded or (self.powerups.doubleJump and self.jumpCount < 2)) then
    self.vy = self.jumpStrength
    self.grounded = false
    self.jumpCount = self.jumpCount + 1
  end

  if DEBUG_MODE then
    -- add debug controls here
  end
end

function player:keyreleased(key)
  if key == "up" and not self.grounded then
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
