local textBox = {}

function textBox.new(uiStack, message, keyboardControl, mouseControl) 
  local self = {}
  self.message = message
  self.keyboardControl = keyboardControl
  self.mouseControl = mouseControl
  local screenWidth = love.graphics.getWidth() / 3
  local screenHeight = love.graphics.getHeight() / 3
  self.w = screenWidth
  self.x = screenWidth - self.w / 2
  self.y = screenHeight - 90

  function self:hasKeyboardControl() 
    return true
  end

  function self:hasMouseControl() 
    return true
  end

  function self:update()
  end

  function self:draw()
    local padding = 8
    local boxHeight = 100

    local r, b, g, a = love.graphics.getColor()
    love.graphics.setColor(.1, .1, .1, .5)
    love.graphics.rectangle("fill", self.x - padding, self.y - padding, self.w + padding*2, boxHeight)

    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle("line", self.x - padding, self.y - padding, self.w + padding*2, boxHeight)
    love.graphics.printf(self.message, self.x, self.y, self.w)
    love.graphics.print("press 'x' to continue", self.x + self.w + padding - 200, self.y + boxHeight - padding * 3 - 3)
  end

  function self:keypressed(key)
    if key == "x" then
      table.remove(uiStack)
    end
  end

  function self:keyreleased(key)
  end

  return self
end

local root = textBox
return root
