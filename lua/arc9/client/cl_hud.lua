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
local convar_keephints = GetConVar("arc9_hud_keephints")

local hud_bg = Material("arc9/hud_bg.png", "mips smooth")
local hud_t_full = Material("arc9/thermometer_full.png", "mips")
local hud_t_empty = Material("arc9/thermometer_empty.png", "mips")
local hud_bigblur = Material("arc9/bigblur.png", "mips")

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
        HoldBreath = tobool(wpn:GetInSights() and wpn:GetValue("HoldBreathTime") > 0),
        VariableZoom = tobool(wpn:GetInSights() and (wpn:GetSight().atttbl or {}).RTScopeAdjustable)
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
            local fmh_text = ARC9.GetBindKey("+zoom")--"[" .. ARC9.GetBindKey("+zoom") .. "]"
            local fmh_x = 212
            local fmh_y = 53

            if ARC9.CTRL_Lookup[fmh_text] then fmh_text = ARC9.CTRL_Lookup[fmh_text] end
            if ARC9.CTRL_ConvertTo[fmh_text] then fmh_text = ARC9.CTRL_ConvertTo[fmh_text] end
            if ARC9.CTRL_Exists[fmh_text] then fmh_text = Material( "arc9/glyphs_knockout/" .. fmh_text .. "_lg" .. ".png", "smooth" ) else fmh_text = "["..fmh_text.."]" end
            fmh_text = isstring(fmh_text) and fmh_text or { fmh_text, 16 }

            surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.SetFont("ARC9_12_Unscaled")
            local fmh_w = GetControllerKeyLineSize( { font = "ARC9_12_Unscaled" }, fmh_text )
            CreateControllerKeyLine( { x = fmh_x + s_right - fmh_w, y = fmh_y + s_down, size = 16, font = "ARC9_12_Unscaled" }, fmh_text )

            surface.SetDrawColor(ARC9.GetHUDColor("fg_3d", 255))
            surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
            surface.SetFont("ARC9_12_Unscaled")
            CreateControllerKeyLine( { x = fmh_x - fmh_w, y = fmh_y, size = 16, font = "ARC9_12_Unscaled" }, fmh_text )
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

        local CTRL = false--ARC9.ControllerMode()
        local hints = {}

        local glyphset = GetConVar("arc9_controller_glyphset"):GetString()
        if glyphset != "" then
            if glyphset:Left(1) == "!" then
                if glyphset == "!SC" then
                    ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_SC
                elseif glyphset == "!SD" then
                    ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_SD
                elseif glyphset == "!Xbox" then
                    ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_Xbox
                elseif glyphset == "!Xbox360" then
                    ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_Xbox360
                elseif glyphset == "!PS5" then
                    ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_PS5
                elseif glyphset == "!PS4" then
                    ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_PS4
                elseif glyphset == "!SwitchPro" then
                    ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_SwitchPro
                elseif glyphset == "!SwitchProXboxABXY" then
                    ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_SwitchPro_XboxABXY
                end
            else
                table.Empty(ARC9.CTRL_Set_UserCustom)
                local config = glyphset
                config = string.Split( config, "\\n" )
                for i, v in ipairs(config) do
                    local swig = string.Split( v, "\\t" )
                    ARC9.CTRL_Set_UserCustom[swig[1]] = swig[2]
                end
                ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_UserCustom
            end
        elseif sinput then
            if !sinput.enabled then sinput.Init() end
            local P1 = sinput.GetControllerForGamepadIndex(0)
            local controltype = sinput.GetInputTypeForHandle(P1)
            if !controltype or controltype == "Unknown" then
                ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_Xbox
            elseif controltype == "SteamController" then
                ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_SC
            elseif controltype == "XBox360Controller" then
                ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_Xbox360
            elseif controltype == "XBoxOneController" then
                ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_Xbox
            elseif controltype == "GenericXInput" then
                ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_Xbox
            elseif controltype == "PS4Controller" then
                ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_PS4
            elseif controltype == "SwitchProController" then
                ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_SwitchPro
            elseif controltype == "PS3Controller" then
                ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_PS4
            end
        else
            ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_Xbox
        end

        if capabilities.UBGL then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+use"),
                glyph2 = ARC9.GetBindKey("+attack2"),
                action = "Toggle Weapon"
            })
        end

        if capabilities.SwitchSights then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+walk"),
                glyph2 = ARC9.GetBindKey("+use"),
                action = "Switch Sights"
            })
        end

        if capabilities.VariableZoom then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("invnext"),
                glyph2 = ARC9.GetBindKey("invprev"),
                action = "Change Zoom"
            })
        end

        if capabilities.HoldBreath then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+speed"),
                action = "Hold Breath"
            })
        end

        if capabilities.Bash then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+use"),
                glyph2 = ARC9.GetBindKey("+attack"),
                action = "Bash"
            })
        end

        if capabilities.Inspect then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+reload"),
                glyph2 = ARC9.GetBindKey("+use"),
                action = "Inspect"
            })
        end

        if capabilities.Blindfire then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+alt1"),
                glyph2 = ARC9.GetBindKey("+forward"),
                action = "Blindfire"
            })
        end

        if capabilities.BlindfireLeft then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+alt1"),
                glyph2 = ARC9.GetBindKey("+moveleft"),
                action = "Blindfire Left"
            })
        end

        if capabilities.Firemode then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+zoom"),
                action = "Switch Firemode"
            })
        end

        if weapon:CanToggleAllStatsOnF() then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("impulse 100"),
                action = "Toggle Att. Stats"
            })
        end

        table.insert(hints, {
            glyph = ARC9.GetBindKey("+menu_context"),
            action = weapon:GetInSights() and "Peek" or "Customize" })

        table.insert(hints, {
            glyph = ARC9.GetBindKey("+use"),
            glyph2 = ARC9.GetBindKey("+zoom"),
            action = "Toggle Safe"
        })

        for i, v in ipairs(hints) do
            if ARC9.CTRL_Lookup[v.glyph] then v.glyph = ARC9.CTRL_Lookup[v.glyph] end
            if ARC9.CTRL_ConvertTo[v.glyph] then v.glyph = ARC9.CTRL_ConvertTo[v.glyph] end
            if ARC9.CTRL_Exists[v.glyph] then v.glyph = Material( "arc9/glyphs_light/" .. v.glyph .. "_lg" .. ".png", "smooth" ) end
            if v.glyph2 then 
                if ARC9.CTRL_Lookup[v.glyph2] then v.glyph2 = ARC9.CTRL_Lookup[v.glyph2] end
                if ARC9.CTRL_ConvertTo[v.glyph2] then v.glyph2 = ARC9.CTRL_ConvertTo[v.glyph2] end
                if ARC9.CTRL_Exists[v.glyph2] then v.glyph2 = Material( "arc9/glyphs_light/" .. v.glyph2 .. "_lg" .. ".png", "smooth" ) end
            end
        end

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
        local SIZE = 18

        if hidefadetime + 1.5 > CurTime() then
            hint_alpha = math.Approach(hint_alpha, 1, FrameTime() / 0.1)
        else
            hint_alpha = math.Approach(hint_alpha, 0, FrameTime() / 1)
        end
        if convar_keephints:GetBool() then hint_alpha = 1 end

        cam.Start3D2D(pos - (ang:Right() * ((16 * #hints * 0.0125) + 0.25)), ang, 0.0125)
            surface.SetDrawColor(ARC9.GetHUDColor("shadow", 150 * hint_alpha))
            surface.SetMaterial(hud_bigblur)
            surface.DrawTexturedRect(-32, 0, 300, 16 * #hints)

            for _, hint in ipairs(hints) do
                local strreturn = 0
                surface.SetFont("ARC9_16_Unscaled")
                surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
                surface.SetTextColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
                surface.SetTextPos(hx + 4, hy + 2)
                strreturn = CreateControllerKeyLine( {x = hx + 4, y = hy + 2, size = 16, font = "ARC9_16_Unscaled" }, { hint.glyph, SIZE }, (hint.glyph2 and " " or ""), (hint.glyph2 and { hint.glyph2, SIZE } or "") )
                CreateControllerKeyLine( {x = hx + 4 + math.max(strreturn, 48), y = hy + 2, size = 16, font = "ARC9_16_Unscaled" }, " " .. hint.action )


                surface.SetFont("ARC9_16_Unscaled")
                surface.SetDrawColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
                surface.SetTextColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
                surface.SetTextPos(hx, hy)
                strreturn = CreateControllerKeyLine( {x = hx, y = hy, size = 16, font = "ARC9_16_Unscaled" }, { hint.glyph, SIZE }, (hint.glyph2 and " " or ""), (hint.glyph2 and { hint.glyph2, SIZE } or "") )
                CreateControllerKeyLine( {x = hx + math.max(strreturn, 48), y = hy, size = 16, font = "ARC9_16_Unscaled" }, " " .. hint.action )

                hy = hy + 16
            end
        cam.End3D2D()
    end

    cam.End3D()

    lastweapon = weapon
end

hook.Add("HUDPaint", "ARC9_DrawHud", ARC9.DrawHUD)



-- Controller / key additions by Fesiug. Blame Fesiug!

local convar_controllermode = GetConVar("arc9_controller")
function ARC9.ControllerMode()
    return convar_controllermode:GetBool()
end

ARC9.CTRL_Set_PS4 = {
    xbox_button_select = "ps4_button_share",
    xbox_button_start = "ps4_button_options",
    xbox_button_logo = "ps4_button_logo",

    shared_button_a = "ps_button_x",
    shared_button_b = "ps_button_circle",
    shared_button_x = "ps_button_square",
    shared_button_y = "ps_button_triangle",

    xbox_lb = "ps4_l1",
    xbox_rb = "ps4_r1",
    xbox_lt = "ps4_l2",
    xbox_rt = "ps4_r2",
    xbox_lt_soft = "ps4_l2_soft",
    xbox_rt_soft = "ps4_r2_soft",

    shared_dpad = "ps_dpad",
    shared_dpad_down = "ps_dpad_down",
    shared_dpad_up = "ps_dpad_up",
    shared_dpad_left = "ps_dpad_left",
    shared_dpad_right = "ps_dpad_right",
}
ARC9.CTRL_Set_PS5 = {
    xbox_button_select = "ps5_button_create",
    xbox_button_start = "ps5_button_options",
    xbox_button_logo = "ps4_button_logo",

    shared_button_a = "ps_button_x",
    shared_button_b = "ps_button_circle",
    shared_button_x = "ps_button_square",
    shared_button_y = "ps_button_triangle",

    xbox_lb = "ps5_l1",
    xbox_rb = "ps5_r1",
    xbox_lt = "ps5_l2",
    xbox_rt = "ps5_r2",
    xbox_lt_soft = "ps5_l2_soft",
    xbox_rt_soft = "ps5_r2_soft",

    shared_dpad = "ps_dpad",
    shared_dpad_down = "ps_dpad_down",
    shared_dpad_up = "ps_dpad_up",
    shared_dpad_left = "ps_dpad_left",
    shared_dpad_right = "ps_dpad_right",

}
ARC9.CTRL_Set_SwitchPro = {
    xbox_button_select = "switchpro_button_minus",
    xbox_button_start = "switchpro_button_plus",
    xbox_button_logo = "switchpro_button_home",

    -- WHY DO I ALWAYS GET THE FREAKS?!
    shared_button_a = "shared_button_b",
    shared_button_b = "shared_button_a",
    shared_button_x = "shared_button_y",
    shared_button_y = "shared_button_x",

    shared_dpad = "switchpro_dpad",
    shared_dpad_down = "switchpro_dpad_down",
    shared_dpad_up = "switchpro_dpad_up",
    shared_dpad_left = "switchpro_dpad_left",
    shared_dpad_right = "switchpro_dpad_right",

    xbox_lb = "switchpro_l",
    xbox_rb = "switchpro_r",
    xbox_lt = "switchpro_l2",
    xbox_rt = "switchpro_r2",
    xbox_lt_soft = "switchpro_l2_soft",
    xbox_rt_soft = "switchpro_r2_soft",

    shared_lstick = "switchpro_lstick",
    shared_lstick_click = "switchpro_lstick_click",
    shared_lstick_down = "switchpro_lstick_down",
    shared_lstick_up = "switchpro_lstick_up",
    shared_lstick_left = "switchpro_lstick_left",
    shared_lstick_right = "switchpro_lstick_right",

    shared_rstick = "switchpro_rstick",
    shared_rstick_click = "switchpro_rstick_click",
    shared_rstick_down = "switchpro_rstick_down",
    shared_rstick_up = "switchpro_rstick_up",
    shared_rstick_left = "switchpro_rstick_left",
    shared_rstick_right = "switchpro_rstick_right",
}
ARC9.CTRL_Set_SwitchPro_XboxABXY = {
    xbox_button_select = "switchpro_button_minus",
    xbox_button_start = "switchpro_button_plus",
    xbox_button_logo = "switchpro_button_home",

    -- DON'T THOSE FREAKS HAVE FLIPPED ABXYs

    shared_dpad = "switchpro_dpad",
    shared_dpad_down = "switchpro_dpad_down",
    shared_dpad_up = "switchpro_dpad_up",
    shared_dpad_left = "switchpro_dpad_left",
    shared_dpad_right = "switchpro_dpad_right",

    xbox_lb = "switchpro_l",
    xbox_rb = "switchpro_r",
    xbox_lt = "switchpro_l2",
    xbox_rt = "switchpro_r2",
    xbox_lt_soft = "switchpro_l2_soft",
    xbox_rt_soft = "switchpro_r2_soft",

    shared_lstick = "switchpro_lstick",
    shared_lstick_click = "switchpro_lstick_click",
    shared_lstick_down = "switchpro_lstick_down",
    shared_lstick_up = "switchpro_lstick_up",
    shared_lstick_left = "switchpro_lstick_left",
    shared_lstick_right = "switchpro_lstick_right",

    shared_rstick = "switchpro_rstick",
    shared_rstick_click = "switchpro_rstick_click",
    shared_rstick_down = "switchpro_rstick_down",
    shared_rstick_up = "switchpro_rstick_up",
    shared_rstick_left = "switchpro_rstick_left",
    shared_rstick_right = "switchpro_rstick_right",
}
ARC9.CTRL_Set_SC = {
    xbox_button_select = "sc_button_l_arrow",
    xbox_button_start = "sc_button_r_arrow",
    xbox_button_logo = "sc_button_steam",

    shared_dpad = "sc_dpad",
    shared_dpad_down = "sc_dpad_down",
    shared_dpad_up = "sc_dpad_up",
    shared_dpad_left = "sc_dpad_left",
    shared_dpad_right = "sc_dpad_right",

    -- shared_dpad_click = "sc_dpad_click"
    -- shared_dpad_swipe = "sc_dpad_swipe"
    -- shared_dpad_touch = "sc_dpad_touch"

    xbox_lb = "sc_lb",
    xbox_rb = "sc_rb",
    xbox_lt = "sc_lt",
    xbox_rt = "sc_rt",
    xbox_lt_soft = "sc_lt_soft",
    xbox_rt_soft = "sc_rt_soft",
    xbox_p1 = "sc_rg",
    xbox_p3 = "sc_lg",

    -- xbox_lb_click = "sc_lt_click",
    -- xbox_rt_click = "sc_rt_click",
}
ARC9.CTRL_Set_SD = {
    xbox_button_select = "button_view",
    xbox_button_start = "button_menu",
    xbox_button_logo = "button_steam",
    xbox_button_share = "button_aux",

    xbox_lb = "sd_l1",
    xbox_rb = "sd_r1",
    xbox_lt = "sd_l2",
    xbox_rt = "sd_r2",
    xbox_lt_soft = "sd_l2_half",
    xbox_rt_soft = "sd_r2_half",

    xbox_p1 = "sd_r4",
    xbox_p2 = "sc_r5",
    xbox_p3 = "sd_l4",
    xbox_p4 = "sc_l5",
}
ARC9.CTRL_Set_Xbox360 = {
    xbox_button_select = "xbox360_button_select",
    xbox_button_start = "xbox360_button_select",
}
ARC9.CTRL_Set_Xbox = {}
ARC9.CTRL_Set_UserCustom = {}

ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_Xbox360 -- {}

ARC9.CTRL_Lookup = {
    MOUSE1 = "shared_mouse_l_click",
    MOUSE2 = "shared_mouse_r_click",
    MOUSE3 = "shared_mouse_mid_click",
    MOUSE4 = "shared_mouse_4",
    MOUSE5 = "shared_mouse_5",

    MWHEELUP = "shared_mouse_scroll_up",
    MWHEELDOWN = "shared_mouse_scroll_down",
}

ARC9.CTRL_BindTo = {
    ["+attack2"] = "xbox_lt_soft",
    ["+attack"] = "xbox_rt_soft",
    ["+jump"] = "shared_button_a",
    ["+reload"] = "shared_button_b",
    ["+use"] = "shared_button_x",
    ["+alt1"] = "shared_button_y",
    ["+speed"] = "shared_lstick_click",
    ["toggle_duck"] = "shared_rstick_click",
    ["+menu_context"] = "xbox_lb",
    ["+walk"] = "xbox_rb",
    ["invprev"] = "shared_dpad_up",
    ["impulse 100"] = "shared_dpad_right",
    ["invnext"] = "shared_dpad_down",
    ["+zoom"] = "shared_dpad_left",

    ["+forward"] = "shared_lstick_up",
    ["+back"] = "shared_lstick_down",
    ["+moveleft"] = "shared_lstick_left",
    ["+right"] = "shared_lstick_right",
}

ARC9.CTRL_Exists = {
    ps4_button_logo = true,
    ps4_button_options = true,
    ps4_button_share = true,
    ps4_l1 = true,
    ps4_l2 = true,
    ps4_l2_soft = true,
    ps4_r1 = true,
    ps4_r2 = true,
    ps4_r2_soft = true,
    ps4_trackpad_click = true,
    ps4_trackpad_down = true,
    ps4_trackpad_l_click = true,
    ps4_trackpad_l_down = true,
    ps4_trackpad_l_left = true,
    ps4_trackpad_l_right = true,
    ps4_trackpad_l_ring = true,
    ps4_trackpad_l_swipe = true,
    ps4_trackpad_l_touch = true,
    ps4_trackpad_l_up = true,
    ps4_trackpad_left = true,
    ps4_trackpad = true,
    ps4_trackpad_r_click = true,
    ps4_trackpad_r_down = true,
    ps4_trackpad_r_left = true,
    ps4_trackpad_r_right = true,
    ps4_trackpad_r_ring = true,
    ps4_trackpad_r_swipe = true,
    ps4_trackpad_r_touch = true,
    ps4_trackpad_r_up = true,
    ps4_trackpad_right = true,
    ps4_trackpad_ring = true,
    ps4_trackpad_swipe = true,
    ps4_trackpad_up = true,
    ps5_button_create = true,
    ps5_button_options = true,
    ps5_l1 = true,
    ps5_l2 = true,
    ps5_l2_soft = true,
    ps5_r1 = true,
    ps5_r2 = true,
    ps5_r2_soft = true,
    ps5_trackpad_click = true,
    ps5_trackpad_down = true,
    ps5_trackpad_l_click = true,
    ps5_trackpad_l_down = true,
    ps5_trackpad_l_left = true,
    ps5_trackpad_l_right = true,
    ps5_trackpad_l_ring = true,
    ps5_trackpad_l_swipe = true,
    ps5_trackpad_l_touch = true,
    ps5_trackpad_l_up = true,
    ps5_trackpad_left = true,
    ps5_trackpad = true,
    ps5_trackpad_r_click = true,
    ps5_trackpad_r_down = true,
    ps5_trackpad_r_left = true,
    ps5_trackpad_r_right = true,
    ps5_trackpad_r_ring = true,
    ps5_trackpad_r_swipe = true,
    ps5_trackpad_r_touch = true,
    ps5_trackpad_r_up = true,
    ps5_trackpad_right = true,
    ps5_trackpad_ring = true,
    ps5_trackpad_swipe = true,
    ps5_trackpad_up = true,
    ps_button_circle = true,
    ps_button_mute = true,
    ps_button_square = true,
    ps_button_triangle = true,
    ps_button_x = true,
    ps_color_button_circle = true,
    ps_color_button_square = true,
    ps_color_button_triangle = true,
    ps_color_button_x = true,
    ps_color_outlined_button_circle = true,
    ps_color_outlined_button_square = true,
    ps_color_outlined_button_triangle = true,
    ps_color_outlined_button_x = true,
    ps_dpad_down = true,
    ps_dpad_left = true,
    ps_dpad = true,
    ps_dpad_right = true,
    ps_dpad_up = true,
    ps_outlined_button_circle = true,
    ps_outlined_button_square = true,
    ps_outlined_button_triangle = true,
    ps_outlined_button_x = true,
    sc_button_l_arrow = true,
    sc_button_r_arrow = true,
    sc_button_steam = true,
    sc_dpad_click = true,
    sc_dpad_down = true,
    sc_dpad_left = true,
    sc_dpad = true,
    sc_dpad_right = true,
    sc_dpad_swipe = true,
    sc_dpad_touch = true,
    sc_dpad_up = true,
    sc_lb = true,
    sc_lg = true,
    sc_lt_click = true,
    sc_lt = true,
    sc_lt_soft = true,
    sc_rb = true,
    sc_rg = true,
    sc_rt_click = true,
    sc_rt = true,
    sc_rt_soft = true,
    sc_touchpad_click = true,
    sc_touchpad_down = true,
    sc_touchpad_edge = true,
    sc_touchpad_left = true,
    sc_touchpad = true,
    sc_touchpad_right = true,
    sc_touchpad_swipe = true,
    sc_touchpad_touch = true,
    sc_touchpad_up = true,
    sd_button_aux = true,
    sd_button_menu = true,
    sd_button_steam = true,
    sd_button_view = true,
    sd_l1 = true,
    sd_l2_half = true,
    sd_l2 = true,
    sd_l4 = true,
    sd_l5 = true,
    sd_ltrackpad_click = true,
    sd_ltrackpad_down = true,
    sd_ltrackpad_left = true,
    sd_ltrackpad = true,
    sd_ltrackpad_right = true,
    sd_ltrackpad_ring = true,
    sd_ltrackpad_swipe = true,
    sd_ltrackpad_up = true,
    sd_r1 = true,
    sd_r2_half = true,
    sd_r2 = true,
    sd_r4 = true,
    sd_r5 = true,
    sd_rtrackpad_click = true,
    sd_rtrackpad_down = true,
    sd_rtrackpad_left = true,
    sd_rtrackpad = true,
    sd_rtrackpad_right = true,
    sd_rtrackpad_ring = true,
    sd_rtrackpad_swipe = true,
    sd_rtrackpad_up = true,
    shared_button_a = true,
    shared_button_b = true,
    shared_button_x = true,
    shared_button_y = true,
    shared_buttons_e = true,
    shared_buttons_n = true,
    shared_buttons_s = true,
    shared_buttons_w = true,
    shared_color_button_a = true,
    shared_color_button_b = true,
    shared_color_button_x = true,
    shared_color_button_y = true,
    shared_color_outlined_button_a = true,
    shared_color_outlined_button_b = true,
    shared_color_outlined_button_x = true,
    shared_color_outlined_button_y = true,
    shared_dpad_down = true,
    shared_dpad_left = true,
    shared_dpad = true,
    shared_dpad_right = true,
    shared_dpad_up = true,
    shared_gyro = true,
    shared_gyro_pitch = true,
    shared_gyro_roll = true,
    shared_gyro_yaw = true,
    shared_l3 = true,
    shared_lstick_click = true,
    shared_lstick_down = true,
    shared_lstick_left = true,
    shared_lstick = true,
    shared_lstick_right = true,
    shared_lstick_touch = true,
    shared_lstick_up = true,
    shared_mouse_4 = true,
    shared_mouse_5 = true,
    shared_mouse_l_click = true,
    shared_mouse_mid_click = true,
    shared_mouse_r_click = true,
    shared_mouse_scroll_down = true,
    shared_mouse_scroll_up = true,
    shared_outlined_button_a = true,
    shared_outlined_button_b = true,
    shared_outlined_button_x = true,
    shared_outlined_button_y = true,
    shared_r3 = true,
    shared_rstick_click = true,
    shared_rstick_down = true,
    shared_rstick_left = true,
    shared_rstick = true,
    shared_rstick_right = true,
    shared_rstick_touch = true,
    shared_rstick_up = true,
    shared_touch_doubletap = true,
    shared_touch = true,
    shared_touch_tap = true,
    switchpro_button_capture = true,
    switchpro_button_home = true,
    switchpro_button_minus = true,
    switchpro_button_plus = true,
    switchpro_dpad_down = true,
    switchpro_dpad_left = true,
    switchpro_dpad = true,
    switchpro_dpad_right = true,
    switchpro_dpad_up = true,
    switchpro_l2 = true,
    switchpro_l2_soft = true,
    switchpro_l = true,
    switchpro_lstick_click = true,
    switchpro_lstick_down = true,
    switchpro_lstick_left = true,
    switchpro_lstick = true,
    switchpro_lstick_right = true,
    switchpro_lstick_up = true,
    switchpro_r2 = true,
    switchpro_r2_soft = true,
    switchpro_r = true,
    switchpro_rstick_click = true,
    switchpro_rstick_down = true,
    switchpro_rstick_left = true,
    switchpro_rstick = true,
    switchpro_rstick_right = true,
    switchpro_rstick_up = true,
    xbox360_button_select = true,
    xbox360_button_start = true,
    xbox_button_logo = true,
    xbox_button_select = true,
    xbox_button_share = true,
    xbox_button_start = true,
    xbox_lb = true,
    xbox_lt = true,
    xbox_lt_soft = true,
    xbox_p1 = true,
    xbox_p2 = true,
    xbox_p3 = true,
    xbox_p4 = true,
    xbox_rb = true,
    xbox_rt = true,
    xbox_rt_soft = true,
}

surface.CreateFont( "ARC9_KeybindPreview", {
	font = "Arial",
	size = 16,
	weight = 600,
	antialias = false,
} )

--[[
    Creates a controller key line.
Info:
     x: X position
     y: Y position
     size: Height of font
     font: Font to use

Vararg:
    String: Out goes a string.
    Table:
        If it has a proper glyph name, it is used.
        If it doesn't, it is made into a key.
]]
function CreateControllerKeyLine( info, ... )
    local args = { ... } 
    local strlength = 0

    for i, v in ipairs( args ) do
        if isstring(v) then
            -- Draw text.
            surface.SetTextPos(info.x + strlength, info.y)
            surface.DrawText(v)
            strlength = strlength + surface.GetTextSize(v)
        elseif istable(v) then
            local size = v[2]
            if isstring(v[1]) and !ARC9.CTRL_Exists[v[1]] then
                -- Draw a key.
                surface.SetFont("ARC9_KeybindPreview")
                local sx, sy = surface.GetTextSize(v[1])
                local keylength = math.max(6 + sx, 16)
                surface.DrawOutlinedRect(info.x + strlength, info.y, keylength, info.size )
                surface.SetTextPos(info.x + strlength - (sx/2) + (keylength/2), info.y - (sy/2) + (info.size/2) )
                surface.DrawText( v[1] )
                surface.SetFont(info.font)
                strlength = strlength + keylength
            else
                -- Draw a controller input.
                surface.SetMaterial(v[1])
                surface.DrawTexturedRect( info.x + strlength, info.y - ((size - info.size)*0.5), size, size )
                strlength = strlength + size
            end
        end
    end
    return strlength
end

-- Gets the size of the controller key line.
function GetControllerKeyLineSize( info, ... )
    local args = { ... } 
    local strlength = 0

    for i, v in ipairs( args ) do
        if isstring(v) then
            strlength = strlength + surface.GetTextSize(v)
        elseif istable(v) then
            local size = v[2]
            if isstring(v[1]) and !ARC9.CTRL_Exists[v[1]] then
                surface.SetFont("ARC9_KeybindPreview")
                local sx = surface.GetTextSize(v[1])
                local keylength = math.max(6 + sx, 16)
                surface.SetFont(info.font)
                strlength = strlength + keylength
            else
                strlength = strlength + size
            end
        end
    end
    return strlength
end

--[[

ps4
	button_logo
	button_options
	button_share
	l1
	l2
	l2_soft
	r1
	r2
	r2_soft
	trackpad_click
	trackpad_down
	trackpad_l_click
	trackpad_l_down
	trackpad_l_left
	trackpad_l_right
	trackpad_l_ring
	trackpad_l_swipe
	trackpad_l_touch
	trackpad_l_up
	trackpad_left
	trackpad
	trackpad_r_click
	trackpad_r_down
	trackpad_r_left
	trackpad_r_right
	trackpad_r_ring
	trackpad_r_swipe
	trackpad_r_touch
	trackpad_r_up
	trackpad_right
	trackpad_ring
	trackpad_swipe
	trackpad_up

ps5
	button_create
	button_options
	l1
	l2
	l2_soft
	r1
	r2
	r2_soft
	trackpad_click
	trackpad_down
	trackpad_l_click
	trackpad_l_down
	trackpad_l_left
	trackpad_l_right
	trackpad_l_ring
	trackpad_l_swipe
	trackpad_l_touch
	trackpad_l_up
	trackpad_left
	trackpad
	trackpad_r_click
	trackpad_r_down
	trackpad_r_left
	trackpad_r_right
	trackpad_r_ring
	trackpad_r_swipe
	trackpad_r_touch
	trackpad_r_up
	trackpad_right
	trackpad_ring
	trackpad_swipe
	trackpad_up

ps
	button_circle
	button_mute
	button_square
	button_triangle
	button_x
	color_button_circle
	color_button_square
	color_button_triangle
	color_button_x
	color_outlined_button_circle
	color_outlined_button_square
	color_outlined_button_triangle
	color_outlined_button_x
	dpad_down
	dpad_left
	dpad
	dpad_right
	dpad_up
	outlined_button_circle
	outlined_button_square
	outlined_button_triangle
	outlined_button_x

sc
	button_l_arrow
	button_r_arrow
	button_steam
	dpad_click
	dpad_down
	dpad_left
	dpad
	dpad_right
	dpad_swipe
	dpad_touch
	dpad_up
	lb
	lg
	lt_click
	lt
	lt_soft
	rb
	rg
	rt_click
	rt
	rt_soft
	touchpad_click
	touchpad_down
	touchpad_edge
	touchpad_left
	touchpad
	touchpad_right
	touchpad_swipe
	touchpad_touch
	touchpad_up

sd
	button_aux
	button_menu
	button_steam
	button_view
	l1
	l2_half
	l2
	l4
	l5
	ltrackpad_click
	ltrackpad_down
	ltrackpad_left
	ltrackpad
	ltrackpad_right
	ltrackpad_ring
	ltrackpad_swipe
	ltrackpad_up
	r1
	r2_half
	r2
	r4
	r5
	rtrackpad_click
	rtrackpad_down
	rtrackpad_left
	rtrackpad
	rtrackpad_right
	rtrackpad_ring
	rtrackpad_swipe
	rtrackpad_up

shared
	button_a
	button_b
	button_x
	button_y
	buttons_e
	buttons_n
	buttons_s
	buttons_w
	color_button_a
	color_button_b
	color_button_x
	color_button_y
	color_outlined_button_a
	color_outlined_button_b
	color_outlined_button_x
	color_outlined_button_y
	dpad_down
	dpad_left
	dpad
	dpad_right
	dpad_up
	gyro
	gyro_pitch
	gyro_roll
	gyro_yaw
	l3
	lstick_click
	lstick_down
	lstick_left
	lstick
	lstick_right
	lstick_touch
	lstick_up
	mouse_4
	mouse_5
	mouse_l_click
	mouse_mid_click
	mouse_r_click
	mouse_scroll_down
	mouse_scroll_up
	outlined_button_a
	outlined_button_b
	outlined_button_x
	outlined_button_y
	r3
	rstick_click
	rstick_down
	rstick_left
	rstick
	rstick_right
	rstick_touch
	rstick_up
	touch_doubletap
	touch
	touch_tap

switchpro
	button_capture
	button_home
	button_minus
	button_plus
	dpad_down
	dpad_left
	dpad
	dpad_right
	dpad_up
	l2
	l2_soft
	l
	lstick_click
	lstick_down
	lstick_left
	lstick
	lstick_right
	lstick_up
	r2
	r2_soft
	r
	rstick_click
	rstick_down
	rstick_left
	rstick
	rstick_right
	rstick_up

xbox360
	button_select
	button_start

xbox
	button_logo
	button_select
	button_share
	button_start
	lb
	lt
	lt_soft
	p1
	p2
	p3
	p4
	rb
	rt
	rt_soft

]]