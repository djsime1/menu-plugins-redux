local MANIFEST = {
    id = "djsime1.calculator",
    author = "djsime1",
    name = "Simple calculator",
    description = "Placeholder until I decide to actually program this thing.",
    version = "1.0",
}

menup(MANIFEST)

menup.drawer.add(MANIFEST.id, "Calculator", function() end, "icon16/calculator.png")

return function()
    menup.drawer.del(MANIFEST.id)
end