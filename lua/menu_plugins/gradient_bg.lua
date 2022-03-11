-- alphabetically sorted
local CONFIG = {
    afade = {
        "Gradient speed", "range", {.1, 3, 1},
        "Speed at which colors change"
    },
    btext = {"Background texts", "list", {}, "One is selected at random."},
    cschmoove = {
        "Schmoove speed", "range", {.5, 4, 1},
        "Speed at which text waves."
    },
    dsize = {"Font size", "int", 0, "0 for automatic."},
    eingame = {"Show text ingame", "bool", false, "Should text be visible on the pause menu during gameplay?"},
    fcolor = {
        "In-game color", "color", {255, 255, 255, 160},
        "Only works if the above option is enabled."
    },
}

local MANIFEST = {
    id = "djsime1.gradient_bg",
    author = "djsime1",
    name = "Background customizer",
    description = "Allows you to change how your menu background looks.",
    version = "1.6",
    config = CONFIG
}

menup(MANIFEST)
local grad = Material("gui/gradient", "nocull smooth")
local r1, r2, r3, r4 = math.random(0, 359), math.random(0, 359), math.random(0, 359), math.random(0, 359)
local fade = 1
local OldDrawBackground = DrawBackground

local function reload()
    local fspeed = menup.config.get(MANIFEST.id, "afade", 1)
    local bgtxt = menup.config.get(MANIFEST.id, "btext", {})
    local tspeed = menup.config.get(MANIFEST.id, "cschmoove", 1)
    local size = menup.config.get(MANIFEST.id, "dsize", 0)
    local doingame = menup.config.get(MANIFEST.id, "eingame", false)
    local ingamecolor = menup.config.get(MANIFEST.id, "fcolor", Color(255, 255, 255, 160))

    if isstring(bgtxt) then
        menup.config.set(MANIFEST.id, "btext", {bgtxt})
    else
        bgtxt = table.Random(bgtxt) or ""
    end

    size = size > 0 and size or 96 * (ScrH() / 480)

    surface.CreateFont("GradientText", {
        font = "Coolvetica",
        size = size,
        weight = 400
    })

    surface.SetFont("GradientText")
    local bgtxtx, bgtxty = surface.GetTextSize(bgtxt)

    function DrawBackground()
        local w, h = ScrW(), ScrH()
        local t = SysTime() * fspeed

        if not IsInGame() then
            surface.SetTextColor(0, 0, 0, 96)
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(-1, -1, w + 2, h + 2)
            fade = 1
        else
            surface.SetTextColor(ingamecolor.r, ingamecolor.g, ingamecolor.b, ingamecolor.a)
            fade = 0
        end

        if IsInGame() and not doingame then return end
        surface.SetMaterial(grad)
        surface.SetAlphaMultiplier(1 * fade)
        surface.SetDrawColor(HSVToColor(t * 20 + r1, 1, .9))
        surface.DrawTexturedRectRotated(w / 2, h / 2, w + 2, h + 2, 0)
        surface.SetAlphaMultiplier(0.75 * fade)
        surface.SetDrawColor(HSVToColor(t * 15 + r2, 1, .9))
        surface.DrawTexturedRectRotated(w / 2, h / 2, h + 2, w + 2, 90)
        surface.SetAlphaMultiplier(0.50 * fade)
        surface.SetDrawColor(HSVToColor(t * 10 + r3, 1, .9))
        surface.DrawTexturedRectRotated(w / 2, h / 2, w + 2, h + 2, 180)
        surface.SetAlphaMultiplier(0.25 * fade)
        surface.SetDrawColor(HSVToColor(t * 5 + r4, 1, .9))
        surface.DrawTexturedRectRotated(w / 2, h / 2, h + 2, w + 2, 270)
        surface.SetAlphaMultiplier(1)
        t = SysTime() * tspeed
        surface.SetFont("GradientText")
        local x = (w / 2) - (bgtxtx / 2)

        for i = 1, #bgtxt do
            surface.SetTextPos(x, (h / 2) - (bgtxty / 2) + (math.sin(math.rad((i * 20) - (t * 60))) * 32))
            surface.DrawText(bgtxt[i])
            x = x + surface.GetTextSize(bgtxt[i])
        end
    end
end

hook.Add("ConfigApply", MANIFEST.id, function(id)
    if id == MANIFEST.id then
        reload()
    end
end)

if IsValid(pnlMainMenu) then
    reload()
else
    hook.Add("MenuVGUIReady", MANIFEST.id, function()
        OldDrawBackground = DrawBackground
        reload()
    end)
end

return function()
    DrawBackground = OldDrawBackground
end