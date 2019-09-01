local sti = require('lib/sti')
local class = require("lib/middleclass")

local EnemySpawner = require("enemies")
local PowerupSpawner = require('powerups')
local Player = require('player')
local Platform = require("entities/Platform")
local Trigger = require("entities/Trigger")
local Scene = require("Scenes/Scene")

-- UI
local TextboxUi = require("Scenes/TextboxUi")

local GameScene = class("GameScene", Scene)

function GameScene:initialize(changeSceneCallback, gameState, map)
  Scene.initialize(self, changeSceneCallback)
  self.setInitialCameraPosition = true
  self.screenShakeTimer = 0

  self.uiStack = {}
  -- Instantiate a new ui Element (root)
  table.insert( self.uiStack, require("Scenes/gameSceneUi").new(self.uiStack, gameState) );

  self.world = bump.newWorld()
  self.gameMap = sti(map, {"box2d"})

  -- Entities
  self.enemies = EnemySpawner:new(self.gameMap, self.world, gameState)
  self.powerups = PowerupSpawner:new(self.gameMap, self.world, gameState)

  local spawnPoint = {}
  for _,obj in pairs(self.gameMap.layers["spawn"].objects) do
    if gameState.scene.last == "START_SCENE" and obj.name == "start" then 
      spawnPoint = obj
    end

    if gameState.scene.last == obj.name then
      spawnPoint = obj
    end
  end

  local function screenShake()
    self.screenShakeTimer = .3
  end

  local function eventHandler(event, data)
    if event == "take-damage" then 
      screenShake() 
    elseif event == "got-powerup" then
      if data == "doubleJump" then
        table.insert( self.uiStack, TextboxUi.new(self.uiStack, "You have acquired the doublejump skill. Press jump twice for a greater jump."))
      elseif data == "wallJump" then
        table.insert( self.uiStack, TextboxUi.new(self.uiStack, "You have acquired the magic gloves. When jumping into walls, hold the direction and press jump to jump away from the wall or hold the initial direction to descend slowly."))
      end
    else
      print(event, "--event not handled")
    end
  end

  self.player = Player:new(self.gameMap, self.world, gameState.player, {x=spawnPoint.x, y=spawnPoint.y}, eventHandler)

  self.camFunc = require('lib/camera')
  self.cam = self.camFunc()
 
  self.platforms = {}
  for i, obj in pairs(self.gameMap.layers["platforms"].objects) do
    local jumpThrough = obj.properties["jump-through"]
    local p = Platform:new({
      x=obj.x,
      y=obj.y, 
      h=obj.height, 
      w=obj.width, 
      jumpThrough=jumpThrough
    }, self.world) 

    table.insert(self.platforms, p)
  end

  self.triggers = {}
  if(self.gameMap.layers["triggers"]) then
    for _, trig in pairs(self.gameMap.layers["triggers"].objects) do
      local t = Trigger:new({
        x=trig.x,
        y=trig.y, 
        h=trig.height, 
        w=trig.width, 
        name=trig.name,
        triggerType=trig.type,
        action=trig.properties.action
      }, self.world) 

      table.insert(self.triggers, t)
    end
  end

end

local function triggerFilter(item)
  if item.class and item.class.name ~= "Player" then 
    return nil 
  end

  return "cross"
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
  
    for _, trig in pairs(self.triggers) do
      local items, len = self.world:queryRect(trig.x,trig.y,trig.w,trig.h, triggerFilter)
      if len > 0 then
        self.changeSceneCallback(trig.action)
      end
    end
  end


  -- moves the camera
  local camX = self.player.x + love.graphics.getWidth()/3;
  local camY = self.player.y + love.graphics.getHeight()/3;
  local mapW = self.gameMap.layers["background"].width * 8
  local mapH = self.gameMap.layers["background"].height * 8
  local halfW = love.graphics.getWidth()/2
  local halfH = love.graphics.getHeight()/2
  if camX < halfW then camX = halfW end
  if camY < halfH then camY = halfH end
  if camX > mapW + halfW/3 then camX = mapW + halfW/3 end
  if camY > mapH + halfH/3 then camY = mapH + halfH/3 end
  cameraWindowSize = 3
  local xmin = love.graphics.getWidth()/2 - cameraWindowSize 
  local xmax = love.graphics.getWidth()/2 + cameraWindowSize 
  local ymin = love.graphics.getHeight()/2 - cameraWindowSize
  local ymax = love.graphics.getHeight()/2 + cameraWindowSize
  if self.setInitialCameraPosition then
    self.cam:lookAt(camX, camY)
    self.setInitialCameraPosition = false
  end
  if self.screenShakeTimer > 0 then
    self.screenShakeTimer = self.screenShakeTimer - dt
    local randomX = math.random(-1,1)
    local randomY = math.random(-1,1)
    self.cam:lookAt(camX + randomX, camY + randomY)
  end
  self.cam:lockWindow(camX, camY, xmin, xmax, ymin, ymax, self.camFunc.smooth.damped(15))
end

function GameScene:draw()
  -- everything that should track with the camera goes in here
  love.graphics.scale(3)
  self.cam:attach()
    self.gameMap:drawLayer(self.gameMap.layers["background"])
    self.gameMap:drawLayer(self.gameMap.layers["lights"])
    self.powerups:draw()
    self.enemies:draw()
    self.player:draw()
    self.gameMap:drawLayer(self.gameMap.layers["foreground"])
    
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
