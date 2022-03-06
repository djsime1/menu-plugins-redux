local CONFIG = {
    savetofile = {"Should the Background data be cached into a file?", "bool", true, "It is good for Pictures that change after a while."},
    bg_url = {"Background URL", "string", "", "The Background URL (PNG OR JPG ONLY it should end with a .jp(e)g or .png)."},
}

local MANIFEST = {
    id = "rooki.background.url",
    author = "Rooki",
    name = "URL Background Changer",
    description = "You can change the background to a url!",
    version = "0.1",
    config = CONFIG,
    source = "https://raw.githubusercontent.com/Pdzly/gmod_reduxed_background_plugin/main/rookis_bg.lua",
    changelog = "Initial Release *It can have bugs!*.",
}

menup(MANIFEST)
local OldDrawBackground = DrawBackground
local WebMaterials = {}
local materials_directory = "rooki_bg"

local function IsExtensionValid(body, headers)
    local contenttype = headers["Content-Type"]
    local isPNG = string.lower(string.sub(body, 2, 4)) == "png" or contenttype == "image/png"
    local isJPEG = string.lower(string.sub(body, 7, 10)) == "jfif" or string.lower(string.sub(body, 7, 10)) == "exif" or contenttype == "image/jpeg"

    return (isPNG and "png") or (isJPEG and "jpg")
end

local function GetExtension(url)
    local isPNG = string.EndsWith(url, ".png")
    local isJPEG = string.EndsWith(url, ".jfif") or string.EndsWith(url, ".jpg") or string.EndsWith(url, ".jpeg") or string.EndsWith(url, ".exif")

    return (isPNG and "png") or (isJPEG and "jpg")
end

local function GetMaterial(url)
    if not url then return end
    if WebMaterials[url] and IsValid(WebMaterials[url]) then return end
    local shouldsave = menup.config.get(MANIFEST.id, "savetofile", true)
    local cleanurl = string.Replace(url, "/", "")
    cleanurl = string.Replace(cleanurl, ":", "")
    cleanurl = string.Replace(cleanurl, ".", "")

    if (shouldsave) then
        local ending = GetExtension(url)

        if (not ending) then
            print("The File Extension is incompatible! (png or jp(e)g)")

            return
        end

        if (file.Exists(materials_directory .. "/" .. cleanurl .. ending, "data")) then
            local dt = file.Read(materials_directory .. "/" .. cleanurl .. ending, "data")
            WebMaterials[url] = Material(dt)

            return
        end
    end

    http.Fetch(url, function(body, size, headers)
        local extension = IsExtensionValid(body, headers)
        print("Loading Started")

        if extension then
            WebMaterials[url] = true
            local material_path = materials_directory .. "/" .. cleanurl .. "." .. extension
            local path = "data/" .. material_path
            local material = Material(path, "noclamp smooth")
            WebMaterials[url] = material

            if (shouldsave) then
                file.Write(material_path, body)
            end

            print("Finished Loading")
        end
    end, function(err)
        print(ply, "Failed to create material, error: " .. err, 1)

        return
    end)
end

local function load()
    local bgurl = menup.config.get(MANIFEST.id, "bg_url", "")
    if (not bgurl or bgurl == "" or IsInGame()) then return end
    GetMaterial(bgurl)

    function DrawBackground()
        if (not WebMaterials[bgurl] or WebMaterials[bgurl] == true or WebMaterials[bgurl]:GetName() == "___error") then
            if (OldDrawBackground) then
                OldDrawBackground()
            end

            return
        end

        surface.SetAlphaMultiplier(1)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(WebMaterials[bgurl])
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end
end

if (not file.IsDir(materials_directory, "data")) then
    file.CreateDir(materials_directory)
end

hook.Add("ConfigApply", MANIFEST.id, function(id)
    if id == MANIFEST.id then
        WebMaterials = {}
        load()
    end
end)

if IsValid(pnlMainMenu) then
    load()
else
    hook.Add("MenuVGUIReady", MANIFEST.id, function()
        OldDrawBackground = DrawBackground
        load()
    end)
end

local bgurl = menup.config.get(MANIFEST.id, "bg_url", "")
if (not bgurl or bgurl == "" or IsInGame()) then return end
GetMaterial(bgurl)

return function()
    DrawBackground = OldDrawBackground
end