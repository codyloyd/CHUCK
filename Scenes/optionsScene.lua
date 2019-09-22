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
      display = function(self)
        return math.ceil(self.value * 100)
      end,
      onChange = function(self, dir)
        if dir == "inc" then
          self.value = self.value + .05
        else
          self.value = self.value - .05
        end
        sounds.setMusicVolume(self.value)
      end
    },
    {
      title = "SFX Volume",
      value = sounds.options.sfxVolume,
      display = function(self)
        return math.ceil(self.value * 100)
      end,
      onChange = function(self, dir)
        if dir == "inc" then
          self.value = self.value + .05
        else
          self.value = self.value - .05
        end
        sounds.setSfxVolume(self.value)
      end,
    },
    {
      title = "Mute all",
      value = false,
      display = function(self)
        return self.value and "On" or "Off"
      end,
      onChange = function(self)
        self.value = not self.value
        if self.value == true then
          self.cachedSfx = sounds.options.sfxVolume
          self.cachedMusic = sounds.options.musicVolume
          sounds.setSfxVolume(0)
          sounds.setMusicVolume(0)
        else
          sounds.setSfxVolume(self.cachedSfx or 1)
          sounds.setMusicVolume(self.cachedMusic or 1)
        end
      end
    },
    {
      title = "Random Setting",
      value = true,
      display = function(self)
        return self.value and "On" or "Off"
      end,
      onChange = function(self)
        self.value = not self.value
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
    love.graphics.printf(selected..opt.title..": "..opt:display()..selected, 0, 180 + i*26, 800, "center")
  end

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
    self.options[self.selectedOption].onChange(self.options[self.selectedOption],"dec")
  end

  if key == "right" then
    self.options[self.selectedOption].onChange(self.options[self.selectedOption],"inc")
  end
end

return OptionsScene
