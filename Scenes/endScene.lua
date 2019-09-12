local class = require("lib/middleclass")
local Scene = require("Scenes/Scene")

local EndScene = class("EndScene", Scene)

function EndScene:initialize(changeSceneCallback)
  Scene.initialize(self, changeSceneCallback)
end

function EndScene:draw()
  love.graphics.print( "End of game, press 'ENTER'", 22, 88 )
end

function EndScene:keypressed(key)
  if key == "return" then
    changeScene("START_SCENE")
  end
end

return EndScene