game.ConsoleCommand( "ai_serverragdolls 1\n" )

hook.Add("OnEntityCreated", "RUIN Disable Serverside Ragdolls", function(ent)
    if tonumber(RUIN.mapSettings["mode"]) != 1 then return end -- Arena.
    if ent:GetClass() != "prop_ragdoll" then return end 
    
    timer.Simple(5, function()
        if !IsValid(ent) then return end

        ent:SetSubMaterial(1, "Models/effects/vol_light001") -- Disables shell outline on police. Looks weird when faded.
        ent:SetSubMaterial(2, "Models/effects/vol_light001") -- Disables shell outline on soldiers. Looks weird when faded.

        timer.Create("RUIN " .. tostring(ent) .. "Fade Corpse", .02, 50, function()
            if !IsValid(ent) then return end
            
            local color = ent:GetColor()
            color.a = math.max(0, color.a - 5.1)
            ent:SetColor(color)
            
            if timer.RepsLeft( "RUIN " .. tostring(ent) .. "Fade Corpse" ) == 1 then
                ent:Remove()
            end
        end)
    end)

    if !ent:IsNPC() or !ent:IsPlayer() then return end
    ent:SetShouldServerRagdoll( true )
end)

hook.Add("OnNPCKilled", "RUIN Disable NPC Ragdoll Collisions", function(npc)
    timer.Simple(.1, function()
        for k, v in pairs(ents.FindByClass("prop_ragdoll")) do 
            v:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
        end
    end)
end)
