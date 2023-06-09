hook.Add( "PlayerFootstep", "RUIN Custom Foot Step", function( ply, pos, foot, sound, volume, rf )
	ply:EmitSound(sound, 75, 100, volume * .2, CHAN_AUTO)
    return true
end )