local _timeAlive = 0.0 
local _hasLanded = false

function OnCreate(entity)
    -- local mat = entity.MeshC:GetMaterial(0)
end

function OnUpdate(entity, dt)
    _timeAlive = _timeAlive + dt
end

function OnCollisionEnter(entity, otherEntity)    
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
    _hasLanded = false
end