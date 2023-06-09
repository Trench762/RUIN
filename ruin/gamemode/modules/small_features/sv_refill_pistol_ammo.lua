hook.Add("KeyPress", "RUIN sv_refill_pistol_ammo", function(ply, key)
    if !IsValid(ply) then return end
    if !ply:Alive() then return end
    if key != IN_RELOAD then return end

    local weapon = ply:GetActiveWeapon()
    if !IsValid(weapon) then return end

    if weapon:GetClass() != "weapon_pistol" then return end

    if ply:GetAmmoCount( "pistol" ) < 1000 then
        print(ply:GetAmmoCount( "pistol" ))
        ply:GiveAmmo( 9999, "pistol", true )
    end
end)