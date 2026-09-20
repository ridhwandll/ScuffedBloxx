local TARGET_BLOCK_COUNT = 8
local FLY_SPEED = 100.0

local _isTriggered = false
local _hasSpawned = false
local _timeAlive = 0.0
local _rb = nil
local _isCollided = false

function OnCreate(entity)

    _G.ResetPlane = function ()
        entity.TransformC.Position = Math.Vec3.new(-9999.0, -9999.0, -9999.0)
        _hasSpawned = false
        _isTriggered = false
        _isCollided = false
        _G.PlaneIncoming = false
    end

    _G.ResetPlane()
end

function OnUpdate(entity, dt)
    if _G.GameState ~= "PLAYING" then
        return
    end

    if not _isTriggered then
        if _G.ActiveBlocks and #_G.ActiveBlocks >= TARGET_BLOCK_COUNT then
            _isTriggered = true
            _G.PlaneIncoming = true
        end
        return
    end

    if _isTriggered then
        _timeAlive = _timeAlive + dt

        if not _hasSpawned then
            entity.TransformC.Position = Math.Vec3.new(-100.0, _G.TowerCameraTargetY - 10, 0.0)
            entity.TransformC.Rotation = Math.Vec3.new(0, -91.54, 0)
            
            local boxC = entity:AddBoxColliderC()
            boxC.HalfExtents = Math.Vec3.new(15.0, 6.0, 15.0)
            
            _rb = entity:AddRigidbodyC()
            _rb.Type = RigidbodyType.DYNAMIC
            _rb.Interpolate = true
            _rb.UseGravity = false
            _rb.ContinuousCollision = true
            _rb.Friction = 0.8
            _rb.Bounciness = 0.5
            _hasSpawned = true
            return
        end

        if _hasSpawned and _rb and not _isCollided then
            _rb:SetLinearVelocity(Math.Vec3.new(FLY_SPEED, 0.0, 0.0))
        elseif _hasSpawned and _rb and _isCollided then
            _rb:AddImpulse(Math.Vec3.new(FLY_SPEED, 0.0, 0.0))
        end

        if entity.TransformC.Position.x > 100.0 then
            if _rb then
                entity:RemoveRigidbodyC()
                entity:RemoveBoxColliderC()
                _G.PlaneIncoming = false
                _isCollided = false
            end            
        end
    end
end

function OnCollisionEnter(entity, otherEntity)        
    local otherName = otherEntity.NameC.Name
    if otherName == "HangingBlock" then
        _isCollided = true
    end    
end

function OnDestroy(entity)
    _isTriggered = false
    _hasSpawned = false
    _timeAlive = 0.0
    _rb = nil
end