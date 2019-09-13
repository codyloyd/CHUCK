local sounds = {}

sounds.walk = love.audio.newSource("sounds/walk.ogg", "static", true)
sounds.walk:setVolume(.1)
sounds.walk:setPitch(1.3)

sounds.jump = love.audio.newSource("sounds/jump.ogg", "static", false)
sounds.jump:setVolume(.2)
sounds.jump:setPitch(1.7)

sounds.attack = love.audio.newSource("sounds/attack.ogg", "static", false)
sounds.attack:setVolume(.1)
sounds.attack:setPitch(1.5)

sounds.hurt = love.audio.newSource("sounds/hurt.ogg", "static", false)
sounds.hurt:setVolume(.2)
sounds.hurt:setPitch(.7)

sounds.hurt2 = love.audio.newSource("sounds/hurt2.ogg", "static", false)
sounds.hurt2:setVolume(.08)
sounds.hurt2:setPitch(.8)

sounds.hit = love.audio.newSource("sounds/hit.ogg", "static", false)
sounds.hit:setVolume(.3)
sounds.hit:setPitch(.9)

sounds.death = love.audio.newSource("sounds/death.ogg", "static", false)
sounds.death:setVolume(.1)
sounds.death:setPitch(.8)

sounds.playerdeath = love.audio.newSource("sounds/playerdeath.ogg", "static", false)
sounds.playerdeath:setVolume(.3)
sounds.playerdeath:setPitch(.8)

sounds.fireball = love.audio.newSource("sounds/fireball.ogg", "static", false)
sounds.fireball:setVolume(.1)
sounds.fireball:setPitch(1.5)

sounds.powerup = love.audio.newSource("sounds/powerup.mp3", "static", false)
sounds.powerup:setVolume(.6)
sounds.powerup:setPitch(1)

sounds.open = love.audio.newSource("sounds/open.ogg", "static", false)
sounds.open:setVolume(.4)
sounds.open:setPitch(1)

sounds.pickup = love.audio.newSource("sounds/pickup.ogg", "static", false)
sounds.pickup:setVolume(.2)
sounds.pickup:setPitch(1)

sounds.chuckSong = love.audio.newSource("sounds/CHUCK.mp3", "stream", true)
sounds.chuckSong:setVolume(1)

sounds.mazeSong = love.audio.newSource("sounds/mazey.mp3", "stream", true)
sounds.mazeSong:setVolume(1)

return sounds
