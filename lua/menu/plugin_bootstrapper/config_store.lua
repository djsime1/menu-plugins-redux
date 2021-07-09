local writeq = {}
local delq = {}

if not sql.TableExists("menup_redux") then
    print("Creating SQL table.")
    sql.Query("CREATE TABLE IF NOT EXISTS menup_redux ( key TEXT NOT NULL PRIMARY KEY, value TEXT );")
end

local function dbget(key, default)
    return delq[key] and nil
    or writeq[key]
    or sql.QueryValue("SELECT value FROM menup_redux WHERE key = " .. SQLStr(key))
    or default
end

local function dbset(key, value)
    writeq[key] = value
end

local function dbdel(key)
    delq[key] = true
end

local function process()
    if table.IsEmpty(writeq) and table.IsEmpty(delq) then return end

    sql.Begin()

    for k, v in pairs(writeq) do
        sql.Query("INSERT OR REPLACE INTO menup_redux (key, value) VALUES ( " .. SQLStr( k ) .. ", " .. SQLStr( v ) .. " )")
    end

    for k, _ in pairs(delq) do
        sql.Query("DELETE FROM cookies WHERE key = " .. SQLStr( k ))
    end

    sql.Commit()

    table.Empty(writeq)
    table.Empty(delq)
end

menup.config = {}
menup.config.set = function(id, key, value)
    local data = util.JSONToTable(dbget("data_" .. id, '{"data": "{}", "store": ""}'))
    data.config[key] = value
    dbset("data_" .. id, util.TableToJSON(data, false))
end

menup.config.get = function(id, key, value)
    local data = util.JSONToTable(dbget("data_" .. id, '{"data": "{}", "store": ""}'))
    return (key ~= nil and data.config.key or data.config) or value
end

menup.store = {}
menup.store.set = function(id, str)
    local data = util.JSONToTable(dbget("data_" .. id, '{"data": "{}", "store": ""}'))
    data.store = str
    dbset("data_" .. id, util.TableToJSON(data, false))
end

menup.store.get = function(id, default)
    local data = util.JSONToTable(dbget("data_" .. id, '{"data": "{}", "store": ""}'))
    return data.store or default
end

menup.options = {} -- compatiblity layer for menup.config
function menup.options.addOption(id, key, default)
    if menup.config.get(id, key) ~= nil then return
    else menup.config.set(id, key, default) end
end

function menup.options.getTable() return {} end -- i'll do it later

menup.options.getOption = menup.config.get
menup.options.setOption = menup.config.set

menup.db = {} -- please dont use this in a plugin
menup.db.get = dbget
menup.db.set = dbset
menup.db.del = dbdel

timer.Create("menup_db", .5, 0, process)