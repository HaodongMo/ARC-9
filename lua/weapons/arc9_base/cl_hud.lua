function SWEP:ShouldDrawCrosshair()
    -- return false
    -- return true
end

local function drawshadowrect(x, y, w, h, col)
    local shadow = Color(0, 0, 0, 100)

    surface.SetDrawColor(col)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(shadow)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)
end

local lastgap = 0

function SWEP:DoDrawCrosshair(x, y)

    if self:GetOwner():IsAdmin() and GetConVar("developer"):GetInt() >= 2 and self:GetInSights() then
        surface.SetDrawColor(255, 0, 0, 150)
        surface.DrawLine(ScrW() / 2, 0, ScrW() / 2, ScrH())
        surface.DrawLine(0, ScrH() / 2, ScrW(), ScrH() / 2)
    end

    if !self:GetProcessedValue("Crosshair") then return true end
    if self:GetCustomize() then return true end

    local endpos = self:GetShootPos() + (self:GetShootDir():Forward() * 9000)
    local toscreen = endpos:ToScreen()
    x, y = toscreen.x, toscreen.y

    if self:GetInSights() then return true end

    local mode = self:GetCurrentFiremode()

    local dotsize = ScreenScale(1)

    local gap = ScreenScale(8)

    local shoottimegap = math.Clamp((self:GetNextPrimaryFire() - CurTime()) / (60 / (self:GetProcessedValue("RPM") * 0.1)), 0, 1)

    shoottimegap = math.ease.OutCirc(shoottimegap)

    gap = gap + ((self:GetProcessedValue("Spread") - self:GetValue("Spread", true)) * 36 * ScreenScale(8))

    gap = gap + (shoottimegap * ScreenScale(8))

    lastgap = Lerp(0.5, gap, lastgap)

    gap = lastgap

    local prong = ScreenScale(8)
    local minigap = ScreenScale(2)
    local miniprong_1 = ScreenScale(4)
    local miniprong_2 = ScreenScale(2)

    local col = Color(255, 255, 255, 150)

    drawshadowrect(x - (dotsize / 2), y - (dotsize / 2), dotsize, dotsize, col)

    if self:GetSprintAmount() > 0 then return true end
    if self:GetReloading() then return true end

    if mode > 1 then
        // Burst crosshair
        drawshadowrect(x - (dotsize / 2) - gap - miniprong_2, y - (dotsize / 2), miniprong_2, dotsize, col)
        drawshadowrect(x - (dotsize / 2) - gap - miniprong_2 - minigap - miniprong_1, y - (dotsize / 2), miniprong_1, dotsize, col)

        drawshadowrect(x - (dotsize / 2) + gap, y - (dotsize / 2), miniprong_2, dotsize, col)
        drawshadowrect(x - (dotsize / 2) + gap + miniprong_2 + minigap, y - (dotsize / 2), miniprong_1, dotsize, col)

        drawshadowrect(x - (dotsize / 2), y - (dotsize / 2) + gap, dotsize, miniprong_2, col)
        drawshadowrect(x - (dotsize / 2), y - (dotsize / 2) + gap + miniprong_2 + minigap, dotsize, miniprong_1, col)

        if mode > 2 then
            drawshadowrect(x - (dotsize / 2), y - (dotsize / 2) - gap - miniprong_2, dotsize, miniprong_2, col)
            drawshadowrect(x - (dotsize / 2), y - (dotsize / 2) - gap - miniprong_2 - minigap - miniprong_1, dotsize, miniprong_1, col)
        end
    elseif mode != 0 then
        drawshadowrect(x - (dotsize / 2) - gap - prong, y - (dotsize / 2), prong, dotsize, col)
        drawshadowrect(x - (dotsize / 2) + gap, y - (dotsize / 2), prong, dotsize, col)
        drawshadowrect(x - (dotsize / 2), y - (dotsize / 2) + gap, dotsize, prong, col)

        if mode < 0 then
            // Auto crosshair
            drawshadowrect(x - (dotsize / 2), y - (dotsize / 2) - gap - prong, dotsize, prong, col)
        end
    end

    return true
end

function SWEP:GetBinding(bind)
    local t_bind = input.LookupBinding(bind)

    if !t_bind then
        t_bind = "BIND " .. bind .. "!"
    end

    return string.upper(t_bind)
end

function SWEP:DrawHUD()
    self:HoldBreathHUD()
    self:DrawCustomizeHUD()

    self:RunHook("Hook_HUDPaint")
end

SWEP.Mat_Select = nil

function SWEP:DrawWeaponSelection(x, y, w, h, a)
    -- if !self.Mat_Select then
    --     self.Mat_Select = Material("entities/" .. self:GetClass() .. ".png")
    -- end

    -- surface.SetDrawColor(255, 255, 255, 255)
    -- surface.SetMaterial(self.Mat_Select)

    -- if w > h then
    --     y = y - ((w - h) / 2)
    -- end

    -- surface.DrawTexturedRect(x, y, w, w)

    local selecticon = self.AutoSelectIcon

    if !selecticon then
        local filename = ARC9.PresetPath .. self:GetPresetBase() .. "_icon.png"
        if !file.Exists(filename, "DATA") then
            selecticon = self.DefaultSelectIcon
        else
            selecticon = Material("data/" .. filename, "smooth")
        end
    end

    if !selecticon then return end

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(selecticon)
    if w > h then
        y = y - ((w - h) / 2)
    end
    surface.DrawTexturedRect(x, y, w, w)
end

SWEP.AutoSelectIcon = nil

function SWEP:DoIconCapture()
    self:DoPresetCapture(ARC9.PresetPath .. self:GetPresetBase() .. "_icon")
end

function SWEP:RangeUnitize(range)
    return tostring(math.Round(range * ARC9.HUToM)) .. "M"
end