local function PaintScrollBar(panel, w, h)
    surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
    surface.DrawRect(ScreenScale(3), 0 + ScreenScale(1), w - ScreenScale(3), h)

    surface.SetDrawColor(ARC9.GetHUDColor("fg"))
    surface.DrawRect(ScreenScale(2), 0, w - ScreenScale(3), h - ScreenScale(1))
end

function SWEP:CreateHUD_Stats()
    local bg = self.CustomizeHUD

    self:ClearTabPanel()

    -- {
    --     title = "Recoil",
    --     stat = "Recoil",
    --     unit = "%",
    --     fifty = 5, # value for "50%" point on stat bar, logistic from then on
    --     func = function() return 0 end,
    --     cond = function() return true end
    --     conv = function(a) return a * 100 end
    -- }

    local stats = {
        {
            title = "Firepower",
            unit = "DMG",
            fifty = 50,
            conv = function(a)
                local dv = self:GetProcessedValue("DamageMax")

                dv = math.Round(dv, 0)

                return dv
            end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "Range",
            unit = "M",
            fifty = 500,
            stat = "RangeMax",
            conv = function(a)
                return a * ARC9.HUToM
            end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "Recoil",
            unit = "%",
            fifty = 75,
            conv = function(a)
                local recoilup = self:GetProcessedValue("RecoilUp")
                local recoilside = self:GetProcessedValue("RecoilSide")
                local recoilrup = self:GetProcessedValue("RecoilRandomUp")
                local recoilrside = self:GetProcessedValue("RecoilRandomSide")

                local rv = recoilup + (recoilside * 1.5) + (recoilrup * 4) + (recoilrside * 4)
                rv = rv * self:GetProcessedValue("Recoil")

                rv = rv - (self:GetProcessedValue("RecoilAutoControl") * 0.25)

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
            fifty = 600,
            unit = "RPM",
            conv = function(a) return math.Round(a / 50, 0) * 50 end,
        },
        {
            title = "Burst Delay",
            stat = "PostBurstDelay",
            fifty = 0.1,
            unit = "s",
            cond = function()
                return self:GetProcessedValue("PrimaryBash") or self:GetProcessedValue("PostBurstDelay") <= 0
            end
        },
        {
            title = "Noise",
            stat = "ShootVolume",
            fifty = 100,
            unit = "dB",
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "Precision",
            stat = "Spread",
            fifty = 5,
            unit = "MoA",
            conv = function(a) return math.Round(a * 360 * 60 / 10, 1) end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "Muzzle Velocity",
            stat = "PhysBulletMuzzleVelocity",
            fifty = 500,
            unit = "m/s",
            conv = function(a) return math.Round(a * ARC9.HUToM) end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "Aim Time",
            stat = "AimDownSightsTime",
            fifty = 0.3,
            unit = "s",
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "Sprint To Fire Time",
            stat = "SprintToFireTime",
            fifty = 0.3,
            unit = "s"
        },
        {
            title = "Sway",
            stat = "Sway",
            fifty = 95,
            unit = "%",
            conv = function(a) return math.Round(a * 60, 0) end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "Free Aim Radius",
            stat = "FreeAimRadius",
            fifty = 20,
            unit = "°",
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "Movement Speed",
            stat = "SpeedMult",
            fifty = 95,
            unit = "%",
            conv = function(a) return math.Round(a * 100, 0) end,
        },
        {
            title = "Penetration",
            stat = "Penetration",
            fifty = 50,
            unit = "mm"
        },
        {
            title = "Armor Piercing",
            stat = "ArmorPiercing",
            fifty = 25,
            unit = "%",
            conv = function(a) return math.Round(a * 100, 0) end,
        },
        {
            title = "Ammo Type",
            stat = "Ammo",
            conv = function(a) return language.GetPhrase(a .. "_ammo") end
        },
        {
            title = "Capacity",
            stat = "ClipSize",
            fifty = 20,
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end,
            conv = function(a)
                a = tostring(a)

                if self:GetProcessedValue("ChamberSize") > 0 then
                    a = a .. "+" .. tostring(self:GetProcessedValue("ChamberSize"))
                end

                return a
            end
        },
        {
            title = "Supply Limit",
            stat = "SupplyLimit",
            fifty = 3,
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end,
            conv = function(a) return math.Round(a, 0) end,
            unit = ""
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
    tp:SetSize(ScreenScale(150), ScrH() - ScreenScale(76 + 4))
    tp:SetPos(ScrW() - ScreenScale(150 + 12), ScreenScale(76))
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

    for i, stat in pairs(stats) do
        if stat.cond and stat.cond() then continue end

        local newbtn = tp:Add("DPanel")
        newbtn:SetSize(ScreenScale(150), ScreenScale(27))
        newbtn:Dock(TOP)
        newbtn.stats = stat
        newbtn.Paint = function(self2, w, h)
            -- title
            surface.SetFont("ARC9_8")
            local tw = surface.GetTextSize(self2.stats.title)

            surface.SetFont("ARC9_8")
            surface.SetTextPos(w - tw - ScreenScale(1), ScreenScale(2 + 1))
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            surface.DrawText(self2.stats.title)

            surface.SetFont("ARC9_8")
            surface.SetTextPos(w - tw - ScreenScale(2), ScreenScale(2))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.DrawText(self2.stats.title)

            local tw_u = 0
            -- unit
            if self2.stats.unit then
                surface.SetFont("ARC9_8")
                tw_u = surface.GetTextSize(self2.stats.unit)

                surface.SetFont("ARC9_8")
                surface.SetTextPos(w - tw_u - ScreenScale(2) + ScreenScale(1), ScreenScale(16 + 1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(self2.stats.unit)

                surface.SetFont("ARC9_8")
                surface.SetTextPos(w - tw_u - ScreenScale(2), ScreenScale(16))
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

            if isnumber(major) then
                major = math.Round(major, 2)
            end

            local oldmajor = major

            major = tostring(major)

            surface.SetFont("ARC9_12")
            tw_p = surface.GetTextSize(major) + tw_u

            surface.SetFont("ARC9_12")
            surface.SetTextPos(w - tw_p - ScreenScale(2), ScreenScale(12 + 1))
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            self:DrawTextRot(self2, major, 0, 0, math.max(w - tw_p - ScreenScale(2), 0), ScreenScale(12 + 1), w)

            surface.SetFont("ARC9_12")
            surface.SetTextPos(w - tw_p - ScreenScale(3), ScreenScale(12))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            self:DrawTextRot(self2, major, 0, 0, math.max(w - tw_p - ScreenScale(3), 0), ScreenScale(12), w, true)

            if self2.stats.fifty and isnumber(oldmajor) then
                local mapped = -(1 / ((oldmajor / self2.stats.fifty) + 1)) + 1

                surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
                surface.DrawRect(ScreenScale(1), ScreenScale(12 + 1), ScreenScale(1), ScreenScale(13))

                surface.SetDrawColor(ARC9.GetHUDColor("fg"))
                surface.DrawRect(0, ScreenScale(12), ScreenScale(1), ScreenScale(13))

                local shortw = w - ScreenScale(1)

                local barw = mapped * shortw

                surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
                surface.DrawRect(shortw - barw + ScreenScale(1), ScreenScale(12 + 1), barw, ScreenScale(13))

                surface.SetDrawColor(ARC9.GetHUDColor("fg"))
                surface.DrawRect(shortw - barw, ScreenScale(12), barw, ScreenScale(13))

                local screenx, screeny = self2:LocalToScreen(shortw - barw, ScreenScale(12 + 1))

                render.SetScissorRect(screenx, screeny, screenx + barw, screeny + ScreenScale(12), true)

                surface.SetFont("ARC9_8")
                surface.SetTextPos(w - tw_u - ScreenScale(2), ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(self2.stats.unit)

                surface.SetFont("ARC9_12")
                surface.SetTextPos(w - tw_p - ScreenScale(2), ScreenScale(12))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                self:DrawTextRot(self2, major, 0, 0, math.max(w - tw_p - ScreenScale(2), 0), ScreenScale(12), w, true)

                render.SetScissorRect(0, 0, 0, 0, false)
            end
        end
    end
end