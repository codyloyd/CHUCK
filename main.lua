inspect = require('./lib/inspect')

function love.load()
  -- DEBUG_MODE = true

  love.graphics.setBackgroundColor(0.5,.73,1)
  love.graphics.setDefaultFilter( "nearest" )
  anim8 = require('lib/anim8')
  HC = require('lib/HC')
  bump = require("lib/bump")
  sceneDirector = require("sceneDirector")
end

function love.update(dt)
  sceneDirector.update(dt)
end

function love.draw()
  sceneDirector.draw()
end

function love.keypressed(key)
  if key == "escape" then
    DEBUG_MODE = not DEBUG_MODE
  end
  sceneDirector.keypressed(key)
end

function love.keyreleased(key)
  sceneDirector.keyreleased(key)
end
