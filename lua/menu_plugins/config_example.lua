local CONFIG = {
    bool = {"Example bool", "bool", true, "Example description"},
    int = {"Example int", "int", 10},
    float = {"Example float", "float", 420.69, "nice"},
    range = {"Example range", "range", {0, 100, 50}}, -- min max default
    str = {"Example string", "string", "Bazinga!"}, -- default is also placeholder
    sel = {"Example select", "select", {"Apple", "pear", "banana","","socially distanced banana"}} -- first item is default, empty string for spacer.
}

local MANIFEST = {
    id = "djsime1.config_example",
    author = "djsime1",
    name = "Config example",
    description = "Demonstrates all possible types of configuration options.",
    version = "1.0",
    config = CONFIG
}

menup(MANIFEST)