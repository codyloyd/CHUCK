
local class = require("lib/middleclass")

local Door = class("Door")

function Door:initialize(gameMap, world, gameState)
  self.world = world
  self.gameMap = gameMap
  self.gameState = gameState
  self.inactive = gameState.doors[gameState.scene.current]

  if self.gameMap.layers["door"] then
    local door = self.gameMap.layers["door"].objects[1] -- Only one door per map
    self.x = door.x
    self.y = door.y
    self.w = door.width
    self.h = door.height
    self.name = door.name

    world:add(self, self.x, self.y, self.w, self.h)
  end

end

function Door:update(dt) 
end

function Door:draw()
  if not self.inactive and self.gameMap.layers["door-tiles"] then
    self.gameMap:drawLayer(self.gameMap.layers["door-tiles"])
  end
end

function Door:deactivate()
  -- TODO: Spawn Particle
  self.inactive = true
  self.gameState.doors[self.gameState.scene.current] = true
end

return Door