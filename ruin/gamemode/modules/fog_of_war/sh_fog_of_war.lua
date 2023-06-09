if SERVER then
    local nextThink = CurTime()
    local tr1, tr2, tr3
    local player = nil
    local _filter = {}
    local DEBUG = false -- SET THIS TO TRUE TO VISUALIZE DEBUGGING, REQUIRED "developer 1" IN CONSOLE

    util.AddNetworkString("RUIN FOW Fade Entity In")
    util.AddNetworkString("RUIN FOW Fade Entity Out")

    hook.Add("PlayerSpawn", "RUIN Fog Of War Set Up Ents On Load", function(ply, transition)
        _filter = {}
        
        timer.Simple(1, function()
            player = ply
            for k, v in pairs(ents.FindByClass("npc_*")) do
                if !v then return end
                if !IsValid(v) then return end
                v:SetRenderMode( RENDERMODE_TRANSALPHA )
            end

            -- Getting func_brushes that are being used as low cover to be filtered out later by fog of war trace filter.
            for k, v in pairs(ents.FindByClass("func_brush")) do
                if (string.StartWith( v:GetName(), "fow_ignore" )) then
                    table.insert( _filter, v )
                end
            end
            
            -- Breakables need to be filtered for seperately.
            for k, v in pairs(ents.FindByClass("func_breakable")) do
                if (string.StartWith( v:GetName(), "fow_ignore" )) then
                    table.insert( _filter, v )
                end
            end

            -- Getturrets and model based cover to be filtered out later by fog of war trace filter.
            for k, v in pairs(ents.FindByClass("prop_dynamic")) do
                if (v:GetModel() == "models/props_combine/bunker_gun01.mdl") then
                    table.insert( _filter, v )
                end
                if (string.StartWith( v:GetName(), "fow_ignore" )) then
                    table.insert( _filter, v )
                end
            end

            -- Get all prop_physics flagged as fow_ignore to be filtered out later by the fog of war trace filter.
            for k, v in pairs(ents.FindByClass("prop_physics")) do
                if (string.StartWith( v:GetName(), "fow_ignore" )) then
                    table.insert( _filter, v )
                end
            end

            -- Getting initially spawned npc_view_cull.
            for k, v in pairs(ents.FindByClass("npc_view_cull")) do
                table.insert( _filter, v )
            end

            -- Add player to the filter too.
            if !IsValid(player) then return end
            table.insert(_filter, player)
        end)
    end)

    hook.Add("WeaponEquip", "RUIN Fog Of War Equipped Weapon Filter", function(weapon, owner)
        timer.Simple(.1, function()
            if(!IsValid(owner)) then return end
            table.insert(_filter, weapon)
        end)
    end)

    -- Prevent entity popping in when it first spawns.
    -- For some reason needs a second of serverside nodraw otherwise client realm overrides? 
    hook.Add("OnEntityCreated", "RUIN Fog Of War Set Up Ents", function(ent)        
        if(ent:IsNPC()) then        
            ent:SetNoDraw(true)
            
            timer.Simple(1, function()
                if !IsValid(ent) then return end
                ent:SetNoDraw(false)
            end)
        end

        timer.Simple( .1, function()
            if !IsValid(ent) then return end

            if (ent:GetClass() == "ruin_npc_view_cull") then
                table.insert(_filter, ent)
            end
            
            if (ent:GetClass() == "ruin_force_shield") then
                table.insert(_filter, ent)
            end

            if ent:IsNPC() then 
                ent:SetRenderMode( RENDERMODE_TRANSALPHA )
            end
        end)

    end)

    local npcBlacklist = { 
        ["npc_grenade_frag"] = true,                         
    }

    hook.Add( "OnNPCKilled", "RUIN Fog Of War Set NPC Opaque On Death", function( npc )
        
        if !IsValid(npc) then return end 
        
        npc:SetNoDraw(false)
        
        local color = npc:GetColor()
        npc.FogOfWarAlpha = 255
        color.a = npc.FogOfWarAlpha
        npc:SetColor( color )

    end)

    local eyePos 
    hook.Add("Think", "RUIN Fog Of War", function() -- TODO: Try IsLineOfSightClear() to fix cases of bad detection?
        if nextThink > CurTime() then return end
        nextThink = CurTime() + .05
        if !IsValid(player) then return end
        if _filter[1] != player then -- Bandaid fix cause player isnt inserted into the table sometimes for some reason?
            table.insert(_filter, 1, player)
        end

        -- Makes fog of war rendering more accurate when player is dead.
        if(Entity(1):Health() > 0) then
            eyePos = Entity(1):EyePos()
        end

        for k, v in ipairs(ents.FindByClass( "npc_*")) do
            if v:GetRenderMode() != RENDERMODE_TRANSALPHA then -- Headcrabs make it so I have to do this inefficient bandaid fix.
                if !IsValid(v) then continue end
                v:SetRenderMode( RENDERMODE_TRANSALPHA )
            end

            -- Needed for metro cops since they draw their pistols post spawn, tried to do this many other ways but couldn't get it working.
            -- Need to exclude frags since they count as npc's and dont have a GetActiveWeapon() method on them.
            if (v:GetClass() != "npc_grenade_frag") and IsValid(v:GetActiveWeapon()) then
                v:GetActiveWeapon():SetNoDraw(true)
            end

            local hit = false
            // head to head
            tr1 = util.TraceLine( {
                start = eyePos,
                endpos = v:EyePos(), 
                filter = _filter
            } )
            if (tr1 and (tr1.Entity == v or tr1.Entity == NULL)) then hit = true end

            -- Fade npc and weapon in our out.
            -- If see enemy, but already faded in don't do anything to not network. (Same for fade out)
            if hit then 
                if v:GetClass() == "npc_grenade_frag" then continue end
                v:setIsVisibleToPlayer(true) -- For use by other systems without having to make additional traces. (borrow from this sytem)
                net.Start("RUIN FOW Fade Entity In")
                net.WriteEntity(v)
                net.Broadcast()
            else
                if v:GetClass() == "npc_grenade_frag" then continue end
                v:setIsVisibleToPlayer(false) -- For use by other systems without having to make additional traces. (borrow from this system)
                net.Start("RUIN FOW Fade Entity Out")
                net.WriteEntity(v)
                net.Broadcast()
            end 

            if DEBUG == false then continue end  
            debugoverlay.Line( eyePos, tr1.HitPos, .05, Color( 30, 255, 0), false )
            PrintTable(_filter)
        end
    end)

    local garbageCollectNextThink = CurTime() + 10

    hook.Add("Think", "RUIN Fog Of War Trace Filter Garbage Collect", function()
        if ( CurTime() < garbageCollectNextThink ) then return end
        garbageCollectNextThink = CurTime() + 10

        local dumpTable = {}

        for k, v in ipairs(_filter) do
            if IsValid(v) then 
                table.insert( dumpTable, v ) 
            end
        end

        _filter = dumpTable
    end)
end

if CLIENT then
    local function fadeIn( entity ) 
        if !IsValid(entity) then return end

        entity:SetNoDraw(false)
        
        if IsValid(entity.weaponSkin) then
            entity.weaponSkin:SetNoDraw(false)
        end

        entity:SetSubMaterial(1, "ruin/misc/black") -- Re-enables shell outline on police. 
        entity:SetSubMaterial(2, "ruin/misc/black") -- Re-enables shell outline on soldiers. 
        
        local children = entity:GetChildren()
        for k, v in pairs(children) do
            if v:IsWeapon() then continue end
            v:SetNoDraw(false)
        end
        
        timer.Create( "RUIN " .. tostring(entity) .. "sh_fog_of_war.FadeNpc", 0, 1, function ()
            if !IsValid(entity) then return end 
            local color = entity:GetColor()
            entity.FogOfWarAlpha = math.Clamp( (entity.FogOfWarAlpha or color.a) + 255, 0, 255 )
            color.a = entity.FogOfWarAlpha
            entity:SetColor(color)
            if IsValid(entity.weaponSkin) then 
                entity.weaponSkin:SetColor(color)
            end
        end )
    end

    local function fadeOut( entity )
        if !IsValid(entity) then return end
        
        if IsValid(entity.weaponSkin) then
            entity.weaponSkin:SetNoDraw(true)
        end

        entity:SetSubMaterial(1, "Models/effects/vol_light001") -- Disables shell outline on police. Looks weird when faded.
        entity:SetSubMaterial(2, "Models/effects/vol_light001") -- Disables shell outline on soldiers. Looks weird when faded.

        timer.Create( "RUIN " .. tostring(entity) .. "sh_fog_of_war.FadeNpc", 0, 32, function ()  
            if !IsValid(entity) then return end
            
            local color = entity:GetColor()
            
            entity.FogOfWarAlpha = math.Clamp( (entity.FogOfWarAlpha or color.a) - 8, 0, 255) 
            color.a = entity.FogOfWarAlpha
            entity:SetColor(color)

            if timer.RepsLeft( "RUIN " .. tostring(entity) .. "sh_fog_of_war.FadeNpc" ) == 1 then
                entity:SetNoDraw(true)
                if IsValid(entity.weaponSkin) then 
                    entity.weaponSkin:SetNoDraw(true)
                end
            end
        
        end )
    end

    net.Receive("RUIN FOW Fade Entity In", function()
        fadeIn(net.ReadEntity())
    end)

    net.Receive("RUIN FOW Fade Entity Out", function()
        fadeOut(net.ReadEntity())
    end)
end
