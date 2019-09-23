local hud = {}
local pause = require("UI/optionsScreen")

function hud.new(uiStack, gameState) 
  local self = {}
  self.healthSprite = love.graphics.newImage("assets/HEALTH.png")
  self.healthSprite_empty = love.graphics.newImage("assets/HEALTH_EMPTY.png")
  function self:hasKeyboardControl() 
    return false 
  end

  function self:hasMouseControl() 
    return false
  end

  function self:update()
  end

  function self:draw()
    love.graphics.scale(.5,.5)

    for i=1,gameState.player.maxHealth do
      if i <= gameState.player.health then
        love.graphics.draw(self.healthSprite, 16 + ((16 * (i - 1)) * 2), 8, 0, 2)
      else
        love.graphics.draw(self.healthSprite_empty, 16 + ((16 * (i - 1)) * 2), 8, 0, 2)
      end
    end
  end

  function self:keypressed(key)
    if key == "escape" then
      table.insert( uiStack, pause.new(uiStack, gameState))
      if gameState.score and gameState.score.startTime then
        gameState.score.tempTime = love.timer.getTime() - gameState.score.startTime
      end
    end
  end

  function self:keyreleased(key)
  end

  return self
end


local root = hud
return root
