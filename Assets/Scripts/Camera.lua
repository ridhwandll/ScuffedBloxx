local STARTING_HEIGHT = 5.0

local BASE_ZOOM_Z = 20.0       -- Normal resting distance
local ZOOM_OUT_AMOUNT = 20.0   -- How far back it pulls when Space is pressed
local ZOOM_HANG_TIME = 0.7     -- How many seconds to stay zoomed out after a tap

-- Speeds
local _panSpeedY = 6.0
local _zoomSpeedZ = 4.0  

-- State tracking
local _zoomTimer = 0.0

function OnCreate(entity)
    entity.TransformC.Position = Math.Vec3.new(0, STARTING_HEIGHT, 20)
end

function OnUpdate(entity, dt)
    local currentPos = entity.TransformC.Position
    
    -- Decrease the timer safely
    if _zoomTimer > 0.0 then
        _zoomTimer = _zoomTimer - dt
    end

    -- Detect Spacebar to trigger/reset the timer
    if Input.IsKeyPressed(Key.Space) then
        _zoomTimer = ZOOM_HANG_TIME
    end
    
    -- 3. CALCULATE TARGETS
    local targetY = _G.TowerCameraTargetY
    local targetZ = BASE_ZOOM_Z
    
    -- If the timer is active, override the target X to pull back!
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