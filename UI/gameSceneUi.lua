local hud = {}
local pause = {}

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
    if key == "p" then
      table.insert( uiStack, pause.new(uiStack, gameState))
      gameState.score.tempTime = love.timer.getTime() - gameState.score.startTime
    end
  end

  function self:keyreleased(key)
  end

  return self
end

function pause.new(uiStack, gameState) 
  local self = {}
  function self:hasKeyboardControl() 
    return true 
  end

  function self:hasMouseControl() 
    return true
  end

  function self:update()
  end

  function self:draw()
    love.graphics.print( "Paused", love.graphics.getWidth()/4, love.graphics.getHeight()/4, 0, 4 )
  end

  function self:keypressed(key)
    if key == "p" then
      table.remove(uiStack)
      gameState.score.startTime = love.timer.getTime() - gameState.score.tempTime
      gameState.score.tempTime = nil
    end
  end

  function self:keyreleased(key)
  end

  return self
end

local root = hud
return root
