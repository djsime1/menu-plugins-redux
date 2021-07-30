-- call me crazy for how i do this
menup.plugins = {}

local meta, env, manifest = {}, {}, nil
local shouldload = util.JSONToTable(menup.db.get("enabled", "{}"))
local manifest_default = {
    author = "Unknown",
    description = "Legacy addon.",
    version = "Legacy",
    config = {},
    undo = function() end
}
local config_default = {
    bool = false,
    int = 0,
    float = 0,
    range = 0,
    string = "",
    select = "",
}

function meta:__call() end
setmetatable(menup, meta)

function env.menup(perhaps)
    manifest = perhaps
end

if !file.IsDir("lua/menu_plugins", "GAME") then return print("Missing menu_plugins folder in garrysmod/lua!!") end

local files, _ = file.Find("lua/menu_plugins/*.lua", "GAME")
print("Now loading plugins...")
for _, v in ipairs(files) do
    local name = string.StripExtension(v)
    local script = file.Read("lua/menu_plugins/" .. v, "GAME")
    local trial = CompileString(script, v, false)
    if isstring(trial) then ErrorNoHalt("Error loading file " .. v .. ":\n" .. trial) continue end
    setfenv(trial, env)
    pcall(trial)
    setfenv(trial, _G)

    if istable(manifest) then -- new plugin
        manifest.config = manifest.config or {}
        manifest.file = v
        manifest.legacy = false
        manifest.func = trial
    else -- legacy plugin
        manifest = table.Copy(manifest_default)
        manifest.id = "legacy." .. name
        manifest.name = name
        manifest.config = {}
        manifest.file = v
        manifest.legacy = true
        manifest.func = trial
    end

    if shouldload[manifest.id] then
        print(manifest.id .. " (" .. v .. ") is ENABLED.")
        manifest.enabled = true
        if not table.IsEmpty(manifest.config) then
            for ck, cv in pairs(manifest.config) do
                menup.config.set(manifest.id, ck, cv[3] ~= nil and cv[3] or config_default[cv[2]])
            end
        end
        local success, result = pcall(trial)
        if not success then
            ErrorNoHalt("Error loading " .. manifest.id .. ":\n" .. result)
        elseif isfunction(result) then
            manifest.undo = result
        else
            manifest.undo = function() end
        end
    else
        print(manifest.id .. " (" .. v .. ") is disabled.")
        manifest.enabled = false
        shouldload[manifest.id] = false
    end

    menup.plugins[manifest.id] = table.Copy(manifest)
    manifest = nil
end

menup.db.set("enabled", util.TableToJSON(shouldload, false))

print("All done!")