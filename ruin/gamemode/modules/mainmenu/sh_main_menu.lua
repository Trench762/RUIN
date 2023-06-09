if CLIENT then
    local ply = LocalPlayer()
    
    ply.inMainMenu = true 
    RUIN.mainMenuVGUI = RUIN.mainMenuVGUI or nil
    
    local mainMenuTextColor = Color( 215, 215, 215)
    local mainMenuTextColorHovered = Color( 255, 252, 98)
    local mainMenuTextOutlineColor = Color( 0, 0, 0, 100)
    local mainMenuTextOutlineColorHovered = Color( 255, 252, 98, 5)
    local letterboxColor = Color(0,0,0)
    local w, h = ScrW(), ScrH()

    surface.CreateFont("Main_Menu" , { font = "Kenney Future Square", size = ScreenScale(15), weight = 0, blursize = 0; scanlines = 0, shadow = false, additive = false, })

    hook.Add( "OnScreenSizeChanged", "RUIN Main Menu UI Rebuild Screen Sizes", function( oldWidth, oldHeight )
        w, h = ScrW(), ScrH()
        surface.CreateFont("Main_Menu" , { font = "Kenney Future Square", size = ScreenScale(15), weight = 0, blursize = 0; scanlines = 0, shadow = false, additive = false, })
    end )

    -- Support lua refresh by storing it in a global var when created, then checking it here and removing it. Globals arent cleared on refresh which is why we can do this.
    if mainMenuVGUI then mainMenuVGUI:Remove() end
    
    RUIN.createMainMenu = function()
        RUIN.playSong(ply.inMainMenu)

        local mainMenu = vgui.Create( "DFrame" )
        mainMenuVGUI = mainMenu 
        RUIN.mainMenuVGUI = mainMenu
        mainMenu:SetPos( 0, 0 ) 
        mainMenu:SetSize( w, h ) -- Height doesnt matter.
        mainMenu:SetTitle( "" ) 
        mainMenu:SetDraggable( false ) 
        mainMenu:ShowCloseButton( false ) 
        mainMenu:MakePopup()
    
        function mainMenu:Paint(w, h) 
            draw.RoundedBox(0,0,0,w,h*.085,letterboxColor)
            draw.RoundedBox(0,0,h*.915,w,h*.09,letterboxColor)
        end
    
        local playGameButton = vgui.Create("DButton", mainMenu)
        playGameButton:SetText("")
        playGameButton:SetPos(0, 0)
        playGameButton:SetTall(h*.05)
        playGameButton:Dock(BOTTOM)
        playGameButton:DockMargin(w * .42, 0, w * .42, h * .01)
            
        function playGameButton:Paint(w, h)
            if self:IsHovered() then
                draw.SimpleText("Start Game", "Main_Menu", w*.5, 0, mainMenuTextColorHovered, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            else
                draw.SimpleText("Start Game", "Main_Menu", w*.5, 0, mainMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end
        end
    
        function playGameButton:OnCursorEntered()
            EmitSound( "buttons/lightswitch2.wav", Vector(0,0,0), -2, CHAN_AUTO, 1, 75, 0, 200, 0 )
        end
    
        function playGameButton:DoClick()
            EmitSound( "buttons/button9.wav", Vector(0,0,0), -2, CHAN_AUTO, 1, 75, 0, 250, 0 )
            mainMenu:Remove() 
            RunConsoleCommand( "RuinAbilitySelector" )
            ply.numTimesLoadoutSelected = 0
        end
    end

    RUIN.createMainMenu()

    hook.Add("PreRender", "RUIN Main Menu Hide When Needed", function()
        if !RUIN.mainMenuVGUI then return end
        if !IsValid(RUIN.mainMenuVGUI) then return end

        if ply.escMenuOpen or gui.IsGameUIVisible() then 
            RUIN.mainMenuVGUI:Hide()
        else 
            RUIN.mainMenuVGUI:Show()
        end
    end)
end