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
end

function SWEP:CreateHUD_Bottom()
    local bg = self.CustomizeHUD

    self:ClearBottomBar()

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
                return (atttbl_a.PrintName or "") < (atttbl_b.PrintName or "")
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
                local slot = self:LocateSlotFromAddress(self2.address)
                local attached = slot.Installed == self2.att

                local col1 = ARC9.GetHUDColor("fg")

                local hasbg = false

                if self2:IsHovered() or attached then
                    col1 = ARC9.GetHUDColor("shadow")

                    surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
                    surface.DrawRect(ScreenScale(1), ScreenScale(1), w - ScreenScale(1), h - ScreenScale(1))

                    surface.SetDrawColor(ARC9.GetHUDColor("fg"))
                    surface.DrawRect(0, 0, w - ScreenScale(1), h - ScreenScale(1))

                    hasbg = true
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

                surface.SetDrawColor(col1)
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(ScreenScale(1), ScreenScale(1), w - ScreenScale(1), h - ScreenScale(1))

                if !hasbg then
                    surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                    surface.SetTextPos(ScreenScale(14), ScreenScale(1))
                    surface.SetFont("ARC9_10")
                    self:DrawTextRot(self2, atttbl.CompactName or atttbl.PrintName or atttbl.ShortName, 0, 0, ScreenScale(3), ScreenScale(1), ScreenScale(46), true)
                end

                surface.SetTextColor(col1)
                surface.SetTextPos(ScreenScale(13), 0)
                surface.SetFont("ARC9_10")
                self:DrawTextRot(self2, atttbl.CompactName or atttbl.PrintName or atttbl.ShortName, 0, 0, ScreenScale(2), 0, ScreenScale(46), false)
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

    self:ClearAttInfoBar()

    local bp = vgui.Create("DPanel", bg)
    bp:SetSize(ScrW() / 3, ScrH() - ScreenScale(64 + ScreenScale(4)))
    bp:SetPos(ScreenScale(4), ScreenScale(4))
    bp.Paint = function(self2, w, h)
        local atttbl = ARC9.GetAttTable(self.AttInfoBarAtt)

        local title = atttbl.PrintName

        surface.SetFont("ARC9_24")
        surface.SetTextPos(0, 0)
        surface.SetTextColor(ARC9.GetHUDColor("shadow"))
        self:DrawTextRot(self2, title, 0, 0, ScreenScale(1), ScreenScale(1), w, false)

        surface.SetFont("ARC9_24")
        surface.SetTextPos(0, 0)
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        self:DrawTextRot(self2, title, 0, 0, 0, 0, w, true)

        surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
        surface.DrawRect(ScreenScale(1), ScreenScale(27), w - ScreenScale(1), ScreenScale(1))

        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.DrawRect(0, ScreenScale(26), w - ScreenScale(1), ScreenScale(1))
    end

    self.AttInfoBar = bp
end