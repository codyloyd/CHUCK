local hud = {}
local pause = {}

function hud.new(uiStack, gameState) 
  local self = {}
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
    love.graphics.print( "Press 'i' to Pause", 16, 16 )
    love.graphics.print( "Press 'p' to suicide", 16, 32 )
    love.graphics.print( "Press 'esc' for DEBUG MODE", 16, 48 )
    love.graphics.print( gameState.player.health, 16, 99)
  end

  function self:keypressed(key)
    if key == "i" then
      table.insert( uiStack, pause.new(uiStack, gameState))
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
    if key == "i" then
      table.remove(uiStack)
    end
  end

  function self:keyreleased(key)
  end

  return self
end

local root = hud
return root
