local CONFIG = {
    sound = {"Sound path", "file", {"sound", "*", "garrysmod/content_downloaded.wav"}},
    asound = {"Alert with sound", "bool", true},
    aflash = {"Alert with taskbar flash", "bool", true},
    onlaunch = {
        "Notify on launch...", "select", {"When menu is loaded", "When workshop is complete", "Never"}
    },
    onjoin = {
        "Notify on join... ", "select", {"When spawned in server", "When lua started", "When FPS stabilizes", "Never"}
    },
}

local MANIFEST = {
    id = "djsime1.pling",
    author = "djsime1",
    name = "Pling!",
    description = "Allows you to be notified when GMod finishes loading, or when you fully load into a server.",
    version = "1.2",
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
        if asound then
            surface.PlaySound(soundfile)
        end

        if aflash then
            system.FlashWindow()
        end

        print("Pling!")
    end

    hook.Remove("MenuStart", MANIFEST.id)
    hook.Remove("WorkshopEnd", MANIFEST.id)
    hook.Remove("CaptureVideo", MANIFEST.id)
    timer.Remove(MANIFEST.id)

    local launchfuncs = {
        function() -- When menu is loaded
            hook.Add("MenuStart", MANIFEST.id, function()
                alert()
            end)
        end,
        function() -- When workshop is complete
            hook.Add("WorkshopEnd", MANIFEST.id, function()
                if IsInGame() then return end
                timer.Simple(1, alert)
            end)
        end,
        function() end -- Never
    }

    local joinfuncs = {
        function() -- When spawned in server
            local wasingame = false

            timer.Create(MANIFEST.id, 1, 0, function()
                if IsInGame() == true and wasingame == false then
                    alert()
                end
                wasingame = IsInGame()
            end)
        end,
        function() -- When lua started
            local loadstatus = ""

            hook.Add("CaptureVideo", MANIFEST.id, function()
                if GetLoadStatus() == "Lua Started!" and loadstatus ~= "Lua Started!" then -- TODO: Localize
                    alert()
                end

                loadstatus = GetLoadStatus()
            end)
        end,
        function() -- When FPS stabilizes
            local wasingame = false

            timer.Create(MANIFEST.id, 1, 0, function()
                if IsInGame() == true and wasingame == false then
                    local fps = {}

                    hook.Add("CaptureVideo", MANIFEST.id, function()
                        if not IsInGame() then return end
                        local sum = 0
                        table.insert(fps, 1, 1 / FrameTime())
                        fps[30] = nil

                        for i = 1, #fps do
                            sum = sum + fps[i]
                        end

                        if #fps < 20 then return end

                        if math.abs((sum / 30) - (1 / FrameTime())) <= 5 then
                            hook.Remove("CaptureVideo", MANIFEST.id)
                            alert()
                        end
                    end)
                end

                wasingame = IsInGame()
            end)
        end,
        function() end -- Never
    }

    launchfuncs[onlaunch]()
    joinfuncs[onjoin]()
end

apply()

hook.Add("ConfigApply", "GradientBackgroundReload", function(id)
    if id == MANIFEST.id then
        apply()
        surface.PlaySound(menup.config.get(MANIFEST.id, "sound", "garrysmod/content_downloaded.wav"))
    end
end)

return function()
    hook.Remove("MenuStart", MANIFEST.id)
    hook.Remove("WorkshopEnd", MANIFEST.id)
    hook.Remove("CaptureVideo", MANIFEST.id)
    timer.Remove(MANIFEST.id)
end