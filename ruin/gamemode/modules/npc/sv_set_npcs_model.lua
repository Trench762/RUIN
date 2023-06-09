local npcModelTranslations = {
    ["npc_metropolice"] = "models/ruin/humans/police_01.mdl",
    ["npc_combine_s"] = "models/ruin/humans/soldier_01.mdl",
}
hook.Add("OnEntityCreated", "RUIN NPC Set Custom Model On Spawn", function(ent)
    if !ent:IsNPC() then return end
    
    timer.Simple(.1, function() -- Seems like changing the model too fast interrupts their schedules sometimes.
        if !IsValid(ent) then return end
        
        if npcModelTranslations[ent:GetClass()] then
            ent:SetModel(npcModelTranslations[ent:GetClass()])
            
            if ent:GetSequence() == ACT_RAPPEL_LOOP then return end
            ent:SetPos(ent:GetPos() + Vector(0,0,16)) -- Changing their model causes them to get stuck in the floor.
        end
    end)
end)