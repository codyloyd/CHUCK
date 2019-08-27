local player = {}

player.spriteSheet = love.graphics.newImage('KNIGHT_WHITE.png')
-- TODO get this info from Tiled so we can put the player wherever.
player.x = 100
player.y = 100
player.width = 8
player.height = 16
player.grid = anim8.newGrid(16,16,64,64)
player.walking = anim8.newAnimation(player.grid('1-4',2), 0.1)
player.standing = anim8.newAnimation(player.grid('1-4',1), 0.3)
player.jumping = anim8.newAnimation(player.grid('1-1',3), 1)
player.attacking = anim8.newAnimation(player.grid('1-4', 4), 0.1)
player.animation = player.standing
player.grounded = false
player.direction = 1
player.dx = 0
player.dy = 0
player.maxSpeed = 150
player.gravity = 790
player.jumpStrength = 260
player.shortJumpStrength = 100
player.maxFallSpeed = 2000
-- player.rect = HC.rectangle(0,0,8,16)
player.hitTimer = 0

player.jumpCount = 0

player.powerups = {}
player.powerups.doubleJump = true

world:add(player,player.x,player.y,player.width,player.height)

function player:setPosition(x ,y)
  self.x = x
  self.y = y
end

function player:reset()
  player:setPosition(100, 100)
end

function player:takeDamage(delta)
  if self.hitTimer == 0 then
    self.hitTimer = 60
    self.dy = 20
    self.dx = delta.x > 0 and -100 or 100
  end
end

function player:update(dt)
  self.animation:update(dt)
  
  if self.hitTimer > 0 then
    self.hitTimer = self.hitTimer - 1
  end

  -- gravity
  self.dy = math.min(self.dy - self.gravity * dt, self.maxFallSpeed)

  if not (math.abs(self.dy) <= self.gravity * dt) then
    self.grounded = false

    if self.jumpCount < 1 then
      self.jumpCount = 1
    end
  end

  if love.keyboard.isDown("left") then
    if self.hitTimer == 0 then
      self.dx = self.dx + 16 * self.maxSpeed * dt
    end
    self.direction = -1
  end

  if love.keyboard.isDown("right") then
    if self.hitTimer == 0 then
      self.dx = self.dx - 16 * self.maxSpeed * dt
    end
    self.direction = 1
  end

  if not love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
    if self.hitTimer == 0 then 
      self.dx = self.dx * .9
    end
  end

  if self.dx >= self.maxSpeed then
    self.dx = self.maxSpeed
  end

  if self.dx <= -self.maxSpeed then
    self.dx = -self.maxSpeed
  end

  if math.abs(player.dx) > 50 then
    self.animation = self.walking
  else 
    self.animation = self.standing
  end
  
  if not self.grounded then
    self.animation = self.jumping
  end

  if self.grounded then 
    self.jumpCount = 0
  end

  local startx = self.x
  local starty = self.y

  goalX = self.x - self.dx * dt
  goalY = self.y - self.dy * dt
  local actualX, actualY, cols, len = world:move(player, goalX, goalY)

  function changeVelocityByCollisionNormal(nx, ny, bounciness)
    bounciness = bounciness or 0
    local dx, dy = self.dx, self.dy

    if (nx < 0 and dx < 0) or (nx > 0 and dx > 0) then
      dx = -dx * bounciness
    end

    if (ny < 0 and dy < 0) or (ny > 0 and dy > 0) then
      dy = -dy * bounciness
    end

    self.dx, self.dy = dx, dy
  end

  function checkIfOnGround(ny)
    if ny < 0 then self.grounded = true end
  end

  for i=1,len do
    local col = cols[i]
    changeVelocityByCollisionNormal(col.normal.x, col.normal.y)
    checkIfOnGround(col.normal.y)
  end

  self:setPosition(actualX, actualY)

  --for shape, delta in pairs(HC.collisions(self.rect)) do
  --  ---bottom collisions
  --  if (delta.y < 0 and self.dy < 0) then 
  --    local topOfShape = 99999999;
  --    local playerBottomBefore = starty + 8;
  --    for _, vertex in ipairs(shape._polygon.vertices) do
  --      topOfShape = math.min(vertex.y, topOfShape);
  --    end
  --    if playerBottomBefore > topOfShape then return end

  --    self.dy = 0
  --    self.y = starty
  --    self.grounded = true
  --  end

  --  --top collisions
  --  if (delta.y > 0 and not shape.jumpThrough) then
  --    self.dy = -5
  --    self.y = starty + delta.y
  --  end

  --  --side collision
  --  if ((delta.x > 0 or delta.x < 0) and not shape.jumpThrough) then
  --    self.dx = 0
  --    self.x = startx + delta.x
  --  end

    -- self.rect:moveTo(self.x, self.y)

    -- for _, e in pairs(enemies.table) do
    --   if shape == e.rect then
    --     self:takeDamage(delta)
    --   end
    -- end

  -- end
end

function player:draw()
  if self.hitTimer > 30 then
    love.graphics.setColor(1,0,0)
    love.graphics.print("HIT!", self.x, self.y)
  end
  self.animation:draw(self.spriteSheet,math.floor(self.x+4),math.ceil(self.y+8),nil,self.direction,1,8,8)
  love.graphics.setColor(1,1,1)
end

function player:keypressed(key)
  if key == "up" and (self.grounded or (self.powerups.doubleJump and self.jumpCount < 2)) then
    self.dy = self.jumpStrength
    self.grounded = false
    self.jumpCount = self.jumpCount + 1
  end

  if DEBUG_MODE then
    -- add debug controls here
  end
end

function player:keyreleased(key)
  if key == "up" and not self.grounded then
    if self.dy > self.shortJumpStrength then 
      self.dy = self.shortJumpStrength 
    end
  end
end

function player:getPowerup(type) 
  if type == "doubleJump" then
    self.powerups.doubleJump = true
  end
end

return player
