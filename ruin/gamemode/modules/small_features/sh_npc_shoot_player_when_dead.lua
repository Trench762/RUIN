if SERVER then
	hook.Add("PlayerDeath", "RUIN NPC Shoot Player When Dead", function(ply, inflictor, attacker)
        if !attacker:IsNPC() then return end
		
		local target = ents.Create("npc_bullseye")

		-- Spawn the target hopefully when the player's ragdoll stops moving.
		timer.Simple(.25, function() 
			if !IsValid(target) or !IsValid(ply) then return end
			target:SetHealth(10000)
			ply:GetRagdollEntity():RagdollUpdatePhysics()
			target:SetPos(ply:GetRagdollEntity():GetPos())
			target:Spawn()
		end)

		-- Remove the target after a while.
		timer.Simple(2, function()
			if !IsValid(target) then return end
			target:Remove()
		end)
		
        if !IsValid(attacker) or !attacker:IsNPC() then return end
		
		-- Get all metro cops to shoot the body.
		for k, v in pairs(ents.FindByClass("npc_metro*")) do 
			v:AddRelationship( "npc_bullseye D_HT 99")
			v:SetTarget(target)
			v:SetEnemy(target)
		end
		
		-- Get all combine to shoot the body.
		for k, v in pairs(ents.FindByClass("npc_combine*")) do 
			v:AddRelationship( "npc_bullseye D_HT 99")
			v:SetTarget(target)
			v:SetEnemy(target)
		end
    end)
end
