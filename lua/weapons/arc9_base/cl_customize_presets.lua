local mat_default = Material("arc9/hit.png")

function SWEP:CreateHUD_Presets(scroll)
    for _, preset in pairs(self:GetPresets()) do
        local btn = vgui.Create("DButton", scroll)
        btn:SetSize(ScreenScale(48), ScreenScale(48))
        btn:DockMargin(ScreenScale(2), 0, 0, 0)
        btn:Dock(LEFT)
        btn:SetText("")
        scroll:AddPanel(btn)
        btn.preset = preset
        btn.OnMousePressed = function(self2, kc)
            self:LoadPreset(preset)
        end
        btn.Paint = function(self2, w, h)
            local col1 = ARC9.GetHUDColor("fg")
            local name = self2.preset
            local icon = mat_default

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
    end
end