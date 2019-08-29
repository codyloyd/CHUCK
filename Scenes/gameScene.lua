local sti = require('lib/sti')
local class = require("lib/middleclass")

local EnemySpawner = require("enemies")
local PowerupSpawner = require('powerups')
local Player = require('player')
local Scene = require("Scenes/Scene")

local GameScene = class("GameScene", Scene)

local function spawnPlatform(x,y,w,h, jumpThrough)
  -- height 0 breaks it.. so if height happens to be 0, change it to 1
  h = h > 0 and h or 1
  w = w > 0 and w or 1

  local p = {
    jumpThrough=jumpThrough,
    x=x,
    y=y,
    w=w,
    h=h
  }

  return p
end

function GameScene:initialize(changeSceneCallback)
  Scene.initialize(self, changeSceneCallback)

  self.uiStack = {}
  -- Instantiate a new ui Element (root)
  table.insert( self.uiStack, require("Scenes/gameSceneUi").new(uiStack) );

  self.world = bump.newWorld()
  self.gameMap = sti("map/caves.lua", {"box2d"})

  -- Entities
  self.enemies = EnemySpawner:new(self.gameMap, self.world)
  self.powerups = PowerupSpawner:new(self.gameMap, self.world)
  self.player = Player:new(self.gameMap, self.world)

  self.camFunc = require('lib/camera')
  self.cam = self.camFunc()
 
  self.platforms = {}
  for i, obj in pairs(self.gameMap.layers["platforms"].objects) do
    local jumpThrough = obj.properties["jump-through"]
    local p = spawnPlatform(obj.x,obj.y,obj.width,obj.height, jumpThrough)
    self.world:add(p,p.x,p.y,p.w,p.h)
    table.insert(self.platforms, p)
  end
end

function GameScene:update(dt)
  -- Get top of the ui stack and decide to pause or not
  local ui = self.uiStack[#self.uiStack]
  ui:update()
  if not ui:hasKeyboardControl() or not ui:hasMouseControl() then
    self.gameMap:update(dt)
    self.player:update(dt)
    self.enemies:update(dt)
    self.powerups:update(dt)
  end


  -- moves the camera
  local camX = self.player.x + love.graphics.getWidth()/3;
  local camY = self.player.y + love.graphics.getHeight()/3;
  if camX < 400 then camX = 400 end
  if camY < 300 then camY = 300 end
  if camY > 2048 - 200 then camY = 2048- 200 end 
  if camX > 6400 - 300 then camX = 6400 - 300 end
  cameraWindowSize = 7
  local xmin = love.graphics.getWidth()/2 - cameraWindowSize 
  local xmax = love.graphics.getWidth()/2 + cameraWindowSize 
  local ymin = love.graphics.getHeight()/2 - cameraWindowSize
  local ymax = love.graphics.getHeight()/2 + cameraWindowSize
  self.cam:lockWindow(camX, camY, xmin, xmax, ymin, ymax, self.camFunc.smooth.damped(15))
end

function GameScene:draw()
  -- everything that should track with the camera goes in here
  love.graphics.scale(3)
  self.cam:attach()
    self.gameMap:drawLayer(self.gameMap.layers["Tile Layer 1"])
    self.powerups:draw()
    self.player:draw()
    self.enemies:draw()
    
    -- draw collision boxes
    if DEBUG_MODE then
      love.graphics.setColor(.25,.5,1)
      local items, len = self.world:getItems()
      for i, rect in pairs(items) do
        if rect.jumpThrough then 
          love.graphics.setColor(1,.5,0)
        elseif rect == self.player.attackBox then
          love.graphics.setColor(.5, 1, 0)
        elseif rect == self.player then
          love.graphics.setColor( .5, .5,  1)
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
  self.cam:detach()

  --draw debug info
  if DEBUG_MODE then
  end

  -- Draw the UI stack
  for k, v in ipairs(self.uiStack) do
    v:draw()
  end
end

function GameScene:keypressed(key)
  -- handle keypresses from the uiStack
  local ui = self.uiStack[#self.uiStack]

  -- ALWAYS call the ui's keypressed function
  ui:keypressed(key)

  if not ui:hasKeyboardControl() or not ui:hasMouseControl() then
    if key == "p" then
      changeScene("END_SCENE")
    end

    self.player:keypressed(key)
  end
end

function GameScene:keyreleased(key)
  self.player:keyreleased(key)
end

return GameScene
