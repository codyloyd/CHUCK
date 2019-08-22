local startScene = require "Scenes/startScene"
local gameScene = require "Scenes/gameScene"
local endScene = require "Scenes/endScene"

local sceneDirector = {}

local currentScene = "START_SCENE"

local function changeScene(sceneName) 
  currentScene = sceneName
end

local scenes = {
  START_SCENE = startScene.new(changeScene),
  GAME_SCENE = gameScene.new(changeScene),
  END_SCENE = endScene.new(changeScene)
}

function sceneDirector.draw() 
  scenes[currentScene].draw()
end

function sceneDirector.update(dt) 
  scenes[currentScene]:update(dt)
end

function sceneDirector.keypressed(key)
  scenes[currentScene]:keypressed(key)
end

function sceneDirector.keyreleased(key)
  scenes[currentScene]:keyreleased(key)
end


return sceneDirector
