local interactableUi = {}

function interactableUi.new(uiStack, message, action, location) 
  local self = {}
  self.message = message
  self.action = action
  self.x = location.x
  self.y = location.y

  function self:hasKeyboardControl() 
    return false
  end

  function self:hasMouseControl() 
    return false
  end

  function self:update(dt)
  end

  function self:draw()
    love.graphics.print(self.message, location.x, location.y)
  end

  function self:keypressed(key)
    if key == "z" then
      table.remove(uiStack)
    end
  end

  function self:keyreleased(key)
  end

  return self
end

local root = interactableUi
return root
