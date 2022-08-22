local scrolleles = {}

local foldericon = Material("arc9/ui/folder.png", "mips smooth")
local backicon = Material("arc9/ui/back.png", "mips smooth")
local adminicon = Material("arc9/admin.png", "mips smooth")

local ARC9ScreenScale = ARC9.ScreenScale

local function spacer(self, scroll, margin)
    local spacer = vgui.Create("DPanel", scroll)
    spacer:DockMargin(ARC9ScreenScale(margin), 0, ARC9ScreenScale(4), 0)
    spacer:Dock(LEFT)
    spacer:SetSize(ARC9ScreenScale(1), ARC9ScreenScale(2))

    scroll:AddPanel(spacer)
    table.insert(scrolleles, spacer)
    spacer.Paint = function(self2, w, h)
        if !IsValid(self) then return end

        surface.SetDrawColor(ARC9.GetHUDColor("bg"))
        surface.DrawRect(0, ARC9ScreenScale(2), w, ARC9ScreenScale(40))
    end
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

    local backbtn = vgui.Create("ARC9AttButton", scroll)
    backbtn:SetIcon(backicon)
    backbtn:SetEmpty(true)

    backbtn:DockMargin(ARC9ScreenScale(5), 0, 0, 0)
    backbtn:Dock(LEFT)

    scroll:AddPanel(backbtn)
    table.insert(scrolleles, backbtn)

    if #self.BottomBarPath > 0 then
        backbtn:SetButtonText(ARC9:GetPhrase("folder.back") or "BACK")
        backbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                enterfolder(self, scroll, slottbl, nil)
            end
        end
    else
        backbtn:SetButtonText(ARC9:GetPhrase("folder.deselect") or "DESELECT")
        backbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                self.BottomBarAddress = nil
                self.BottomBarMode = 0
                self:CreateHUD_Bottom()
            end
        end
    end

    spacer(self, scroll, 4)
    
    local foldercount = 0

    for folder, children in SortedPairs(folders) do
        if !folders then 
            table.remove(self.BottomBarPath)
        end
        if isbool(children) then continue end

        foldercount = foldercount + 1

        local folderbtn = vgui.Create("ARC9AttButton", scroll)

        folderbtn:SetButtonText(ARC9:GetPhrase("folder." .. folder) or folder)
        folderbtn:SetIcon(foldericon)
        folderbtn:SetEmpty(true)

        folderbtn:DockMargin(0, 0, ARC9ScreenScale(4), 0)
        folderbtn:Dock(LEFT)
    
        scroll:AddPanel(folderbtn)
        table.insert(scrolleles, folderbtn)
        folderbtn.folder = folder

        local count = table.Count(children)
        if count > 99 then count = "99+" end

        folderbtn:SetFolderContain(tostring(count))

        folderbtn.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                enterfolder(self, scroll, slottbl, self2.folder)
            end
        end
    end

    if foldercount>1 then spacer(self, scroll, 0) end

    local strpath = string.Implode("/", self.BottomBarPath)

    for _, att in pairs(self.BottomBarAtts) do
        local atttbl = ARC9.GetAttTable(att.att)

        if atttbl.AdminOnly and !self:GetOwner():IsAdmin() then continue end

        if (!atttbl.Folder and #self.BottomBarPath > 0) or (atttbl.Folder and atttbl.Folder != strpath) then continue end

        local attname = ARC9:GetPhraseForAtt(att.att, "CompactName") or ARC9:GetPhraseForAtt(att.att, "PrintName") or ARC9:GetPhraseForAtt(att.att, "ShortName") or ""

        local attbtn2 = vgui.Create("ARC9AttButton", scroll)
        attbtn2:DockMargin(0, 0, ARC9ScreenScale(4), 0)
        attbtn2:Dock(LEFT)
        attbtn2:SetButtonText(attname)
        attbtn2:SetIcon(atttbl.Icon)
        attbtn2.att = att.att
        attbtn2.attslot = att.slot
        attbtn2.address = slottbl.Address
        attbtn2.slottbl = self:LocateSlotFromAddress(att.slot)
    
        scroll:AddPanel(attbtn2)
        table.insert(scrolleles, attbtn2)
        attbtn2.OnMousePressed = function(self2, kc)
            if kc == MOUSE_LEFT then
                self:Attach(self2.attslot, self2.att)
                self.CustomizeSelectAddr = self2.address
            elseif kc == MOUSE_RIGHT then
                self:DetachAllFromSubSlot(self2.address)
                self.CustomizeSelectAddr = self2.address
            end
        end
        
        attbtn2.Think = function(self2)
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

            attbtn2:SetInstalled(slot.Installed == att.att)
            attbtn2:SetHasModes(!!atttbl.ToggleStats)
            attbtn2:SetHasSlots(!!atttbl.Attachments)
            attbtn2:SetCanAttach(self:CanAttach(slot.Address, att.att, slot))

            if self2:IsHovered() and self.AttInfoBarAtt != self2.att then
                self.AttInfoBarAtt = self2.att
                self:CreateHUD_AttInfo()
            end
        end

        -- print(scrolleles[#scrolleles-1])
        -- PrintTable(scrolleles)
        -- attbtn.Paint = function(self2, w, h)
        --     if !IsValid(self) then return end

        --     local slot = self:LocateSlotFromAddress(self2.attslot)

        --     if !slot then return end
        --         if slot != self2.slottbl then
        --         local c1 = slot.Category
        --         local c2 = self2.slottbl.Category

        --         if istable(c1) then
        --             c1 = table.concat(c1, " ")
        --         end

        --         if istable(c2) then
        --             c2 = table.concat(c2, " ")
        --         end

        --         if c1 != c2 then
        --             self:ClearAttInfoBar()
        --             self:ClearBottomBar()
        --             self.BottomBarAddress = nil
        --             self.AttInfoBarAtt = nil
        --             return
        --         end

        --         self2.slottbl = slot
        --     end

        --     local attached = slot.Installed == self2.att

        --     local col1 = ARC9.GetHUDColor("fg")
        --     local col2 = ARC9.GetHUDColor("shadow")

        --     local hasbg = false

        --     if self2:IsHovered() then
        --         if !attached then self.CustomizeHints["Select"]  = "Attach" end
        --         -- if attached then self.CustomizeHints["Deselect"] = "Unattach" end
        --         if slot.Installed then self.CustomizeHints["Deselect"] = "Unattach" end
        --     end

        --     if self2:IsHovered() or attached then
        --         if !atttbl.FullColorIcon then
        --             col1 = ARC9.GetHUDColor("shadow")
        --             surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
        --             surface.DrawRect(ARC9ScreenScale(1), ARC9ScreenScale(1), w - ARC9ScreenScale(1), h - ARC9ScreenScale(1))

        --             if self2:IsHovered() then
        --                 surface.SetDrawColor(ARC9.GetHUDColor("hi"))
        --                 col2 = ARC9.GetHUDColor("hi")
        --             else
        --                 surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        --                 col2 = ARC9.GetHUDColor("fg")
        --             end
        --             surface.DrawRect(0, 0, w - ARC9ScreenScale(1), h - ARC9ScreenScale(1))
        --         end

        --         hasbg = true
        --     else
        --         surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100))
        --         surface.DrawRect(0, 0, w, h)
        --     end

        --     if self2:IsHovered() and self.AttInfoBarAtt != self2.att then
        --         self.AttInfoBarAtt = self2.att
        --         self:CreateHUD_AttInfo()
        --     end

        --     local canattach = self:CanAttach(slot.Address, self2.att, slot)

        --     if !canattach then
        --         col1 = ARC9.GetHUDColor("neg")
        --     end

        --     local icon = atttbl.Icon

        --     if !hasbg then
        --         surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
        --         surface.SetMaterial(icon)
        --         surface.DrawTexturedRect(ARC9ScreenScale(2), ARC9ScreenScale(2), w - ARC9ScreenScale(1), h - ARC9ScreenScale(1))
        --     end

        --     if atttbl.FullColorIcon then
        --         surface.SetDrawColor(ARC9.GetHUDColor("fg", 150))
        --         surface.SetMaterial(icon)
        --         surface.DrawTexturedRect(ARC9ScreenScale(1), ARC9ScreenScale(1), w - ARC9ScreenScale(1), h - ARC9ScreenScale(1))
        --     else
        --         surface.SetDrawColor(col1)
        --         surface.SetMaterial(icon)
        --         surface.DrawTexturedRect(ARC9ScreenScale(1), ARC9ScreenScale(1), w - ARC9ScreenScale(1), h - ARC9ScreenScale(1))
        --     end

        --     if atttbl.HoloSight or atttbl.RTScope then
        --         local hrs = ARC9ScreenScale(12)
        --         local hricon = atttbl.RTScopeReticle or atttbl.HoloSightReticle
        --         local icons = hrs

        --         if atttbl.RTScopeReticle then
        --             icons = icons * 2
        --         elseif atttbl.HoloSightSize then
        --             icons = icons * (atttbl.HoloSightSize / 500)
        --         end

        --         surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
        --         surface.DrawRect(ARC9ScreenScale(1), ARC9ScreenScale(1) + h - hrs, hrs, hrs)

        --         surface.SetDrawColor(col1)
        --         surface.DrawRect(0, h - hrs, hrs, hrs)

        --         local scx, scy = self2:LocalToScreen(0, h - hrs)

        --         if hricon then
        --             render.SetScissorRect(scx, scy, scx + hrs, scy + hrs, true)
        --             surface.SetDrawColor(col2)
        --             surface.SetMaterial(hricon)
        --             surface.DrawTexturedRect((hrs / 2) - (icons / 2), h - (hrs / 2) - (icons / 2), icons, icons)
        --             render.SetScissorRect(scx, scy, scx + hrs, scy + hrs, false)
        --         end
        --     end

        --     if atttbl.AdminOnly then
        --         local hrs = ARC9ScreenScale(12)

        --         surface.SetDrawColor(col1)
        --         surface.SetMaterial(adminicon)
        --         surface.DrawTexturedRect(w - hrs, h - hrs, hrs, hrs)
        --     end

        --     local name = ARC9:GetPhraseForAtt(self2.att, "CompactName") or ARC9:GetPhraseForAtt(self2.att, "PrintName") or ARC9:GetPhraseForAtt(self2.att, "ShortName") or ""

        --     if !hasbg then
        --         surface.SetTextColor(ARC9.GetHUDColor("shadow"))
        --         surface.SetTextPos(ARC9ScreenScale(14), ARC9ScreenScale(1))
        --         surface.SetFont("ARC9_10")
        --         self:DrawTextRot(self2, name, 0, 0, ARC9ScreenScale(3), ARC9ScreenScale(1), ARC9ScreenScale(46), true)
        --     end

        --     surface.SetTextColor(col1)
        --     surface.SetTextPos(ARC9ScreenScale(13), 0)
        --     surface.SetFont("ARC9_10")
        --     self:DrawTextRot(self2, name, 0, 0, ARC9ScreenScale(2), 0, ARC9ScreenScale(46), false)
        -- end
    end
end

surface.CreateFont("ARC9_KeybindPreview_Cust", {
	font = "Arial",
	size = ARC9ScreenScale(8),
	weight = 1000,
	antialias = true,
})

function SWEP:CreateHUD_Bottom()
    -- if true then return end
    local bg = self.CustomizeHUD
    local lowerpanel = bg.lowerpanel

    self:ClearBottomBar()

    self.AttInfoBarAtt = nil

    local bp = vgui.Create("DPanel", lowerpanel)
    bp:SetSize(lowerpanel:GetWide(), ARC9ScreenScale(62))
    bp:SetPos(0, ARC9ScreenScale(15.5))
    bp.Paint = function() end

    self.BottomBar = bp

    scrolleles = {}
    local scroll = vgui.Create("DHorizontalScroller", bp)
    scroll:SetPos(0, ARC9ScreenScale(3))
    scroll:SetSize(lowerpanel:GetWide(), ARC9ScreenScale(57.3))
    scroll:SetOverlap(-ARC9ScreenScale(7)) -- If this is too small, the right side will be cut out. idk why and idk how to fix it elegantly so here you go
    scroll:MoveToFront()

    -- scroll.btnLeft:SetTall(ARC9ScreenScale(12)) -- not posible due to garry newman dhorizontalscroller   we could override it but i too lazyyyy

    scroll.btnLeft:SetPos(0, scroll:GetTall() - ARC9ScreenScale(12))
    function scroll.btnLeft:Paint(w, h)
        -- surface.SetDrawColor(ARC9.GetHUDColor("fg", 100))
        -- surface.DrawRect(0, h*0.5, w, h*0.5)
    end

    function scroll.btnRight:Paint(w, h)
        -- surface.SetDrawColor(ARC9.GetHUDColor("fg", 100))
        -- surface.DrawRect(0, h*0.5, w, h*0.5)
    end


    if self.BottomBarMode == 1 then
        self.CustomizeHUD.lowerpanel:MoveTo(ARC9ScreenScale(19), ScrH() - ARC9ScreenScale(93+73.5), 0.2, 0, 0.5, nil)
        self.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ARC9ScreenScale(38), ARC9ScreenScale(74+73.5), 0.2, 0, 0.5, nil)
        self.CustomizeHUD.lowerpanel.Extended = true 

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
        self:CreateHUD_Slots(scroll)
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
    local lowerpanel = self.CustomizeHUD.lowerpanel
    -- if true then return end
    local atttbl = ARC9.GetAttTable(self.AttInfoBarAtt)

    self:ClearAttInfoBar()

    if !atttbl then return end

    local infopanel = vgui.Create("DPanel", lowerpanel)
    infopanel:SetSize(lowerpanel:GetWide(), ARC9ScreenScale(70))
    infopanel:SetPos(0, ARC9ScreenScale(75.5))
    infopanel.title = ARC9:GetPhraseForAtt(self.AttInfoBarAtt, "PrintName")
    infopanel.Paint = function(self2, w, h)
        surface.SetFont("ARC9_10")
        surface.SetTextPos(0, 0)
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        self:DrawTextRot(self2, self2.title, 0, 0, ARC9ScreenScale(6), ARC9ScreenScale(3), w, true)
    end

    self.AttInfoBar = infopanel

    local function paintthescroller(scr)
        local scroll_preset = scr:GetVBar()
        scroll_preset:SetHideButtons(true)
        scroll_preset.Paint = function() end
        scroll_preset:SetWide(ARC9ScreenScale(2))
        scroll_preset.btnGrip.Paint = function(panel, w, h)
            surface.SetDrawColor(ARC9.GetHUDColor("fg"))
            surface.DrawRect(0, 0, w, h)
        end
        scroll_preset:SetAlpha(0) -- to prevent blinking
        scroll_preset:AlphaTo(255, 0.2, 0, nil)
    end

    local descscroller = vgui.Create("DScrollPanel", infopanel)
    descscroller:SetSize(lowerpanel:GetWide()/2 - ARC9ScreenScale(5), infopanel:GetTall()-ARC9ScreenScale(16))
    descscroller:SetPos(ARC9ScreenScale(4), ARC9ScreenScale(14))
    paintthescroller(descscroller)

    local multiline = {}
    local desc = ARC9:GetPhraseForAtt(self.AttInfoBarAtt, "Description") or atttbl.Description

    multiline = self:MultiLineText(desc, descscroller:GetWide() - (ARC9ScreenScale(3.5)), "ARC9_9_Slim")

    for i, text in ipairs(multiline) do
        local desc_line = vgui.Create("DPanel", descscroller)
        desc_line:SetSize(descscroller:GetWide(), ARC9ScreenScale(9))
        desc_line:Dock(TOP)
        desc_line.Paint = function(self2, w, h)
            surface.SetFont("ARC9_9_Slim")
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetTextPos(ARC9ScreenScale(2), 0)
            surface.DrawText(text)
        end
    end

    local prosscroller = vgui.Create("DScrollPanel", infopanel)
    prosscroller:SetSize(lowerpanel:GetWide()*0.25 - ARC9ScreenScale(3), infopanel:GetTall() - ARC9ScreenScale(4))
    prosscroller:SetPos(lowerpanel:GetWide()*0.5 + ARC9ScreenScale(3), ARC9ScreenScale(3))
    paintthescroller(prosscroller)

    local consscroller = vgui.Create("DScrollPanel", infopanel)
    consscroller:SetSize(lowerpanel:GetWide()*0.25 - ARC9ScreenScale(3), infopanel:GetTall() - ARC9ScreenScale(4))
    consscroller:SetPos(lowerpanel:GetWide()*0.75 + ARC9ScreenScale(3), ARC9ScreenScale(3))
    paintthescroller(consscroller)


    local prosname, prosnum, consname, consnum = ARC9.GetProsAndCons(atttbl, self)

    if table.Count(prosname) > 0 then
        lowerpanel.HasPros = true
        for k, stat in ipairs(prosname) do
            local pro_stat = vgui.Create("DPanel", prosscroller)
            pro_stat:SetSize(prosscroller:GetWide(), ARC9ScreenScale(9))
            pro_stat:Dock(TOP)
            pro_stat.text = stat
            pro_stat.Paint = function(self2, w, h)
                surface.SetFont("ARC9_9")
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.SetTextPos(ARC9ScreenScale(2), 0)
                self:DrawTextRot(self2, self2.text, 0, 0, ARC9ScreenScale(2), 0, w, true)

                local tw = surface.GetTextSize(prosnum[k])
                self:DrawTextRot(self2, prosnum[k], 0, 0, prosscroller:GetWide()-tw-ARC9ScreenScale(6), 0, w, true)
            end
        end
    else
        lowerpanel.HasPros = nil 
    end

    if table.Count(consname) > 0 then
        lowerpanel.HasCons = true
        for k, stat in ipairs(consname) do
            local con_stat = vgui.Create("DPanel", consscroller)
            con_stat:SetSize(consscroller:GetWide(), ARC9ScreenScale(9))
            con_stat:Dock(TOP)
            con_stat.text = stat
            con_stat.Paint = function(self2, w, h)
                surface.SetFont("ARC9_9")
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.SetTextPos(ARC9ScreenScale(2), 0)
                self:DrawTextRot(self2, self2.text, 0, 0, ARC9ScreenScale(2), 0, w, true)

                local tw = surface.GetTextSize(consnum[k])
                self:DrawTextRot(self2, consnum[k], 0, 0, consscroller:GetWide()-tw-ARC9ScreenScale(6), 0, w, true)
            end
        end
    else
        lowerpanel.HasCons = nil 
    end
end