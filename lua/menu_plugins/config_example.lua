local CONFIG = {
    bool = {"Example bool", "bool", true, "Example description"},
    int = {"Example int", "int", 10},
    float = {"Example float", "float", 420.69, "nice"},
    range = {"Example range", "range", {0, 100, 50}},
    str = {"Example string", "string", "Bazinga!"},
    sel = {"Example select", "select", {"Apple", "pear", "banana"}}
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