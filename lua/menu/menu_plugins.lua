_G.menup = {}
menup.version = "0.2.1" -- used to check for updates
menup.source = "https://raw.githubusercontent.com/djsime1/menu-plugins-redux/main/lua/menu/menu_plugins.lua" -- link to a file with the version string above
menup.changelog = [[
- Implimented PR #1875 from the garrysmod repo. (Tooltip delays)  
- Added helper text to all stock plugins.  
- Added tick mark to currently selected config items.  
- Added loading screen customizer.  
- Fixed grammar in Background Customizer and Pling.  
- Changed loading to gather all manifests before running the plugins for dependency checking.  

*Previous changelog:*  
- Added `api` and `dependencies` parameters to manifests.  
- Added on join functionality to Pling.  
- Added Color, Keybind, File, Stack, Sort, and List config types.  
- Added in-game color option to Background Customizer.  
- Fixed an potential issue with the toolbar button.  
- Changed Pling sound option to file type.  
- Changed Background Customizer to allow multiple background texts.  
- Changed plugin loading to occur BEFORE menu is loaded.  
- Removed debug print form `menup load` command.  
- Removed menu_reload, menu_plugins, and menup_drawer commands.  
]]

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

local l, c1, c2 = 0, Color(0, 195, 255):ToVector() , Color(255, 255, 28):ToVector()
for i = 1, #splash do
    if splash[i] == "\n" then
        l = 0
        MsgC("\n")
    else
        l = l + 1
        local cvec = LerpVector(l / 61, c1, c2) -- if Color:ToVector exists in menu, then why not Vector:ToColor??
        MsgC(Color(cvec.x * 255, cvec.y * 255, cvec.z * 255), splash[i])
    end
end

MsgN()
include("plugin_bootstrapper/tooltip_delay.lua")
include("plugin_bootstrapper/md_panel.lua")
include("plugin_bootstrapper/wip_panel.lua")
include("plugin_bootstrapper/plugins_panel.lua")
include("plugin_bootstrapper/plugins_window.lua")
include("plugin_bootstrapper/menu_button.lua")
include("plugin_bootstrapper/config_store.lua")
include("plugin_bootstrapper/load_shiz.lua")
include("plugin_bootstrapper/menup_command.lua")