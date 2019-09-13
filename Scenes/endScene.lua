local class = require("lib/middleclass")
local Scene = require("Scenes/Scene")

local EndScene = class("EndScene", Scene)

function EndScene:initialize(changeSceneCallback)
  Scene.initialize(self, changeSceneCallback)
end

function EndScene:draw()
  love.graphics.setFont(bigfont)
  love.graphics.printf( "Congratulations! You've made it out of the dungeon! YOU WIN!", 0, 120, love.graphics.getWidth(), "center" )

  love.graphics.setFont(font)
  love.graphics.printf( "Briggs & Cody 2019", 0, 320, love.graphics.getWidth(), "center" )
end

function EndScene:keypressed(key)
  if key == "return" then
    changeScene("START_SCENE")
  end
end

return EndScene
