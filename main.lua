inspect = require('./lib/inspect')

function love.load()
  DEBUG_MODE = false
  SPEEDRUN_MODE = false

  love.graphics.setBackgroundColor(0,0,0)
  love.graphics.setDefaultFilter( "nearest" )
  font = love.graphics.newFont("assets/MatchupPro.ttf", 28)
  bigfont = love.graphics.newFont("assets/MatchupPro.ttf", 48)
  love.graphics.setFont(font)
  anim8 = require('lib/anim8')
  HC = require('lib/HC')
  bump = require("lib/bump")
  sounds = require("sounds")
  sceneDirector = require("sceneDirector")
  tick = require("lib/tick")
  particles = require("particlesController")
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
  sounds.update(dt)
end

function love.draw()
  sceneDirector.draw()
end

function love.keypressed(key)
  if key == "escape" then
    -- DEBUG_MODE = not DEBUG_MODE
  end
  if key == "space" and SPEEDRUN_MODE then
     sceneDirector.reset()
  end
  sceneDirector.keypressed(key)
end

function love.keyreleased(key)
  sceneDirector.keyreleased(key)
end
