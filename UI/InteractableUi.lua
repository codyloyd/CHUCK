local interactableUi = {}

function interactableUi.new(uiStack, message, eventHandler, location) 
  local self = {}
  self.message = message
  self.sendEvent = eventHandler
  self.x = location.x
  self.y = location.y
  self.limit = location.limit
  self.interacting = false

  function self:hasKeyboardControl() 
    return false
  end

  function self:hasMouseControl() 
    return false
  end

  function self:update(dt)
  end

  function self:draw()
    love.graphics.setColor(239/256,231/256,206/256)
    love.graphics.printf(self.message, self.x, self.y, self.limit*3, "center", 0, 1/3, 1/3)
    love.graphics.setColor(1,1,1)
  end

  function self:keypressed(key)
    if key == "z" then
      self.sendEvent()
    end
  end

  function self:keyreleased(key)
  end

  return self
end

local root = interactableUi
return root
