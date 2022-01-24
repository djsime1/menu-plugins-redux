local PANEL = {}
local markdown = include("lib/markdown.lua")

function PANEL:Init()
    self.hashes = {}
    self.head = [[
<head>
    <style>
        code,pre{font-family:Menlo, Monaco, "Courier New", monospace}pre{padding:0.5rem;line-height:1.25;overflow-x:scroll}a,a:visited{color:#3db1ff}a:active,a:focus,a:hover{color:#329de5}html{font-size:12px}@media screen and (min-width: 32rem) and (max-width: 48rem){html{font-size:15px}}@media screen and (min-width: 48rem){html{font-size:16px}}body{line-height:1.85; margin: 0}p{font-size:1rem;margin-bottom:1.3rem}h1,h2,h3,h4{margin:0.5rem 0 0.5rem;font-weight:inherit;line-height:1.42}small{font-size:0.707em}canvas,iframe,img,select,svg,textarea,video{max-width:100%}@import url(http://fonts.googleapis.com/css?family=Open+Sans+Condensed:300,300italic,700);@import url(http://fonts.googleapis.com/css?family=Arimo:700,700italic);html{font-size:18px;max-width:100%}body{color:#FFF;text-shadow:2px 2px 2px #444;font-family:'Open Sans Condensed', sans-serif;font-weight:300;margin:0 auto;max-width:48rem;line-height:1.45;padding:0.25rem}h1,h2,h3,h4,h5,h6{font-family:Arimo, Helvetica, sans-serif}h1,h2,h3{border-bottom:2px solid #fafafa;margin-bottom:1.15rem;padding-bottom:0.5rem;text-align:center;font-weight:700}blockquote{border-left:8px solid #fafafa;padding:1rem}
    </style>
    <script>
        document.onclick=function(e){e=e||window.event;var element=e.target||e.srcElement;if(element.tagName=='A'){var href=element.href;if(href.startsWith('#')){lua.Callback(href)}else{lua.Open(href)}return false}};
    </script>
</head>
]]
    self:SetAllowLua(true)
end

function PANEL:OnDocumentReady()
    -- self:AddFunction("lua", "Callback", function(hash)
    --     if self.hashes[hash] ~= nil then
    --         self.hashes[hash]()
    --     else
    --         print("Unknown hash: " .. hash)
    --     end
    -- end)
    self:AddFunction("lua", "Open", function(url)
        gui.OpenURL(url)
    end)
end

function PANEL:SetBody(txt)
    self.body = txt
    self:SetHTML(self.head .. "<body class=\"markdown-body\">\n" .. txt .. "\n</body>")
end

function PANEL:SetMarkdown(txt)
    self.md = txt
    self:SetBody(markdown(txt))
end

-- function PANEL:AddHash(title, callback)
--     self.hashes[title] = callback
-- end
vgui.Register("MarkdownPanel", PANEL, "DHTML")
menup.markdown = markdown