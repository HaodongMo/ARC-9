local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudGMod"] = false,
}

hook.Add("HUDShouldDraw", "ARC9_HideHUD", function(name)
    if !IsValid(LocalPlayer()) then return end

    if ARC9.ShouldDrawHUD() then
        if hide[name] then return false end
    end
end)

local arc9_hud_scale = GetConVar("arc9_hud_scale")
ARC9.ScreenScale = function(size)
    return size * (ScrW() / 640) * arc9_hud_scale:GetFloat() * 0.9
end

local ARC9ScreenScale = ARC9.ScreenScale

ARC9.Colors = {
    bg      = Color(153, 153, 153, 97), --
    bgdark  = Color(37, 37, 37, 240), --
    bg_pro  = Color(53, 179, 53, 97), --
    bg_con  = Color(204, 61, 61, 97), --
    pro  = Color(54, 179, 54), --
    con  = Color(179, 54, 54), --
    fg      = Color(255, 255, 255), --
    hi      = Color(255, 123, 0), --
    hint    = Color(200, 200, 200, 120), --
    unowned = Color(180, 180, 180, 255),

    notoccupied      = Color(216, 216, 216, 70), --

    sel      = Color(255, 150, 100),
    occupied = Color(150, 255, 100),
    shadow   = Color(17, 17, 9),
    neg      = Color(255, 100, 100),
    pos      = Color(100, 255, 100),

    bg_3d = Color(255, 255, 240),
    fg_3d = Color(0, 0, 0),
    shadow_3d = Color(0, 0, 0),
    hi_3d = Color(255, 50, 50),
    pos_3d = Color(255, 255, 255),

    bg_menu = Color(26, 26, 23, 252),
    md = Color(107,107,92),
}

local cl_drawhud = GetConVar("cl_drawhud")
local arc9_hud_arc9 = GetConVar("arc9_hud_arc9")
local arc9_hud_always = GetConVar("arc9_hud_always")
local arc9_hud_force_disable = GetConVar("arc9_hud_force_disable")

function ARC9.ShouldDrawHUD()
    if !cl_drawhud:GetBool() then return end
    if arc9_hud_force_disable:GetBool() then return end

    local wpn = LocalPlayer():GetActiveWeapon()
    local a9 = wpn.ARC9
    local incust = a9 and wpn:GetCustomize()
    -- local hud = arc9_hud_arc9:GetBool()
    -- local hudalways = arc9_hud_always:GetBool()

    hide.CHudGMod = incust

    -- if (!hud and !incust) or (!a9 and !hudalways) then return end
    if (!arc9_hud_arc9:GetBool() and !incust) or (!a9 and !arc9_hud_always:GetBool()) then return end -- this line was hard

    return true
end

local alldays = {
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [17] = true,
    [18] = true,
    [19] = true,
    [20] = true,
    [21] = true,
    [22] = true,
    [23] = true,
    [24] = true,
    [25] = true,
    [26] = true,
    [27] = true,
    [28] = true,
    [29] = true,
    [30] = true,
    [31] = true,
    [32] = true, -- you can't fight nature, jack
}
local events = {
    ["New Year's"] = {
        months = { [1] = true },
        days = { [1] = true },
    },
    ["Leap Day"] = {
        months = { [2] = true },
        days = { [29] = true },
    },
    -- ["Opposite Day"] = {
    --     months = { 1 },
    --     days = { 25 },
    -- },
    -- ["Earth Day"] = {
    --     months = { 4 },
    --     days = { 22 },
    -- },
    ["Earth Day"] = {
        months = { [4] = true },
        days = { [22] = true },
    },
    ["Easter"] = {
        months = { [4] = true },
        days = alldays,
    },
    ["Halloween"] = {
        months = { [10] = true },
        days = { [31] = true },
    },
    ["Thanksgiving"] = {
        months = { [11] = true }, 
        days = { [23] = true },
    },
    ["Christmas"] = {
        months = { [12] = true },
        days = { [25] = true },
    },
    ["Birthday - Arctic"] = {
        months = { [7] = true },
        days = { [27] = true },
    },
    ["Summer Break"] = {
        months = { [6] = true, [7] = true, [8] = true,  },
        days = alldays,
    },
    ["Troll Day"] = {
        months = { [4] = true },
        days = { [1] = true }
    },
}

local holidayscolors = {
    ["Christmas"] = {
        hi     = Color(184, 210, 160),
        bg     = Color(153, 113, 110, 97),
        bgdark = Color(33, 11, 9, 240),
    },
    ["Halloween"] = {
        hi     = Color(255, 187, 132),
        bg     = Color(120, 110, 153, 97),
        bgdark = Color(14, 6, 37, 240),
    },
    ["Thanksgiving"] = {
        hi     = Color(240, 195, 172),
        bg     = Color(153, 137, 110, 97),
        bgdark = Color(38, 34, 27, 240),
    },
    ["New Year's"] = {
        hi     = Color(255, 255, 200),
        bg     = Color(114, 114, 153, 97),
        bgdark = Color(30, 30, 40, 240),
    },
    ["Birthday - Arctic"] = {
        hi     = Color(210, 235, 255),
        bg     = Color(153, 153, 114, 97),
        bgdark = Color(40, 40, 30, 240),
    },
    ["None"] = {
        hi     = ARC9.Colors.hi,
        bg     = ARC9.Colors.bg,
        bgdark = ARC9.Colors.bgdark,
    },
}

local arc9_holiday_month = GetConVar("arc9_holiday_month")
local arc9_holiday_day = GetConVar("arc9_holiday_day")

function ARC9.GetTime()
    if arc9_holiday_month:GetInt() > 0 and arc9_holiday_day:GetInt() > 0 then
        return os.time( { month = arc9_holiday_month:GetInt(), day = arc9_holiday_day:GetInt(), year = 2000 } )
    else
        return os.time( )--{ month = 12, day = 1, year = 2000 } )
    end
end

function ARC9.GetHolidayColor()
    local d = os.date( "*t", ARC9.GetTime() )
    for i,j in pairs(holidayscolors) do
        if i == "None" then continue end
        if events[i].days[d.day] and events[i].months[d.month] then
            return i
        end
    end
    return "None"
end

ARC9.ActiveHolidays = {}

local d = os.date( "*t", ARC9.GetTime() )
for i,j in pairs(events) do
	if j.days[d.day] and j.months[d.month] then
		ARC9.ActiveHolidays[i] = true
	end
end

local arc9_hud_color_r = GetConVar("arc9_hud_color_r")
local arc9_hud_color_g = GetConVar("arc9_hud_color_g")
local arc9_hud_color_b = GetConVar("arc9_hud_color_b")
local arc9_hud_darkmode = GetConVar("arc9_hud_darkmode")
local arc9_hud_holiday = GetConVar("arc9_hud_holiday")

function ARC9.GetHUDColor(part, alpha)
    alpha = alpha or 255
    local holidayenabled = arc9_hud_holiday:GetBool()
    local col = ARC9.Colors[part] or ARC9.Colors.hi
    local holidaycol = holidayscolors[ARC9.GetHolidayColor()]
    
    
    if part == "hi" then
        col = Color(
            arc9_hud_color_r:GetInt(),
            arc9_hud_color_g:GetInt(),
            arc9_hud_color_b:GetInt()
        )
        if holidayenabled then
            col = holidaycol.hi
        end
    end

    if part == "bg" then
        if holidayenabled then
            col = holidaycol.bg
        end
        if arc9_hud_darkmode:GetBool() then
            col = ARC9.Colors["bgdark"]
            if holidayenabled then
                col = holidaycol.bgdark
            end
        end
    end
    
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
local hud_sillyhints = Material("arc9/sillyhintsblur.png", "mips")
local hud_logo_lowvis = Material("arc9/logo/logo_lowvis.png", "mips smooth")

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

local arc9_lean = GetConVar("arc9_lean")

local function GetWeaponCapabilities(wpn)
    cap = {
        UBGL = tobool(!wpn:GetInSights() and wpn:GetValue("UBGL")),
        Bash = tobool(!wpn:GetInSights() and wpn:GetValue("Bash")),
        SwitchSights = tobool(wpn:GetInSights() and #wpn.MultiSightTable > 1),
        Inspect = !wpn:GetInSights() and tobool(wpn:HasAnimation("enter_inspect") or wpn:HasAnimation("inspect")),
        -- Blindfire = tobool(!wpn:GetInSights() and wpn:GetValue("CanBlindFire")),
        -- BlindfireLeft = tobool(!wpn:GetInSights() and wpn:GetValue("CanBlindFire") and wpn:GetValue("BlindFireLeft")),
        -- BlindfireRight = tobool(!wpn:GetInSights() and wpn:GetValue("CanBlindFire") and wpn:GetValue("BlindFireRight")),
        Firemode = tobool(!wpn:GetUBGL() and #wpn:GetValue("Firemodes") > 1),
        HoldBreath = tobool(wpn:GetInSights() and wpn:GetValue("HoldBreathTime") > 0),
        VariableZoom = tobool(wpn:GetInSights() and (wpn:GetSight().atttbl or {}).RTScopeAdjustable),
        ManualCycle = tobool(wpn:GetNeedsCycle() and wpn:ShouldManualCycle()),
        Lean = tobool(wpn:GetProcessedValue("CanLean", true) and arc9_lean:GetBool()),
    }

    return cap
end

local function GetHintsTable(capabilities)
    local weapon = LocalPlayer():GetActiveWeapon()
    local hints = {}

    if capabilities.UBGL then
        if ARC9.GetKeyIsBound("+arc9_ubgl") then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+arc9_ubgl"),
                action = ARC9:GetPhrase("hud.hint.ubgl") .. " " .. tostring(weapon:GetProcessedValue("UBGLFiremodeName", true))
            })
        else
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+use"),
                glyph2 = ARC9.GetBindKey("+attack2"),
                action = ARC9:GetPhrase("hud.hint.ubgl") .. " " .. tostring(weapon:GetProcessedValue("UBGLFiremodeName", true))
            })
        end
    end

    if capabilities.SwitchSights then
        if ARC9.GetKeyIsBound("+arc9_switchsights") then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+arc9_switchsights"),
                action = ARC9:GetPhrase("hud.hint.switchsights")
            })
        else
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+use"),
                glyph2 = ARC9.GetBindKey("invnext"),
                action = ARC9:GetPhrase("hud.hint.switchsights")
            }) -- TODO: hardcoded to mouse wheel, see sh_move.lua ARC9.StartCommand
        end
    end

    if capabilities.VariableZoom then
        table.insert(hints, {
            glyph = !input.LookupBinding("invnext") and !(input.LookupKeyBinding(113) != nil and input.LookupKeyBinding(113):len() > 0) and "shared_mouse_scroll_down" or ARC9.GetBindKey("invnext"),
            glyph2 = !input.LookupBinding("invprev") and !(input.LookupKeyBinding(112) != nil and input.LookupKeyBinding(112):len() > 0) and "shared_mouse_scroll_up" or ARC9.GetBindKey("invprev"),
            action = ARC9:GetPhrase("hud.hint.zoom")
        }) -- use mouse wheel if invnext or invprev not bound, possible convar to swap maybe? currently for semi parity with switchsights
    end

    if capabilities.HoldBreath then
        table.insert(hints, {
            glyph = ARC9.GetBindKey("+speed"),
            action = ARC9:GetPhrase("hud.hint.breath")
        })
    end

    if capabilities.Bash and !weapon.PrimaryBash then
		if weapon.SecondaryBash then -- If the weapon performs bashing as the primary attack function, only display the "+attack" function.
			table.insert(hints, {
				glyph = ARC9.GetBindKey("+attack2"),
				action = ARC9:GetPhrase("hud.hint.bash")
			})
		else
			if ARC9.GetKeyIsBound("+arc9_melee") then
				table.insert(hints, {
					glyph = ARC9.GetBindKey("+arc9_melee"),
					action = ARC9:GetPhrase("hud.hint.bash")
				})
			else
				table.insert(hints, {
					glyph = ARC9.GetBindKey("+use"),
					glyph2 = ARC9.GetBindKey("+attack"),
					action = ARC9:GetPhrase("hud.hint.bash")
				})
			end
		end
    end

    if capabilities.Inspect then
        if ARC9.GetKeyIsBound("+arc9_inspect") then
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+arc9_inspect"),
                action = ARC9:GetPhrase("hud.hint.inspect")
            })
        else
            table.insert(hints, {
                glyph = ARC9.GetBindKey("+use"),
                glyph2 = ARC9.GetBindKey("+reload"),
                action = ARC9:GetPhrase("hud.hint.inspect")
            })
        end
    end

    if capabilities.Firemode then
        table.insert(hints, {
            glyph = ARC9.GetBindKey("+zoom"),
            action = ARC9:GetPhrase("hud.hint.firemode")
        })
    end

    if capabilities.ManualCycle then
        table.insert(hints, {
            glyph = ARC9.GetBindKey("+reload"),
            action = ARC9:GetPhrase("hud.hint.cycle")
        })
    end

    if weapon:CanToggleAllStatsOnF() then
        table.insert(hints, {
            glyph = ARC9.GetBindKey("impulse 100"),
            action = ARC9:GetPhrase("hud.hint.toggleatts")
        })
    end

    table.insert(hints, {
        glyph = ARC9.GetBindKey("+menu_context"),
        action = not weapon:GetProcessedValue("CantPeek",true) and weapon:GetInSights() and ARC9:GetPhrase("hud.hint.peek") or ARC9:GetPhrase("hud.hint.customize") })

    table.insert(hints, {
        glyph = ARC9.GetBindKey("+use"),
        glyph2 = ARC9.GetBindKey("+zoom"),
        action = ARC9:GetPhrase("hud.hint.safe")
    })

    if capabilities.Lean and input.LookupBinding("+alt1") and input.LookupBinding("+alt2") then
        table.insert(hints, {
            glyph = ARC9.GetBindKey("+alt1"),
            glyph2 = ARC9.GetBindKey("+alt2"),
            action = ARC9:GetPhrase("hud.hint.lean")
        })
    end

    for i, v in ipairs(hints) do
        if ARC9.CTRL_Lookup[v.glyph] then v.glyph = ARC9.CTRL_Lookup[v.glyph] end
        if ARC9.CTRL_ConvertTo[v.glyph] then v.glyph = ARC9.CTRL_ConvertTo[v.glyph] end
        if ARC9.CTRL_Exists[v.glyph] then v.glyph = Material( "arc9/" .. ARC9.GlyphFamilyHUD() .. v.glyph .. ".png", "smooth" ) end
        if v.glyph2 then
            if ARC9.CTRL_Lookup[v.glyph2] then v.glyph2 = ARC9.CTRL_Lookup[v.glyph2] end
            if ARC9.CTRL_ConvertTo[v.glyph2] then v.glyph2 = ARC9.CTRL_ConvertTo[v.glyph2] end
            if ARC9.CTRL_Exists[v.glyph2] then v.glyph2 = Material( "arc9/" .. ARC9.GlyphFamilyHUD() .. v.glyph2 .. ".png", "smooth" ) end
        end
    end

    return hints
end

local arc9_hud_nohints = GetConVar("arc9_hud_nohints")
local arc9_hud_compact = GetConVar("arc9_hud_compact")
local deadzonex = GetConVar("arc9_hud_deadzonex")

local function DrawSimpleHints()
    if arc9_hud_nohints:GetBool() then return end

    local weapon = LocalPlayer():GetActiveWeapon()
    if !weapon.ARC9 then return end

    if !cl_drawhud:GetBool() then return end
    if weapon:GetCustomize() then return end

    local ct = CurTime()

    local capabilities = GetWeaponCapabilities(weapon)

    local CTRL = false

    local hints = GetHintsTable(capabilities)

    if lasthintcount != #hints and hidefadetime + 1.5 < ct then
        hidefadetime = ct
    end

    if weapon:GetInSights() and hidefadetime + 1.5 < ct then
        hidefadetime = ct
    end

    if first then
        hidefadetime = ct + 7
        first = false
    end

    lasthintcount = #hints

    local hx = 0
    local hy = 0
    local SIZE = ARC9ScreenScale(8)

    if hidefadetime + 1.5 > ct then
        hint_alpha = math.Approach(hint_alpha, 1, FrameTime() / 0.1)
    else
        hint_alpha = math.Approach(hint_alpha, 0, FrameTime() / 1)
    end
    if convar_keephints:GetBool() then hint_alpha = 1 end

    local hints_w = ARC9ScreenScale(100)
    local hints_h = ARC9ScreenScale(11) * table.Count(hints)

    hx = ARC9ScreenScale(10) + deadzonex:GetInt()
    hy = (ScrH() - hints_h) / 2

    surface.SetDrawColor(ARC9.GetHUDColor("shadow", 160 * hint_alpha))
    surface.SetMaterial(hud_sillyhints)
    surface.DrawTexturedRect(-ARC9ScreenScale(5) + deadzonex:GetInt(), hy-ARC9ScreenScale(12.5), hints_w, hints_h+ARC9ScreenScale(25))

    local off_x = ARC9ScreenScale(1)
    local off_y = ARC9ScreenScale(1)

    local txt_off_y = -ARC9ScreenScale(0.8)

    for _, hint in ipairs(hints) do
        local strreturn = 0
        surface.SetFont("ARC9_10")
        surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
        surface.SetTextColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
        surface.SetTextPos(hx + off_x, hy + off_y)
        strreturn = CreateControllerKeyLine( {x = hx + off_x, y = hy + off_y, size = ARC9ScreenScale(9), font_keyb = "ARC9_10", font = "ARC9_10" }, { hint.glyph, SIZE }, (hint.glyph2 and "  " or ""), (hint.glyph2 and { hint.glyph2, SIZE } or "") )
        CreateControllerKeyLine( {x = hx + off_x + math.max(strreturn, ARC9ScreenScale(25)), y = hy + txt_off_y + off_y, size = ARC9ScreenScale(10), font_keyb = "ARC9_10", font = "ARC9_10" }, " " .. hint.action )

        surface.SetFont("ARC9_10")
        surface.SetDrawColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
        surface.SetTextColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
        surface.SetTextPos(hx, hy)
        strreturn = CreateControllerKeyLine( {x = hx, y = hy, size = ARC9ScreenScale(9), font_keyb = "ARC9_10", font = "ARC9_10" }, { hint.glyph, SIZE }, (hint.glyph2 and "  " or ""), (hint.glyph2 and { hint.glyph2, SIZE } or "") )
        CreateControllerKeyLine( {x = hx + math.max(strreturn, ARC9ScreenScale(25)), y = hy + txt_off_y, size = ARC9ScreenScale(10), font_keyb = "ARC9_10", font = "ARC9_10" }, " " .. hint.action )

        hy = hy + ARC9ScreenScale(12)
    end
end

local deadzonex = GetConVar("arc9_hud_deadzonex")

function ARC9.DrawHUD()
    EyeAngles() -- This, for some ungodly reason, allows sway to work when the HUD is off.
    EyePos()

    if !ARC9.ShouldDrawHUD() then
        DrawSimpleHints()
        return
    end

    local localplayer = LocalPlayer()
    local weapon = localplayer:GetActiveWeapon()

    if !IsValid(weapon) then return end

    local ct = CurTime()

    if lastweapon != weapon then
        rackrisetime = ct
        lastrow = 0
        hidefadetime = ct
    end

    -- local weapon_printname = weapon:GetPrintName()
    local weapon_clipsize = weapon:GetMaxClip1()
    local weapon_clip = weapon:Clip1()
    local weapon_reserve = localplayer:GetAmmoCount(weapon:GetPrimaryAmmoType())

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

        firemode_text = weapon:GetFiremodeName()

        if #weapon:GetValue("Firemodes") > 1 then
            multiple_modes = true
        end

        if weapon:GetProcessedValue("NoFiremodeWhenEmpty", true) and weapon:Clip1() <= 0 then
            multiple_modes = false
        end

        if weapon:GetUBGL() then
            arc9_mode = {
                Mode = weapon:GetCurrentFiremode(),
                PrintName = weapon:GetProcessedValue("UBGLFiremodeName", true)
            }
            firemode_text = arc9_mode.PrintName
            weapon_clipsize = weapon:GetMaxClip2()
            weapon_clip = weapon:Clip2()
            clip_to_show = weapon_clip
            weapon_reserve = localplayer:GetAmmoCount(weapon:GetSecondaryAmmoType())
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

        if weapon:GetSafe() then
            firemode_pic = firemode_pics[0]
        end

        if weapon:GetInfiniteAmmo() then
            inf_reserve = true
            weapon_reserve = 2147483640
        end

        if weapon:GetProcessedValue("BottomlessClip", true) then
            inf_clip = true
            weapon_reserve = weapon_reserve + weapon_clip
            clip_to_show = weapon_reserve
            weapon_clip = weapon_reserve
            weapon_clipsize = 1
            chambered = 0

            if inf_reserve then
                clip_to_show = 2147483640 - weapon:GetNthShot() % 2147483640
            end
        end

        if weapon:GetJammed() then
            jammed = true
        end

        if weapon:GetProcessedValue("Overheat", true) then
            showheat = true
            heat = weapon:GetHeatAmount()
            heatcap = weapon:GetProcessedValue("HeatCapacity", true)
            heatlocked = weapon:GetHeatLockout()
        end
    elseif weapon.ArcCW then
        local arccw_mode = weapon:GetCurrentFiremode()

        firemode_text = weapon:GetFiremodeName()
        -- there was a reason I kept it to 4 letters you assholes

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
            firemode_text = ARC9:GetPhrase("hud.firemode.single")
        end

        if weapon.ThreeRoundBurst then
            firemode_pic = firemode_pics[3]
            firemode_text = "3-" .. ARC9:GetPhrase("hud.firemode.burst")
        end

        if weapon.TwoRoundBurst then
            firemode_pic = firemode_pics[2]
            firemode_text = "2-" .. ARC9:GetPhrase("hud.firemode.burst")
        end

        if weapon.GetSafe then
            if weapon:GetSafe() then
                firemode_pic = firemode_pics[0]
                firemode_text = ARC9:GetPhrase("hud.firemode.safe")
            end
        end

        if isfunction(weapon.Safe) then
            if weapon:Safe() then
                firemode_pic = firemode_pics[0]
                firemode_text = ARC9:GetPhrase("hud.firemode.safe")
            end
        end

        if isfunction(weapon.Safety) then
            if weapon:Safety() then
                firemode_pic = firemode_pics[0]
                firemode_text = ARC9:GetPhrase("hud.firemode.safe")
            end
        end
    else
        if !automatics[weapon:GetClass()] then
            firemode_pic = firemode_pics[1]
            firemode_text = ARC9:GetPhrase("hud.firemode.single")
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

    if (flashheatbar and math.floor(ct * flash_period) % 2 == 0) then
        heat_col = ARC9.GetHUDColor("hi_3d", 200)
    end

    local am_col = ARC9.GetHUDColor("fg_3d", 255)

    if (flashammowidgets and math.floor(ct * flash_period) % 2 == 0) or (weapon_clip == 0 and !melee) then
        am_col = ARC9.GetHUDColor("hi_3d", 255)
    end

    local s_right = 2
    local s_down = 1

    -- cam.Start3D(Vector pos=EyePos(), Angle angles=EyeAngles(), number fov=nil, number x=0, number y=0, number w=ScrW(), number h=ScrH(), number zNear=nil, number zFar=nil)
    local anchorwidth = math.min(ScrW() / 2, ScrH() / 2)

    cam.Start3D(nil, nil, 55, deadzonex:GetInt(), ScrH() - anchorwidth, anchorwidth, anchorwidth)
    -- cam.Start3D(nil, nil, 105)

    local ang = EyeAngles()

    local up, right, forward = ang:Up(), ang:Right(), ang:Forward()

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

    local compatc = arc9_hud_compact:GetBool()

    cam.Start3D2D(pos, ang, 0.0125)
        -- surface.SetDrawColor(ARC9.GetHUDColor("shadow_3d", 20))
        -- surface.DrawRect( 8, 4, 254, 110 )

        if compatc then
            surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 20))
            surface.DrawRect( 0, 0, 254, 80 )

            surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 100))
            surface.SetMaterial(hud_bg)
            surface.DrawTexturedRect(0, 0, 254, 80)

            surface.DrawLine(0, 85, 254, 85)

            surface.SetDrawColor(Color(0, 0, 0, 50))
            surface.SetMaterial(hud_logo_lowvis)
            surface.DrawTexturedRect((254 - 80) / 2, 0, 80, 80)
        else
            surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 20))
            surface.DrawRect( 0, 0, 254, 110 )

            surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 100))
            surface.SetMaterial(hud_bg)
            surface.DrawTexturedRect(0, 0, 254, 110)

            surface.DrawLine(0, 115, 254, 115)

            surface.SetDrawColor(Color(0, 0, 0, 50))
            surface.SetMaterial(hud_logo_lowvis)
            surface.DrawTexturedRect((254 - 110) / 2, 0, 110, 110)
        end

        -- surface.SetDrawColor(ARC9.GetHUDColor("bg_3d", 20))
        -- surface.DrawRect( 0, 0, 140, 70 )

        local deco_x = 6
        local deco_y = 2
        local deco = ARC9:GetPhrase("hud.version") .. ARC9.Version

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
        local health = math.Clamp(localplayer:Health() / localplayer:GetMaxHealth(), 0, 99.99)
        local overheal = localplayer:Health() > localplayer:GetMaxHealth() or localplayer:Armor() > 100

        local flashhealthwidgets = false

        if localplayer:Health() <= 10 then
            flashhealthwidgets = true
        end

        local hb_col = ARC9.GetHUDColor("fg_3d", 225)
        local hw_col = ARC9.GetHUDColor("fg_3d", 255)

        if (flashhealthwidgets and math.floor(ct * flash_period) % 2 == 0) then
            hw_col = ARC9.GetHUDColor("hi_3d", 255)
            hb_col = ARC9.GetHUDColor("hi_3d", 170)
        end

        local hb_left = 30
        local hb_tall = 24
        local hb_wide = 209

        if compatc and showheat then
            hb_wide = 140
        end

        if !overheal then
            if localplayer:Armor() > 0 then
                hb_tall = 18

                local armor = math.min(localplayer:Armor() / 100, 1)

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
            healthtext = "♥:" .. tostring(math.ceil(health * 100)) .. "%"
        end

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_24_LCD")
        surface.SetTextPos(health_x + s_right, health_y + s_down)
        surface.DrawText(healthtext)

        surface.SetTextColor(hw_col)
        surface.SetFont("ARC9_24_LCD")
        surface.SetTextPos(health_x, health_y)
        surface.DrawText(healthtext)

        if overheal then
            local armor_x = 250
            local armor_y = 9
            local armor = math.Round((localplayer:Armor() / 100) * 100)
            armor = "⌂:" .. tostring(math.ceil(armor)) .. "%"

            surface.SetFont("ARC9_24_LCD")
            armor_x = armor_x - surface.GetTextSize(armor)

            surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
            surface.SetFont("ARC9_24_LCD")
            surface.SetTextPos(armor_x + s_right, armor_y + s_down)
            surface.DrawText(armor)

            surface.SetTextColor(ARC9.GetHUDColor("fg_3d", 255))
            surface.SetFont("ARC9_24_LCD")
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
            local therm_deco = ARC9:GetPhrase("hud.therm_deco")

            if compatc then
                therm_x = 174
                therm_y = 6
                therm_w = 70
                therm_h = 35

                therm_deco_x = 190
                therm_deco_y = 5
            end

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
            ammo_text = ARC9:GetPhrase("hud.jammed")
        end

        surface.SetTextColor(ARC9.GetHUDColor("shadow_3d", 100))
        surface.SetFont("ARC9_24_LCD")
        surface.SetTextPos(ammo_x + s_right, ammo_y + s_down)
        surface.DrawText(ammo_text)

        surface.SetTextColor(am_col)
        surface.SetFont("ARC9_24_LCD")
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
            if ARC9.CTRL_Exists[fmh_text] then fmh_text = Material( "arc9/" .. ARC9.GlyphFamilyHUD() .. fmh_text .. ".png", "smooth" ) else fmh_text = "["..fmh_text.."]" end
            fmh_text = isstring(fmh_text) and fmh_text or { fmh_text, 15 }

            surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
            surface.SetTextColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
            surface.SetFont("ARC9_12_LCD")
            local fmh_w = GetControllerKeyLineSize( { font = "ARC9_12_LCD" }, fmh_text )
            CreateControllerKeyLine( { x = fmh_x + s_right - fmh_w, y = fmh_y + s_down, size = 16, font = "ARC9_12_LCD" }, fmh_text )

            surface.SetDrawColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
            surface.SetTextColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
            surface.SetFont("ARC9_12_LCD")
            CreateControllerKeyLine( { x = fmh_x - fmh_w, y = fmh_y, size = 16, font = "ARC9_12_LCD" }, fmh_text )
        end

        if !compatc then
            -- bullet fields

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
                    rackrisetime = ct
                end

                lastrow = row
            else
                row2_bullets = clip_to_show
            end

            if rackrisetime + 0.2 > ct then
                local rackrisedelta = ((rackrisetime + 0.2) - ct) / 0.2
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
        end

    cam.End3D2D()

    if weapon.ARC9 and !arc9_hud_nohints:GetBool() then
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

        local hints = GetHintsTable(capabilities)

        if lasthintcount != #hints and hidefadetime + 1.5 < ct then
            hidefadetime = ct
        end

        if weapon:GetInSights() and hidefadetime + 1.5 < ct then
            hidefadetime = ct
        end

        if first then
            hidefadetime = ct + 10
            first = false
        end

		-- hints = table.Reverse(hints)

        lasthintcount = #hints

        local hx = 0
        local hy = 0
        local SIZE = 16

        if hidefadetime + 1.5 > ct then
            hint_alpha = math.Approach(hint_alpha, 1, FrameTime() / 0.1)
        else
            hint_alpha = math.Approach(hint_alpha, 0, FrameTime() / 1)
        end
        if convar_keephints:GetBool() then hint_alpha = 1 end

        cam.Start3D2D(pos - (ang:Right() * ((20 * #hints * 0.0125) + 0.25)), ang, 0.0125)
            surface.SetDrawColor(ARC9.GetHUDColor("shadow", 150 * hint_alpha))
            surface.SetMaterial(hud_bigblur)
            surface.DrawTexturedRect(-32, 0, 300, 20 * #hints)

            for _, hint in ipairs(hints) do
                local strreturn = 0
                surface.SetFont("ARC9_16_Unscaled")
                surface.SetDrawColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
                surface.SetTextColor(ARC9.GetHUDColor("shadow", 100 * hint_alpha))
                surface.SetTextPos(hx + 4, hy + 2)
                strreturn = CreateControllerKeyLine( {x = hx + 2, y = hy + 1, size = 16, font = "ARC9_16_Unscaled" }, { hint.glyph, SIZE }, (hint.glyph2 and " " or ""), (hint.glyph2 and { hint.glyph2, SIZE } or "") )
                CreateControllerKeyLine( {x = hx + 4 + math.max(strreturn, 48), y = hy + 2, size = 16, font = "ARC9_16_Unscaled" }, " " .. hint.action )


                surface.SetFont("ARC9_16_Unscaled")
                surface.SetDrawColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
                surface.SetTextColor(ARC9.GetHUDColor("fg", 200 * hint_alpha))
                surface.SetTextPos(hx, hy)
                strreturn = CreateControllerKeyLine( {x = hx, y = hy, size = 16, font = "ARC9_16_Unscaled" }, { hint.glyph, SIZE }, (hint.glyph2 and " " or ""), (hint.glyph2 and { hint.glyph2, SIZE } or "") )
                CreateControllerKeyLine( {x = hx + math.max(strreturn, 48), y = hy, size = 16, font = "ARC9_16_Unscaled" }, " " .. hint.action )

                hy = hy + 22
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

ARC9.CTRL_Set_Xbox = {}
ARC9.CTRL_Set_UserCustom = {}

ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_Xbox -- {}

function ARC9.GlyphFamilyHUD()
	local con = GetConVar("arc9_glyph_family_hud"):GetString()
	local family = "glyphs_light/" -- Fallback
	
	if con == "light" then
		family = "glyphs_light/"
	elseif con == "dark" then
		family = "glyphs_dark/"
	elseif con == "knockout" then
		family = "glyphs_knockout/"
	end

	return family
end

function ARC9.GlyphFamilyCust()
	local con = GetConVar("arc9_glyph_family_cust"):GetString()
	local family = "glyphs_light/" -- Fallback
	
	if con == "light" then
		family = "glyphs_light/"
	elseif con == "dark" then
		family = "glyphs_dark/"
	elseif con == "knockout" then
		family = "glyphs_knockout/"
	end

	return family
end

function ARC9.GlyphSet()
	local buttonfamily = "xboxseries_"
	local glyphf = GetConVar("arc9_glyph_type"):GetString()
	
	if glyphf == "luna" then buttonfamily = "luna_"
		elseif glyphf == "ouya" then buttonfamily = "ouya_"
		elseif glyphf == "ps3" then buttonfamily = "ps3_"
		elseif glyphf == "ps4" then buttonfamily = "ps4_"
		elseif glyphf == "ps5" then buttonfamily = "ps5_"
		elseif glyphf == "psvita" then buttonfamily = "psvita_"
		elseif glyphf == "stadia" then buttonfamily = "stadia_"
		elseif glyphf == "steamc" then buttonfamily = "steamc_"
		elseif glyphf == "steamdeck" then buttonfamily = "steamdeck_"
		elseif glyphf == "switch" then buttonfamily = "switch_"
		elseif glyphf == "wiiu" then buttonfamily = "wiiu_"
		elseif glyphf == "xbox360" then buttonfamily = "xbox360_"
		elseif glyphf == "xboxone" then buttonfamily = "xboxone_"
		elseif glyphf == "xboxseries" then buttonfamily = "xboxseries_"
	end

	return buttonfamily
end

ARC9.CTRL_Lookup = {
    MOUSE1 = "shared_mouse_l_click_lg",
    MOUSE2 = "shared_mouse_r_click_lg",
    MOUSE3 = "shared_mouse_mid_click_lg",
    MOUSE4 = "shared_mouse_5_lg",
    MOUSE5 = "shared_mouse_4_lg",

    MWHEELUP = "shared_mouse_scroll_up_lg",
    MWHEELDOWN = "shared_mouse_scroll_down_lg",

    KP_INS = "KP 0",
    KP_END = "KP 1",
    KP_DOWNARROW  = "KP 2",
    KP_PGDN       = "KP 3",
    KP_LEFTARROW  = "KP 4",
    KP_5   = "KP 5",
    KP_RIGHTARROW = "KP 6",
    KP_HOME       = "KP 7",
    KP_UPARROW    = "KP 8",
    KP_PGUP       = "KP 9",
    KP_SLASH      = "KP /",
    KP_MULTIPLY   = "KP *",
    KP_MINUS      = "KP -",
    KP_PLUS       = "KP +",
    KP_ENTER      = "KP ENTER",
    KP_DEL = "KP .",

}

ARC9.CTRL_Exists = {

--[[ New Glyphs
	-- Mouse Buttons
	mouse_left =  true,
	mouse_mid =  true,
	mouse_right =  true,
	mouse4 =  true,
	mouse5 =  true,
	mouse_scroll_up =  true,
	mouse_scroll_down =  true,
	
-- Amazon Luna
	luna_face_down = true,
	luna_face_left = true,
	luna_face_right = true,
	luna_face_up = true,

	luna_stick_left = true,
	luna_stick_right = true,

	luna_stickclick_left = true,
	luna_stickclick_right = true,

	luna_trigger_left = true,
	luna_trigger_right = true,

	luna_bumper_left = true,
	luna_bumper_right = true,

	luna_back = true,
	luna_start = true,

	luna_dpad= true,
	luna_dpad_down = true,
	luna_dpad_left = true,
	luna_dpad_right = true,
	luna_dpad_up = true,

	luna_unique_mic = true,

-- Ouya
	ouya_face_down = true,
	ouya_face_left = true,
	ouya_face_right = true,
	ouya_face_up = true,
	
	ouya_stick_left = true,
	ouya_stick_right = true,
	
	ouya_trigger_left = true,
	ouya_trigger_right = true,
	
	ouya_bumper_left = true,
	ouya_bumper_right = true,

	ouya_dpad= true,
	ouya_dpad_down = true,
	ouya_dpad_left = true,
	ouya_dpad_right = true,
	ouya_dpad_up = true,
	
	ouya_unique_menu = true,
	ouya_unique_touch = true,
	
-- PlayStation 3 / DualShock 3
	ps3_face_down = true,
	ps3_face_left = true,
	ps3_face_right = true,
	ps3_face_up = true,
	
	ps3_stick_left = true,
	ps3_stick_right = true,
	
	ps3_stickclick_left = true,
	ps3_stickclick_right = true,
	
	ps3_trigger_left = true,
	ps3_trigger_right = true,
	
	ps3_bumper_left = true,
	ps3_bumper_right = true,
	
	ps3_back = true,
	ps3_start = true,
	
	ps3_dpad= true,
	ps3_dpad_down = true,
	ps3_dpad_left = true,
	ps3_dpad_right = true,
	ps3_dpad_up = true,
	
-- PlayStation 4 / DualShock 4
	ps4_face_down = true,
	ps4_face_left = true,
	ps4_face_right = true,
	ps4_face_up = true,
	
	ps4_stick_left = true,
	ps4_stick_right = true,
	
	ps4_stickclick_left = true,
	ps4_stickclick_right = true,
	
	ps4_trigger_left = true,
	ps4_trigger_right = true,
	
	ps4_bumper_left = true,
	ps4_bumper_right = true,
	
	ps4_back = true,
	ps4_start = true,
	
	ps4_dpad= true,
	ps4_dpad_down = true,
	ps4_dpad_left = true,
	ps4_dpad_right = true,
	ps4_dpad_up = true,
	
	ps4_unique_share = true,
	
-- PlayStation 5 / DualSense
	ps5_face_down = true,
	ps5_face_left = true,
	ps5_face_right = true,
	ps5_face_up = true,
	
	ps5_stick_left = true,
	ps5_stick_right = true,
	
	ps5_stickclick_left = true,
	ps5_stickclick_right = true,
	
	ps5_trigger_left = true,
	ps5_trigger_right = true,
	
	ps5_bumper_left = true,
	ps5_bumper_right = true,
	
	ps5_back = true,
	ps5_start = true,
	
	ps5_dpad= true,
	ps5_dpad_down = true,
	ps5_dpad_left = true,
	ps5_dpad_right = true,
	ps5_dpad_up = true,
	
	ps5_start_alt = true,
	ps5_unique_mic = true,
	ps5_unique_share = true,
	ps5_unique_share_alt = true,

-- PlayStation Vita
	psvita_face_down = true,
	psvita_face_left = true,
	psvita_face_right = true,
	psvita_face_up = true,
	
	psvita_stick_left = true,
	psvita_stick_right = true,
	
	psvita_bumper_left = true,
	psvita_bumper_right = true,
	
	psvita_back = true,
	psvita_start = true,
	
	psvita_dpad= true,
	psvita_dpad_down = true,
	psvita_dpad_left = true,
	psvita_dpad_right = true,
	psvita_dpad_up = true,
	
	psvita_unique_minus = true,
	psvita_unique_plus = true,
	psvita_unique_power = true,
	psvita_unique_touchpad = true,

-- Google Stadia
	stadia_face_down = true,
	stadia_face_left = true,
	stadia_face_right = true,
	stadia_face_up = true,
	
	stadia_stick_left = true,
	stadia_stick_right = true,
	
	stadia_trigger_left = true,
	stadia_trigger_right = true,
	
	stadia_bumper_left = true,
	stadia_bumper_right = true,
	
	stadia_back = true,
	stadia_start = true,
	
	stadia_dpad= true,
	stadia_dpad_down = true,
	stadia_dpad_left = true,
	stadia_dpad_right = true,
	stadia_dpad_up = true,

	stadia_unique_assistant = true,
	stadia_unique_dots = true,

-- Steam Controller
	steamc_face_down = true,
	steamc_face_left = true,
	steamc_face_right = true,
	steamc_face_up = true,

	steamc_track = true,
	steamc_track_center = true,
	steamc_track_down = true,
	steamc_track_left = true,
	steamc_track_right = true,
	steamc_track_up = true,

	steamc_track2 = true,
	steamc_track2_center = true,
	steamc_track2_down = true,
	steamc_track2_left = true,
	steamc_track2_right = true,
	steamc_track2_up = true,

	steamc_trigger_left = true,
	steamc_trigger_right = true,
	
	steamc_bumper_left = true,
	steamc_bumper_right = true,
	
	steamc_back = true,
	steamc_start = true,
	
	steamc_unique_gyro = true,
	steamc_unique_roll = true,
	steamc_unique_tilt = true,
	steamc_unique_yaw = true,
	steamc_unique_grip_left = true,
	steamc_unique_grip_right = true,
	steamc_unique_system = true,

-- Steam Deck
	steamdeck_face_down = true,
	steamdeck_face_left = true,
	steamdeck_face_right = true,
	steamdeck_face_up = true,
	
	steamdeck_stick_left = true,
	steamdeck_stick_right = true,
	
	steamdeck_stickclick_left = true,
	steamdeck_stickclick_right = true,
	
	steamdeck_trigger_left = true,
	steamdeck_trigger_right = true,
	
	steamdeck_bumper_left = true,
	steamdeck_bumper_right = true,
	
	steamdeck_back = true,
	steamdeck_start = true,
	
	steamdeck_dpad= true,
	steamdeck_dpad_down = true,
	steamdeck_dpad_left = true,
	steamdeck_dpad_right = true,
	steamdeck_dpad_up = true,

	steamdeck_unique_dots = true,
	steamdeck_unique_gyro = true,
	steamdeck_unique_l4 = true,
	steamdeck_unique_l5 = true,
	steamdeck_unique_minus = true,
	steamdeck_unique_pad_left = true,
	steamdeck_unique_pad_right = true,
	steamdeck_unique_plus = true,
	steamdeck_unique_power = true,
	steamdeck_unique_r4 = true,
	steamdeck_unique_r5 = true,
	steamdeck_unique_steam = true,

-- Nintendo Switch / Switch Pro Controller
	switch_face_down = true,
	switch_face_left = true,
	switch_face_right = true,
	switch_face_up = true,
	
	switch_stick_left = true,
	switch_stick_right = true,
	
	switch_trigger_left = true,
	switch_trigger_right = true,
	
	switch_bumper_left = true,
	switch_bumper_right = true,
	
	switch_back = true,
	switch_start = true,
	
	switch_dpad= true,
	switch_dpad_down = true,
	switch_dpad_left = true,
	switch_dpad_right = true,
	switch_dpad_up = true,

	switch_unique_down = true,
	switch_unique_home = true,
	switch_unique_left = true,
	switch_unique_right = true,
	switch_unique_square = true,
	switch_unique_up = true,

-- Nintendo Wii U
	wiiu_face_down = true,
	wiiu_face_left = true,
	wiiu_face_right = true,
	wiiu_face_up = true,
	
	wiiu_stick_left = true,
	wiiu_stick_right = true,

	wiiu_trigger_left = true,
	wiiu_trigger_right = true,
	
	wiiu_bumper_left = true,
	wiiu_bumper_right = true,
	
	wiiu_back = true,
	wiiu_start = true,
	
	wiiu_dpad= true,
	wiiu_dpad_down = true,
	wiiu_dpad_left = true,
	wiiu_dpad_right = true,
	wiiu_dpad_up = true,

	wiiu_unique_1 = true,
	wiiu_unique_2 = true,
	wiiu_unique_power = true,

-- Xbox 360
	xbox360_face_down = true,
	xbox360_face_left = true,
	xbox360_face_right = true,
	xbox360_face_up = true,
	
	xbox360_stick_left = true,
	xbox360_stick_right = true,
	
	xbox360_stickclick_left = true,
	xbox360_stickclick_right = true,
	
	xbox360_trigger_left = true,
	xbox360_trigger_right = true,
	
	xbox360_bumper_left = true,
	xbox360_bumper_right = true,
	
	xbox360_back = true,
	xbox360_start = true,
	
	xbox360_dpad= true,
	xbox360_dpad_down = true,
	xbox360_dpad_left = true,
	xbox360_dpad_right = true,
	xbox360_dpad_up = true,

	xbox360_back_alt = true,
	xbox360_start_alt = true,

-- Xbox One
	xboxone_face_down = true,
	xboxone_face_left = true,
	xboxone_face_right = true,
	xboxone_face_up = true,
	
	xboxone_stick_left = true,
	xboxone_stick_right = true,
	
	xboxone_stickclick_left = true,
	xboxone_stickclick_right = true,
	
	xboxone_trigger_left = true,
	xboxone_trigger_right = true,
	
	xboxone_bumper_left = true,
	xboxone_bumper_right = true,
	
	xboxone_back = true,
	xboxone_start = true,
	
	xboxone_dpad= true,
	xboxone_dpad_down = true,
	xboxone_dpad_left = true,
	xboxone_dpad_right = true,
	xboxone_dpad_up = true,

-- Xbox Series X|S
	xboxseries_face_down = true,
	xboxseries_face_left = true,
	xboxseries_face_right = true,
	xboxseries_face_up = true,
	
	xboxseries_stick_left = true,
	xboxseries_stick_right = true,
	
	xboxseries_stickclick_left = true,
	xboxseries_stickclick_right = true,
	
	xboxseries_trigger_left = true,
	xboxseries_trigger_right = true,
	
	xboxseries_bumper_left = true,
	xboxseries_bumper_right = true,
	
	xboxseries_back = true,
	xboxseries_start = true,
	
	xboxseries_dpad= true,
	xboxseries_dpad_down = true,
	xboxseries_dpad_left = true,
	xboxseries_dpad_right = true,
	xboxseries_dpad_up = true,
	
	xboxseries_unique_share = true,
	
	]]--

	ps4_button_logo_lg =  true,
	ps4_button_options_lg =  true,
	ps4_button_share_lg =  true,
	ps4_l1_lg =  true,
	ps4_l2_lg =  true,
	-- ps4_l2_soft_lg =  true,
	ps4_r1_lg =  true,
	ps4_r2_lg =  true,
	-- ps4_r2_soft_lg =  true,
	ps4_trackpad_click_lg =  true,
	ps4_trackpad_down_lg =  true,
	ps4_trackpad_l_click_lg =  true,
	ps4_trackpad_l_down_lg =  true,
	ps4_trackpad_l_left_lg =  true,
	ps4_trackpad_l_right_lg =  true,
	ps4_trackpad_l_ring_lg =  true,
	ps4_trackpad_l_swipe_lg =  true,
	ps4_trackpad_l_touch_lg =  true,
	ps4_trackpad_l_up_lg =  true,
	ps4_trackpad_left_lg =  true,
	ps4_trackpad_lg =  true,
	ps4_trackpad_r_click_lg =  true,
	ps4_trackpad_r_down_lg =  true,
	ps4_trackpad_r_left_lg =  true,
	ps4_trackpad_r_right_lg =  true,
	ps4_trackpad_r_ring_lg =  true,
	ps4_trackpad_r_swipe_lg =  true,
	ps4_trackpad_r_touch_lg =  true,
	ps4_trackpad_r_up_lg =  true,
	ps4_trackpad_right_lg =  true,
	ps4_trackpad_ring_lg =  true,
	ps4_trackpad_swipe_lg =  true,
	ps4_trackpad_up_lg =  true,
	ps5_button_create_lg =  true,
	ps5_button_options_lg =  true,
	ps5_l1_lg =  true,
	ps5_l2_lg =  true,
	-- ps5_l2_soft_lg =  true,
	ps5_r1_lg =  true,
	ps5_r2_lg =  true,
	-- ps5_r2_soft_lg =  true,
	ps5_trackpad_click_lg =  true,
	ps5_trackpad_down_lg =  true,
	ps5_trackpad_l_click_lg =  true,
	ps5_trackpad_l_down_lg =  true,
	ps5_trackpad_l_left_lg =  true,
	ps5_trackpad_l_right_lg =  true,
	ps5_trackpad_l_ring_lg =  true,
	ps5_trackpad_l_swipe_lg =  true,
	ps5_trackpad_l_touch_lg =  true,
	ps5_trackpad_l_up_lg =  true,
	ps5_trackpad_left_lg =  true,
	ps5_trackpad_lg =  true,
	ps5_trackpad_r_click_lg =  true,
	ps5_trackpad_r_down_lg =  true,
	ps5_trackpad_r_left_lg =  true,
	ps5_trackpad_r_right_lg =  true,
	ps5_trackpad_r_ring_lg =  true,
	ps5_trackpad_r_swipe_lg =  true,
	ps5_trackpad_r_touch_lg =  true,
	ps5_trackpad_r_up_lg =  true,
	ps5_trackpad_right_lg =  true,
	ps5_trackpad_ring_lg =  true,
	ps5_trackpad_swipe_lg =  true,
	ps5_trackpad_up_lg =  true,
	ps_button_circle_lg =  true,
	ps_button_mute_lg =  true,
	ps_button_square_lg =  true,
	ps_button_triangle_lg =  true,
	ps_button_x_lg =  true,
	ps_color_button_circle_lg =  true,
	ps_color_button_square_lg =  true,
	ps_color_button_triangle_lg =  true,
	ps_color_button_x_lg =  true,
	ps_color_outlined_button_circle_lg =  true,
	ps_color_outlined_button_square_lg =  true,
	ps_color_outlined_button_triangle_lg =  true,
	ps_color_outlined_button_x_lg =  true,
	ps_dpad_down_lg =  true,
	ps_dpad_left_lg =  true,
	ps_dpad_lg =  true,
	ps_dpad_right_lg =  true,
	ps_dpad_up_lg =  true,
	ps_outlined_button_circle_lg =  true,
	ps_outlined_button_square_lg =  true,
	ps_outlined_button_triangle_lg =  true,
	ps_outlined_button_x_lg =  true,
	sc_button_l_arrow_lg =  true,
	sc_button_r_arrow_lg =  true,
	sc_button_steam_lg =  true,
	sc_dpad_click_lg =  true,
	sc_dpad_down_lg =  true,
	sc_dpad_left_lg =  true,
	sc_dpad_lg =  true,
	sc_dpad_right_lg =  true,
	sc_dpad_swipe_lg =  true,
	sc_dpad_touch_lg =  true,
	sc_dpad_up_lg =  true,
	sc_lb_lg =  true,
	sc_lg_lg =  true,
	sc_lt_click_lg =  true,
	sc_lt_lg =  true,
	-- sc_lt_soft_lg =  true,
	sc_rb_lg =  true,
	sc_rg_lg =  true,
	sc_rt_click_lg =  true,
	sc_rt_lg =  true,
	-- sc_rt_soft_lg =  true,
	sc_touchpad_click_lg =  true,
	sc_touchpad_down_lg =  true,
	sc_touchpad_edge_lg =  true,
	sc_touchpad_left_lg =  true,
	sc_touchpad_lg =  true,
	sc_touchpad_right_lg =  true,
	sc_touchpad_swipe_lg =  true,
	sc_touchpad_touch_lg =  true,
	sc_touchpad_up_lg =  true,
	sd_button_aux_lg =  true,
	sd_button_menu_lg =  true,
	sd_button_steam_lg =  true,
	sd_button_view_lg =  true,
	sd_l1_lg =  true,
	sd_l2_half_lg =  true,
	sd_l2_lg =  true,
	sd_l4_lg =  true,
	sd_l5_lg =  true,
	sd_ltrackpad_click_lg =  true,
	sd_ltrackpad_down_lg =  true,
	sd_ltrackpad_left_lg =  true,
	sd_ltrackpad_lg =  true,
	sd_ltrackpad_right_lg =  true,
	sd_ltrackpad_ring_lg =  true,
	sd_ltrackpad_swipe_lg =  true,
	sd_ltrackpad_up_lg =  true,
	sd_r1_lg =  true,
	sd_r2_half_lg =  true,
	sd_r2_lg =  true,
	sd_r4_lg =  true,
	sd_r5_lg =  true,
	sd_rtrackpad_click_lg =  true,
	sd_rtrackpad_down_lg =  true,
	sd_rtrackpad_left_lg =  true,
	sd_rtrackpad_lg =  true,
	sd_rtrackpad_right_lg =  true,
	sd_rtrackpad_ring_lg =  true,
	sd_rtrackpad_swipe_lg =  true,
	sd_rtrackpad_up_lg =  true,
	shared_button_a_lg =  true,
	shared_button_b_lg =  true,
	shared_button_x_lg =  true,
	shared_button_y_lg =  true,
	shared_buttons_e_lg =  true,
	shared_buttons_n_lg =  true,
	shared_buttons_s_lg =  true,
	shared_buttons_w_lg =  true,
	shared_color_button_a_lg =  true,
	shared_color_button_b_lg =  true,
	shared_color_button_x_lg =  true,
	shared_color_button_y_lg =  true,
	shared_color_outlined_button_a_lg =  true,
	shared_color_outlined_button_b_lg =  true,
	shared_color_outlined_button_x_lg =  true,
	shared_color_outlined_button_y_lg =  true,
	shared_dpad_down_lg =  true,
	shared_dpad_left_lg =  true,
	shared_dpad_lg =  true,
	shared_dpad_right_lg =  true,
	shared_dpad_up_lg =  true,
	shared_gyro_lg =  true,
	shared_gyro_pitch_lg =  true,
	shared_gyro_roll_lg =  true,
	shared_gyro_yaw_lg =  true,
	shared_l3_lg =  true,
	shared_lstick_click_lg =  true,
	shared_lstick_down_lg =  true,
	shared_lstick_left_lg =  true,
	shared_lstick_lg =  true,
	shared_lstick_right_lg =  true,
	shared_lstick_touch_lg =  true,
	shared_lstick_up_lg =  true,
	shared_mouse_4_lg =  true,
	shared_mouse_5_lg =  true,
	shared_mouse_l_click_lg =  true,
	shared_mouse_mid_click_lg =  true,
	shared_mouse_r_click_lg =  true,
	shared_mouse_scroll_down_lg =  true,
	shared_mouse_scroll_up_lg =  true,
	shared_outlined_button_a_lg =  true,
	shared_outlined_button_b_lg =  true,
	shared_outlined_button_x_lg =  true,
	shared_outlined_button_y_lg =  true,
	shared_r3_lg =  true,
	shared_rstick_click_lg =  true,
	shared_rstick_down_lg =  true,
	shared_rstick_left_lg =  true,
	shared_rstick_lg =  true,
	shared_rstick_right_lg =  true,
	shared_rstick_touch_lg =  true,
	shared_rstick_up_lg =  true,
	-- shared_touch_doubletap_lg =  true,
	-- shared_touch_lg =  true,
	-- shared_touch_tap_lg =  true,
	switchpro_button_capture_lg =  true,
	switchpro_button_home_lg =  true,
	switchpro_button_minus_lg =  true,
	switchpro_button_plus_lg =  true,
	switchpro_dpad_down_lg =  true,
	switchpro_dpad_left_lg =  true,
	switchpro_dpad_lg =  true,
	switchpro_dpad_right_lg =  true,
	switchpro_dpad_up_lg =  true,
	switchpro_l2_lg =  true,
	-- switchpro_l2_soft_lg =  true,
	switchpro_l_lg =  true,
	switchpro_lstick_click_lg =  true,
	switchpro_lstick_down_lg =  true,
	switchpro_lstick_left_lg =  true,
	switchpro_lstick_lg =  true,
	switchpro_lstick_right_lg =  true,
	switchpro_lstick_up_lg =  true,
	switchpro_r2_lg =  true,
	-- switchpro_r2_soft_lg =  true,
	switchpro_r_lg =  true,
	switchpro_rstick_click_lg =  true,
	switchpro_rstick_down_lg =  true,
	switchpro_rstick_left_lg =  true,
	switchpro_rstick_lg =  true,
	switchpro_rstick_right_lg =  true,
	switchpro_rstick_up_lg =  true,
	xbox360_button_select_lg =  true,
	xbox360_button_start_lg =  true,
	xbox_button_logo_lg =  true,
	xbox_button_select_lg =  true,
	xbox_button_share_lg =  true,
	xbox_button_start_lg =  true,
	xbox_lb_lg =  true,
	xbox_lt_lg =  true,
	-- xbox_lt_soft_lg =  true,
	xbox_p1_lg =  true,
	xbox_p2_lg =  true,
	xbox_p3_lg =  true,
	xbox_p4_lg =  true,
	xbox_rb_lg =  true,
	xbox_rt_lg =  true,
	-- xbox_rt_soft_lg =  true,

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

local lastupdate = 0
local arc9_controller_glyphset = GetConVar("arc9_controller_glyphset")
local function UpdateGlyphs()
    if lastupdate == FrameNumber() then
        return false
    end
    lastupdate = FrameNumber()

    local glyphset = arc9_controller_glyphset:GetString()
    if glyphset != "" then
        table.Empty(ARC9.CTRL_Set_UserCustom)
        local config = glyphset
        config = string.Split( config, "\\n" )
        for i, v in ipairs(config) do
            local swig = string.Split( v, "\\t" )
            ARC9.CTRL_Set_UserCustom[swig[1]] = swig[2]
        end
        ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_UserCustom
    else
        ARC9.CTRL_ConvertTo = ARC9.CTRL_Set_Xbox
    end

    return true
end

function CreateControllerKeyLine( info, ... )
    UpdateGlyphs()
    local args = { ... }
    local strlength = 0

    for i, v in ipairs( args ) do
        if IsColor(v) then
            surface.SetDrawColor(v)
            surface.SetTextColor(v)
        elseif isstring(v) then
            -- Draw text.
            surface.SetTextPos(info.x + strlength, info.y)
            surface.DrawText(v)
            strlength = strlength + surface.GetTextSize(v)
        elseif istable(v) then
            local size = v[2]
            if isstring(v[1]) and !ARC9.CTRL_Exists[v[1]] then
                -- Draw a key.
                surface.SetFont(info.font_keyb or "ARC9_KeybindPreview")
                local sx, sy = surface.GetTextSize(v[1])
                local keylength = math.max(sx + (info.size/2), info.size)
                surface.DrawOutlinedRect(info.x + strlength, info.y, keylength, info.size )
                surface.SetTextPos(info.x + strlength - (sx/2) + (keylength/2), info.y - (sy/2) + (info.size/2) )
                surface.DrawText( v[1] )
                surface.SetFont(info.font)
                strlength = strlength + keylength
            else
                -- Draw a controller input.
                surface.SetMaterial(v[1])
                surface.DrawTexturedRect( info.x + strlength, info.y - ((size - info.size)*0), size * 1.25, size * 1.25 )
                strlength = strlength + size
            end
        end
    end
    return strlength
end

-- Gets the size of the controller key line.
function GetControllerKeyLineSize( info, ... )
    UpdateGlyphs()
    local args = { ... }
    local strlength = 0

    for i, v in ipairs( args ) do
        if isstring(v) then
            strlength = strlength + surface.GetTextSize(v)
        elseif istable(v) then
            local size = v[2]
            if isstring(v[1]) and !ARC9.CTRL_Exists[v[1]] then
                surface.SetFont(info.font_keyb or "ARC9_KeybindPreview")
                local sx = surface.GetTextSize(v[1])
                local keylength = math.max(sx + (info.size/2), info.size)
                surface.SetFont(info.font)
                strlength = strlength + keylength
            else
                strlength = strlength + size
            end
        end
    end
    return strlength
end




function ARC9MultiLineText(text, maxw, font)
    local content = {}
    local tline = ""
    local x = 0
    surface.SetFont(font)

    local ts = surface.GetTextSize(" ")

    local newlined = string.Split(text, "\n")

    for _, line in ipairs(newlined) do
        local words = string.Split(line, " ")

        -- Keep track of the current color tag across lines
        local active_color_tag = nil

        for _, word in ipairs(words) do
            local tx = surface.GetTextSize(word)

            -- Don't count color tags for length purposes
            local match = {string.match(word, "<color=%d+,%d+,%d+>")}
            local matchend = {string.match(word, "</color>")}
            
            local matchfont = {string.match(word, "<font=^.*$>")}
            local matchfontend = {string.match(word, "</font>")}
            
            for _, v in ipairs(match) do
                tx = tx - surface.GetTextSize(v)
            end
            for _, v in ipairs(matchend) do
                tx = tx - surface.GetTextSize(v)
            end

            for _, v in ipairs(matchfont) do
                tx = tx - surface.GetTextSize(v)
            end
            for _, v in ipairs(matchfontend) do
                tx = tx - surface.GetTextSize(v)
            end

            -- if #match + #matchend > 0 then
            --     print(word, table.ToString(match), table.ToString(matchend))
            -- end

            if x + tx > maxw then
                local dashi = string.find(word, "-")
                if dashi and surface.GetTextSize(utf8.sub(word, 0, dashi)) <= maxw - x then
                    -- cut the word at the dash sign if possible
                    table.insert(content, tline .. utf8.sub(word, 0, dashi))
                    tline = ""
                    x = 0
                    word = utf8.sub(word, dashi + 1)
                    tx = surface.GetTextSize(word)
                else
                    -- move whole word to new line

                    -- close color tag
                    if active_color_tag != nil then
                        tline = tline .. "</color>"
                    end

                    table.insert(content, tline)
                    tline = ""
                    x = 0

                    -- reopen color tag
                    if active_color_tag != nil then
                        tline = tline .. active_color_tag
                    end
                end
            end

            -- Check the status of the color tag at the end of current word
            if math.abs(#match - #matchend) > 1 then
                ErrorNoHalt("<color> tag miscount!\n")
            elseif #match > #matchend then
                if active_color_tag != nil then
                    ErrorNoHalt("<color> tag miscount (too many opening tags)!\n")
                else
                    active_color_tag = match[#match]
                end
            elseif #matchend > #match then
                if active_color_tag == nil then
                    ErrorNoHalt("<color> tag miscount (too many closing tags)!\n")
                else
                    active_color_tag = nil
                end
            end

            tline = tline .. word .. " "

            x = x + tx + ts
        end

        -- close color tag
        if active_color_tag != nil then
            tline = tline .. "</color>"
        end

        table.insert(content, tline)
        tline = ""
        x = 0
    end

    return content
end


-- span: panel that hosts the rotating text
-- txt: the text to draw
-- x: where to start the crop
-- y: where to start the crp
-- tx, ty: where to draw the text
-- maxw: maximum width
-- only: don't advance text
function ARC9.DrawTextRot(span, txt, x, y, tx, ty, maxw, only)
    local tw, th = surface.GetTextSize(txt or "")

    span.TextRot = span.TextRot or {}

    if tw > maxw then
        local realx, realy = span:LocalToScreen(x, y)
        render.SetScissorRect(realx, realy, realx + maxw, realy + (th * 2), true)

        span.TextRot[txt] = span.TextRot[txt] or 0

        if !only then
            span.StartTextRot = span.StartTextRot or CurTime()
            span.TextRotState = span.TextRotState or 0 -- 0: start, 1: moving, 2: end
            if span.TextRotState == 0 then
                span.TextRot[txt] = 0
                if span.StartTextRot < CurTime() - 2 then
                    span.TextRotState = 1
                end
            elseif span.TextRotState == 1 then
                span.TextRot[txt] = span.TextRot[txt] + (FrameTime() * ARC9ScreenScale(16))
                if span.TextRot[txt] >= (tw - maxw) + ARC9ScreenScale(8) then
                    span.StartTextRot = CurTime()
                    span.TextRotState = 2
                end
            elseif span.TextRotState == 2 then
                if span.StartTextRot < CurTime() - 2 then
                    span.TextRotState = 3
                    span.StartTextRot = CurTime()
                end
            elseif span.TextRotState == 3 then
                span.TextRot[txt] = span.TextRot[txt] - (FrameTime() * ARC9ScreenScale(16))
                if span.TextRot[txt] <= 0 then
                    span.StartTextRot = CurTime()
                    span.TextRotState = 0
                end
            end
        end
        surface.SetTextPos(tx - span.TextRot[txt], ty)
        surface.DrawText(txt)
        render.SetScissorRect(0, 0, 0, 0, false)
    else
        surface.SetTextPos(tx, ty)
        surface.DrawText(txt)
    end
end
