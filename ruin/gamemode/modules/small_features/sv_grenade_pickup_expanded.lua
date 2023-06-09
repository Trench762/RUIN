hook.Add("KeyPress", "RUIN Detect Use For Grenade Pickup Expanded", function(ply, key)
    if key != IN_USE then return end
    local searchPos = ply:WorldSpaceCenter() + ply:EyeAngles():Forward() * 64 
    local currentClosestNadeDist = 5184 -- This will be the maximum distance a player can grab.
    local closestGrenade = nil

    for k, v in pairs(ents.FindByClass("npc_grenade_frag")) do 
        local dist = ply:GetPos():DistToSqr( v:GetPos() ) 
        
        if dist < currentClosestNadeDist then 
            currentClosestNadeDist = dist 
            closestGrenade = v 
        end
    end
    
    if !IsValid(closestGrenade) then return end
    -- Needed because Source will call use at the same time, check if the object is in hand (which it will be) 
    -- and if it is, it will drop it, resulting in never being able to pick up and object while also having your hands 
    -- occupied and having use disabled.
    timer.Simple(0, function() 
        ply:PickupObject( closestGrenade )
    end)
end)

