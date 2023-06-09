if CLIENT then
	local recoilLookup = {
		["weapon_357"] = 10,
		["weapon_pistol"] = 14,
		["weapon_ar2"] = 20,
		["weapon_shotgun"] = 50,
		["weapon_smg1"] = 15
	}

	net.Receive("RUIN Bullet Fire Screen Shake", function()
		if( LocalPlayer():Health() <= 0 ) then return end
		local weapon = LocalPlayer():GetActiveWeapon()
		
		util.ScreenShake( LocalPlayer():GetPos(), 1 * recoilLookup[weapon:GetClass()], 10, .05, 10000 ) -- Fefault 3rd arg == 5 (Frequency in hertz)
	end)
end

if SERVER then 
	util.AddNetworkString( "RUIN Bullet Fire Screen Shake" )

	hook.Add("EntityFireBullets", "RUIN Bullet Fire Screen Shake", function(ent, data)
		if(!IsValid(ent) or !ent:IsPlayer()) then return end
		net.Start("RUIN Bullet Fire Screen Shake")
		net.Send(ent)
	end)
end


