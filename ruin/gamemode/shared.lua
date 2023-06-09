GM.Name = "ruin"
GM.Author = "Trench with assistance from Slaugh7er (Chiefly for file loader & death screen)"
GM.Email = "N/A" -- Dont want to give out my personal email, contact me on Steam for any questions.
GM.Website = "https://steamcommunity.com/id/12312415121235/" -- Steam link
RUIN = RUIN or {}

// GLOBAL META TABLES
pMeta = FindMetaTable( "Player" ) 
eMeta = FindMetaTable( "Entity" ) 
// GLOBAL META TABLES

--DeriveGamemode( "sandbox" ) -- For testing.
DeriveGamemode( "base" )

-- function GM:Initialize()
	
-- end
	
local function LoadFileStart( k )
	-- print( "." ) 
	timer.Create( "RUIN " .. k, 1, 1, function() 
	-- 	print( "--| FAILED TO LOAD MODULE <" .. k .. ">" ) 
	end )
	-- print( "++| LOADING MODULE <" .. k .. ">" )
end

local function LoadFileEnd( k )
	timer.Remove( "RUIN " .. k )
	-- print( "==| DONE LOADING MODULE <" .. k .. ">" )
end

local function LoadModules() -- Credits to darkrp developers.
    local root = GAMEMODE.FolderName .. "/gamemode/modules/"
    local _, folders = file.Find(root .. "*", "LUA")
	
	local StartTime = math.Round(CurTime())
	
-- 	print( [[
-- ================================================
-- 	MODULE LOADER STARTED <]] .. StartTime .. [[>
-- ================================================
-- 	]] )
	
    for _, folder in SortedPairs(folders, true) do 
		// MOUNT SERVER FILES
		if SERVER then
			for _, File in SortedPairs(file.Find(root .. folder .. "/sv_*.lua", "LUA"), true) do
				LoadFileStart( folder .. " >> " .. File )
				timer.Simple(0,function()
					include(root .. folder .. "/" .. File)
				end)
				LoadFileEnd( folder .. " >> " .. File )
			end
		end
		// MOUNT SHARED FILES
        for _, File in SortedPairs(file.Find(root .. folder .. "/sh_*.lua", "LUA"), true) do
			LoadFileStart( folder .. " >> " .. File )
			timer.Simple(0,function()
				AddCSLuaFile( root .. folder .. "/" .. File )
				include(root .. folder .. "/" .. File) 
			end)
			LoadFileEnd( folder .. " >> " .. File )
        end
		// MOUNT CLIENT FILES
		for _, File in SortedPairs(file.Find(root .. folder .. "/cl_*.lua", "LUA"), true) do
			LoadFileStart( folder .. " >> " .. File )
			timer.Simple(0,function()
				AddCSLuaFile( root .. folder .. "/" .. File )
				if CLIENT then include(root .. folder .. "/" .. File) end
			end)
			LoadFileEnd( folder .. " >> " .. File )
		end
		-- print( " " ) -- print splitter
    end
	
-- 	local TimeElapsed = (CurTime() - StartTime)
-- 	print( [[
-- ================================================
-- 	MODULE LOADER FINISHED <]] .. TimeElapsed .. [[>
-- ================================================
-- 	]] )
end

function NilFunc() return nil end 	
function NullFunc() return NULL end 

-- local GAMEMODE_RELOADING_ALPHA = 255
-- hook.Add( "HUDPaint", "RUIN cl.gamemode.reload.HUDPaint", function() 
-- 	local w, h = ScrW(), ScrH()
-- 	local a = GAMEMODE_RELOADING_ALPHA/255
-- 	if GAMEMODE_RELOADING_ALPHA>0 then GAMEMODE_RELOADING_ALPHA=GAMEMODE_RELOADING_ALPHA-FrameTime()*66 end
-- 	draw.RoundedBox( h*.1, w*.4, h*.45, w*.2, h*.1, Color(0,0,0,200*a) )
-- 	draw.SimpleTextOutlined( "[GAMEMODE RELOADING]", "DermaLarge", w/2, h/2, Color(255,255,255,255*a), 1, 1, 3, Color(0,0,0,100*a) )
-- 	if timer.Exists( "cl.gamemode.reload.HUDPaint.Timer" ) then return end
-- 	timer.Create( "RUIN cl.gamemode.reload.HUDPaint.Timer", 5, 1, function() 
-- 		hook.Remove( "HUDPaint", "RUIN cl.gamemode.reload.HUDPaint" )
-- 	end )
-- end )

hook.Add( "Think", "RUIN sh.LoadModules.Think", function() -- supports lua refresh and hotloading
	LoadModules() 
	hook.Remove( "Think", "RUIN sh.LoadModules.Think" )
end )	


if SERVER then
	concommand.Add( "_remount_all_gamemode_lua_server", function() 
		LoadModules() 
	end )
	concommand.Add( "_remount_all_gamemode_lua_shared", function() 
		LoadModules() 
		for _, p in pairs( player.GetAll() ) do p:ConCommand("remount_all_gamemode_lua_client") end
	end )
end
if CLIENT then
	concommand.Add( "remount_all_gamemode_lua_client", function() 
		LoadModules() 
	end )
	concommand.Add( "remount_all_gamemode_lua_server", function() 
		RunConsoleCommand( "_remount_all_gamemode_lua_server" )
	end )
	concommand.Add( "remount_all_gamemode_lua_shared", function()
		RunConsoleCommand( "_remount_all_gamemode_lua_shared" )
	end )
end 
