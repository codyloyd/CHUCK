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
  self.grounded = opts and opts.grounded or false
  self.causesDamage = opts and opts.causesDamage or true
end

function Entity:updateAnimation(dt)
    self.animation:update(dt)
end

function Entity:updateGravity(dt)
    self.vy = math.min(self.vy - self.gravity * dt, self.maxVy)
end

function Entity:changeVelocityByCollision(nx, ny)
  if ny == -1 then
    self.vy = 0
  end
end

function Entity.collisionFilter(item, other)
  -- Override this function to change the behavior of collisions on a per-entity basis
  -- https://github.com/kikito/bump.lua#moving-an-item-in-the-world-with-collision-resolution
  if other.noClip then
    return 'cross'
  end

  return 'slide'
end

function Entity:moveWithCollisions(dt)
    local goalX = self.x - self.vx * dt
    local goalY = self.y - self.vy * dt
    local actualX, actualY, cols, len = world:move(self, goalX, goalY, self.collisionFilter)

    for i=1, len do
      local col = cols[i]
      -- col.normal is the direction of the collision
      -- x == 1 is a 'right side' collision
      -- x == -1 is 'left side'
      -- y == 1 is 'top'
      -- y == -1 is 'bottom'
      -- 0 means no collision
      self:changeVelocityByCollision(col.normal.x, col.normal.y)
    end

    self.x = actualX
    self.y = actualY

    return cols, len
end

function Entity:update(dt)
    self:updateAnimation(dt)
    self:updateGravity(dt)
    self:moveWithCollisions(dt)
end

return Entity
