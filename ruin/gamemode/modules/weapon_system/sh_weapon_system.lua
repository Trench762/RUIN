if CLIENT then
    local maxHaloAlpha = 125
    local distToWeapon = 0
    local ply = LocalPlayer()

    hook.Add( "PreDrawHalos", "RUIN Weapon Halos", function() 
        -- Health is actually more reliable since ply:Alive() gets called a bit late which results in the halo rendering for a little after the player is technically dead.
        if (!IsValid(ply) or ply:Health() <= 0) then return end
        if ply.escMenuOpen then return end
        for k, v in ipairs(ents.FindByClass( "ruin_weapon*")) do
            -- We dont render a halo for pistol or stun_stick since player can't pick them up.
            distToWeapon = Entity(1):GetPos():DistToSqr(v:GetPos())
            if RUIN.extracted then return end
            if ( distToWeapon > 25600 or (v:GetClass() == "ruin_weapon_pistol") or (v:GetClass() == "ruin_weapon_stunstick")) then continue end
            
            local weaponMagCount = v:getMagCount()
            local magMax = v.magMax
            
            if(weaponMagCount == magMax) then
                local _color_green = Color(0, 255, 0, 125)
                _color_green.a = maxHaloAlpha * math.Remap(distToWeapon,0,25600,1,0)
                halo.Add( {v}, _color_green, 1, 1, 1 ) 
            elseif(weaponMagCount >= magMax * .66) then
                local _color_yellow = Color(255, 191, 0, 125)
                _color_yellow.a = maxHaloAlpha * math.Remap(distToWeapon,0,25600,1,0)
                halo.Add( {v}, _color_yellow, 1, 1, 1 ) 
            elseif(weaponMagCount >= magMax * .34) then
                local _color_orange = Color(255, 93, 0, 125)
                _color_orange.a = maxHaloAlpha * math.Remap(distToWeapon,0,25600,1,0)
                halo.Add( {v}, _color_orange, 1, 1, 1 ) 
            elseif(weaponMagCount > 0) then 
                local _color_red = Color(255, 0, 0, 125)
                _color_red.a = maxHaloAlpha * math.Remap(distToWeapon,0,25600,1,0)
                halo.Add( {v}, _color_red, 1, 1, 1 ) 
            end
        end
    end )
    
    -- TODO: AR2 Replacment.
    local weaponRenderList = {
        ["weapon_smg1"] = { "models/ruin/weapons/stng-r.mdl",   Vector(-10.084167480469, -1.982666015625, -6.8025512695313), Angle(0.25680103898048, 162.45446777344, 137.23658752441) },
        ["weapon_ar2"] = { "models/ruin/weapons/sxv-3.mdl",     Vector(-1.5551452636719, -1.0799560546875, -9.7564697265625), Angle(-4.8483195304871, 159.15351867676, -36.289672851563) },
        ["weapon_shotgun"] = { "models/ruin/weapons/gr-50.mdl", Vector(-0.39724731445313, -2.4524536132813, -8.6998901367188), Angle(4.3448867797852, 158.66273498535, -35.947872161865) } 
    }
    
    local holsteredWeapon
    local pistolIsHolstered 
    
    function eMeta:drawHolsteredWeapon(pickedUpWeapon)
        if(ply:hasPrimaryEquipped()) then
            holsteredWeapon = weaponRenderList[ply:activeWeaponClass()]
            pistolIsHolstered = false
        else
            pistolIsHolstered = true
        end

        if (ply.renderWeapon) then 
            ply.renderWeapon:Remove()
        end
        
        if(pickedUpWeapon) then 
            if !IsValid(ply.renderWeapon) then return end
            ply.renderWeapon:Remove()
        end

        if(ply:activeWeaponClass() == "none") then
            if !IsValid(ply.renderWeapon) then return end
            ply.renderWeapon:Remove()
            return 
        end
        
        if(pistolIsHolstered) then return end
        ply.renderWeapon = ClientsideModel( holsteredWeapon[1] )

        if(holsteredWeapon[1] == "models/weapons/w_smg1.mdl") then
            ply.renderWeapon:SetPos( LocalPlayer():GetPos() + ply:GetAngles():Right() * 5 - ply:GetAngles():Forward() * 7)
            
            local angle = LocalPlayer():GetAngles()
            angle:RotateAroundAxis( ply:EyeAngles():Up(), 180 )
            ply.renderWeapon:SetAngles( angle )
        else
            ply.renderWeapon:SetPos( LocalPlayer():GetPos() + ply:GetAngles():Right() * 7 - ply:GetAngles():Forward() * 5)
            ply.renderWeapon:SetAngles( LocalPlayer():GetAngles() )
        end
        
        ply.renderWeapon:Spawn()
        ply.renderWeapon:FollowBone( ply, 4 ) -- 4 = ValveBiped.Bip01_Spine4
    end

    hook.Add( "Think", "RUIN backup weapon copy player material", function()
        local ply = LocalPlayer()
        if !ply.renderWeapon or !IsValid(ply) or !IsValid(ply.renderWeapon) then return end
        ply.renderWeapon:SetMaterial( ply:GetMaterial() )
    end )
    
    net.Receive("RUIN Notify Player Draw Holstered Weapon Post Death", function()
        -- Need to set this here because it wont send from the server fast enough, 
        -- we know if we're receiving this that active weapon will be none anyways, so its fine.
        LocalPlayer():setActiveWeaponClass("none") 
        LocalPlayer():drawHolsteredWeapon(false) 
    end)
    
    local function reloadingLaserAction()
        LocalPlayer().isReloadingPistol = true 
        timer.Remove( "RUIN Enable Laser Post Switch After Mag Was Empty")
        timer.Create("RUIN Enable Laser Post Switch After Mag Was Empty", 1.5, 1, function()
            LocalPlayer().isReloadingPistol = false
        end)
    end
    
    hook.Add("PlayerBindPress", "RUIN Switch Weapons", function(ply, bind, pressed, code)
        if( (!IsValid(ply)) or (ply:hasPrimary() == false) ) or bind != "+showscores" or !ply:Alive() or ply:Health() <= 0 then return end

        ply:drawHolsteredWeapon(false)
    
        net.Start("RUIN Player Switch Weapon")
        net.SendToServer()

        surface.PlaySound("weapons/smg1/switch_single.wav")

        -- This shit is inverted cause bullshit idk, im tired
        if(ply:GetActiveWeapon():GetClass() == "weapon_pistol") then  
            ply.isReloadingPistol = false -- So if ur reloading pistol and u swap to primary before fully reloading it u will still have a laser. (Check bottom of camera_and_control/sh_camera_and_control)
        else
            if(ply:GetWeapons()[1]:Clip1() != 0) then return end
            reloadingLaserAction()
        end
    end)

    hook.Add("PlayerBindPress" , "RUIN Reload Detect", function(ply, bind, pressed, code)
		if ( !IsValid(ply) or ply:Health() <= 0 ) then return end -- MUST DO ISVALID FIRST BECAUSE U CANT GET HP OF NON-EXISTANT PLAYER
		if (bind == "+reload") then 
			local weapon = ply:GetActiveWeapon()
			if !IsValid(weapon) then return end
			if ( !(weapon:GetClass() == "weapon_pistol") or (weapon:Clip1() == 18) ) then return end
			
			reloadingLaserAction()
		end
	end)

    net.Receive("Ruin Notify Player Dumped Mag For Laser", function()
        reloadingLaserAction()
    end)
end
    
if SERVER then
    util.AddNetworkString( "RUIN Player Switch Weapon" )
    util.AddNetworkString( "RUIN Notify Player Dumped Mag For Laser" )
    util.AddNetworkString( "RUIN Notify Player Draw Holstered Weapon" )
    util.AddNetworkString( "RUIN Notify Player Draw Holstered Weapon Post Death")

    net.Receive("RUIN Player Switch Weapon", function(len, ply)
        if(ply:hasPrimaryEquipped()) then
            ply:SelectWeapon("weapon_pistol")
            ply:setHasPrimaryEquipped(false)
        else
            ply:SelectWeapon(ply:activeWeaponClass())
            ply:setHasPrimaryEquipped(true)
        end
    end)


    RUIN.weaponConversions = {
        ["weapon_pistol"] = "ruin_weapon_pistol",
        ["weapon_smg1"] = "ruin_weapon_smg1",
        ["weapon_357"] = "ruin_weapon_357",
        ["weapon_ar2"] = "ruin_weapon_ar2",
        ["weapon_shotgun"] = "ruin_weapon_shotgun", 
        ["weapon_stunstick"] = "ruin_weapon_stunstick"
    }

    function RUIN.dropWeapon(ply, weaponToDrop, ammoCount, isSwap, swapEnt)
        if(weaponToDrop == "weapon_pistol") then return end
        ply:StripWeapon(weaponToDrop)
        -- If the player is not swapping to another weapon then swap to pistol 
        -- (This means they shot off all the ammo in their primary)
        if(isSwap == false) then  
            ply:SelectWeapon( "weapon_pistol" )
            ply:setHasPrimary(false)
            ply:setHasPrimaryEquipped(false)
            ply:setActiveWeaponClass("none")
        end
        
        local weapon = ents.Create(RUIN.weaponConversions[weaponToDrop]) 
        
        if( (IsValid(swapEnt)) and (swapEnt:fromCrate() == true) ) then
            weapon:SetPos(swapEnt:GetPos())
            weapon:SetAngles(swapEnt:GetAngles())
            weapon:Spawn()
            weapon:setMagCount(ammoCount)
            weapon:SetMoveType(MOVETYPE_NONE)
            weapon:setFromCrate(true)
            return  
        end

        weapon:SetPos(ply:WorldSpaceCenter())
        weapon:Spawn()
        weapon:setMagCount(ammoCount)
        
        -- If shot of all ammo, throw weapon, if just switching, drop weapon on ground.
        if(!isSwap) then
            local physObj = weapon:GetPhysicsObject()
            local angle = ply:GetAngles()
            angle:RotateAroundAxis( Vector(0,0,1), 180 )
            physObj:SetAngles(angle)
            physObj:ApplyTorqueCenter(Vector(math.random(20,50), math.random(20,50), math.random(20,50)))
            physObj:SetVelocity(ply:EyeAngles():Forward() * 300)
        else
            weapon:SetPos(weapon:GetPos() + Vector(0,0,32))
            local physObj = weapon:GetPhysicsObject()
            local angle = ply:GetAngles()
            angle:RotateAroundAxis( Vector(0,0,1), 180 )
            physObj:SetAngles(angle)
            physObj:ApplyTorqueCenter(Vector(math.random(20,50), math.random(20,50), math.random(20,50)))
        end

        -- If it's arena mode, the weapon is dropped with 0 ammo and will dis-appear.
        if tonumber(RUIN.mapSettings["mode"]) == 0 then return end -- 0 = Extraction
        weapon:setMagCount(0)
        weapon:SetRenderMode(RENDERMODE_TRANSALPHA)
        
        local color = Color(255,255,255,255)
        timer.Simple(5, function()
            if !IsValid(weapon) then return end
            weapon:SetSubMaterial(1, "Models/effects/vol_light001") -- Disables shell outline on weapon. Looks weird when faded.
            timer.Create("RUIN Weapon System Arena Mode Fade Dropped Player Weapons", .05, 20, function()
                if !IsValid(weapon) then return end
                color.a = math.max(0, color.a - 13)
                weapon:SetColor(color)
                
                if timer.RepsLeft("RUIN Weapon System Arena Mode Fade Dropped Player Weapons") == 0 then
                    weapon:Remove()
                end
            end)
        end)
    end

    hook.Add("DoPlayerDeath", "RUIN Manage Holstered Weapons On Death", function(ply)
        net.Start("RUIN Notify Player Draw Holstered Weapon Post Death", false)
        net.Broadcast()
    end)

    hook.Add("EntityFireBullets","RUIN Weapons Manager", function(ent, data)
        if ( !IsValid(ent) or !ent:IsPlayer()) then return end
        local activeWeapon = ent:GetActiveWeapon()

        ------Low ammo stuff------
        local lowAmmoAmt = math.Round(ent:GetActiveWeapon():GetMaxClip1() * .25, 0)
        if(activeWeapon:Clip1() <= lowAmmoAmt) then
            ent:EmitSound("weapons/ar2/ar2_empty.wav",150,100,1)
        end
        --------------------------

        -- Making sure the laser is disabled if the player is auto reloading the pistol or runs out of ammo on primary and switches to empty pistol.
        if(activeWeapon:Clip1() == 0 and ent:GetWeapons()[1]:Clip1() == 0) then 
            net.Start("RUIN Notify Player Dumped Mag For Laser")
            net.Send(ent) 
        end

        if(activeWeapon:GetClass() == "weapon_pistol") then return end
        -- This is kind of a stupid way of doing this.
        if(activeWeapon:Clip1() <= 0) then
            ent:setPrimaryMag(0)
            RUIN.dropWeapon(ent, ent:GetActiveWeapon():GetClass(), ent:getPrimaryMag(), false)
        else
            ent:setPrimaryMag(ent:getPrimaryMag() - 1)
        end
    end)

    local function replaceAllWeapons()        
        for k, v in pairs(ents.FindByClass("weapon_*")) do 
            -- Needed so weapons that belong to actors and players arent replaced.
            if(v:GetParent() != NULL) then continue end
            
            -- Just remove the weapon in Arena, don't replace it with the RUIN weapon alternative.
            if tonumber(RUIN.mapSettings["mode"]) == 1 then 
                v:Remove() 
                continue
            end 
            
            local weaponReplacement = RUIN.weaponConversions[v:GetClass()]
            if !weaponReplacement then continue end
            
            weaponReplacement = ents.Create(weaponReplacement)
            weaponReplacement:SetPos(v:GetPos())
            weaponReplacement:Spawn()
        end
    end

    local function replaceDeadNPCWeapon(npc, weapon)          
        if !IsValid(npc) or !IsValid(weapon) then return end
    
        local weaponReplacement = RUIN.weaponConversions[weapon:GetClass()]
        if !weaponReplacement then return end
        
        local weaponClass = weapon:GetClass()
        
        weaponReplacement = ents.Create(weaponReplacement)
        weaponReplacement:SetPos(npc:GetPos() + Vector(0,0,64))
        weaponReplacement:Spawn()
        
        if (weaponClass != "weapon_pistol" and weaponClass != "weapon_stunstick" and weaponClass != "weapon_crowbar" and weaponClass != "weapon_frag") then
            weaponReplacement:setMagCount( weapon:GetClass() == "weapon_shotgun" and 1 or math.max(0, (weapon:Clip1() - weapon:GetMaxClip1() * 0.6)) ) 
            if math.random(2) == 1 then weaponReplacement:setMagCount(0) end
        end
        
        weapon:Remove()
        
        -- Send it flying if its an npc dying and dropping a weapon.
        local equippedWeaponToDropPhysObj =  weaponReplacement:GetPhysicsObject()
        equippedWeaponToDropPhysObj:SetVelocity(npc:GetAngles():Forward() * (math.min(equippedWeaponToDropPhysObj:GetMass() * 100, 100)))
        equippedWeaponToDropPhysObj:ApplyTorqueCenter(Vector(math.min(equippedWeaponToDropPhysObj:GetMass() * math.random(3,6), 5), math.min(equippedWeaponToDropPhysObj:GetMass() * math.random(3,6), 5), math.min(equippedWeaponToDropPhysObj:GetMass() * math.random(3,6)), 5))
    end

    -- Replace default weapons on map spawn.
    hook.Add("PostCleanupMap", "RUIN Weapon Replace On Map Cleanup", replaceAllWeapons)

    -- Replace weapons when an NPC is killed.
    hook.Add("OnNPCKilled", "RUIN Weapon Replace On NPC Killed", function(npc)
        -- Just remove the weapon in Arena, don't replace it with the RUIN weapon alternative.
        if tonumber(RUIN.mapSettings["mode"]) == 1 then 
            npc:GetActiveWeapon():Remove() 
            return
        end  

        replaceDeadNPCWeapon(npc, npc:GetActiveWeapon()) 
    end)

    hook.Add("FindUseEntity", "RUIN Weapon System Prevent Shield Block Weapon Pickup", function(ply,ent)
        if !ent then return end
        if !IsValid(ent) then return end

        if ent:GetClass() == "ruin_force_shield" then
            local ents = ents.FindInSphere((ply:GetPos() + ply:GetForward() * 64) + Vector(0,0,16), 32)
            --debugoverlay.Sphere((ply:GetPos() + ply:GetForward() * 64) + Vector(0,0,16), 32, 10, Color(0,255,0), true )
            local weapon
    
            for k, v in pairs(ents) do 
                if v:GetClass() != "ruin_wep_use_radius" then continue end
                if weapon then continue end -- If we found a weapon just move on.
                weapon = v
            end
            
            if !weapon then return end
            return weapon
        end
    end)
end
    
    