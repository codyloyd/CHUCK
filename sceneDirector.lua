local BasicGameScene = require("Scenes/BasicGameScene")

local sceneDirector = {}
local currentSceneName
local currentScene
local scenes = {
  START_SCENE = require("Scenes/startScene"),
  caves = BasicGameScene("map/caves.lua"),
  caves2 = BasicGameScene("map/caves2.lua")
  -- END_SCENE = require("Scenes/endScene")
}

local fadeTimer = 0

local gameState = {
  scene = {
    last = nill
  },
  player = {
    powerups = {
      doubleJump = false,
      wallJump = false
    },
    -- health = 100,
  }
}
easeIn = function(t, b, c, d) 
    local t = t / d;
    return c*t*t + b;
  end 

function changeScene(sceneName) 
  fadeTimer = .5 
  gameState.scene.last = currentSceneName
  currentSceneName = sceneName
  currentScene = scenes[sceneName]:new(changeScene, gameState)
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
