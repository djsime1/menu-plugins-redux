local MANIFEST = {
    id = "djsime1.calculator",
    author = "djsime1",
    name = "Simple calculator",
    description = "A very simple calculator to demonstrate Menu Plugins Redux.",
    version = "1.0",
}

menup(MANIFEST)

menup.toolbar.add(MANIFEST.id, "Calculator", "icon16/calculator.png")

return function()
    menup.toolbar.del(MANIFEST.id)
end