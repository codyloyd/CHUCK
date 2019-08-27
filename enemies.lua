local enemies = {}
enemies.table = {}

local class = require('lib/middleclass')
local Entity = class('Entity')

-- options is a table
function Entity:initialize(opts)
  self.x = opts and opts.x or 0
  self.y = opts and opts.y or 0
  self.w = opts and opts.w or 16
  self.h = opts and opts.h or 16 
  self.vx = opts and opts.vx or 0
  self.vy = opts and opts.vy or 0
  self.maxVx = opts and opts.maxVx or 100
  self.maxVy = opts and opts.maxVy or 2000 
  self.spritesheet = opts and opts.spritesheet or null
  self.animationGrid = opts and opts.animationGrid or null
  self.animation = opts and opts.animation or null
  self.direction = opts and opts.direction or 1
  self.gravity = opts and opts.gravity or 790 
end

local Slime = class('Slime', Entity)

function Slime:initialize(opts)
  Entity.initialize(self, opts)
  self.vx = 30
  self.w = 8
  self.h = 8
  self.spritesheet = love.graphics.newImage('SLIME.png')
  self.animationGrid = anim8.newGrid(16,16,64,64)
  self.animation = anim8.newAnimation(self.animationGrid('1-4',1),.2)
end


function spawnEnemy(x,y,direction)
  local slime = Slime:new({
      x = x,
      y = y,
    })
  world:add(slime, slime.x, slime.y, slime.w, slime.h)
  return slime
end 

-- loads enemies from tilemap into table
for i, e in pairs(gameMap.layers["enemies"].objects) do
  table.insert(enemies.table, spawnEnemy(e.x, e.y))
end

function enemies:update(dt)
  for i, e in ipairs(self.table) do
    e.animation:update(dt)
    e.vy = math.min(e.vy - e.gravity * dt, e.maxVy)

    local goalX = e.x - e.vx * dt
    local goalY = e.y - e.vy * dt
    local actualX, actualY, cols, len = world:move(e, goalX, goalY)
    e.x = actualX
    e.y = actualY

    for i=1, len do
      local col = cols[i]
      if math.abs(col.normal.x) == 1 then
        e.vx = -e.vx
      end
      if col.normal.y == -1 then
        e.vy = 0
      end
    end
  end
end

function enemies:draw()
  for i, e in ipairs(self.table) do
    e.animation:draw(e.spritesheet,math.ceil(e.x + e.w/2),math.ceil(e.y),nil,nil,nil,8,8)
  end
end


return enemies
