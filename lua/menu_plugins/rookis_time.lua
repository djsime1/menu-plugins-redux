local CONFIG = {
    clockmode = {"24 (on) / 12 (off) hours clock", "bool", true, "En/Disable the 24 / 12 Hours clock for the AM and PM"},
    hours = {"Enable Hours", "bool", true, "En/Disable hours on the clock"},
    minutes = {"Enable Minutes", "bool", true, "En/Disable minutes on the clock"},
    seconds = {"Enable Seconds", "bool", true, "En/Disable Seconds on the clock"},
    seperator = {"The seperator of the hours minutes and seconds.", "string", "", "For example: 11:10:59 if you enter ':'"},
    font_size = {"The Size of the Font.", "int", 15, "15 is default ( do not spam the save! )"},
}

local MANIFEST = {
    id = "rooki.time",
    author = "Rooki",
    name = "Clock",
    description = "Its just adds a clock!",
    version = "0.1",
    config = CONFIG,
    source = "https://raw.githubusercontent.com/Pdzly/rookis_gmod_reduxed_plugins/main/rookis_time.lua",
    changelog = "Initial Release *It can have bugs!*.",
}

menup(MANIFEST)

surface.CreateFont("rooki_time_text", {
    font = "Arial",
    extended = false,
    size = 15,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

local txtsize = 15
local tframe
local timetext = "%X"

local function getsize(font, text)
    surface.SetFont(font)

    return surface.GetTextSize(text)
end

local function fixfont()
    local tsize = menup.config.get(MANIFEST.id, "font_size", 15)
    if (tsize == txtsize) then return end

    surface.CreateFont("rooki_time_text", {
        font = "Arial",
        extended = false,
        size = tsize,
        weight = 1000,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
    })
end

local function setTimeString()
    local mode = menup.config.get(MANIFEST.id, "clockmode", true)
    local hr = menup.config.get(MANIFEST.id, "hours", true)
    local min = menup.config.get(MANIFEST.id, "minutes", true)
    local sec = menup.config.get(MANIFEST.id, "seconds", true)
    local seper = menup.config.get(MANIFEST.id, "seperator", ":")
    local str = ""

    if (hr) then
        if (mode) then
            str = "%H"
        else
            str = "%I"
        end

        str = str .. seper
    end

    if (min) then
        str = str .. "%M"
        str = str .. seper
    end

    if (sec) then
        str = str .. "%S"
        str = str
    end

    if (not mode) then
        str = str .. " %p"
    end

    timetext = str
end

local function createtime()
    if (tframe and IsValid(tframe)) then
        tframe:Remove()
    end

    local scrw, scrh = ScrW(), ScrH()
    tframe = vgui.Create("DFrame")
    tframe:SetSizable(false)
    tframe:SetDraggable(false)
    tframe:ShowCloseButton(false)
    tframe:SetSize(50, 50)
    tframe:SetPos(scrw / 2, scrh * 0.05)
    tframe:SetTitle("")
    tframe:MakePopup()
    tframe:SetKeyboardInputEnabled(false)

    tframe.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(0, 0, 0, 216))
    end

    local tw, th = tframe:GetSize()
    local time = vgui.Create("DLabel", tframe)
    time:SetText("Loading....")
    time:SetContentAlignment(5)
    time:SetFont("rooki_time_text")
    time:SizeToContents()

    time.Think = function(self)
        local txt = os.date(timetext)
        local w, h = getsize("rooki_time_text", txt)
        tframe:SetSize(w * 1.5, h * 1.25)
        tframe:SetPos(scrw/2 - ((w * 1.5) / 2), 15)
        self:SetText(txt)
        self:SetY(h/2 * 0.25)
        self:SetX(w * 0.25)
        self:SizeToContents()
    end

    time.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 5, w, h, Color(0, 0, 0, 0))
    end
end

local function deletetime()
    if (tframe and IsValid(tframe)) then
        tframe:Remove()
    end
end

hook.Add("ConfigApply", MANIFEST.id, function(id)
    if id == MANIFEST.id then
        fixfont()
        setTimeString()
    end
end)

if IsValid(pnlMainMenu) then
    fixfont()
    setTimeString()
    createtime()
else
    hook.Add("MenuVGUIReady", MANIFEST.id, function()
        fixfont()
        setTimeString()
        createtime()
    end)
end

return function()
    deletetime()
end