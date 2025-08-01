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
local arc9_crosshair_peek = GetConVar("arc9_crosshair_peek")
local arc9_crosshair_sgstyle = GetConVar("arc9_cross_sgstyle")


function SWEP:ShouldDrawCrosshair()
    local crossh = self:GetProcessedValue("Crosshair", true) or arc9_crosshair_force:GetBool()
    if self:GetInSights() then

        if (self.Peeking and !self:GetProcessedValue("NoPeekCrosshair", true) and arc9_crosshair_peek:GetFloat() == 1) and crossh then
            return true
        end

        return self:GetSight().CrosshairInSights
    end
    if !crossh and !ARC9.ShouldThirdPerson() then return false end
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
local arc9_crosshair_target = GetConVar("arc9_crosshair_target")
local sgcircle = Material("arc9/circlehollow.png", "mips smooth")
local sgcirclethick = Material("arc9/circlehollowsmall.png", "mips smooth")
local sgcirclethin = Material("arc9/circlehollowbig.png", "mips smooth")
local sgcircleprong = Material("arc9/circleprong.png", "mips smooth")

function SWEP:DoDrawCrosshair(x, y)
    if !arc9_cross_enable:GetBool() then return end

    if self:GetInspecting() then lasthelperalpha = 0 return true end

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
    local hidedot = self:GetProcessedValue("CrosshairHideDot", true)

    -- local col = Color(255, 255, 255, 255)
    -- col.r = arc9_cross_r:GetFloat()
    -- col.g = arc9_cross_g:GetFloat()
    -- col.b = arc9_cross_b:GetFloat()
    -- col.a =  arc9_cross_a:GetFloat()

    if owner.ARC9_AATarget != nil and arc9_crosshair_target:GetBool() then
        col = Color(255,0,0,255)
    else
        col = Color(255, 255, 255, 255)
        col.r = arc9_cross_r:GetFloat()
        col.g = arc9_cross_g:GetFloat()
        col.b = arc9_cross_b:GetFloat()
        col.a =  arc9_cross_a:GetFloat()
    end


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

        if !hidedot then drawshadowrect(x - (dotsize / 2), y - (dotsize / 2), dotsize, dotsize, col) end

        return true
    else
        helpertarget = 1

        lasthelperalpha = math.Approach(lasthelperalpha, helpertarget, FrameTime() / 0.1)
    end

    local mode = self:GetCurrentFiremode()
    local shoottimegap = 0

    if !self:GetProcessedValue("NoCrosshairShootTimeGap") then
        math.Clamp((self:GetNextPrimaryFire() - CurTime()) / (60 / (self:GetProcessedValue("RPM", true) * 0.1)), 0, 1)
        shoottimegap = math.ease.OutCirc(shoottimegap)
    end


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

    if !hidedot then drawshadowrect(x - (dotsize / 2), y - (dotsize / 2), dotsize, dotsize, col) end

    if self:GetSprintAmount() > 0 then return true end
    if self:GetReloading() then return true end

    local forcestd = self:GetProcessedValue("ForceStandardCrosshair", true)

    if self:GetProcessedValue("CustomCrosshair", true) then
        surface.SetDrawColor(col)

        surface.SetMaterial( self:GetProcessedValue("CustomCrosshairMaterial", true) or Material("arc9/ui/share.png", "mips smooth") )

        local size = self:GetProcessedValue("CustomCrosshairSize", true) or 100

        if self:GetProcessedValue("CustomCrosshairSingle", true) then
            surface.DrawTexturedRectRotated(x, y, (dotsize + gap) + size, (dotsize + gap) + size, 0) -- Central
        else
            surface.DrawTexturedRectRotated(x - (dotsize / 2) - gap - ARC9.ScreenScale(11), y - (dotsize / 2), size, size, 0) -- Left
            surface.DrawTexturedRectRotated(x - (dotsize / 2) + gap + ARC9.ScreenScale(11), y - (dotsize / 2), size, size, 180) -- Right

            surface.DrawTexturedRectRotated(x - (dotsize / 2), y - (dotsize / 2) - gap - prong - ARC9.ScreenScale(7), size, size, -90) -- Top
            surface.DrawTexturedRectRotated(x - (dotsize / 2), y + (dotsize / 2) + gap + ARC9.ScreenScale(10), size, size, 90) -- Bottom
        end
    elseif self:GetProcessedValue("MissileCrosshair", true) then
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
    elseif (self:GetProcessedValue("ShootEnt", true) or self:GetProcessedValue("LauncherCrosshair", true)) and !forcestd then
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
    elseif self:GetProcessedValue("Num", true) > 1 and !forcestd then
        local style = arc9_crosshair_sgstyle:GetInt()

        if style == 4 or style == 5 then
            local dotcount = style == 5 and self:GetProcessedValue("Num", true) or 10

            for i = 1, dotcount do
                local rad = i * math.pi * 2 / dotcount
                rad = rad - (math.pi / 2) + math.pi / 2
                local cx = math.cos(rad)
                local cy = math.sin(rad)

                cx = cx * gap
                cy = cy * gap

                drawshadowrect(x + cx - (dotsize / 2), y + cy - (dotsize / 2), dotsize, dotsize, col)
            end
        elseif style == 3 or style == 2 then
            local size = gap - gap * 0.5 + 15

            surface.SetDrawColor(col)
            surface.SetMaterial(sgcircleprong)

            surface.DrawTexturedRectRotated(x - (dotsize / 2) - gap, y - (dotsize / 2) + 1, size, size, 0) -- Left
            surface.DrawTexturedRectRotated(x - (dotsize / 2) + 2 + gap, y - (dotsize / 2) + 1, size, size, 180) -- Right
            if style == 2 then
                surface.DrawTexturedRectRotated(x - (dotsize / 2) + 1, y - (dotsize / 2) - gap - 1 , size, size, -90) -- Top
                surface.DrawTexturedRectRotated(x - (dotsize / 2) + 1, y + (dotsize / 2) + gap , size, size, 90) -- Bottom
            end
        else
            surface.SetDrawColor(col)
            surface.SetMaterial((gap > 75 and sgcirclethin) or (gap < 30 and sgcirclethick) or sgcircle)
            surface.DrawTexturedRectRotated(x, y, (dotsize + gap) * 2, (dotsize + gap) * 2, 0) -- Central
        end

        -- surface.DrawCircle(x, y, dotsize + gap - 1, col.r, col.g, col.b, 255) -- Middle White / Coloured One
        -- surface.DrawCircle(x, y, dotsize + gap, 0, 0, 0, 100) -- Outside Gray
        -- surface.DrawCircle(x, y, dotsize + gap -2, 0, 0, 0, 100) -- Inside Gra
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
local bipodreloadmove = 0 -- ??
local bipodhintstate = false -- enter or exit

local arc9_center_reload_enable = GetConVar("arc9_center_reload_enable")
local arc9_center_reload = GetConVar("arc9_center_reload")
local arc9_center_jam = GetConVar("arc9_center_jam")
local arc9_center_bipod = GetConVar("arc9_center_bipod")
local arc9_infinite_ammo = GetConVar("arc9_infinite_ammo")
local arc9_center_overheat = GetConVar("arc9_center_overheat")
local arc9_hud_arc9 = GetConVar("arc9_hud_arc9")
local arc9_center_overheat_dark = GetConVar("arc9_center_overheat_dark")
local arc9_center_firemode = GetConVar("arc9_center_firemode")
local arc9_cruelty_reload = GetConVar("arc9_cruelty_reload")
local cl_drawhud = GetConVar("cl_drawhud")


local firemodealpha, lastfiremode, lastfiremodetime = 0, 0, 0

function SWEP:DrawHUD()
    self:RunHook("Hook_HUDPaintBackground")

    if cl_drawhud:GetBool() then
        local scrw, scrh = ScrW(), ScrH()
        local getsight = self:GetSight()
        local ct = CurTime()

        local ubgl = self:GetUBGL()
        local rel = self:GetReloading()
        local throw = self.Throwable
        local primbash = self.PrimaryBash

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

        if arc9_center_bipod:GetBool() and bipodhint > 0 then
            local glyph = ARC9.GetBindKey(bipodhintstate and "+back" or "+attack2")
            -- local text = bipodhintstate and "Exit bipod" or "Enter bipod"
            -- local text = bipodhintstate and ARC9:GetPhrase("hud.hint.bipod.exit") or ARC9:GetPhrase("hud.hint.bipod.enter")
            local text = ARC9:GetPhrase("hud.hint.bipod")
            local twbp = surface.GetTextSize(text)

            if ARC9.CTRL_Lookup[glyph] then glyph = ARC9.CTRL_Lookup[glyph] end
            if ARC9.CTRL_ConvertTo[glyph] then glyph = ARC9.CTRL_ConvertTo[glyph] end
            if ARC9.CTRL_Exists[glyph] then glyph = Material( "arc9/" .. ARC9.GlyphFamilyHUD() .. glyph .. ".png", "mips smooth" ) end

            surface.SetTextColor(255, 255, 255, bipodhint)
            surface.SetDrawColor(255, 255, 255, bipodhint)
            surface.SetFont("ARC9_16")

            local symbol = CreateControllerKeyLine({x = scrw / 2-ScreenScale(10) - (surface.GetTextSize(text) * 0.35) + ScreenScale(5), y = scrh / 2 + ScreenScale(97), size = ScreenScale(8), font = "ARC9_12", font_keyb = "ARC9_12" }, { glyph, ScreenScale(7) })

            surface.SetFont("ARC9_10")

            surface.SetDrawColor(0, 0, 0, math.Clamp(bipodhint, 0, 175))
            surface.DrawRect(scrw / 2 + 2 - surface.GetTextSize(text) / 2 + ScreenScale(5) - 4, scrh / 2 + 2 + ScreenScale(96), surface.GetTextSize(text) + 5, 27.5)

            surface.SetTextColor(0, 0, 0, bipodhint) -- Black
            surface.SetTextPos(scrw / 2 + 2 - surface.GetTextSize(text) / 2 + ScreenScale(5), scrh / 2 + 2 + ScreenScale(97))
            surface.DrawText(text)

            surface.SetTextColor(255, 255, 255, bipodhint) -- White
            surface.SetTextPos(scrw / 2 - surface.GetTextSize(text) / 2 + ScreenScale(5), scrh / 2 + ScreenScale(97))
            surface.DrawText(text)
        end

        if !ubgl then
            magazine = self:Clip1()
            mag = magazine <= self:GetMaxClip1() * arc9_center_reload:GetFloat()
            maxmag = self.Owner:GetAmmoCount(self.Primary.Ammo)
        else
            magazine = self:Clip2()
            mag = magazine <= self:GetMaxClip2() * arc9_center_reload:GetFloat()
            maxmag = self.Owner:GetAmmoCount(self.Secondary.Ammo)
        end

        local blink = 255 * math.abs(math.sin(ct * 5))

        local glyph = ARC9.GetBindKey("+reload")

        if ARC9.CTRL_Lookup[glyph] then glyph = ARC9.CTRL_Lookup[glyph] end
        if ARC9.CTRL_ConvertTo[glyph] then glyph = ARC9.CTRL_ConvertTo[glyph] end
        if ARC9.CTRL_Exists[glyph] then glyph = Material( "arc9/" .. ARC9.GlyphFamilyHUD() .. glyph .. ".png", "mips smooth" ) end

        if (arc9_center_reload_enable:GetBool() and (self.ClipSize > 0 and arc9_center_reload:GetFloat() > 0.02)) and !self:GetInspecting() and !self:GetJammed() then
            if !rel and !throw and !primbash and mag then
                local text = ARC9:GetPhrase("hud.hint.reload")
                local textlow = ARC9:GetPhrase("hud.hint.lowammo")
                local textempty = ARC9:GetPhrase("hud.hint.noammo")

                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetFont("ARC9_12")

                local tw = surface.GetTextSize(text)
                local twlow = surface.GetTextSize(textlow)
                local twempty = surface.GetTextSize(textempty)
                local ia = arc9_infinite_ammo:GetBool()

                if !ia and (magazine == 0 and maxmag == 0) then -- If no ammo and no reserve
                    surface.SetDrawColor(0, 0, 0, 175 * math.abs(math.sin(ct * 5)))
                    surface.DrawRect(scrw / 2 + 2 - twempty / 2 - 5, scrh / 2 + 2 + ScreenScale(98) + (bipodhint / 7.5), twempty + 7, 27.5)

                    surface.SetTextPos(scrw / 2 + 2 - twempty / 2, scrh / 2 + 2 + ScreenScale(97) + (bipodhint / 7.5)) -- Black
                    surface.SetTextColor(0, 0, 0, blink)
                    surface.DrawText(textempty)

                    surface.SetTextPos(scrw / 2 - twempty / 2, scrh / 2 + ScreenScale(97) + (bipodhint / 7.5)) -- White
                    surface.SetTextColor(255, 100, 100, blink)
                    surface.DrawText(textempty)
                elseif !ia and mag and maxmag == 0 then -- If low on ammo with no reserve ammo
                    surface.SetDrawColor(0, 0, 0, 175 * math.abs(math.sin(ct * 5)))
                    surface.DrawRect(scrw / 2 + 2 - twlow / 2 - 5, scrh / 2 + 2 + ScreenScale(98) + (bipodhint / 7.5), twlow + 7, 27.5)

                    surface.SetTextPos(scrw / 2 + 2 - twlow / 2, scrh / 2 + 2 + ScreenScale(97) + (bipodhint / 7.5)) -- Black
                    surface.SetTextColor(0, 0, 0, blink)
                    surface.DrawText(textlow)

                    surface.SetTextPos(scrw / 2 - twlow / 2, scrh / 2 + ScreenScale(97) + (bipodhint / 7.5)) -- White
                    surface.SetTextColor(255, 255, 100, blink)
                    surface.DrawText(textlow)
                elseif (ia and mag) or (!ia and mag and maxmag > 0) then -- If low on ammo and have reserve ammo
                    surface.SetTextColor(255, 255, 255, 255)
                    local symbol = CreateControllerKeyLine({x = scrw / 2-ScreenScale(10) - (tw * 0.5) + ScreenScale(5), y = scrh / 2 + 7.5 + ScreenScale(96) + (bipodhint / 7.5), size = ScreenScale(8), font = "ARC9_12", font_keyb = "ARC9_12" }, { glyph, ScreenScale(7) })

                    surface.SetDrawColor(0, 0, 0, 175 * math.abs(math.sin(ct * 5)))
                    surface.DrawRect(scrw / 2 - tw / 2 + ScreenScale(4.75), scrh / 2 + ScreenScale(98) + (bipodhint / 7.5), tw + 5, 27.5)

                    surface.SetTextPos(scrw / 2 - tw / 2 + 2 + ScreenScale(5), scrh / 2 + 2 + ScreenScale(97) + (bipodhint / 7.5)) -- Black
                    surface.SetTextColor(0, 0, 0, blink)
                    surface.DrawText(text)

                    surface.SetTextPos(scrw / 2 - tw / 2 + ScreenScale(5), scrh / 2 + ScreenScale(97) + (bipodhint / 7.5)) -- White
                    surface.SetTextColor(255, 255, 255, blink)
                    surface.DrawText(text)

                end
            end
        end

        if arc9_center_jam:GetBool() and self:GetJammed() and not self:StillWaiting() then -- If weapon is Jammed
            if !self:GetProcessedValue("Overheat", true) then -- overheat makes guns auto unjam so hint is useless
                local textunjam = ARC9:GetPhrase("hud.hint.unjam")
                local twunjam = surface.GetTextSize(textunjam)

                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetFont("ARC9_12")

                surface.SetTextColor(255, 255, 255, 255)
                local symbol = CreateControllerKeyLine({x = scrw / 2-ScreenScale(10) - (surface.GetTextSize(textunjam) * 0.5) + ScreenScale(5), y = scrh / 2 + 7.5 + ScreenScale(96) + (bipodhint / 7.5), size = ScreenScale(8), font = "ARC9_12", font_keyb = "ARC9_12" }, { glyph, ScreenScale(7) })

                surface.SetDrawColor(0, 0, 0, 175 * math.abs(math.sin(ct * 5)))
                surface.DrawRect(scrw / 2 - surface.GetTextSize(textunjam) / 2 + ScreenScale(4.75), scrh / 2 + ScreenScale(98) + (bipodhint / 7.5), surface.GetTextSize(textunjam) + 5, 27.5)

                surface.SetTextPos(scrw / 2 - surface.GetTextSize(textunjam) / 2 + 2 + ScreenScale(5), scrh / 2 + 2 + ScreenScale(97) + (bipodhint / 7.5)) -- Black
                surface.SetTextColor(0, 0, 0, blink)
                surface.DrawText(textunjam)

                surface.SetTextPos(scrw / 2 - surface.GetTextSize(textunjam) / 2 + ScreenScale(5), scrh / 2 + ScreenScale(97) + (bipodhint / 7.5)) -- White
                surface.SetTextColor(255, 255, 255, blink)
                surface.DrawText(textunjam)

            end
        end

        if arc9_center_overheat:GetBool() and !arc9_hud_arc9:GetBool() and self:GetProcessedValue("Overheat", true) then
            local heat = self:GetHeatAmount()
            local heatcap = self:GetProcessedValue("HeatCapacity", true)
            local heatlocked = self:GetHeatLockout()
            local hud_t_full = Material("arc9/thermometer_full.png", "mips smooth")
            local hud_t_empty = Material("arc9/thermometer_empty.png", "mips smooth")
            local fill = math.Clamp(0.035 + (0.9 * heat) / heatcap, 0, 1)
            local wp = 25
            local xp = 70
            local col = {
                white = Color(255,255,255, heat * 1.5),
                black = Color(0,0,0, heat * 1.5),
                red = Color(255,255,255, heat * 1.5),
                redblink = Color(255, 255 * math.abs(math.sin(ct * 5)), 255 * math.abs(math.sin(ct * 5)), heat * 1.5),
            }

            local flashheatbar = false
            if heatlocked then flashheatbar = true end

            local heat_col = col["white"]

            if arc9_center_overheat_dark:GetBool() then heat_col = col["black"] end

            if heat > (heatcap * 0.75) then
                heat_col = col["redblink"]
            end

            surface.SetDrawColor(col.black)
            surface.SetMaterial(hud_t_full)
            surface.DrawTexturedRectUV(scrw / 2 - ScreenScale(wp), scrh / 2 + ScreenScale(xp), math.ceil(150 * fill), 60, 0, 0, fill, 1)

            surface.SetDrawColor(heat_col)
            surface.SetMaterial(hud_t_full)
            surface.DrawTexturedRectUV(scrw / 2 - ScreenScale(wp), scrh / 2 + ScreenScale(xp), math.ceil(150 * fill), 60, 0, 0, fill, 1)

            surface.SetDrawColor(col.black)
            surface.SetMaterial(hud_t_empty)
            surface.DrawTexturedRectUV(scrw / 2 - ScreenScale(wp) + math.ceil(150 * fill), scrh / 2 + ScreenScale(xp), 150 * (1 - fill), 60, fill, 0, 1, 1)

            surface.SetDrawColor(heat_col)
            surface.SetMaterial(hud_t_empty)
            surface.DrawTexturedRectUV(scrw / 2 - ScreenScale(wp) + math.ceil(150 * fill), scrh / 2 + ScreenScale(xp), 150 * (1 - fill), 60, fill, 0, 1, 1)
        end

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

        if arc9_center_firemode:GetBool() then
            local fm = self:GetFiremodeName()

            if lastfiremode != fm and self:GetReadyTime() - ct <= 0 then
                -- if   more than 1 fm   OR   fm is safety   OR   switched from safety
                if (#self:GetValue("Firemodes") or 0) > 1 or self:GetSafe() or lastfiremode == ARC9:GetPhrase("hud.firemode.safe") then
                    lastfiremodetime = ct
                    lastfiremode = fm
                end
            end

            if ct - lastfiremodetime < 1 then
                local funnynumber = math.min(1, math.sin(3.5 * math.Clamp(ct - lastfiremodetime, 0, 1)) * 2.5)
                firemodealpha = funnynumber * 255

                local text = fm
                surface.SetFont("ARC9_10")
                local tw = surface.GetTextSize(fm)
                -- local blink = math.abs(math.sin(ct * 10))


                surface.SetDrawColor(255, 255, 255, firemodealpha)

                surface.SetTextColor(0, 0, 0, firemodealpha) -- Black BG
                surface.SetTextPos(scrw / 2 - tw / 2, scrh / 2 + ScreenScale(60))
                surface.DrawText(fm)

                surface.SetTextColor(255, 255, 255, firemodealpha)
                surface.SetTextPos(scrw / 2 - tw / 2 - 2, scrh / 2 + ScreenScale(60) - 2)
                surface.DrawText(fm)
            end
        end

        if arc9_cruelty_reload:GetBool() and input.IsKeyDown(input.GetKeyCode(self:GetBinding("+reload"))) then
            -- Draw vertical line

            local col = Color(255, 255, 255, 255)

            local reloadline_x = scrw * 3 / 4

            surface.SetDrawColor(col)
            surface.DrawLine(reloadline_x, 0, reloadline_x, scrh)

            local reloadline_target_w = scrw / 20
            local reloadline_target_y = scrh * 2 / 3

            surface.DrawLine(reloadline_x - (reloadline_target_w / 2), reloadline_target_y, reloadline_x + (reloadline_target_w / 2), reloadline_target_y)

            surface.SetFont("ARC9_16")
            local text = "Reload"
            local text_w, text_h = surface.GetTextSize(text)

            surface.SetTextPos(reloadline_x + ARC9ScreenScale(2), reloadline_target_y - text_h)
            surface.SetTextColor(col)
            surface.DrawText(text)

            surface.SetFont("ARC9_16")
            local text2 = "Drag down to reload!!!"
            local text2_w, text2_h = surface.GetTextSize(text2)

            surface.SetTextPos(reloadline_x + ARC9ScreenScale(2), reloadline_target_y + ARC9ScreenScale(2))
            surface.SetTextColor(Color(255, 255, 255, 255 * math.abs(math.sin(ct * 5))))
            surface.DrawText(text2)

            local reloadline_mover_y = reloadline_target_y * ARC9.ReloadAmount

            surface.DrawLine(reloadline_x - (reloadline_target_w / 2), reloadline_mover_y, reloadline_x + (reloadline_target_w / 2), reloadline_mover_y)
        end

        -- if !self:GetCustomize() and self:GetInspecting() then -- If weapon is inspecting
            -- local deadzonex = GetConVar("arc9_hud_deadzonex")
            -- local hx = ARC9ScreenScale(10) + deadzonex:GetInt()
            -- local hy = ScrH() / 2 + ARC9ScreenScale(100)
            -- local hud_sillyhints = Material("arc9/sillyhintsblur.png", "mips")

            -- surface.SetDrawColor(ARC9.GetHUDColor("shadow", 200))
            -- surface.SetMaterial(hud_sillyhints)
            -- surface.DrawTexturedRect(hx - ARC9ScreenScale(12.5), hy, ARC9ScreenScale(100), ARC9ScreenScale(11)+ARC9ScreenScale(10))

            -- surface.SetFont("ARC9_12") -- Weapon Name
            -- surface.SetTextPos(hx + ARC9ScreenScale(1.5), hy + ARC9ScreenScale(1.5)) -- Black
            -- surface.SetTextColor(0, 0, 0, 175)
            -- surface.DrawText(self:GetPrintName())

            -- surface.SetTextPos(hx, hy) -- White
            -- surface.SetTextColor(255, 255, 255, 255)
            -- surface.DrawText(self:GetPrintName())

            -- surface.SetFont("ARC9_8")-- Category
            -- surface.SetTextPos(hx + ARC9ScreenScale(1.5), hy + ARC9ScreenScale(11.5)) -- Black
            -- surface.SetTextColor(0, 0, 0, 175)
            -- surface.DrawText(self.Class or " ")

            -- surface.SetTextPos(hx, hy + ARC9ScreenScale(10)) -- White
            -- surface.SetTextColor(255, 255, 255, 255)
            -- surface.DrawText(self.Class or " ")
        -- end
    end

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
        if !file.Exists(filename, "DATA") then
            filename = ARC9.PresetPath .. self:GetPresetBase() .. "/default." .. ARC9.PresetIconFormat
        end
        selecticon = Material("data/" .. filename, "smooth")
    end

    if !selecticon then return end

    self.WepSelectIcon = selecticon:GetTexture("$basetexture")
    if self:GetJammed() then
        surface.SetDrawColor(200, 50, 50, a)
    else
        surface.SetDrawColor(255, 255, 255, a)
    end

    surface.SetMaterial(selecticon)
    if w > h then
        y = y - ((w - h) / 2)
    end
    surface.DrawTexturedRect(x, y, w, w)
    // surface.DrawTexturedRectUV(x, y, w, w, 0, 0, 1, 1)
end

SWEP.AutoSelectIcon = nil

function SWEP:DoIconCapture(instant)
    if instant then self:DoPresetCapture(ARC9.PresetPath .. self:GetPresetBase() .. "_icon") return end
    timer.Simple(0.05, function() -- helps with flickering
        if IsValid(self) then
            self:DoPresetCapture(ARC9.PresetPath .. self:GetPresetBase() .. "_icon")
        end
    end)
end

local arc9_imperial = GetConVar("arc9_imperial")
function SWEP:RangeUnitize(range)
    if arc9_imperial:GetBool() then return tostring(math.Round(range * ARC9.HUToM * 1.0936)) .. ARC9:GetPhrase("unit.yard") end
    return tostring(math.Round(range * ARC9.HUToM)) .. ARC9:GetPhrase("unit.meter")
end

function SWEP:CustomAmmoDisplay()
    if self:GetProcessedValue("BottomlessClip") then
        self.AmmoDisplay = self.AmmoDisplay or {}
        self.AmmoDisplay.Draw = true

        self.AmmoDisplay.PrimaryClip = -1
        self.AmmoDisplay.PrimaryAmmo = self:Ammo1() + self:Clip1()

        return self.AmmoDisplay
    end
end