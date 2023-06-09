hook.Add("DoPlayerDeath", "RUIN Player Drop Weapons On Death", function( ply )
    local weapon = ply:GetActiveWeapon()
    local equippedWeapon = ents.Create(RUIN.weaponConversions[weapon:GetClass()])
    -- Create weapon.
    equippedWeapon:SetPos(ply:GetActiveWeapon():GetWorldTransformMatrix():GetTranslation() + Vector(0,0,64) + (ply:EyeAngles():Forward() * 10))
    if(ply:GetActiveWeapon():GetClass() == "weapon_smg1") then
        equippedWeapon:SetAngles(ply:GetAngles())
    else
        equippedWeapon:SetAngles(ply:GetAngles() * -1)
    end
    equippedWeapon:Spawn()
    
    -- Make it fly forward and spin.
    local equippedWeaponPhysObj = equippedWeapon:GetPhysicsObject()
    equippedWeaponPhysObj:SetVelocity(ply:GetForward() * (math.min(equippedWeaponPhysObj:GetMass() * 150, 150)))
    equippedWeaponPhysObj:ApplyTorqueCenter(Vector(math.min(equippedWeaponPhysObj:GetMass() * math.random(3,6), 5), math.min(equippedWeaponPhysObj:GetMass() * math.random(3,6), 5), math.min(equippedWeaponPhysObj:GetMass() * math.random(3,6)), 5))

    -- Code below is to drop the holstered weapon.
    if(ply:activeWeaponClass() == "none" or ply:hasPrimaryEquipped()) then return end
    
    local holsteredWeapon = ents.Create(RUIN.weaponConversions[ply:activeWeaponClass()])
    holsteredWeapon:SetPos( ply:GetPos() + Vector(0,0,32))
    holsteredWeapon:SetAngles( ply:GetAngles() )
    holsteredWeapon:Spawn()
    
    local holsteredWeaponPhysObj = holsteredWeapon:GetPhysicsObject()
    holsteredWeaponPhysObj:SetVelocity(ply:GetForward() * -100)
    holsteredWeaponPhysObj:ApplyTorqueCenter(Vector(math.random(20,50), math.random(20,50), math.random(20,50)))
end)

