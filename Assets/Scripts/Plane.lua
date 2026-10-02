local TARGET_BLOCK_COUNT = 15
local FLY_SPEED = 100.0

local _state = "IDLE" -- "IDLE", "FLYING", "CRASHED"
local _timeAlive = 0.0
local _cleanupTimer = 0.0

local _planeIncomingAudioSrc = nil
local _planeCrashAudioSrc = nil
local _particles = {}

local function RandomRange(minVal, maxVal)
    return minVal + math.random() * (maxVal - minVal)
end

local function SpawnExplosionParticles(position)
    local numParticles = 120
    for i = 1, numParticles do
        local angleX = RandomRange(0.0, math.pi * 2.0)
        local angleY = RandomRange(0.0, math.pi * 2.0)
        local speed = RandomRange(15.0, 70.0)

        local velX = math.cos(angleY) * math.cos(angleX) * speed + (FLY_SPEED * 0.4)
        local velY = math.sin(angleX) * speed
        local velZ = math.sin(angleY) * math.cos(angleX) * speed

        table.insert(_particles, {
            Pos = Math.Vec3.new(position.x, position.y, position.z),
            Vel = Math.Vec3.new(velX, velY, velZ),
            Rot = Math.Vec3.new(RandomRange(0, 360), RandomRange(0, 360), RandomRange(0, 360)),
            RotVel = Math.Vec3.new(RandomRange(-150, 150), RandomRange(-150, 150), RandomRange(-150, 150)),
            Scale = RandomRange(4.0, 9.0),
            Life = RandomRange(0.5, 1.5),
            MaxLife = 1.5
        })
    end
end

local function BlowUpTower(impactPos)
    if not _G.ActiveBlocks then return end
    
    for i = 1, #_G.ActiveBlocks do
        local blockEntity = _G.ActiveBlocks[i]
        
        if blockEntity and blockEntity:IsValid() and blockEntity:HasRigidbodyC() then
            local rb = blockEntity.RigidbodyC
            local pos = blockEntity.TransformC.Position
            
            local zOffset = pos.z - impactPos.z
            local directionZ = zOffset > 0 and 1.0 or -1.0
            local velZ = directionZ * RandomRange(30.0, 90.0)
            rb:SetLinearVelocity(Math.Vec3.new(0, 0, velZ))
            
            local spinX = RandomRange(-600.0, 600.0)
            local spinY = RandomRange(-600.0, 600.0)
            local spinZ = RandomRange(-600.0, 600.0)
            rb:SetAngularVelocity(Math.Vec3.new(spinX, spinY, spinZ))
        end
    end
end

function OnCreate(entity)
    _planeIncomingAudioSrc = entity:FindEntityByName("PlaneIncomingAudio").AudioSourceC
    _planeCrashAudioSrc = entity:FindEntityByName("Plane").AudioSourceC

    _G.ResetPlane = function ()
        entity.TransformC.Position = Math.Vec3.new(-9999.0, -9999.0, -9999.0)        
        if entity:HasRigidbodyC() then entity:RemoveRigidbodyC() end
        if entity:HasBoxColliderC() then entity:RemoveBoxColliderC() end        
        _G.PlaneIncoming = false
        _state = "IDLE"
        _cleanupTimer = 0.0
    end

    _G.ResetPlane()
end

function OnUpdate(entity, dt)
    for i = #_particles, 1, -1 do
        local p = _particles[i]
        p.Life = p.Life - dt

        if p.Life <= 0.0 then
            table.remove(_particles, i)
        else
            p.Vel.x = p.Vel.x * (1.0 - (4.0 * dt))
            p.Vel.z = p.Vel.z * (1.0 - (4.0 * dt))
            p.Vel.y = p.Vel.y - (12.0 * dt)

            p.Pos.x = p.Pos.x + (p.Vel.x * dt)
            p.Pos.y = p.Pos.y + (p.Vel.y * dt)
            p.Pos.z = p.Pos.z + (p.Vel.z * dt)

            p.Rot.x = p.Rot.x + (p.RotVel.x * dt)
            p.Rot.y = p.Rot.y + (p.RotVel.y * dt)
            p.Rot.z = p.Rot.z + (p.RotVel.z * dt)

            local lifeRatio = p.Life / p.MaxLife
            
            local r = lifeRatio > 0.5 and 1.0 or (lifeRatio * 2.0)
            local g = lifeRatio > 0.5 and (lifeRatio * 0.8) or (lifeRatio * 0.5)
            local b = lifeRatio > 0.8 and 0.2 or 0.0
            local alpha = lifeRatio * 0.9

            local posVec = Math.Vec3.new(p.Pos.x, p.Pos.y, p.Pos.z)
            local rotVec = Math.Vec3.new(p.Rot.x, p.Rot.y, p.Rot.z)
            local scaleVec = Math.Vec3.new(p.Scale, p.Scale, p.Scale)
            local colorVec = Math.Vec4.new(r, g, b, alpha)

            Renderer.DrawQuad(posVec, rotVec, scaleVec, colorVec)
        end
    end

    if _G.GameState ~= "PLAYING" then
        return
    end

    _timeAlive = _timeAlive + dt

    -- STATE 1: Waiting for the tower to reach the threshold
    if _state == "IDLE" then
        if _G.ActiveBlocks and #_G.ActiveBlocks >= TARGET_BLOCK_COUNT then
            _state = "FLYING"
            _G.PlaneIncoming = true
            if _planeIncomingAudioSrc then _planeIncomingAudioSrc:Play() end
            
            entity.TransformC.Position = Math.Vec3.new(-400.0, _G.TowerCameraTargetY - 10, 0.0)
            entity.TransformC.Rotation = Math.Vec3.new(0, -91.54, 0)
            
            local boxC = entity:HasBoxColliderC() and entity.BoxColliderC or entity:AddBoxColliderC()
            boxC.HalfExtents = Math.Vec3.new(15.0, 6.0, 15.0)

            local rb = entity:HasRigidbodyC() and entity.RigidbodyC or entity:AddRigidbodyC()
            rb.Type = RigidbodyType.DYNAMIC
            rb.Interpolate = true
            rb.UseGravity = false
            rb.ContinuousCollision = true
            rb.Friction = 0.8
            rb.Bounciness = 0.5
            
            rb:SetLinearVelocity(Math.Vec3.new(FLY_SPEED, 0.0, 0.0))
        end
        return
    end

    if _state == "FLYING" then
        if entity:HasRigidbodyC() then
            entity.RigidbodyC:SetLinearVelocity(Math.Vec3.new(FLY_SPEED, 0.0, 0.0))
        end

        -- If the plane somehow misses and flies off-screen, reset it
        if entity.TransformC.Position.x > 100.0 then
            _G.ResetPlane()
        end
        return
    end

    if _state == "CRASHED" then
        _cleanupTimer = _cleanupTimer + dt
        
        entity.TransformC.Position = Math.Vec3.new(-9999.0, -9999.0, -9999.0)

        if _cleanupTimer > 3.0 then
            _G.ResetPlane()
        end
    end
end

function OnCollisionEnter(entity, otherEntity)        
    if _state ~= "FLYING" then return end
    
    if not otherEntity:HasNameC() then return end
    local otherName = otherEntity.NameC.Name
    
    if otherName == "HangingBlock" or otherName == "Floor" then
        -- Instantly shift to CRASHED state
        _state = "CRASHED"
        _cleanupTimer = 0.0
        
        if _planeCrashAudioSrc then
            _planeCrashAudioSrc.Volume = 2
            _planeCrashAudioSrc:Play()
        end

        if _planeIncomingAudioSrc then
            _planeIncomingAudioSrc:Stop()
            _planeIncomingAudioSrc:Seek(0)
        end

        if _G.CameraShake then _G.CameraShake(3, 1) end
        
        local impactPos = entity.TransformC.Position
        SpawnExplosionParticles(impactPos)
        BlowUpTower(impactPos)
        
        if entity:HasRigidbodyC() then entity:RemoveRigidbodyC() end
        if entity:HasBoxColliderC() then entity:RemoveBoxColliderC() end
    end    
end

function OnDestroy(entity)
    _state = "IDLE"
    _particles = {}
    _cleanupTimer = 0.0
end