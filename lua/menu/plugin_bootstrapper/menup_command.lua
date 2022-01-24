--[[
menup list
menup enable
menup disable
menup gui
menup drawer
menup reload
menup load
]]
local function menup_list(filter)
    filter = table.concat(filter, " ", 2)
    MsgC(Color(41, 121, 255), "Loaded menu plugins:\n")

    for k, v in pairs(menup.plugins) do
        local p = menup.plugins[k]
        if filter and not (string.find(k, filter) or string.find(p.name, filter)) then continue end
        MsgC(Color(166, 166, 166), " - ", Color(255, 255, 255), string.format("%s (%s)", p.name, k), Color(166, 166, 166), " :: ")

        if p.enabled then
            MsgC(Color(0, 230, 118), "Enabled.\n")
        else
            MsgC(Color(255, 23, 68), "Disabled.\n")
        end
    end
end

local function menup_enable(id)
    id = table.concat(id, " ", 2)
    local p = menup.plugins[id]

    if not p then
        MsgC(Color(255, 234, 0), "Plugin not found.\n")
    elseif p.enabled then
        MsgC(Color(255, 234, 0), "Plugin already enabled.\n")
    else
        menup.control.enable(id)
        MsgC(Color(41, 121, 255), p.name, Color(255, 255, 255), " is now ", Color(0, 230, 118), "enabled.\n")
    end
end

local function menup_disable(id)
    id = table.concat(id, " ", 2)
    local p = menup.plugins[id]

    if not p then
        MsgC(Color(255, 234, 0), "Plugin not found.\n")
    elseif not p.enabled then
        MsgC(Color(255, 234, 0), "Plugin already disabled.\n")
    else
        menup.control.disable(id)
        MsgC(Color(41, 121, 255), p.name, Color(255, 255, 255), " is now ", Color(255, 23, 68), "disabled.\n")
    end
end

local function menup_restart(confirm)
    confirm = confirm[2]

    if confirm == "confirm" then
        MsgC(Color(41, 121, 255), "Restarting MPR...\n")

        for k, v in pairs(menup.plugins) do
            if v.enabled then
                menup.control.disable(k, false)
            end
        end

        CloseDermaMenus()

        if IsValid(PluginsWindow) then
            PluginsWindow:Close()
        end

        table.Empty(menup)

        if pnlMainMenu and pnlMainMenu.HTML and vgui.GetControlTable("MainMenuPanel") then
            pnlMainMenu.HTML:Call([[document.getElementById("PluginsButton").remove();]])
        end

        include("menu/menu_plugins.lua")
    elseif confirm == "risky" then
        include("menu/menu_plugins.lua")
    else
        MsgC(Color(255, 234, 0), "Hold up a second! ", Color(255, 255, 255), "Things can break if you do this. To proceed, run 'menup restart confirm'\n")
    end
end

local function menup_load(stuff)
    stuff = stuff[2]
    if not stuff then
        MsgC(Color(255, 255, 255), "Please specify a file name or plugin ID to (re)load.\n")
    elseif file.Exists("lua/menu_plugins/" .. stuff, "GAME") then
        MsgC(Color(255, 255, 255), "Loading file ", Color(41, 121, 255), stuff, Color(255, 255, 255), " as a plugin...\n")
        local manifest = menup.control.load("lua/menu_plugins/" .. stuff)
        menup.control.run(manifest.id)
    elseif menup.plugins[stuff] then
        local p = menup.plugins[stuff]
        if not p.file then MsgC(Color(255, 234, 0), "The plugin has no file assicaited with it.\n") return end
        menup_load({"bazinga", p.file})
    else
        MsgC(Color(255, 234, 0), "Could not find a file or plugin ID with that query.\n")
    end
end

local function menup_command(_, _, args, argstr)
    local cmds = {
        list = menup_list,
        enable = menup_enable,
        disable = menup_disable,
        gui = ShowPluginsWindow,
        drawer = menup.drawer.open,
        restart = menup_restart,
        load = menup_load,
    }

    local sub = args[1]

    if not sub or not cmds[sub] then
        MsgC(Color(41, 121, 255), "Available commands:\n")

        for k, _ in SortedPairs(cmds) do
            MsgC(Color(255, 255, 255), " - " .. k .. "\n")
        end
    else
        cmds[sub](args)
    end
end

concommand.Add("menup", menup_command)