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

sounds.music = {}

sounds.music.chuck = love.audio.newSource("sounds/CHUCK.mp3", "stream", true)
sounds.music.chuck:setVolume(1)

sounds.music.mazey = love.audio.newSource("sounds/mazey.mp3", "stream", true)
sounds.music.mazey:setVolume(1)

local function createTimedSong(song, totalTime, fadeIn)
  return {
      song = song, -- a string that refers to the song inside songs.music
      timer = totalTime, -- the timer that gets manipulated
      time = totalTime, -- the total time of the timer... for calculating the actual volume, potentially usable for easing curves
      fadingIn = fadeIn,
      fadingOut = false
  }
end

local playingTracks = {}

function sounds.music:play(song)
  local isSongPlaying = false
  for i,track in ipairs(playingTracks) do
    isSongPlaying = true
  end
  if not isSongPlaying then
    sounds.music[song]:setVolume(1)
    sounds.music[song]:play()
    table.insert(playingTracks, createTimedSong(song))
  end
end

function sounds.music:fadeTo(song)
  local isSongPlaying = false

  -- set every song except THIS one to fadingOut
  for i,track in ipairs(playingTracks) do
    if track.song ~= song then
      track.fadingIn =  false
      track.fadingOut = true
      track.time = 2
      track.timer = 2 
    end


    if track.song == song then 
      if track.fadingOut == true then
        track.fadingOut = false
        track.fadingIn = true
      end
      isSongPlaying = true
    end
  end

  -- only do this if the song isn't currently playing
  if not isSongPlaying then
    sounds.music[song]:setVolume(0)
    sounds.music[song]:play()
    table.insert(playingTracks, createTimedSong(song, 2, true))
  end
end


function sounds.update(dt)
  for i,track in ipairs(playingTracks) do
    if track.timer > 0 then
      track.timer = track.timer - dt
    end
    if track.fadingIn then
      sounds.music[track.song]:setVolume((track.time - track.timer)/track.time)
    end
    if track.fadingOut then
      sounds.music[track.song]:setVolume(track.timer/track.time)
      if track.timer <=0 then
        sounds.music[track.song]:stop()
        table.remove(playingTracks, i)
      end
    end
  end
end

return sounds
