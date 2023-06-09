-- Sound overrides for combine voices are being done manually 
-- Hopefully they add a hook to intercept those vo lines but for now this is the only way.

-- hook.Add("EntityEmitSound", "RUIN NPC Sound Override", function(data)
--     if !data.Entity:IsNPC() then return end
--     return false -- Return false to block sound.
-- end)