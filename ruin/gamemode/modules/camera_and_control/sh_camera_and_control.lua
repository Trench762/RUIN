if SERVER then
	util.AddNetworkString( "RUIN Reset Camera Yaw" ) 
	local localPly 
	
	hook.Add("PlayerSpawn", "Ruin Align Camera On Spawn", function(ply)
		local ply  = ply
		localPly  = ply
		
		net.Start("RUIN Reset Camera Yaw")
		net.Send(ply)
	end)

	hook.Add("Think", "RUIN Disable Laser When Player Using Turret", function()
		if !IsValid(localPly) then return end

		if(localPly:GetEntityInUse() != NULL) then
			localPly:setIsUsingTurret(true)
		else
			localPly:setIsUsingTurret(false)
		end
	end)

	concommand.Add( "ruin_debug_menu_cam", function( ply, cmd, args )
		ply:setDebuggingMenuCamera( !ply:getDebuggingMenuCamera() )
		
		ply:PrintMessage( HUD_PRINTCENTER, "Menu Cam Debug Mode Entered: Noclip Enabled" )
		ply:PrintMessage( HUD_PRINTCONSOLE, "Menu Cam Debug Mode Entered: Noclip Enabled" )
	end )

	concommand.Add( "ruin_debug_menu_cam_get_values", function( ply, cmd, args )
		if(ply:getDebuggingMenuCamera()) then
			print("Position: " .. tostring(math.Round(ply:EyePos().x,4)) .. " " .. tostring(math.Round(ply:EyePos().y,4)) .. " " .. tostring(math.Round(ply:EyePos().z,4)))
			print("Angles: " .. tostring(math.Round(ply:EyeAngles().p,4)) .. " " .. tostring(math.Round(ply:EyeAngles().y,4)) .. " " .. tostring(math.Round(ply:EyeAngles().r,4)))
		else
			print("Not in main menu cam debug mode!")
		end
	end )
end

if CLIENT then
	local DEBUG = false -- SET THIS TO TRUE TO VISUALIZE DEBUGGING, REQUIRED "developer 1" IN CONSOLE
	local nextDebugRender = CurTime()
	local zoomLevel = 2
	local currentZoomLevel = zoomLevel
	local camPos = 0
	local eyeAngles
	local viewAng = Angle(54.5,90,0)
	local currentAng = currentAng or Angle(55,90,0)
	local targetAng = targetAng or Angle(55,90,0)
	local angleDifference = 0
	local absoluteZ 
	local plyOrigin
	local autoAimDirection
	local focusCam = false
	local updatingCam = false

	hook.Add( "CalcView", "RUIN Top Down View", function( ply, pos, angles, fov )	
		if ply:getDebuggingMenuCamera() then return end
		if !RUIN.mapSettings then return end 
		
		if ply.inMainMenu then 
			local view = {
				origin = Vector(util.StringToType(RUIN.mapSettings.main_menu_cam_pos, "Vector")), 
				angles = Angle(util.StringToType(RUIN.mapSettings.main_menu_cam_ang, "Angle")),  
				fov = 85,
				drawviewer = true
			}

			return view
		end

		-- Move cam deep into void when dead to avoid flicker due to render buffer issues when opening esc menu 
		if (!ply:Alive() and ply:Health() <= 0) then
			local view = {
				origin = Vector(0,0,-9999999), 
				angles = Angle(-90,0,0),  
				fov = 85,
				drawviewer = false
			}

			return view
		end
	
		-- Stop moving cam when HP Gets to 0.
		if(ply:Health() <= 0) then
			local view = {
				origin = camPos,
				angles = viewAng,
				fov = 85,
				drawviewer = true
			}
	
			return view
		end

		zoomLevel = input.IsButtonDown(KEY_LCONTROL) and 1.7 or 2
		absoluteZ = ply:GetPos().z 	-- Needed because using pos alone will cause camera to go down if player crouches,
		plyOrigin = pos			 	-- using GetPos() alone will cause the camera shake code when bullets are fired to not work.
		plyOrigin.z = absoluteZ
		eyeAngles = ply:LocalEyeAngles()
		
		-- Autoaim integration check modules/auto_aim/sh_autoaim.lua
		if(RUIN.autoAimOverride == false) then
			eyeAngles.pitch = 0 --make it so player can't look up or down 
		elseif(RUIN.autoAimOverride == true) then
			autoAimDirection = (RUIN.autoAimTargetPosition - ply:EyePos()):Angle()
			eyeAngles.pitch = autoAimDirection.pitch
		end

		ply:SetEyeAngles(eyeAngles) -- Needed for auto aim override to take effect.
		angleDifference =  math.abs( math.AngleDifference(currentAng.yaw, eyeAngles.yaw) )

		if(angleDifference > 10 and !updatingCam) then
			focusCam = true 
		end

		if(snapCameraOnSpawn) then
			currentAng = eyeAngles
			if viewAng.y == eyeAngles.y then
				timer.Simple(.1, function()
					snapCameraOnSpawn = false
				end)
			end
		end

		if(focusCam == true) then			
			currentAng = LerpAngle(snapCameraOnSpawn and 1 or FrameTime() * (math.max(angleDifference / 2, 4 )) , currentAng, targetAng )
			targetAng = eyeAngles
			updatingCam = true
			
			if(angleDifference <= .5 ) then 
				focusCam = false 
				updatingCam = false
			end
		end

		viewAng.yaw = currentAng.yaw

		-- Used viewAng:Right():Angle():Right() because this gets a line shooting backwards out of the 
		-- camera's view angle that's parraellel to the ground.
		-- (If you use viewAng:Forward() then offset is not parrellel to the ground and multiplying this number will change the height of the camera aswell)
		-- Also for some reason x and y offsets need to be done seperately to avoid collision issues.
		currentZoomLevel = Lerp(FrameTime() * 4, currentZoomLevel, zoomLevel)
		camPos = plyOrigin + Vector(viewAng:Right():Angle():Right() * (50 * currentZoomLevel ), 0, 0) 
		camPos = camPos + Vector(0, 0, 150 * (currentZoomLevel  + 1))				  
	
		local view = {
			origin = camPos,
			angles = viewAng,
			fov = 85,
			drawviewer = true
		}

		return view
	end )

	net.Receive("RUIN Reset Camera Yaw", function()
		snapCameraOnSpawn = true 
	end)

    local traceMins =  Vector( -12, -12, -36 )
    local traceMaxs = Vector( 12, 12, 36 )
    local ply = nil

    hook.Add("Think", "RUIN Cam Update On Enemy Targeted", function()
        if !IsValid(ply) then ply = LocalPlayer() end
        if (!IsValid(ply)) or (ply:Health() <= 0) then return end
        -- This way the trace will always be shooting straight out no matter what the pitch of the player's aim is (Important for when autoaim code overrides the pitch)
        local correctedEyeAngles = ply:EyeAngles()
        correctedEyeAngles.p = 0
        
        local tr = util.TraceHull( {
            start = ply:EyePos(),
            endpos = ply:EyePos() + (correctedEyeAngles:Forward() * 10000),

            filter = function( ent )
                return ( ent:GetClass() == "npc_metropolice" ) 
                or ( ent:GetClass() == "npc_combine_s" ) 
            end, 
			ignoreworld = true,
            mins = traceMins,
            maxs = traceMaxs,
        } )

        local hitPos = tr.HitPos
        local hitEnt = tr.Entity

        if tr.Hit == true  and hitEnt:IsNPC() and hitEnt:isVisibleToPlayer() then
			focusCam = true
		end

        -- DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG--
        -- DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG--
        if DEBUG == false then return end
        if nextDebugRender > CurTime() then return end
        nextDebugRender = CurTime() + .01
        debugoverlay.Box( hitPos, traceMins, traceMaxs, .01, Color( 0, 181, 253) )
        -- DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG--
        -- DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG--
    end)

	-- This is needed so player can't move mouse when dead which is a problem with using pos with CalcView below
	hook.Add("AdjustMouseSensitivity", "RUIN Top Down View Clamp Death Sense", function()
		if(Entity(1):Health() > 0) then return end
		return 0.000000001
	end)

	local delayLaserCalc = 0
	local laserStartPos = Vector()
	local laserHitPos = Vector()
	local laserDistance = 0
	local laserDistNormalized = 0
	local laserDistNormalizedInverse = 1
	local traceInfluence = Vector()
	local correctiveTraceInfluence = Vector()
	local laserTooClose = false
	local weaponWorldModel = nil
	local weaponBarrelWorldPosition = Vector()

	-- Reference: https://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/indexdd58.html
	local laserEndMaterial = Material( "ruin/misc/laser_end" )
	local laserBodyMaterial = Material("ruin/misc/laser")
	local laserOutlineMaterial = Material ( "trails/smoke")
	local laserColor = Color(255, 255, 255)
	local laserColorOutline = Color(255, 255, 255, 100)
	local ply = LocalPlayer()
	local laserLength = 0
	timer.Simple(.1, function()
		ply = LocalPlayer()
	end)

	hook.Add( "PostDrawTranslucentRenderables", "RUIN Draw Laser", function()
		if (!ply:IsValid() or ply:Health() <= 0 or ply.isReloadingPistol or ply:isUsingTurret()) then return end
		if ply.escMenuOpen then return end
		if ply.inMainMenu then return end
		if ply:getDebuggingMenuCamera() then return end
		if RUIN.extracted then return end
		if ply:isCloaking() then return end
		weaponWorldModel = ply:GetActiveWeapon() 
		if(IsValid(weaponWorldModel)) then
			weaponBarrelWorldPosition = weaponWorldModel:GetAttachment(weaponWorldModel:LookupAttachment("muzzle")).Pos
		end

		if(delayLaserCalc < CurTime()) then
			-- ~120 times a second (Wont update past more than 120 FPS, this is so that we dont overcalculate at high fps which would lower fps)
			delayLaserCalc = CurTime() + 0.0083 

			local trace = util.QuickTrace( ply:EyePos(), ply:GetAimVector() * 10000, 
				function(ent) if  ((ent == ply) or ent.shouldLaserIgnore) then return false else return true end
			end)

			local correctiveTrace = util.QuickTrace( weaponBarrelWorldPosition - (ply:GetForward() * 32) + Vector(0,0,0), ply:EyeAngles():Forward() * 10000, 
				function(ent) if  ((ent == ply) or ent.shouldLaserIgnore) then return false else return true end
			end)

			laserStartPos = trace.StartPos
			laserHitPos = trace.HitPos
			laserDistance = laserStartPos:DistToSqr(laserHitPos)

			laserDistNormalized = math.min(1, math.Round(math.Remap( laserDistance, 0, 40000, 0, 1), 2)) -- math.Remap isn't even working properly? (40000 = 200 units when it start blending)
			laserDistNormalizedInverse =  math.Remap(laserDistNormalized, 0, 1, 1, 0)
			traceInfluence.x, traceInfluence.y, traceInfluence.z = laserDistNormalized, laserDistNormalized ,laserDistNormalized
			correctiveTraceInfluence.x, correctiveTraceInfluence.y, correctiveTraceInfluence.z = laserDistNormalizedInverse, laserDistNormalizedInverse, laserDistNormalizedInverse 

			laserHitPos = (trace.HitPos * traceInfluence) + (correctiveTrace.HitPos * correctiveTraceInfluence)

			if(laserDistance < 2304) then  -- Stop laser render if 48 units close to object.
				laserTooClose = true
			else
				laserTooClose = false
			end

			// DEBUG DEBUG DEBUG //
				if(DEBUG == true) then
					print("Trace Influence: ")
					print( traceInfluence)
					print("Corrective Trace Influence: ")
					print(correctiveTraceInfluence)
				end
			// DEBUG DEBUG DEBUG //
		end

		if(laserTooClose == true) then return end
		laserColor.r, laserColorOutline.r = ply.options.laserColor.r, ply.options.laserColor.r
		laserColor.g, laserColorOutline.g = ply.options.laserColor.g, ply.options.laserColor.g
		laserColor.b, laserColorOutline.b = ply.options.laserColor.b, ply.options.laserColor.b
		laserColor.a, laserColorOutline.r = math.random(100,255), 200

		laserLength = (laserHitPos - weaponBarrelWorldPosition):Length()
		
		if(ply:isUsingAggressorQ()) then
			render.SetMaterial(laserEndMaterial)
			local sin = math.sin( CurTime()*32 ) * 2
			for i=1, 3 do
				render.DrawSprite( weaponBarrelWorldPosition, (10/i)+sin, (10/i)+sin, Color(255,255,255,100) )
			end
		end

		render.SetMaterial(laserEndMaterial)
		render.DrawSprite( laserHitPos, 10, 10, laserColor )
		
		render.SetMaterial(laserOutlineMaterial )
		render.DrawBeam(weaponBarrelWorldPosition , laserHitPos, 1, 0, 1, laserColorOutline)
		render.SetMaterial(laserBodyMaterial)
		render.DrawBeam(weaponBarrelWorldPosition , laserHitPos, 3, 0, laserLength / 8, laserColor) 
	end )

	CreateClientConVar( "ruin_camera_yaw", "180", false, true, "", nil, nil )

    hook.Add( "Think", "RUIN Top Down View Think", function()       
        RunConsoleCommand( "ruin_camera_yaw", viewAng.yaw )   
    end )
end

local crouchMult = 1

local function ruinMove(ply, mv)
    local camAngle = Angle(0, ply:GetInfoNum("ruin_camera_yaw", 0), 0)
    local moveDir = Vector()
    local speed = speed or ply:GetWalkSpeed()
    
    if (mv:KeyDown(IN_DUCK)) then
        crouchMult = 0.5
    else
        crouchMult = 1
    end

    if ply:getDebuggingMenuCamera() then 
        if (mv:KeyDown(IN_FORWARD)) 	then moveDir = moveDir + ply:GetAngles():Forward() end
        if (mv:KeyDown(IN_MOVELEFT)) 	then moveDir = moveDir + (-ply:GetAngles():Right()) end
        if (mv:KeyDown(IN_MOVERIGHT)) 	then moveDir = moveDir + ply:GetAngles():Right() end
        if (mv:KeyDown(IN_BACK)) 		then moveDir = moveDir + (-ply:GetAngles():Forward()) end
    else
        if (mv:KeyDown(IN_FORWARD)) 	then moveDir = moveDir + camAngle:Forward() end
        if (mv:KeyDown(IN_MOVELEFT)) 	then moveDir = moveDir + (-camAngle:Right()) end
        if (mv:KeyDown(IN_MOVERIGHT)) 	then moveDir = moveDir + camAngle:Right() end
        if (mv:KeyDown(IN_BACK)) 		then moveDir = moveDir + (-camAngle:Forward()) end
    end

    moveDir:Normalize()

    local velocity = Vector() 
    velocity = velocity + (moveDir * speed * crouchMult)

    if ply:isDashing() then 
		velocity = velocity * 5 
	end

    mv:SetVelocity( velocity + Vector(0,0,-300) )
end

hook.Add("Move", "RUIN Movement", ruinMove)

