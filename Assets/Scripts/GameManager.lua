local STARTING_HEIGHT = 3.0
local BLOCK_HEIGHT = 2.0
local FALL_THRESHOLD = 30.0 -- Distance below camera to count as a "fall"

function OnCreate(entity)
    -- 1. Initialize Global Game State
    _G.GameState = "PLAYING" -- States: "PLAYING", "GAMEOVER"
    _G.Score = 0
    _G.Lives = 3
    _G.StatusText = "Press SPACE"    
    _G.TowerHeight = 0.0
    _G.TowerCameraTargetY = STARTING_HEIGHT

    _G.ActiveBlocks = {}

    --Expose Global Functions for the Crane to call
    _G.OnBlockDropped = function()
        if _G.GameState ~= "PLAYING" then return end

        _G.TowerHeight = _G.TowerHeight + BLOCK_HEIGHT
        _G.TowerCameraTargetY = _G.TowerCameraTargetY + BLOCK_HEIGHT
        _G.Score = _G.Score + 50
    end

    _G.OnBlockFellOff = function()
        if _G.GameState ~= "PLAYING" then return end
        
        _G.Lives = _G.Lives - 1
        Log.Warn("Block dropped! Lives remaining: " .. tostring(_G.Lives))

        if _G.Lives <= 0 then
            _G.GameState = "GAMEOVER"
            Log.Error("GAME OVER! Final Score: " .. tostring(_G.Score))
        end
    end
end

function OnUpdate(entity, dt)
    if _G.GameState == "GAMEOVER" then
        if Input.IsKeyPressed(Key.R) then
            Log.Info("Restarting Game...")
            _G.Score = 0
            _G.Lives = 3
            _G.TowerHeight = 0.0
            _G.TowerCameraTargetY = STARTING_HEIGHT
            
            -- Destroy all blocks
            if _G.ActiveBlocks then
                for i = 1, #_G.ActiveBlocks do
                    local b = _G.ActiveBlocks[i]
                    if b and b:IsValid() then
                        b:Destroy()
                    end
                end
            end
            
            _G.ActiveBlocks = {}
            _G.GameState = "PLAYING"
        end
    end

    -- KILL Z LOOP
    if _G.ActiveBlocks and _G.TowerCameraTargetY then
        local killZ = _G.TowerCameraTargetY - FALL_THRESHOLD

        -- Iterate backwards to safely remove items from the table while looping
        for i = #_G.ActiveBlocks, 1, -1 do
            local blockEntity = _G.ActiveBlocks[i]
            
            if blockEntity and blockEntity:IsValid() then
                local blockY = blockEntity.TransformC.Position.y

                if blockY < killZ then
                    _G.OnBlockFellOff()                
                    blockEntity:Destroy()                
                    table.remove(_G.ActiveBlocks, i)
                end
            else
                table.remove(_G.ActiveBlocks, i)
            end
        end
    end
    
    local textStr = "Score: " .. tostring(_G.Score) .. " | Lives: " .. tostring(_G.Lives)    
    if _G.GameState == "GAMEOVER" then
        textStr = "GAME OVER!\nFinal Score: " .. tostring(_G.Score) .. "\nPress 'R' to Restart"
    end
    _G.StatusText = textStr
end

function OnDestroy(entity)
    _G.ActiveBlocks = nil 
    _G.GameState = nil
    _G.Score = nil
    _G.Lives = nil
    _G.TowerHeight = nil
    _G.TowerCameraTargetY = nil
    _G.OnBlockDropped = nil
    _G.OnBlockFellOff = nil
    _G.StatusText = nil;
end