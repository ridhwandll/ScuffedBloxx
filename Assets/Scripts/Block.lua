local _timeAlive = 0.0
local mat = nil;
local _hasLanded = false

function OnCreate(entity)
    mat = entity.MeshC:GetMaterial(0)
end

function OnUpdate(entity, dt)
    _timeAlive = _timeAlive + dt
    
    -- Now the sine wave will actually progress forward!
    -- local time = _timeAlive * 5.0
    -- local pulse = (math.sin(time) + 1.0) / 2.0    
    -- local emissionColor = Math.Vec3.new(pulse, 0, pulse)
    -- mat:SetVec3("Albedo", emissionColor)
end

function OnCollisionEnter(entity, otherEntity)    
    -- If this specific block has already settled, ignore secondary shocks
    if _hasLanded or not entity:IsValid() or not otherEntity:IsValid() then
        return
    end
    
    if otherEntity.NameC.Name == "HangingBlock" then
        _hasLanded = true
        Log.Info("The block smashed into another block!")        
        if entity:HasAudioSourceC() then
            entity.AudioSourceC:Play()
        end
    end
end

function OnDestory(entity)
    --mat:SetVec3("Albedo", Math.Vec3.new(1, 1, 1));
    --mat = nil;
    _hasLanded = false
end