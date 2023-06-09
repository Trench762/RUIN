if SERVER then
    util.AddNetworkString("RUIN Network To Player Extraction Completed")
    util.AddNetworkString("RUIN Network To Player Extraction Variable Reset")

    hook.Add("PlayerSpawn", "RUIN Reset Extraction Variable", function(ply)
        net.Start("RUIN Network To Player Extraction Variable Reset")
        net.Send(ply)
        RUIN.extracted = false
    end)
end

if CLIENT then
    surface.CreateFont( "ExtractionFont", { font = "Kenney Future Square", size = ScreenScale(21), weight = 0 } )
    surface.CreateFont( "ExtractionFont2", { font = "Kenney Future Square", size = ScreenScale(11), weight = 0 } )
    local p = LocalPlayer()
    local ply = LocalPlayer()
    local w, h = ScrW(), ScrH()
    local extractionMessage = "Extraction Completed"
    local lettersToShow = 0
    local showContinueMessage = false
    local continueMessageAlpha = 0
    local nextLetterIncrement = CurTime()
    local delayText = true
    local colorBlack = Color(0,0,0)
    local colorWhite = Color(255,255,255)
    RUIN.extracted = false

    hook.Add( "OnScreenSizeChanged", "RUIN Extraction UI Rebuild Screen Sizes", function( oldWidth, oldHeight )
        w, h = ScrW(), ScrH()
        surface.CreateFont( "ExtractionFont", { font = "Kenney Future Square", size = ScreenScale(21), weight = 0 } )
        surface.CreateFont( "ExtractionFont2", { font = "Kenney Future Square", size = ScreenScale(11), weight = 0 } )
    end )

    local colorLookup = {
        [ "$pp_colour_addr" ] = 0,
        [ "$pp_colour_addg" ] = 0,
        [ "$pp_colour_addb" ] = 0,
        [ "$pp_colour_brightness" ] = 0,
        [ "$pp_colour_contrast" ] = 1,
        [ "$pp_colour_colour" ] = 0, --This controls saturation
        [ "$pp_colour_mulr" ] = 0,
        [ "$pp_colour_mulg" ] = 0,
        [ "$pp_colour_mulb" ] = 0
    }
    
    net.Receive("RUIN Network To Player Extraction Completed", function()
        RUIN.extracted = true
        lettersToShow = 0
        showContinueMessage = false
        delayText = true
        RUIN.queueMainMenu = true

        timer.Create("RUIN extraction HUD Increment Black Screen Alpha", 1, 1, function()
            delayText = false
        end)

        timer.Simple(4, function()
            showContinueMessage = true
            timer.Create("RUIN extraction HUD continue message alpha increment", .05, 20, function()
                continueMessageAlpha = math.min(continueMessageAlpha + 13, 255)
            end)
        end)
    end)
    
    net.Receive("RUIN Network To Player Extraction Variable Reset", function()
        RUIN.extracted = false
        
        -- Show main menu again if they had just extracted.
        if (RUIN.queueMainMenu) then
            ply.inMainMenu = true
            RUIN.createMainMenu()
            RUIN.queueMissionText = true
        end
        RUIN.queueMainMenu = false
    end)
    
    hook.Add("HUDPaint", "RUIN Extraction HUD", function()
        if ply.escMenuOpen then return end
        if !RUIN.extracted then return end
        if RUIN.extracted == false then return end
        
        if delayText then return end

        if nextLetterIncrement < CurTime() and lettersToShow <= string.len( extractionMessage ) then
            lettersToShow = lettersToShow + 1
            nextLetterIncrement = CurTime() + .1
            surface.PlaySound("ruin/effects/ui/type_writer.ogg")
        end

        draw.SimpleTextOutlined(string.sub(extractionMessage, 1, lettersToShow), "ExtractionFont", w/2, h/2, colorWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, h *.001, colorBlack)
        if !showContinueMessage then return end
        draw.SimpleText("Press Any Key To Continue", "ExtractionFont2", w/2, h * .91, Color(36,36,36, continueMessageAlpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)  

    hook.Add( "RenderScreenspaceEffects", "RUIN Extraction Menu Effect", function() -- Desaturation, Toytown blur, and motion blur.
        if RUIN.extracted then 
            DrawColorModify( colorLookup )
            DrawToyTown( 2, h  )
        end
    end )

    hook.Add("AdjustMouseSensitivity", "RUIN Extraction HUD Prevent Mouse Movement", function()
        if !RUIN.extracted then return end
		return 0.000000001
	end)
end

