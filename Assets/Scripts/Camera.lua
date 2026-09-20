local STARTING_HEIGHT = 5.0

local BASE_ZOOM_Z = 25.0     -- Normal resting distance
local ZOOM_OUT_AMOUNT = 40.0

local _panSpeedY = 6.0
local _zoomSpeedZ = 4.0  

function OnCreate(entity)
    entity.TransformC.Position = Math.Vec3.new(0, STARTING_HEIGHT, 20)
end

function OnUpdate(entity, dt)
    local currentPos = entity.TransformC.Position
      
    local targetY = _G.TowerCameraTargetY
    local targetZ = BASE_ZOOM_Z
    
    if _G.PlaneIncoming then
        targetZ = BASE_ZOOM_Z + ZOOM_OUT_AMOUNT
    end
    
    local newY = Math.Lerp(currentPos.y, targetY, dt * _panSpeedY)
    local newZ = Math.Lerp(currentPos.z, targetZ, dt * _zoomSpeedZ)
    entity.TransformC.Position = Math.Vec3.new(currentPos.x, newY, newZ)
end

function OnDestroy(entity)
end