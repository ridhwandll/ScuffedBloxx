local STARTING_HEIGHT = 5.0

local BASE_ZOOM_Z = 25.0 -- Normal resting distance
local ZOOM_OUT_AMOUNT = 20.0 -- How far back it pulls when Space is pressed
local ZOOM_HANG_TIME = 0.7

local _panSpeedY = 6.0
local _zoomSpeedZ = 4.0  

local _zoomTimer = 0.0

function OnCreate(entity)
    entity.TransformC.Position = Math.Vec3.new(0, STARTING_HEIGHT, 20)
end

function OnUpdate(entity, dt)
    local currentPos = entity.TransformC.Position
    
    if _zoomTimer > 0.0 then
        _zoomTimer = _zoomTimer - dt
    end

    if Input.IsKeyPressed(Key.Space) then
        _zoomTimer = ZOOM_HANG_TIME
    end
    
    local targetY = _G.TowerCameraTargetY
    local targetZ = BASE_ZOOM_Z
    
    if _zoomTimer > 0.0 then
        targetZ = BASE_ZOOM_Z + ZOOM_OUT_AMOUNT
    end
    
    local newY = Math.Lerp(currentPos.y, targetY, dt * _panSpeedY)
    local newZ = Math.Lerp(currentPos.z, targetZ, dt * _zoomSpeedZ)
    entity.TransformC.Position = Math.Vec3.new(currentPos.x, newY, newZ)
end

function OnDestroy(entity)
    _zoomTimer = 0.0
end