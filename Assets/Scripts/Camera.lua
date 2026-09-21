local STARTING_HEIGHT = 5.0

local BASE_ZOOM_Z = 25.0     -- Normal resting distance
local ZOOM_OUT_AMOUNT = 40.0

local _panSpeedY = 6.0
local _zoomSpeedZ = 4.0

local ORBIT_SPEED = 0.3            -- speed of the revolution around the floor
local MENU_PITCH = -14.0           -- look-down angle while orbiting
local BOB_HEIGHT_AMPLITUDE = 1.5   -- how far the camera drifts up/down while orbiting
local BOB_SPEED = 0.5              -- speed of the vertical bob
local BREATHE_AMPLITUDE = 3.0      -- how far the orbit radius pulses in/out
local BREATHE_SPEED = 0.35         -- speed of the radius pulse
local PITCH_SWAY_AMPLITUDE = 4.0   -- degrees of pitch drift while orbiting
local PITCH_SWAY_SPEED = 0.25      -- speed of the pitch drift
local PITCH_LERP_SPEED = 2.5       -- how fast pitch eases toward its sway target

local _orbitAngle = 0.0
local _menuTime = 0.0
local _currentPitch = 0.0
local _currentYaw = 0.0

-- Shake State
local _shakeTimer = 0.0
local _shakeIntensity = 0.0

function OnCreate(entity)
    entity.TransformC.Position = Math.Vec3.new(0, STARTING_HEIGHT, 20)
    entity.TransformC.Rotation = Math.Vec3.new(0.0, 0.0, 0.0)
    _orbitAngle = 0.0
    _menuTime = 0.0
    _currentPitch = 0.0
    _currentYaw = 0.0
    
    _G.CameraShake = function(intensity, duration)
        _shakeIntensity = intensity or 0.5
        _shakeTimer = duration or 0.2
    end
end

function OnUpdate(entity, dt)
    local currentPos = entity.TransformC.Position

    local targetY = _G.TowerCameraTargetY or STARTING_HEIGHT
    local baseRadius = BASE_ZOOM_Z

    if _G.PlaneIncoming then
        baseRadius = BASE_ZOOM_Z + ZOOM_OUT_AMOUNT + 20
    end

    local targetX = 0.0
    local targetZ = baseRadius
    local bobOffset = 0.0

    if _G.GameState == "MENU" then
        _menuTime = _menuTime + dt
        _orbitAngle = _orbitAngle + (dt * ORBIT_SPEED)

        if _orbitAngle > math.pi then
            _orbitAngle = _orbitAngle - (math.pi * 2.0)
        end

        bobOffset = math.sin(_menuTime * BOB_SPEED) * BOB_HEIGHT_AMPLITUDE

        local breatheOffset = math.sin(_menuTime * BREATHE_SPEED + 1.0) * BREATHE_AMPLITUDE
        local radius = baseRadius + breatheOffset

        targetX = math.sin(_orbitAngle) * radius
        targetZ = math.cos(_orbitAngle) * radius

        local targetPitch = MENU_PITCH + math.sin(_menuTime * PITCH_SWAY_SPEED) * PITCH_SWAY_AMPLITUDE
        _currentPitch = Math.Lerp(_currentPitch, targetPitch, dt * PITCH_LERP_SPEED)
        _currentYaw = _orbitAngle * (180.0 / math.pi)
    else
        _currentPitch = 0.0
        _currentYaw = 0.0
    end

    local newX = Math.Lerp(currentPos.x, targetX, dt * _zoomSpeedZ)
    local newY = Math.Lerp(currentPos.y, targetY + bobOffset, dt * _panSpeedY)
    local newZ = Math.Lerp(currentPos.z, targetZ, dt * _zoomSpeedZ)

    -- Camera Shake
    local shakeOffsetX = 0.0
    local shakeOffsetY = 0.0
    local shakeOffsetZ = 0.0
    if _shakeTimer > 0.0 then
        _shakeTimer = _shakeTimer - dt
        local fadeRatio = math.max(0.0, _shakeTimer) 
        local currentShakePower = _shakeIntensity * fadeRatio
        
        shakeOffsetX = (math.random() * 2.0 - 1.0) * currentShakePower
        shakeOffsetY = (math.random() * 2.0 - 1.0) * currentShakePower
        shakeOffsetZ = (math.random() * 2.0 - 1.0) * currentShakePower
    end

    entity.TransformC.Position = Math.Vec3.new(newX + shakeOffsetX, newY + shakeOffsetY, newZ + shakeOffsetZ)
    entity.TransformC.Rotation = Math.Vec3.new(_currentPitch, _currentYaw, 0.0)
end

function OnDestroy(entity)
    _orbitAngle = 0.0
    _menuTime = 0.0
    _currentPitch = 0.0
    _currentYaw = 0.0
    
    _shakeTimer = 0.0
    _shakeIntensity = 0.0
    _G.CameraShake = nil
end