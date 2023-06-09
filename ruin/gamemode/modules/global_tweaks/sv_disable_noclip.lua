hook.Add( "PlayerNoClip", "RUIN Disable Noclip", function(ply, desiredState)
    if (ply:getDebuggingMenuCamera()) then
        return true 
    else
        return false 
    end
end)