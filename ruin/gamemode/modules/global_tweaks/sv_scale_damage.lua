hook.Add( "EntityTakeDamage", "RUIN Scale Damage", function( target, dmginfo )
	if !IsValid(dmginfo:GetAttacker()) then return end
	
	if (target:IsPlayer() and IsValid(target)) then
		dmginfo:ScaleDamage(12.5) 
	elseif(target:IsNPC() and IsValid(target)) then
		dmginfo:ScaleDamage(6)
	end
end )
