local options = {}

function options.new(uiStack, gameState) 
  local self = {}
  self.options = {
    {
      title = "Music Volume",
      value = sounds.options.musicVolume,
      display = function(self)
        return math.ceil(self.value * 100)
      end,
      onChange = function(self, dir)
        if dir == "inc" then
          self.value = math.min(self.value + .05, 1)
        else
          self.value = math.max(self.value - .05, 0)
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
    -- {
    --   title = "Random Setting",
    --   value = true,
    --   display = function(self)
    --     return self.value and "On" or "Off"
    --   end,
    --   onChange = function(self)
    --     self.value = not self.value
    --   end
    -- }
  }
  self.selectedOption = 1

  function self:hasKeyboardControl() 
    return true 
  end

  function self:hasMouseControl() 
    return true
  end

  function self:update()
  end

  function self:draw()
    love.graphics.scale(1/1.5)
    love.graphics.setColor(0,0,0,.8)
    love.graphics.rectangle("fill", 0,0,4000,4000)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("OPTIONS", 0, 150, 800, "center")
    for i, opt in ipairs(self.options) do
      local selected = ""
      if i == self.selectedOption then
        selected = "=="
      end
      love.graphics.printf(selected..opt.title..": "..opt:display()..selected, 0, 180 + i*26, 800, "center")
    end

    love.graphics.printf( "Controls:", 0, 500, 800, "center")
    love.graphics.printf( "arrows to move, 'x' to fight!", 0, 530, 800, "center")
    love.graphics.printf( "Press 'esc' to pause/resume", 0, 560, 800, "center")
  end

  function self:keypressed(key)
    -- if key == "return" then
    --   changeScene("START_SCENE")
    -- end
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

    if key == "escape" then
      table.remove(uiStack)
      if gameState.score and gameState.score.startTime and gameState.score.tempTime then
        gameState.score.startTime = love.timer.getTime() - gameState.score.tempTime
        gameState.score.tempTime = nil
      end
    end
  end

  function self:keyreleased(key)
  end

  return self
end

return options

