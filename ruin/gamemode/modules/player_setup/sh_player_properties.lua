local _weapons = {
    weapon_smg1 = "Smg",
    weapon_shotgun = "Shotgun",
    weapon_ar2 = "Assault Rifle",
}

-----------------------------------
----GENERAL PLAYER VARS------------
-----------------------------------
do
	function eMeta:setIsDashing(bool)
		self:SetNWBool('isDashing', bool )
	end
	
	function eMeta:isDashing()
		return self:GetNWBool('isDashing', false)
	end

	function eMeta:setIsCloaking(bool)
		self:SetNWBool('isCloaking', bool )
	end
	
	function eMeta:isCloaking()
		return self:GetNWBool('isCloaking', false)
	end

	function eMeta:setDebuggingMenuCamera(bool)
		self:SetNWBool('debuggingMenuCamera', bool )
	end
	
	function eMeta:getDebuggingMenuCamera()
		return self:GetNWBool('debuggingMenuCamera', false)
	end
	
	function eMeta:setPrimaryMag(number)
		self:SetNWInt('primaryMag', number )
	end

	function eMeta:getPrimaryMag()
		return self:GetNWInt('primaryMag', 0)
	end

	function eMeta:setHasPrimary(bool)
		self:SetNWBool('hasPrimary', bool )
	end

	function eMeta:hasPrimary()
		return self:GetNWBool('hasPrimary', false)
	end

	function eMeta:setHasPrimaryEquipped(bool)
		self:SetNWBool('hasPrimaryEquipped', bool )
	end

	function eMeta:hasPrimaryEquipped()
		return self:GetNWBool('hasPrimaryEquipped', false)
	end

	function eMeta:setActiveWeaponClass(class)
		self:SetNWString('activeWeaponClass', class )
	end

	function eMeta:activeWeaponClass()
		return self:GetNWString('activeWeaponClass', "none")
	end

	function eMeta:setJustSpawned(bool)
		self:SetNWBool('justSpawned', bool )
	end

	function eMeta:justSpawned()
		return self:GetNWBool('justSpawned', false)
	end

	function eMeta:setIsUsingTurret(bool)
		self:SetNWBool('usingTurret', bool )
	end

	function eMeta:isUsingTurret()
		return self:GetNWBool('usingTurret', false)
	end

	function eMeta:setWorldIsCold(bool)
		self:SetNWBool('worldIsCold', bool )
	end

	function eMeta:getWorldIsCold()
		return self:GetNWBool('worldIsCold', false)
	end

	function pMeta:getPrimaryWeapon()
		local weapon 
		for k, v in pairs( _weapons ) do
			weapon = self:GetWeapon( k )
			if IsValid(weapon) then return weapon, v end
		end
	end
end

hook.Add("PlayerLoadout", "RUIN Loadout", function(ply)
	ply:setHasPrimary(false)
	ply:setHasPrimaryEquipped(false)
	ply:setActiveWeaponClass("none")
	ply:setDebuggingMenuCamera(false)
	ply:setPrimaryMag(0)
	ply:AddEFlags( EFL_NO_DAMAGE_FORCES ) -- Makes it so player isn't pushed back by damage.
	
	ply:SetSlowWalkSpeed(128)
	ply:SetWalkSpeed(128)
	ply:SetRunSpeed(128)
	ply:SetMaxHealth(100)
	ply:SetHealth(100)

	ply:Give("weapon_pistol")
	ply:SetAmmo( 000, "ar2" )
	ply:SetAmmo( 000, "357")
	ply:SetAmmo( 000, "buckshot")
	ply:SetAmmo( 10000, "pistol")
	ply:SetAmmo( 000, "smg1")
	ply:SetAmmo( 000, "grenade")
	ply:SetAmmo( 000, "xbowbolt")
	ply:SetAmmo( 000, "ar2altfire")
	ply:SetAmmo( 000, "smg1altfire")

    return true
end)

hook.Add("PlayerSpawn", "RUIN Player Properties On Spawn", function(ply)
	ply:setJustSpawned(true)
	timer.Simple(.1, function()
		ply:setJustSpawned(false)
	end)
end )

hook.Add("PlayerSetModel", "RUIN Set Player Model", function(ply)
	ply:SetModel("models/ruin/humans/ruin_player_01.mdl")
end)
