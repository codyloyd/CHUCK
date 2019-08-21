function playerLoad()
  player = {}
  player.spriteSheet = love.graphics.newImage('dude.png')
  player.body = love.physics.newBody(myWorld, 201,100,"dynamic")
  player.shape = love.physics.newRectangleShape(32,64)
  player.fixture = love.physics.newFixture(player.body,player.shape)
  player.grid = anim8.newGrid(64,64,512,128)
  player.walking = anim8.newAnimation(player.grid('1-7',1), 0.1)
  player.standing = anim8.newAnimation(player.grid('8-8',1),1)
  player.jumping = anim8.newAnimation(player.grid('1-1',2),1)
  player.animation = player.standing
  player.grounded = false
  player.direction = 1
  player.body:setFixedRotation(true)
  player.dx = 0
  player.maxSpeed = 450
end

function playerUpdate(dt)
  player.animation:update(dt)
  if love.keyboard.isDown("left") then
    player.dx = player.dx + 4 * player.maxSpeed * dt
    player.direction = -1
  end
  if love.keyboard.isDown("right") then
    player.dx = player.dx - 4 * player.maxSpeed * dt
    player.direction = 1
  end
  if not love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
    player.dx = player.dx * .9
  end
  if player.dx >= player.maxSpeed then
    player.dx = player.maxSpeed
  end
  if player.dx <= -player.maxSpeed then
    player.dx = -player.maxSpeed
  end
  if math.abs(player.dx) > 100 then
    player.animation = player.walking
  else 
    player.animation = player.standing
  end
  if not player.grounded then
    player.animation = player.jumping
  end
  player.body:setX(player.body:getX() - player.dx * dt)
end

function playerDraw()
  player.animation:draw(player.spriteSheet,math.floor(player.body:getX()),math.ceil(player.body:getY()),nil,player.direction,1,32,32)
end

function playerKeypressed(key)
  if key == "up" and player.grounded then
    player.body:applyLinearImpulse(0,-2525)
    player.grounded = false
  end
end
