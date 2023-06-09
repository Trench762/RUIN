hook.Add("PlayerBindPress", "RUIN Disable Alt Fire", function(ply, bind, pressed, code)
    if(!IsValid(ply)) then return end
    
    if(bind == "+attack2" or bind == "+attack3") then -- No clue what +attack3 is but blocking it just in-case.
        return true 
    end
end)

