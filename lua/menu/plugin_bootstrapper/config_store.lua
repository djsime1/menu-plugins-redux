local writeq = {}
local delq = {}
local von = include("lib/von.lua")
menup.von = von

if not sql.TableExists("menup_redux") then
    print("Creating SQL table.")
    sql.Query("CREATE TABLE IF NOT EXISTS menup_redux ( key TEXT NOT NULL PRIMARY KEY, value TEXT );")
end

local function dbget(key, default)
    return delq[key] and nil or writeq[key] or sql.QueryValue("SELECT value FROM menup_redux WHERE key = " .. SQLStr(key)) or default
end

local function dbset(key, value)
    writeq[key] = value
end

local function dbdel(key)
    delq[key] = true
end

local function dblist(query)
    return sql.Query("SELECT * FROM menup_redux WHERE key LIKE " .. SQLStr(query) .. "")
end

local function process()
    if table.IsEmpty(writeq) and table.IsEmpty(delq) then return end
    sql.Begin()

    for k, v in pairs(writeq) do
        sql.Query("INSERT OR REPLACE INTO menup_redux (key, value) VALUES ( " .. SQLStr(k) .. ", " .. SQLStr(v) .. " )")
    end

    for k, _ in pairs(delq) do
        sql.Query("DELETE FROM menup_redux WHERE key = " .. SQLStr(k))
    end

    sql.Commit()
    table.Empty(writeq)
    table.Empty(delq)
end

menup.config = {}

menup.config.set = function(id, key, value)
    local data = util.JSONToTable(dbget("data_" .. id, [[{"config": "{}", "store": ""}]]))

    if isstring(data.config) then
        data.config = util.JSONToTable(data.config)
    end

    local old = data.config[key]
    hook.Run("ConfigChange", id, key, value, old)
    data.config[key] = value
    dbset("data_" .. id, util.TableToJSON(data, false))
end

menup.config.get = function(id, key, value)
    local data = util.JSONToTable(dbget("data_" .. id, [[{"config": "{}", "store": ""}]]))

    if isstring(data.config) then
        data.config = util.JSONToTable(data.config)
    end

    if key == nil then
        return data.config
    elseif data.config[key] == nil then
        return value
    else
        return data.config[key]
    end
end

menup.store = {}

menup.store.set = function(id, str)
    local data = util.JSONToTable(dbget("data_" .. id, [[{"config": "{}", "store": ""}]]))
    data.store = str
    dbset("data_" .. id, util.TableToJSON(data, false))
end

menup.store.get = function(id, default)
    local data = util.JSONToTable(dbget("data_" .. id, [[{"config": "{}", "store": ""}]]))

    return data.store or default
end

menup.options = {} -- compatiblity layer for menup.config

function menup.options.addOption(id, key, default)
    id = "legacy." .. id
    local val = menup.config.get(id, key, default)
    menup.plugins[id].config[key] = val
    menup.config.set(id, key, val)
end

function menup.options.getOption(id, key, default)
    return menup.config.get("legacy." .. id, key, default)
end

function menup.options.setOption(id, key, value)
    menup.config.set("legacy." .. id, key, value)
end

function menup.options.getTable()
    local res = dblist("data_legacy.%")
    if not res then return {} end
    local out = {}

    for _, v in ipairs(res) do
        out[string.sub(v.key, 13)] = util.JSONToTable(v.value).config
    end

    return out
end

function menup.include(path)
    return include("menu_plugins/" .. path)
end

menup.db = {} -- please dont use this in a plugin
menup.db.get = dbget
menup.db.set = dbset
menup.db.del = dbdel
menup.db.list = dblist
timer.Create("menup_db", 1, 0, process)