local sceneDirector = {}
local currentScene
local scenes = {
  START_SCENE = require("Scenes/startScene"),
  GAME_SCENE = require("Scenes/gameScene"),
  -- END_SCENE = require("Scenes/endScene")
}

function changeScene(sceneName) 
  currentScene = scenes[sceneName]:new(changeScene)
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
