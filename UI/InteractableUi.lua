local interactableUi = {}

function interactableUi.new(uiStack, message, eventHandler, location) 
  local self = {}
  self.message = message
  self.sendEvent = eventHandler
  self.x = location.x
  self.y = location.y
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
    love.graphics.setColor(1,1,1)
    love.graphics.print("HEY", 100, 400)
    love.graphics.printf(self.message, location.x, location.y, location.limit, "center")
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
