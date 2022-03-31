-- call me crazy for how i do this
menup.plugins = {}
menup.control = {}
local meta, env, manifest = {}, {}, nil
local shouldload = util.JSONToTable(menup.db.get("enabled", "{}"))

local manifest_default = {
    author = "Unknown",
    description = "Legacy addon.",
    version = "Legacy",
    config = {},
    undo = function() end
}

-- local config_default = {
--     bool = false,
--     int = 0,
--     float = 0,
--     range = 0,
--     string = "",
--     select = "",
-- }
function meta:__call()
end

setmetatable(menup, meta)

function env.menup(perhaps)
    manifest = perhaps
end

function menup.control.preload(func)
    setfenv(func, env)
    pcall(func)
    setfenv(func, _G)

    -- new plugin
    if istable(manifest) then
        manifest.config = manifest.config or {}
        manifest.legacy = false
        manifest.func = func
    else -- legacy plugin
        manifest = table.Copy(manifest_default)
        manifest.id = "legacy.unknown"
        manifest.name = "Unknown"
        manifest.config = {}
        manifest.legacy = true
        manifest.func = func
    end

    local temp = table.Copy(manifest)
    manifest = nil

    return temp
end

function menup.control.load(fileorfunc, name)
    if isfunction(fileorfunc) and not isstring(name) then
        error("Calling load with a function MUST also supply a name!")
    end

    if isstring(fileorfunc) then
        name = name or string.StripExtension(string.Right(fileorfunc, #fileorfunc - #string.GetPathFromFilename(fileorfunc)))
        local script = file.Read(fileorfunc, "GAME")

        if not script then
            error("File " .. fileorfunc .. " doesn't exist!\n(Is the path based from garrysmod?)")
        end

        fileorfunc = CompileString(script, fileorfunc, false)

        if isstring(fileorfunc) then
            error("Error loading plugin " .. name .. ":\n" .. fileorfunc)
        end
    end

    local temp = menup.control.preload(fileorfunc)

    if temp.legacy then
        temp.id = "legacy." .. name
        temp.name = name
    end

    hook.Run("PluginLoaded", temp)

    return temp
end

function menup.control.run(id)
    local manifest = menup.plugins[id]

    if not manifest.enabled then
        ErrorNoHalt("Running plugin " .. id .. " despite it being disabled.")
    end

    hook.Run("PluginRun", manifest)
    local success, result = pcall(manifest.func)

    if not success then
        ErrorNoHaltWithStack("Error running plugin " .. id .. ":\n" .. result)
    elseif isfunction(result) then
        manifest.undo = result
    else
        manifest.undo = nil -- function() end
    end

    return success
end

function menup.control.undo(id)
    local manifest = menup.plugins[id]

    if isfunction(manifest.undo) then
        hook.Run("PluginUndo", manifest)
        local success, result = pcall(manifest.undo)

        if not success then
            ErrorNoHaltWithStack("Error undoing plugin " .. id .. ":\n" .. result)

            return false
        else
            return result ~= nil and result or true
        end
    else
        return false
    end
end

function menup.control.shouldload(id, enabled)
    local shouldload = util.JSONToTable(menup.db.get("enabled", "{}"))
    enabled = enabled ~= nil and enabled or menup.plugins[id].enabled
    shouldload[id] = enabled
    menup.db.set("enabled", util.TableToJSON(shouldload, false))
end

function menup.control.enable(id, save)
    local manifest = menup.plugins[id]

    if save == nil then
        save = true
    else
        save = false
    end

    if not istable(manifest) then
        error("Attempted to enable unregistered plugin " .. id .. ".")
    end

    manifest.enabled = true
    hook.Run("PluginEnabled", manifest)

    if save then
        menup.control.shouldload(id, true)
    end

    return menup.control.run(id)
end

function menup.control.disable(id, save)
    local manifest = menup.plugins[id]

    if save == nil then
        save = true
    else
        save = false
    end

    if not istable(manifest) then
        error("Attempted to disable unregistered plugin " .. id .. ".")
    end

    manifest.enabled = false
    hook.Run("PluginDisabled", manifest)

    if save then
        menup.control.shouldload(id, false)
    end

    return menup.control.undo(id)
end

if not file.IsDir("lua/menu_plugins", "GAME") then
    Derma_Message("You are missing the menu_plugins folder in your garrysmod lua directory! Please create the folder, then restart the game.", "Menu Plugins Redux", "OK")

    return error("Missing menu_plugins folder in garrysmod/lua!!")
end

local files = file.Find("lua/menu_plugins/*.lua", "GAME")
local status = util.JSONToTable(menup.db.get("loadstatus", [[{"loading": "done", "blame": ""}]]))
local start = SysTime()

-- Experimental crash prevention, comment out to enable.
status = {loading = "done"}

local function LoadManifests()
    for _, v in ipairs(files) do
        if v == status.blame then continue end

        menup.db.set("loadstatus", util.TableToJSON({
            loading = "manifest",
            blame = v
        }, false))

        local res, ret = pcall(menup.control.load, "lua/menu_plugins/" .. v)
        if not res then continue end
        ret.file = v
        menup.plugins[ret.id] = ret
    end
end

local function LoadPlugins()
    for k, v in pairs(menup.plugins) do
        if v.file == status.blame then continue end
        menup.db.set("loadstatus", util.TableToJSON({
            loading = "plugin",
            blame = v.file
        }, false))
        if shouldload[k] == true then
            MsgC(Color(166, 166, 166), "| ", Color(255, 255, 255), string.format("%s (%s) is ", k, v.file), Color(0, 230, 118), "enabled.\n")
            local lstart = SysTime()
            menup.control.enable(k, false)
            v.initalization = math.Round((SysTime() - start) * 1000, 2)
        else
            MsgC(Color(166, 166, 166), "| ", Color(255, 255, 255), string.format("%s (%s) is ", k, v.file), Color(255, 23, 68), "disabled.\n")
            v.enabled = false
            shouldload[k] = false
        end
    end
end

local function LoadFull()
    MsgC(Color(166, 166, 166), "+ ", Color(41, 121, 255), "[MPR]", Color(255, 255, 255), " Now loading plugins...\n")
    start = SysTime()
    LoadManifests()
    LoadPlugins()
    menup.db.set("loadstatus", util.TableToJSON({
        loading = "done",
        blame = ""
    }, false))
    menup.db.set("enabled", util.TableToJSON(shouldload, false))
    MsgC(Color(166, 166, 166), "+ ", Color(255, 255, 255), "Done! Plugins loaded in ", Color(41, 121, 255), tostring(math.Round((SysTime() - start) * 1000, 2)), Color(255, 255, 255), " milliseconds.\n")
end

if status.loading ~= "done" then
    Derma_Query(string.format("Last time plugins were loaded, the game crashed. The crash was likely caused by the following plugin: %s. What would you like to do?", status.blame), "Menu Plugins Redux",
    "Continue as normal", function()
        status.blame = ""
        LoadFull()
    end, "Disable " .. status.blame, function()
        shouldload[status.blame] = false
        LoadFull()
    end, "Don't load anything", function()
    end)
    return
else
    LoadFull()
end