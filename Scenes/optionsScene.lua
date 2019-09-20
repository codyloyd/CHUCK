local class = require("lib/middleclass")
local Scene = require("Scenes/Scene")

local OptionsScene = class("OptionsScene", Scene)

function OptionsScene:initialize(changeSceneCallback, gameState)
  Scene.initialize(self, changeSceneCallback)
  self.gameState = gameState
  self.options = {
    {
      title = "Music Volume",
      value = sounds.options.musicVolume,
      callBack = function(self)
        sounds.setMusicVolume(self.value)
      end
    },
    {
      title = "SFX Volume",
      value = sounds.options.sfxVolume,
      callBack = function(self)
        sounds.setSfxVolume(self.value)
      end
    }
  }
  self.selectedOption = 1
end

function OptionsScene:draw()
  love.graphics.setColor(1,1,1)
  love.graphics.printf("OPTIONS", 0, 150, 800, "center")
  for i, opt in ipairs(self.options) do
    local selected = ""
    if i == self.selectedOption then
      selected = "=="
    end
    love.graphics.printf(selected..opt.title..": "..math.ceil(opt.value * 100)..selected, 0, 180 + i*24, 800, "center")
  end

  love.graphics.printf("Press X to mute all.", 0, 300, 800, "center")
  love.graphics.printf("Press Enter to go back.", 0, 550, 800, "center")
end

function OptionsScene:keypressed(key)
  if key == "return" then
    changeScene("START_SCENE")
  end
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

  if key == "left" then
    self.options[self.selectedOption].value = self.options[self.selectedOption].value - .05
    self.options[self.selectedOption]:callBack()
  end

  if key == "right" then
    self.options[self.selectedOption].value = self.options[self.selectedOption].value + .05
    self.options[self.selectedOption]:callBack()
  end

  if key == "x" then
    self.options[1].value = 0
    self.options[2].value = 0
    self.options[1]:callBack()
    self.options[2]:callBack()
  end
end

return OptionsScene
