-- I don't recall where I got this script from, forgive me if it's yours.

local function lua_run_menu(_, _, _, code)
    local func = CompileString(code, "", false)

    if isstring(func) then
        Msg"Invalid syntax> "
        print(func)

        return
    end

    MsgN("> ", code)

    xpcall(func, function(err)
        print(debug.traceback(err))
    end)
end

concommand.Add("lua_run_menu", lua_run_menu)

local function FindInTable(tab, find, parents, depth)
    depth = depth or 0
    parents = parents or ""
    if (not istable(tab)) then return end
    if (depth > 3) then return end
    depth = depth + 1

    for k, v in pairs(tab) do
        if (type(k) == "string") then
            if (k and k:lower():find(find:lower())) then
                Msg("\t", parents, k, " - (", type(v), " - ", v, ")\n")
            end

            -- Recurse
            if (istable(v) and k ~= "_R" and k ~= "_E" and k ~= "_G" and k ~= "_M" and k ~= "_LOADED" and k ~= "__index") then
                local NewParents = parents .. k .. "."
                FindInTable(v, find, NewParents, depth)
            end
        end
    end
end

local function Find(ply, command, arguments)
    if (IsValid(ply) and ply:IsPlayer() and not ply:IsAdmin()) then return end
    if (not arguments[1]) then return end
    Msg("Finding '", arguments[1], "':\n\n")
    FindInTable(_G, arguments[1])
    FindInTable(debug.getregistry(), arguments[1])
    Msg("\n\n")
end

concommand.Add("lua_find_menu", Find, nil, "", {FCVAR_DONTRECORD})

function ReloadMenu()
    if IsValid(pnlMainMenu) then
        pnlMainMenu:Remove()
    end

    include("menu/menu.lua")
end

concommand.Add("menu_reload", ReloadMenu)