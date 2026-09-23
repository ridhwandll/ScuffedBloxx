local _timeAlive = 0.0 
local _hasLandedOnBlock = false
local _hasLandedOnFloor = false

local _isDead = false
local _deathTimer = 0.0
local DEATH_DURATION = 5.0

local blockHitAudioPlayer = nil

local _particles = {} 

local function RandomRange(minVal, maxVal)
    return minVal + math.random() * (maxVal - minVal)
end

local function SpawnImpactParticles(position)
    local particleCount = 24
    for i = 1, particleCount do
        local angle = RandomRange(0.0, math.pi * 2.0)
        
        local speed = RandomRange(15.0, 35.0) 
        local velX = math.cos(angle) * speed
        local velZ = math.sin(angle) * speed
        local velY = RandomRange(0.5, 3.0) 
        
        table.insert(_particles, {
            Pos = Math.Vec3.new(position.x, position.y - 1.0, position.z),
            Vel = Math.Vec3.new(velX, velY, velZ),
            Life = RandomRange(0.2, 0.7),
            MaxLife = 0.4
        })
    end
end

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

    -- Particles
    for i = #_particles, 1, -1 do
        local p = _particles[i]
        p.Life = p.Life - dt

        if p.Life <= 0.0 then
            table.remove(_particles, i)
        else
            p.Vel.x = p.Vel.x * (1.0 - (8.0 * dt))
            p.Vel.z = p.Vel.z * (1.0 - (8.0 * dt))
            
            p.Vel.y = p.Vel.y - (20.0 * dt)
            
            p.Pos.x = p.Pos.x + (p.Vel.x * dt)
            p.Pos.y = p.Pos.y + (p.Vel.y * dt)
            p.Pos.z = p.Pos.z + (p.Vel.z * dt)

            local p0 = Math.Vec3.new(p.Pos.x, p.Pos.y, p.Pos.z)
            local p1 = Math.Vec3.new(p.Pos.x - (p.Vel.x * 0.03), p.Pos.y - (p.Vel.y * 0.03), p.Pos.z - (p.Vel.z * 0.03))            
            local color = Math.Vec4.new(0.85, 0.85, 0.85, 1)

            Renderer.DrawLine(p0, p1, color)
        end
    end
end

function OnCollisionEnter(entity, otherEntity)    
    if not otherEntity:HasNameC() then return end
    local otherName = otherEntity.NameC.Name
    
    if otherName == "HangingBlock" and not _hasLandedOnBlock then
        _hasLandedOnBlock = true
        if blockHitAudioPlayer then blockHitAudioPlayer:Play() end
        SpawnImpactParticles(entity.TransformC.Position)
    end

    if otherName == "Floor" and not _hasLandedOnFloor then
        if _G.OnBlockFellOff then _G.OnBlockFellOff() end
        _hasLandedOnFloor = true
        _isDead = true
        _deathTimer = DEATH_DURATION
        SpawnImpactParticles(entity.TransformC.Position)
    end
end

function OnDestroy(entity)
    _hasLandedOnBlock = false
    _hasLandedOnFloor = false
    _isDead = false
    _particles = {}
end