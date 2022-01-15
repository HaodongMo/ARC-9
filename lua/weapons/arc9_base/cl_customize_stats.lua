local function PaintScrollBar(panel, w, h)
    surface.SetDrawColor(ARC9.GetHUDColor("fg"))
    surface.DrawRect(ScreenScale(2), 0, w - ScreenScale(2), h)
end

function SWEP:CreateHUD_Stats()
    local bg = self.CustomizeHUD

    self:ClearTabPanel()

    -- {
    --     title = "Recoil",
    --     stat = "Recoil",
    --     unit = "%",
    --     func = function() return 0 end,
    --     cond = function() return true end
    --     conv = function(a) return a * 100 end
    -- }

    local stats = {
        {
            title = "Recoil",
            unit = "%",
            conv = function(a)
                local recoilup = self:GetValue("RecoilUp")
                local recoilside = self:GetValue("RecoilSide")
                local recoilrup = self:GetValue("RecoilRandomUp")
                local recoilrside = self:GetValue("RecoilRandomSide")

                local rv = recoilup + (recoilside * 1.5) + (recoilrup * 4) + (recoilrside * 4)
                rv = rv * self:GetValue("Recoil")

                rv = rv - (self:GetValue("RecoilAutoControl") * 0.25)

                rv = rv * 15

                rv = math.Round(rv, 0)

                return rv
            end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "Cyclic ROF",
            stat = "RPM",
            unit = "RPM"
        },
        {
            title = "Noise",
            stat = "ShootVolume",
            unit = "dB",
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "Precision",
            stat = "Spread",
            unit = "MoA",
            conv = function(a) return math.Round(a * 360 * 60 / 10, 1) end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "Ammo Type",
            stat = "Ammo",
            conv = function(a) return language.GetPhrase(a .. "_ammo") end
        },
        {
            title = "Capacity",
            stat = "ClipSize",
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end,
            conv = function(a)
                a = tostring(a)

                if self:GetValue("ChamberSize") > 0 then
                    a = a .. "+" .. tostring(self:GetValue("ChamberSize"))
                end

                return a
            end
        },
        {
            title = "Aim Time",
            stat = "AimDownSightsTime",
            unit = "s"
        },
        {
            title = "Sprint To Fire Time",
            stat = "SprintToFireTime",
            unit = "s"
        },
        {
            title = "Penetration",
            stat = "Penetration",
            unit = "mm"
        },
        {
            title = "Fire Modes",
            conv = function(a)
                str = ""

                for i, k in pairs(self:GetValue("Firemodes")) do
                    if k.PrintName then
                        str = str .. k.PrintName .. ", "
                    else
                        if k.Mode then
                            if k.Mode == 0 then
                                str = str .. "SAFE, "
                            elseif k.Mode < 0 then
                                str = str .. "AUTO, "
                            elseif k.Mode == 1 then
                                str = str .. "SEMI, "
                            elseif k.Mode > 1 then
                                str = str .. tostring(k.Mode) .. "-BURST, "
                            end
                        end
                    end
                end

                str = string.sub(str, 1, string.len(str) - 2)

                return str
            end
        }
    }

    local tp = vgui.Create("DScrollPanel", bg)
    tp:SetSize(ScreenScale(150), ScrH() - ScreenScale(76 + 64))
    tp:SetPos(ScrW() - ScreenScale(150 + 12), ScreenScale(76))

    local scroll_preset = tp:GetVBar()
    scroll_preset.Paint = function() end
    scroll_preset.btnUp.Paint = function(span, w, h)
    end
    scroll_preset.btnDown.Paint = function(span, w, h)
    end
    scroll_preset.btnGrip.Paint = PaintScrollBar

    self.TabPanel = tp

    for i, stat in pairs(stats) do
        if stat.cond and stat.cond() then continue end

        local newbtn = tp:Add("DPanel")
        newbtn:SetSize(ScreenScale(150), ScreenScale(26))
        newbtn:Dock(TOP)
        newbtn.stats = stat
        newbtn.Paint = function(self2, w, h)
            -- title
            surface.SetFont("ARC9_8")
            local tw = surface.GetTextSize(self2.stats.title)

            surface.SetFont("ARC9_8")
            surface.SetTextPos(w - tw + ScreenScale(1), ScreenScale(2 + 1))
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            surface.DrawText(self2.stats.title)

            surface.SetFont("ARC9_8")
            surface.SetTextPos(w - tw, ScreenScale(2))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.DrawText(self2.stats.title)

            local tw_u = 0
            -- unit
            if self2.stats.unit then
                surface.SetFont("ARC9_8")
                tw_u = surface.GetTextSize(self2.stats.unit)

                surface.SetFont("ARC9_8")
                surface.SetTextPos(w - tw_u + ScreenScale(1), ScreenScale(16 + 1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(self2.stats.unit)

                surface.SetFont("ARC9_8")
                surface.SetTextPos(w - tw_u, ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(self2.stats.unit)
            end

            local major = ""

            if self2.stats.stat then
                major = self:GetValue(self2.stats.stat)
            end

            if self2.stats.conv then
                major = self2.stats.conv(major)
            end

            major = tostring(major)

            surface.SetFont("ARC9_12")
            tw_p = surface.GetTextSize(major) + tw_u

            surface.SetFont("ARC9_12")
            surface.SetTextPos(w - tw_p + ScreenScale(1), ScreenScale(12 + 1))
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            self:DrawTextRot(self2, major, 0, 0, math.max(w - tw_p + ScreenScale(1), 0), ScreenScale(12 + 1), w)

            surface.SetFont("ARC9_12")
            surface.SetTextPos(w - tw_p, ScreenScale(12))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            self:DrawTextRot(self2, major, 0, 0, math.max(w - tw_p, 0), ScreenScale(12), w, true)
        end
    end
end