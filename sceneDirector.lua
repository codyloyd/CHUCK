local BasicGameScene = require("Scenes/BasicGameScene")

local sceneDirector = {}
local currentScene
local scenes = {
  START_SCENE = require("Scenes/startScene"),
  caves = BasicGameScene("map/caves.lua"),
  caves2 = BasicGameScene("map/caves2.lua")
  -- END_SCENE = require("Scenes/endScene")
}

local gameState = {
  player = {
    powerups = {
      doubleJump = false,
      wallJump = false
    },
    -- health = 100,
  }
}

function changeScene(sceneName) 
  currentScene = scenes[sceneName]:new(changeScene, gameState)
end

changeScene("START_SCENE")

function sceneDirector.draw() 
  currentScene:draw()
end

function sceneDirector.update(dt) 
  currentScene:update(dt)
end

function sceneDirector.keypressed(key)
  currentScene:keypressed(key)
end

function sceneDirector.keyreleased(key)
  currentScene:keyreleased(key)
end


return sceneDirector
