local MANIFEST = {
    id = "djsime1.gradient_bg",
    author = "djsime1",
    name = "Background gradients",
    description = "Replaces menu background with gradients.",
    version = "1.0"
}

menup(MANIFEST)

local grad = Material("gui/gradient", "nocull smooth")
local r1, r2, r3, r4 = math.random(0, 359), math.random(0, 359), math.random(0, 359), math.random(0, 359)
local fade = 1

function DrawBackground()
    local w, h = ScrW(), ScrH()
    local t = SysTime()

    if not IsInGame() then
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(-1, -1, w + 2, h + 2)
        fade = 1
    else
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
end