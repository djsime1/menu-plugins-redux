local CONFIG = {
    amode = {
        "Loadingscreen type", "select", {"Use server loading screen", "Use GMod's loading screen", "Use custom URL"}
    },
    burl = {"Custom URL", "string", "", "Set first option to 'Use custom URL'."},
    csteamid = {"Override SteamID64", "string", "", "Leave blank to use your own."},
    dsound = {"Disable sounds", "bool", false, "*Attempts* to prevent sounds from playing."},
}

local MANIFEST = {
    id = "djsime1.loading_customizer",
    author = "djsime1 & Meepen",
    name = "Loading screen modifier",
    description = "Allows you to tweak the loading screen.  \nCode adapted from [Meepen's Loading Screen sound remover](https://forum.facepunch.com/t/loading-screen-sound-remover-clientside/194462) with permission.",
    version = "1.0",
    config = CONFIG
}

menup(MANIFEST)
local oldGD = GameDetails

function GameDetails(name, url, mapname, maxply, steamid, gamemode)
    url = ({
        url,
        GetDefaultLoadingHTML(),
        menup.config.get(MANIFEST.id, "burl", GetDefaultLoadingHTML())
    })[menup.config.get(MANIFEST.id, "amode", 1)]

    steamid = menup.config.get(MANIFEST.id, "csteamid", "") == "" and steamid or menup.config.get(MANIFEST.id, "csteamid", steamid)

    return oldGD(name, url, mapname, maxply, steamid, gamemode)
end

-- The following is adapted from https://forum.facepunch.com/t/loading-screen-sound-remover-clientside/194462 with permission from Meepen.
local loadp
local old_showurl
local javascript = [[
    var amount = 0;
    function DeleteAll(name) {
        var all = document.getElementsByTagName(name);
        for(var i = 0; i < all.length; i++) {
            amount = amount + 1;
            all*.parentElement.removeChild(all*);
        }
    }
    DeleteAll("iframe");
    DeleteAll("audio");
    DeleteAll("source");
]]
local overwrite = [[
    var old = document.createElement;
    document.createElement = function(tagname) {
        tagname = tagname.toLowerCase();
        if(tagname === "iframe" || tagname === "audio" || tagname === "source") {
            return; // sorry i am too lazy to redirect this to our stuff
        }
        return old(tagname);
    };
]]
local hasoverwritten = false

local function ThinkLoad()
    if not IsValid(loadp) then
        hook.Remove("Think", MANIFEST.id)

        return
    end

    if not IsValid(loadp.HTML) then return end -- wait for it

    if hasoverwritten == false then
        loadp.HTML:RunJavascript(overwrite)
        hasoverwritten = true
    end

    if loadp.HTML:IsLoading() then return end -- wait for the load!
    loadp.HTML:RunJavascript(javascript)
    hook.Remove("Think", MANIFEST.id)
end

local function ApplyMute()
    if isfunction(GetLoadPanel) and ispanel(GetLoadPanel()) then
        loadp = GetLoadPanel()
        old_showurl = loadp.ShowURL

        function loadp:ShowURL(a, b, c, d, e, f)
            local ret = old_showurl(self, a, b, c, d, e, f)
            hasoverwritten = false
            hook.Add("Think", MANIFEST.id, ThinkLoad)

            return ret
        end

        print("Now muting loading screen.")
    else
        print("Unable to find loading panel, sounds will not be muted.")
    end
end

hook.Add("MenuVGUIReady", MANIFEST.id, function()
    if menup.config.get(MANIFEST.id, "dsound", false) then
        ApplyMute()
    end
end)

hook.Add("ConfigApply", MANIFEST.id, function(id)
    if id ~= MANIFEST.id then return end

    if menup.config.get(MANIFEST.id, "dsound", false) then
        ApplyMute()
    else
        if ispanel(loadp) then
            loadp.ShowURL = old_showurl
        end
    end
end)

return function()
    GameDetails = oldGD

    if ispanel(loadp) then
        loadp.ShowURL = old_showurl
    end

    hook.Remove("Think", MANIFEST.id)
end