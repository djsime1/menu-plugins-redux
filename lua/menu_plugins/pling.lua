local CONFIG = {
    sound = {"Sound path", "string", "garrysmod/content_downloaded.wav"},
    asound = {"Alert with sound", "bool", true},
    aflash = {"Alert with taskbar flash", "bool", true},
    onlaunch = {
        "Notify on launch...", "select", {"When menu is loaded", "When workshop is complete", "Never"}
    },
    onjoin = {
        "Notify on join... (Doesn't work yet)", "select", {"When spawned in server", "When lua started", "When FPS stabilizes", "Never"}
    },
}

local MANIFEST = {
    id = "djsime1.pling",
    author = "djsime1",
    name = "Pling!",
    description = "Allows you to be notified when GMod finishes loading, or when you fully load into a server.",
    version = "1.0",
    config = CONFIG
}

menup(MANIFEST)

local function apply()
    local soundfile = menup.config.get(MANIFEST.id, "sound", "garrysmod/content_downloaded.wav")
    local asound = menup.config.get(MANIFEST.id, "asound", true)
    local aflash = menup.config.get(MANIFEST.id, "aflash", true)
    local onlaunch = menup.config.get(MANIFEST.id, "onlaunch", 1)
    local onjoin = menup.config.get(MANIFEST.id, "onjoin", 1)

    local function alert()
        if asound then surface.PlaySound(soundfile) end
        if aflash then system.FlashWindow() end
        print("Pling!")
    end

    local launchfuncs = {
        function() -- When menu is loaded
            hook.Add("GameContentChanged", "PlingMainMenu", function()
                hook.Remove("GameContentChanged", "PlingMainMenu")
                timer.Simple(1, alert)
            end)
        end,
        function() -- When workshop is complete
            hook.Add("WorkshopEnd", "PlingWorkshop", function()
                if IsInGame() then return end
                timer.Simple(0, alert)
            end)
        end,
        function() end -- Never
    }

    local joinfuncs = {
        
    }

    launchfuncs[onlaunch]()

end

apply()

hook.Add("ConfigApply", "GradientBackgroundReload", function(id)
    if id == MANIFEST.id then
        apply()
        surface.PlaySound(menup.config.get(MANIFEST.id, "sound", "garrysmod/content_downloaded.wav"))
    end
end)

return function()
    hook.Remove("GameContentChanged", "PlingMainMenu")
    hook.Remove("WorkshopEnd", "PlingWorkshop")
end