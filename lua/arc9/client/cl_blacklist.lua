ARC9.Blacklist = {}

-- CLIENT

net.Receive("arc9_sendblacklist", function(len, ply)

    ARC9.Blacklist = {}

    local count = net.ReadUInt(32)

    for i = 1, count do
        local attid = net.ReadUInt(ARC9.Attachments_Bits)

        local atttbl = ARC9.GetAttTable(attid)

        if !atttbl then continue end

        local shortname = atttbl.ShortName

        ARC9.Blacklist[shortname] = true
    end
end)

function ARC9:SendClientBlacklist()
    net.Start("arc9_sendblacklist")

    net.WriteUInt(table.Count(ARC9.Blacklist), 32)

    for attname, i in pairs(ARC9.Blacklist) do
        if !i then continue end
        local atttbl = ARC9.GetAttTable(attname)

        local id = atttbl.ID

        net.WriteUInt(id, ARC9.Attachments_Bits)
    end

    net.SendToServer()
end

function ARC9:AddAttToBlacklist(att)
    ARC9.Blacklist[att] = true
end

function ARC9:RemoveAttFromBlacklist(att)
    ARC9.Blacklist[att] = false
end

concommand.Add("arc9_blacklist_show", function()
    for i, k in pairs(ARC9.Blacklist) do
        print(i)
    end
end)

concommand.Add("arc9_blacklist_add", function(ply, cmd, args)
    if !ply:IsAdmin() then return end

    for _, i in ipairs(args) do
        local atttbl = ARC9.GetAttTable(i)

        if !atttbl then
            print("WARNING! ", i, " is not a valid attachment! Make sure it's spelled correctly!")
            continue
        end

        ARC9:AddAttToBlacklist(i)
    end

    ARC9:SendClientBlacklist()
end)

concommand.Add("arc9_blacklist_remove", function(ply, cmd, args)
    if !ply:IsAdmin() then return end

    for _, i in ipairs(args) do
        local atttbl = ARC9.GetAttTable(i)

        if !atttbl then
            print("WARNING! ", i, " is not a valid attachment! Make sure it's spelled correctly!")
            continue
        end

        ARC9:RemoveAttFromBlacklist(i)
    end

    ARC9:SendClientBlacklist()
end)

concommand.Add("arc9_blacklist_clear", function()
    if !ply:IsAdmin() then return end

    ARC9.Blacklist = {}

    ARC9:SendClientBlacklist()
end)

concommand.Add("arc9_blacklist_send", function()
    if !ply:IsAdmin() then return end

    ARC9:SendClientBlacklist()
end)

local srf      = surface

local blacklistWindow = nil
local blacklistTbl    = {}
local filter          = ""
local onlyblacklisted = false
local internalName    = false
local dragMode = nil

local color_bred = Color(150, 50, 50, 255)
local color_lred = Color(125, 25, 25, 150)
local color_dred = Color(75, 0, 0, 150)
local color_dtbl = Color(0, 0, 0, 200)

local arc9_hud_scale = GetConVar("arc9_hud_scale")
if !ARC9.ScreenScale then ARC9.ScreenScale = function(size) return size * (ScrW() / 640) * arc9_hud_scale:GetFloat() * 0.9 end end -- idk
local ARC9ScreenScale = ARC9.ScreenScale

local arc9logo_layer1 = Material("arc9/logo/logo_bottom.png", "mips smooth")
local arc9logo_layer2 = Material("arc9/logo/logo_middle.png", "mips smooth")

local function SaveBlacklist()
    net.Start("arc9_sendblacklist")

    net.WriteUInt(table.Count(blacklistTbl), 32)

    for attname, i in pairs(blacklistTbl) do
        if !i then continue end
        local atttbl = ARC9.GetAttTable(attname)

        local id = atttbl.ID

        net.WriteUInt(id, ARC9.Attachments_Bits)
    end

    net.SendToServer()
end

local function CreateAttButton(parent, attName, attTbl)
    local attBtn = vgui.Create("DButton", parent)
    attBtn:SetFont("ARC9_8")
    attBtn:SetText("")
    attBtn:SetSize(ARC9ScreenScale(256), ARC9ScreenScale(16))
    attBtn:Dock(TOP)
    attBtn:DockMargin(ARC9ScreenScale(4), ARC9ScreenScale(1), ARC9ScreenScale(4), ARC9ScreenScale(1))
    attBtn:SetContentAlignment(5)

    attBtn.Paint = function(spaa, w, h)
        local blisted = blacklistTbl[attName]
        if blisted == nil then blisted = ARC9.Blacklist[attName] end

        local hovered = spaa:IsHovered()
        local blackhov = blisted and hovered

        local Bfg_col = blackhov and color_bred or blisted and color_bred or hovered and color_black or color_white
        local Bbg_col = blackhov and color_lred or blisted and color_dred or hovered and color_white or color_dtbl

        srf.SetDrawColor(Bbg_col)
        srf.DrawRect(0, 0, w, h)

        local img = attTbl.Icon
        if img then
            srf.SetDrawColor(Bfg_col)
            srf.SetMaterial(img)
            srf.DrawTexturedRect(ARC9ScreenScale(2), 0, h, h)
        end

        local txt = ARC9:GetPhrase(attName .. ".PrintName") or attTbl.PrintName
        if internalName or !txt then txt = attName end
        srf.SetTextColor(Bfg_col)
        srf.SetTextPos(ARC9ScreenScale(20), ARC9ScreenScale(2))
        srf.SetFont("ARC9_12")
        srf.DrawText(txt)

        local listed   = (blacklistTbl[attName] and !ARC9.Blacklist[attName])
        local unlisted = (ARC9.Blacklist[attName] and !blacklistTbl[attName])
        local saved = (listed) and " [not saved]" or ""
        srf.SetTextColor(Bfg_col)
        srf.SetTextPos(spaa:GetWide() - ARC9ScreenScale(36), ARC9ScreenScale(4))
        srf.SetFont("ARC9_8")
        srf.DrawText(saved)
    end

    -- In addition to clicking on a button, you can drag over all of them! -- this not work correctly!!!!!!!!!!!!!!!!!!!
    attBtn.OnMousePressed = function(spaa, kc)
        blacklistTbl[attName] = !blacklistTbl[attName] and !blacklistTbl[attName]
        dragMode = blacklistTbl[attName]
        hook.Add("Think", "ARC9_Blacklist", function()
            if !input.IsMouseDown(MOUSE_LEFT) then
                dragMode = nil
                hook.Remove("Think", "ARC9_Blacklist")
            end
        end)
    end
    attBtn.OnCursorEntered = function(spaa, kc)
        if dragMode != nil and input.IsMouseDown(MOUSE_LEFT) then
            blacklistTbl[attName] = dragMode
        end
    end

    return attBtn
end

local clicksound = "arc9/newui/uimouse_click_return.ogg"
local arc9_hud_darkmode = GetConVar("arc9_hud_darkmode")

function ARC9_BlacklistMenu()
    if blacklistWindow then blacklistWindow:Remove() end

    local bg = vgui.Create("DFrame")
    bg:SetPos(0, 0)
    bg:SetSize(ScrW(), ScrH())
    bg:SetTitle("")
    bg:SetDraggable(false)
    bg:ShowCloseButton(false)        -- set to false when done please!!
    bg:SetAlpha(0)
    bg:AlphaTo(255, 0.2, 0, nil)
    bg:SetBackgroundBlur(true)
    bg:MakePopup()

    bg.Paint = function(self2, w, h)
        if arc9_hud_darkmode:GetBool() then
            surface.SetDrawColor(58, 58, 58, 206)
        else
            surface.SetDrawColor(20, 20, 20, 224)
        end
        surface.DrawRect(0, 0, w, h)
    end
    

    blacklistTbl = {}

    blacklistTbl = table.Copy(ARC9.Blacklist)

    blacklistWindow = vgui.Create("DFrame", bg)
    blacklistWindow:SetSize(ScrW() * 0.45, ScrH() * 0.9)
    blacklistWindow:Center()
    blacklistWindow:SetTitle("")
    blacklistWindow:SetDraggable(false)
    blacklistWindow:SetVisible(true)
    blacklistWindow:ShowCloseButton(false )
    blacklistWindow:MakePopup()
    blacklistWindow:SetAlpha(0)
    blacklistWindow:AlphaTo(255, 0.2, 0, nil)

    blacklistWindow.OnRemove = function() bg:Remove() end
    
    local cornercut = ARC9ScreenScale(3.5)
    local buttontalling = 0
    local talll = ARC9ScreenScale(50)

    blacklistWindow.Paint = function(self, w, h)
        draw.NoTexture()

        srf.SetDrawColor(ARC9.GetHUDColor("bg"))
        srf.DrawPoly({{x = cornercut, y = h}, {x = 0, y = h-cornercut}, {x = 0, y = ARC9ScreenScale(24+2)}, {x = w, y = ARC9ScreenScale(24+2)}, {x = w, y = h-cornercut}, {x = w-cornercut, y = h}}) -- left bottom panel
        -- srf.DrawPoly({{x = w-ARC9ScreenScale(98,4), y = h}, {x = w-ARC9ScreenScale(98,4), y = ARC9ScreenScale(25.7)}, {x = w, y = ARC9ScreenScale(25.7)}, {x = w, y = h-cornercut}, {x = w-cornercut, y = h}}) -- right panel
        srf.DrawPoly({{x = 0, y = ARC9ScreenScale(24)},{x = 0, y = cornercut},{x = cornercut, y = 0}, {x = w-cornercut, y = 0}, {x = w, y = cornercut}, {x = w, y = ARC9ScreenScale(24)}}) -- top panel

        srf.SetDrawColor(ARC9.GetHUDColor("hi"))
        srf.DrawPoly({{x = cornercut, y = h}, {x = 0, y = h-cornercut}, {x = cornercut, y = h-cornercut*.5}})
        srf.DrawPoly({{x = w, y = h-cornercut}, {x = w-cornercut, y = h}, {x = w-cornercut, y = h-cornercut*.5}})
        srf.DrawPoly({{x = cornercut, y = h-cornercut*.5}, {x = w-cornercut, y = h-cornercut*.5}, {x = w-cornercut, y = h}, {x = cornercut, y = h}, })

        do
            local x, y, s = ARC9ScreenScale(4), ARC9ScreenScale(2), ARC9ScreenScale(20)
            srf.SetDrawColor(255, 255, 255)
            srf.SetMaterial(arc9logo_layer1)
            srf.DrawTexturedRect(x, y, s, s)
        
            srf.SetDrawColor(ARC9.GetHUDColor("hi"))
            srf.SetMaterial(arc9logo_layer2)
            srf.DrawTexturedRect(x, y, s, s)
        end


        srf.SetFont("ARC9_16")
        srf.SetTextColor(ARC9.GetHUDColor("fg"))
        srf.SetTextPos(ARC9ScreenScale(30), ARC9ScreenScale(4))
        srf.DrawText(ARC9:GetPhrase("blacklist.title"))
    end

    -- local title = vgui.Create("DLabel", blacklistWindow)
    -- title:SetSize(ARC9ScreenScale(256), ARC9ScreenScale(26))
    -- title:Dock(TOP)
    -- title:SetFont("ARC9_24")
    -- title:SetText("ARC9 Blacklist")
    -- title:DockMargin(ARC9ScreenScale(16), 0, ARC9ScreenScale(16), ARC9ScreenScale(8))

    local close = vgui.Create("ARC9TopButton", blacklistWindow)
    close:SetPos(blacklistWindow:GetWide() - ARC9ScreenScale(21+2), ARC9ScreenScale(2))
    close:SetIcon(Material("arc9/ui/close.png", "mips smooth"))
    close.DoClick = function(self2)
        surface.PlaySound(clicksound)
        blacklistWindow:AlphaTo(0, 0.1, 0, nil)
        bg:AlphaTo(0, 0.1, 0, function()
            bg:Remove()
            blacklistWindow:Remove()
        end)
    end

    bg.OnMousePressed = function(self2, keycode)
        close.DoClick()
    end

    local desc = vgui.Create("DLabel", blacklistWindow)
    desc:SetSize(ARC9ScreenScale(256), ARC9ScreenScale(12))
    desc:Dock(TOP)
    desc:DockMargin(ARC9ScreenScale(4), ARC9ScreenScale(19), ARC9ScreenScale(4), ARC9ScreenScale(2))
    desc:SetFont("ARC9_12")
    desc:SetColor(ARC9.GetHUDColor("fg"))
    desc:SetText(ARC9:GetPhrase("blacklist.desc"))
    desc:SetContentAlignment(5)

    local attList = vgui.Create("ARC9ScrollPanel", blacklistWindow)
    attList:SetText("")
    attList:Dock(FILL)
    attList:DockMargin(ARC9ScreenScale(14), 0, ARC9ScreenScale(16), ARC9ScreenScale(28))
    attList:SetContentAlignment(5)
    attList.Paint = function(span, w, h) end

    local sbar = attList:GetVBar()
    sbar.Paint = function() end
    sbar.btnUp.Paint = function(span, w, h) end
    sbar.btnDown.Paint = function(span, w, h) end
    sbar.btnGrip.Paint = function(span, w, h)
        srf.SetDrawColor(color_white)
        srf.DrawRect(0, 0, w, h)
    end

    local FilterPanel = vgui.Create("DPanel", blacklistWindow)
    FilterPanel:Dock(TOP)
    FilterPanel:DockMargin(ARC9ScreenScale(16), ARC9ScreenScale(2), ARC9ScreenScale(16), ARC9ScreenScale(2))
    FilterPanel:SetSize(ARC9ScreenScale(256), ARC9ScreenScale(12))
    FilterPanel:SetPaintBackground(false)

    local FilterLabel = vgui.Create("DLabel", FilterPanel)
    FilterLabel:Dock(LEFT)
    FilterLabel:SetWidth(ARC9ScreenScale(36))
    FilterLabel:DockMargin(ARC9ScreenScale(2), ARC9ScreenScale(2), ARC9ScreenScale(2), ARC9ScreenScale(2))
    FilterLabel:SetFont("ARC9_12")
    FilterLabel:SetColor(ARC9.GetHUDColor("fg"))
    FilterLabel:SetText(ARC9:GetPhrase("blacklist.filter"))

    local FilterButton = vgui.Create("DButton", FilterPanel)
    FilterButton:SetFont("ARC9_8")
    FilterButton:SetText("")
    FilterButton:SetSize(ARC9ScreenScale(48), ARC9ScreenScale(12))
    FilterButton:Dock(RIGHT)
    FilterButton:DockMargin(ARC9ScreenScale(1), 0, 0, 0)
    FilterButton:SetContentAlignment(5)

    FilterButton.OnMousePressed = function(spaa, kc)
        onlyblacklisted = !onlyblacklisted

        attList:GenerateButtonsToList()
    end

    FilterButton.Paint = function(spaa, w, h)
        local hovered = spaa:IsHovered()

        local Bfg_col = hovered and color_black or color_white
        local Bbg_col = hovered and color_white or color_dtbl

        srf.SetDrawColor(Bbg_col)
        srf.DrawRect(0, 0, w, h)

        spaa:SetTextColor(Bfg_col)
        spaa:SetText(onlyblacklisted and ARC9:GetPhrase("blacklist.blisted") or ARC9:GetPhrase("blacklist.all"))
    end

    local NameButton = vgui.Create("DButton", FilterPanel)
    NameButton:SetFont("ARC9_8")
    NameButton:SetText("")
    NameButton:SetSize(ARC9ScreenScale(24), ARC9ScreenScale(12))
    NameButton:Dock(RIGHT)
    NameButton:DockMargin(ARC9ScreenScale(1), 0, 0, 0)
    NameButton:SetContentAlignment(5)

    NameButton.OnMousePressed = function(spaa, kc)
        internalName = !internalName
        attList:GenerateButtonsToList()
    end

    NameButton.Paint = function(spaa, w, h)
        local hovered = spaa:IsHovered()

        local Bfg_col = hovered and color_black or color_white
        local Bbg_col = hovered and color_white or color_dtbl

        srf.SetDrawColor(Bbg_col)
        srf.DrawRect(0, 0, w, h)

        spaa:SetTextColor(Bfg_col)
        spaa:SetText(internalName and ARC9:GetPhrase("blacklist.id") or ARC9:GetPhrase("blacklist.name"))
    end

    local FilterEntry = vgui.Create("DTextEntry", FilterPanel)
    FilterEntry:Dock(FILL)
    FilterEntry:SetValue(filter)
    FilterEntry:SetFont("ARC9_12")
    FilterEntry.OnChange = function( self )
        filter = self:GetValue():lower()

        attList:GenerateButtonsToList()
    end

    local savebtntext = ARC9:GetPhrase("customize.presets.save")
    local savebtn = vgui.Create("ARC9TopButton", blacklistWindow)
    surface.SetFont("ARC9_16")
    local tw = surface.GetTextSize(savebtntext)
    savebtn:SetPos(blacklistWindow:GetWide()/2-(ARC9ScreenScale(29)+tw)/2, blacklistWindow:GetTall() - ARC9ScreenScale(26))
    -- savebtn:Dock(BOTTOM)
    -- savebtn:DockMargin(blacklistWindow:GetWide()/2-ARC9ScreenScale(29)-tw, 0, blacklistWindow:GetWide()/2-ARC9ScreenScale(40), ARC9ScreenScale(4))
    savebtn:SetSize(ARC9ScreenScale(29)+tw, ARC9ScreenScale(22))
    savebtn:SetButtonText(savebtntext, "ARC9_16")
    savebtn:SetIcon(Material("arc9/ui/apply.png", "mips smooth"))
    savebtn.DoClick = function(self2)
        surface.PlaySound(clicksound)

        SaveBlacklist()
        blacklistWindow:Close()
        blacklistWindow:Remove()
    end
    
    -- Perhaps unoptimized, but it's client
    -- client_side_calculations_is_not_expensive.png
    function attList:GenerateButtonsToList()
        self:GetCanvas():Clear()

        for attName, attTbl in SortedPairsByMemberValue(ARC9.Attachments, "PrintName") do
            if attTbl.Hidden then continue end

            if attTbl.Blacklisted then blacklistTbl[attName] = true end

            if onlyblacklisted and !(attTbl.Blacklisted or blacklistTbl[attName]) then continue end
            if filter != "" and !(string.find((attTbl.PrintName and attTbl.PrintName or attName):lower(), filter) or string.find((attName):lower(), filter)) then continue end

            --if attTbl.Slot == "charm" then continue end why the fuck would you do this

            CreateAttButton(self, attName, attTbl)
        end
    end

    attList:GenerateButtonsToList()
end

concommand.Add("arc9_blacklist", function()
    if LocalPlayer():IsAdmin() then ARC9_BlacklistMenu() end
end)