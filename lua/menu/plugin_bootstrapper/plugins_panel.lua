local InfoPanel = table.Copy(vgui.GetControlTable("DPanel"))

local function LegacyConfig(v)
    local dm = DermaMenu()

    for i, _ in pairs(v.config) do
        local x = menup.config.get(v.id, i)
        local cv = dm:AddOption(i)

        cv.DoClick = function()
            Derma_StringRequest("Change option", v.name .. "." .. i .. " = " .. tostring(x), tostring(x), function(txt)
                menup.config.set(v.id, i, tonumber(txt) == nil and txt or tonumber(txt))
            end)
        end

        if x == "true" or x == 1 or x == true then
            cv:SetIcon("icon16/tick.png")
        elseif x == "false" or x == 0 or x == false then
            cv:SetIcon("icon16/cross.png")
        else
            cv:SetIcon("icon16/pencil.png")
        end
    end

    dm:Open()
end

local cfpnls = {
    bool = function(id, key, data)
        local val = menup.config.get(id, key, isbool(data[3]) and data[3] or false)
        local root = vgui.Create("DPanel")
        local label = root:Add("DLabel")
        local cb = root:Add("DCheckBox")

        if isstring(data[4]) then
            root:SetTooltip(data[4])
        end

        cb:Dock(RIGHT)
        cb:SetWide(15)
        cb:SetChecked(val)
        label:Dock(FILL)
        label:SetText(data[1])
        label:SetTextColor(Color(0, 0, 0))

        cb.OnChange = function(pnl, newval)
            menup.config.set(id, key, newval)
        end

        return root
    end,
    int = function(id, key, data)
        local val = menup.config.get(id, key, isnumber(data[3]) and data[3] or 0)
        local root = vgui.Create("DPanel")
        local label = root:Add("DLabel")
        local wang = root:Add("DNumberWang")

        if isstring(data[4]) then
            root:SetTooltip(data[4])
        end

        wang:Dock(RIGHT)
        wang:SetWide(96)
        wang:SetDecimals(0)
        wang:SetMin(-math.huge)
        wang:SetMax(math.huge)
        wang:SetValue(val)
        label:Dock(FILL)
        label:SetText(data[1])
        label:SetTextColor(Color(0, 0, 0))

        wang.OnValueChanged = function(pnl, newval)
            newval = math.Round(newval)
            wang:SetText(tostring(newval))
            menup.config.set(id, key, newval)
        end

        return root
    end,
    float = function(id, key, data)
        local val = menup.config.get(id, key, isnumber(data[3]) and data[3] or 0)
        local root = vgui.Create("DPanel")
        local label = root:Add("DLabel")
        local wang = root:Add("DNumberWang")

        if isstring(data[4]) then
            root:SetTooltip(data[4])
        end

        wang:Dock(RIGHT)
        wang:SetWide(96)
        wang:SetMin(-math.huge)
        wang:SetMax(math.huge)
        wang:SetValue(val)
        label:Dock(FILL)
        label:SetText(data[1])
        label:SetTextColor(Color(0, 0, 0))

        wang.OnValueChanged = function(pnl, newval)
            menup.config.set(id, key, newval)
        end

        return root
    end,
    range = function(id, key, data)
        local min, max, default = data[3][1], data[3][2], data[3][3]
        min = (min ~= nil and min or 0)
        max = (max ~= nil and max or 100)
        local val = menup.config.get(id, key, isnumber(default) and default or 0)
        local root = vgui.Create("DPanel")
        local slider = root:Add("DNumSlider")

        if isstring(data[4]) then
            root:SetTooltip(data[4])
        end

        slider:Dock(FILL)
        slider:SetDecimals(3)
        slider:SetMinMax(min, max)
        slider:SetValue(val)
        slider:SetText(data[1])
        slider:SetDark(true)

        slider.OnValueChanged = function(pnl, newval)
            menup.config.set(id, key, newval)
        end

        return root
    end,
    string = function(id, key, data)
        local val = menup.config.get(id, key, isstring(data[3]) and data[3] or "")
        local root = vgui.Create("DPanel")
        local label = root:Add("DLabel")
        local tbox = root:Add("DTextEntry")

        if isstring(data[4]) then
            root:SetTooltip(data[4])
        end

        root:SetTall(48)
        tbox:Dock(BOTTOM)
        tbox:SetText(val)
        tbox:SetPlaceholderText(isstring(data[3]) and data[3])
        label:Dock(FILL)
        label:SetText(data[1])
        label:SetTextColor(Color(0, 0, 0))

        tbox.OnLoseFocus = function(pnl)
            menup.config.set(id, key, pnl:GetText())
        end

        return root
    end,
    select = function(id, key, data)
        local val = menup.config.get(id, key, isnumber(data[3][1]) and data[3][1] or 1)
        local root = vgui.Create("DPanel")
        local label = root:Add("DLabel")
        local combo = root:Add("DComboBox")

        if isstring(data[4]) then
            root:SetTooltip(data[4])
        end

        root:SetTall(48)
        combo:Dock(BOTTOM)
        combo:SetSortItems(false)

        for _, txt in ipairs(data[3]) do
            if txt == "" then
                combo:AddSpacer()
            else
                combo:AddChoice(txt)
            end
        end

        combo:ChooseOptionID(val)
        label:Dock(FILL)
        label:SetText(data[1])
        label:SetTextColor(Color(0, 0, 0))

        combo.OnSelect = function(pnl, newval)
            menup.config.set(id, key, newval)
        end

        return root
    end,
}

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
    local cp = self:Add("DScrollPanel")
    md:SetPos(0, 32)
    md:SetTall(512)
    cp:SetPos(self:GetWide(), 32)
    cp:SetTall(512)
    self.controls = controls
    self.toggle = toggle
    self.alt = alt
    self.md = md
    self.cp = cp
    self.scroll = 0
    self.target = 0
end

function InfoPanel:Think()
    local w = self.controls:GetWide()
    local h = self:GetParent():GetParent():GetParent():GetTall() - 56 -- info collapse list sheet frame
    self.scroll = Lerp(FrameTime() * 10, self.scroll, self.target)
    local s = self.scroll
    self.toggle:SetWide(w / 2)
    self.alt:SetWide(w / 2)
    self.md:SetSize(w, h)
    self.cp:SetSize(w, h)
    self.alt:SetPos(w / 2, 0)
    self.md:SetPos(-w * s, 32)
    self.cp:SetPos((1 - s) * w, 32)
end

function InfoPanel:SetEnabled(state)
    local plugs = util.JSONToTable(menup.db.get("enabled", "{}"))
    local manifest = self.manifest
    self.target = 0
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
    else
        manifest.undo()
    end

    self:GetParent().toggle:SetChecked(state)
    self:Load(manifest)
end

function InfoPanel:BuildConfig(manifest)
    self.cp:Clear()

    -- name type param desc
    for k, v in SortedPairsByMemberValue(manifest.config, 1) do
        if isfunction(cfpnls[v[2]]) then
            local pnl = cfpnls[v[2]](manifest.id, k, v)
            self.cp:AddItem(pnl)
            pnl:Dock(TOP)
            pnl:DockPadding(4, 4, 4, 4)
            pnl:DockMargin(0, 2, 0, 2)
        else
            print(manifest.id .. " has unknown config type \"" .. v[2] .. "\" for key \"" .. k .. "\"!")
        end
    end
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
        self.alt:SetEnabled(not table.IsEmpty(manifest.config))
    else
        self.toggle:SetText("Enable")
        self.toggle:SetIcon("icon16/add.png")
        self.alt:SetText("Reset")
        self.alt:SetIcon("icon16/control_repeat.png")
        self.alt:SetEnabled(true)
    end

    self.toggle.DoClick = function(pnl)
        self:SetEnabled(not manifest.enabled)
    end

    self.alt.DoClick = function(pnl)
        -- goto config
        if manifest.enabled and self.target == 0 then
            self:BuildConfig(manifest)
            self.target = 1
            self.alt:SetText("Description")
            self.alt:SetIcon("icon16/text_dropcaps.png")
        elseif manifest.enabled and self.target == 1 then
            -- goto description
            self.target = 0
            self.alt:SetText("Config")
            self.alt:SetIcon("icon16/cog.png")
        else -- reset
            Derma_Query("Are you sure you want to reset this plugins config & store?", "Confirmation", "Yes", function()
                menup.db.del("data_" .. manifest.id)
            end, "No")
        end
    end
end

local PANEL = {}

function PANEL:Init()
    local new, legacy = {}, {}
    local lcollapse
    self.plugins = {}
    self:SetPaintBackground(false)

    for _, v in SortedPairsByMemberValue(menup.plugins, "name") do
        if v.legacy then
            table.insert(legacy, v)
        else
            table.insert(new, v)
        end
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
            if not state then return end

            for _, c in pairs(self:GetChildren()[1]:GetChildren()) do
                if c ~= me then
                    c:DoExpansion(false)
                end
            end

            timer.Simple(me:GetAnimTime(), function()
                self:ScrollToChild(collapse)
            end)
        end

        function toggle:OnChange(state)
            info:SetEnabled(state)
        end

        info:Load(v)
        collapse.toggle = toggle
        collapse.info = info
        self.plugins[v.id] = collapse
    end

    if not table.IsEmpty(legacy) then
        lcollapse = self:Add("Legacy plugins")
        lcollapse:SetExpanded(false)

        lcollapse.OnToggle = function(me, state)
            if not state then return end

            for _, c in pairs(self:GetChildren()[1]:GetChildren()) do
                if c ~= me then
                    c:DoExpansion(false)
                end
            end

            timer.Simple(me:GetAnimTime(), function()
                self:ScrollToChild(lcollapse)
            end)
        end

        for _, v in ipairs(legacy) do
            local btn = lcollapse:Add(v.name)
            btn:SetTall(22)
            btn:SetEnabled(false)
            btn:SetCursor("arrow")

            btn.Paint = function(pnl, w, h)
                draw.NoTexture()
                surface.SetDrawColor(255, 255, 255)
                surface.DrawRect(0, 0, w, h)
                derma.SkinHook("Paint", "CategoryButton", pnl, w, h)
            end

            local alt = btn:Add("DButton")
            alt:Dock(RIGHT)
            alt:SetWide(22)
            alt:SetText("")
            alt:SetIcon("icon16/cog.png")
            local toggle = btn:Add("DButton")
            toggle:Dock(RIGHT)
            toggle:SetWide(22)
            toggle:SetText("")

            alt.DoClick = function()
                LegacyConfig(v)
            end

            toggle.DoClick = function()
                local plugs = util.JSONToTable(menup.db.get("enabled", "{}"))
                local state = not v.enabled
                v.enabled = state
                plugs[v.id] = state
                menup.db.set("enabled", util.TableToJSON(plugs, false))

                if state then
                    local success, result = pcall(v.func)

                    if not success then
                        ErrorNoHalt("Error loading " .. v.id .. ":\n" .. result)
                    end
                end

                alt:SetEnabled(v.enabled and not table.IsEmpty(v.config))
                toggle:SetIcon(v.enabled and "icon16/lightbulb.png" or "icon16/lightbulb_off.png")
            end

            alt:SetEnabled(v.enabled and not table.IsEmpty(v.config))
            toggle:SetIcon(v.enabled and "icon16/lightbulb.png" or "icon16/lightbulb_off.png")
        end
    end
end

function PANEL:Paint()
end

vgui.Register("PluginsPanel", PANEL, "DCategoryList")