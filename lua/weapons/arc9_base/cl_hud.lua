function SWEP:ShouldDrawCrosshair()
    if self:GetInSights() then
        if self:GetSight().CrosshairInSights then
            return true
        else
            return false
        end
    end
    if !self:GetProcessedValue("Crosshair") and !ARC9.ShouldThirdPerson() then return false end
    if self:GetCustomize() then return false end

    return true
end

local function drawshadowrect(x, y, w, h, col)
    local shadow = Color(0, 0, 0, col.a * 100 / 150)

    surface.SetDrawColor(col)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(shadow)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)
end

local lastgap = 0
local lasthelperalpha = 0

function SWEP:DoDrawCrosshair(x, y)

    local dotsize = ScreenScale(1)
    local prong = ScreenScale(8)
    local minigap = ScreenScale(2)
    local miniprong_1 = ScreenScale(4)
    local miniprong_2 = ScreenScale(2)
    local gap = ScreenScale(4)
    local staticgap = gap
    local col = Color(255, 255, 255, 100)

    local d = self:GetSightDelta()

    prong = Lerp(d, prong, ScreenScale(6))
    gap = Lerp(d, gap, ScreenScale(4))
    minigap = Lerp(d, minigap, ScreenScale(1))
    miniprong_1 = Lerp(d, miniprong_1, ScreenScale(3))
    miniprong_2 = Lerp(d, miniprong_2, ScreenScale(1))

    if self:GetOwner():IsAdmin() and GetConVar("developer"):GetInt() >= 2 and self:GetInSights() then
        surface.SetDrawColor(255, 0, 0, 150)
        surface.DrawLine(ScrW() / 2, 0, ScrW() / 2, ScrH())
        surface.DrawLine(0, ScrH() / 2, ScrW(), ScrH() / 2)
    end

    local helpertarget = 0

    col.a = lasthelperalpha * col.a

    if !self:ShouldDrawCrosshair() then
        if self:GetOwner():KeyDown(IN_USE) then
            helpertarget = 1
        end

        lasthelperalpha = math.Approach(lasthelperalpha, helpertarget, FrameTime() / 0.1)

        drawshadowrect(x - (dotsize / 2), y - (dotsize / 2), dotsize, dotsize, col)

        return true
    else
        helpertarget = 1

        lasthelperalpha = math.Approach(lasthelperalpha, helpertarget, FrameTime() / 0.1)
    end

    local endpos = self:GetShootPos() + (self:GetShootDir():Forward() * 9000)
    local toscreen = endpos:ToScreen()

    if ARC9.ShouldThirdPerson() then
        local tr = util.TraceLine({
            start = self:GetShootPos(),
            endpos = endpos,
            mask = MASK_SHOT,
            filter = self:GetOwner()
        })

        toscreen = tr.HitPos:ToScreen()
    end

    x, y = toscreen.x, toscreen.y

    local mode = self:GetCurrentFiremode()

    local shoottimegap = math.Clamp((self:GetNextPrimaryFire() - CurTime()) / (60 / (self:GetProcessedValue("RPM") * 0.1)), 0, 1)

    shoottimegap = math.ease.OutCirc(shoottimegap)

    gap = gap + ((self:GetProcessedValue("Spread") - self:GetValue("Spread", true)) * 36 * ScreenScale(8))

    gap = gap + (shoottimegap * ScreenScale(8))

    lastgap = Lerp(0.5, gap, lastgap)

    gap = lastgap

    drawshadowrect(x - (dotsize / 2), y - (dotsize / 2), dotsize, dotsize, col)

    if self:GetSprintAmount() > 0 then return true end
    if self:GetReloading() then return true end

    if self:GetProcessedValue("MissileCrosshair") then
        -- local dotcount = 4

        -- for i = 1, dotcount do
        --     local rad = i * math.pi * 2 / dotcount
        --     rad = rad - (math.pi / 4)
        --     local cx = math.cos(rad)
        --     local cy = math.sin(rad)

        --     cx = cx * gap * 3
        --     cy = cy * gap * 3

        --     drawshadowrect(x + cx - (dotsize / 2), y + cy - (dotsize / 2), dotsize, dotsize, col)
        -- end

        drawshadowrect(x - gap * 2.75 - (dotsize / 2), y - gap * 2.75 - (dotsize / 2), dotsize, dotsize, col)
        drawshadowrect(x + gap * 2.75 - (dotsize / 2), y - gap * 2.75 - (dotsize / 2), dotsize, dotsize, col)
        drawshadowrect(x - gap * 2.75 - (dotsize / 2), y + gap * 2.75 - (dotsize / 2), dotsize, dotsize, col)
        drawshadowrect(x + gap * 2.75 - (dotsize / 2), y + gap * 2.75 - (dotsize / 2), dotsize, dotsize, col)

        drawshadowrect(x - gap * 2.75 - (dotsize / 2), y - gap * 2 - (dotsize / 2), dotsize, gap * 1, col)
        drawshadowrect(x + gap * 2.75 - (dotsize / 2), y - gap * 2 - (dotsize / 2), dotsize, gap * 1, col)

        drawshadowrect(x - gap * 2.75 - (dotsize / 2), y - gap * -1 - (dotsize / 2), dotsize, gap * 1, col)
        drawshadowrect(x + gap * 2.75 - (dotsize / 2), y - gap * -1 - (dotsize / 2), dotsize, gap * 1, col)

        drawshadowrect(x - gap * 2 - (dotsize / 2), y - gap * 2.75 - (dotsize / 2), gap * 1, dotsize, col)
        drawshadowrect(x - gap * 2 - (dotsize / 2), y + gap * 2.75 - (dotsize / 2), gap * 1, dotsize, col)

        drawshadowrect(x - gap * -1 - (dotsize / 2), y - gap * 2.75 - (dotsize / 2), gap * 1, dotsize, col)
        drawshadowrect(x - gap * -1 - (dotsize / 2), y + gap * 2.75 - (dotsize / 2), gap * 1, dotsize, col)
    elseif self:GetProcessedValue("ShootEnt") or self:GetProcessedValue("LauncherCrosshair") then
        if mode > 1 then
            drawshadowrect(x - (dotsize / 2) - gap - miniprong_2, y - (dotsize / 2), miniprong_2, dotsize, col)
            drawshadowrect(x - (dotsize / 2) - gap - miniprong_2 - minigap - miniprong_1, y - (dotsize / 2), miniprong_1, dotsize, col)

            drawshadowrect(x - (dotsize / 2) + gap, y - (dotsize / 2), miniprong_2, dotsize, col)
            drawshadowrect(x - (dotsize / 2) + gap + miniprong_2 + minigap, y - (dotsize / 2), miniprong_1, dotsize, col)

            if mode > 2 then
                drawshadowrect(x - (dotsize / 2), y - (dotsize / 2) - gap - miniprong_2, dotsize, miniprong_2, col)
                drawshadowrect(x - (dotsize / 2), y - (dotsize / 2) - gap - miniprong_2 - minigap - miniprong_1, dotsize, miniprong_1, col)
            end
        elseif mode < 0 then
            // Auto crosshair
            drawshadowrect(x - (dotsize / 2), y - (dotsize / 2) - gap - prong, dotsize, prong, col)
        else
            drawshadowrect(x - (dotsize / 2) - gap - prong, y - (dotsize / 2), prong, dotsize, col)
            drawshadowrect(x - (dotsize / 2) + gap, y - (dotsize / 2), prong, dotsize, col)
        end


        -- drawshadowrect(x - (dotsize / 2), y - (dotsize / 2) + gap * 1.25, dotsize, staticgap * 5, col)

        drawshadowrect(x - (dotsize / 2) - (minigap * 5), y - (dotsize / 2) + gap + (staticgap * 1), dotsize, dotsize, col)
        drawshadowrect(x - (dotsize / 2) + (minigap * 5), y - (dotsize / 2) + gap + (staticgap * 1), dotsize, dotsize, col)

        drawshadowrect(x - (dotsize / 2) - (minigap * 4), y - (dotsize / 2) + gap + (staticgap * 2.5), dotsize, dotsize, col)
        drawshadowrect(x - (dotsize / 2) + (minigap * 4), y - (dotsize / 2) + gap + (staticgap * 2.5), dotsize, dotsize, col)

        drawshadowrect(x - (dotsize / 2) - (minigap * 3), y - (dotsize / 2) + gap + (staticgap * 4), dotsize, dotsize, col)
        drawshadowrect(x - (dotsize / 2) + (minigap * 3), y - (dotsize / 2) + gap + (staticgap * 4), dotsize, dotsize, col)

        drawshadowrect(x - (dotsize / 2) - (minigap * 2), y - (dotsize / 2) + gap + (staticgap * 5.5), dotsize, dotsize, col)
        drawshadowrect(x - (dotsize / 2) + (minigap * 2), y - (dotsize / 2) + gap + (staticgap * 5.5), dotsize, dotsize, col)
    elseif self:GetProcessedValue("Num") > 1 then
        local dotcount = 10

        for i = 1, dotcount do
            local rad = i * math.pi * 2 / dotcount
            rad = rad - (math.pi / 2)
            local cx = math.cos(rad)
            local cy = math.sin(rad)

            cx = cx * gap
            cy = cy * gap

            drawshadowrect(x + cx - (dotsize / 2), y + cy - (dotsize / 2), dotsize, dotsize, col)
        end
    else
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

SWEP.InvalidateSelectIcon = false

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

    if !selecticon or self.InvalidateSelectIcon then
        self:DoIconCapture()

        local filename = ARC9.PresetPath .. self:GetPresetBase() .. "_icon." .. ARC9.PresetIconFormat
        selecticon = Material("data/" .. filename, "smooth")
    end

    if !selecticon then return end

    self.WepSelectIcon = selecticon:GetTexture("$basetexture")

    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(selecticon)
    if w > h then
        y = y - ((w - h) / 2)
    end
    -- surface.DrawTexturedRect(x, y, w, w)
     surface.DrawTexturedRectUV(x, y, w, w, 1, 0, 0, 1)
end

SWEP.AutoSelectIcon = nil

function SWEP:DoIconCapture()
    self:DoPresetCapture(ARC9.PresetPath .. self:GetPresetBase() .. "_icon")
end

function SWEP:RangeUnitize(range)
    return tostring(math.Round(range * ARC9.HUToM)) .. "M"
end