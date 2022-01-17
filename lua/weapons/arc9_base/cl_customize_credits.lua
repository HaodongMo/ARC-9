local function PaintScrollBar(panel, w, h)
    surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
    surface.DrawRect(ScreenScale(3), 0 + ScreenScale(1), w - ScreenScale(3), h)

    surface.SetDrawColor(ARC9.GetHUDColor("fg"))
    surface.DrawRect(ScreenScale(2), 0, w - ScreenScale(3), h - ScreenScale(1))
end

function SWEP:CreateHUD_Credits()
    local bg = self.CustomizeHUD

    self:ClearTabPanel()

    local tp = vgui.Create("DScrollPanel", bg)
    tp:SetSize(ScreenScale(400), ScrH() - ScreenScale(76 + 4))
    tp:SetPos(ScrW() - ScreenScale(400 + 12), ScreenScale(76))
    tp.Paint = function(self2, w, h)
    end

    local scroll_preset = tp:GetVBar()
    scroll_preset.Paint = function() end
    scroll_preset.btnUp.Paint = function(span, w, h)
    end
    scroll_preset.btnDown.Paint = function(span, w, h)
    end
    scroll_preset.btnGrip.Paint = PaintScrollBar

    self.TabPanel = tp

    for title, trivia in pairs(self.Credits) do
        if title == "BaseClass" then continue end
        local newbtn2 = tp:Add("DPanel")
        newbtn2:SetSize(ScreenScale(200), ScreenScale(27))
        newbtn2:Dock(TOP)
        newbtn2.title = title
        newbtn2.trivia = trivia
        newbtn2.Paint = function(self2, w, h)
            -- title
            surface.SetFont("ARC9_8")
            local tw = surface.GetTextSize(self2.title)

            surface.SetFont("ARC9_8")
            surface.SetTextPos(w - tw - ScreenScale(1), ScreenScale(2 + 1))
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            surface.DrawText(self2.title)

            surface.SetFont("ARC9_8")
            surface.SetTextPos(w - tw - ScreenScale(2), ScreenScale(2))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.DrawText(self2.title)

            local major = self2.trivia

            surface.SetFont("ARC9_12")
            tw_p = surface.GetTextSize(major)

            surface.SetFont("ARC9_12")
            surface.SetTextPos(w - tw_p - ScreenScale(1), ScreenScale(12))
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            self:DrawTextRot(self2, major, 0, 0, math.max(w - tw_p - ScreenScale(1), ScreenScale(1)), ScreenScale(12 + 1), w)

            surface.SetFont("ARC9_12")
            surface.SetTextPos(w - tw_p - ScreenScale(2), ScreenScale(12))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            self:DrawTextRot(self2, major, 0, 0, math.max(w - tw_p - ScreenScale(2), 0), ScreenScale(12), w, true)
        end
    end
end