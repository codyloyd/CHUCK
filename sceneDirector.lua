local BasicGameScene = require("Scenes/BasicGameScene")

local sceneDirector = {}
local currentSceneName
local currentScene
local scenes = {
  START_SCENE = require("Scenes/startScene"),
  caves = BasicGameScene("map/caves.lua"),

  caves101 = BasicGameScene("map/caves101.lua"),
  caves101_h1 = BasicGameScene("map/caves101_h1.lua"),
  caves102 = BasicGameScene("map/caves102.lua"),
  caves103 = BasicGameScene("map/caves103.lua"),
  caves103_h1 = BasicGameScene("map/caves103_h1.lua"),

  caves2 = BasicGameScene("map/caves2.lua"),
  caves3 = BasicGameScene("map/caves3.lua"),
  caves4 = BasicGameScene("map/caves4.lua"),
  caves5 = BasicGameScene("map/caves5.lua"),
  sample = BasicGameScene("map/samplerMap.lua"),
  sample2 = BasicGameScene("map/samplerMap2.lua"),
  end_scene = require("Scenes/endScene")
}
local fadingTrack = nil

local gameState = {
  scene = {
    current = nil,
    last = nil
  },
  player = {
    spawn = {
      scene = nil,
      spawnPoint = nil
    },
    powerups = {
      doubleJump = false,
      wallJump = false
    },
    health = 5,
    maxHealth = 5
  },
  doors = {
    -- Will wind up having this structure:
    -- <mapname> = true/false
    -- true = closed, false = open
  },
  interactables = {
    -- This is for onetime interactables, like door switches
    -- <mapname> = { <name> = true/false }
  }
}

easeIn = function(t, b, c, d) 
    local t = t / d;
    return c*t*t + b;
  end 

local currentSong = nil
local function toggleMusic(scene)
  local newSong 
  if scene == "START_SCENE" or scene == "caves"  or scene == "caves3" then
    newSong = "chuckSong"
  elseif scene == "caves101" or scene == "caves5" then
    newSong = "mazeSong"
  end
  if newSong then
    if currentSong and currentSong ~= newSong then
      fadingTrack = currentSong
    end
    currentSong = newSong
    sounds[newSong]:play()
    sounds[newSong]:setVolume(1)
  end
end

local fadeTimer = 0

function changeScene(sceneName, reason) 
  fadeTimer = .5 

  gameState.scene.last = gameState.scene.current 
  gameState.scene.current = sceneName

  if reason == "spawn" then
    local newCurrentScene = sceneName or gameState.player.spawn.scene or "caves"

    -- Spawn at last spawn point
    gameState.player.health = 5
    gameState.scene.current = newCurrentScene
    currentScene = scenes[newCurrentScene]:new(changeScene, gameState, gameState.player.spawn.spawnPoint or "start")
    toggleMusic(newCurrentScene)
  else
    currentScene = scenes[sceneName]:new(changeScene, gameState)
    toggleMusic(sceneName)
  end 
end

changeScene("START_SCENE")

function sceneDirector.draw() 
  currentScene:draw()
  love.graphics.setColor(0,0,0,easeIn(fadeTimer, .1, 1, .5))
  love.graphics.rectangle("fill",0,0,4000,4000)
  love.graphics.setColor(1,1,1)
end

function sceneDirector.update(dt) 
  if fadeTimer >= 0 then
    fadeTimer = fadeTimer - dt 
  end
  --crossfading music
  if fadingTrack and sounds[fadingTrack]:getVolume() > 0 then
    sounds[fadingTrack]:setVolume(sounds[fadingTrack]:getVolume() - dt*.4)
  end
  if fadingTrack and sounds[fadingTrack]:getVolume() <= 0.1 then
    sounds[fadingTrack]:stop()
  end

  currentScene:update(dt)
end

function sceneDirector.keypressed(key)
  currentScene:keypressed(key)
end

function sceneDirector.keyreleased(key)
  currentScene:keyreleased(key)
end


return sceneDirector
