local mat_default = Material("arc9/arccw_bird.png")
local mat_new = Material("arc9/plus.png")
local mat_reset = Material("arc9/reset.png")
local mat_export = Material("arc9/arrow_up.png")
local mat_import = Material("arc9/arrow_down.png")
local nextpreset = 0

function SWEP:CreateHUD_Slots(scroll)
    self.CustomizeHUD.lowerpanel:MoveTo(ScreenScale(19), ScrH() - ScreenScale(93), 0.2, 0, 0.5, nil)
    self.CustomizeHUD.lowerpanel:SizeTo(ScrW() - ScreenScale(38), ScreenScale(74), 0.2, 0, 0.5, nil)
    self.CustomizeHUD.lowerpanel.Extended = nil 





    local presetlist = self:GetPresets()


        
    -- local DEBUG_testbutton = vgui.Create("ARC9AttButton", scroll)
    -- DEBUG_testbutton:SetPos(ScreenScale(100), ScreenScale(0))
    -- DEBUG_testbutton:SetButtonText("Muzzle")

    for _, preset in pairs(presetlist) do
        if preset == "autosave" or preset == "default" then continue end
        local filename = ARC9.PresetPath .. self:GetPresetBase() .. "/" .. preset .. "." .. ARC9.PresetIconFormat
        local btn = vgui.Create("DButton", scroll)
        btn:SetSize(ScreenScale(48), ScreenScale(48))
        btn:DockMargin(ScreenScale(2), 0, 0, 0)
        btn:Dock(LEFT)
        btn:SetText("")
        scroll:AddPanel(btn)
        btn.preset = preset

        if file.Exists(filename, "DATA") then
            btn.icon = Material("data/" .. filename, "smooth")
        end

        btn.DoClick = function(self2)
            self:LoadPreset(preset)
            surface.PlaySound("arc9/preset_install.ogg")
        end

        btn.DoRightClick = function(self2)
            self:DeletePreset(preset)
            surface.PlaySound("arc9/preset_delete.ogg")
            self:CreateHUD_Bottom()
        end

        btn.Paint = function(self2, w, h)
            if !IsValid(self) then return end

            local col1 = ARC9.GetHUDColor("fg")
            local icon = self2.icon or mat_default
            local hasbg = false

            if self2:IsHovered() then
                self.CustomizeHints["Select"]   = "Load"
                self.CustomizeHints["Deselect"] = "Delete"
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

            preset = string.upper(preset)

            if !hasbg then
                surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(ScreenScale(2), ScreenScale(2), w - ScreenScale(1), h - ScreenScale(1))

                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.SetTextPos(ScreenScale(14), ScreenScale(1))
                surface.SetFont("ARC9_10")
                self:DrawTextRot(self2, preset, 0, 0, ScreenScale(3), ScreenScale(1), ScreenScale(46), true)
            end

            surface.SetDrawColor(col1)
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(ScreenScale(1), ScreenScale(1), w - ScreenScale(1), h - ScreenScale(1))

            surface.SetTextColor(col1)
            surface.SetTextPos(ScreenScale(13), 0)
            surface.SetFont("ARC9_10")
            self:DrawTextRot(self2, preset, 0, 0, ScreenScale(2), 0, ScreenScale(46), false)
        end
    end
end