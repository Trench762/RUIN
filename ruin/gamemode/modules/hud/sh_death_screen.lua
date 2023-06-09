-- <SLAUGH7ER>
if SERVER then
	hook.Add( "PostPlayerDeath", "RUIN GameEnd Screen", function(ply) 
		game.SetTimeScale(.75)
		timer.Simple( .1, function() ply:ConCommand( "doDeathScreen" ) end )
	end )

	hook.Add("PlayerSpawn", "RUIN Death Screen Player Spawn", function(ply)
		game.SetTimeScale(1)
	end )
end

if CLIENT then
	surface.CreateFont( "DeathScreenFont", { font = "Kenney Future Square", size = ScreenScale(43), weight = 0 } )
	surface.CreateFont( "DeathScreenKillsFont", { font = "Kenney Future Square", size = ScreenScale(16), weight = 0 } )
	surface.CreateFont( "DeathScreenLoadoutFont", { font = "Kenney Future Square", size = ScreenScale(11), weight = 0 } )
	local p = LocalPlayer()
	local ply = LocalPlayer()
	local w, h = ScrW(), ScrH()
	local loadoutTextColor = Color( 36, 36, 36)
    local loadoutTextColorHovered = Color( 251, 251, 251)
	local killCountAlpha = 0
	local Skull = Material("icons/kill_count_skull.png", "mip smooth")

	hook.Add( "OnScreenSizeChanged", "RUIN Death Screen UI Rebuild Screen Sizes", function( oldWidth, oldHeight )
		w, h = ScrW(), ScrH()
		surface.CreateFont( "DeathScreenFont", { font = "Kenney Future Square", size = ScreenScale(43), weight = 0 } )
		surface.CreateFont( "DeathScreenKillsFont", { font = "Kenney Future Square", size = ScreenScale(16), weight = 0 } )
		surface.CreateFont( "DeathScreenLoadoutFont", { font = "Kenney Future Square", size = ScreenScale(11), weight = 0 } )
	end )
	
	hook.Add("Think", "RUIN Death Screen HUD Manager Think", function()
        if !p.deathScreenHUD then return end
        if !IsValid(p.deathScreenHUD) then return end

		if LocalPlayer().escMenuOpen or gui.IsGameUIVisible() or RUIN.extracted then 
            p.deathScreenHUD:Hide()
            for _, element in pairs(p.deathScreenHUD:GetChildren()) do
                element:Hide()
            end
        else
            p.deathScreenHUD:Show()
            for _, element in pairs(p.deathScreenHUD:GetChildren()) do
                element:Show()
            end
        end
    end)

	concommand.Add( "doDeathScreen", function()
		if RUIN.justSelectedClass then return end
		
		surface.PlaySound( "ambient/levels/citadel/strange_talk9.wav" )
		
		local soundchannel
		sound.PlayFile( "sound/ambient/atmosphere/noise2.wav", "noblock", function( channel )
			if !IsValid( channel ) then return end
			channel:Play()
			channel:EnableLooping( true )
			channel:SetVolume( .05 )
			timer.Create( "RUIN doDeathScreenTimer", .5, 19, function()
				if IsValid( channel ) then 
					channel:SetVolume( channel:GetVolume() + .05 )
				end
			end )
			soundchannel = channel
		end )

		local DFrame = vgui.Create( "DFrame" )
		DFrame:SetSize( w, h )
		DFrame:ShowCloseButton(false)
		DFrame:SetTitle("")
		p.deathScreenHUD = DFrame
		local fraction = 0
		local fraction2 = 0
		local forceCursorPos = true
		timer.Simple(.6, function() 
			forceCursorPos = false
		end)
		
		killCountAlpha = 0
		
		timer.Simple(.2, function()
			timer.Create("RUIN death screen increment kill count alpha", .025, 13, function() 
				killCountAlpha = killCountAlpha + 12.75
				deathCurtainEnable = true
			end)
		end)

		local kills = ply.arenaKills

		DFrame.Paint = function(self,w,h)
			if ply.escMenuOpen then return end
			
			render.SetScissorRect( 0, h*.5, w, h, true )
			draw.SimpleText( "DEAD", "DeathScreenFont", w/2, h*.4+(h *.1 * fraction), Color(126,0,0), 1, 1 )
			
			if tonumber(RUIN.mapSettings["mode"]) == 1 then 
				local text
				if (kills == 1) then 
					text = " kill"
				else
					text = " kills"
				end
				draw.SimpleText( kills .. text, "DeathScreenKillsFont", w/2, h *.475 + (h *.1 * fraction2), Color(60, 60, 60, killCountAlpha), 1, 1 )
			end
			
			render.SetScissorRect( 0, 0, 0, 0, false )
			render.SetScissorRect( 0, 0, w, h*.5, true )
			draw.SimpleText( "DEAD", "DeathScreenFont", w/2, h*.6+(h*.1* -fraction), Color(126,0,0), 1, 1 )
			render.SetScissorRect( 0, 0, 0, 0, false )
		end
		
		DFrame.Think = function(self)
			if ply:Alive() then self:Close() end
			if forceCursorPos then input.SetCursorPos(w * .5, h * .95) end
			fraction = Lerp( FrameTime() * 16, fraction, 1 )
			fraction2 = Lerp( FrameTime() * 8, fraction2, 1 )
			self:ShowCloseButton(false)
		end
		
		DFrame.Close = function(self)
			if self.CLOSING then return end
			
			self.CLOSING = true
			self:AlphaTo( 0, .2, 0, function() self:Remove() end )
			
			timer.Create( "RUIN doDeathScreenTimer", .05, 32, function()
				if IsValid( soundchannel ) then 
					soundchannel:SetVolume( soundchannel:GetVolume() - .05 )
					if soundchannel:GetVolume() <= 0 then
						soundchannel:Stop()
					end
				end
			end )
		end
	
		local DButton = vgui.Create( "DButton", DFrame )
		DButton:SetSize( w*.3, h*.05 )
		DButton:Dock(BOTTOM)
		DButton:DockMargin(0,0,0,w*.03)
		DButton:SetAlpha( 0 )
		DButton:SetText( "" )
		
		DButton.DoClick = function()
			RunConsoleCommand( "RuinAbilitySelector" )
			DFrame:Close()
			surface.PlaySound( "buttons/button9.wav" )
		end
		
		DButton.OnCursorEntered = function(s)
			surface.PlaySound( "buttons/lightswitch2.wav" )
		end
		
		DButton.Paint = function(s,w,h)
			local hover = s:IsHovered()
			draw.SimpleTextOutlined( "[CHANGE LOADOUT]", "DeathScreenLoadoutFont", w/2, h/2, hover and loadoutTextColorHovered or loadoutTextColor, 1, 1, 2, Color(0,0,0,30) )
		end
		
		DButton:AlphaTo( 255, .3, 2, function()
			if !IsValid(DFrame) then return end
			DFrame:MakePopup()
			DFrame:SetKeyboardInputEnabled( false )
		end )
	end )
end