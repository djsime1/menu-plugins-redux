local PANEL = {}

function PANEL:Init()
    self:SetSize(400, 600)
    --self:SetSize(ScrW() * 0.4, ScrH() * 0.6)
    self:Center()
    self:SetMinimumSize(400, 600)
    self:DockPadding(5, 3, 5, 3)
    self:SetTitle("")
    self:SetDraggable(true)
    self:SetScreenLock(true)
    self:SetSizable(true)
    local tabs = vgui.Create("DPropertySheet", self)
    tabs:Dock(FILL)
    tabs:SetFadeTime(0)
    self.tabs = tabs
    local plist = self:Add("PluginsPanel")
    tabs:AddSheet("Installed plugins", plist, "icon16/box.png")
    self.plist = plist
    local find = vgui.Create("DPanel")
    tabs:AddSheet("Find more", find, "icon16/add.png")
    local openrepo = find:Add("DButton")
    openrepo:Dock(BOTTOM)
    openrepo:SetText("Open repository")
    openrepo:SetIcon("icon16/folder_go.png")
    openrepo.DoClick = function()
        gui.OpenURL("https://github.com/djsime1/redux-plugins/")
    end
    local fm = find:Add("MarkdownPanel")
    fm:Dock(FILL)
    fm:SetMarkdown([[# Sorta W.I.P.
Eventually this screen will automagically list all avilable plugins from the public repository.
However, that hasn't been set up yet.
Click the button at the bottom of this window to open the repository URL and browse the plugins.
]])
    find:SetPaintBackground(false)
    self.find = find
    local about = self:Add("MarkdownPanel")
    tabs:AddSheet("About/Credits", about, "icon16/information.png")
    about:SetMarkdown(([[# Menu Plugins *Redux*
Version %s  : :  [GitHub](https://github.com/djsime1/menu-plugins-redux)

## About
This modification was written to enable the usage of menu plugins.  
They're like addons, but for the main/pause menu.  
The Redux version extends the existing Menu Plugins framework while retaining compatibility with existing scripts.  
Want to make your own menu plugin? Check out [the wiki](https://github.com/djsime1/menu-plugins-redux/wiki).

## Changelog
%s

## Credits
- *[djsime1](https://github.com/djsime1)* : Lead author of this mess.  
- *[GLua team](https://github.com/glua)* : Original menu plugins.  
- *[mpeterv](https://github.com/mpeterv)* : markdown.lua.  
- *[markdowncss](https://github.com/markdowncss)* : Modest CSS.  
- *[vercas](https://github.com/vercas)* : vON.  
- *[Garry](https://garry.tv)* : Obligatory thanks.  
- *[You](https://steamcommunity.com/my)* : For being epic **<3**  

## Licenses
[MPR is licensesd under the MIT license](https://github.com/djsime1/menu-plugins-redux/blob/dev/LICENSE).  
In addition, the following licenses apply to libraries/code used within MPR:  
- [markdown.lua](https://github.com/mpeterv/markdown) : [MIT license](https://github.com/mpeterv/markdown/blob/master/LICENSE).  
- [Modest CSS](https://github.com/markdowncss/modest) : [MIT license](https://github.com/markdowncss/modest/blob/master/LICENSE).  
- [vON](https://github.com/vercas/vON) :[Read here](https://github.com/vercas/vON/blob/master/von.lua#L1:L23).  
]]):format(menup.version, menup.changelog))
    self.about = about
    self.btnClose:MoveToFront()
    self.btnMaxim:Hide()
    self.btnMinim:Hide()
end

function PANEL:Paint(w, h)
end

vgui.Register("PluginsWindow", PANEL, "DFrame")

function ShowPluginsWindow()
    PluginsWindow = IsValid(PluginsWindow) and PluginsWindow or vgui.Create("PluginsWindow")
    PluginsWindow:Center()
    PluginsWindow:SetZPos(9001)
    PluginsWindow:MakePopup()
end

function DoMenuButton()
    if table.Count(menup.drawer.buttons) == 0 then ShowPluginsWindow() else menup.drawer.open() end
end

-- concommand.Add("menu_plugins", ShowPluginsWindow)