hook.Add("KeyPress", "RUIN open physical doors detect use", function(ply,key)
    if !IsValid(ply) then return end
    if key != IN_USE then return end

    local ents = ents.FindInSphere((ply:GetPos() + ply:GetForward() * 64) + Vector(0,0,16), 32)
    --debugoverlay.Sphere((ply:GetPos() + ply:GetForward() * 64) + Vector(0,0,16), 32, 10, Color(0,255,0), true )
    local door

    for k, v in pairs(ents) do 
        if !( v:GetClass() == "prop_physics" && string.match( v:GetModel(), "door" ) == "door" ) then continue end
        if door then continue end -- If we found a door, just move on.
        door = v
    end
    
    if !door then return end
    if !IsValid(door) then return end
    local phys = door:GetPhysicsObject()
    phys:ApplyForceCenter( ply:GetAimVector() * 2500 )
end) 


