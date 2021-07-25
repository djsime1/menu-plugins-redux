local CONFIG = {
    {"Example bool", "bool", true, "Example description"},
    {"Example int", "int", 10},
    {"Example float", "float", 420.69, "nice"},
    {"Example range", "range", {0, 100}},
    {"Example string", "string", "Bazinga!"},
    {"Example select", "select", {"Apple", "pear", "banana"}}
}

local MANIFEST = {
    id = "djsime1.config_example",
    author = "djsime1",
    name = "Config example",
    description = "Configure me then run configexample",
    version = "1.0",
    config = CONFIG
}

menup(MANIFEST)