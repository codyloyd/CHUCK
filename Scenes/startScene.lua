local scene = {}
function scene.new(changeScene)
  local self = {}
  function self:init()
  end

  function self:update(dt)
  end

  function self:draw()
    print "draw"
    love.graphics.print( "Press 'enter' to go", 22, 88 )
  end

  function self:keypressed(key)
    if key == "return" then
      changeScene("GAME_SCENE")
    end
  end

  return self
end

return scene