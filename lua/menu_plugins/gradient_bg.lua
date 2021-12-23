-- alphabetically sorted
local CONFIG = {
    afade = {
        "Fade speed", "range", {.1, 3, 1},
        "Speed at which colors change"
    },
    btext = {"Background text", "string", ""},
    cschmoove = {
        "Schmoove speed", "range", {.5, 4, 1},
        "Speed at which text waves"
    },
    dsize = {"Font size", "int", 0, "0 for automatic"},
    eingame = {"Show text ingame", "bool", false}
}

local MANIFEST = {
    id = "djsime1.gradient_bg",
    author = "djsime1",
    name = "Background customizer",
    description = "Replaces menu background with gradients & custom text.",
    version = "1.2",
    config = CONFIG
}

menup(MANIFEST)
local grad = Material("gui/gradient", "nocull smooth")
local r1, r2, r3, r4 = math.random(0, 359), math.random(0, 359), math.random(0, 359), math.random(0, 359)
local fade = 1
OldDrawBackground = DrawBackground
local function reload()
    local fspeed = menup.config.get(MANIFEST.id, "afade", 1)
    local bgtxt = menup.config.get(MANIFEST.id, "btext", "")
    local tspeed = menup.config.get(MANIFEST.id, "cschmoove", 1)
    local size = menup.config.get(MANIFEST.id, "dsize", 0)
    local doingame = menup.config.get(MANIFEST.id, "eingame", false)
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
            surface.SetTextColor(255, 255, 255, 160)
            fade = 0
        end

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
        if IsInGame() and not doingame then return end
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

hook.Add("ConfigApply", "GradientBackgroundReload", function(id)
    if id == MANIFEST.id then reload() end
end)

reload()

return function()
    DrawBackground = OldDrawBackground
end