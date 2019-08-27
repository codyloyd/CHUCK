local scene = {}

function scene.new(changeScene)
  local self = {}
  -- uiStack "array"
  local uiStack = {}
  -- Instantiate a new ui Element (root)
  table.insert( uiStack, require("Scenes/gameSceneUi").new(uiStack) );

  world = bump.newWorld()
  sti = require('lib/sti')
  gameMap = sti("map/caves.lua", {"box2d"})
  player = require('player')
  enemies = require('enemies')
  camFunc = require('lib/camera')
  cam = camFunc()
 
  platforms = {}
  for i, obj in pairs(gameMap.layers["platforms"].objects) do
    local jumpThrough = obj.properties["jump-through"]
    spawnPlatform(obj.x,obj.y,obj.width,obj.height, jumpThrough)
  end

  function self:init()
  end

  function self:update(dt)
    -- Get top of the ui stack and decide to pause or not
    local ui = uiStack[#uiStack]
    ui:update()
    if not ui:hasKeyboardControl() or not ui:hasMouseControl() then
      gameMap:update(dt)
      player:update(dt)
      enemies:update(dt)
    end


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

  function self:draw()
    -- everything that should track with the camera goes in here
    love.graphics.scale(3)
    cam:attach()
      gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
      player:draw()
      enemies:draw()
     
      -- draw collision boxes
      if DEBUG_MODE then
        love.graphics.setColor(.5,0,1)
        -- player.rect:draw(fill)

        love.graphics.setColor(.25,.5,1)
        local items, len = world:getItems()
        for i, rect in pairs(items) do
          if rect.jumpThrough then 
            love.graphics.setColor(1,.5,0)
          else
            love.graphics.setColor(1,0,.5)
          end
          if rect.x and rect.y and rect.width and rect.height then
            love.graphics.rectangle("line", rect.x, rect.y, rect.width, rect.height)
          end
          if rect.x and rect.y and rect.w and rect.h then
            love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h)
          end
        end
      end

      love.graphics.setColor(1,1,1)
    cam:detach()

    --draw debug info
    if DEBUG_MODE then
    end

    -- Draw the UI stack
    for k, v in ipairs(uiStack) do
      v:draw()
    end
  end

  function self:keypressed(key)
    -- handle keypresses from the uiStack
    local ui = uiStack[#uiStack]

    -- ALWAYS call the ui's keypressed function
    ui:keypressed(key)

    if not ui:hasKeyboardControl() or not ui:hasMouseControl() then
      if key == "p" then
        changeScene("END_SCENE")
      end

      player:keypressed(key)
    end
  end

  function self:keyreleased(key)
    player:keyreleased(key)
  end

  return self
end

function spawnPlatform(x,y,width,height, jumpThrough)
  -- height 0 breaks it.. so if height happens to be 0, change it to 1
  height = height > 0 and height or 1
  width = width > 0 and width or 1

  local p = {
    name=platform,
    jumpThrough=jumpThrough,
    x=x,
    y=y,
    width=width,
    height=height
  }
  world:add(p,x,y,width,height)

  table.insert(platforms,p)
end

return scene
