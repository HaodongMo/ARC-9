local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
}

hook.Add("HUDShouldDraw", "ARC9_HideHUD", function(name)
    if !IsValid(LocalPlayer()) then return end

    if ARC9.ShouldDrawHUD() then
        if hide[name] then return false end
    end
end)

ARC9.Colors = {
    bg      = Color(66, 66, 61),
    fg      = Color(220, 220, 188),
    sel     = Color(255, 150, 100),
    occupied = Color(150, 255, 100),
    hi      = Color(255, 255, 255),
    shadow  = Color(17, 17, 9),

    neg     = Color(255, 100, 100),
    pos     = Color(100, 255, 100),

    bg_3d = Color(255, 255, 255),
    fg_3d = Color(0, 0, 0),
    shadow_3d = Color(0, 0, 0),
    hi_3d = Color(255, 50, 50)
}

function ARC9.ShouldDrawHUD()
    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 then return end

    return true
end

function ARC9.GetHUDColor(part, alpha)
    local col = ARC9.Colors[part] or ARC9.Colors.hi
    col.a = alpha or 255
    return col
end

local lastammo = 0
local lastshoottime = 0
local rackrisetime = 0
local lastshotalpha = 0
local lastrow = 0

local firemode_pics = {
    [-1] = Material("arc9/fs_auto.png", "mips smooth"),
    [0] = Material("arc9/fs_safe.png", "mips smooth"),
    [1] = Material("arc9/fs_semi.png", "mips smooth"),
    [2] = Material("arc9/fs_2rb.png", "mips smooth"),
    [3] = Material("arc9/fs_3rb.png", "mips smooth"),
}

function ARC9.DrawHUD()
    if !ARC9.ShouldDrawHUD() then return end

    local weapon = LocalPlayer():GetActiveWeapon()

    local weapon_printname = weapon:GetPrintName()
    local weapon_clipsize = weapon:GetMaxClip1()
    local weapon_clip = weapon:Clip1()
    local weapon_reserve = weapon:Ammo1()

    local firemode_pic = firemode_pics[-1]

    if !weapon.Primary.Automatic then
        firemode_pic = firemode_pics[1]
    end

    if weapon.ARC9 then
        local arc9_mode = weapon:GetCurrentFiremodeTable()

        if arc9_mode.Icon then
            firemode_pic = arc9_mode.Icon
        else
            if firemode_pics[arc9_mode.Mode] then
                firemode_pic = firemode_pics[arc9_mode.Mode]
            elseif arc9_mode.Mode < 0 then
                firemode_pic = firemode_pics[-1]
            else
                firemode_pic = firemode_pics[3]
            end
        end

        if weapon:GetSafe() then
            firemode_pic = firemode_pics[0]
        end
    end

    local chambered = math.max(weapon_clip - weapon_clipsize, 0)
    local clip_to_show = math.min(weapon_clip, weapon_clipsize)

    local s_right = 2
    local s_down = 1

    cam.Start3D()

    local up, right, forward = EyeAngles():Up(), EyeAngles():Right(), EyeAngles():Forward()

    local ang = EyeAngles()
    local ang2 = EyeAngles()

    -- ang = ang + Angle(0, 180, 0)

    -- ang = -ang

    ang:RotateAroundAxis(up, 175)
    ang:RotateAroundAxis(right, 80)
    ang:RotateAroundAxis(forward, -90)

    ang2:RotateAroundAxis(up, 185)
    ang2:RotateAroundAxis(right, 110)
    ang2:RotateAroundAxis(forward, -90)

    cam.Start3D2D(EyePos() + (forward * 8) + (up * -3.25) + (right * -9.5), ang2, 0.0125 )
        surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 20))
        surface.DrawRect( 0, 0, 250, 70 )

        local health_x = 8
        local health_y = 4
        local health = math.Round((LocalPlayer():Health() / LocalPlayer():GetMaxHealth()) * 100)
        health = "♥:" .. tostring(health) .. "%"

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_24_Unscaled")
        surface.SetTextPos(health_x + s_right, health_y + s_down)
        surface.DrawText(health)

        surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
        surface.SetFont("ARC9_24_Unscaled")
        surface.SetTextPos(health_x, health_y)
        surface.DrawText(health)

        local armor_x = 8
        local armor_y = 36
        local armor = math.Round((LocalPlayer():Armor() / 100) * 100)
        armor = "®:" .. tostring(armor) .. "%"

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_24_Unscaled")
        surface.SetTextPos(armor_x + s_right, armor_y + s_down)
        surface.DrawText(armor)

        surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
        surface.SetFont("ARC9_24_Unscaled")
        surface.SetTextPos(armor_x, armor_y)
        surface.DrawText(armor)
    cam.End3D2D()

    cam.Start3D2D(EyePos() + (forward * 8) + (up * -3) + (right * 5), ang, 0.0125 )
        surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 20))
        surface.DrawRect( 0, 0, 320, 70 )

        -- local title_x = 8
        -- local title_y = 2

        -- surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        -- surface.SetFont("ARC9_24_Unscaled")
        -- surface.SetTextPos(title_x + s_right, title_y + s_down)
        -- surface.DrawText(weapon_printname)

        -- surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
        -- surface.SetFont("ARC9_24_Unscaled")
        -- surface.SetTextPos(title_x, title_y)
        -- surface.DrawText(weapon_printname)

        local ammo_x = 8
        local ammo_y = 4
        local ammo_text = tostring(clip_to_show)

        if chambered > 0 then
            ammo_text = ammo_text .. "+" .. tostring(chambered)
        end

        ammo_text = ammo_text .. "/" .. tostring(weapon_reserve)

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_24_Unscaled")
        surface.SetTextPos(ammo_x + s_right, ammo_y + s_down)
        surface.DrawText(ammo_text)

        surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
        surface.SetFont("ARC9_24_Unscaled")
        surface.SetTextPos(ammo_x, ammo_y)
        surface.DrawText(ammo_text)

        surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetMaterial(firemode_pic)
        surface.DrawTexturedRect(280 + s_right, 2 + s_down, 32, 32)

        surface.SetDrawColor(ARC9.GetHUDColor("fg_3d", 255))
        surface.SetMaterial(firemode_pic)
        surface.DrawTexturedRect(280, 2, 32, 32)

        // bullet fields

        local b_alpha = 225

        local b_m_left = -8
        local b_m_down = 34
        local b_m_margin = 2

        local row_size = 19

        local row1_bullets = 0
        local row2_bullets = 0
        local rackrise = 0

        local disparity = weapon_clipsize % row_size

        local corrected = clip_to_show - disparity

        local row = math.ceil(corrected / row_size)

        local sb = 14

        local crc = clip_to_show

        if disparity > 0 then
            crc = clip_to_show + row_size - disparity
        end

        if crc > row_size then
            row2_bullets = math.min(row_size, clip_to_show + disparity)
            row1_bullets = (corrected % row_size)

            if row1_bullets == 0 then
                row1_bullets = row_size
            end

            if clip_to_show <= row_size + disparity then
                row2_bullets = disparity
            end

            if row < lastrow then
                rackrisetime = CurTime()
            end

            lastrow = row
        else
            row2_bullets = clip_to_show
        end

        if rackrisetime + 0.2 > CurTime() then
            local rackrisedelta = ((rackrisetime + 0.2) - CurTime()) / 0.2
            rackrise = rackrisedelta * (sb + b_m_margin)
        end

        for i = 1, row1_bullets do
            surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.DrawRect(b_m_left + ((sb + b_m_margin) * i) + s_right, b_m_down + rackrise + s_down, sb, sb)

            if row1_bullets - i < chambered then
                surface.SetDrawColor(ARC9.GetHUDColor("hi_3d", b_alpha))
            else
                surface.SetDrawColor(ARC9.GetHUDColor("fg_3d", b_alpha))
            end
            surface.DrawRect(b_m_left + ((sb + b_m_margin) * i), b_m_down + rackrise, sb, sb)
        end

        for i = 1, row2_bullets do
            surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.DrawRect(b_m_left + ((sb + b_m_margin) * i) + s_right, b_m_down + sb + b_m_margin + rackrise + s_down, sb, sb)

            if row2_bullets - i < chambered - row1_bullets then
                surface.SetDrawColor(ARC9.GetHUDColor("hi_3d", b_alpha))
            else
                surface.SetDrawColor(ARC9.GetHUDColor("fg_3d", b_alpha))
            end
            surface.DrawRect(b_m_left + ((sb + b_m_margin) * i), b_m_down + sb + b_m_margin + rackrise, sb, sb)
        end

    cam.End3D2D()

    cam.End3D()
end

hook.Add("HUDPaint", "ARC9_DrawHud", ARC9.DrawHUD)