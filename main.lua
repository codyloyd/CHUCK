inspect = require('./lib/inspect')

function love.load()
  DEBUG_MODE = true

  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.setDefaultFilter( "nearest" )
  anim8 = require('lib/anim8')
  HC = require('lib/HC')
  bump = require("lib/bump")
  sceneDirector = require("sceneDirector")
  tick = require("lib/tick")
  particles = require("particlesController")
  sounds = require("sounds")
  -- keybinds
  -- can probably load these from a file 
  -- or make them editable if we want
  UP = "up"
  DOWN = "down"
  LEFT = "left"
  RIGHT = "right"
  JUMP = "up"
  ATTACK = "x"
end

function love.update(dt)
  sceneDirector.update(dt)
  tick.update(dt)
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
