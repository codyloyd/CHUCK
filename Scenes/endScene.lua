local class = require("lib/middleclass")
local Scene = require("Scenes/Scene")

local EndScene = class("EndScene", Scene)

function EndScene:initialize(changeSceneCallback, gameScene)
  Scene.initialize(self, changeSceneCallback)
  self.gameScene = gameScene
  self.gameScene.score.endTime = love.timer.getTime()
end

function EndScene:draw()
  love.graphics.setFont(bigfont)
  love.graphics.printf( "Congratulations! You've made it out of the dungeon! YOU WIN!", 0, 120, love.graphics.getWidth(), "center" )

  love.graphics.setFont(font)
  local timeString = string.format("Time to Completion: %.2f\n", self.gameScene.score.endTime - self.gameScene.score.startTime)
  love.graphics.printf( timeString, 0, 225, love.graphics.getWidth(), "center" )

  local deathString = string.format("Times Died: %d\n", self.gameScene.score.deaths)
  love.graphics.printf( deathString, 0, 252.5, love.graphics.getWidth(), "center" )

  local killString = string.format("Enemies Massacred: %d\n", self.gameScene.score.kills)
  love.graphics.printf( killString, 0, 280, love.graphics.getWidth(), "center" )

  love.graphics.printf( "Briggs & Cody 2019", 0, 520, love.graphics.getWidth(), "center" )
end

function EndScene:keypressed(key)
  if key == "return" then
    changeScene("START_SCENE")
  end
end

return EndScene
