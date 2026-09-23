local CLOUD_MESH_PATH = "Meshes/Cloud.gltf"
local FLOOR_MESH_PATH = "Meshes/Floor.gltf"

local TOTAL_BG_CLOUDS = 50
local TOTAL_FG_CLOUDS = 50
local TOTAL_POSZ_CLOUDS = 20

local TOTAL_MOUNTAINS = 7

local MIN_X = -250.0
local MAX_X = 250.0
local MIN_Y = -15.0 
local MAX_Y = 45.0

local MOUNTAIN_SPACING = 250.0
local MOUNTAIN_DEPTH_BG = -700.0
local MOUNTAIN_DEPTH_FG = 200.0
local MOUNTAIN_DRIFT_SPEED = 4.0

local _clouds = {}
local _mountains = {}
local _time = 0

local function RandomRange(minVal, maxVal)
    return minVal + math.random() * (maxVal - minVal)
end

local function SpawnCloud(parentEntity, spawnX, spawnY, minZ, maxZ)
    local spawnZ = RandomRange(minZ, maxZ)
    local cloud = parentEntity:CreateEntity("Cloud")
    
    cloud.TransformC.Position = Math.Vec3.new(spawnX, spawnY, spawnZ)   
    
    local uniformScale = RandomRange(1.0, 1.5)
    if spawnZ < -400.0 or spawnZ > 100.0 then
        uniformScale = uniformScale * RandomRange(1.5, 3.0)
    end
    cloud.TransformC.Scale = Math.Vec3.new(uniformScale, uniformScale, uniformScale)
    cloud:SetParent(parentEntity)

    local meshC = cloud:AddMeshC()
    meshC:SetMesh(CLOUD_MESH_PATH)

    table.insert(_clouds, {
        Entity = cloud,
        Speed = RandomRange(3, 5),
        MinZ = minZ,
        MaxZ = maxZ
    })
end

local function SpawnMountain(parentEntity, spawnX, spawnZ)
    local mountain = parentEntity:CreateEntity("BackgroundMountain")
    
    local spawnY = RandomRange(-40.0, 80.0)
    mountain.TransformC.Position = Math.Vec3.new(spawnX, spawnY, spawnZ)
    local scale = RandomRange(2, 4)
    mountain.TransformC.Scale = Math.Vec3.new(scale, scale, scale)
    mountain.TransformC.Rotation = Math.Vec3.new(0.0, RandomRange(0.0, 360.0), 0.0)
    mountain:SetParent(parentEntity)

    local meshC = mountain:AddMeshC()
    meshC:SetMesh(FLOOR_MESH_PATH)

    table.insert(_mountains, {
        Entity = mountain,
        SpeedX = MOUNTAIN_DRIFT_SPEED
    })
end

function OnCreate(entity)
    _clouds = {}
    _mountains = {}
    math.randomseed(os.time())

    -- Foreground Clouds
    for _ = 1, TOTAL_FG_CLOUDS do
        SpawnCloud(entity, RandomRange(MIN_X, MAX_X), RandomRange(MIN_Y, MAX_Y), -80.0, -10.0)
    end

    -- Spawn Background Clouds
    for _ = 1, TOTAL_BG_CLOUDS do
        SpawnCloud(entity, RandomRange(MIN_X, MAX_X), RandomRange(MIN_Y, MAX_Y), -1000.0, -150.0)
    end
    
    -- Positive Z Clouds
    for _ = 1, TOTAL_POSZ_CLOUDS do
        SpawnCloud(entity, RandomRange(MIN_X, MAX_X), RandomRange(MIN_Y, MAX_Y), 35.0, 300.0)
    end
    
    -- Spawn Mountains
    local startX = -((TOTAL_MOUNTAINS * MOUNTAIN_SPACING) / 2.0)
    for i = 1, TOTAL_MOUNTAINS do
        local rx = startX + (i * MOUNTAIN_SPACING) + RandomRange(-25.0, 25.0)    
        
        -- -ve Z
        local rzBG = MOUNTAIN_DEPTH_BG - RandomRange(0.0, 100.0)
        SpawnMountain(entity, rx, rzBG)
        
        -- +ve Z
        local rzFG = MOUNTAIN_DEPTH_FG + RandomRange(0.0, 100.0)
        SpawnMountain(entity, rx, rzFG)
    end
end

function OnUpdate(entity, dt)
    _time = _time + dt

    -- Clouds
    for i = 1, #_clouds do
        local cloudData = _clouds[i]
        local cloudEntity = cloudData.Entity

        if cloudEntity and cloudEntity:IsValid() then
            local pos = cloudEntity.TransformC.Position
            local newX = pos.x + (cloudData.Speed * dt)

            if newX > MAX_X then
                newX = MIN_X
                pos.y = RandomRange(MIN_Y, MAX_Y)
                pos.z = RandomRange(cloudData.MinZ, cloudData.MaxZ)
                
                local newScale = RandomRange(1.0, 1.2)
                if pos.z < -400.0 or pos.z > 100.0 then 
                    newScale = newScale * RandomRange(1.5, 3.0) 
                end
                cloudEntity.TransformC.Scale = Math.Vec3.new(newScale, newScale, newScale)
            end

            cloudEntity.TransformC.Position = Math.Vec3.new(newX, pos.y, pos.z)
        end
    end
    
    -- Mountains
    local mntMaxX = (TOTAL_MOUNTAINS * MOUNTAIN_SPACING) / 2.0
    local mntMinX = -mntMaxX

    for i = 1, #_mountains do
        local mntData = _mountains[i]
        local mntEntity = mntData.Entity

        if mntEntity and mntEntity:IsValid() then
            local pos = mntEntity.TransformC.Position
            local newX = pos.x + (mntData.SpeedX * dt)

            if newX > mntMaxX then
                newX = mntMinX
                pos.y = RandomRange(-40.0, 80.0)
            end
            mntEntity.TransformC.Position = Math.Vec3.new(newX, pos.y, pos.z)
        end
    end

    local windSpeed = 80.0
    local windLength = 3.0
    local windColor = Math.Vec4.new(0.9, 0.95, 1.0, 0.8)

    -- Wind
    for i = 1, 15 do
        -- Use a pseudo-random hash on 'i' to scatter the base heights between -10.0 and 40.0
        local baseY = 15.0 + (math.sin(i * 73.19) * 25.0) 
        local baseZ = 0.0 - (i * 5.0)
        
        local y = baseY + math.sin(_time * 4.0 + i) * 1.5
        
        local x = ((_time * windSpeed + i * 35.0) % 300.0) - 150.0 

        local p0 = Math.Vec3.new(x, y, baseZ)
        local p1 = Math.Vec3.new(x + windLength, y, baseZ)        
        Renderer.DrawLine(p0, p1, windColor)
    end
end

function OnDestroy(entity)
    _clouds = {}
    _mountains = {}
end