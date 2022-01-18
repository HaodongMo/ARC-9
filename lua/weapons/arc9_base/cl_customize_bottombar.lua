local function PaintScrollBar(panel, w, h)
    surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
    surface.DrawRect(ScreenScale(3), 0 + ScreenScale(1), w - ScreenScale(3), h)

    surface.SetDrawColor(ARC9.GetHUDColor("fg"))
    surface.DrawRect(ScreenScale(2), 0, w - ScreenScale(3), h - ScreenScale(1))
end

SWEP.BottomBar = nil

-- 0: Preset
-- 1: Attachment
SWEP.BottomBarMode = 0

SWEP.BottomBarAddress = 0

function SWEP:ClearBottomBar()
    if self.BottomBar then
        self.BottomBar:Remove()
        self.BottomBar = nil
    end

    self:ClearAttInfoBar()
end

function SWEP:CreateHUD_Bottom()
    local bg = self.CustomizeHUD

    self:ClearBottomBar()

    self.AttInfoBarAtt = nil

    local bp = vgui.Create("DPanel", bg)
    bp:SetSize(ScrW(), ScreenScale(62))
    bp:SetPos(0, ScrH() - ScreenScale(62))
    bp.Paint = function(self2, w, h)
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
        end

        surface.SetFont("ARC9_8")
        surface.SetTextColor(ARC9.GetHUDColor("shadow"))
        surface.SetTextPos(ScreenScale(8 + 4), 0)
        surface.DrawText(bartxt)
    end

    self.BottomBar = bp

    local scroll = vgui.Create("DHorizontalScroller", bp)
    scroll:SetPos(0, ScreenScale(12))
    scroll:SetSize(ScrW(), ScreenScale(48))

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

        table.sort(atts, function(a, b)
            a = a or ""
            b = b or ""

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

        for _, att in pairs(atts) do
            local atttbl = ARC9.GetAttTable(att)

            local attbtn = vgui.Create("DButton", scroll)
            attbtn:SetSize(ScreenScale(48), ScreenScale(48))
            attbtn:DockMargin(ScreenScale(2), 0, 0, 0)
            attbtn:Dock(LEFT)
            attbtn:SetText("")
            attbtn.att = att
            attbtn.address = slottbl.Address
            attbtn.slottbl = slottbl
            attbtn.OnMousePressed = function(self2, kc)
                if kc == MOUSE_LEFT then
                    self:Attach(self2.address, self2.att)
                    self.CustomizeSelectAddr = self2.address
                elseif kc == MOUSE_RIGHT then
                    self:Detach(self2.address)
                    self.CustomizeSelectAddr = self2.address
                end
            end
            attbtn.Paint = function(self2, w, h)
                if !IsValid(self) then return end

                local slot = self:LocateSlotFromAddress(self2.address)

                if !slot then return end
                if slot.Category != self2.slottbl.Category then
                    self:ClearAttInfoBar()
                    self:ClearBottomBar()
                    self.BottomBarAddress = nil
                    self.AttInfoBarAtt = nil
                    return
                end

                local attached = slot.Installed == self2.att

                local col1 = ARC9.GetHUDColor("fg")

                local hasbg = false

                if self2:IsHovered() or attached then
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

                surface.SetDrawColor(col1)
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(ScreenScale(1), ScreenScale(1), w - ScreenScale(1), h - ScreenScale(1))

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