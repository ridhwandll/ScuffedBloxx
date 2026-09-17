-- BoxSpawner.lua

local BLOCK_ASSET_PATH = "Meshes/Box.gltf"
local BLOCK_SCRIPT_ASSET_PATH = "Scripts/Block.lua"
local BLOCK_HEIGHT = 2.0       

-- Pendulum Settings
local CRANE_PIVOT_OFFSET_Y = 13.0 -- height of the crane's anchor point above the tower
local CABLE_LENGTH = 10.0
local SWING_SPEED = 0.9
local MAX_SWING_ANGLE = 0.4 -- Higher = wider swing

local _timeAlive = 0.0
local _isSpaceDown = false
local _currentBlock = nil 

function SpawnHangingBlock(parentEntity, startX, startY)
    _currentBlock = parentEntity:CreateEntity("HangingBlock")
    _currentBlock.TransformC.Position = Math.Vec3.new(startX, startY, 0)
    _currentBlock.TransformC.Rotation = Math.Vec3.new(0, 0, 0)

    local meshC = _currentBlock:AddMeshC()
    meshC:SetMesh(BLOCK_ASSET_PATH)
    _currentBlock:SetParent(parentEntity);

    local scriptC = _currentBlock:AddScriptC()
    scriptC:SetScript(BLOCK_SCRIPT_ASSET_PATH)
end

function DropBlock()
    if _currentBlock == nil then return end

    local boxColliderC = _currentBlock:AddBoxColliderC()
    boxColliderC.HalfExtents = Math.Vec3.new(1, 1, 1)

    local rigidBodyC = _currentBlock:AddRigidbodyC()
    rigidBodyC.Mass = 50
    rigidBodyC.Friction = 1
    rigidBodyC.Bounciness = 0
    rigidBodyC.Interpolate = true

    _G.AddBlock(_currentBlock) 
    _G.OnBlockDropped();

    _currentBlock = nil
end

function OnCreate(entity)

    _G.TowerHeight = 0.0          
    _G.TowerCameraTargetY = 5.0   
    SpawnHangingBlock(entity, 0, _G.TowerHeight + (CRANE_PIVOT_OFFSET_Y - CABLE_LENGTH))
end

function OnUpdate(entity, dt)
    if _G.GameState ~= "PLAYING" then
        return
    end

    _timeAlive = _timeAlive + dt

    local currentAngle = math.sin(_timeAlive * SWING_SPEED) * MAX_SWING_ANGLE

    local currentTargetY = _G.TowerCameraTargetY or 5.0
    local pivotY = currentTargetY + CRANE_PIVOT_OFFSET_Y

    -- Arc
    local currentX = math.sin(currentAngle) * CABLE_LENGTH
    local currentY = pivotY - math.cos(currentAngle) * CABLE_LENGTH

    if _currentBlock ~= nil then
        _currentBlock.TransformC.Position = Math.Vec3.new(currentX, currentY, 0.0)
        local angleInDegrees = currentAngle * (180.0 / math.pi)
        _currentBlock.TransformC.Rotation = Math.Vec3.new(0.0, 0.0, angleInDegrees)
    end

    local spacePressedNow = Input.IsKeyPressed(Key.Space) -- or Input.IsMouseButtonPressed(Mouse.ButtonLeft)
    if spacePressedNow and not _isSpaceDown then
        DropBlock()
        local nextSpawnY = _G.TowerCameraTargetY + (CRANE_PIVOT_OFFSET_Y - CABLE_LENGTH)
        SpawnHangingBlock(entity, 0.0, nextSpawnY)
    end
    _isSpaceDown = spacePressedNow

    -- 4 cable lines from the top anchor to the 4 corners of the top face
    if _currentBlock ~= nil then
        local halfW = 1.0
        local halfH = BLOCK_HEIGHT * 0.5 -- 1.0
        local halfD = 1.0

        local cosA = math.cos(currentAngle)
        local sinA = math.sin(currentAngle)

        local function GetWorldPoint(localX, localY, localZ)
            local rotX = (localX * cosA) - (localY * sinA)
            local rotY = (localX * sinA) + (localY * cosA)
            return Math.Vec3.new(currentX + rotX, currentY + rotY, localZ)
        end

        local cornerFL = GetWorldPoint(-halfW, halfH,  halfD)
        local cornerFR = GetWorldPoint( halfW, halfH,  halfD)
        local cornerBL = GetWorldPoint(-halfW, halfH, -halfD)
        local cornerBR = GetWorldPoint( halfW, halfH, -halfD)

        local cableColor = Math.Vec4.new(0.15, 0.15, 0.15, 1.0)
        local cranePivot = Math.Vec3.new(0.0, pivotY + 30, 0.0) -- +30 so that it is never shown in camera
        Renderer.DrawLine(cranePivot, cornerFL, cableColor)
        Renderer.DrawLine(cranePivot, cornerFR, cableColor)
        Renderer.DrawLine(cranePivot, cornerBL, cableColor)
        Renderer.DrawLine(cranePivot, cornerBR, cableColor)
    end
end

function OnDestroy(entity)
    _timeAlive = 0.0
    _isSpaceDown = false
    _currentBlock = nil 
end