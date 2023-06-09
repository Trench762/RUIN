------------------------------------------------------
----------------------HUD STUFF-----------------------
------------------------------------------------------
local songTranslations = {
    ["sound/ruin/music/Raizzer_Blind.ogg"]          = "RaiiZeR - Blind",
    ["sound/ruin/music/Raizzer_Corruption.ogg"]     = "RaiiZeR - Corruption",
    ["sound/ruin/music/Raizzer_Memory.ogg"]         = "RaiiZeR - Memory",
    ["sound/ruin/music/Raizzer_Rogue.ogg"]          = "RaiiZeR - Rogue",
    ["sound/ruin/music/Raizzer_Try.ogg"]            = "RaiiZeR - Try",
    ["sound/ruin/music/Raizzer_Warning.ogg"]        = "RaiiZeR - Warning",
    ["sound/ruin/music/Raizzer_The_Hunt.ogg"]       = "RaiiZer - The Hunt",
    ["sound/ruin/music/Unholy_20202020.ogg"]        = "Unholy - 20202020",
}

local color = Color(255,255,255,150)
local color2
local ply = LocalPlayer()
local scrW, scrH = ScrW(), ScrH()

surface.CreateFont("Music System HUD Font" , { font = "Kenney Future Square", size = ScreenScale(7), weight = 0, blursize = 0; scanlines = 0, shadow = true, additive = true, })

hook.Add( "OnScreenSizeChanged", "RUIN Music System UI Rebuild Screen Sizes", function( oldWidth, oldHeight )
    scrW, scrH = ScrW(), ScrH()
    surface.CreateFont("Music System HUD Font" , { font = "Kenney Future Square", size = ScreenScale(7), weight = 0, blursize = 0; scanlines = 0, shadow = true, additive = true, })
end )

local activeSong = "N/A"
local musicPlayingIcon = Material("icons/radio_waves.png")

hook.Add("DrawOverlay", "RUIN Music system HUD paint", function()
    ply = ply or LocalPlayer()
    if ply.escMenuOpen then return end
    if !IsValid(ply.musicChannel) then return end
    color.a = math.max(0, math.Remap(ply.musicChannel:GetTime() or 0,0,8,255,0))
    if ply.musicChannel:GetVolume() == 0 then return end

    surface.SetMaterial(musicPlayingIcon)
    surface.SetDrawColor(color)
    surface.DrawTexturedRect(scrW * .01, scrH * .0275, scrH * .035, scrH * .035  )
    draw.SimpleText( "Now playing " .. activeSong or "N/A", "Music System HUD Font", scrW * .035, scrH * .035, color, 0, 3 )
end)

local function displayActiveSong(song)
    activeSong = songTranslations[song]
    print("Now playing: " .. activeSong)
end
------------------------------------------------------
----------------------HUD STUFF-----------------------
------------------------------------------------------

local ply = LocalPlayer()

local mainMenuSong = "sound/ruin/music/Unholy_20202020.ogg"

-- TODO: Get songs.
local gameplaySongs = {
    "sound/ruin/music/Raizzer_Blind.ogg",     
    "sound/ruin/music/Raizzer_Corruption.ogg",     
    "sound/ruin/music/Raizzer_Memory.ogg",     
    "sound/ruin/music/Raizzer_Rogue.ogg",     
    "sound/ruin/music/Raizzer_Try.ogg",     
    "sound/ruin/music/Raizzer_Warning.ogg",  
    "sound/ruin/music/Raizzer_The_Hunt.ogg",  
}

local dumpTable = {}
local lastPlayedSong

-- Randomly pick songs from a table and then remove songs from that table, putting them into another table, once all songs are played, 
-- re-insert the songs and clear the dump table. Continue ad infinitum.
local function queueSong()
    if(table.Count(gameplaySongs) == 0) then    --If our picking table is empty, 
        gameplaySongs = dumpTable               --repopulate it with values from dump table
        dumpTable = {}                          --Clear the dump table
    end

    song = table.Random(gameplaySongs)          --Pick a random song
    table.RemoveByValue( gameplaySongs, song )  --Remove it from the table we're picking from
    table.insert(dumpTable, song)               --Add it to the dump table

    if (song == lastPlayedSong) then            --Make 100% sure the same song isn't played twice as it can still rarely occur
        song = gameplaySongs[1]                 --We know this can only occur when just refilling the table, so it's safe to take from the first index of the picking table
        table.insert(dumpTable, gameplaySongs[1]) --Insert that song into the dump table
        table.remove(gameplaySongs, 1)           --And remove it from the picking table
    end

    lastPlayedSong = song                   
    return song
end

function RUIN.playSong(inMainMenu, startAtTime, forceSong) 
    local song = nil -- Need to do it this way so it doesn't get garbage collected? 

    if inMainMenu then
        song = mainMenuSong
    end

    if forceSong then
        song = forceSong
    end

    -- Not sure if "song = song or queueSong() will work in this context.
    if song == nil then 
        song = queueSong()
    end 

    sound.PlayFile( song, "noblock", function( channel, errCode, errStr )
        if ( IsValid( channel ) ) then
            -- Stop any audio playing on this channel.
            if(IsValid(ply.musicChannel)) then  -- Attaching to player and then clearing separately ensures no floating references/ double playing songs when editing code.
                local musicChannel = ply.musicChannel
                musicChannel:Stop()
            end
            -- Set the variable that will contain our channel to this channnel and play the audio.
            ply = LocalPlayer()
            ply.musicChannel = channel
            channel:SetVolume(ply.options.musicVolume) 
            channel:SetTime(startAtTime or 0) -- Start at a specified time if supplied, if not start the song from the beginning.
            channel:Play()
            displayActiveSong(song)

            -- print("----Table----")
            -- PrintTable(gameplaySongs)
            -- print("---Dump Table--")
            -- PrintTable(dumpTable)
        else
            print( "Error playing sound!", errCode, errStr )
        end
    end )
end

-- APPARENTLY THIS IS NO LONGER NEEDED? DID THEY FIX THIS? 
-- FOUND OUT IT WASN'T NEEDED CAUSE IT WAS DOUBLE PLAYING IN POST CLEANUP WHICH WAS MESSING UP CODE TO
-- PLAY THE MAIN MENU SONG AFTER AN EXTRACTION, KEEPING THIS HERE JUST INCASE

    -- local songTimePreCleanupMap
    -- --Cache the time the song left off on before the map is cleaned up
    -- hook.Add("PreCleanupMap", "RUIN Music System Cache Audio Channel Pre Cleanup", function()
    --     if !IsValid(ply) or !IsValid(ply.musicChannel) then return end
    --     if !ply.musicChannel then return end
    --     songTimePreCleanupMap = ply.musicChannel:GetTime()
    -- end)
    -- --Play the song with the optional arguments for the time that it left off on and force it to play the previous song with the third (optional) argument for RUIN.playSong()
    -- hook.Add("PostCleanupMap", "RUIN Music System Cache Audio Channel Pre Cleanup", function()
    --     timer.Simple(.1, function()
    --         RUIN.playSong(ply.inMainMenu, songTimePreCleanupMap, lastPlayedSong) -- TODO: make sure to replace this with ply.inMainMenu later on when integrating
    --     end)
    -- end)

    local justForcedSwitch = false -- The forcedswitch check is neccessary because this hook runs so fast it can call RUIN.playSong() more than once.

    local function resetForcedSwitch()
        timer.Simple(1, function()
            justForcedSwitch = false
        end)
    end

hook.Add("PostRender", "RUIN Music System Handle Pause Song Tabbed Out or Esc Menu and Handle Continue Song and Handle Death Song", function()
    local musicChannel = ply.musicChannel -- To not access so many times.
    if !IsValid(musicChannel) then return end
    
    -- Handles playing the next song if it has reached its max time. (combat songs)
    if !justForcedSwitch and musicChannel:GetState() != GMOD_CHANNEL_PAUSED and musicChannel:GetTime() == musicChannel:GetLength() then 
        RUIN.playSong(ply.inMainMenu) 
        justForcedSwitch = true 
        resetForcedSwitch()
    end

    -- Set music volume based on whether or not they are in the escape menu. (Instant when going in menu, lerp when going out)
    if ply.escMenuOpen then
        musicChannel:SetVolume(ply.options.musicVolume * .15)
    else
        local v = Lerp( .25, musicChannel:GetVolume(), ply.options.musicVolume )
        musicChannel:SetVolume( v )
    end

    -- Handles distorting the song when dead.
    local f = game.GetTimeScale()
    local ff = Lerp( FrameTime(), musicChannel:GetPlaybackRate(), f )
    musicChannel:SetPlaybackRate( ff )

    -- TODO: Do this for if in RUIN Options menu aswell.
    if gui.IsGameUIVisible() then 
        musicChannel:Pause()
        return 
    else
        musicChannel:Play()
        return 
    end
end)




