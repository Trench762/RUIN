if CLIENT then
	local muzzleFlashColor = Color(41, 13, 0, 255)
	local muzzleFlashAngle = Angle(90,0,0)
	local muzzleFlashOffset = Vector(0,0,64)

	net.Receive("RUIN Draw Enhanced Muzzle Flash", function()
		if LocalPlayer().options.enableLamps == false then return end 
		
		local flashPos = net.ReadVector()
		local isUsingAggressorQ = net.ReadBool() 
		local flash = ProjectedTexture()

		flash:SetTexture( "effects/flashlight/soft" )
		flash:SetColor( isUsingAggressorQ and color_white or muzzleFlashColor)
		flash:SetFarZ( 400 )
		flash:SetNearZ ( 60 )
		flash:SetFOV( math.random(100,135) )
		flash:SetBrightness( isUsingAggressorQ and 3 or math.random(15,20) )
		flash:SetEnableShadows ( true )

		flash:SetPos( flashPos + muzzleFlashOffset )
		flash:SetAngles( muzzleFlashAngle )
		flash:Update()
		timer.Simple( 0.025, function() flash:Remove() end)
	end)
end


if SERVER then 
	util.AddNetworkString( "RUIN Draw Enhanced Muzzle Flash" )

	hook.Add("EntityFireBullets","RUIN Enhanced Muzzle Flash", function(ent, data)
		local firePos = data.Src
		local p = IsValid(ent) and ent.IsPlayer and ent:IsPlayer() and ent
		net.Start("RUIN Draw Enhanced Muzzle Flash")
			net.WriteVector( firePos )
			net.WriteBool( IsValid(p) and p:isUsingAggressorQ() ) 
		net.Broadcast()
	end)
end