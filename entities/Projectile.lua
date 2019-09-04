
local class = require('lib/middleclass')
local Entity = require('entities/Entity')

local Projectile = class('Projectile', Entity)

function Projectile:initialize(opts, world) 
  Entity.initialize(self, opts, world)

  self.w = 4
  self.h = 4
  self.noClip = true
  self.dead = false
  -- self.speed = opts and opts.speed or 40
  self.speed = 80
  self.direction = opts and opts.direction or 1

  self.spritesheet = love.graphics.newImage('assets/fireball.png')
  self.animationGrid = anim8.newGrid(8,4,16,4)
  self.animation = anim8.newAnimation(self.animationGrid('1-2', 1), .1)

  self.exploded = false

  self.world = world
  self.world:add(self, self.x, self.y, self.w, self.h)
end

function Projectile:shouldCleanUp()
  return self.dead
end

function Projectile:update(dt)
  if not self.dead then
    self:updateAnimation(dt)
    local goalX = self.x + (self.speed * self.direction * dt)
    local goalY = self.y
    local actualX, actualY, cols = self.world:move(self, goalX, goalY, function() return "cross" end)

    for _, col in pairs(cols) do
      -- kill projectiles if they hit wall
      if col.other.class and col.other.class.name == "Platform" then
        self.dead = true
      end
    end

    -- kill projectiles if they go off map
    if self.x < 0 or self.y < 0 then self.dead = true end
    if self.x > 4000 or self.y > 4000 then self.dead = true end

    self.x, self.y = actualX, actualY 
  end

  if not self.dead then
    particles:createTrail(self.x,self.y,{.67,.19,.19})
  end

  if self.dead and not self.exploded then
    particles:createExplosion(self.x, self.y)
    self.exploded = true
  end
end

function Projectile:draw()
  if not self.dead then
    self.animation:draw(self.spritesheet, math.ceil(self.x, self.w/2), math.ceil(self.y), nil, -self.direction, 1)
  end
  
end

return Projectile
