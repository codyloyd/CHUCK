local BasicGameScene = require("Scenes/BasicGameScene")

local sceneDirector = {}
local currentSceneName
local currentScene
local scenes = {
  START_SCENE = require("Scenes/startScene"),
  caves = BasicGameScene("map/TESTINGMAP.lua"),
  -- caves2 = BasicGameScene("map/caves2.lua")
  -- END_SCENE = require("Scenes/endScene")
}

local gameState = {
  scene = {
    current = nil,
    last = nil
  },
  player = {
    spawn = {
      scene = nil,
      spawnPoint = nil
    },
    powerups = {
      doubleJump = false,
      wallJump = false
    },
    health = 5,
    maxHealth = 5
  }
}

easeIn = function(t, b, c, d) 
    local t = t / d;
    return c*t*t + b;
  end 

local fadeTimer = 0

function changeScene(sceneName, reason) 
  fadeTimer = .5 

  gameState.scene.last = gameState.scene.current 
  gameState.scene.current = sceneName

  if reason == "spawn" then
    print(inspect(gameState.player))
    -- Spawn at last spawn point
    currentScene = scenes[gameState.player.spawn.scene or "caves"]:new(changeScene, gameState, gameState.player.spawn.spawnPoint or "start")
  else
    currentScene = scenes[sceneName]:new(changeScene, gameState)
  end
end

changeScene("START_SCENE")

function sceneDirector.draw() 
  currentScene:draw()
  love.graphics.setColor(0,0,0,easeIn(fadeTimer, .1, 1, .5))
  love.graphics.rectangle("fill",0,0,4000,4000)
  love.graphics.setColor(1,1,1)
end

function sceneDirector.update(dt) 
  if fadeTimer >= 0 then
    fadeTimer = fadeTimer - dt 
  end
  currentScene:update(dt)
end

function sceneDirector.keypressed(key)
  currentScene:keypressed(key)
end

function sceneDirector.keyreleased(key)
  currentScene:keyreleased(key)
end


return sceneDirector
