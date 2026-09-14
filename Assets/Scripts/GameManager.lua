local STARTING_HEIGHT = 5.0
local BLOCK_HEIGHT = 2.0

function OnCreate(entity)
    _G.GameState = "PLAYING" -- TODO States: "PLAYING", "GAMEOVER"
    _G.Score = 0
    _G.Lives = 3
    _G.StatusText = "Press SPACE"    
    _G.TowerCameraTargetY = STARTING_HEIGHT

    _G.ActiveBlocks = {}

    _G.AddBlock = function (currentBlock)
        table.insert(_G.ActiveBlocks, currentBlock)
    end

    _G.IncreaseHeight = function(blockCount)
        blockCount = blockCount or 1
        _G.TowerHeight = _G.TowerHeight + (BLOCK_HEIGHT * blockCount)
    end
    _G.DecreaseHeight = function(blockCount)
        blockCount = blockCount or 1
        _G.TowerHeight = _G.TowerHeight - (BLOCK_HEIGHT * blockCount)
    end

    -- Camera Utils
    _G.MoveCameraUp = function()
        _G.TowerCameraTargetY = _G.TowerCameraTargetY + BLOCK_HEIGHT
    end
    _G.MoveCameraDown = function()
        _G.TowerCameraTargetY = _G.TowerCameraTargetY - BLOCK_HEIGHT
    end

    --Expose Global Functions for the Crane to call
    _G.OnBlockDropped = function()
        if _G.GameState ~= "PLAYING" then return end
        _G.IncreaseHeight()
        _G.Score = _G.Score + 1
    end
end

function OnUpdate(entity, dt)
    if _G.ActiveBlocks then
        for i = #_G.ActiveBlocks, 1, -1 do
            local blockEntity = _G.ActiveBlocks[i]

            if not blockEntity:IsValid() then
                table.remove(_G.ActiveBlocks, i)
            end
        end
    end
    
    local textStr = "Score: " .. tostring(_G.Score) .. " | Lives: " .. tostring(_G.Lives)    
    _G.StatusText = textStr
end

function OnDestroy(entity)
    _G.ActiveBlocks = nil 
    _G.GameState = nil
    _G.Score = nil
    _G.Lives = nil
    _G.TowerCameraTargetY = nil

    _G.IncreaseHeight = nil
    _G.DecreaseHeight = nil
    _G.MoveCameraUp = nil
    _G.MoveCameraDown = nil
    _G.OnBlockDropped = nil
    _G.StatusText = nil;
end