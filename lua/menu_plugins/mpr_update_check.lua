local CONFIG = {
    channel = {"Update channel", "select", {"Stable", "Beta"}, "Beta has more frequent updates, but may contain bugs."},
}

local MANIFEST = {
    id = "djsime1.update_check",
    author = "djsime1",
    name = "MPR Update checker",
    description = "Notifies when a new version of MPR is available.",
    version = "1.0",
    config = CONFIG,
}

menup(MANIFEST)

// turns a semantaic version string into a number
local function vnum(version)
    local major, minor, patch = version:match("(%d+)%.(%d+)%.(%d+)")
    return tonumber(major) * 1000000 + tonumber(minor) * 1000 + tonumber(patch)
end

local branch = ({"main", "dev"})[menup.config.get(MANIFEST.id, "channel", 1)]
local url = string.format("https://raw.githubusercontent.com/djsime1/menu-plugins-redux/%s/lua/menu/menu_plugins.lua", branch)
print("Checking for MPR updates on the " .. branch .. " branch...")

http.Fetch(url, function(body)
    local ver, changelog = body:match("menup%.version = \"(%d+%.%d+%.%d+)\""), body:match("menup%.changelog = %[%[\n?(.-)\n?]]") or "No changelog."
    if not ver then print("MPR update check failed. (Couldn't find version string)") return end
    local cur, new = vnum(ver), vnum(menup.version)
    if new >= cur then
        print(string.format("MPR update avilable, %s -> %s", menup.version, ver))
        local frame = vgui.Create("DFrame")
        frame:SetSize(800, 600)
        frame:Center()
        frame:SetTitle("Update available!")
        local md = frame:Add("MarkdownPanel")
        md:SetMarkdown(string.format([[# MPR Update available!
Menu Plugins *Redux* version **%s** is now available, you are currently running version **%s**.
## Changelog
%s]], ver, menup.version, changelog))
        md:Dock(FILL)
        frame:MakePopup()
    else
        print("You are running the latest version of MPR.")
    end
end,
function(err)
    print("MPR update check failed. (" .. err .. ")")
end)