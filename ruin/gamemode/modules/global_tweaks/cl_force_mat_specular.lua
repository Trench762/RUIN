if CLIENT then
    timer.Simple(.1, function()
        LocalPlayer():ConCommand( "mat_specular 1" )
    end)
end