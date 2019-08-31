local GameScene = require("Scenes/GameScene")

local function BasicGameScene(map)
  local sceneInitializer = {}
  function sceneInitializer:new(changeSceneCallback, gameState)
    return GameScene:new(changeSceneCallback, gameState, map)
  end

  return sceneInitializer
end

return BasicGameScene