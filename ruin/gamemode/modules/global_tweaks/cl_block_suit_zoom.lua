hook.Add("PlayerBindPress", "RUIN Block Suit Zoom", function(ply, bind, pressed, code)
    if(!IsValid(ply)) then return end

    if (bind == "+zoom") then 
        return true
    end
end)

