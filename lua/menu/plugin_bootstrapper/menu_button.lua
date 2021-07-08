-- Adds a button to the default menu's toolbar.
hook.Add("GameContentChanged","menup_button", function()
    hook.Remove("GameContentChanged", "menup_button")
    if pnlMainMenu and pnlMainMenu.HTML and vgui.GetControlTable("MainMenuPanel") then
        print("Pretty sure this is the default menu, injecting button!")
        pnlMainMenu.HTML:Call([[
        var navright = document.getElementById("NavBar").getElementsByClassName("right")[0];
        var container = document.createElement("span");
        container.setAttribute("id", "PluginsButton")
        navright.appendChild(container);
        container.innerHTML = `<li class="smallicon hidelabel" onclick="lua.Run('TogglePuginsWindow()')"><img src='asset://garrysmod/materials/icon16/bricks.png'><span>Plugins</span></li>`
        ]])
    else
        print("Custom menu detected, open plugins window by running menu_plugins.")
    end
end)