local function PaintScrollBar(panel, w, h)
    surface.SetDrawColor(ARC9.GetHUDColor("shadow"))
    surface.DrawRect(ScreenScale(3), 0 + ScreenScale(1), w - ScreenScale(3), h)

    surface.SetDrawColor(ARC9.GetHUDColor("fg"))
    surface.DrawRect(ScreenScale(2), 0, w - ScreenScale(3), h - ScreenScale(1))
end

-- given fov and distance solve apparent size
local function solvetriangle(angle, dist)
    local a = angle / 2
    local b = dist
    return b * math.tan(a) * 2
end

local hits_1 = {}
local hits_3 = {}

local function rollhit(radius)
    local anglerand = math.Rand(0, 360)
    local dist = math.Rand(0, radius)

    local hit_x = math.sin(anglerand) * dist
    local hit_y = math.cos(anglerand) * dist

    return {x = hit_x, y = hit_y}
end

local function rollallhits(self, range_3, range_1)

    hits_1 = {}
    hits_3 = {}

    local ang = self:GetValue("Spread") * 10 / 360

    local radius_1 = solvetriangle(ang, range_1)
    local radius_3 = solvetriangle(ang, range_3)

    local hitcount = math.Clamp(math.max(math.Round(self:GetCapacity(self:GetUBGL()) / 4), math.Round(self:GetValue("Num") * 2)), 10, 20)

    for i = 1, hitcount do
        table.insert(hits_1, rollhit(radius_1))
    end

    for i = 1, hitcount do
        table.insert(hits_3, rollhit(radius_3))
    end
end

local bullseye = Material("arc9/bullseye.png", "mips smooth")
local mat_hit = Material("arc9/hit.png", "mips smooth")
local mat_hit_dot = Material("arc9/hit_dot.png", "mips smooth")

function SWEP:CreateHUD_Bench()
    local bg = self.CustomizeHUD

    self:ClearTabPanel()

    local tp = vgui.Create("DScrollPanel", bg)
    tp:SetSize(ScreenScale(200), ScrH() - ScreenScale(76 + 4))
    tp:SetPos(ScrW() - ScreenScale(200 + 12), ScreenScale(76))

    local scroll_preset = tp:GetVBar()
    scroll_preset.Paint = function() end
    scroll_preset.btnUp.Paint = function(span, w, h)
    end
    scroll_preset.btnDown.Paint = function(span, w, h)
    end
    scroll_preset.btnGrip.Paint = PaintScrollBar

    self.TabPanel = tp

    local ranger = vgui.Create("DPanel", tp)
    ranger:SetPos(0, 0)
    ranger:SetSize(ScreenScale(200), ScreenScale(100))
    ranger.Paint = function(self2, w, h)
        if !IsValid(self) then return end

        surface.SetDrawColor(ARC9.GetHUDColor("bg", 50))
        surface.DrawRect(0, 0, w, h)

        local dmg_max = self:GetValue("DamageMax")
        local dmg_min = self:GetValue("DamageMin")

        local range_min = self:GetValue("RangeMin")
        local range_max = self:GetValue("RangeMax")

        surface.SetDrawColor(ARC9.GetHUDColor("fg", 75))

        local range_1_y = 2 * (h / 5)
        local range_2_y = 4 * (h / 5)

        local range_1_x = 0
        local range_2_x = (w / 3)
        local range_3_x = 2 * (w / 3)

        if dmg_max < dmg_min then
            range_1_y = 4 * (h / 5)
            range_2_y = 2 * (h / 5)
        elseif dmg_max == dmg_min then
            range_1_y = 3 * (h / 5)
            range_2_y = 3 * (h / 5)
        end

        if range_min == 0 then
            range_2_x = 0
            range_3_x = w / 2
        end

        surface.DrawLine(range_2_x, 0, range_2_x, h)
        surface.DrawLine(range_3_x, 0, range_3_x, h)

        surface.SetDrawColor(ARC9.GetHUDColor("fg"))

        for i = 0, 1 do
            surface.DrawLine(range_1_x, range_1_y + i, range_2_x, range_1_y + i)
            surface.DrawLine(range_2_x, range_1_y + i, range_3_x, range_2_y + i)
            surface.DrawLine(range_3_x, range_2_y + i, w, range_2_y + i)
        end

        local mouse_x, mouse_y = input.GetCursorPos()
        mouse_x, mouse_y = self2:ScreenToLocal(mouse_x, mouse_y)

        local draw_rangetext = true

        if mouse_x > 0 and mouse_x < w then
            if mouse_y > 0 and mouse_y < h then
                local range = 0

                local range_m_x = 0

                if mouse_x < range_2_x then
                    range = range_min
                    range_m_x = range_2_x
                elseif mouse_x > range_3_x then
                    range = range_max
                    range_m_x = range_3_x
                else
                    local d = (mouse_x - range_2_x) / (range_3_x - range_2_x)
                    range = Lerp(d, range_min, range_max)
                    range_m_x = mouse_x
                end

                local dmg = self:GetDamageAtRange(range)

                local txt_dmg1 = tostring(math.Round(dmg)) .. " DAMAGE"

                if self:GetValue("Num") > 1 then
                    txt_dmg1 = math.Round(dmg * self:GetValue("Num")) .. "-" .. txt_dmg1
                end

                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                surface.DrawLine(range_m_x, 0, range_m_x, h)

                surface.SetFont("ARC9_8")
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                local txt_dmg1_w = surface.GetTextSize(txt_dmg1)
                surface.SetTextPos((w / 3) - txt_dmg1_w - (ScreenScale(2)), ScreenScale(1))
                surface.DrawText(txt_dmg1)

                local txt_range1 = self:RangeUnitize(range)

                surface.SetFont("ARC9_8")
                surface.SetTextColor(ARC9.GetHUDColor("fg"))
                local txt_range1_w = surface.GetTextSize(txt_range1)
                surface.SetTextPos((w / 3) - txt_range1_w - (ScreenScale(2)), ScreenScale(1 + 8))
                surface.DrawText(txt_range1)

                draw_rangetext = false
            end
        end


        if draw_rangetext then
            local txt_dmg1 = tostring(math.Round(dmg_max)) .. " DAMAGE"

            if self:GetValue("Num") > 1 then
                txt_dmg1 = math.Round(dmg_max * self:GetValue("Num")) .. "-" .. txt_dmg1
            end

            surface.SetFont("ARC9_8")
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            local txt_dmg1_w = surface.GetTextSize(txt_dmg1)
            surface.SetTextPos((w / 3) - txt_dmg1_w - (ScreenScale(2)), ScreenScale(1))
            surface.DrawText(txt_dmg1)

            local txt_range1 = self:RangeUnitize(range_min)

            surface.SetFont("ARC9_8")
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            local txt_range1_w = surface.GetTextSize(txt_range1)
            surface.SetTextPos((w / 3) - txt_range1_w - (ScreenScale(2)), ScreenScale(1 + 8))
            surface.DrawText(txt_range1)

            local txt_dmg2 = tostring(math.Round(dmg_min)) .. " DAMAGE"

            if self:GetValue("Num") > 1 then
                txt_dmg2 = math.Round(dmg_min * self:GetValue("Num")) .. "-" .. txt_dmg2
            end

            surface.SetFont("ARC9_8")
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetTextPos(2 * (w / 3) + (ScreenScale(2)), ScreenScale(1))
            surface.DrawText(txt_dmg2)

            local txt_range2 = self:RangeUnitize(range_max)

            surface.SetFont("ARC9_8")
            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetTextPos(2 * (w / 3) + (ScreenScale(2)), ScreenScale(1 + 8))
            surface.DrawText(txt_range2)
        end

        local txt_corner = "TERMINAL BALLISTICS PERFORMANCE EVALUATION"
        surface.SetFont("ARC9_6")
        local tw = surface.GetTextSize(txt_corner)
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos((w - tw) / 2, h - ScreenScale(8))
        surface.DrawText(txt_corner)
    end

    local range_3 = math.max(math.Round(self:GetValue("RangeMax") / 25) * 25, 50) --self.Range * self:GetBuff_Mult("Mult_Range")
    local range_1 = math.max(math.Round(range_3 / 3 / 25) * 25, 15) --(self.RangeMin or 0) * self:GetBuff_Mult("Mult_RangeMin")

    if range_1 == 0 then
        range_1 = range_3 * 0.5
    end

    rollallhits(self, range_3, range_1)

    local ballisticchart = vgui.Create("DButton", tp)
    ballisticchart:SetSize(ScreenScale(200), ScreenScale(110))
    ballisticchart:SetPos(0, ScreenScale(110))
    ballisticchart:SetText("")
    ballisticchart.DoClick = function(self2)
        rollallhits(self, range_3, range_1)
    end
    ballisticchart.Paint = function(self2, w, h)
        if !IsValid(self) then return end

        local col = ARC9.GetHUDColor("bg", 50)
        if self2:IsHovered() then
            self.CustomizeHints["Select"] = "Recalculate"
            col = ARC9.GetHUDColor("hi", 50)
        end

        if self:GetValue("PrimaryBash") then
            surface.SetDrawColor(col)
            surface.DrawRect(0, 0, w, h)

            local txt = "No Data"

            surface.SetTextColor(ARC9.GetHUDColor("fg"))
            surface.SetFont("ARC9_24")
            local tw, th = surface.GetTextSize(txt)
            surface.SetTextPos((w - tw) / 2, (h - th) / 2)
            surface.DrawText(txt)
            return
        end

        surface.SetDrawColor(col)
        surface.DrawRect(0, 0, w, h)

        local s = w / 2
        local s2 = ScreenScale(10)

        local range_1_txt = self:RangeUnitize(range_1)
        local range_3_txt = self:RangeUnitize(range_3)

        surface.SetMaterial(bullseye)
        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.DrawTexturedRect(0, 0, s, s)

        local r_1_x, r_1_y = self2:LocalToScreen(0, 0)

        render.SetScissorRect(r_1_x, r_1_y, r_1_x + s, r_1_y + s, true)

        for _, hit in ipairs(hits_1) do
            if self:GetValue("Num") > 1 then
                surface.SetMaterial(mat_hit_dot)
            else
                surface.SetMaterial(mat_hit)
            end
            surface.SetDrawColor(ARC9.GetHUDColor("fg"))
            surface.DrawTexturedRect((s / 2) + (hit.x * s) - (s2 / 2), (s / 2) + (hit.y * s) - (s2 / 2), s2, s2)
        end

        render.SetScissorRect(r_1_x, r_1_y, r_1_x + s, r_1_y + s, false)

        surface.SetFont("ARC9_10")
        -- local range_1_txtw = surface.GetTextSize(range_1_txt)

        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos(ScreenScale(2), h - ScreenScale(16))
        surface.DrawText(range_1_txt)

        surface.SetMaterial(bullseye)
        surface.SetDrawColor(ARC9.GetHUDColor("fg"))
        surface.DrawTexturedRect(s, 0, s, s)

        render.SetScissorRect(r_1_x + s, r_1_y, r_1_x + (s * 2), r_1_y + s, true)

        for _, hit in ipairs(hits_3) do
            if self:GetValue("Num") > 1 then
                surface.SetMaterial(mat_hit_dot)
            else
                surface.SetMaterial(mat_hit)
            end
            surface.SetDrawColor(ARC9.GetHUDColor("fg"))
            surface.DrawTexturedRect(s + (s / 2) + (hit.x * s) - (s2 / 2), (s / 2) + (hit.y * s) - (s2 / 2), s2, s2)
        end

        render.SetScissorRect(r_1_x, r_1_y, r_1_x + s, r_1_y + s, false)

        surface.SetFont("ARC9_10")
        local range_3_txtw = surface.GetTextSize(range_3_txt)

        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos(w - range_3_txtw - ScreenScale(2), h - ScreenScale(16))
        surface.DrawText(range_3_txt)

        local txt_corner = "MECHANICAL PRECISION TEST"
        surface.SetFont("ARC9_6")
        local tw = surface.GetTextSize(txt_corner)
        surface.SetTextColor(ARC9.GetHUDColor("fg"))
        surface.SetTextPos((w - tw) / 2, h - ScreenScale(8))
        surface.DrawText(txt_corner)
    end
end