local enemies = {}

enemies.table = {}

function spawnEnemy(x,y,direction)
  -- TODO move this into a proper module with a factory so we can
  -- pass in multiple sprites
  local e = {}
  e.spriteSheet = love.graphics.newImage('SLIME.png')
  e.x = x
  e.y = y
  e.rect = HC.rectangle(0,0,8,8)
  e.xOffset = 0
  e.yOffset = 4
  e.grid = anim8.newGrid(16,16,64,64)
  e.animation = anim8.newAnimation(e.grid('1-4',1),.2)
  e.direction = 1
  e.dx = -30
  e.dy = 0
  e.gravity = 790
  e.maxFallSpeed = 2000
  return e
end 

-- loads enemies from tilemap into table
for i, e in pairs(gameMap.layers["enemies"].objects) do
  table.insert(enemies.table, spawnEnemy(e.x, e.y))
end

function enemies:update(dt)
  -- TODO give the enemy factory it's own update loop so that we can 
  -- give different enemies different behaviors
  for i, e in ipairs(self.table) do
    e.animation:update(dt)
    e.dy = math.min(e.dy - e.gravity * dt, e.maxFallSpeed)

    local startx = e.x
    local starty = e.y

    e.x = e.x - e.dx * dt
    e.y = e.y - e.dy * dt
    e.rect:moveTo(e.x, e.y)

    -- TODO abstract this out so we don't have to copy/paste it all over the place
    for shape, delta in pairs(HC.collisions(e.rect)) do
      if shape == player.rect then
        newDelta = {x=-delta.x, delta.y}
        player:takeDamage(newDelta)
      end
      ---bottom collisions
      if (delta.y < 0 and e.dy < 0) then 
        e.dy = 0
        e.y = starty
      end

      --top collisions
      if (delta.y > 0 and not shape.jumpThrough) then
        e.dy = -5
        e.y = starty + delta.y
      end

      --side collision
      if ((delta.x > 0 or delta.x < 0) and not shape.jumpThrough) then
        e.dx = -e.dx
        e.x = startx + delta.x
      end

      e.rect:moveTo(e.x, e.y)
    end
  end
end

function enemies:draw()
  for i, e in ipairs(self.table) do
    e.animation:draw(e.spriteSheet,math.ceil(e.x)-e.xOffset,math.ceil(e.y)-e.yOffset,nil,nil,nil,8,8)
  end
end


return enemies
