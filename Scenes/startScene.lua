local class = require("lib/middleclass")
local Scene = require("Scenes/Scene")

local StartScene = class("StartScene", Scene)
local titleSprite = love.graphics.newImage("assets/title.png")

function StartScene:initialize(changeSceneCallback, gameState)
  Scene.initialize(self, changeSceneCallback)
  self.gameState = gameState
  self.options = {
    {
      title = "Start new game",
      onSelect = function()
        changeScene(nil, "spawn")
        self.gameState.score.startTime = love.timer.getTime()
      end
    },
    {
      title = "Options",
      onSelect = function()
        changeScene("OPTIONS_SCENE")
      end
    }
  }
  self.selectedOption = 1
end

function StartScene:draw()
  love.graphics.setColor(57/256,64/256,113/256)
  love.graphics.rectangle("fill", 0,0,4000,4000)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(titleSprite, 120, 16, 0, 4, 4)
  love.graphics.setFont(bigfont)
  love.graphics.printf("The Adventures of Sir Charles the " .. (SPEEDRUN_MODE and "Swift" or "Small"), love.graphics.getWidth()/2-200, 200, 400, "center")

  love.graphics.setFont(font)
  for i,opt in ipairs(self.options) do
    local selected = ""
    if i == self.selectedOption then
      selected = "=="
    end
    love.graphics.printf(selected..opt.title..selected, 0, 480 + i*26, 800, "center")
  end

end

function StartScene:keypressed(key)
  if key == "up" then
    self.selectedOption = self.selectedOption - 1
  end

  if key == "down" then
    self.selectedOption = self.selectedOption + 1
  end

  if self.selectedOption > #self.options then
    self.selectedOption = 1
  elseif self.selectedOption < 1 then
    self.selectedOption = #self.options
  end

  if key == "return" then
    self.options[self.selectedOption].onSelect()
  end

  if  key == "backspace" then
     SPEEDRUN_MODE = not SPEEDRUN_MODE
  end
end

return StartScene
