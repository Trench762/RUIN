local color = Color(255, 255, 255, 50)
local version = "1.0.26"
local ply = LocalPlayer()

surface.CreateFont("RUIN Gamemode Version Font" , { font = "Kenney Future Square", size = ScreenScale(8), weight = 0, blursize = 0; scanlines = 0, shadow = false, additive = false, })

hook.Add( "OnScreenSizeChanged", "RUIN Gamemode Version Rebuild Font", function( oldWidth, oldHeight )
    surface.CreateFont("RUIN Gamemode Version Font" , { font = "Kenney Future Square", size = ScreenScale(8), weight = 0, blursize = 0; scanlines = 0, shadow = false, additive = false, })
end )

local scrW, scrH = ScrW(), ScrH()
hook.Add( "HUDPaint", "Ruin Display Gamemode Version", function()
    if !IsValid(LocalPlayer()) then ply = LocalPlayer() end
    if !ply.escMenuOpen then return end
    draw.SimpleText( "RUIN Version " .. version, "RUIN Gamemode Version Font", scrW * .01, scrH * .01, color )
end )

