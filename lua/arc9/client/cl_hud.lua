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

    bg_3d = Color(255, 255, 240),
    fg_3d = Color(0, 0, 0),
    shadow_3d = Color(0, 0, 0),
    hi_3d = Color(255, 50, 50),
    pos_3d = Color(255, 255, 255),

    bg_menu = Color(26, 26, 23, 252),
    md = Color(107,107,92)
}

function ARC9.ShouldDrawHUD()
    if !GetConVar("cl_drawhud"):GetBool() then return false end

    local wpn = LocalPlayer():GetActiveWeapon()

    if !wpn.ARC9 and !GetConVar("arc9_hud_always"):GetBool() then return end
    -- if !wpn.ARC9 then return end

    return true
end

function ARC9.GetHUDColor(part, alpha)
    alpha = alpha or 255
    local col = ARC9.Colors[part] or ARC9.Colors.hi
    if alpha < 255 then
        col = Color(col.r, col.g, col.b)
        col.a = alpha or 255
    end
    return col
end

local rackrisetime = 0
local lastrow = 0
local lastweapon = NULL
local hint_alpha = 1
local lasthintcount = 0
local hidefadetime = 0
local first = true

local hud_bg = Material("arc9/hud_bg.png", "mips smooth")
local hud_t_full = Material("arc9/thermometer_full.png", "mips")
local hud_t_empty = Material("arc9/thermometer_empty.png", "mips")

local firemode_pics = {
    [-1] = Material("arc9/fs_auto.png", "mips smooth"),
    [0] = Material("arc9/fs_safe.png", "mips smooth"),
    [1] = Material("arc9/fs_semi.png", "mips smooth"),
    [2] = Material("arc9/fs_2rb.png", "mips smooth"),
    [3] = Material("arc9/fs_3rb.png", "mips smooth"),
}

local automatics = {
    ["weapon_smg1"] = true,
    ["weapon_ar2"] = true,
    ["weapon_mp5_hl1"] = true,
    ["weapon_gauss"] = true,
    ["weapon_egon"] = true
}

local function GetWeaponCapabilities(wpn)
    cap = {
        UBGL = tobool(!wpn:GetInSights() and wpn:GetValue("UBGL")),
        Bash = tobool(!wpn:GetInSights() and wpn:GetValue("Bash")),
        SwitchSights = tobool(wpn:GetInSights() and #wpn.MultiSightTable > 1),
        Inspect = tobool(!wpn:GetInSights() and wpn:HasAnimation("enter_inspect") or wpn:HasAnimation("enter_inspect")),
        Blindfire = tobool(!wpn:GetInSights() and wpn:GetValue("CanBlindFire")),
        BlindfireLeft = tobool(!wpn:GetInSights() and wpn:GetValue("CanBlindFire") and wpn:GetValue("BlindFireLeft")),
        Firemode = tobool(!wpn:GetUBGL() and #wpn:GetValue("Firemodes") > 1),
        HoldBreath = tobool(wpn:GetInSights() and wpn:GetValue("HoldBreathTime") > 0)
    }

    return cap
end

function ARC9.DrawHUD()
    if !ARC9.ShouldDrawHUD() then return end

    local weapon = LocalPlayer():GetActiveWeapon()

    if !IsValid(weapon) then return end

    if lastweapon != weapon then
        rackrisetime = CurTime()
        lastrow = 0
        hidefadetime = CurTime()
    end

    -- local weapon_printname = weapon:GetPrintName()
    local weapon_clipsize = weapon:GetMaxClip1()
    local weapon_clip = weapon:Clip1()
    local weapon_reserve = LocalPlayer():GetAmmoCount(weapon:GetPrimaryAmmoType())

    local flash_period = 3

    local firemode_text = "AUTO"
    local firemode_pic = firemode_pics[-1]

    local chambered = math.max(weapon_clip - weapon_clipsize, 0)
    local clip_to_show = math.min(weapon_clip, weapon_clipsize)

    local inf_clip = false
    local inf_reserve = false
    local melee = false
    local jammed = false
    local showheat = false
    local heat = 0
    local heatcap = 100
    local heatlocked = false
    local multiple_modes = false

    if weapon_clipsize <= 0 then
        inf_clip = true
        clip_to_show = weapon_reserve
    end

    if weapon.ARC9 then
        if weapon:GetCustomize() then return end

        local arc9_mode = weapon:GetCurrentFiremodeTable()

        if #weapon:GetValue("Firemodes") > 1 then
            multiple_modes = true
        end

        if weapon:GetUBGL() then
            arc9_mode = {
                Mode = weapon:GetCurrentFiremode(),
                PrintName = weapon:GetProcessedValue("UBGLFiremodeName")
            }
            weapon_clipsize = weapon:GetMaxClip2()
            weapon_clip = weapon:Clip2()
            weapon_reserve = LocalPlayer():GetAmmoCount(weapon:GetSecondaryAmmoType())
            multiple_modes = false
        end

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

        if arc9_mode.PrintName then
            firemode_text = arc9_mode.PrintName
        else
            if arc9_mode.Mode == 1 then
                firemode_text = "SEMI"
            elseif arc9_mode.Mode == 0 then
                firemode_text = "SAFE"
            elseif arc9_mode.Mode < 0 then
                firemode_text = "AUTO"
            elseif arc9_mode.Mode > 1 then
                firemode_text = tostring(arc9_mode.Mode) .. "BST"
            end
        end

        if weapon:GetSafe() then
            firemode_pic = firemode_pics[0]
            firemode_text = "SAFE"
        end

        if weapon:GetProcessedValue("BottomlessClip") then
            inf_clip = true
            weapon_reserve = weapon_reserve + weapon_clip
            clip_to_show = weapon_reserve
            weapon_clipsize = 30
            chambered = 0
        end

        if weapon:GetInfiniteAmmo() then
            inf_reserve = true
            if inf_clip then
                clip_to_show = 2147483640 - weapon:GetNthShot() % 2147483640
            end
        end

        if weapon:GetJammed() then
            jammed = true
        end

        if weapon:GetProcessedValue("Overheat") then
            showheat = true
            heat = weapon:GetHeatAmount()
            heatcap = weapon:GetProcessedValue("HeatCapacity")
            heatlocked = weapon:GetHeatLockout()
        end
    elseif weapon.ArcCW then
        local arccw_mode = weapon:GetCurrentFiremode()

        firemode_text = weapon:GetFiremodeName()
        // there was a reason I kept it to 4 letters you assholes

        firemode_text = string.Replace(firemode_text, "-", "")
        firemode_text = string.Replace(firemode_text, " ", "")
        firemode_text = string.sub(firemode_text, 1, 4)
        firemode_text = string.upper(firemode_text)

        if arccw_mode.Mode > 1 then
            firemode_pic = firemode_pics[-1]
        elseif arccw_mode.Mode == 1 then
            firemode_pic = firemode_pics[1]
        elseif firemode_pics[-arccw_mode.Mode] then
            firemode_pic = firemode_pics[-arccw_mode.Mode]
        else
            firemode_pic = firemode_pics[3]
        end
    elseif weapon:IsScripted() then
        if !weapon.Primary.Automatic then
            firemode_pic = firemode_pics[1]
            firemode_text = "SEMI"
        end

        if weapon.GetSafe then
            if weapon:GetSafe() then
                firemode_pic = firemode_pics[0]
                firemode_text = "SAFE"
            end
        end

        if isfunction(weapon.Safe) then
            if weapon:Safe() then
                firemode_pic = firemode_pics[0]
                firemode_text = "SAFE"
            end
        end

        if isfunction(weapon.Safety) then
            if weapon:Safety() then
                firemode_pic = firemode_pics[0]
                firemode_text = "SAFE"
            end
        end
    else
        if !automatics[weapon:GetClass()] then
            firemode_pic = firemode_pics[1]
            firemode_text = "SEMI"
        end
    end

    local flashammowidgets = false

    if (weapon_clip / weapon_clipsize) < 0.34 then
        flashammowidgets = true
        if weapon_clip == 0 then
            flashammowidgets = false
        end
    end

    if weapon_clipsize <= 0 and weapon:GetPrimaryAmmoType() == -1 then
        melee = true
        flashammowidgets = false
    end

    if inf_clip then
        weapon_clipsize = 30
    end

    if jammed then
        flashammowidgets = true
    end

    local flashheatbar = false

    if heatlocked then flashheatbar = true end

    local heat_col = ARC9.GetHUDColor("fg_3d", 200)

    if (flashheatbar and math.floor(CurTime() * flash_period) % 2 == 0) then
        heat_col = ARC9.GetHUDColor("hi_3d", 200)
    end

    local am_col = ARC9.GetHUDColor("fg_3d", 255)

    if (flashammowidgets and math.floor(CurTime() * flash_period) % 2 == 0) or (weapon_clip == 0 and !melee) then
        am_col = ARC9.GetHUDColor("hi_3d", 255)
    end

    local s_right = 2
    local s_down = 1

    -- cam.Start3D(Vector pos=EyePos(), Angle angles=EyeAngles(), number fov=nil, number x=0, number y=0, number w=ScrW(), number h=ScrH(), number zNear=nil, number zFar=nil)
    local anchorwidth = math.min(ScrW() / 2, ScrH() / 2)

    cam.Start3D(nil, nil, 55, 0, ScrH() - anchorwidth, anchorwidth, anchorwidth)
    -- cam.Start3D(nil, nil, 105)

    local up, right, forward = EyeAngles():Up(), EyeAngles():Right(), EyeAngles():Forward()

    local ang = EyeAngles()
    -- local ang = EyeAngles()

    -- ang = ang + Angle(0, 180, 0)

    -- ang = -ang

    -- ang:RotateAroundAxis(up, 175)
    -- ang:RotateAroundAxis(right, 80)
    -- ang:RotateAroundAxis(forward, -90)

    ang:RotateAroundAxis(up, 180)
    ang:RotateAroundAxis(right, 105)
    ang:RotateAroundAxis(forward, -95)

    -- cam.Start3D2D(EyePos() + (forward * 8) + (up * -3.25) + (right * -10), ang2, 0.0125 )
    -- cam.End3D2D()

    -- local ratio = ScrW() / ScrH()

    local pos = EyePos() + (forward * 4) + (up * -0.25) + (right * -1.5)

    pos, ang = ARC9.HUDBob(pos, ang)
    pos, ang = ARC9.HUDSway(pos, ang)

    cam.Start3D2D(pos, ang, 0.0125)
        -- surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 20))
        -- surface.DrawRect( 8, 4, 254, 110 )

        surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 20))
        surface.DrawRect( 0, 0, 254, 110 )

        surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 100))
        surface.SetMaterial(hud_bg)
        surface.DrawTexturedRect(0, 0, 254, 110)

        surface.DrawLine(0, 115, 254, 115)

        -- surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 20))
        -- surface.DrawRect( 0, 0, 140, 70 )

        local deco_x = 6
        local deco_y = 2
        local deco = "ARC9 UNIVERSAL HUD v1.03"

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_Deco_8_Unscaled")
        surface.SetTextPos(deco_x + s_right, deco_y + s_down)
        surface.DrawText(deco)

        surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
        surface.SetFont("ARC9_Deco_8_Unscaled")
        surface.SetTextPos(deco_x, deco_y)
        surface.DrawText(deco)

        local health_x = 8
        local health_y = 9
        local health = math.Clamp(LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0, 99.99)
        local overheal = LocalPlayer():Health() > LocalPlayer():GetMaxHealth() or LocalPlayer():Armor() > 100

        local flashhealthwidgets = false

        if LocalPlayer():Health() <= 10 then
            flashhealthwidgets = true
        end

        local hb_col = ARC9.GetHUDColor("fg_3d", 225)
        local hw_col = ARC9.GetHUDColor("fg_3d", 255)

        if (flashhealthwidgets and math.floor(CurTime() * flash_period) % 2 == 0) then
            hw_col = ARC9.GetHUDColor("hi_3d", 255)
            hb_col = ARC9.GetHUDColor("hi_3d", 170)
        end

        local hb_left = 30
        local hb_tall = 24
        local hb_wide = 209

        if !overheal then
            if LocalPlayer():Armor() > 0 then
                hb_tall = 18

                local armor = math.min(LocalPlayer():Armor() / 100, 1)

                surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
                surface.DrawRect(hb_left + s_right, 32 + s_down, hb_wide * armor, 3)

                surface.SetDrawColor(hb_col)
                surface.DrawRect(hb_left, 32, hb_wide * armor, 3)
            end

            surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
            if health < 1 then
                surface.DrawLine(hb_wide + hb_left + s_right, 12 + s_down, hb_wide + hb_left + s_right, 12 + hb_tall + s_down)
            end
            surface.DrawRect(hb_left + s_right, 12 + s_down, hb_wide * health, hb_tall)

            surface.SetDrawColor(hb_col)
            if health < 1 then
                surface.DrawLine(hb_wide + hb_left, 12, hb_wide + hb_left, 12 + hb_tall)
            end
            surface.DrawRect(hb_left, 12, hb_wide * health, hb_tall)
        end

        local healthtext = "♥"

        if overheal then
            healthtext = "♥:" .. tostring(health * 100) .. "%"
        end

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_24_Unscaled")
        surface.SetTextPos(health_x + s_right, health_y + s_down)
        surface.DrawText(healthtext)

        surface.SetTextColor(hw_col)
        surface.SetFont("ARC9_24_Unscaled")
        surface.SetTextPos(health_x, health_y)
        surface.DrawText(healthtext)

        if overheal then
            local armor_x = 250
            local armor_y = 9
            local armor = math.Round((LocalPlayer():Armor() / 100) * 100)
            armor = "⌂:" .. tostring(armor) .. "%"

            surface.SetFont("ARC9_24_Unscaled")
            armor_x = armor_x - surface.GetTextSize(armor)

            surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.SetFont("ARC9_24_Unscaled")
            surface.SetTextPos(armor_x + s_right, armor_y + s_down)
            surface.DrawText(armor)

            surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
            surface.SetFont("ARC9_24_Unscaled")
            surface.SetTextPos(armor_x, armor_y)
            surface.DrawText(armor)
        end

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

        if showheat then
            local therm_x = 174
            local therm_y = 66
            local therm_w = 70
            local therm_h = 35

            local therm_deco_x = 190
            local therm_deco_y = 97
            local therm_deco = "BARREL TEMP"

            surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.SetFont("ARC9_Deco_8_Unscaled")
            surface.SetTextPos(therm_deco_x + s_right, therm_deco_y + s_down)
            surface.DrawText(therm_deco)

            surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
            surface.SetFont("ARC9_Deco_8_Unscaled")
            surface.SetTextPos(therm_deco_x, therm_deco_y)
            surface.DrawText(therm_deco)

            local fill = math.Clamp(0.05 + (0.9 * heat) / heatcap, 0, 1)

            surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.SetMaterial(hud_t_full)
            surface.DrawTexturedRectUV(therm_x + s_right, therm_y + s_down, math.ceil(therm_w * fill), therm_h, 0, 0, fill, 1)
            -- surface.DrawTexturedRect(therm_x + s_right, therm_y + s_down, therm_s, therm_s)

            surface.SetDrawColor(heat_col)
            surface.SetMaterial(hud_t_full)
            surface.DrawTexturedRectUV(therm_x, therm_y, math.ceil(therm_w * fill), therm_h, 0, 0,  fill, 1)

            surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.SetMaterial(hud_t_empty)
            surface.DrawTexturedRectUV(therm_x + math.ceil(therm_w * fill) + s_right, therm_y + s_down, therm_w * (1 - fill), therm_h, fill, 0, 1, 1)
            -- surface.DrawTexturedRect(therm_x + s_right, therm_y + s_down, therm_s, therm_s)

            surface.SetDrawColor(heat_col)
            surface.SetMaterial(hud_t_empty)
            surface.DrawTexturedRectUV(therm_x + math.ceil(therm_w * fill), therm_y, therm_w * (1 - fill), therm_h, fill, 0, 1, 1)
            -- surface.DrawTexturedRect(therm_x, therm_y, therm_s, therm_s)
        end

        local ammo_x = 8
        local ammo_y = 40
        local ammo_text = tostring(weapon_clip)

        if inf_reserve then
            ammo_text = ammo_text .. "/∞"
            if inf_clip then
                ammo_text = "∞"
            end
        else
            ammo_text = ammo_text .. "/" .. tostring(weapon_reserve)
            if inf_clip then
                ammo_text = tostring(weapon_reserve)
            end
        end

        if melee then
            ammo_text = "-"
        end

        if jammed then
            ammo_text = "JAMMED!"
        end

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_24_Unscaled")
        surface.SetTextPos(ammo_x + s_right, ammo_y + s_down)
        surface.DrawText(ammo_text)

        surface.SetTextColor(am_col)
        surface.SetFont("ARC9_24_Unscaled")
        surface.SetTextPos(ammo_x, ammo_y)
        surface.DrawText(ammo_text)

        local fmi_x = 215
        local fmi_y = 38
        local fmi_s = 30

        surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetMaterial(firemode_pic)
        surface.DrawTexturedRect(fmi_x + s_right, fmi_y + s_down, fmi_s, fmi_s)

        surface.SetDrawColor(ARC9.GetHUDColor("fg_3d", 255))
        surface.SetMaterial(firemode_pic)
        surface.DrawTexturedRect(fmi_x, fmi_y, fmi_s, fmi_s)

        local fmm_text = firemode_text
        local fmm_x = 212
        local fmm_y = 39

        if !multiple_modes then
            fmm_y = 45
        end

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_12_Unscaled")
        local fmm_w = surface.GetTextSize(fmm_text)
        surface.SetTextPos(fmm_x + s_right - fmm_w, fmm_y + s_down)
        surface.DrawText(fmm_text)

        surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
        surface.SetFont("ARC9_12_Unscaled")
        surface.SetTextPos(fmm_x - fmm_w, fmm_y)
        surface.DrawText(fmm_text)

        if multiple_modes then
            local fmh_text = "[" .. ARC9.GetBindKey("+zoom") .. "]"
            local fmh_x = 212
            local fmh_y = 53

            surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.SetFont("ARC9_12_Unscaled")
            local fmh_w = surface.GetTextSize(fmh_text)
            surface.SetTextPos(fmh_x + s_right - fmh_w, fmh_y + s_down)
            surface.DrawText(fmh_text)

            surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
            surface.SetFont("ARC9_12_Unscaled")
            surface.SetTextPos(fmh_x - fmh_w, fmh_y)
            surface.DrawText(fmh_text)
        end

        // bullet fields

        local b_alpha = 225

        local b_m_left = -8
        local b_m_down = 72
        local b_m_margin = 2

        local row_size = 15

        if showheat then
            row_size = 10
        end

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

    if weapon.ARC9 then
        local capabilities = GetWeaponCapabilities(weapon)

        -- local hints = {
        --     {
        --         {"E", "R"},
        --         "Inspect"
        --     },
        --     {
        --         {"E", "M2"},
        --         "Toggle Alt-Weapon"
        --     },
        --     {
        --         {"E", "M1"},
        --         "Bash"
        --     },
        --     {
        --         {"B"},
        --         "Switch Firemode"
        --     },
        -- }

        local hints = {}

        if capabilities.UBGL then
            local str = "[" .. ARC9.GetBindKey("+use") .. "&" .. ARC9.GetBindKey("+attack2") .. "]"
            str = str .. " Toggle Weapon"

            table.insert(hints, str)
        end

        if capabilities.SwitchSights then
            local str = "[" .. ARC9.GetBindKey("+walk") .. "&" .. ARC9.GetBindKey("+use") .. "]"
            str = str .. " Switch Sights"

            table.insert(hints, str)
        end

        if capabilities.HoldBreath then
            local str = "[" .. ARC9.GetBindKey("+speed") .. "]"
            str = str .. " Hold Breath"

            table.insert(hints, str)
        end

        if capabilities.Bash then
            local str = "[" .. ARC9.GetBindKey("+use") .. "&" .. ARC9.GetBindKey("+attack") .. "]"
            str = str .. " Bash"

            table.insert(hints, str)
        end

        if capabilities.Inspect then
            local str = "[" .. ARC9.GetBindKey("+use") .. "&" .. ARC9.GetBindKey("reload") .. "]"
            str = str .. " Inspect"

            table.insert(hints, str)
        end

        if capabilities.Blindfire then
            local str = "[" .. ARC9.GetBindKey("+alt1") .. "&" .. ARC9.GetBindKey("+forward") .. "]"
            str = str .. " Blindfire"

            table.insert(hints, str)
        end

        if capabilities.BlindfireLeft then
            local str = "[" .. ARC9.GetBindKey("+alt1") .. "&" .. ARC9.GetBindKey("+moveleft") .. "]"
            str = str .. " Blindfire Left"

            table.insert(hints, str)
        end

        if capabilities.Firemode then
            local str = "[" .. ARC9.GetBindKey("+zoom") .. "]"
            str = str .. " Change Firemode"

            table.insert(hints, str)
        end

        local str = "[" .. ARC9.GetBindKey("+menu_context") .. "]"

        if weapon:GetInSights() then
            str = str .. " Peek"
        else
            str = str .. " Customize"
        end

        table.insert(hints, str)

        local str2 = "[" .. ARC9.GetBindKey("+use") .. "&" .. ARC9.GetBindKey("+zoom") .. "]"
        str2 = str2 .. " Toggle Safe"

        table.insert(hints, str2)

        if lasthintcount != #hints and hidefadetime + 1.5 < CurTime() then
            hidefadetime = CurTime()
        end

        if weapon:GetInSights() and hidefadetime + 1.5 < CurTime() then
            hidefadetime = CurTime()
        end

        if first then
            hidefadetime = CurTime() + 10
            first = false
        end

        lasthintcount = #hints

        local hx = 0
        local hy = 0

        if hidefadetime + 1.5 > CurTime() then
            hint_alpha = math.Approach(hint_alpha, 1, FrameTime() / 0.1)
        else
            hint_alpha = math.Approach(hint_alpha, 0, FrameTime() / 1)
        end

        cam.Start3D2D(pos - (ang:Right() * ((16 * #hints * 0.0125) + 0.25)), ang, 0.0125)
            for _, hint in ipairs(hints) do
                hx = 0

                surface.SetFont("ARC9_16_Unscaled")
                surface.SetTextColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
                surface.SetTextPos(hx + 4, hy + 2)
                surface.DrawText(hint)

                surface.SetFont("ARC9_16_Unscaled")
                surface.SetTextColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
                surface.SetTextPos(hx, hy)
                surface.DrawText(hint)

                hx = hx + surface.GetTextSize(hint)

                -- local hc = #hint[1]
                -- for v, i in ipairs(hint[1]) do
                --     if isstring(i) then
                --         surface.SetFont("ARC9_24_Unscaled")
                --         surface.SetTextColor(ARC9.GetHUDColor("fg"))

                --         surface.SetTextPos(hx, hy)
                --         surface.DrawText(i)

                --         hx = hx + surface.GetTextSize(i)
                --     end

                --     if v < hc then
                --         surface.SetFont("ARC9_24_Unscaled")
                --         surface.SetTextColor(ARC9.GetHUDColor("fg"))

                --         surface.SetTextPos(hx, hy)
                --         surface.DrawText("+")

                --         hx = hx + surface.GetTextSize("+")
                --     end
                -- end

                -- surface.SetFont("ARC9_24_Unscaled")
                -- surface.SetTextColor(ARC9.GetHUDColor("fg"))

                -- surface.SetTextPos(hx, hy)
                -- surface.DrawText("] ")

                -- hx = hx + surface.GetTextSize("] ")

                -- surface.SetFont("ARC9_24_Unscaled")
                -- surface.SetTextColor(ARC9.GetHUDColor("fg"))

                -- surface.SetTextPos(hx, hy)
                -- surface.DrawText(hint[2])

                -- hx = hx + surface.GetTextSize(hint[2])

                hy = hy + 16
            end
        cam.End3D2D()
    end

    cam.End3D()

    lastweapon = weapon
end

hook.Add("HUDPaint", "ARC9_DrawHud", ARC9.DrawHUD)