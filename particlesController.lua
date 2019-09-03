local particlesController = {}
local ExplosionParticles = {}
local TrailParticles = {}

local FireColors = {
  {.67,.19,.19},
  {.98,.81,.11},
  {.87,.5,.14},
  {.1,0,0}
}

function particlesController:createExplosion(x, y)
  for i=1,25 do
    table.insert(ExplosionParticles, {
        x = x,
        y = y,
        vy = math.random(-37,37),
        vx = math.random(-37,37),
        radius = math.random(2,5),
        color = FireColors[math.random(1,4)],
        life = math.random() * .3,
      })
  end
end

function particlesController:createHit(x,y,direction)
  for i=1,15 do
    table.insert(TrailParticles, {
        x = x + 20*direction,
        y = y,
        vy = math.random(67*direction),
        vx = math.random(167*direction),
        radius = math.random(1,3),
        color = {.05,0,.1},
        alpha = .5,
        life = math.random(),
      })
  end
end

function particlesController:createTrail(x,y,color)
  if math.random() < .1 then
    table.insert(TrailParticles, {
        x = x,
        y = y,
        vx = 0,
        vy = math.random(-4,4),
        color = color,
        life = math.random() * .6,
      })
  end
end

function particlesController:update(dt)
  for i,p in ipairs(ExplosionParticles) do
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.life = p.life - dt
    if p.life < 0 then
      table.remove(ExplosionParticles, i)
    end
  end
  for i,p in ipairs(TrailParticles) do
    p.y = p.y + p.vy * dt
    p.x = p.x + p.vx * dt
    p.life = p.life - dt
    if p.life < 0 then
      table.remove(TrailParticles, i)
    end
  end
end

function particlesController:draw()
  for _, p in pairs(ExplosionParticles) do
    local a = p.alpha or 1
    love.graphics.setColor(p.color[1],p.color[2],p.color[3], a)
    love.graphics.circle("fill", p.x,p.y,p.radius,9)
  end

  for _, p in pairs(TrailParticles) do
    local a = p.alpha or 1
    love.graphics.setColor(p.color[1],p.color[2],p.color[3],a)
    love.graphics.rectangle("fill", p.x,p.y,1,1)
  end

  love.graphics.setColor(1,1,1)
end

return particlesController
