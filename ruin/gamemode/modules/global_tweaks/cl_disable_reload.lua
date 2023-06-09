hook.Add("PlayerBindPress", "RUIN Block Reload", function(ply, bind)
    if bind != "+reload" then return end
    if !IsValid(ply:GetActiveWeapon()) then return end
    
    -- Block reloading with primary weapons.
    if ply:GetActiveWeapon():GetClass() != "weapon_pistol" then
        return true
    end
end)