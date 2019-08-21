function love.load()
  love.graphics.setBackgroundColor(129,188,257)
  myWorld = love.physics.newWorld(0,2500,false)
  myWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)
  anim8 = require('lib/anim8')

  require('player')
  require('enemies')
  camFunc = require('lib/camera')
  cam = camFunc()
  
  sti = require('lib/sti')
  gameMap = sti("map/dirtngrasslevel.lua", {"box2d"})

  playerLoad()
  enemiesLoad()

  platforms = {}

  for i, obj in pairs(gameMap.layers["platforms"].objects) do
    spawnPlatform(obj.x,obj.y,obj.width,obj.height)
  end
end

function love.update(dt)
  gameMap:update(dt)
  myWorld:update(dt)
  playerUpdate(dt)
  enemiesUpdate(dt)
  local camX = player.body:getX()
  local camY = player.body:getY()
  if camX < 300 then camX = 300 end
  if camY < 200 then camY = 200 end
  if camY > 2048 - 200 then camY = 2048- 200 end 
  if camX > 6400 - 300 then camX = 6400 - 300 end
  cam:lockWindow(math.ceil(camX),math.ceil(camY),300,love.graphics.getWidth()-300,200,love.graphics.getHeight()-200, camFunc.smooth.damped(15))
end

function love.draw()
  cam:attach()
  gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
  playerDraw()
  enemiesDraw()
  cam:detach()
  -- print(cam:position())
end

function love.keypressed(key)
  playerKeypressed(key)
end

function spawnPlatform(x,y,width,height)
  local p = {}
  p.body = love.physics.newBody(myWorld, x, y, "static")
  p.shape = love.physics.newRectangleShape(width/2, height/2, width, height)
  p.fixture = love.physics.newFixture(p.body, p.shape)
  p.width = width
  p.height = height

  table.insert(platforms,p)
end

function beginContact(a,b,coll)
  for i, p in ipairs(platforms) do
    if a == player.fixture and b == p.fixture then
      player.grounded = true
    end
  end 
  for i, e in ipairs(enemies) do
    if a == player.fixture 
      and b == e.fixture then
      print("OUCH")
    end 
    if a ==  e.fixture or b == e.fixture then
      e.dx = -e.dx
    end
  end
end

function endContact(a,b,coll)
  local x1, y1, x2, y2 = a:getBoundingBox()
  local xx1, yy1, xx2, yy2 = b:getBoundingBox()
  if (math.ceil(y2) <= math.ceil(yy1)) then
    player.grounded = false
  end
end
