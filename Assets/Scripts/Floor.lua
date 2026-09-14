function OnCollisionEnter(entity, otherEntity)    
    if otherEntity.NameC.Name == "HangingBlock" then
        otherEntity:Destroy()
    end
end