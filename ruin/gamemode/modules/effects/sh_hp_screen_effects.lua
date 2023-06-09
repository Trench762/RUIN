if CLIENT then
	local scrH = ScrH()

	local colorLookup = {
		[ "$pp_colour_addr" ] = 0,
		[ "$pp_colour_addg" ] = 0,
		[ "$pp_colour_addb" ] = 0,
		[ "$pp_colour_brightness" ] = 0,
		[ "$pp_colour_contrast" ] = 1,
		[ "$pp_colour_colour" ] = 1, -- This controls saturation.
		[ "$pp_colour_mulr" ] = 0,
		[ "$pp_colour_mulg" ] = 0,
		[ "$pp_colour_mulb" ] = 0
	}

	-- HEALTH REGEN DONE IN SEPERATE MODULE: health_regeneration/sv_health_regen
	hook.Add( "RenderScreenspaceEffects", "RUIN HP Related Effects", function() --Desaturation, Toytown blur, and motion blur
		local ply = LocalPlayer()
		local hp = ply:Health()
		if hp == ply:GetMaxHealth() then return end

		if (hp <= 0) then
			colorLookup["$pp_colour_colour"] = 0 
			DrawColorModify( colorLookup ) 
			DrawToyTown( 2, scrH )
		elseif (hp > 0) then
			colorLookup["$pp_colour_colour"] = math.max(0, 1 - (1 - hp/ply:GetMaxHealth())) 
			DrawColorModify( colorLookup )  
			local blurMult = math.Remap(ply:Health(), 0, ply:GetMaxHealth(), 1, 0)
			DrawToyTown( 2, (scrH * .5 ) * blurMult)
		end
	end )
end
