menup.drawer = {}
menup.drawer.buttons = {}

function menup.drawer.add(id, title, cb, icon)
    menup.drawer.buttons[id] = {title, cb, icon}
end

function menup.drawer.del(id)
    menup.drawer.buttons[id] = nil
end

function menup.drawer.open(x, y)
    local dm = DermaMenu()

    for k, v in SortedPairs(menup.drawer.buttons) do
        local btn = dm:AddOption(v[1], v[2])

        if v[3] then
            btn:SetIcon(v[3])
        end
    end

    dm:AddSpacer()
    dm:AddOption("Manage plugins", ShowPluginsWindow):SetIcon("icon16/plugin_edit.png")

    if x and y then
        dm:Open(x, y)
    else
        dm:Open()
    end
end

hook.Add("DrawOverlay", "menup_button", function()
    hook.Remove("DrawOverlay", "menup_button")
    hook.Run("MenuVGUIReady")

    if pnlMainMenu and pnlMainMenu.HTML and vgui.GetControlTable("MainMenuPanel") then
        print("Pretty sure this is the default menu, injecting button!")
        pnlMainMenu.HTML:Call([[
        var navright = document.getElementById("NavBar").getElementsByClassName("right")[0];
        var container = document.createElement("span");
        container.setAttribute("id", "PluginsButton")
        navright.appendChild(container);
        container.innerHTML = `<li class="smallicon hidelabel" onclick="lua.Run('if table.Count(menup.drawer.buttons) == 0 then ShowPluginsWindow() else menup.drawer.open() end')"><img src='asset://garrysmod/materials/icon16/plugin.png'><span>Plugins</span></li>`
        ]])
    else
        print("Custom menu detected, open plugins window by running menu_plugins.")
    end
end)

-- concommand.Add("menup_drawer", menup.drawer.open)