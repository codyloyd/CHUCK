local class = require("lib/middleclass")
local Scene = class("Scene")

function Scene:initialize(changeSceneCallback)
  self.changeSceneCallback = changeSceneCallback
end

function Scene:draw()
end

function Scene:update(dt)
end

function Scene:keypressed(key)
end

function Scene:keyreleased(key)
end

return Scene