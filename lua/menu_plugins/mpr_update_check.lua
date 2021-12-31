local CONFIG = {
    channel = {
        "Update channel", "select", {"Stable", "Beta"},
        "Beta has more frequent updates, but may contain bugs."
    },
    plugins = {"Check for plugin updates", "bool", true, "Not all plugins are supported."}
}

local MANIFEST = {
    id = "djsime1.update_check",
    author = "djsime1",
    name = "Update checker",
    description = "Notifies when a new version of MPR and/or plugins are available.",
    version = "1.2",
    config = CONFIG,
}

menup(MANIFEST)

local function vnum(version)
    local sum, pieces = 0, {}

    for s in version:gmatch("%d+") do
        table.insert(pieces, tonumber(s))
    end

    for i = 1, #pieces do
        sum = sum + pieces[i] * math.pow(100, #pieces - i)
    end

    return sum
end

local function mprcheck(url, cb)
    http.Fetch(url, function(body)
        local ver, changelog = body:match("menup%.version = \"(%d+%.%d+%.%d+)\""), body:match("menup%.changelog = %[%[\n?(.-)\n?]]") or "No changelog."

        if not ver then
            print("MPR update check failed. (Couldn't find version string)")
            cb(false)

            return
        end

        local new, cur = vnum(ver), vnum(menup.version)

        if new > cur then
            cb(true, {"Menu Plugins Redux", menup.version, ver, "https://github.com/djsime1/menu-plugins-redux", changelog})
        else
            print("You are running the latest version of MPR.")
            cb(false)
        end
    end, function(err)
        print("MPR update check failed. (" .. err .. ")")
        cb(false)
    end)
end

local function pcheck(id, cb)
    local plugin = menup.plugins[id]

    http.Fetch(plugin.source, function(body)
        local func = CompileString(body, "Update check", false)

        if isstring(func) then
            print(id .. " update check failed. (" .. func .. ")")
            cb(false)
        end

        local manifest = menup.control.preload(func)
        local ver = manifest.version

        if not ver then
            print(id .. " update check failed. (Couldn't find version string)")

            return
        end

        local new, cur = vnum(ver), vnum(menup.version)

        if new > cur then
            cb(true, {plugin.name, plugin.version, ver, plugin.source, manifest.changelog})
        else
            print("You are running the latest version of " .. id)
            cb(false)
        end
    end, function(err)
        print(id .. " update check failed. (" .. err .. ")")
        cb(false)
    end)
end

local function popup(updates)
    local updatelist, changelogs = "", ""

    for _, v in ipairs(updates) do
        updatelist = updatelist .. string.format("- [%s](%s) (%s -> %s)  \n", v[1], v[4], v[2], v[3])

        if v[5] then
            changelogs = changelogs .. string.format("### [%s](%s)\n%s  \n", v[1], v[4], v[5])
        end
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 600)
    frame:Center()
    frame:SetTitle("Updates available!")
    local silence = frame:Add("DButton")
    silence:SetText("Got it, don't remind me for...")
    silence:SetIcon("icon16/bell_delete.png")
    silence:Dock(BOTTOM)

    silence.DoClick = function()
        local times = {
            ["6 hours"] = 21600,
            ["12 hours"] = 43200,
            ["1 day"] = 86400,
            ["3 days"] = 172800,
            ["A week"] = 604800,
            ["A month"] = 2678400,
            ["9001 years"] = 31536000 * 9001
        }

        local dm = DermaMenu()

        for k, v in pairs(times) do
            dm:AddOption(k, function()
                menup.config.set(MANIFEST.id, "silence", os.time() + v)
                frame:Close()
            end)
        end

        dm:Open()
    end

    local md = frame:Add("MarkdownPanel")
    md:SetMarkdown(string.format([[# Updates avilable!
*Updates for the following are avilable:*  
%s
## Changelogs:
%s]], updatelist, changelogs))
    md:Dock(FILL)
    frame:MakePopup()
end

hook.Add("MenuVGUIReady", MANIFEST.id, function()
    if menup.config.get(MANIFEST.id, "silence", 0) > os.time() then return end

    local branch = ({"main", "dev"})[menup.config.get(MANIFEST.id, "channel", 1)]

    local url = string.format("https://raw.githubusercontent.com/djsime1/menu-plugins-redux/%s/lua/menu/menu_plugins.lua", branch)
    local count, expecting = 0, 0
    local updates = {} -- {name, current, new, source, changelog}

    local function cb(success, data)
        if success then
            table.insert(updates, data)
        end

        count = count + 1

        if count >= expecting then
            popup(updates)
        end
    end

    mprcheck(url, cb)
    if not menup.config.get(MANIFEST.id, "plugins", true) then return end

    for k, v in pairs(menup.plugins) do
        if not v.legacy and v.source and v.version then
            pcheck(k, cb)
            expecting = expecting + 1
        end
    end
end)