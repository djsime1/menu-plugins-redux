local PANEL = {}

local function ColorRand()
    return HSVToColor(math.Rand(0, 360) * 50, .7, 1)
end

function PANEL:Init()
    self.bouncies = {}
    self:SetSize(512, 512)
    self:AddBouncy()
end

function PANEL:Think()
    local px,py = self:GetSize()
    local function bounce(thing, axis) -- this devolved quickly
        thing:SetTextColor(ColorRand())
        if axis then thing.dx = thing.dx * -1
        else thing.dy = thing.dy * -1 end
        thing:SetPos(thing:GetX() + thing.dx, thing:GetY() + thing.dy)
        if #self.bouncies < 100 then
            local new = self:AddBouncy()
            new:SetPos(thing:GetPos())
            if !axis then new.dx = thing.dx * -1; new.dy = thing.dy
            else new.dy = thing.dy * -1; new.dx = thing.dx end
        end
    end
    for _, label in ipairs(self.bouncies) do
        local x,y = label:GetPos()
        if (x <= 0) or (x + label.sx >= px) then bounce(label, true) end
        if (y <= 0) or (y + label.sy >= py) then bounce(label, false) end
        label:SetPos(x + label.dx, y + label.dy)
    end
end

function PANEL:AddBouncy(text)
    text = text or "W.I.P"
    local label = vgui.Create("DLabel", self)
    label:SetFont("DermaLarge")
    label:SetText(text)
    label:InvalidateLayout(true)
    label:SizeToContents()
    label:SetTextColor(ColorRand())
    label:Center()
    label.sx,label.sy = label:GetSize()
    label.dx, label.dy = table.Random({-1, 1}), table.Random({-1, 1})
    table.insert(self.bouncies, label)
    return label
end

function PANEL:Paint(w, h) end

vgui.Register("WIPFrame", PANEL, "DPanel")