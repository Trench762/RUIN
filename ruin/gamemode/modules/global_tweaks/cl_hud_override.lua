local hide = {
	["CHudChat"] = true,
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudWeaponSelection"] = true,
	["CHudCrosshair"] = true,
	["CHUDQuickInfo"] = true, -- Health and ammo near crosshair.
	["CHudCloseCaption"] = true,
	["CHudDamageIndicator"] = true,
}

hook.Add( "HUDShouldDraw", "RUIN HUD Override", function( name )
	if ( hide[ name ] ) then
		return false
	end

	-- Don't return anything here, it may break other addons that rely on this hook.
end )


hook.Add("DrawDeathNotice", "RUIN Disable Kill Feed", function()
		return 0,0
end)

-- CHANGE THIS IF U GET A CUSTOM HUD FOR THIS BEHAVIOR
hook.Add( "HUDWeaponPickedUp", "RUIN Weapon Picked Up HUD", function( itemName )
    return false
end )

hook.Add( "HUDItemPickedUp", "RUIN Item Picked Up HUD", function( itemName )
    return false
end )

hook.Add( "HUDAmmoPickedUp", "RUIN Ammo Picked Up HUD", function(itemName, number)
	return false
end )
