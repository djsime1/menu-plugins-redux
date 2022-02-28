-- https://github.com/Facepunch/garrysmod/pull/1875
local pmeta = FindMetaTable("Panel")
local ttmeta = vgui.GetControlTable("DTooltip")
local tooltip_delay = GetConVar("tooltip_delay")

function pmeta:GetTooltipPanel()
    return self.pnlTooltipPanel
end

function pmeta:SetTooltipDelay(delay)
    self.numTooltipDelay = delay
end

function ttmeta:OpenForPanel(panel)
    self.TargetPanel = panel
    self.OpenDelay = isnumber(panel.numTooltipDelay) and panel.numTooltipDelay or tooltip_delay:GetFloat()
    self:PositionTooltip()
    -- Use the parent panel's skin
    self:SetSkin(panel:GetSkin().Name)

    if (self.OpenDelay > 0) then
        self:SetVisible(false)

        timer.Simple(self.OpenDelay, function()
            if (not IsValid(self)) then return end
            if (not IsValid(panel)) then return end
            self:PositionTooltip()
            self:SetVisible(true)
        end)
    end
end