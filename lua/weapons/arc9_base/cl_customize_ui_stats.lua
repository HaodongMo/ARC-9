local ARC9ScreenScale = ARC9.ScreenScale

local function GetTrueRPM(self)
    if self:GetCapacity() == 1 then
        local reloadtime = self:GetProcessedValue("ReloadTime") * self:GetAnimationTime("reload")

        local a = 60 / reloadtime

        a = math.Round(a, 0)

        return a
    else
        local a = self:GetProcessedValue("RPM")
        local delay = 60 / a

        if self:GetProcessedValue("TriggerDelayRepeat") then
            delay = math.max(self:GetProcessedValue("TriggerDelayTime"), delay)
        end

        if self:GetProcessedValue("ManualAction") then
            delay = delay + (self:GetAnimationTime("cycle") * self:GetProcessedValue("CycleTime"))
        end

        if self:GetCurrentFiremode() > 1 then
            local pbd = self:GetProcessedValue("PostBurstDelay")
            local burstlength = self:GetCurrentFiremode()

            delay = delay + (pbd / burstlength)
        end

        a = 60 / delay

        a = math.Round(a / 50, 0) * 50

        return a
    end
end

function SWEP:CreateHUD_Stats()
    local lowerpanel = self.CustomizeHUD.lowerpanel

    -- if true then return end
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
            title = "customize.stats.firepower",
            unit = "unit.dmg",
            fifty = 50,
            conv = function(a)
                local dv = self:GetProcessedValue("DamageMax")

                dv = math.Round(dv, 0)

                if self:GetProcessedValue("Num") > 1 then
                    dv = dv .. " x " .. tostring(self:GetProcessedValue("Num"))
                end

                return dv
            end,
            cond = function()
                return self:GetProcessedValue("ShootEnt")
            end,
        },
        {
            title = "customize.stats.rof",
            stat = "RPM",
            fifty = 600,
            unit = "unit.rpm",
            conv = function(a)
                local cyclic = self:GetProcessedValue("RPM")
                a = GetTrueRPM(self)

                local str = ""

                if cyclic != a then
                    str = "~"
                end

                return str .. tostring(a)
            end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end,
        },
        {
            title = "customize.stats.cyclic",
            stat = "RPM",
            fifty = 600,
            unit = "unit.rpm",
            conv = function(a)
                a = math.Round(a / 50, 0) * 50

                return a
            end,
            cond = function()
                return self:GetProcessedValue("RPM") == GetTrueRPM(self) or self:GetProcessedValue("ManualAction") or self:GetCapacity() == 1
            end,
        },
        {
            title = "customize.stats.capacity",
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
            title = "customize.stats.range",
            unit = "unit.meter",
            fifty = 500,
            stat = "RangeMax",
            conv = function(a)
                return a * ARC9.HUToM
            end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash") or self:GetProcessedValue("ShootEnt")
            end
        },
        {
            title = "customize.stats.precision",
            stat = "Spread",
            fifty = 5,
            unit = "unit.moa",
            conv = function(a) return math.Round(a * 360 * 60 / 10, 1) end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash") or self:GetProcessedValue("Spread") == 0
            end
        },
        {
            title = "customize.stats.muzzlevelocity",
            stat = "PhysBulletMuzzleVelocity",
            fifty = 500,
            unit = "unit.meterpersecond",
            conv = function(a) return math.Round(a * ARC9.HUToM) end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash") or self:GetProcessedValue("ShootEnt")
            end
        },


        {
            title = "customize.stats.ammo",
            stat = "Ammo",
            conv = function(a) return language.GetPhrase(a .. "_ammo") end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "customize.stats.penetration",
            stat = "Penetration",
            fifty = 50,
            unit = "unit.millimeter",
            cond = function()
                return self:GetProcessedValue("PrimaryBash") or self:GetProcessedValue("ShootEnt")
            end
        },
        {
            title = "customize.stats.ricochet",
            stat = "RicochetChance",
            fifty = 50,
            unit = "%",
            conv = function(a) return math.Round(a * 100, 0) end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash") or self:GetProcessedValue("ShootEnt")
            end
        },
        {
            title = "customize.stats.armorpiercing",
            stat = "ArmorPiercing",
            fifty = 25,
            unit = "%",
            conv = function(a) return math.Round(a * 100, 0) end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash") or self:GetProcessedValue("ShootEnt")
            end
        },
        {
            title = "customize.stats.explosive",
            stat = "ExplosionDamage",
            fifty = 50,
            unit = "unit.dmg",
            conv = function(a) return math.Round(a, 0) end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash") or self:GetProcessedValue("ShootEnt") or self:GetProcessedValue("ExplosionDamage") <= 0
            end
        },
        {
            title = "customize.stats.speed",
            stat = "SpeedMult",
            fifty = 95,
            unit = "%",
            conv = function(a) return math.Round(a * 100, 0) end,
        },
        {
            title = "customize.stats.aimtime",
            stat = "AimDownSightsTime",
            fifty = 0.3,
            unit = "unit.second",
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "customize.stats.sprinttofire",
            stat = "SprintToFireTime",
            fifty = 0.3,
            unit = "unit.second"
        },
        -- {
        --     title = "Projectile Count",
        --     fifty = 3,
        --     stat = "Num",
        --     unit = "",
        --     cond = function()
        --         return self:GetProcessedValue("Num") <= 1
        --     end
        -- },
        -- {
        --     title = "Recoil",
        --     unit = "%",
        --     fifty = 75,
        --     conv = function(a)
        --         local recoilup = self:GetProcessedValue("RecoilUp")
        --         local recoilside = self:GetProcessedValue("RecoilSide")
        --         local recoilrup = self:GetProcessedValue("RecoilRandomUp")
        --         local recoilrside = self:GetProcessedValue("RecoilRandomSide")

        --         local rv = recoilup + (recoilside * 1.5) + (recoilrup * 4) + (recoilrside * 4)
        --         rv = rv * self:GetProcessedValue("Recoil")

        --         rv = rv - (self:GetProcessedValue("RecoilAutoControl") * 0.25)

        --         rv = rv * 15

        --         rv = math.Round(rv, 0)

        --         return rv
        --     end,
        --     cond = function()
        --         return self:GetProcessedValue("PrimaryBash")
        --     end
        -- },
        {
            title = "customize.stats.firemodes",
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
        },
        {
            title = "customize.stats.burstdelay",
            stat = "PostBurstDelay",
            fifty = 0.1,
            unit = "unit.second",
            cond = function()
                return self:GetProcessedValue("PrimaryBash") or self:GetProcessedValue("PostBurstDelay") <= 0 or self:GetCapacity() == 0
            end
        },
        {
            title = "customize.stats.triggerdelay",
            stat = "TriggerDelayTime",
            fifty = 0.1,
            unit = "unit.second",
            cond = function()
                return self:GetProcessedValue("PrimaryBash") or self:GetProcessedValue("TriggerDelayTime") <= 0 or !self:GetProcessedValue("TriggerDelay")
            end
        },
        {
            title = "customize.stats.noise",
            stat = "ShootVolume",
            fifty = 100,
            unit = "unit.decibel",
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end
        },
        {
            title = "customize.stats.sway",
            stat = "Sway",
            fifty = 95,
            unit = "%",
            conv = function(a) return math.Round(a * 60, 0) end,
            cond = function()
                return self:GetProcessedValue("PrimaryBash") or !GetConVar("arc9_mod_sway"):GetBool()
            end
        },
        {
            title = "customize.stats.freeaim",
            stat = "FreeAimRadius",
            fifty = 20,
            unit = "°",
            cond = function()
                return self:GetProcessedValue("PrimaryBash") or !GetConVar("arc9_mod_freeaim"):GetBool()
            end
        },
        {
            title = "customize.stats.supplylimit",
            stat = "SupplyLimit",
            fifty = 3,
            cond = function()
                return self:GetProcessedValue("PrimaryBash")
            end,
            conv = function(a) return math.Round(a, 0) end,
            unit = ""
        },
    }


    local statsspanel = vgui.Create("DPanel", lowerpanel)
    statsspanel:SetPos(ARC9ScreenScale(60), ARC9ScreenScale(20))
    statsspanel:SetSize(lowerpanel:GetWide()*0.8, ARC9ScreenScale(98))
    statsspanel.Paint = function(self2, w, h)
        -- surface.SetDrawColor(144, 0, 0, 100)
        -- surface.DrawRect(0, 0, w, h)
    end

    statsspanel:SetAlpha(0)
    statsspanel:AlphaTo(255, 0.2, 0, nil)

    self.BottomBar = statsspanel

    local realI = 0
    
    local many = false                -- probably not the best way
    for i, stat in ipairs(stats) do 
        if stat.cond and stat.cond() then continue end 
        realI = realI + 1
        if realI>6 then many = true end 
    end
    
    realI = 0
    
    for i, stat in ipairs(stats) do
        if stat.cond and stat.cond() then continue end
        realI = realI + 1
        
        local statpanel = vgui.Create("DPanel", statsspanel )
        statpanel:SetSize(ARC9ScreenScale(120), ARC9ScreenScale(16))

        if !many then 
            statpanel:SetPos(statsspanel:GetWide()*0.5-ARC9ScreenScale(60), ARC9ScreenScale(16.5) * realI - ARC9ScreenScale(16))
        else
            if realI > 12 then
                statpanel:SetPos(statsspanel:GetWide()-ARC9ScreenScale(120), ARC9ScreenScale(16.5) * (realI-12) - ARC9ScreenScale(16))
            elseif realI > 6 then
                statpanel:SetPos(statsspanel:GetWide()*0.5-ARC9ScreenScale(60), ARC9ScreenScale(16.5) * (realI-6) - ARC9ScreenScale(16))
            else
                statpanel:SetPos(0, ARC9ScreenScale(16.5) * realI - ARC9ScreenScale(16))
            end
        end

        statpanel.stats = stat
        statpanel.ri = realI
        statpanel.Paint = function(self2, w, h)
            if self2.ri%2==1 then
                surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100))
                surface.DrawRect(0, 0, w, h)
            end
            surface.SetFont("ARC9_10_Slim")
            surface.SetTextPos(ARC9ScreenScale(2), ARC9ScreenScale(2))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.DrawText(ARC9:GetPhrase(self2.stats.title) or self2.stats.title)

            local tw_u = 0
            if self2.stats.unit then
                surface.SetFont("ARC9_8")
                tw_u = surface.GetTextSize(ARC9:GetPhrase(self2.stats.unit) or self2.stats.unit)

                surface.SetTextPos(w - tw_u - ARC9ScreenScale(2), ARC9ScreenScale(3))
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawText(ARC9:GetPhrase(self2.stats.unit) or self2.stats.unit)
                
                tw_u = tw_u + ARC9ScreenScale(4)
            else
                tw_u = ARC9ScreenScale(2)
            end

            local major = ""
            if self2.stats.stat then major = self:GetValue(self2.stats.stat) end
            if self2.stats.conv then major = self2.stats.conv(major) end
            if isnumber(major) then major = math.Round(major, 2) end
            local oldmajor = major
            major = tostring(major)

            surface.SetFont("ARC9_10")
            local tw = surface.GetTextSize(major)
            surface.SetTextPos(w-tw-tw_u, ARC9ScreenScale(2))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.DrawText(major)
        end
    end

    --[[
    local tp = vgui.Create("DScrollPanel", bg)
    tp:SetSize(ARC9ScreenScale(150), ScrH() - ARC9ScreenScale(76 + 4))
    tp:SetPos(ScrW() - ARC9ScreenScale(150 + 12), ARC9ScreenScale(76))
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
        newbtn:SetSize(ARC9ScreenScale(150), ARC9ScreenScale(27))
        newbtn:Dock(TOP)
        newbtn.stats = stat
        newbtn.Paint = function(self2, w, h)
            if !IsValid(self) then return end
            -- title
            surface.SetFont("ARC9_8")
            local tw = surface.GetTextSize(self2.stats.title)

            surface.SetFont("ARC9_8")
            surface.SetTextPos(w - tw - ARC9ScreenScale(1), ARC9ScreenScale(2 + 1))
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            surface.DrawText(self2.stats.title)

            surface.SetFont("ARC9_8")
            surface.SetTextPos(w - tw - ARC9ScreenScale(2), ARC9ScreenScale(2))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.DrawText(self2.stats.title)

            local tw_u = 0
            -- unit
            if self2.stats.unit then
                surface.SetFont("ARC9_8")
                tw_u = surface.GetTextSize(self2.stats.unit)

                surface.SetFont("ARC9_8")
                surface.SetTextPos(w - tw_u - ARC9ScreenScale(2) + ARC9ScreenScale(1), ARC9ScreenScale(16 + 1))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(self2.stats.unit)

                surface.SetFont("ARC9_8")
                surface.SetTextPos(w - tw_u - ARC9ScreenScale(2), ARC9ScreenScale(16))
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
            surface.SetTextPos(w - tw_p - ARC9ScreenScale(2), ARC9ScreenScale(12 + 1))
            surface.SetTextColor(ARC9.GetHUDColor("shadow"))
            self:DrawTextRot(self2, major, 0, 0, math.max(w - tw_p - ARC9ScreenScale(2), 0), ARC9ScreenScale(12 + 1), w)

            surface.SetFont("ARC9_12")
            surface.SetTextPos(w - tw_p - ARC9ScreenScale(3), ARC9ScreenScale(12))
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            self:DrawTextRot(self2, major, 0, 0, math.max(w - tw_p - ARC9ScreenScale(3), 0), ARC9ScreenScale(12), w, true)

            if self2.stats.fifty and isnumber(oldmajor) then
                local mapped = -(1 / ((oldmajor / self2.stats.fifty) + 1)) + 1

                surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
                surface.DrawRect(ARC9ScreenScale(1), ARC9ScreenScale(12 + 1), ARC9ScreenScale(1), ARC9ScreenScale(13))

                surface.SetDrawColor(ARC9.GetHUDColor("fg"))
                surface.DrawRect(0, ARC9ScreenScale(12), ARC9ScreenScale(1), ARC9ScreenScale(13))

                local shortw = w - ARC9ScreenScale(1)

                local barw = mapped * shortw

                surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
                surface.DrawRect(shortw - barw + ARC9ScreenScale(1), ARC9ScreenScale(12 + 1), barw, ARC9ScreenScale(13))

                surface.SetDrawColor(ARC9.GetHUDColor("fg"))
                surface.DrawRect(shortw - barw, ARC9ScreenScale(12), barw, ARC9ScreenScale(13))

                local screenx, screeny = self2:LocalToScreen(shortw - barw, ARC9ScreenScale(12 + 1))

                render.SetScissorRect(screenx, screeny, screenx + barw, screeny + ARC9ScreenScale(12), true)

                surface.SetFont("ARC9_8")
                surface.SetTextPos(w - tw_u - ARC9ScreenScale(2), ARC9ScreenScale(16))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                surface.DrawText(self2.stats.unit)

                surface.SetFont("ARC9_12")
                surface.SetTextPos(w - tw_p - ARC9ScreenScale(2), ARC9ScreenScale(12))
                surface.SetTextColor(ARC9.GetHUDColor("shadow"))
                self:DrawTextRot(self2, major, 0, 0, math.max(w - tw_p - ARC9ScreenScale(2), 0), ARC9ScreenScale(12), w, true)

                render.SetScissorRect(0, 0, 0, 0, false)
            end
        end
    end

    ]]--
end