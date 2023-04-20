local arc9_crosshair_force = GetConVar("arc9_crosshair_force")
local arc9_cross_enable = GetConVar("arc9_cross_enable")
local arc9_crosshair_static = GetConVar("arc9_crosshair_static")
local arc9_cross_size_mult = GetConVar("arc9_cross_size_mult")
local arc9_cross_size_dot = GetConVar("arc9_cross_size_dot")
local arc9_cross_size_prong = GetConVar("arc9_cross_size_prong")
local arc9_cross_r = GetConVar("arc9_cross_r")
local arc9_cross_g = GetConVar("arc9_cross_g")
local arc9_cross_b = GetConVar("arc9_cross_b")
local arc9_cross_a = GetConVar("arc9_cross_a")
local arc9_dev_crosshair = GetConVar("arc9_dev_crosshair")


function SWEP:ShouldDrawCrosshair()
    if self:GetInSights() then
        return self:GetSight().CrosshairInSights
    end
    if (!self:GetProcessedValue("Crosshair", true) and !arc9_crosshair_force:GetBool()) and !ARC9.ShouldThirdPerson() then return false end
    if self:GetCustomize() then return false end

    return true
end

local function drawshadowrect(x, y, w, h, col)
    surface.SetDrawColor(col)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(0, 0, 0, col.a * 100 / 150)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)
end

local lastgap = 0
local lasthelperalpha = 0

local lerp = Lerp
-- local arcticcolor = Color(255, 255, 255, 100)
local ARC9ScreenScale = ARC9.ScreenScale

function SWEP:DoDrawCrosshair(x, y)
    if !arc9_cross_enable:GetBool() then return end
    local scrw, scrh = ScrW(), ScrH()
    local owner = self:GetOwner()

    local staticcs = arc9_crosshair_static:GetBool()

    if staticcs then
        x = scrw / 2
        y = scrh / 2
    else
        local sp, sa = self:GetShootPos()

        local endpos = sp + (sa:Forward() * 9000)
        local toscreen = endpos:ToScreen()
    
        if ARC9.ShouldThirdPerson() then
            local tr = util.TraceLine({
                start = sp,
                endpos = endpos,
                mask = MASK_SHOT,
                filter = owner
            })
    
            toscreen = tr.HitPos:ToScreen()
        end
    
        x, y = toscreen.x, toscreen.y
    end

    local m = arc9_cross_size_mult:GetFloat()
    local sizeprong = arc9_cross_size_prong:GetFloat()

    local dotsize = ARC9ScreenScale(1) * m * arc9_cross_size_dot:GetFloat()
    local prong = ARC9ScreenScale(4) * m * sizeprong
    local minigap = ARC9ScreenScale(2) * m
    local miniprong_1 = ARC9ScreenScale(4) * m * sizeprong
    local miniprong_2 = ARC9ScreenScale(2) * m * sizeprong
    local gap = 0
    local staticgap = ARC9ScreenScale(4)

    local col = Color(255, 255, 255, 255)
    col.r = arc9_cross_r:GetFloat()
    col.g = arc9_cross_g:GetFloat()
    col.b = arc9_cross_b:GetFloat()
    col.a =  arc9_cross_a:GetFloat()

    local d = self:GetSightDelta()

    prong = lerp(d, prong, ARC9ScreenScale(6))
    gap = lerp(d, gap, 0)
    minigap = lerp(d, minigap, ARC9ScreenScale(1))
    miniprong_1 = lerp(d, miniprong_1, ARC9ScreenScale(3))
    miniprong_2 = lerp(d, miniprong_2, ARC9ScreenScale(1))

    local helpertarget = 0

    col.a = lasthelperalpha * col.a

    if owner:IsAdmin() and arc9_dev_crosshair:GetBool() then
        self:DevStuffCrosshair()
        return true
    end

    if !self:ShouldDrawCrosshair() then
        --[[]
        if owner:KeyDown(IN_USE) then
            helpertarget = 1
        end
        ]]

        lasthelperalpha = math.Approach(lasthelperalpha, helpertarget, FrameTime() / 0.1)

        drawshadowrect(x - (dotsize / 2), y - (dotsize / 2), dotsize, dotsize, col)

        return true
    else
        helpertarget = 1

        lasthelperalpha = math.Approach(lasthelperalpha, helpertarget, FrameTime() / 0.1)
    end

    local mode = self:GetCurrentFiremode()

    local shoottimegap = math.Clamp((self:GetNextPrimaryFire() - CurTime()) / (60 / (self:GetProcessedValue("RPM", true) * 0.1)), 0, 1)

    shoottimegap = math.ease.OutCirc(shoottimegap)

    if staticcs then shoottimegap = 0 end

    cam.Start3D()
        local lool = ( EyePos() + ( EyeAngles():Forward() ) + ( (self:GetProcessedValue("Spread")) * EyeAngles():Up() ) ):ToScreen()
    cam.End3D()

    local gau = 0
    gau = ( (scrh / 2) - lool.y )

    gap = gap + gau

    gap = math.max(ARC9ScreenScale(4), gap)
    gap = gap + (shoottimegap * ARC9ScreenScale(8))

    lastgap = lerp(0.5, gap, lastgap)

    gap = lastgap

    drawshadowrect(x - (dotsize / 2), y - (dotsize / 2), dotsize, dotsize, col)

    if self:GetSprintAmount() > 0 then return true end
    if self:GetReloading() then return true end

    if self:GetProcessedValue("MissileCrosshair", true) then
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
    elseif self:GetProcessedValue("ShootEnt", true) or self:GetProcessedValue("LauncherCrosshair", true) then
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
            -- Auto crosshair
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
    elseif self:GetProcessedValue("Num", true) > 1 then
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
            -- Burst crosshair
            drawshadowrect(x - (dotsize / 2) - gap - miniprong_2, y - (dotsize / 2), miniprong_2, dotsize, col)
            drawshadowrect(x - (dotsize / 2) - gap - miniprong_2 - minigap - miniprong_1, y - (dotsize / 2), miniprong_1, dotsize, col)

            drawshadowrect(x + (dotsize / 2) + gap, y - (dotsize / 2), miniprong_2, dotsize, col)
            drawshadowrect(x + (dotsize / 2) + gap + miniprong_2 + minigap, y - (dotsize / 2), miniprong_1, dotsize, col)

            drawshadowrect(x - (dotsize / 2), y + (dotsize / 2) + gap, dotsize, miniprong_2, col)
            drawshadowrect(x - (dotsize / 2), y + (dotsize / 2) + gap + miniprong_2 + minigap, dotsize, miniprong_1, col)

            if mode > 2 then
                drawshadowrect(x - (dotsize / 2), y - (dotsize / 2) - gap - miniprong_2, dotsize, miniprong_2, col)
                drawshadowrect(x - (dotsize / 2), y - (dotsize / 2) - gap - miniprong_2 - minigap - miniprong_1, dotsize, miniprong_1, col)
            end
        elseif mode != 0 then
            drawshadowrect(x - (dotsize / 2) - gap - prong, y - (dotsize / 2), prong, dotsize, col)
            drawshadowrect(x + (dotsize / 2) + gap, y - (dotsize / 2), prong, dotsize, col)
            drawshadowrect(x - (dotsize / 2), y + (dotsize / 2) + gap, dotsize, prong, col)

            if mode < 0 then
                -- Auto crosshair
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

local bipodhint = 0 -- alpha
local bipodhintstate = false -- enter or exit

function SWEP:DrawHUD()
    self:RunHook("Hook_HUDPaintBackground")
    local scrw, scrh = ScrW(), ScrH()
    local getsight = self:GetSight()

    if self:GetSightAmount() > 0.75 and getsight.FlatScope and getsight.FlatScopeOverlay then
        if getsight.FlatScopeBlackBox then
            surface.SetMaterial(getsight.FlatScopeOverlay)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRect((scrw - scrh) / 2, 0, scrh, scrh)

            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(0, 0, (scrw - scrh) / 2, scrh)
            surface.DrawRect(scrw - (scrw - scrh) / 2, 0, (scrw - scrh) / 2, scrh)
        else
            surface.SetMaterial(getsight.FlatScopeOverlay)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRect(0, (scrh - scrw) / 2, scrw, scrw)
        end
    end

    -- Bipod hint

    local ft1000 = RealFrameTime() * 1000
    bipodhint = math.max(0, bipodhint - ft1000)

    if self:GetBipod() then
        bipodhint = math.min(255, bipodhint + ft1000 * 2)
        bipodhintstate = true
    elseif self:CanBipod() and self:GetSightAmount() <= 0 then
        bipodhint = math.min(255, bipodhint + ft1000 * 2)
        bipodhintstate = false
    end

    if bipodhint > 0 then
        local glyph = ARC9.GetBindKey(bipodhintstate and "+back" or "+attack2")
        local text = bipodhintstate and "Exit bipod" or "Enter bipod"

        if ARC9.CTRL_Lookup[glyph] then glyph = ARC9.CTRL_Lookup[glyph] end
        if ARC9.CTRL_ConvertTo[glyph] then glyph = ARC9.CTRL_ConvertTo[glyph] end
        if ARC9.CTRL_Exists[glyph] then glyph = Material( "arc9/glyphs_light/" .. glyph .. "_lg" .. ".png", "smooth" ) end

        surface.SetTextColor(255, 255, 255, bipodhint)
        surface.SetDrawColor(255, 255, 255, bipodhint)
        surface.SetFont("ARC9_16")
        local symbol = CreateControllerKeyLine({x = scrw / 2-ScreenScale(5), y = scrh / 2 + ScreenScale(96), size = ScreenScale(8), font = "ARC9_12", font_keyb = "ARC9_12" }, { glyph, ScreenScale(8) })

        surface.SetFont("ARC9_10")
        local tw = surface.GetTextSize(text)
        surface.SetTextPos(scrw / 2 - tw / 2, scrh / 2 + ScreenScale(106))
        surface.DrawText(text)
    end

    --

    self:HoldBreathHUD()
    self:DrawCustomizeHUD()

    self:DrawLockOnHUD(false)

    self:RunHook("Hook_HUDPaint")
end

SWEP.InvalidateSelectIcon = false

function SWEP:DrawWeaponSelection(x, y, w, h, a)
    if self.EntitySelectIcon then
        if !self.Mat_Select then
            self.Mat_Select = Material("entities/" .. self:GetClass() .. ".png")
        end

        surface.SetDrawColor(255, 255, 255, a)
        surface.SetMaterial(self.Mat_Select)

        if w > h then
            y = y - ((w - h) / 2)
        end

        surface.DrawTexturedRect(x, y, w, w)
        return
    elseif self.CustomSelectIcon then
        surface.SetDrawColor(255, 255, 255, a)
        surface.SetMaterial(self.CustomSelectIcon)

        h = w / 2

         y = y + (h / 8)

        surface.DrawTexturedRect(x, y, w, h)
        return
    end

    local selecticon = self.AutoSelectIcon

    if !selecticon or self.InvalidateSelectIcon then
        self:DoIconCapture()

        local filename = ARC9.PresetPath .. self:GetPresetBase() .. "_icon." .. ARC9.PresetIconFormat
        selecticon = Material("data/" .. filename, "smooth")
    end

    if !selecticon then return end

    self.WepSelectIcon = selecticon:GetTexture("$basetexture")

    surface.SetDrawColor(255, 255, 255, a)
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
    return tostring(math.Round(range * ARC9.HUToM)) .. ARC9:GetPhrase("unit.meter")
end