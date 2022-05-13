local function PaintScrollBar(panel, w, h)
    surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
    surface.DrawRect(ScreenScale(3), 0 + ScreenScale(1), w - ScreenScale(3), h)

    surface.SetDrawColor(ARC9.GetHUDColor("fg"))
    surface.DrawRect(ScreenScale(2), 0, w - ScreenScale(3), h - ScreenScale(1))
end

local scrolleles = {}

local foldericon = Material("arc9/folder.png", "mips smooth")
local backicon = Material("arc9/back.png", "mips smooth")
local adminicon = Material("arc9/admin.png", "mips smooth")

local function iconbutton(self, scroll, name, icon)
    local btn = vgui.Create("DButton", scroll)
    btn:SetSize(ScreenScale(48), ScreenScale(48))
    btn:DockMargin(ScreenScale(2), 0, 0, 0)
    btn:Dock(LEFT)
    btn:SetText("")
    scroll:AddPanel(btn)
    table.insert(scrolleles, btn)
    btn.Paint = function(self2, w, h)
        if !IsValid(self) then return end
        local col1 = ARC9.GetHUDColor("fg")

        local hasbg = false

        if self2:IsHovered() then
            col1 = ARC9.GetHUDColor("shadow")

            surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
            surface.DrawRect(ScreenScale(1), ScreenScale(1), w - ScreenScale(1), h - ScreenScale(1))

            if self2:IsHovered() then
                surface.SetDrawColor(ARC9.GetHUDColor("hi"))
            else
                surface.SetDrawColor(ARC9.GetHUDColor("fg"))
            end
            surface.DrawRect(0, 0, w - ScreenScale(1), h - ScreenScale(1))

            hasbg = true
        else
            surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100))
            surface.DrawRect(0, 0, w, h)
        end

        if !hasbg then
            surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(ScreenScale(2), ScreenScale(2), w - ScreenScale(1), h - ScreenScale(1))
        end

        surface.SetDrawColor(col1)
        surface.SetMaterial(icon)
        surface.DrawTexturedRect(ScreenScale(1), ScreenScale(1), w - ScreenScale(1), h - ScreenScale(1))

        if !hasbg then
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            surface.SetTextPos(ScreenScale(14), ScreenScale(1))
            surface.SetFont("ARC9_10")
            self:DrawTextRot(self2, name, 0, 0, ScreenScale(3), ScreenScale(1), ScreenScale(46), true)
        end

        surface.SetTextColor(col1)
        surface.SetTextPos(ScreenScale(13), 0)
        surface.SetFont("ARC9_10")
        self:DrawTextRot(self2, name, 0, 0, ScreenScale(2), 0, ScreenScale(46), false)
    end
    return btn
end

SWEP.BottomBar = nil

-- 0: Preset
-- 1: Attachment
SWEP.BottomBarMode = 0

SWEP.BottomBarAddress = 0

SWEP.BottomBarFolders = {}
SWEP.BottomBarPath = {}
SWEP.BottomBarAtts = {}

function SWEP:ClearBottomBar()
    if self.BottomBar then
        self.BottomBar:Remove()
        self.BottomBar = nil
    end

    self:ClearAttInfoBar()
end

local function enterfolder(self, scroll, slottbl, fname)
    if fname != true then
        if fname == nil then
            table.remove(self.BottomBarPath)
        else
            table.insert(self.BottomBarPath, fname)
        end
    end

    local folders = self.BottomBarFolders
    for _, v in ipairs(self.BottomBarPath) do
        folders = folders[v]
    end

    for _, p in pairs(scrolleles) do
        p:Remove()
    end

    if #self.BottomBarPath > 0 then
        local backbtn = iconbutton(self, scroll, ARC9:GetPhrase("folder.back") or "BACK", backicon)
        backbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                enterfolder(self, scroll, slottbl, nil)
            end
        end
        local oldp = backbtn.Paint
        backbtn.Paint = function(self2, w, h)
            if !IsValid(self) then return end
            oldp(self2, w, h)
            if self2:IsHovered() then
                self.CustomizeHints["Select"] = "Return"
            end
        end
    else
        local deselbtn = iconbutton(self, scroll, ARC9:GetPhrase("folder.deselect") or "DESELECT", backicon)
        deselbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                self.BottomBarAddress = nil
                self.BottomBarMode = 0
                self:CreateHUD_Bottom()
            end
        end
        local oldp = deselbtn.Paint
        deselbtn.Paint = function(self2, w, h)
            if !IsValid(self) then return end
            oldp(self2, w, h)
            if self2:IsHovered() then
                self.CustomizeHints["Select"] = "Return"
            end
        end
    end

    for folder, children in SortedPairs(folders) do

        if isbool(children) then continue end

        local folderbtn = iconbutton(self, scroll, ARC9:GetPhrase("folder." .. folder) or folder, foldericon)
        folderbtn.folder = folder
        local count = table.Count(children)
        if count > 99 then count = "99+" end
        folderbtn.count = tostring(count)
        folderbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                enterfolder(self, scroll, slottbl, self2.folder)
            end
        end
        local oldp = folderbtn.Paint
        folderbtn.Paint = function(self2, w, h)
            if !IsValid(self) then return end
            oldp(self2, w, h)

            if self2:IsHovered() then
                self.CustomizeHints["Select"] = "Expand"
            end

            surface.SetFont("ARC9_10")
            local txtw, txth = surface.GetTextSize(self2.count)
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            self:DrawTextRot(self2, self2.count, 0, 0, w - ScreenScale(2) - txtw, h - ScreenScale(4) - txth / 2, ScreenScale(46), true)
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            self:DrawTextRot(self2, self2.count, 0, 0, w - ScreenScale(3) - txtw, h - ScreenScale(5) - txth / 2, ScreenScale(46), true)

        end
    end

    local strpath = string.Implode("/", self.BottomBarPath)

    for _, att in pairs(self.BottomBarAtts) do
        local atttbl = ARC9.GetAttTable(att.att)

        if atttbl.AdminOnly and !self:GetOwner():IsAdmin() then continue end

        if (!atttbl.Folder and #self.BottomBarPath > 0) or (atttbl.Folder and atttbl.Folder != strpath) then continue end

        local attbtn = vgui.Create("DButton", scroll)
        attbtn:SetSize(ScreenScale(48), ScreenScale(48))
        attbtn:DockMargin(ScreenScale(2), 0, 0, 0)
        attbtn:Dock(LEFT)
        attbtn:SetText("")
        attbtn.att = att.att
        attbtn.attslot = att.slot
        attbtn.address = slottbl.Address
        attbtn.slottbl = self:LocateSlotFromAddress(att.slot)
        scroll:AddPanel(attbtn)
        table.insert(scrolleles, attbtn)
        attbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                self:Attach(self2.attslot, self2.att)
                self.CustomizeSelectAddr = self2.address
            elseif kc == MOUSE_RIGHT then
                self:DetachAllFromSubSlot(self2.address)
                self.CustomizeSelectAddr = self2.address
            end
        end
        attbtn.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            local slot = self:LocateSlotFromAddress(self2.attslot)

            if !slot then return end
                if slot != self2.slottbl then
                local c1 = slot.Category
                local c2 = self2.slottbl.Category

                if istable(c1) then
                    c1 = table.concat(c1, " ")
                end

                if istable(c2) then
                    c2 = table.concat(c2, " ")
                end

                if c1 != c2 then
                    self:ClearAttInfoBar()
                    self:ClearBottomBar()
                    self.BottomBarAddress = nil
                    self.AttInfoBarAtt = nil
                    return
                end

                self2.slottbl = slot
            end

            local attached = slot.Installed == self2.att

            local col1 = ARC9.GetHUDColor("fg")
            local col2 = ARC9.GetHUDColor("shadow")

            local hasbg = false

            if self2:IsHovered() then
                if !attached then self.CustomizeHints["Select"]  = "Attach" end
                if attached then self.CustomizeHints["Deselect"] = "Unattach" end
            end

            if self2:IsHovered() or attached then
                if !atttbl.FullColorIcon then
                    col1 = ARC9.GetHUDColor("shadow")
                    surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
                    surface.DrawRect(ScreenScale(1), ScreenScale(1), w - ScreenScale(1), h - ScreenScale(1))

                    if self2:IsHovered() then
                        surface.SetDrawColor(ARC9.GetHUDColor("hi"))
                        col2 = ARC9.GetHUDColor("hi")
                    else
                        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
                        col2 = ARC9.GetHUDColor("fg")
                    end
                    surface.DrawRect(0, 0, w - ScreenScale(1), h - ScreenScale(1))
                end

                hasbg = true
            else
                surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100))
                surface.DrawRect(0, 0, w, h)
            end

            if self2:IsHovered() and self.AttInfoBarAtt != self2.att then
                self.AttInfoBarAtt = self2.att
                self:CreateHUD_AttInfo()
            end

            local canattach = self:CanAttach(slot.Address, self2.att, slot)

            if !canattach then
                col1 = ARC9.GetHUDColor("neg")
            end

            local icon = atttbl.Icon

            if !hasbg then
                surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(ScreenScale(2), ScreenScale(2), w - ScreenScale(1), h - ScreenScale(1))
            end

            if atttbl.FullColorIcon then
                surface.SetDrawColor(ARC9.GetHUDColor("fg", 150))
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(ScreenScale(1), ScreenScale(1), w - ScreenScale(1), h - ScreenScale(1))
            else
                surface.SetDrawColor(col1)
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(ScreenScale(1), ScreenScale(1), w - ScreenScale(1), h - ScreenScale(1))
            end

            if atttbl.HoloSight or atttbl.RTScope then
                local hrs = ScreenScale(12)
                local hricon = atttbl.RTScopeReticle or atttbl.HoloSightReticle
                local icons = hrs

                if atttbl.RTScopeReticle then
                    icons = icons * 2
                elseif atttbl.HoloSightSize then
                    icons = icons * (atttbl.HoloSightSize / 500)
                end

                surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
                surface.DrawRect(ScreenScale(1), ScreenScale(1) + h - hrs, hrs, hrs)

                surface.SetDrawColor(col1)
                surface.DrawRect(0, h - hrs, hrs, hrs)

                local scx, scy = self2:LocalToScreen(0, h - hrs)

                if hricon then
                    render.SetScissorRect(scx, scy, scx + hrs, scy + hrs, true)
                    surface.SetDrawColor(col2)
                    surface.SetMaterial(hricon)
                    surface.DrawTexturedRect((hrs / 2) - (icons / 2), h - (hrs / 2) - (icons / 2), icons, icons)
                    render.SetScissorRect(scx, scy, scx + hrs, scy + hrs, false)
                end
            end

            if atttbl.AdminOnly then
                local hrs = ScreenScale(12)

                surface.SetDrawColor(col1)
                surface.SetMaterial(adminicon)
                surface.DrawTexturedRect(w - hrs, h - hrs, hrs, hrs)
            end

            local name = ARC9:GetPhraseForAtt(self2.att, "CompactName") or ARC9:GetPhraseForAtt(self2.att, "PrintName") or ARC9:GetPhraseForAtt(self2.att, "ShortName") or ""

            if !hasbg then
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.SetTextPos(ScreenScale(14), ScreenScale(1))
                surface.SetFont("ARC9_10")
                self:DrawTextRot(self2, name, 0, 0, ScreenScale(3), ScreenScale(1), ScreenScale(46), true)
            end

            surface.SetTextColor(col1)
            surface.SetTextPos(ScreenScale(13), 0)
            surface.SetFont("ARC9_10")
            self:DrawTextRot(self2, name, 0, 0, ScreenScale(2), 0, ScreenScale(46), false)
        end
    end
end

surface.CreateFont( "ARC9_KeybindPreview_Cust", {
	font = "Arial",
	size = ScreenScale(8),
	weight = 1000,
	antialias = true,
} )

function SWEP:CreateHUD_Bottom()
    local bg = self.CustomizeHUD

    self:ClearBottomBar()

    self.AttInfoBarAtt = nil

    local bp = vgui.Create("DPanel", bg)
    bp:SetSize(ScrW(), ScreenScale(62))
    bp:SetPos(0, ScrH() - ScreenScale(62))
    bp.Paint = function(self2, w, h)
        if !IsValid(self) then
            self2:Remove()
            gui.EnableScreenClicker(false)
        end

        surface.SetDrawColor(ARC9.GetHUDColor("bg", 50))
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
        surface.DrawRect(ScreenScale(8) + ScreenScale(1), ScreenScale(1), (w * 3 / 4) - ScreenScale(16), ScreenScale(1))
        surface.DrawRect(ScreenScale(8) + ScreenScale(1), ScreenScale(1), ScreenScale(128), ScreenScale(8))

        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.DrawRect(ScreenScale(8), 0, (w * 3 / 4) - ScreenScale(16), ScreenScale(1))
        surface.DrawRect(ScreenScale(8), 0, ScreenScale(128), ScreenScale(8))

        local bartxt = "Presets"

        if self.BottomBarMode == 1 then
            local slot = self:LocateSlotFromAddress(self.BottomBarAddress)

            if !slot then
                self.BottomBarMode = 0
                self:CreateHUD_Bottom()
                return
            end

            bartxt = slot.PrintName or "Attachments"
            if #self.BottomBarPath > 0 then bartxt = bartxt .. "/" .. string.Implode("/", self.BottomBarPath) end
        end

        surface.SetFont("ARC9_8")
        surface.SetTextColor(ARC9.GetHUDColor("shadow"))
        surface.SetTextPos(ScreenScale(8 + 4), 0)
        surface.DrawText(bartxt)
    end

    self.BottomBar = bp

    scrolleles = {}
    local scroll = vgui.Create("DHorizontalScroller", bp)
    -- scroll:Dock(FILL)
    scroll:SetPos(0, ScreenScale(12))
    scroll:SetSize(ScrW(), ScreenScale(48))
    scroll:SetOverlap(-ScreenScale(3)) -- If this is too small, the right side will be cut out. idk why and idk how to fix it elegantly so here you go
    scroll:MoveToFront()

    scroll.btnLeft:SetPos(0, scroll:GetTall() - ScreenScale(12))
    scroll.btnLeft:SetSize(ScreenScale(12), ScreenScale(12))
    function scroll.btnLeft:Paint( w, h )
        surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
        surface.DrawRect(ScreenScale(3), 0 + ScreenScale(1), w - ScreenScale(3), h)

        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.DrawRect(ScreenScale(2), 0, w - ScreenScale(3), h - ScreenScale(1))
    end

    scroll.btnRight:SetPos(scroll:GetWide() - ScreenScale(12), scroll:GetTall() - ScreenScale(12))
    scroll.btnRight:SetSize(ScreenScale(12), ScreenScale(12))
    function scroll.btnRight:Paint( w, h )
        surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
        surface.DrawRect(ScreenScale(3), 0 + ScreenScale(1), w - ScreenScale(3), h)

        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.DrawRect(ScreenScale(2), 0, w - ScreenScale(3), h - ScreenScale(1))
    end


    if self.BottomBarMode == 1 then
        local slottbl = self:LocateSlotFromAddress(self.BottomBarAddress)

        if !slottbl then return end

        if slottbl.Installed then
            self.AttInfoBarAtt = slottbl.Installed
            self:CreateHUD_AttInfo()
        else
            self:ClearAttInfoBar()
        end

        local atts = ARC9.GetAttsForCats(slottbl.Category or "")
        local atts_slots = {}

        for _, att in pairs(atts) do
            table.insert(atts_slots, {
                att = att,
                slot = self.BottomBarAddress
            })
        end

        if slottbl.MergeSlotAddresses then
            for _, addr in pairs(slottbl.MergeSlotAddresses) do
                local slottbl2 = self:LocateSlotFromAddress(addr)

                local atts2 = ARC9.GetAttsForCats(slottbl2.Category or "")
                table.Add(atts, atts2)
                for _, att in pairs(atts2) do
                    table.insert(atts_slots, {
                        att = att,
                        slot = addr
                    })
                end
            end
        end

        table.sort(atts_slots, function(a, b)
            a = a.att or ""
            b = b.att or ""

            if a == "" or b == "" then return true end

            local atttbl_a = ARC9.GetAttTable(a)
            local atttbl_b = ARC9.GetAttTable(b)

            local order_a = 0
            local order_b = 0

            order_a = atttbl_a.SortOrder or order_a
            order_b = atttbl_b.SortOrder or order_b

            if order_a == order_b then
                return (atttbl_a.CompactName or atttbl_a.PrintName or "") < (atttbl_b.CompactName or atttbl_b.PrintName or "")
            end

            return order_a < order_b
        end)

        self.BottomBarFolders = ARC9.GetFoldersForAtts(atts)
        self.BottomBarAtts = atts_slots

        if table.Count(self.BottomBarFolders) == 1 then
            local sub = table.GetKeys(self.BottomBarFolders)[1]

            -- print(sub)

            if istable(self.BottomBarFolders[sub]) then
                self.BottomBarPath = {}
                enterfolder(self, scroll, slottbl, sub)
                return
            end
        end

        enterfolder(self, scroll, slottbl, true)
    else
        self:CreateHUD_Presets(scroll)
    end
end

SWEP.AttInfoBar = nil
SWEP.AttInfoBarAtt = nil

function SWEP:ClearAttInfoBar()
    if self.AttInfoBar then
        self.AttInfoBar:Remove()
        self.AttInfoBar = nil
    end
end

function SWEP:CreateHUD_AttInfo()
    local bg = self.CustomizeHUD

    local atttbl = ARC9.GetAttTable(self.AttInfoBarAtt)

    self:ClearAttInfoBar()

    if !atttbl then return end

    local bp = vgui.Create("DPanel", bg)
    bp:SetSize(ScrW() / 3, ScrH() - ScreenScale(64 + 24))
    bp:SetPos(ScreenScale(4), ScreenScale(24))
    bp.title = ARC9:GetPhraseForAtt(self.AttInfoBarAtt, "PrintName")
    bp.Paint = function(self2, w, h)
        if !IsValid(self) or !self:GetCustomize() then
            self2:Remove()
            gui.EnableScreenClicker(false)
        end

        surface.SetFont("ARC9_16")
        surface.SetTextPos(0, 0)
        surface.SetTextColor(ARC9.GetHUDColor("shadow"))
        self:DrawTextRot(self2, self2.title, 0, 0, ScreenScale(1), ScreenScale(8 + 1), w, false)

        surface.SetFont("ARC9_16")
        surface.SetTextPos(0, 0)
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        self:DrawTextRot(self2, self2.title, 0, 0, 0, ScreenScale(8), w, true)

        surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
        surface.DrawRect(ScreenScale(1), ScreenScale(27), w - ScreenScale(1), ScreenScale(1))

        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.DrawRect(0, ScreenScale(26), w - ScreenScale(1), ScreenScale(1))
    end

    self.AttInfoBar = bp

    local close = vgui.Create("DButton", bp)
    close:SetPos(ScreenScale(160), ScreenScale(34))
    close:SetSize(ScreenScale(48), ScreenScale(12))
    close:SetText("")
    close.title = "Hide"
    close.DoClick = function(self2)
        self:ClearAttInfoBar()
    end
    close.Paint = function(self2, w, h)
        local col1 = Color(0, 0, 0, 0)
        local col2 = ARC9.GetHUDColor("fg")

        local noshade = false

        if self2:IsHovered() then
            col1 = ARC9.GetHUDColor("hi")
            col2 = ARC9.GetHUDColor("shadow")
            self.CustomizeHints["Select"] = "Hide"

            noshade = true
        end

        if noshade then
            surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
            surface.DrawRect(ScreenScale(1), ScreenScale(1), w, h)
        end

        surface.SetDrawColor(col1)
        surface.DrawRect(0, 0, w - ScreenScale(1), h - ScreenScale(1))

        surface.SetFont("ARC9_8")
        local tw = surface.GetTextSize(self2.title)

        if !noshade then
            surface.SetFont("ARC9_8")
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            surface.SetTextPos((w - tw) / 2 + ScreenScale(1), ScreenScale(1 + 1))
            surface.DrawText(self2.title)
        end

        surface.SetFont("ARC9_8")
        surface.SetTextColor(col2)
        surface.SetTextPos((w - tw) / 2, ScreenScale(1))
        surface.DrawText(self2.title)
    end

    local tp = vgui.Create("DScrollPanel", bp)
    tp:SetSize(ScreenScale(150), bp:GetTall() - ScreenScale(28 + 6))
    tp:SetPos(ScreenScale(4), ScreenScale(28 + 4))
    tp.Paint = function(self2, w, h)
        surface.SetDrawColor(ARC9.GetHUDColor("shadow", 240))
        surface.DrawRect(0, 0, w, h)
    end

    local scroll_preset = tp:GetVBar()
    scroll_preset.Paint = function() end
    scroll_preset.btnUp.Paint = function(span, w, h)
    end
    scroll_preset.btnDown.Paint = function(span, w, h)
    end
    scroll_preset.btnGrip.Paint = PaintScrollBar

    local newbtn = tp:Add("DPanel")
    newbtn:SetSize(ScreenScale(400), ScreenScale(9))
    newbtn:Dock(TOP)
    newbtn.title = "Description"
    newbtn.Paint = function(self2, w, h)
        -- title
        surface.SetFont("ARC9_6")
        surface.SetTextPos(ScreenScale(3), ScreenScale(2 + 1))
        surface.SetTextColor(ARC9.GetHUDColor("shadow"))
        surface.DrawText(self2.title)

        surface.SetFont("ARC9_6")
        surface.SetTextPos(ScreenScale(2), ScreenScale(2))
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.DrawText(self2.title)
    end

    local multiline = {}
    local desc = ARC9:GetPhraseForAtt(self.AttInfoBarAtt, "Description") or atttbl.Description

    multiline = self:MultiLineText(desc, tp:GetWide() - (ScreenScale(3.5)), "ARC9_8")

    for i, text in pairs(multiline) do
        local desc_line = vgui.Create("DPanel", tp)
        desc_line:SetSize(tp:GetWide(), ScreenScale(9))
        desc_line:Dock(TOP)
        desc_line.Paint = function(self2, w, h)
            surface.SetFont("ARC9_8")
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            surface.SetTextPos(ScreenScale(3), ScreenScale(1))
            surface.DrawText(text)

            surface.SetFont("ARC9_8")
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetTextPos(ScreenScale(2), 0)
            surface.DrawText(text)
        end
    end

    local pros, cons = ARC9.GetProsAndCons(atttbl, self)

    if table.Count(pros) > 0 then
        local pro_label = vgui.Create("DPanel", tp)
        pro_label:SetSize(tp:GetWide(), ScreenScale(11))
        pro_label:Dock(TOP)
        pro_label.text = "Advantages"
        pro_label.Paint = function(self2, w, h)
            surface.SetFont("ARC9_10")
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            surface.SetTextPos(ScreenScale(3), ScreenScale(1))
            surface.DrawText(self2.text)

            surface.SetFont("ARC9_10")
            surface.SetTextColor(ARC9.GetHUDColor("pos"))
            surface.SetTextPos(ScreenScale(2), 0)
            surface.DrawText(self2.text)
        end

        for _, stat in pairs(pros) do
            local pro_stat = vgui.Create("DPanel", tp)
            pro_stat:SetSize(tp:GetWide(), ScreenScale(9))
            pro_stat:Dock(TOP)
            pro_stat.text = stat
            pro_stat.Paint = function(self2, w, h)
                surface.SetDrawColor(ARC9.GetHUDColor("pos", 15))
                surface.DrawRect(0, 0, w, h)

                surface.SetFont("ARC9_8")
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.SetTextPos(ScreenScale(3), ScreenScale(1))
                self:DrawTextRot(self2, self2.text, 0, 0, ScreenScale(3), ScreenScale(1), w, false)

                surface.SetFont("ARC9_8")
                surface.SetTextColor(ARC9.GetHUDColor("pos"))
                surface.SetTextPos(ScreenScale(2), 0)
                self:DrawTextRot(self2, self2.text, 0, 0, ScreenScale(2), 0, w, true)
            end
        end
    end

    if table.Count(cons) > 0 then
        local con_label = vgui.Create("DPanel", tp)
        con_label:SetSize(tp:GetWide(), ScreenScale(11))
        con_label:Dock(TOP)
        con_label.text = "Disadvantages"
        con_label.Paint = function(self2, w, h)
            surface.SetFont("ARC9_10")
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            surface.SetTextPos(ScreenScale(3), ScreenScale(1))
            surface.DrawText(self2.text)

            surface.SetFont("ARC9_10")
            surface.SetTextColor(ARC9.GetHUDColor("neg"))
            surface.SetTextPos(ScreenScale(2), 0)
            surface.DrawText(self2.text)
        end

        for _, stat in pairs(cons) do
            local con_stat = vgui.Create("DPanel", tp)
            con_stat:SetSize(tp:GetWide(), ScreenScale(9))
            con_stat:Dock(TOP)
            con_stat.text = stat
            con_stat.Paint = function(self2, w, h)
                surface.SetDrawColor(ARC9.GetHUDColor("neg", 15))
                surface.DrawRect(0, 0, w, h)

                surface.SetFont("ARC9_8")
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.SetTextPos(ScreenScale(3), ScreenScale(1))
                self:DrawTextRot(self2, self2.text, 0, 0, ScreenScale(3), ScreenScale(1), w, false)

                surface.SetFont("ARC9_8")
                surface.SetTextColor(ARC9.GetHUDColor("neg"))
                surface.SetTextPos(ScreenScale(2), 0)
                self:DrawTextRot(self2, self2.text, 0, 0, ScreenScale(2), 0, w, true)
            end
        end
    end
end