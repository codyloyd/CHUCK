local sti = require('lib/sti')
local class = require("lib/middleclass")

local EnemySpawner = require("enemies")
local PowerupSpawner = require('powerups')
local TriggerSpawner = require("triggers")
local Door = require("doors")
local InteractableSpawner = require("interactables")
local Player = require('player')
local Platform = require("entities/Platform")
local Scene = require("Scenes/Scene")

-- UI
local TextboxUi = require("UI/TextboxUi")

local GameScene = class("GameScene", Scene)

local healthSprite = love.graphics.newImage("assets/HEALTH.png")

function GameScene:initialize(changeSceneCallback, gameState, playerSpawn, map)
  Scene.initialize(self, changeSceneCallback)
  self.gameState = gameState
  self.setInitialCameraPosition = true
  self.screenShakeTimer = 0
  self.respawnTimer = 0

  self.enemyDrops = {}

  -- for UI attached to the screen
  self.uiStack = {}
  -- Instantiate a new ui Element (root)
  table.insert( self.uiStack, require("UI/gameSceneUi").new(self.uiStack, gameState) );

  -- For UI attached to the world instead of the screen
  self.worldUiStack = {}

  self.world = bump.newWorld()
  self.gameMap = sti(map, {"box2d"})

  local function screenShake()
    self.screenShakeTimer = .3
  end

  local function eventHandler(event, data)
    if event == "take-damage" then 
      screenShake() 
    elseif event == "got-powerup" then
      if data == "doubleJump" then
        table.insert( self.uiStack, TextboxUi.new(self.uiStack, "You have acquired the magic boots. Press jump twice for a greater jump."))
      elseif data == "wallJump" then
        table.insert( self.uiStack, TextboxUi.new(self.uiStack, "You have acquired the magic gloves. When jumping into walls, hold the direction and press jump to jump away from the wall or hold the initial direction to descend slowly."))
      end

      self.gameState.player.spawn.scene = self.gameState.scene.current
      self.gameState.player.spawn.spawnPoint = "powerup-spawn"
      sounds.powerup:play()
    elseif event == "open-door" then
      -- Open a door
      self.door:deactivate()
    elseif event == "player-death" then
      self.respawnTimer = 2
    elseif event == "dropHealth" then
      if self.player.health < self.player.maxHealth then
        local drop = {
            dropType = "health",
            x = data.x,
            y = data.y-8,
            life = 5
        }
        self.world:add(drop, drop.x, drop.y, 8, 8)
        table.insert(self.enemyDrops, drop)
      end
    else
      print(event, "--event not handled")
    end
  end

  -- Entities
  self.enemies = EnemySpawner:new(self.gameMap, self.world, gameState, eventHandler)
  self.powerups = PowerupSpawner:new(self.gameMap, self.world, gameState)
  self.triggers = TriggerSpawner:new(self.gameMap, self.world, gameState, changeSceneCallback)
  self.interactables = InteractableSpawner:new(self.gameMap, self.world, gameState, self.worldUiStack, eventHandler, self.player)
  self.door = Door:new(self.gameMap, self.world, gameState)

  local spawnPoint = {}
  for _,obj in pairs(self.gameMap.layers["spawn"].objects) do
    if playerSpawn ~= nil and playerSpawn == obj.name then
      spawnPoint = obj
      break
    end

    if gameState.scene.last == "START_SCENE" and obj.name == "start" then 
      spawnPoint = obj
      break
    end

    if gameState.scene.last == obj.name and playerSpawn == nil then
      spawnPoint = obj
      break
    end
  end

  self.player = Player:new(self.gameMap, self.world, gameState.player, {x=spawnPoint.x, y=spawnPoint.y}, eventHandler)

  self.camFunc = require('lib/camera')
  self.cam = self.camFunc()
 
  self.platforms = {}
  for i, obj in pairs(self.gameMap.layers["platforms"].objects) do
    local jumpThrough = obj.properties["jump-through"]
    local spikes = obj.name == "spikes"
    local p = Platform:new({
      x=obj.x,
      y=obj.y, 
      h=obj.height, 
      w=obj.width, 
      jumpThrough=jumpThrough,
      spikes=spikes
    }, self.world) 

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
    self.triggers:update(dt)
    self.interactables:update(dt)
    particles:update(dt)

    -- update enemy drops
    for i, d in ipairs(self.enemyDrops) do 
      if d.life > 0 then 
        d.life = d.life - dt
      end
      if d.life <= 0 then
        self.world:remove(d)
        table.remove(self.enemyDrops, i)
      end
    end

    if self.player.dead then
      self.respawnTimer = self.respawnTimer - dt
      if self.respawnTimer < 0 then
        self.changeSceneCallback(nil, 'spawn')
      end
    end

    if #self.worldUiStack > 0 then
      self.worldUiStack[#self.worldUiStack]:update()
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
    self.triggers:draw()
    self.interactables:draw()

    -- draw enemy drops
    for i, d in pairs(self.enemyDrops) do 
      if d.dropType == "health" then 
        love.graphics.draw(healthSprite, d.x, d.y)
      end
    end

    self.door:draw()
    particles:draw()
    
    -- draw collision boxes
    if DEBUG_MODE then
      love.graphics.setColor(.25,.5,1)
      local items, len = self.world:getItems()
      for i, rect in pairs(items) do
        if rect.jumpThrough then 
          love.graphics.setColor(.1,.5,0)
        elseif rect.spikes then
          love.graphics.setColor(.125,.25,1)
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

    -- Draw world UI
    for k, v in ipairs(self.worldUiStack) do
      v:draw()
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
    self.player:keypressed(key)
    if self.worldUiStack[#self.worldUiStack] then
      self.worldUiStack[#self.worldUiStack]:keypressed(key)
    end
  end
end

function GameScene:keyreleased(key)
  self.player:keyreleased(key)
end

return GameScene
