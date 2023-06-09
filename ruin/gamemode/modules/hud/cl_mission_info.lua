local ply = LocalPlayer()
local missionInfo
local displayMissionInfoHUD
local messageAlpha = 255
local lettersToShow = 0
local nextLetterIncrement = CurTime()
local w, h = ScrW(), ScrH()
local messageColor = Color(255,255,255,255)
local distort = false
local flicker = false
RUIN.queueMissionText = true

surface.CreateFont( "Mission Info Font", { font = "Kenney Future Square", size = ScreenScale(11), weight = 0 } )

hook.Add( "OnScreenSizeChanged", "RUIN Mission Info UI Rebuild Screen Sizes", function( oldWidth, oldHeight )
    w, h = ScrW(), ScrH()
    surface.CreateFont( "Mission Info Font", { font = "Kenney Future Square", size = ScreenScale(11), weight = 0 } )
end )

RUIN.displayMissionInfo = function()
    if !RUIN.queueMissionText then return end
    RUIN.queueMissionText = false
    
    displayMissionInfoHUD = true
    messageAlpha = 255
    messageColor.a = 255

    -- Type inconsistencies force me to cast to a number.
    if tonumber(RUIN.mapSettings["mode"]) == 0 then -- Extraction 
        missionInfo = "Extraction: Get to exfil"
    else                                            -- Arena
        missionInfo = "Arena: Kill them all"
    end

    lettersToShow = 0

    timer.Simple(5.5, function()
        surface.PlaySound("ruin/effects/ui/glitch_01.ogg")
    end)

    timer.Simple(5.8, function()
        distort = true
        flicker = true
    end)

    timer.Simple(6, function()
        flicker = false
        distort = false
        messageColor.a = math.max(0, messageColor.a - 255)
        displayMissionInfoHUD = false
    end)
end

hook.Add("HUDPaint", "RUIN Mission Info HUD", function()  
    if !displayMissionInfoHUD then return end
    if ply.escMenuOpen then return end
    if !ply:Alive() then return end
    
    if flicker then
        messageColor.a = 255 + math.random(-255,0)
    end

    if nextLetterIncrement < CurTime() and lettersToShow <= string.len( missionInfo ) then
        lettersToShow = lettersToShow + 1
        nextLetterIncrement = CurTime() + .1
        surface.PlaySound("ruin/effects/ui/type_writer.ogg")
    end

    draw.SimpleText(string.sub(missionInfo, 1, lettersToShow), "Mission Info Font", distort and w * .01 + math.random(-w * 0.003,w * 0.003) or w * .01,  distort and h * 0.5 + math.random(-h * 0.001,h * 0.001) or h * 0.5, messageColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
end)