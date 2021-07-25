menup.toolbar = {}
menup.toolbar.buttons = {}

local dskin = derma.GetDefaultSkin()

local function BuildDrawer()
    local drawer = vgui.Create("DDrawer")
    drawer:SetOpenSize(50)
    drawer:SetOpenTime(.15)
    local scroller = drawer:Add("DHorizontalScroller")
    scroller:Dock(FILL)

    drawer.ToggleButton.Paint = function(pnl, w, h) dskin.tex.TabT_Active( 0, 0, w, h ) end
    drawer.ToggleButton.Think = function(pnl) pnl:CenterHorizontal() pnl.y = drawer.y - 10 end
    drawer.ToggleButton:SetText("  Plugin toolbar  ")
    drawer.ToggleButton:SizeToContents()
    scroller.Paint = function(pnl, w, h) dskin.tex.Tab_Control( 0, 0, w, h ) end
    -- scroller:GetCanvas():Dock(FILL)
    scroller:InvalidateLayout(true)

    drawer.scroller = scroller
    menup.toolbar.drawer = drawer

    menup.toolbar.add("", "Manage plugins", "icon16/plugin.png", ShowPluginsWindow)

    return drawer
end

function menup.toolbar.add(id, title, iconcb, cb)
    local btn = menup.toolbar.buttons[id] or vgui.Create("DButton")
    if not IsValid(menup.toolbar.buttons[id]) and IsValid(menup.toolbar.drawer) then
        menup.toolbar.buttons[id] = btn
        menup.toolbar.drawer.scroller:AddPanel(btn)
        btn:Dock(LEFT)
        btn:DockMargin(8, 8, 8, 8)
    end
    if isstring(iconcb) then
        btn:SetText("   " .. title)
        btn:SetImage(iconcb)
        btn.DoClick = cb
    else
        btn:SetText(title)
        btn.DoClick = iconcb
    end
    btn:SizeToContents()
end

function menup.toolbar.del(id)
    if IsValid(menup.toolbar.buttons[id]) then menup.toolbar.buttons[id]:Remove() end
    menup.toolbar.buttons[id] = nil
end

function menup.toolbar.setparent(pnl)
    local drawer = IsValid(menup.toolbar.drawer) and menup.toolbar.drawer or BuildDrawer()
    drawer:MakePopup()
    drawer.ToggleButton:MakePopup()
    drawer:SetParent(pnl)
end

function ShowPluginsDrawer()
    menup.toolbar.drawer:Toggle()
end

hook.Add("GameContentChanged","menup_button", function()
    hook.Remove("GameContentChanged", "menup_button")
    if pnlMainMenu and pnlMainMenu.HTML and vgui.GetControlTable("MainMenuPanel") then
        print("Pretty sure this is the default menu, injecting button!")
        pnlMainMenu.HTML:Call([[
        var navright = document.getElementById("NavBar").getElementsByClassName("right")[0];
        var container = document.createElement("span");
        container.setAttribute("id", "PluginsButton")
        navright.appendChild(container);
        container.innerHTML = `<li class="smallicon hidelabel" onclick="lua.Run('ShowPluginsWindow()')"><img src='asset://garrysmod/materials/icon16/plugin.png'><span>Plugins</span></li>`
        ]])
        menup.toolbar.setparent(pnlMainMenu)
    else
        print("Custom menu detected, open plugins window by running menu_plugins.")
    end
end)

concommand.Add("menu_toolbar", ShowPluginsDrawer)