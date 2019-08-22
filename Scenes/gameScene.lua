local scene = {}
function scene.new(changeScene)
  local self = {}
  function self:init()
  end

  function self:update(dt)
  end

  function self:draw()
    love.graphics.print( "Gameplay, press 'p' to die", 22, 88 )
  end

  function self:keypressed(key)
    if key == "p" then
      changeScene("END_SCENE")
    end
  end

  return self
end

return scene