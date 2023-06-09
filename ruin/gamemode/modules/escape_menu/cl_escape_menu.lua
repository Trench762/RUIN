-- This code wasn't abstracted. As such there is a lot of reptitive code which makes this hard to read and work with.
util.PrecacheSound("buttons/lightswitch2.wav")
util.PrecacheSound("buttons/button9.wav")
local ply = LocalPlayer()
local w, h = ScrW(), ScrH()
local escMenuTextColor = Color( 215, 215, 215)
local escMenuTextColorHovered = Color( 255, 252, 98)
local escMenuTextOutlineColor = Color( 0, 0, 0, 100)
local escMenuTextOutlineColorHovered = Color( 255, 252, 98, 5)
local escMenuTextColorHovered2 = Color( 255, 252, 68, 210)
local escapeMenuColor1 = Color(0,225,255, 4)
local escapeMenuColor2 = Color( 164, 164, 164, 50)
local escapeMenuColor3 = Color( 164, 164, 164, 175)
local escapeMenuColor4 = Color( 164, 164, 164, 25)
local escapeMenuMat1 = Material("ruin/misc/escape_menu_texture_01")
RUIN.EscapeMenuVGUI = RUIN.EscapeMenuVGUI or nil
RUIN.EscapeOptionsSubMenuVGUI = RUIN.EscapeOptionsSubMenuVGUI or nil
RUIN.keyReferenceSubMenuVGUI = RUIN.keyReferenceSubMenuVGUI or nil
RUIN.mapSelectionSubMenu = RUIN.mapSelectionSubMenu or nil
ply.escMenuOpen = false

surface.CreateFont("Esc_Menu" , { font = "Kenney Future Square", size = ScreenScale( 15 ), weight = 0, blursize = 0; scanlines = 0, shadow = false, additive = false, })
surface.CreateFont("Esc_Menu_Small" , { font = "Kenney Future Square", size = ScreenScale( 8 ), weight = 0, blursize = 0; scanlines = 0, shadow = false, additive = false, })


hook.Add( "OnScreenSizeChanged", "RUIN Escape Menu UI Rebuild Screen Sizes", function( oldWidth, oldHeight )
	w, h = ScrW(), ScrH()
    surface.CreateFont("Esc_Menu" , { font = "Kenney Future Square", size = ScreenScale( 15 ), weight = 0, blursize = 0; scanlines = 0, shadow = false, additive = false, })
    surface.CreateFont("Esc_Menu_Small" , { font = "Kenney Future Square", size = ScreenScale( 8 ), weight = 0, blursize = 0; scanlines = 0, shadow = false, additive = false, })
    if RUIN.EscapeMenuVGUI and RUIN.EscapeMenuVGUI:IsValid() then
        ply:ConCommand( "RUIN_escapeMenuToggle" )
        ply:ConCommand( "RUIN_escapeMenuToggle" )
    end
end )

--------------------------------
---OPTIONS INIT-----------------
--------------------------------
ply.options = {
    musicVolume = 0.5,
    enableDLights = false,
    enableLamps = true,
    enableSnowParticles = true,
    enableThreatHighlighter = true,
    laserColor = {r = 127, g = 255, b = 0},
    enableHud = true,
}

if file.Exists( "ruin/player_settings.txt", "DATA" ) then 
    ply.options = util.JSONToTable( file.Read( "ruin/player_settings.txt", "DATA" ) )
    print("--------------------------")
    print("Player Settings File Found") 
    print("--------------------------")
    PrintTable(ply.options) 
    print("-------------------------- \n")
else -- File was never made: Create it and store default values (Defined above in ply.options)
    print("--------------------------")
    print("Player Settings Not Found, Creating Directory...") 
    print("-------------------------- \n")
    file.CreateDir( "ruin" )
    file.Write( "ruin/player_settings.txt", util.TableToJSON( ply.options, true ) ) 
    ply.options = util.JSONToTable( file.Read( "ruin/player_settings.txt", "DATA" ) )
end

--------------------------------
--------------------------------
--------------------------------

local function playEscMenuButtonEnteredSound()
    EmitSound( "buttons/lightswitch2.wav", Vector(0,0,0), -2, CHAN_AUTO, 1, 75, 0, 200, 0 )
end

local function playEscMenuButtonPressedSound()
    EmitSound( "buttons/button9.wav", Vector(0,0,0), -2, CHAN_AUTO, 1, 75, 0, 250, 0 )
end

local keyManagerHUD = NULL
local optionsHUD = NULL
local mapSelectionHUD = NULL

hook.Add("PreRender", "RUIN Escape Menu Manager Think", function()
    optionsHUD = ply.optionsHUD
    if optionsHUD and IsValid(optionsHUD) then 
        if gui.IsGameUIVisible() then
            optionsHUD:Hide()
            for _, element in pairs(optionsHUD:GetChildren()) do
                element:Hide() 
            end
        else
            optionsHUD:Show()
            for _, element in pairs(optionsHUD:GetChildren()) do
                element:Show()
            end
        end
    end
    
    keyManagerHUD = ply.keyManagerHUD
    if keyManagerHUD and IsValid(keyManagerHUD) then 
        if gui.IsGameUIVisible() then 
            keyManagerHUD:Hide()
            for _, element in pairs(keyManagerHUD:GetChildren()) do
                element:Hide()
            end
        else
            keyManagerHUD:Show()
            for _, element in pairs(keyManagerHUD:GetChildren()) do
                element:Show()
            end
        end
    end

    mapSelectionHUD = ply.mapSelectionHUD
    if mapSelectionHUD and IsValid(mapSelectionHUD) then 
        if gui.IsGameUIVisible() then 
            mapSelectionHUD:Hide()
            for _, element in pairs(mapSelectionHUD:GetChildren()) do
                element:Hide()
            end
        else
            mapSelectionHUD:Show()
            for _, element in pairs(mapSelectionHUD:GetChildren()) do
                element:Show()
            end
        end
    end

    if RUIN.EscapeMenuVGUI and RUIN.EscapeMenuVGUI:IsValid() then
        if !keyManagerHUD then return end
        if !optionsHUD then return end
        if !mapSelectionHUD then return end
        
        if keyManagerHUD != NULL and keyManagerHUD:IsVisible() then return end
        if optionsHUD != NULL and optionsHUD:IsVisible() then return end
        if mapSelectionHUD != NULL and mapSelectionHUD:IsVisible() then return end

        if gui.IsGameUIVisible() then 
            RUIN.EscapeMenuVGUI:Hide() 
        else
            RUIN.EscapeMenuVGUI:Show()
        end
    end
end)

------------------------------------------------
----OPTIONS SUB MENU----------------------------
------------------------------------------------

local function createOptionsSubMenu()
    ----------------------------------------------------------------------------
    ---Main Sub Menu Panel------------------------------------------------------
    ----------------------------------------------------------------------------
    -- Support lua refresh by storing it in a global var when created, then checking it here and removing it. Globals arent cleared on refresh which is why we can do this.
    if optionsSubMenuVGUI then optionsSubMenuVGUI:Remove() end

    local optionsSubMenu = vgui.Create( "DFrame" )
    RUIN.EscapeOptionsSubMenuVGUI = optionsSubMenu 
    ply.optionsHUD = optionsSubMenu
    optionsSubMenuVGUI = optionsSubMenu
    optionsSubMenu:SetPos( 0, 0 ) 
    optionsSubMenu:SetSize( w, h ) --Height doesnt matter
    optionsSubMenu:SetTitle( "" ) 
    optionsSubMenu:SetDraggable( false ) 
    optionsSubMenu:ShowCloseButton( false ) 
    timer.Simple(0, function()
        if !optionsSubMenu then return end
        if !IsValid(optionsSubMenu) then return end
        optionsSubMenu:MakePopup()
    end)

    function optionsSubMenu:Paint(w, h)
        surface.SetDrawColor( 0, 0, 0)                                    -- Set the drawing color.
        surface.SetMaterial( escapeMenuMat1 )                               -- Use our cached material.
        surface.DrawTexturedRect(0, 0, w, h )                               -- Actually draw the rectangle.
        draw.RoundedBox(0, w * .3625, 0, w * .275, h, escapeMenuColor1)
        draw.RoundedBox(0, w * .362, 0, w * .0025, h, escapeMenuColor2)
        draw.RoundedBox(0, w * .6355, 0, w * .0025, h, escapeMenuColor2)
    end

    function optionsSubMenu:Think()
        self:ShowCloseButton(false)
    end

    ----------------------------------------------------------------------------
    ---Center Panel Container---------------------------------------------------
    ----------------------------------------------------------------------------
    local optionsSubMenuCenterPanel = vgui.Create( "DPanel", optionsSubMenu ) 
    optionsSubMenuCenterPanel:Dock(FILL)
    optionsSubMenuCenterPanel:DockMargin(w*.3615,0,w*.3615,0)
    
    function optionsSubMenuCenterPanel:Paint() end

    ----------------------------------------------------------------------------
    ---Options Sub Menu Top Text -----------------------------------------------
    ----------------------------------------------------------------------------
    local optionsSubMenuTopTextPanel = vgui.Create( "DPanel", optionsSubMenuCenterPanel )
    optionsSubMenuTopTextPanel:SetTall(h *.05)
    optionsSubMenuTopTextPanel:Dock(TOP)
    optionsSubMenuTopTextPanel:DockMargin(0,w*.01,0,0)

    function optionsSubMenuTopTextPanel:Paint(w, h)
        draw.SimpleTextOutlined("Ruin Settings", "Esc_Menu", w *.5, h*.5, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
    end

    ----------------------------------------------------------------------------
    ---Horizontal Rule 1--------------------------------------------------------
    ----------------------------------------------------------------------------
    local optionsSubMenuHorizontalRule1 = vgui.Create( "DPanel", optionsSubMenuCenterPanel )
    optionsSubMenuHorizontalRule1:SetTall(1) 
    optionsSubMenuHorizontalRule1:Dock(TOP)
    optionsSubMenuHorizontalRule1:DockMargin(0,w*.01,0,w*.01)


    function optionsSubMenuHorizontalRule1:Paint(w, h) 
        draw.RoundedBox(0, 0, 0,w, h, escapeMenuColor4)  
    end

    ----------------------------------------------------------------------------
    ---Toggle HUD Option--------------------------------------------------------
    ----------------------------------------------------------------------------
    local toggleHUDPanel = vgui.Create( "DPanel", optionsSubMenuCenterPanel )
    toggleHUDPanel:SetTall(h * .09)
    toggleHUDPanel:Dock(TOP)

    function toggleHUDPanel:Paint(w, h)
        draw.SimpleText("Heads up Display", "Esc_Menu_Small", w *.05, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local enableHUDCheckbox = vgui.Create( "DCheckBox", toggleHUDPanel )  
    enableHUDCheckbox:SetSize( h*.03, h*.03 ) 
    enableHUDCheckbox:Dock(RIGHT)
    enableHUDCheckbox:DockMargin(0,h*.03,h*.05,h*.03)
    enableHUDCheckbox:SetChecked( ply.options.enableHud )

    function enableHUDCheckbox:Think()
        self:SetWide(self:GetTall())
    end

    function enableHUDCheckbox:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function enableHUDCheckbox:DoClick()
        playEscMenuButtonPressedSound()
        self:SetValue( !self:GetChecked() )
        ply.options.enableHud = self:GetChecked()
        file.Write( "ruin/player_settings.txt", util.TableToJSON( ply.options, true ) ) 
        print("HUD Enabled: " .. tostring(ply.options.enableHud))
    end

    function enableHUDCheckbox:Paint(w, h)
        surface.SetDrawColor(escapeMenuColor3)
        surface.DrawOutlinedRect( 0, 0, w * .8, w * .8, h * .05 )
        draw.RoundedBox(0, 0, 0, w * .8, h * .8, escapeMenuColor4)
        if self:GetChecked() then
            draw.RoundedBox(0, w*.2, h*.2, w*.4, h*.4, escMenuTextColorHovered2)
        end
    end

    ----------------------------------------------------------------------------
    ---Toggle Threat Highlighter Option-----------------------------------------
    ----------------------------------------------------------------------------
    local toggleThreatPanel = vgui.Create( "DPanel", optionsSubMenuCenterPanel )
    toggleThreatPanel:SetTall(h * .09)
    toggleThreatPanel:Dock(TOP)

    function toggleThreatPanel:Paint(w, h)
        draw.SimpleText("Threat Highlighter", "Esc_Menu_Small", w *.05, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local enableThreatHighlighterCheckbox = vgui.Create( "DCheckBox", toggleThreatPanel )  
    enableThreatHighlighterCheckbox:SetSize( h*.03, h*.03 ) 
    enableThreatHighlighterCheckbox:Dock(RIGHT)
    enableThreatHighlighterCheckbox:DockMargin(0,h*.03,h*.05,h*.03)
    enableThreatHighlighterCheckbox:SetChecked( ply.options.enableThreatHighlighter )

    function enableThreatHighlighterCheckbox:Think()
        self:SetWide(self:GetTall())
    end

    function enableThreatHighlighterCheckbox:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function enableThreatHighlighterCheckbox:DoClick()
        playEscMenuButtonPressedSound()
        self:SetValue( !self:GetChecked() )
        ply.options.enableThreatHighlighter = self:GetChecked()
        file.Write( "ruin/player_settings.txt", util.TableToJSON( ply.options, true ) ) 
        print("Threat Highlighter Enabled: " .. tostring(ply.options.enableThreatHighlighter))
    end

    function enableThreatHighlighterCheckbox:Paint(w, h)
        surface.SetDrawColor(escapeMenuColor3)
        surface.DrawOutlinedRect( 0, 0, w * .8, w * .8, h * .05 )
        draw.RoundedBox(0, 0, 0, w * .8, h * .8, escapeMenuColor4)
        if self:GetChecked() then
            draw.RoundedBox(0, w*.2, h*.2, w*.4, h*.4, escMenuTextColorHovered2)
        end
    end

    ----------------------------------------------------------------------------
    ---Toggle Lamps Option------------------------------------------------------
    ----------------------------------------------------------------------------
    local lampsOptionPanel = vgui.Create( "DPanel", optionsSubMenuCenterPanel )
    lampsOptionPanel:SetTall(h * .09) 
    lampsOptionPanel:Dock(TOP)

    function lampsOptionPanel:Paint(w, h)
        draw.SimpleText("Projected Textures", "Esc_Menu_Small", w *.05, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local lampsCheckbox = vgui.Create( "DCheckBox", lampsOptionPanel )  
    lampsCheckbox:SetSize( h*.03, h*.03 ) 
    lampsCheckbox:Dock(RIGHT)
    lampsCheckbox:DockMargin(0,h*.03,h*.05,h*.03)
    lampsCheckbox:SetChecked( ply.options.enableLamps )

    function lampsCheckbox:Think()
        self:SetWide(self:GetTall())
    end

    function lampsCheckbox:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function lampsCheckbox:DoClick()
        playEscMenuButtonPressedSound()
        self:SetValue( !self:GetChecked() )
        ply.options.enableLamps = self:GetChecked()
        file.Write( "ruin/player_settings.txt", util.TableToJSON( ply.options, true ) ) 
        print("Lamps Enabled: " .. tostring(ply.options.enableLamps))
    end

    function lampsCheckbox:Paint(w, h)
        surface.SetDrawColor(escapeMenuColor3)
        surface.DrawOutlinedRect( 0, 0, w * .8, w * .8, h * .05 )
        draw.RoundedBox(0, 0, 0, w * .8, h * .8, escapeMenuColor4)
        if self:GetChecked() then
            draw.RoundedBox(0, w*.2, h*.2, w*.4, h*.4, escMenuTextColorHovered2)
        end
    end

    ----------------------------------------------------------------------------
    ---Toggle Snow Particles Option---------------------------------------------
    ----------------------------------------------------------------------------
    local snowOptionPanel = vgui.Create( "DPanel", optionsSubMenuCenterPanel )
    snowOptionPanel:SetTall(h * .09) 
    snowOptionPanel:Dock(TOP)

    function snowOptionPanel:Paint(w, h)
        draw.SimpleText("Snow Particles", "Esc_Menu_Small", w *.05, h* .5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local snowCheckbox = vgui.Create( "DCheckBox", snowOptionPanel )  
    snowCheckbox:SetSize( h*.03, h*.03 ) 
    snowCheckbox:Dock(RIGHT)
    snowCheckbox:DockMargin(0,h*.03,h*.05,h*.03)
    snowCheckbox:SetChecked( ply.options.enableSnowParticles )

    function snowCheckbox:Think()
        self:SetWide(self:GetTall())
    end

    function snowCheckbox:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function snowCheckbox:DoClick()
        playEscMenuButtonPressedSound()
        self:SetValue( !self:GetChecked() )
        ply.options.enableSnowParticles = self:GetChecked()
        file.Write( "ruin/player_settings.txt", util.TableToJSON( ply.options, true ) ) 
        print("Snow Particles Enabled: " .. tostring(ply.options.enableSnowParticles))
    end

    function snowCheckbox:Paint(w, h)
        surface.SetDrawColor(escapeMenuColor3)
        surface.DrawOutlinedRect( 0, 0, w * .8, w * .8, h * .05 )
        draw.RoundedBox(0, 0, 0, w * .8, h * .8, escapeMenuColor4)
        if self:GetChecked() then
            draw.RoundedBox(0, w*.2, h*.2, w*.4, h*.4, escMenuTextColorHovered2)
        end
    end

    ----------------------------------------------------------------------------
    ---Horizontal Rule 2--------------------------------------------------------
    ----------------------------------------------------------------------------
    local optionsSubMenuHorizontalRule2 = vgui.Create( "DPanel", optionsSubMenuCenterPanel )
    optionsSubMenuHorizontalRule2:SetTall(1) 
    optionsSubMenuHorizontalRule2:Dock(TOP)
    optionsSubMenuHorizontalRule2:DockMargin(0,w*.01,0,w*.01)


    function optionsSubMenuHorizontalRule2:Paint(w, h) 
        draw.RoundedBox(0, 0, 0,w, h, escapeMenuColor4) 
    end

    ----------------------------------------------------------------------------
    ---Music Volume-------------------------------------------------------------
    ----------------------------------------------------------------------------
    local musicSliderPanel = vgui.Create( "DPanel", optionsSubMenuCenterPanel )
    musicSliderPanel:SetTall(h * .09) 
    musicSliderPanel:Dock(TOP)

    function musicSliderPanel:Paint(w, h) 
        draw.SimpleText("Music Volume", "Esc_Menu_Small", w*.05, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local musicSlider = vgui.Create( "DNumSlider", musicSliderPanel )				
    musicSlider:SetTall(h * .09)	
    musicSlider:Dock(FILL)	
    musicSlider:DockMargin(0,0,w*.01,0)
    musicSlider:SetText( "" )
    musicSlider:SetMin( 0 )				 	
    musicSlider:SetMax( 100 )				
    musicSlider:SetDecimals( 0 )	
    if ply.musicChannel then 
        musicSlider:SetValue( math.Remap(ply.musicChannel:GetVolume(),0,.15,0,100) )
    else
        musicSlider:SetValue( 0,0,.15,0,100) 
    end

    musicSlider.Slider.Knob:SetSize(h * .007, h * .015)	

    function musicSlider.Slider.Knob:Paint(w, h)
        draw.RoundedBox(0, 0, 0,w, h, escMenuTextColor) 
    end

    function musicSlider.Slider:Paint(w, h) 
        draw.RoundedBox(0, 0, h * .475, w, h * .05, escapeMenuColor4) 
    end

    function musicSlider.TextArea:Paint(w, h)
        draw.SimpleText(self:GetValue(), "Esc_Menu_Small", w*.5, h*.5, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end


    
    function musicSlider:OnValueChanged()
        ply.options.musicVolume = math.Remap(musicSlider:GetValue(),0,100,0,1)
        ply.musicChannel:SetVolume(ply.options.musicVolume)
        file.Write( "ruin/player_settings.txt", util.TableToJSON( ply.options, true ) ) 
    end

    ----------------------------------------------------------------------------
    ---Horizontal Rule 3--------------------------------------------------------
    ----------------------------------------------------------------------------
    local optionsSubMenuHorizontalRule3 = vgui.Create( "DPanel", optionsSubMenuCenterPanel )
    optionsSubMenuHorizontalRule3:SetTall(1) 
    optionsSubMenuHorizontalRule3:Dock(TOP)
    optionsSubMenuHorizontalRule3:DockMargin(0,w*.01,0,w*.01)


    function optionsSubMenuHorizontalRule3:Paint(w, h) 
        draw.RoundedBox(0, 0, 0,w, h, escapeMenuColor4)  
    end

    ----------------------------------------------------------------------------
    ---Laser Color--------------------------------------------------------------
    ----------------------------------------------------------------------------
    local laserColorPanel = vgui.Create( "DPanel", optionsSubMenuCenterPanel )
    laserColorPanel:SetTall(h * .09) 
    laserColorPanel:Dock(TOP)

    function laserColorPanel:Paint(w, h) 
        draw.SimpleText("Laser Color", "Esc_Menu_Small", w*.05, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end	
    
    local laserColorPalette = vgui.Create( "DColorPalette", laserColorPanel )
    laserColorPalette:Dock(RIGHT)	
    laserColorPalette:DockMargin(w*.05,h*.0175,w*.03,0)
    laserColorPalette:SetPos( 5, 50 )
    laserColorPalette:SetSize( w*.1, h*.025 )
    laserColorPalette:SetButtonSize( h * .015 )

    function laserColorPalette:OnValueChanged(newColor)
        playEscMenuButtonPressedSound()
        ply.options.laserColor = newColor
        file.Write( "ruin/player_settings.txt", util.TableToJSON( ply.options, true ) ) 
        PrintTable(ply.options.laserColor)
    end

    ----------------------------------------------------------------------------
    ---Horizontal Rule 3--------------------------------------------------------
    ----------------------------------------------------------------------------
    local optionsSubMenuHorizontalRule3 = vgui.Create( "DPanel", optionsSubMenuCenterPanel )
    optionsSubMenuHorizontalRule3:SetTall(1) 
    optionsSubMenuHorizontalRule3:Dock(TOP)
    optionsSubMenuHorizontalRule3:DockMargin(0,w*.01,0,w*.01)

    function optionsSubMenuHorizontalRule3:Paint(w, h) 
        draw.RoundedBox(0, 0, 0,w, h, escapeMenuColor4)  
    end

    ----------------------------------------------------------------------------
    ---Return To Main Menu Button-----------------------------------------------
    ----------------------------------------------------------------------------
    local optionsSubMenuReturnToMainmenu = vgui.Create("DButton", optionsSubMenuCenterPanel)
    optionsSubMenuReturnToMainmenu:SetText("")
    optionsSubMenuReturnToMainmenu:SetPos(0, 0)
    optionsSubMenuReturnToMainmenu:SetSize( w*.25, h*.1) 
    optionsSubMenuReturnToMainmenu:Dock(BOTTOM)
    optionsSubMenuReturnToMainmenu:DockMargin(0, h*.05, 0, 0)
        
    function optionsSubMenuReturnToMainmenu:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("RETURN", "Esc_Menu", w*.5, h*.1, escMenuTextColorHovered, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .005, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("RETURN", "Esc_Menu", w*.5, h*.1, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .003, escMenuTextOutlineColor)
        end
    end

    function optionsSubMenuReturnToMainmenu:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function optionsSubMenuReturnToMainmenu:DoClick()
        playEscMenuButtonPressedSound()
        optionsSubMenu:Remove()
        RUIN.EscapeMenuVGUI:Show()
    end

end

------------------------------------------------
----KEY REFERENCE SUB MENU----------------------
------------------------------------------------

local function createKeyReferenceSubMenu()
    ----------------------------------------------------------------------------
    ---Main Sub Menu Panel------------------------------------------------------
    ----------------------------------------------------------------------------
    -- Support lua refresh by storing it in a global var when created, then checking it here and removing it. Globals arent cleared on refresh which is why we can do this.
    if keyReferenceSubMenuVGUI then keyReferenceSubMenuVGUI:Remove() end

    local keyReferenceSubMenu = vgui.Create( "DFrame" )
    RUIN.keyReferenceSubMenuVGUI = keyReferenceSubMenu
    ply.keyManagerHUD = keyReferenceSubMenu
    keyReferenceSubMenuVGUI = keyReferenceSubMenu
    keyReferenceSubMenu:SetPos( 0, 0 ) 
    keyReferenceSubMenu:SetSize( w, h ) --Height doesnt matter
    keyReferenceSubMenu:SetTitle( "" ) 
    keyReferenceSubMenu:SetDraggable( false ) 
    keyReferenceSubMenu:ShowCloseButton( false ) 
    timer.Simple(0, function()
        if !keyReferenceSubMenu then return end
        if !IsValid(keyReferenceSubMenu) then return end
        keyReferenceSubMenu:MakePopup()
    end)

    function keyReferenceSubMenu:Paint(w, h)
        surface.SetDrawColor( 0, 0, 0)                                    -- Set the drawing color.
        surface.SetMaterial( escapeMenuMat1 )                               -- Use our cached material.
        surface.DrawTexturedRect(0, 0, w, h )                               -- Actually draw the rectangle.
        draw.RoundedBox(0, w * .3625, 0, w * .275, h, escapeMenuColor1)
        draw.RoundedBox(0, w * .362, 0, w * .0025, h, escapeMenuColor2)
        draw.RoundedBox(0, w * .6355, 0, w * .0025, h, escapeMenuColor2)
    end

    function keyReferenceSubMenu:Think()
        self:ShowCloseButton(false)
    end

    ----------------------------------------------------------------------------
    ---Center Panel Container---------------------------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceSubMenuCenterPanel = vgui.Create( "DPanel", keyReferenceSubMenu ) 
    keyReferenceSubMenuCenterPanel:Dock(FILL)
    keyReferenceSubMenuCenterPanel:DockMargin(w*.3615,0,w*.3615,0)
    
    function keyReferenceSubMenuCenterPanel:Paint() end

    ----------------------------------------------------------------------------
    ---Key Reference Sub Menu Top Text------------------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceTopTextPanel = vgui.Create( "DPanel", keyReferenceSubMenuCenterPanel )
    keyReferenceTopTextPanel:SetTall(h * .05)
    keyReferenceTopTextPanel:Dock(TOP)
    keyReferenceTopTextPanel:DockMargin(0,w*.01,0,0)

    function keyReferenceTopTextPanel:Paint(w, h)
        draw.SimpleTextOutlined("Controls", "Esc_Menu", w *.5, h*.5, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
    end

    ----------------------------------------------------------------------------
    ---Horizontal Rule 1--------------------------------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceSubMenuHorizontalRule1 = vgui.Create( "DPanel", keyReferenceSubMenuCenterPanel )
    keyReferenceSubMenuHorizontalRule1:SetTall(1) 
    keyReferenceSubMenuHorizontalRule1:Dock(TOP)
    keyReferenceSubMenuHorizontalRule1:DockMargin(0,w*.02,0,w*.01)


    function keyReferenceSubMenuHorizontalRule1:Paint(w, h) 
        draw.RoundedBox(0, 0, 0,w, h, escapeMenuColor4)  
    end

    ----------------------------------------------------------------------------
    ---Key Reference Sub Menu Movement Keys Text--------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceMovementKeysTextPanel = vgui.Create( "DButton", keyReferenceSubMenuCenterPanel )
    keyReferenceMovementKeysTextPanel:SetText("")
    keyReferenceMovementKeysTextPanel:SetTall(h * .05)
    keyReferenceMovementKeysTextPanel:Dock(TOP)
    keyReferenceMovementKeysTextPanel:DockMargin(0,0,0,0)

    function keyReferenceMovementKeysTextPanel:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("Movement", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColorHovered, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
            draw.SimpleTextOutlined(input.LookupBinding( "+forward", true ) .. "," .. input.LookupBinding( "+moveleft", true ) .. "," .. input.LookupBinding( "+back", true ) .. "," .. input.LookupBinding( "+moveright", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColorHovered, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("Movement", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
            draw.SimpleTextOutlined(input.LookupBinding( "+forward", true ) .. "," .. input.LookupBinding( "+moveleft", true ) .. "," .. input.LookupBinding( "+back", true ) .. "," .. input.LookupBinding( "+moveright", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
        end
    end

    function keyReferenceMovementKeysTextPanel:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function keyReferenceMovementKeysTextPanel:DoClick()
        playEscMenuButtonPressedSound()
        RunConsoleCommand( "gamemenucommand", "OpenOptionsDialog" )
        self:GetParent():GetParent():Hide()
        timer.Simple(0, function() gui.ActivateGameUI() end)
    end

    ----------------------------------------------------------------------------
    ---Key Reference Sub Menu Shoot Key Text------------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceShootKeyTextPanel = vgui.Create( "DButton", keyReferenceSubMenuCenterPanel )
    keyReferenceShootKeyTextPanel:SetText("")
    keyReferenceShootKeyTextPanel:SetTall(h * .05)
    keyReferenceShootKeyTextPanel:Dock(TOP)
    keyReferenceShootKeyTextPanel:DockMargin(0,0,0,0)

    function keyReferenceShootKeyTextPanel:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("Shoot", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColorHovered, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
            draw.SimpleTextOutlined(input.LookupBinding( "+attack", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColorHovered, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)    
        else
            draw.SimpleTextOutlined("Shoot", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
            draw.SimpleTextOutlined(input.LookupBinding( "+attack", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)    
        end
    end

    function keyReferenceShootKeyTextPanel:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function keyReferenceShootKeyTextPanel:DoClick()
        playEscMenuButtonPressedSound()
        RunConsoleCommand( "gamemenucommand", "OpenOptionsDialog" )
        self:GetParent():GetParent():Hide()
        timer.Simple(0, function() gui.ActivateGameUI() end)
    end

    ----------------------------------------------------------------------------
    ---Key Reference Sub Menu Crouch Key Text-----------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceCrouchKeyTextPanel = vgui.Create( "DButton", keyReferenceSubMenuCenterPanel )
    keyReferenceCrouchKeyTextPanel:SetText("")
    keyReferenceCrouchKeyTextPanel:SetTall(h * .05)
    keyReferenceCrouchKeyTextPanel:Dock(TOP)
    keyReferenceCrouchKeyTextPanel:DockMargin(0,0,0,0)

    function keyReferenceCrouchKeyTextPanel:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("Crouch", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColorHovered, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
            draw.SimpleTextOutlined(input.LookupBinding( "+duck", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColorHovered, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("Crouch", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
            draw.SimpleTextOutlined(input.LookupBinding( "+duck", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
        end   
    end

    function keyReferenceCrouchKeyTextPanel:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function keyReferenceCrouchKeyTextPanel:DoClick()
        playEscMenuButtonPressedSound()
        RunConsoleCommand( "gamemenucommand", "OpenOptionsDialog" )
        self:GetParent():GetParent():Hide()
        timer.Simple(0, function() gui.ActivateGameUI() end)
    end
    
    ----------------------------------------------------------------------------
    ---Horizontal Rule 2--------------------------------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceSubMenuHorizontalRule2 = vgui.Create( "DPanel", keyReferenceSubMenuCenterPanel )
    keyReferenceSubMenuHorizontalRule2:SetTall(1) 
    keyReferenceSubMenuHorizontalRule2:Dock(TOP)
    keyReferenceSubMenuHorizontalRule2:DockMargin(0,w*.01,0,w*.01)

    function keyReferenceSubMenuHorizontalRule2:Paint(w, h) 
        draw.RoundedBox(0, 0, 0,w, h, escapeMenuColor4)  
    end

    ----------------------------------------------------------------------------
    ---Key Reference Sub Menu Use Key Text--------------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceUseKeyTextPanel = vgui.Create( "DButton", keyReferenceSubMenuCenterPanel )
    keyReferenceUseKeyTextPanel:SetText("")
    keyReferenceUseKeyTextPanel:SetTall(h * .05)
    keyReferenceUseKeyTextPanel:Dock(TOP)
    keyReferenceUseKeyTextPanel:DockMargin(0,0,0,0)

    function keyReferenceUseKeyTextPanel:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("Use", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColorHovered, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
            draw.SimpleTextOutlined(input.LookupBinding( "+use", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColorHovered, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("Use", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
            draw.SimpleTextOutlined(input.LookupBinding( "+use", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
        end 
    end

    function keyReferenceUseKeyTextPanel:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function keyReferenceUseKeyTextPanel:DoClick()
        playEscMenuButtonPressedSound()
        RunConsoleCommand( "gamemenucommand", "OpenOptionsDialog" )
        self:GetParent():GetParent():Hide()
        timer.Simple(0, function() gui.ActivateGameUI() end)
    end


    ----------------------------------------------------------------------------
    ---Key Reference Sub Menu Switch Weapon Key Text----------------------------
    ----------------------------------------------------------------------------
    local keyReferenceSwitchWeaponKeyTextPanel = vgui.Create( "DButton", keyReferenceSubMenuCenterPanel )
    keyReferenceSwitchWeaponKeyTextPanel:SetText("")
    keyReferenceSwitchWeaponKeyTextPanel:SetTall(h * .05)
    keyReferenceSwitchWeaponKeyTextPanel:Dock(TOP)
    keyReferenceSwitchWeaponKeyTextPanel:DockMargin(0,0,0,0)

    function keyReferenceSwitchWeaponKeyTextPanel:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("Swap Weapon", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColorHovered, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
            draw.SimpleTextOutlined(input.LookupBinding( "+showscores", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColorHovered, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("Swap Weapon", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
            draw.SimpleTextOutlined(input.LookupBinding( "+showscores", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
        end 
    end

    function keyReferenceSwitchWeaponKeyTextPanel:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function keyReferenceSwitchWeaponKeyTextPanel:DoClick()
        playEscMenuButtonPressedSound()
        RunConsoleCommand( "gamemenucommand", "OpenOptionsDialog" )
        self:GetParent():GetParent():Hide()
        timer.Simple(0, function() gui.ActivateGameUI() end)
    end

    ----------------------------------------------------------------------------
    ---Horizontal Rule 3--------------------------------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceSubMenuHorizontalRule3 = vgui.Create( "DPanel", keyReferenceSubMenuCenterPanel )
    keyReferenceSubMenuHorizontalRule3:SetTall(1) 
    keyReferenceSubMenuHorizontalRule3:Dock(TOP)
    keyReferenceSubMenuHorizontalRule3:DockMargin(0,w*.01,0,w*.01)

    function keyReferenceSubMenuHorizontalRule3:Paint(w, h) 
        draw.RoundedBox(0, 0, 0,w, h, escapeMenuColor4)  
    end

    ----------------------------------------------------------------------------
    ---Key Reference Sub Menu Ability 1 Key Text--------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceAbility1KeyTextPanel = vgui.Create( "DButton", keyReferenceSubMenuCenterPanel )
    keyReferenceAbility1KeyTextPanel:SetText("")
    keyReferenceAbility1KeyTextPanel:SetTall(h * .05)
    keyReferenceAbility1KeyTextPanel:Dock(TOP)
    keyReferenceAbility1KeyTextPanel:DockMargin(0,0,0,0)

    function keyReferenceAbility1KeyTextPanel:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("Ability 1", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColorHovered, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
            draw.SimpleTextOutlined(input.LookupBinding( "+speed", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColorHovered, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("Ability 1", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
            draw.SimpleTextOutlined(input.LookupBinding( "+speed", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
        end 
    end

    function keyReferenceAbility1KeyTextPanel:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function keyReferenceAbility1KeyTextPanel:DoClick()
        playEscMenuButtonPressedSound()
        RunConsoleCommand( "gamemenucommand", "OpenOptionsDialog" )
        self:GetParent():GetParent():Hide()
        timer.Simple(0, function() gui.ActivateGameUI() end)
    end

    ----------------------------------------------------------------------------
    ---Key Reference Sub Menu Ability 2 Key Text--------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceAbility2KeyTextPanel = vgui.Create( "DButton", keyReferenceSubMenuCenterPanel )
    keyReferenceAbility2KeyTextPanel:SetText("")
    keyReferenceAbility2KeyTextPanel:SetTall(h * .05)
    keyReferenceAbility2KeyTextPanel:Dock(TOP)
    keyReferenceAbility2KeyTextPanel:DockMargin(0,0,0,0)

    function keyReferenceAbility2KeyTextPanel:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("Ability 2", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColorHovered, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
            draw.SimpleTextOutlined(input.LookupBinding( "impulse 100", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColorHovered, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("Ability 2", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
            draw.SimpleTextOutlined(input.LookupBinding( "impulse 100", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
        end 
    end

    function keyReferenceAbility2KeyTextPanel:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function keyReferenceAbility2KeyTextPanel:DoClick()
        playEscMenuButtonPressedSound()
        RunConsoleCommand( "gamemenucommand", "OpenOptionsDialog" )
        self:GetParent():GetParent():Hide()
        timer.Simple(0, function() gui.ActivateGameUI() end)
    end

    ----------------------------------------------------------------------------
    ---Key Reference Sub Menu Ability 3 Key Text--------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceAbility3KeyTextPanel = vgui.Create( "DButton", keyReferenceSubMenuCenterPanel )
    keyReferenceAbility3KeyTextPanel:SetText("")
    keyReferenceAbility3KeyTextPanel:SetTall(h * .05)
    keyReferenceAbility3KeyTextPanel:Dock(TOP)
    keyReferenceAbility3KeyTextPanel:DockMargin(0,0,0,0)

    function keyReferenceAbility3KeyTextPanel:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("Ability 3", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColorHovered, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
            draw.SimpleTextOutlined(input.LookupBinding( "+menu", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColorHovered, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("Ability 3", "Esc_Menu_Small", w * .1, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
            draw.SimpleTextOutlined(input.LookupBinding( "+menu", true ), "Esc_Menu_Small", w * .9, h*.5, escMenuTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
        end 
    end

    function keyReferenceAbility3KeyTextPanel:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function keyReferenceAbility3KeyTextPanel:DoClick()
        playEscMenuButtonPressedSound()
        RunConsoleCommand( "gamemenucommand", "OpenOptionsDialog" )
        self:GetParent():GetParent():Hide()
        timer.Simple(0, function() gui.ActivateGameUI() end)
    end

    ----------------------------------------------------------------------------
    ---Horizontal Rule 4--------------------------------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceSubMenuHorizontalRule4 = vgui.Create( "DPanel", keyReferenceSubMenuCenterPanel )
    keyReferenceSubMenuHorizontalRule4:SetTall(1) 
    keyReferenceSubMenuHorizontalRule4:Dock(TOP)
    keyReferenceSubMenuHorizontalRule4:DockMargin(0,w*.01,0,w*.01)

    function keyReferenceSubMenuHorizontalRule4:Paint(w, h) 
        draw.RoundedBox(0, 0, 0,w, h, escapeMenuColor4)  
    end

    ----------------------------------------------------------------------------
    ---Return To Main Menu Button-----------------------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceSubMenuReturnToMainmenu = vgui.Create("DButton", keyReferenceSubMenuCenterPanel)
    keyReferenceSubMenuReturnToMainmenu:SetText("")
    keyReferenceSubMenuReturnToMainmenu:SetPos(0, 0)
    keyReferenceSubMenuReturnToMainmenu:SetSize( w*.25, h*.1) 
    keyReferenceSubMenuReturnToMainmenu:Dock(BOTTOM)
    keyReferenceSubMenuReturnToMainmenu:DockMargin(0, h*.05, 0, 0)
        
    function keyReferenceSubMenuReturnToMainmenu:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("RETURN", "Esc_Menu", w*.5, h*.1, escMenuTextColorHovered, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .005, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("RETURN", "Esc_Menu", w*.5, h*.1, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .003, escMenuTextOutlineColor)
        end
    end

    function keyReferenceSubMenuReturnToMainmenu:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function keyReferenceSubMenuReturnToMainmenu:DoClick()
        playEscMenuButtonPressedSound()
        keyReferenceSubMenu:Remove()
        RUIN.EscapeMenuVGUI:Show()
    end
end

------------------------------------------------
----MAP SELECT REFERENCE SUB MENU---------------
------------------------------------------------
local function createMapSelectSubMenu()
    ----------------------------------------------------------------------------
    ---Main Sub Menu Panel------------------------------------------------------
    ----------------------------------------------------------------------------
    -- Support lua refresh by storing it in a global var when created, then checking it here and removing it. Globals arent cleared on refresh which is why we can do this.
    if mapSelectionSubMenuVGUI then mapSelectionSubMenuVGUI:Remove() end

    local mapSelectionSubMenu = vgui.Create( "DFrame" )
    RUIN.mapSelectionSubMenu = mapSelectionSubMenu
    ply.mapSelectionHUD = mapSelectionSubMenu
    mapSelectionSubMenuVGUI = mapSelectionSubMenu
    mapSelectionSubMenu:SetPos( 0, 0 ) 
    mapSelectionSubMenu:SetSize( w, h ) -- Height doesnt matter.
    mapSelectionSubMenu:SetTitle( "" ) 
    mapSelectionSubMenu:SetDraggable( false ) 
    mapSelectionSubMenu:ShowCloseButton( false ) 
    timer.Simple(0, function()
        if !mapSelectionSubMenu then return end
        if !IsValid(mapSelectionSubMenu) then return end
        mapSelectionSubMenu:MakePopup()
    end)

    function mapSelectionSubMenu:Paint(w, h)
        surface.SetDrawColor( 0, 0, 0)                                    -- Set the drawing color.
        surface.SetMaterial( escapeMenuMat1 )                               -- Use our cached material.
        surface.DrawTexturedRect(0, 0, w, h )                               -- Actually draw the rectangle.
        draw.RoundedBox(0, w * .3625, 0, w * .275, h, escapeMenuColor1)
        draw.RoundedBox(0, w * .362, 0, w * .0025, h, escapeMenuColor2)
        draw.RoundedBox(0, w * .6355, 0, w * .0025, h, escapeMenuColor2)
    end

    function mapSelectionSubMenu:Think()
        self:ShowCloseButton(false)
    end

    ----------------------------------------------------------------------------
    ---Center Panel Container---------------------------------------------------
    ----------------------------------------------------------------------------
    local mapSelectionSubMenuCenterPanel = vgui.Create( "DPanel", mapSelectionSubMenu ) 
    mapSelectionSubMenuCenterPanel:Dock(FILL)
    mapSelectionSubMenuCenterPanel:DockMargin(w*.3615,0,w*.3615,0)
    
    function mapSelectionSubMenuCenterPanel:Paint() end

    ----------------------------------------------------------------------------
    ---Map Select Sub Menu Top Text---------------------------------------------
    ----------------------------------------------------------------------------
    local mapSelectTopTextPanel = vgui.Create( "DPanel", mapSelectionSubMenuCenterPanel )
    mapSelectTopTextPanel:SetTall(50)
    mapSelectTopTextPanel:Dock(TOP)
    mapSelectTopTextPanel:DockMargin(0,w*.01,0,0)

    function mapSelectTopTextPanel:Paint(w, h)
        draw.SimpleTextOutlined("Map Select", "Esc_Menu", w *.5, h*.5, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
    end

    ----------------------------------------------------------------------------
    ---Horizontal Rule 1--------------------------------------------------------
    ----------------------------------------------------------------------------
    local mapSelectSubMenuHorizontalRule1 = vgui.Create( "DPanel", mapSelectionSubMenuCenterPanel )
    mapSelectSubMenuHorizontalRule1:SetTall(1) 
    mapSelectSubMenuHorizontalRule1:Dock(TOP)
    mapSelectSubMenuHorizontalRule1:DockMargin(0,w*.02,0,w*.03)


    function mapSelectSubMenuHorizontalRule1:Paint(w, h) 
        draw.RoundedBox(0, 0, 0,w, h, escapeMenuColor4)  
    end

    ----------------------------------------------------------------------------
    ---Scroll Panel ------------------------------------------------------------
    ---------------------------------------------------------------------------- 
    local mapSelectScrollPanel = vgui.Create( "DScrollPanel", mapSelectionSubMenuCenterPanel )
    mapSelectScrollPanel:Dock( FILL )
    mapSelectScrollPanel:DockMargin( 0, 0, w*.006, h*.00475 )
    
    local scrollBar = mapSelectScrollPanel:GetVBar() -- The scroll bar on the right side of the scroll panel.
    
    function scrollBar:Paint(w,h)  
        draw.RoundedBox(0,0,0,w,h,escapeMenuColor4)
    end

    function scrollBar.btnGrip:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,escapeMenuColor3)
    end
    
    function scrollBar.btnUp:Paint(w, h) 
        draw.RoundedBox(0,0,0,w,h,escapeMenuColor2)
    end

    function scrollBar.btnDown:Paint(w, h) 
        draw.RoundedBox(0,0,0,w,h,escapeMenuColor2)
    end
    
    local maps = file.Find( "maps/rn_*", "GAME" )
    local missingImageIcon = Material("icons/missing_image.png")
    local mapIcons = {}

    for _, map in pairs(maps) do
        local mapNameForLevelChange = string.Replace(map, ".bsp", "")
        local mapNameForDisplay = string.Replace(map, "rn_", "")
        mapNameForDisplay = string.Replace(mapNameForDisplay, "_", " ")
        mapNameForDisplay = string.Replace(mapNameForDisplay, ".bsp", "")
        mapNameForDisplay = string.sub( mapNameForDisplay, 1, 25 ) -- Trim maps with very long name so they don't go outside the HUD.

        local DButton = mapSelectScrollPanel:Add( "DButton" )
        DButton:SetText( mapNameForDisplay )
        DButton:SetTall(h * .09)
        DButton:Dock( TOP )
        DButton:DockMargin( 0, 0, 0, 5 )
        DButton:SetText("")

        if file.Exists( "maps/thumb/" .. mapNameForLevelChange .. ".png", "GAME" ) then
            mapIcons[mapNameForLevelChange] = Material("maps/thumb/" .. mapNameForLevelChange .. ".png")
        end

        function DButton:Paint(w, h)
            surface.SetMaterial(mapIcons[mapNameForLevelChange] or missingImageIcon)
            surface.SetDrawColor(Color(255, 255, 255, 200))
            surface.DrawTexturedRect(w*.02,0,h,h)

            if self:IsHovered() then
                draw.SimpleTextOutlined(mapNameForDisplay, "Esc_Menu_Small", w * .3, h*.5, escMenuTextColorHovered, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColorHovered)
            else
                draw.SimpleTextOutlined(mapNameForDisplay, "Esc_Menu_Small", w * .3, h*.5, escMenuTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, w * .003, escMenuTextOutlineColor)
            end
        end

        function DButton:OnCursorEntered()
            playEscMenuButtonEnteredSound() 
        end
    
        function DButton:DoClick()
            playEscMenuButtonPressedSound()
            RunConsoleCommand( "changelevel", mapNameForLevelChange )
        end
    end

    ----------------------------------------------------------------------------
    ---Return To Main Menu Button-----------------------------------------------
    ----------------------------------------------------------------------------
    local mapSelectSubMenuReturnToMainmenu = vgui.Create("DButton", mapSelectionSubMenuCenterPanel)
    mapSelectSubMenuReturnToMainmenu:SetText("")
    mapSelectSubMenuReturnToMainmenu:SetPos(0, 0)
    mapSelectSubMenuReturnToMainmenu:SetSize( w*.25, h*.1) 
    mapSelectSubMenuReturnToMainmenu:Dock(BOTTOM)
    mapSelectSubMenuReturnToMainmenu:DockMargin(0, h*.05, 0, 0)
        
    function mapSelectSubMenuReturnToMainmenu:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("RETURN", "Esc_Menu", w*.5, h*.1, escMenuTextColorHovered, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .005, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("RETURN", "Esc_Menu", w*.5, h*.1, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .003, escMenuTextOutlineColor)
        end
    end

    function mapSelectSubMenuReturnToMainmenu:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function mapSelectSubMenuReturnToMainmenu:DoClick()
        playEscMenuButtonPressedSound()
        mapSelectionSubMenu:Remove()
        RUIN.EscapeMenuVGUI:Show()
    end
end


------------------------------------------------
----ESCAPE MENU---------------------------------
------------------------------------------------

local function RUINescapeMenuToggle()         
    -- Support lua refresh by storing it in a global var when created, then checking it here and removing it. Globals arent cleared on refresh which is why we can do this.
    if RUINescapeMenuToggleVGUI then RUINescapeMenuToggleVGUI:Remove() end
    
    -- If a menu is already up, close it.
    if IsValid( RUIN.EscapeMenuVGUI or RUIN.EscapeOptionsSubMenuVGUI) then
        if IsValid(RUIN.EscapeMenuVGUI) then RUIN.EscapeMenuVGUI:Remove() end
        if IsValid(RUIN.EscapeOptionsSubMenuVGUI) then RUIN.EscapeOptionsSubMenuVGUI:Remove() end
        if IsValid(RUIN.keyReferenceSubMenuVGUI) then RUIN.keyReferenceSubMenuVGUI:Remove() end
        if IsValid(RUIN.mapSelectionSubMenu) then RUIN.mapSelectionSubMenu:Remove() end
        return
    end
    RUINescapeMenuToggleVGUI = RUIN.EscapeMenuVGUI
    ----------------------------------------------------------------------------
    ---Main Escape Menu Panel---------------------------------------------------
    ----------------------------------------------------------------------------
    local escMenu = vgui.Create( "DFrame" ) -- escMenu actually holds a pointer to where DFrame is actually stored.
    RUIN.EscapeMenuVGUI = escMenu           -- Global var for referencing outside defined scope. (Don't think this will be needed actually)
    escMenu:SetPos( 0, 0 ) 
    escMenu:SetSize( w, h ) 
    escMenu:SetTitle( "" )  
    escMenu:SetDraggable( false ) 
    escMenu:ShowCloseButton( false ) 
    escMenu:MakePopup()
    input.SetCursorPos(w * .5, h * .8)
    
    function escMenu:Paint( w, h )
        surface.SetDrawColor( 0, 0, 0)                                    -- Set the drawing color.
        surface.SetMaterial( escapeMenuMat1 )                               -- Use our cached material.
        surface.DrawTexturedRect(0, 0, w, h )                               -- Actually draw the rectangle.
        draw.RoundedBox(0, w * .3625, 0, w * .275, h, escapeMenuColor1) 
        draw.RoundedBox(0, w * .362, 0, w * .0025, h, escapeMenuColor2 )
        draw.RoundedBox(0, w * .6355, 0, w * .0025, h, escapeMenuColor2 )
    end

    ----------------------------------------------------------------------------
    ---Resume Game Menu button--------------------------------------------------
    ----------------------------------------------------------------------------
    local resumeButton = vgui.Create("DButton", escMenu)
    resumeButton:SetText("")
    resumeButton:SetPos(0, 0)
    resumeButton:SetSize( w*.5, h*.1) 
    resumeButton:Dock(TOP)
    resumeButton:DockMargin(w *.36, h*.05, w*.36, 0) 
    resumeButton:DockPadding( w, 5, 5, 5 )
    
    function resumeButton:Paint(w, h)    
        if self:IsHovered() then
            draw.SimpleTextOutlined("Resume", "Esc_Menu", w*.5, h*.1, escMenuTextColorHovered, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .005, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("Resume", "Esc_Menu", w*.5, h*.1, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .003, escMenuTextOutlineColor)
        end
    end
    
    function resumeButton:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end
    
    function resumeButton:DoClick()
        playEscMenuButtonPressedSound()
        escMenu:Remove()
    end
    
    ----------------------------------------------------------------------------
    ---RUIN Options Menu button-------------------------------------------------
    ----------------------------------------------------------------------------
    local RUINoptionsMenuButton = vgui.Create("DButton", escMenu)
    RUINoptionsMenuButton:SetText("")
    RUINoptionsMenuButton:SetPos(0, 0)
    RUINoptionsMenuButton:SetSize( w*.5, h*.1) 
    RUINoptionsMenuButton:Dock(TOP)
    RUINoptionsMenuButton:DockMargin(w *.36, h*.02, w*.36, 0) 
    RUINoptionsMenuButton:DockPadding( w, 5, 5, 5 )
    
    function RUINoptionsMenuButton:Paint(w, h)    
        if self:IsHovered() then
            draw.SimpleTextOutlined("RUIN Settings", "Esc_Menu", w*.5, h*.1, escMenuTextColorHovered, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .005, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("RUIN Settings", "Esc_Menu", w*.5, h*.1, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .003, escMenuTextOutlineColor)
        end
    end
    
    function RUINoptionsMenuButton:OnCursorEntered()
            playEscMenuButtonEnteredSound() 
    end
    
    function RUINoptionsMenuButton:DoClick()
            playEscMenuButtonPressedSound()
            createOptionsSubMenu()
            escMenu:Hide()
    end

    ----------------------------------------------------------------------------
    ---Key Reference Button-----------------------------------------------------
    ----------------------------------------------------------------------------
    local keyReferenceMenu = vgui.Create("DButton", escMenu)
    keyReferenceMenu:SetText("")
    keyReferenceMenu:SetPos(0, 0)
    keyReferenceMenu:SetSize( w*.25, h*.1) 
    keyReferenceMenu:Dock(TOP)
    keyReferenceMenu:DockMargin(w *.36, h*.02, w*.36, 0) 
        
    function keyReferenceMenu:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("Controls", "Esc_Menu", w*.5, h*.1, escMenuTextColorHovered, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .005, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("Controls", "Esc_Menu", w*.5, h*.1, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .003, escMenuTextOutlineColor)
        end
    end

    function keyReferenceMenu:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function keyReferenceMenu:DoClick()
        playEscMenuButtonPressedSound()
        createKeyReferenceSubMenu()
        escMenu:Hide()
    end

    ----------------------------------------------------------------------------
    ---Map Select Menu Button---------------------------------------------------
    ----------------------------------------------------------------------------
    local RUINlevelSelect = vgui.Create("DButton", escMenu)
    RUINlevelSelect:SetText("")
    RUINlevelSelect:SetPos(0, 0)
    RUINlevelSelect:SetSize( w*.25, h*.1) 
    RUINlevelSelect:Dock(TOP)
    RUINlevelSelect:DockMargin(w *.36, h*.02, w*.36, 0) 
    
    function RUINlevelSelect:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("Map Select", "Esc_Menu", w*.5, h*.1, escMenuTextColorHovered, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .005, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("Map Select", "Esc_Menu", w*.5, h*.1, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .003, escMenuTextOutlineColor)
        end
    end

    function RUINlevelSelect:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function RUINlevelSelect:DoClick()
        playEscMenuButtonPressedSound()
        createMapSelectSubMenu()
        escMenu:Hide()
    end
    
    ----------------------------------------------------------------------------
    ---Gmod Menu Button---------------------------------------------------------
    ----------------------------------------------------------------------------
    local gmodMenu = vgui.Create("DButton", escMenu)
    gmodMenu:SetText("")
    gmodMenu:SetPos(0, 0)
    gmodMenu:SetSize( w*.25, h*.1) 
    gmodMenu:Dock(TOP)
    gmodMenu:DockMargin(w *.36, h*.02, w*.36, 0) 
            
    function gmodMenu:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("Gmod Menu", "Esc_Menu", w*.5, h*.1, escMenuTextColorHovered, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .005, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("Gmod Menu", "Esc_Menu", w*.5, h*.1, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .003, escMenuTextOutlineColor)
        end
    end

    function gmodMenu:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function gmodMenu:DoClick()
        playEscMenuButtonPressedSound()
        RUIN.EscapeMenuVGUI:Hide()
        timer.Simple(0, function() gui.ActivateGameUI() end)
    end
    
    ----------------------------------------------------------------------------
    ---Discord Link Button------------------------------------------------------
    ----------------------------------------------------------------------------
    -- local discordLink = vgui.Create("DButton", escMenu)
    -- discordLink:SetText("")
    -- discordLink:SetPos(0, 0)
    -- discordLink:SetSize( w*.25, h*.1) 
    -- discordLink:Dock(TOP)
    -- discordLink:DockMargin(w *.36, h*.02, w*.36, 0) 
    
    -- function discordLink:Paint(w, h)
    --     if self:IsHovered() then
    --         draw.SimpleTextOutlined("Discord", "Esc_Menu", w*.5, h*.1, escMenuTextColorHovered, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .005, escMenuTextOutlineColorHovered)--TODO: Add custom font
    --     else
    --         draw.SimpleTextOutlined("Discord", "Esc_Menu", w*.5, h*.1, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .003, escMenuTextOutlineColor)--TODO: Add custom font
    --     end
    -- end
    
    -- function discordLink:OnCursorEntered()
    --     playEscMenuButtonEnteredSound() 
    -- end
    
    -- function discordLink:DoClick()
    --     playEscMenuButtonPressedSound()
    --     gui.OpenURL( "" )
    -- end
    
    ----------------------------------------------------------------------------
    ---Quit Button--------------------------------------------------------------
    ----------------------------------------------------------------------------
    local disconnect = vgui.Create("DButton", escMenu)
    disconnect:SetText("")
    disconnect:SetPos(0, 0)
    disconnect:SetSize( w*.25, h*.1) 
    disconnect:Dock(BOTTOM)
    disconnect:DockMargin(w *.36, h*.05, w*.36, 0) 
        
    function disconnect:Paint(w, h)
        if self:IsHovered() then
            draw.SimpleTextOutlined("Quit", "Esc_Menu", w*.5, h*.025, escMenuTextColorHovered, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .005, escMenuTextOutlineColorHovered)
        else
            draw.SimpleTextOutlined("Quit", "Esc_Menu", w*.5, h*.025, escMenuTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, w * .003, escMenuTextOutlineColor)
        end
    end

    function disconnect:OnCursorEntered()
        playEscMenuButtonEnteredSound() 
    end

    function disconnect:DoClick()
        ply:ConCommand( "disconnect" )
    end
end

concommand.Add("RUIN_escapeMenuToggle", RUINescapeMenuToggle) -- Rebinding functionality. (Doubt anyone will use it, I'm not going to bother integrating it)

local frontBuffer = Material("effects/frontbuffer")
hook.Add( "PreRender", "RUIN Custom Escape Menu", function()
    if ((input.IsKeyDown(KEY_ESCAPE) or input.IsButtonDown(KEY_XBUTTON_START)) and gui.IsGameUIVisible()) then
        gui.HideGameUI()
        ply:ConCommand( "RUIN_escapeMenuToggle" )
        -- Render a texture of the screen over the screen for a frame to mask the gmod menu popping up for a frame before its closed by gui.HideGameUI()
        -- For some reason effects/frontbuffer is a missing texture when it shouldn't be so we need to do some extra work to make it function properly using 
        -- render.GetScreenEffectTexture()
        cam.Start2D()
            surface.SetDrawColor(255, 255, 255, 255)
            render.UpdateScreenEffectTexture()
            frontBuffer:SetTexture( "$basetexture", render.GetScreenEffectTexture() )
            surface.SetMaterial(frontBuffer)
            surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        cam.End2D()
        
        return true 
    end
end )

-- This is a mess no matter what.
hook.Add("Think", "RUIN sh_escape_menu", function()
    if !RUIN.EscapeMenuVGUI then return end

    if RUIN.EscapeMenuVGUI:IsVisible() then
        ply.escMenuOpen = true
    else
        if RUIN.EscapeOptionsSubMenuVGUI and RUIN.EscapeOptionsSubMenuVGUI:IsVisible() then 
            ply.escMenuOpen = true
            return 
        end

        if RUIN.keyReferenceSubMenuVGUI and RUIN.keyReferenceSubMenuVGUI:IsVisible() then
            ply.escMenuOpen = true 
            return
        end

        if RUIN.mapSelectionSubMenu and RUIN.mapSelectionSubMenu:IsVisible() then
            ply.escMenuOpen = true 
            return
        end
        
        ply.escMenuOpen = false
    end
end)

local colorLookup = {
    [ "$pp_colour_addr" ] = 0,
    [ "$pp_colour_addg" ] = 0,
    [ "$pp_colour_addb" ] = 0,
    [ "$pp_colour_brightness" ] = 0,
    [ "$pp_colour_contrast" ] = 1,
    [ "$pp_colour_colour" ] = 0, -- This controls saturation.
    [ "$pp_colour_mulr" ] = 0,
    [ "$pp_colour_mulg" ] = 0,
    [ "$pp_colour_mulb" ] = 0
}

hook.Add( "RenderScreenspaceEffects", "RUIN sh_escape_menu Escape Menu Screen Effects", function() -- Desaturation, Toytown blur, and motion blur.
    if ply.escMenuOpen then 
        DrawColorModify( colorLookup )
        DrawToyTown( 2, h  )
    end
end )

-- Hacky solution to menus integration, need to initialize all of these so escape menu will re-open properly when you press gmod menu and it was ur first time loading in and
-- you never opened any of the sub menus. The timer is needed because otherwise it will say musicChannel is nil since the option menu uses it and music channel gets created 1 sec
-- after game start.
timer.Simple(1.1, function()
    createOptionsSubMenu()
    createKeyReferenceSubMenu()
    createMapSelectSubMenu()
    
    ply.optionsHUD:Remove()
    ply.keyManagerHUD:Remove()
    ply.mapSelectionHUD:Remove()
end)
