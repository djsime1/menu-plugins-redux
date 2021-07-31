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
    local resetwip = find:Add("DButton")
    resetwip:Dock(BOTTOM)
    resetwip:SetText("Reset")
    local wip = find:Add("WIPFrame")
    wip:Dock(FILL)
    find.Paint = function() end

    resetwip.DoClick = function()
        for k, v in ipairs(wip.bouncies) do
            v:Remove()
            wip.bouncies[k] = nil
        end

        wip:AddBouncy()
    end

    find.resetwip = resetwip
    find.wip = wip
    self.find = find
    local about = self:Add("MarkdownPanel")
    tabs:AddSheet("About/Credits", about, "icon16/information.png")
    about:SetMarkdown([[
# Menu Plugins *Redux*

## About
This modification was written to enable the usage of menu plugins.  
They're like addons, but for the main/pause menu.  
The Redux version extends the existing Menu Plugins framework while retaining compatibility with existing scripts.  

## Credits
- *[djsime1](https://dj.je)* : Authoring the majority of this.  
- *[GLua team](https://github.com/glua)* : Original menu plugins.  
- *[mpeterv](https://github.com/mpeterv)* : markdown.lua.  
- *[markdowncss](https://github.com/markdowncss)* : Modest CSS.  
- *[Garry](https://garry.tv)* : Obligatory thanks.  
- *[You](https://steamcommunity.com/my)* : For being epic **<3**  
]])
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

concommand.Add("menu_plugins", ShowPluginsWindow)