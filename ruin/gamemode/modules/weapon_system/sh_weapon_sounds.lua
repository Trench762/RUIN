local weaponSoundReplacements = {
    -- Viewmodel Sounds Player ---------------------------------------------
    ["Weapon_Pistol.Single"] = "ruin/weapons/CXL-3/CXL-3_fire_01.ogg",
    ["Weapon_Pistol.Reload"] = "ruin/weapons/CXL-3/CXL-3_reload_01.ogg",
    
    ["Weapon_AR2.Single"] = "ruin/weapons/SXV-3/SXV-3_fire_01.ogg",
    
    ["Weapon_SMG1.Single"] = "ruin/weapons/STNG-R/STNG-R_fire_01.ogg",
    
    ["Weapon_Shotgun.Single"] = "ruin/weapons/GR-50/GR-50_fire_01.ogg",
    ["Weapon_Shotgun.Special1"] = "ruin/weapons/GR-50/GR-50_reload_03.ogg", -- When shotgun is cocked
    
    -- World Sounds (NPC's) -----------------------------------------------
    ["Weapon_Pistol.NPC_Single"] = "ruin/weapons/CXL-3/CXL-3_fire_01.ogg",
    ["Weapon_Pistol.NPC_Reload"] = "ruin/weapons/CXL-3/CXL-3_reload_01.ogg",
    
    ["Weapon_SMG1.NPC_Single"] = "ruin/weapons/STNG-R/STNG-R_fire_01.ogg",
    ["Weapon_SMG1.NPC_Reload"] = "ruin/weapons/STNG-R/STNG-R_reload_01.ogg",
    
    ["Weapon_AR2.NPC_Single"] = "ruin/weapons/SXV-3/SXV-3_fire_01.ogg",
    ["Weapon_AR2.NPC_Reload"] = "ruin/weapons/SXV-3/SXV-3_reload_01.ogg",
    
    ["Weapon_Shotgun.NPC_Single"] = "ruin/weapons/GR-50/GR-50_fire_01.ogg",
    ["Weapon_Shotgun.NPC_Reload"] = "ruin/weapons/GR-50/GR-50_reload_01.ogg",
    
    ["BaseGrenade.Explode"] = "ruin/weapons/grenade/grenade_explode_01.ogg",
    ["BaseExplosionEffect.Sound"] = "ruin/weapons/grenade/grenade_explode_01.ogg",
}

hook.Add("EntityEmitSound", "RUIN Weapon System Sounds", function(data)

    if weaponSoundReplacements[data.OriginalSoundName] then
        data.SoundName = weaponSoundReplacements[data.OriginalSoundName]
        data.Volume = data.Entity:IsPlayer() and 0.2 or 0.6  -- No idea why but default volumes of weapons are different from each other, so setting them all to be at max here.
    end

    return true
end)


