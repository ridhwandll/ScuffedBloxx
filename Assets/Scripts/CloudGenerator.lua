-- CloudGenerator.lua

local CLOUD_MESH_PATH = "Meshes/Cloud.gltf"

local TOTAL_CLOUDS = 15
local MIN_X = -80.0
local MAX_X = 80.0
local MIN_Y = 5.0
local MAX_Y = 32.0
local MIN_Z = -80.0
local MAX_Z = -15.0
local DRIFT_SPEED_MIN = 2.0
local DRIFT_SPEED_MAX = 3.5
local _clouds = {}

local function RandomRange(minVal, maxVal)
    return minVal + math.random() * (maxVal - minVal)
end

local function SpawnCloud(parentEntity, spawnX, spawnY, spawnZ)
    local cloud = parentEntity:CreateEntity("Cloud")
    
    -- Setup initial transform
    cloud.TransformC.Position = Math.Vec3.new(spawnX, spawnY, spawnZ)
    -- cloud.TransformC.Rotation = Math.Vec3.new(0, RandomRange(0, 360), 0)
    
    local uniformScale = RandomRange(1.0, 1.1)
    cloud.TransformC.Scale = Math.Vec3.new(uniformScale, uniformScale, uniformScale)
    cloud:SetParent(parentEntity)

    -- Attach only the Mesh component and assign the asset
    local meshC = cloud:AddMeshC()
    meshC:SetMesh(CLOUD_MESH_PATH)

    table.insert(_clouds, {
        Entity = cloud,
        Speed = RandomRange(DRIFT_SPEED_MIN, DRIFT_SPEED_MAX)
    })
end

function OnCreate(entity)
    _clouds = {}
    math.randomseed(os.time())

    -- Initial population of clouds across the sky
    for _ = 1, TOTAL_CLOUDS do
        local rx = RandomRange(MIN_X, MAX_X)
        local ry = RandomRange(MIN_Y, MAX_Y)
        local rz = RandomRange(MIN_Z, MAX_Z)
        SpawnCloud(entity, rx, ry, rz)
    end
end

function OnUpdate(entity, dt)

    -- MAX_Y = _G.TowerCameraTargetY + 10

    -- Drift clouds across the X axis and wrap around when out of bounds
    for i = 1, #_clouds do
        local cloudData = _clouds[i]
        local cloudEntity = cloudData.Entity

        if cloudEntity and cloudEntity:IsValid() then
            local pos = cloudEntity.TransformC.Position
            local newX = pos.x + (cloudData.Speed * dt)

            -- Wrap around to the other side of the sky
            if newX > MAX_X then
                newX = MIN_X
                pos.y = RandomRange(MIN_Y, MAX_Y)
                pos.z = RandomRange(MIN_Z, MAX_Z)
            end

            cloudEntity.TransformC.Position = Math.Vec3.new(newX, pos.y, pos.z)
        end
    end
end

function OnDestroy(entity)
    _clouds = {}
end