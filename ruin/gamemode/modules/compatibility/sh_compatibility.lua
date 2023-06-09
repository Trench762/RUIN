local hooksRemoved = 0

local function cleanExternalHooks()
    for hookEventName, hookTable in pairs(hook.GetTable()) do
        for name, func in pairs(hookTable) do 
            if !func then return end
            
            local src = debug.getinfo(func).source

            -- If it's not from includes, base GM, or RUIN GM then remove it.
            if  !string.find(src, "lua/includes") and !string.find(src, "gamemodes/base") and !string.find(src, "gamemodes/ruin") then
                hook.Remove(hookEventName, name)
                hooksRemoved = hooksRemoved + 1
            end
        end
    end
end

-- Quick and easy way to account for non uniform load order across operating systems.
-- It will keep removing external hooks every frame for the first second of the game, this should be more than enough time for all files to load.
-- This method won't account for timers that re-initialize and/or run code, glua has offers no ability to fetch timers as far as I know (The con command isn't useful).
local stopTimer = false
timer.Simple(1, function()
    stopTimer = true
end)

hook.Add("Think", "RUIN Clear External Hooks On Start", function()
    if stopTimer then 
        hook.Remove("Think", "RUIN Clear External Hooks On Start") 
        print("Removed " .. hooksRemoved .. " external hooks not related to RUIN for compatibility reasons. \n")
        return 
    end

    cleanExternalHooks()
end)



