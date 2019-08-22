function playerLoad()
  player = {}
  player.spriteSheet = love.graphics.newImage('KNIGHT_WHITE.png')
  player.x = 100
  player.y = 100
  player.grid = anim8.newGrid(16,16,64,64)
  player.walking = anim8.newAnimation(player.grid('1-4',2), 0.1)
  player.standing = anim8.newAnimation(player.grid('1-4',1), 0.3)
  player.jumping = anim8.newAnimation(player.grid('1-1',3), 1)
  player.animation = player.standing
  player.grounded = false
  player.direction = 1
  player.dx = 0
  player.dy = 0
  player.maxSpeed = 150
  player.gravity = 600
  player.jumpStrength = 260
  player.maxFallSpeed = 2000
  player.rect = HC.rectangle(0,0,8,16)

  player.jumpCount = 0

  player.powerups = {}
  player.powerups.doubleJump = true

  function player:setPosition(x ,y)
    self.x = x
    self.y = y
    self.rect:moveTo(self.x, self.y)
  end
end


function playerUpdate(dt)
  if settingGravity or settingJumpSpeed then return end

  player.animation:update(dt)

  -- gravity
  player.dy = math.min(player.dy - player.gravity * dt, player.maxFallSpeed)

  if love.keyboard.isDown("left") then
    player.dx = player.dx + 16 * player.maxSpeed * dt
    player.direction = -1
  end
  if love.keyboard.isDown("right") then
    player.dx = player.dx - 16 * player.maxSpeed * dt
    player.direction = 1
  end
  if not love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
    player.dx = player.dx * .3
  end
  if player.dx >= player.maxSpeed then
    player.dx = player.maxSpeed
  end
  if player.dx <= -player.maxSpeed then
    player.dx = -player.maxSpeed
  end
  if math.abs(player.dx) > 50 then
    player.animation = player.walking
  else 
    player.animation = player.standing
  end
  if not player.grounded then
    player.animation = player.jumping
  end

  if player.grounded then 
    player.jumpCount = 0
  end

  local startx = player.x
  local starty = player.y

  newx = player.x - player.dx * dt
  newy = player.y - player.dy * dt
  player:setPosition(newx, newy)

  for shape, delta in pairs(HC.collisions(player.rect)) do
    ---bottom collisions
    if (delta.y < 0 and delta.y > -4 and player.dy < 0) then 
      player.dy = 0
      player.y = starty
      player.rect:moveTo(player.x, player.y)
      player.grounded = true
    end
    --top collisions
    if (delta.y > 0 and not shape.jumpThrough) then
      player.dy = 0
      player.y = starty
      player.rect:moveTo(player.x, player.y)
    end
    --side collision
    if ((delta.x > 0 or delta.x < 0) and not shape.jumpThrough) then
      player.dx = 0
      player.x = startx
      player.rect:moveTo(player.x, player.y)
    end
  end
end

function playerDraw()
  player.animation:draw(player.spriteSheet,math.floor(player.x),math.ceil(player.y),nil,player.direction,1,8,8)
end

function playerKeypressed(key)
  if key == "up" and (player.grounded or (player.jumpCount < 2 and player.powerups.doubleJump)) then
    player.dy = player.jumpStrength
    player.grounded = false
    player.jumpCount = player.jumpCount + 1
  end

  if DEBUG_MODE then
    if key == "g" then
      settingGravity = true
    end
    if key == "j" then
      settingJumpSpeed = true
    end

    if key == "left" and settingGravity == true then
      player.gravity = player.gravity - 10
    end
    if key == "right" and settingGravity == true then
      player.gravity = player.gravity + 10
    end

    if key == "left" and settingJumpSpeed == true then
      player.jumpStrength = player.jumpStrength - 10
    end
    if key == "right" and settingJumpSpeed == true then
      player.jumpStrength = player.jumpStrength + 10
    end
  end
end

function playerKeyreleased(key)
  if DEBUG_MODE then
    if key == "g" then
      settingGravity = false
    end
    if key == "j" then
      settingJumpSpeed = false
    end
  end
end

function getPowerup(type) 
  if type == "doubleJump" then
    player.powerups.doubleJump = true
  end
end
