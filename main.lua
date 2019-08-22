inspect = require('./lib/inspect')

function love.load()
  DEBUG_MODE = false
  love.graphics.setBackgroundColor(0.5,.73,1)
  love.graphics.setDefaultFilter( "nearest" )
  anim8 = require('lib/anim8')
  HC = require('lib/HC')

  require('player')
  -- require('enemies')
  camFunc = require('lib/camera')
  cam = camFunc()
  
  sti = require('lib/sti')
  gameMap = sti("map/caves.lua", {"box2d"})

  playerLoad()
  -- enemiesLoad()

  platforms = {}

  for i, obj in pairs(gameMap.layers["platforms"].objects) do
    local jumpThrough = obj.properties["jump-through"]
    spawnPlatform(obj.x,obj.y,obj.width,obj.height, jumpThrough)
  end
end

function love.update(dt)
  gameMap:update(dt)

  playerUpdate(dt)

  -- enemiesUpdate(dt)

  -- moves the camera
  local camX = player.x + love.graphics.getWidth()/3;
  local camY = player.y + love.graphics.getHeight()/3;
  if camX < 400 then camX = 400 end
  if camY < 300 then camY = 300 end
  if camY > 2048 - 200 then camY = 2048- 200 end 
  if camX > 6400 - 300 then camX = 6400 - 300 end

  cameraWindowSize = 7
  local xmin = love.graphics.getWidth()/2 - cameraWindowSize 
  local xmax = love.graphics.getWidth()/2 + cameraWindowSize 
  local ymin = love.graphics.getHeight()/2 - cameraWindowSize
  local ymax = love.graphics.getHeight()/2 + cameraWindowSize
  cam:lockWindow(camX, camY, xmin, xmax, ymin, ymax, camFunc.smooth.damped(15))
end

function love.draw()
  love.graphics.scale(3)
  cam:attach()
    gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
    playerDraw()
    -- enemiesDraw()
   
    -- draw collision boxes
    if DEBUG_MODE then
      love.graphics.setColor(.5,0,1)
      player.rect:draw(fill)
      for i, rect in pairs(platforms) do
        if rect.jumpThrough then 
          love.graphics.setColor(1,.5,0)
        else
          love.graphics.setColor(1,0,.5)
        end
        rect:draw(fill)
      end
    end

    love.graphics.setColor(1,1,1)
  cam:detach()

  -- draw gravity etc.
  if DEBUG_MODE then
    love.graphics.scale(.5,.5)
    love.graphics.print("gravity: "..player.gravity,0,0)
    love.graphics.print("jumpStrength: "..player.jumpStrength,0,32)
  end
end

function love.keypressed(key)
  if key == "escape" then
    DEBUG_MODE = not DEBUG_MODE
  end

  playerKeypressed(key)
end
function love.keyreleased(key)
  playerKeyreleased(key)
end

function spawnPlatform(x,y,width,height, jumpThrough)
  -- height 0 breaks it.. so if height happens to be 0, change it to 1
  height = height > 0 and height or 1
  width = width > 0 and width or 1

  local p = HC.rectangle(x,y,width,height) 
  p.jumpThrough = jumpThrough
  table.insert(platforms,p)
end
