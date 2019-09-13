local class = require("lib/middleclass")
local Scene = require("Scenes/Scene")

local StartScene = class("StartScene", Scene)

function StartScene:initialize(changeSceneCallback)
  Scene.initialize(self, changeSceneCallback)
end

function StartScene:draw()
  love.graphics.print( "Press 'enter' to go", 22, 88 )
  love.graphics.print( "Press 'p' to pause", 22, 88*2 )
end

function StartScene:keypressed(key)
  if key == "return" then
    changeScene(nil, "spawn")
  end
end

return StartScene