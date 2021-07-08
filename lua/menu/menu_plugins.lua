local banner = [[
+-----------------------------+
    M e n u   P l u g i n s
     _   _ 
    | \ | |
    |  \| | ___ _   _  ___
    | . ` |/ _ \ | | |/ _ \
    | |\  |  __/ |_| |  __/
    \_| \_/\___|\__,_|\___|
+-----------------------------+
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