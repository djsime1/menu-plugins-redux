local splash = [[
+-----------------------------------------------------------+
     __  __                    ___ _
    |  \/  |___ _ _ _  _      | _ \ |_  _ __ _(_)_ _  ___
    | |\/| / -_) ' \ || |     |  _/ | || / _` | | ' \(_-<
    |_|  |_\___|_||_\_,_|     |_| |_|\_,_\__, |_|_||_/__/
                                         |___/
     ______     ______     _____     __  __     __  __   
    /\  == \   /\  ___\   /\  __-.  /\ \/\ \   /\_\_\_\  
    \ \  __<   \ \  __\   \ \ \/\ \ \ \ \_\ \  \/_/\_\/_ 
     \ \_\ \_\  \ \_____\  \ \____-  \ \_____\   /\_\/\_\
      \/_/ /_/   \/_____/   \/____/   \/_____/   \/_/\/_/

+-----------------------------------------------------------+
]]

local l = 0
local hs = math.Rand(0, 360)
local he = hs + (180 * table.Random({-1, 1}))
for i = 1, #splash do
    if splash[i] == "\n" then
        l = 0
        MsgC("\n")
    else
        l = l + 1
        MsgC(HSVToColor(Lerp(l / 61, hs, he), .6, 1),splash[i])
    end
end

MsgN()
_G.menup = {}
include("plugin_bootstrapper/md_panel.lua")
include("plugin_bootstrapper/wip_panel.lua")
include("plugin_bootstrapper/plugins_panel.lua")
include("plugin_bootstrapper/plugins_window.lua")
include("plugin_bootstrapper/menu_button.lua")
include("plugin_bootstrapper/menu_dev.lua")
include("plugin_bootstrapper/config_store.lua")
include("plugin_bootstrapper/load_shiz.lua")