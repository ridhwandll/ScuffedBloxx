-- GameManager.lua
local STARTING_HEIGHT = 5.0
local CAMERA_LOOK_OFFSET_Y = 2.0
local ABSOLUTE_KILL_Y = -2.0

local function ClearActiveBlocks()
    if _G.ActiveBlocks then
        for i = 1, #_G.ActiveBlocks do
            local b = _G.ActiveBlocks[i]
            if b and b:IsValid() then
                b:Destroy()
            end
        end
    end
    _G.ActiveBlocks = {}
end

function OnCreate(entity)
    _G.GameState = "MENU"
    _G.Score = 0
    _G.Lives = 3
    _G.TowerCameraTargetY = STARTING_HEIGHT
    _G.TowerHeight = 0.0
    _G.ActiveBlocks = {}

    _G.AddBlock = function(currentBlock)
        table.insert(_G.ActiveBlocks, currentBlock)
    end

    _G.StartGame = function()
        ClearActiveBlocks()
        _G.Score = 0
        _G.Lives = 3
        _G.TowerCameraTargetY = STARTING_HEIGHT
        _G.TowerHeight = 0.0
        _G.GameState = "PLAYING"
    end

    _G.RestartGame = function()
        _G.StartGame()
    end

    _G.GoToMainMenu = function()
        ClearActiveBlocks()
        _G.Score = 0
        _G.Lives = 3
        _G.TowerCameraTargetY = STARTING_HEIGHT
        _G.TowerHeight = 0.0
        _G.GameState = "MENU"
    end

    _G.OnBlockDropped = function()
        if _G.GameState ~= "PLAYING" then return end
        _G.Score = _G.Score + 1
    end

    _G.OnBlockFellOff = function()
        if _G.GameState ~= "PLAYING" then return end
        _G.Lives = _G.Lives - 1
        if _G.Lives <= 0 then
            _G.GameState = "GAMEOVER"
        end
    end
end

function OnUpdate(entity, dt)
    if _G.GameState ~= "PLAYING" then
        return
    end

    local highestBlockY = 0.0

    if _G.ActiveBlocks then
        for i = #_G.ActiveBlocks, 1, -1 do
            local blockEntity = _G.ActiveBlocks[i]

            if blockEntity and blockEntity:IsValid() then
                local bPos = blockEntity.TransformC.Position

                local hasFallenOff = (bPos.y < ABSOLUTE_KILL_Y)
                if hasFallenOff then
                    _G.OnBlockFellOff()
                    blockEntity:Destroy()
                    table.remove(_G.ActiveBlocks, i)
                else
                    if bPos.y > highestBlockY then
                        highestBlockY = bPos.y
                    end
                end
            else
                table.remove(_G.ActiveBlocks, i)
            end
        end
    end

    _G.TowerCameraTargetY = math.max(STARTING_HEIGHT, highestBlockY + CAMERA_LOOK_OFFSET_Y)
    _G.TowerHeight = highestBlockY
end

function OnDestroy(entity)
    ClearActiveBlocks()
    _G.ActiveBlocks = nil 
    _G.GameState = nil
    _G.Score = nil
    _G.Lives = nil
    _G.TowerCameraTargetY = nil
    _G.TowerHeight = nil
    _G.StartGame = nil
    _G.RestartGame = nil
    _G.GoToMainMenu = nil
    _G.AddBlock = nil
    _G.OnBlockDropped = nil
    _G.OnBlockFellOff = nil
end