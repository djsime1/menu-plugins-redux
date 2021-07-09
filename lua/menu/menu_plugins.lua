local release = 1
local banner = [[
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
local message = string.Explode("\n", banner, false)
local longest = 0
for k, v in pairs(message) do
	if v:len() > longest then longest = v:len() end
end

MsgN()

for k, line in pairs(message) do
	for i = 1, line:len() do
		local hue = ((i-1) / longest) * 360
		MsgC(HSVToColor(hue, 0.375, 1), line:sub(i, i))
	end
	MsgN()
end

MsgN()

_G.menup = {}

include("plugin_bootstrapper/markdown.lua")
include("plugin_bootstrapper/wip_minigame.lua")
include("plugin_bootstrapper/plugins_window.lua")
include("plugin_bootstrapper/menu_button.lua")
include("plugin_bootstrapper/menu_dev.lua")
include("plugin_bootstrapper/config_store.lua")
include("plugin_bootstrapper/load_shit.lua")