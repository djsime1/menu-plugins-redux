local InfoPanel = table.Copy(vgui.GetControlTable("DPanel"))

function InfoPanel:Init()
    self:SetTall(512)
    self:SetPaintBackground(false)
    local controls = self:Add("DPanel")
    controls:SetPaintBackground(false)
    controls:Dock(TOP)
    controls:SetTall(36)
    local toggle = controls:Add("DButton")
    local alt = controls:Add("DButton")
    local md = self:Add("MarkdownPanel")
    md:SetPos(0, 32)
    md:SetTall(512)
    self.controls = controls
    self.toggle = toggle
    self.alt = alt
    self.md = md
end

function InfoPanel:Think()
    local w = self.controls:GetWide()
    local h = self:GetParent():GetParent():GetParent():GetTall() - 56 -- info collapse list sheet frame
    self.toggle:SetWide(w / 2)
    self.alt:SetWide(w / 2)
    self.md:SetWide(w)
    self.md:SetTall(h)
    self.alt:SetPos(w / 2, 0)
end

function InfoPanel:SetEnabled(state)
    local plugs = util.JSONToTable(menup.db.get("enabled", "{}"))
    local manifest = self.manifest
    manifest.enabled = state
    plugs[manifest.id] = state
    menup.db.set("enabled", util.TableToJSON(plugs, false))
    if state then
        local success, result = pcall(manifest.func)
        if not success then
            ErrorNoHalt("Error loading " .. manifest.id .. ":\n" .. result)
        elseif isfunction(result) then
            manifest.undo = result
        else
            manifest.undo = function() end
        end
    else manifest.undo() end
    self:GetParent().toggle:SetChecked(state)
    self:Load(manifest)
end

function InfoPanel:Load(manifest)
    self.manifest = manifest
    self.md:SetMarkdown(string.format([[
## %s
%s  
## 
*Author* : %s  
*Version* : %s  
*ID* : `%s`  
*File* : `%s`  
]], manifest.name, manifest.description, manifest.author, manifest.version, manifest.id, manifest.file))
    if manifest.enabled then
        self.toggle:SetText("Disable")
        self.toggle:SetIcon("icon16/delete.png")
        self.alt:SetText("Config")
        self.alt:SetIcon("icon16/cog.png")
        self.alt:SetEnabled(!table.IsEmpty(manifest.config))
    else
        self.toggle:SetText("Enable")
        self.toggle:SetIcon("icon16/add.png")
        self.alt:SetText("Reset")
        self.alt:SetIcon("icon16/control_repeat.png")
        self.alt:SetEnabled(true)
    end
    self.toggle.DoClick = function() self:SetEnabled(!manifest.enabled) end
end

local PANEL = {}

function PANEL:Init()
    local new, legacy = {}, {}
    local lcollapse
    self.plugins = {}

    self:SetPaintBackground(false)

    for _, v in SortedPairsByMemberValue(menup.plugins, "name") do
        if v.legacy then table.insert(legacy, v)
        else table.insert(new, v) end
    end

    for _, v in ipairs(new) do
        local collapse = self:Add("     " .. v.name)
        local toggle = collapse.Header:Add("DCheckBox")
        toggle:SetPos(2, 2)
        toggle:SetChecked(v.enabled)
        local info = vgui.CreateFromTable(InfoPanel, collapse)
        collapse:SetContents(info)
        collapse:SetExpanded(false)
        function collapse.OnToggle(me, state)
            if !state then return end
            for _, c in pairs(self:GetChildren()[1]:GetChildren()) do
                if c ~= me then c:DoExpansion(false) end
            end
            timer.Simple(me:GetAnimTime(), function() self:ScrollToChild(collapse) end)
        end
        function toggle:OnChange(state)
            info:SetEnabled(state)
        end
        info:Load(v)
        collapse.toggle = toggle
        collapse.info = info
        self.plugins[v.id] = collapse
    end

    if !table.IsEmpty(legacy) then
        lcollapse = self:Add("Legacy plugins")
        lcollapse:SetExpanded(false)
        function lcollapse.OnToggle(me, state)
            if !state then return end
            for _, c in pairs(self:GetChildren()[1]:GetChildren()) do
                if c ~= me then c:DoExpansion(false) end
            end
            timer.Simple(me:GetAnimTime(), function() self:ScrollToChild(lcollapse) end)
        end

        for _, v in ipairs(legacy) do
            local btn = lcollapse:Add(v.name)
        end
    end
end

function PANEL:Paint() end

vgui.Register("PluginsPanel", PANEL, "DCategoryList")