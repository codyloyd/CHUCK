local GameScene = require("Scenes/GameScene")

local function BasicGameScene(map)
  local sceneInitializer = {}
  function sceneInitializer:new(changeSceneCallback, gameState, playerSpawn)
    return GameScene:new(changeSceneCallback, gameState, playerSpawn, map)
  end

  return sceneInitializer
end

return BasicGameScene