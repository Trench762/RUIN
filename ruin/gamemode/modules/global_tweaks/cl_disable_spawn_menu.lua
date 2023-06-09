hook.Add( "SpawnMenuOpen", "RUIN Disable Spawn Menu", function()
	return false
end )

-- return true to allow.
-- return false to dis-allow.
-- Redundant to use false since derived gamemode when shipped will be base which has no spawn menu, keeping anyways because it's an overt indication of intent.