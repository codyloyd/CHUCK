local class = require('lib/middleclass')
local Entity = require('entities/Entity')

local Door = class("Door", Entity)

function DoorSpanwer:initialize(gameMap, world, gameState)
  self.active = true
end