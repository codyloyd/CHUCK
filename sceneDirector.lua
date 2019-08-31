local sceneDirector = {}
local currentScene
local scenes = {
  START_SCENE = require("Scenes/startScene"),
  caves = require("Scenes/caves"),
  caves2 = require("Scenes/caves2")
  -- GAME_SCENE = require("Scenes/gameScene"),
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
