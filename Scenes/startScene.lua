local class = require("lib/middleclass")
local Scene = require("Scenes/Scene")

local StartScene = class("StartScene", Scene)
local titleSprite = love.graphics.newImage("assets/title.png")

function StartScene:initialize(changeSceneCallback, gameState)
  Scene.initialize(self, changeSceneCallback)
  self.gameState = gameState
end

function StartScene:draw()
  love.graphics.setColor(57/256,64/256,113/256)
  love.graphics.rectangle("fill", 0,0,4000,4000)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(titleSprite, 120, 16, 0, 4, 4)
  love.graphics.setFont(bigfont)
  love.graphics.printf("The Adventures of Sir Charles the Small", love.graphics.getWidth()/2-200, 200, 400, "center")
  love.graphics.setFont(font)
  love.graphics.printf( "Press 'enter' to go", 0, 500, 800, "center")
  love.graphics.printf( "Press 'x' to fight!", 0, 530, 800, "center")
  love.graphics.printf( "Press 'p' to pause", 0, 560, 800, "center")
end

function StartScene:keypressed(key)
  if key == "return" then
    changeScene(nil, "spawn")
    self.gameState.score.startTime = os.time()
  end
end

return StartScene
