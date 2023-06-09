if SERVER then
    do
        util.AddNetworkString("RUIN Remove Weapon Skin")
        util.AddNetworkString("RUIN Reskin Weapon")

        util.PrecacheModel( "models/ruin/weapons/cxl-3.mdl" )
        util.PrecacheModel( "models/ruin/weapons/stng-r.mdl" )
        util.PrecacheModel( "models/ruin/weapons/sxv-3.mdl" ) 
        util.PrecacheModel( "models/ruin/weapons/gr-50.mdl" )
        util.PrecacheModel( "models/weapons/w_stunbaton.mdl" )
    end

    hook.Add("OnEntityCreated", "RUIN Reskin Weapon On NPC Spawn", function(ent)
        if !ent:IsNPC() then return end
        timer.Simple(0, function() -- TODO: See if can remove this timer later
            net.Start("RUIN Reskin Weapon")
            net.WriteEntity(ent)
            net.Broadcast()

            if !IsValid(ent) or !IsValid(ent:GetActiveWeapon()) then return end
            ent:GetActiveWeapon():SetNoDraw(true) 
        end)

        function ent:UpdateTransmitState()
            return TRANSMIT_ALWAYS
        end
    end)

    -- This also runs on spawn. (Not including first spawn, this is taken care of clientside by hard coding in timer)
    hook.Add("PlayerSwitchWeapon", "RUIN Reskin Weapon On Player Switch Weapon", function(ply, oldWeapon, newWeapon)
        if !ply:Alive() then return end
        timer.Simple(0, function() -- TODO: See if can remove this timer later.
            net.Start("RUIN Reskin Weapon")
            net.WriteEntity(ply)
            net.Broadcast()
        end)
    end)

    hook.Add("OnNPCKilled", "Remove Fake Weapons On NPC Death", function(npc)
        if !IsValid(npc) then return end
        net.Start("RUIN Remove Weapon Skin")
        net.WriteEntity(npc)
        net.Broadcast()
    end)

    hook.Add("PlayerDeath", "Remove Fake Weapons On Player Death", function(ply)
        if !IsValid(ply) then return end
        net.Start("RUIN Remove Weapon Skin")
        net.WriteEntity(ply)
        net.Broadcast()
    end)
end

if CLIENT then
    local ply = LocalPlayer()
    
    local weaponConversions = {
        ["models/weapons/w_pistol.mdl"] = "models/ruin/weapons/cxl-3.mdl",
        ["models/weapons/w_smg1.mdl"] = "models/ruin/weapons/stng-r.mdl",
        ["models/weapons/w_irifle.mdl"] = "models/ruin/weapons/sxv-3.mdl", 
        ["models/weapons/w_shotgun.mdl"] = "models/ruin/weapons/gr-50.mdl",
        ["models/weapons/w_stunbaton.mdl"] = "models/weapons/w_stunbaton.mdl",
    }

    local function reskinWeapon(owner)
        if !IsValid(owner) then return end
        if !IsValid(owner:GetActiveWeapon()) then return end
        
        if IsValid(owner.weaponSkin) then
            owner.weaponSkin:Remove()
        end

        owner.weaponSkin = ClientsideModel( weaponConversions[owner:GetActiveWeapon():GetModel()] )
        owner.weaponSkin:SetModel(weaponConversions[owner:GetActiveWeapon():GetModel()]) 
        owner.weaponSkin:SetParent(owner)
        owner.weaponSkin:AddEffects(EF_BONEMERGE)
        owner.weaponSkin:Spawn()
        owner.weaponSkin:SetRenderMode( RENDERMODE_TRANSALPHA )
        if owner:IsNPC() then
            owner.weaponSkin:SetNoDraw(true) -- Prevent flicker in when spawned. (FOW will fade this in when needed)
        end

        owner:CallOnRemove("RUIN Remove Weapon Skin When Owner Removed", function()
            owner.weaponSkin:Remove()
        end)

        if owner:isCloaking() then
            owner.weaponSkin:SetMaterial("models/shadertest/shader3")
        else
            owner.weaponSkin:SetMaterial("")
        end

        -- Need this cause sometimes when just switching weapon they are cloaking and so their skin gets set, but then they uncloak in the next frame or few miliseconds, leaving the gun with the cloaking material on.
        timer.Simple(.1, function()
            if !IsValid(owner) or !IsValid(owner.weaponSkin) then return end 
            if owner:isCloaking() then
                owner.weaponSkin:SetMaterial("models/shadertest/shader3")
            else
                owner.weaponSkin:SetMaterial("")
            end
        end)
    end

    net.Receive("RUIN Reskin Weapon", function()
        local ent = net.ReadEntity()
        reskinWeapon(ent)
    end)

    net.Receive("RUIN Remove Weapon Skin", function()
        local ent = net.ReadEntity()
        if !IsValid(ent.weaponSkin) then return end
        ent.weaponSkin:Remove()
    end)

    -- Takes care of first spawn skinning for client.
    timer.Simple(0, function()
        reskinWeapon(LocalPlayer())
    end)

    -- Needed because holding a grenade makes the active weapon render again. (Don't feel like figuring this out so im gonna brute force it)
    hook.Add("Think", "RUIN No Draw Active Weapon", function()
        local weapon = ply:GetActiveWeapon()
        if !IsValid(ply) or !IsValid(weapon) then return end
        ply:GetActiveWeapon():SetNoDraw(true)
    end)

    hook.Add( "Think", "RUIN active weapon copy player material", function()
        if !ply.weaponSkin or !IsValid(ply) or !IsValid(ply.weaponSkin) then return end
        ply.weaponSkin:SetMaterial( ply:GetMaterial() )
    end )

    --Needed to get around PVS issues for clientside renderweapon not following NPC's that spawn outside player's PVS.
    hook.Add("NotifyShouldTransmit", "RUIN NPC Weapon Skin Update On PVS Changed", function(ent, shouldtransmit)
        if !ent:IsNPC() then return end
        reskinWeapon(ent)
    end)
end





