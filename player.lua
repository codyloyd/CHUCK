function playerLoad()
  player = {}
  player.spriteSheet = love.graphics.newImage('KNIGHT_WHITE.png')
  player.body = love.physics.newBody(myWorld, 201,100,"dynamic")
  player.shape = love.physics.newRectangleShape(8,16)
  player.fixture = love.physics.newFixture(player.body,player.shape)
  player.grid = anim8.newGrid(16,16,64,64)
  player.walking = anim8.newAnimation(player.grid('1-4',2), 0.1)
  player.standing = anim8.newAnimation(player.grid('1-4',1), 0.3)
  player.jumping = anim8.newAnimation(player.grid('1-1',3), 1)
  player.animation = player.standing
  player.grounded = false
  player.direction = 1
  player.body:setFixedRotation(true)
  player.dx = 0
  player.maxSpeed = 150

  player.jumpCount = 0

  player.powerups = {}
  player.powerups.doubleJump = true
end

function playerUpdate(dt)
  player.animation:update(dt)
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

  player.body:setX(player.body:getX() - player.dx * dt)
end

function playerDraw()
  player.animation:draw(player.spriteSheet,math.floor(player.body:getX()),math.ceil(player.body:getY()),nil,player.direction,1,8,8)
end

function playerKeypressed(key)
  if key == "up" and (player.grounded or (player.jumpCount < 2 and player.powerups.doubleJump)) then
    player.body:setLinearVelocity(0,-385)
    player.grounded = false
    player.jumpCount = player.jumpCount + 1
  end
end

function getPowerup(type) 
  if type == "doubleJump" then
    player.powerups.doubleJump = true
  end
end
