local class = require("lib/middleclass")
local Scene = require("Scenes/Scene")

local OptionsScene = class("OptionsScene", Scene)

function OptionsScene:initialize(changeSceneCallback, gameState)
  self.uiStack = {}
  table.insert( self.uiStack, require("UI/optionsScreen").new(self.uiStack, gameState) );
end

function OptionsScene:draw()
  -- we should probably refactor out all these scaling things sometime 
  -- by drawing the mapstuff to a canvas
  love.graphics.scale(1.5)
  for k, v in ipairs(self.uiStack) do
    v:draw()
  end
  love.graphics.scale(1/1.5)
end

function OptionsScene:update()
  local ui = self.uiStack[#self.uiStack]
  ui:update()
end

function OptionsScene:keypressed(key)
  local ui = self.uiStack[#self.uiStack]
  ui:keypressed(key)

  if key == "escape" then
    changeScene("START_SCENE")
  end
end

return OptionsScene
