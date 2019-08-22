local scene = {}
function scene.new(changeScene)
  local self = {}
  function self:init()
  end

  function self:draw()
    love.graphics.print( "END: Press 'enter' to start over", 22, 88 )
  end

  function self:update(dt)
  end

  function self:keypressed(key)
    if key == "return" then
      changeScene("START_SCENE")
    end

  end

  function self:keyreleased(key)
  end

  return self
end

return scene
