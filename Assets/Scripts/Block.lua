local _timeAlive = 0.0 
local _hasLandedOnBlock = false
local _hasLandedOnFloor = false

local _isDead = false
local _deathTimer = 0.0
local DEATH_DURATION = 5.0

local blockHitAudioPlayer = nil

function OnCreate(entity)
    blockHitAudioPlayer = entity:FindEntityByName("BlockHitAudioPlayer").AudioSourceC
end

function OnUpdate(entity, dt)
    _timeAlive = _timeAlive + dt

    if _isDead then
        _deathTimer = _deathTimer - dt
        if _deathTimer <= 0.0 then
            entity:Destroy()
        end
    end
end

function OnCollisionEnter(entity, otherEntity)    
    
    local otherName = otherEntity.NameC.Name
    if otherName == "HangingBlock" and not _hasLandedOnBlock then
        _hasLandedOnBlock = true
        blockHitAudioPlayer:Play()
    end

    if otherName == "Floor" and not _hasLandedOnFloor then
        _G.OnBlockFellOff()
        _hasLandedOnFloor = true
        _isDead = true
        _deathTimer = DEATH_DURATION
    end
end

function OnDestory(entity)
    _hasLandedOnBlock = false
    _hasLandedOnFloor = false
end