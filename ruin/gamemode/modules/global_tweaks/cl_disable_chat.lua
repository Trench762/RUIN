hook.Add("PlayerBindPress", "RUIN Disable Chat Use", function(ply, bind)
    if(!IsValid(ply)) then return end
    if (bind == "messagemode" or bind == "messagemode2") then 
        return true
    end
end)

hook.Add( "ChatText", "RUIN Block Chat", function( index, name, text, type )
    return true
end )

