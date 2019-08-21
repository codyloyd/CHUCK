function enemiesLoad()
  enemies = {}
  for i, e in pairs(gameMap.layers["enemies"].objects) do
    spawnEnemy(e.x,e.y)
  end
end

function enemiesUpdate(dt)
  for i, e in ipairs(enemies) do
    e.animation:update(dt)
    e.body:setX(e.body:getX() - e.dx * dt)
  end
end

function enemiesDraw()
  for i, e in ipairs(enemies) do
    e.animation:draw(e.spriteSheet,math.ceil(e.body:getX()),math.ceil(e.body:getY()),nil,nil,nil,32,32)
  end
end

function spawnEnemy(x,y,direction)
  local e = {}
  e.spriteSheet = love.graphics.newImage('monster.png')
  e.body = love.physics.newBody(myWorld,x,y,"dynamic")
  e.shape = love.physics.newRectangleShape(64,64)
  e.fixture = love.physics.newFixture(e.body,e.shape)
  e.grid = anim8.newGrid(64,64,64,64)
  e.animation = anim8.newAnimation(e.grid('1-1',1),.1)
  e.direction = 1
  e.dx = 100
  e.body:setFixedRotation(true)
  table.insert(enemies,e)
end 
