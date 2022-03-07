local CONFIG = {
    sspos = {"Should the Position be saved?", "bool", true, "It will save the Position of the Todo Panel"},
    sssize = {"Should the Size be saved?", "bool", true, "It will save the Size of the Todo Panel"},
    savetime = {"Auto-Save Time", "float", 5, "In these Seconds it will automatically save the todos"},
}

local MANIFEST = {
    id = "rooki.todo.panellist",
    author = "Rooki",
    name = "To-Do List in the Main Menu",
    description = "You can add a To-Do List to your menu!",
    version = "0.2",
    config = CONFIG,
    source = "https://raw.githubusercontent.com/Pdzly/rookis_gmod_reduxed_plugins/main/rookis_todo.panellist.lua",
    changelog = "Initial Release *It can have bugs!*.",
}

menup(MANIFEST)

local todo = {
    settings = {},
    config = {},
    data = {},
    panel = {}
}

local function pprint(txt)
    print("[TODO] " .. txt)
end

function todo.loadconfig()
    pprint("Loading Config")
    if (not file.Exists("rooki_todo/save.txt", "data")) then return end
    local data = file.Read("rooki_todo/save.txt")

    if (data) then
        local temp = util.JSONToTable(data)
        if (not temp) then return end
        todo.config = temp.config or {}
        todo.data = temp.data or temp
    end

    pprint("Successfully loaded Config")
end

function todo.saveconfig()
    if (todo.settings.sspos) then
        todo.config.x = nil
        todo.config.y = nil
    end

    if (todo.settings.sssize) then
        todo.config.w = nil
        todo.config.h = nil
    end

    if (todo.panel.frame and IsValid(todo.panel.frame)) then
        todo.config = {
            w = todo.panel.frame:GetWide(),
            h = todo.panel.frame:GetTall(),
            x = todo.panel.frame:GetX(),
            y = todo.panel.frame:GetY()
        }

        if (not todo.settings.sspos) then
            todo.config.x = nil
            todo.config.y = nil
        end

        if (not todo.settings.sssize) then
            todo.config.w = nil
            todo.config.h = nil
        end
    end

    file.Write("rooki_todo/save.txt", util.TableToJSON({
        config = todo.config,
        data = todo.data
    }))
end

function todo.addline()
    local scrw, scrh = ScrW(), ScrH()
    local frame = vgui.Create("DFrame")
    frame:SetSize(scrw * 0.4, scrh * 0.2)
    frame:Center()
    frame:SetScreenLock(true)
    frame:NoClipping(true)
    frame:ShowCloseButton(true)
    frame:SetTitle("New Entry")
    frame:MakePopup()
    local text = vgui.Create("DTextEntry", frame)
    text:Dock(FILL)
    text:DockMargin(5, 5, 5, 5)
    local addbutton = vgui.Create("DButton", frame)
    addbutton:Dock(BOTTOM)
    addbutton:DockMargin(5, 5, 5, 5)
    addbutton:SetText("Add")

    addbutton.DoClick = function(self)
        todo.line_todo(text:GetValue() or "")
        todo.saveconfig()
    end
end

function todo.line_todo(nm, nb, uuid)
    if (not todo.panel.list or not IsValid(todo.panel.list)) then return false end

    if (not uuid) then
        math.randomseed(os.time() + math.random(0, 1000))
        uuid = math.random(100, 10000)
    end

    local line_checkbox = vgui.Create("DCheckBoxLabel", todo.panel.list) -- Create the checkbox
    line_checkbox:SetText(nm)
    line_checkbox:SetValue(nb or false)
    line_checkbox:SizeToContents()
    line_checkbox:Dock(TOP)
    line_checkbox:DockMargin(5, 5, 0, 5)
    line_checkbox:SetHeight(line_checkbox:GetChildren()[1]:GetTall() + 10)

    todo.data[uuid] = {
        name = nm,
        checked = nb,
        panel = line_checkbox
    }

    local deleteButton = vgui.Create("DButton", line_checkbox)
    deleteButton:SetText("X")
    deleteButton:Dock(RIGHT)
    deleteButton:SetTextColor(Color(255, 255, 255))

    deleteButton.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(255, 0, 0))
    end

    deleteButton.DoClick = function()
        todo.data[uuid] = nil
        line_checkbox:Remove()
        todo.saveconfig()
    end

    line_checkbox.OnChange = function(self, checked)
        todo.data[uuid].checked = checked

        if (not timer.Exists("rooki_todo_save")) then
            timer.Create("rooki_todo_save", 5, 0, function()
                todo.saveconfig()
            end)
        end
    end

    line_checkbox.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(39, 39, 39))
    end

    return line_checkbox
end

local function load_todo()
    pprint("Creating Todo Panel")

    todo.settings = {
        sspos = menup.config.get(MANIFEST.id, "sspos", true),
        sssize = menup.config.get(MANIFEST.id, "ssize", true),
        savetime = menup.config.get(MANIFEST.id, "savetime", 5)
    }

    if (todo.settings.sspos) then
        todo.config.x = nil
        todo.config.y = nil
    end

    if (todo.settings.sssize) then
        todo.config.w = nil
        todo.config.h = nil
    end

    if (todo.panel.frame and IsValid(todo.panel.frame)) then
        todo.panel.frame:Remove()
    end

    local scrw, scrh = ScrW(), ScrH()
    todo.panel.frame = vgui.Create("DFrame")
    todo.panel.frame:SetTitle("Todo List")
    todo.panel.frame:SetSize(todo.config.w or scrw * 0.2, todo.config.h or scrh * 0.5)
    todo.panel.frame:SetPos(todo.config.x or scrw * 0.79, todo.config.y or scrh * 0.25)
    todo.panel.frame:SetScreenLock(true)
    todo.panel.frame:NoClipping(true)
    todo.panel.frame:SetSizable(true)

    todo.panel.frame.Paint = function(self, wp, hp)
        draw.RoundedBox(5, 0, 0, wp, hp, Color(70, 70, 70, 204))
    end

    todo.panel.frame:ShowCloseButton(false)
    todo.panel.frame:MakePopup()
    todo.panel.frame:SetKeyboardInputEnabled(false)
    todo.panel.list = vgui.Create("DScrollPanel", todo.panel.frame)
    todo.panel.list:Dock(FILL)
    todo.panel.list:DockPadding(0, 5, 0, 5)
    todo.panel.button = vgui.Create("DButton", todo.panel.frame)
    todo.panel.button:Dock(BOTTOM)
    todo.panel.button:SetText("Add Entry")

    todo.panel.button.DoClick = function(self)
        todo.addline()
    end

    if (todo.data) then
        for k, v in pairs(todo.data) do
            todo.line_todo(v.name, v.checked, k)
        end
    end

    if (not timer.Exists("rooki_todo_save")) then
        timer.Create("rooki_todo_save", todo.settings.savetime, 0, function()
            todo.saveconfig()
        end)
    end

    pprint("Finished Loading Todo Panel")
end

local function unload_todo()
    todo.data = {}
    todo.config = {}

    if (timer.Exists("rooki_todo_save")) then
        timer.Remove("rooki_todo_save")
    end

    if (todo.panel.frame and IsValid(todo.panel.frame)) then
        todo.panel.frame:Remove()
    end
end

if (not file.IsDir("rooki_todo", "data")) then
    file.CreateDir("rooki_todo")
end

hook.Add("ConfigApply", MANIFEST.id, function(id)
    if id == MANIFEST.id then
        if (timer.Exists("rooki_todo_save")) then
            timer.Remove("rooki_todo_save")
        end

        todo.loadconfig()
        load_todo()
    end
end)

if IsValid(pnlMainMenu) then
    todo.loadconfig()
    load_todo()
    PrintTable(todo.config)
else
    hook.Add("MenuVGUIReady", MANIFEST.id, function()
        todo.loadconfig()
        load_todo()
        PrintTable(todo.config)
    end)
end

hook.Add("PluginReset", MANIFEST.id, function(manifext)
    if (manifext.id == MANIFEST.id) then
        todo.config = {}
        todo.data = {}
        todo.saveconfig()
    end
end)

return function()
    unload_todo()
end
