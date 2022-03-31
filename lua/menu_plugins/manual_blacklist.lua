local CONFIG = {
    bl = {"Blacklist filters", "list", {"123.456.789.000", "gm:Really bad gamemode", "map:rp_2spooky4you"}, "Things to blacklist."},
    usefp = {"Add default blacklist", "bool", true, "You should probably keep this enabled."}
}

local MANIFEST = {
    id = "djsime1.custom_blacklist",
    author = "djsime1",
    name = "Custom server blacklist",
    description = [[Modify the server blacklist. Supports the following prefixes:  
- "map:" Block maps containing this phrase.  
- "desc:" Block servers with this description.  
- "host:" Block servers with this hostname.  
- "gm:" Block gamemodes with this phrase.  
No prefix means blacklist an IP.]],
    version = "1.0",
    config = CONFIG
}

menup(MANIFEST)

local oldAPI = GetAPIManifest

function GetAPIManifest(cb)
    oldAPI(function(json)
        local data = util.JSONToTable(json)
        local custom = menup.config.get(MANIFEST.id, "bl", {})
        if menup.config.get(MANIFEST.id, "usefp") then
            table.Add(data.Servers.Banned, custom)
        else
            data.Servers.Banned = custom
        end
        cb(util.TableToJSON(data))
    end)
end

if IsValid(pnlMainMenu) and not menup.config.get(MANIFEST.id, "seenpre", false) then
    Derma_Query("Custom blacklist only works if it's enabled when you launch the game. Please restart for your settings to take effect.", "Custom server blacklist",
    "Don't remind me", function() menup.config.set(MANIFEST.id, "seenpre", true) end,
    "Acknowledge this once")
elseif not IsValid(pnlMainMenu) then
    print("Custom server blacklist is now active for this session.")
end

return function()
    GetAPIManifest = oldAPI
    if not menup.config.get(MANIFEST.id, "seenpost", false) then
        Derma_Query("Restart your game to remove custom filters.", "Custom server blacklist",
        "Don't remind me", function() menup.config.set(MANIFEST.id, "seenpost", true) end,
        "Acknowledge this once")
    end
end