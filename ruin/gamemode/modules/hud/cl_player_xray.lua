local ply = LocalPlayer()
if IsValid(ply) then
end


hook.Add( "PostDrawOpaqueRenderables", "RUIN Player X-Ray", function()
	if !IsValid(ply) then
		ply = LocalPlayer()
	end
	
	if(!IsValid(ply) or !ply:Alive() or ply:Health() <= 0) then return end
	if ply.escMenuOpen then return end
	if ply.inMainMenu then return end
	if ply:getDebuggingMenuCamera() then return end

	--RESET THE BUFFER-------
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilFailOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()
	-------------------------

	render.SetStencilEnable( true )
	render.SetStencilReferenceValue( 1 )
	render.SetStencilCompareFunction( STENCIL_NEVER )
	render.SetStencilFailOperation( STENCIL_REPLACE )
	
	ply:DrawModel()
	if(IsValid(ply.renderWeapon)) then
		ply.renderWeapon:DrawModel()
	end
	if(IsValid(ply.weaponSkin)) then
		ply.weaponSkin:DrawModel()
	end
	
	render.SetStencilCompareFunction( STENCIL_EQUAL )
	render.SetStencilFailOperation( STENCIL_KEEP )
	render.ClearBuffersObeyStencil( 20, 20, 20, 255, false )
	
	ply:DrawModel()
	if(IsValid(ply.renderWeapon)) then
		ply.renderWeapon:DrawModel()
	end
	if(IsValid(ply.weaponSkin)) then
		ply.weaponSkin:DrawModel()
	end
	
	render.SetStencilEnable( false )
	
end )
